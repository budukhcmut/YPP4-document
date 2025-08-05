USE MsList;
GO
--
-- tự động tăng thứ tự display order cho list view mới trong 1 list 
CREATE OR ALTER TRIGGER trg_AdjustListViewDisplayOrder
ON ListView
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo bảng tạm để lưu các ListId bị ảnh hưởng
    DECLARE @AffectedLists TABLE (ListId INT);

    -- Lấy các ListId từ inserted hoặc updated
    INSERT INTO @AffectedLists (ListId)
    SELECT ListId
    FROM inserted
    UNION
    SELECT ListId
    FROM deleted;

    -- Cập nhật DisplayOrder cho từng ListId bị ảnh hưởng
    WITH RankedListViews AS (
        SELECT 
            Id,
            ListId,
            ROW_NUMBER() OVER (PARTITION BY ListId ORDER BY DisplayOrder, Id) - 1 AS NewDisplayOrder
        FROM ListView
        WHERE ListId IN (SELECT ListId FROM @AffectedLists)
    )
    UPDATE ListView
    SET DisplayOrder = rlv.NewDisplayOrder
    FROM ListView lv
    INNER JOIN RankedListViews rlv ON lv.Id = rlv.Id
    WHERE lv.DisplayOrder != rlv.NewDisplayOrder;
END;
GO

-- Auto-create a default "All Items" list view (type: List)
-- If the list type is Board, Gallery, Calendar, or Form, 
-- also create a view matching the list type
CREATE OR ALTER TRIGGER trg_CreateDefaultListView
ON List
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo ListView mặc định "All Items" với ViewType là 'List' và DisplayOrder = 0
    DECLARE @ListViewTypeId INT;
    SELECT @ListViewTypeId = Id FROM ViewType WHERE Title = 'List';

    IF @ListViewTypeId IS NOT NULL
    BEGIN
        INSERT INTO ListView (ListId, CreatedBy, ViewTypeId, ViewName, DisplayOrder)
        SELECT 
            i.Id,
            i.CreatedBy,
            @ListViewTypeId,
            'All Items',
            0
        FROM inserted i;
    END
    ELSE
    BEGIN
        RAISERROR ('ViewType "List" not found in ViewType table.', 16, 1);
    END

    -- Tạo ListView bổ sung nếu ListType không phải là 'List' với DisplayOrder = 1
    INSERT INTO ListView (ListId, CreatedBy, ViewTypeId, ViewName, DisplayOrder)
    SELECT 
        i.Id,
        i.CreatedBy,
        vt.Id,
        lt.Title,
        1
    FROM inserted i
    INNER JOIN ListType lt ON i.ListTypeId = lt.Id
    INNER JOIN ViewType vt ON lt.Title = vt.Title
    WHERE lt.Title != 'List' AND vt.Id IS NOT NULL;
END;
GO

-- tự động gán quyền 'OWNER' cho người mới tạo list đó
CREATE OR ALTER TRIGGER trg_AssignOwnerToListCreator
ON List
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OwnerPermissionId INT;
    DECLARE @OwnerPermissionCode NVARCHAR(50);

    -- Lấy thông tin quyền OWNER
    SELECT 
        @OwnerPermissionId = Id,
        @OwnerPermissionCode = PermissionCode
    FROM Permission 
    WHERE PermissionCode = 'OWNER';

    IF @OwnerPermissionId IS NULL
    BEGIN
        RAISERROR('Permission "OWNER" not found in Permission table.', 16, 1);
        RETURN;
    END

    -- Thêm vào bảng ListMemberPermission
    INSERT INTO ListMemberPermission (
        ListId,
        AccountId,
        HighestPermissionId,
        HighestPermissionCode,
        GrantedByAccountId,
        Note,
        CreateAt,
        UpdateAt
    )
    SELECT 
        i.Id,
        i.CreatedBy,
        @OwnerPermissionId,
        @OwnerPermissionCode,
        i.CreatedBy,
        N'List creator',
        GETDATE(),
        GETDATE()
    FROM inserted i;
END;
GO

-- Create a trigger to enforce the constraint
CREATE OR ALTER TRIGGER TRG_FavoriteList_PermissionCheck
ON FavoriteList
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if inserted/updated rows have corresponding permissions in ListMemberPermission
    IF EXISTS (
        SELECT i.ListId, i.FavoriteListOfUser
        FROM inserted i
        LEFT JOIN ListMemberPermission lmp
            ON lmp.ListId = i.ListId
            AND lmp.AccountId = i.FavoriteListOfUser
        WHERE lmp.ListId IS NULL
    )
    BEGIN
        RAISERROR ('Cannot add list to FavoriteList. User must have permissions for the list in ListMemberPermission.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- trigger tự động tạo Dynamic Column từ System Column
CREATE OR ALTER TRIGGER tr_CreateDynamicColumnsOnListInsert
ON List
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @ListId INT;
    DECLARE @SystemColumnId INT;
    DECLARE @SystemDataTypeId INT;
    DECLARE @ColumnName NVARCHAR(100);
    DECLARE @DisplayOrder INT;
    DECLARE @CreatedBy INT;
    DECLARE @DataTypeSettingKeyId INT;
    DECLARE @KeyValue NVARCHAR(255);

    -- Cursor to iterate through inserted List records
    DECLARE list_cursor CURSOR FOR
    SELECT Id, CreatedBy FROM inserted;

    OPEN list_cursor;
    FETCH NEXT FROM list_cursor INTO @ListId, @CreatedBy;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Cursor to iterate through SystemColumn records
        DECLARE system_column_cursor CURSOR FOR
        SELECT Id, SystemDataTypeId, ColumnName, DisplayOrder
        FROM SystemColumn;

        OPEN system_column_cursor;
        FETCH NEXT FROM system_column_cursor INTO @SystemColumnId, @SystemDataTypeId, @ColumnName, @DisplayOrder;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Insert into ListDynamicColumn
            INSERT INTO ListDynamicColumn (
                ListId,
                SystemDataTypeId,
                SystemColumnId,
                ColumnName,
                DisplayOrder,
                IsSystemColumn,
                IsVisible,
                CreatedBy,
                CreatedAt
            )
            VALUES (
                @ListId,
                @SystemDataTypeId,
                @SystemColumnId,
                @ColumnName,
                @DisplayOrder,
                1, -- IsSystemColumn = 1 since it's copied from SystemColumn
                CASE WHEN @ColumnName = 'Title' THEN 1 ELSE 0 END, -- IsVisible = 1 for 'Title', 0 for others
                @CreatedBy,
                GETDATE()
            );

            -- Get the newly inserted ListDynamicColumn Id
            DECLARE @NewDynamicColumnId INT;
            SET @NewDynamicColumnId = SCOPE_IDENTITY();

            -- Cursor to iterate through SystemColumnSettingValue for the current SystemColumn
            DECLARE setting_cursor CURSOR FOR
            SELECT DataTypeSettingKeyId, KeyValue
            FROM SystemColumnSettingValue
            WHERE SystemColumnId = @SystemColumnId;

            OPEN setting_cursor;
            FETCH NEXT FROM setting_cursor INTO @DataTypeSettingKeyId, @KeyValue;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Insert into DynamicColumnSettingValue
                INSERT INTO DynamicColumnSettingValue (
                    DynamicColumnId,
                    DataTypeSettingKey,
                    KeyValue,
                    CreateAt,
                    UpdateAt
                )
                VALUES (
                    @NewDynamicColumnId,
                    @DataTypeSettingKeyId,
                    @KeyValue,
                    GETDATE(),
                    GETDATE()
                );

                FETCH NEXT FROM setting_cursor INTO @DataTypeSettingKeyId, @KeyValue;
            END;

            CLOSE setting_cursor;
            DEALLOCATE setting_cursor;

            FETCH NEXT FROM system_column_cursor INTO @SystemColumnId, @SystemDataTypeId, @ColumnName, @DisplayOrder;
        END;

        CLOSE system_column_cursor;
        DEALLOCATE system_column_cursor;

        FETCH NEXT FROM list_cursor INTO @ListId, @CreatedBy;
    END;

    CLOSE list_cursor;
    DEALLOCATE list_cursor;
END;
