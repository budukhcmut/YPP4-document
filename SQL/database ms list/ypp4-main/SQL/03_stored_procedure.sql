USE MsList
GO 

-- SP to auto-increment display order for list view
CREATE OR ALTER PROCEDURE GetNextDisplayOrderForListView
    @ListId INT,
    @NextDisplayOrder INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Input validation
    IF @ListId IS NULL
    BEGIN
        RAISERROR ('ListId cannot be null.', 16, 1);
        RETURN;
    END;

    -- Calculate next DisplayOrder, starting at 1
    SELECT @NextDisplayOrder = ISNULL(MAX(DisplayOrder), 0) + 1
    FROM ListView
    WHERE ListId = @ListId;
END;
GO

-- SP to auto-create default list view for a list
-- use: GetNextDisplayOrderForListView
CREATE OR ALTER PROCEDURE CreateDefaultListViewsForList
    @ListId INT,
    @ListTypeId INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @ListTypeTitle NVARCHAR(255);
    DECLARE @ViewTypeId INT;
    DECLARE @AdditionalViewTypeId INT;
    DECLARE @NextDisplayOrder INT;

    -- Input validation
    IF @ListId IS NULL OR @ListTypeId IS NULL OR @CreatedBy IS NULL
    BEGIN
        RAISERROR ('ListId, ListTypeId, and CreatedBy cannot be null.', 16, 1);
        RETURN;
    END;

    -- Validate ListTypeId
    SELECT @ListTypeTitle = Title
    FROM ListType
    WHERE Id = @ListTypeId;

    IF @ListTypeTitle IS NULL
    BEGIN
        RAISERROR ('Invalid ListTypeId.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

        -- Create default "All Items" view
        SELECT @ViewTypeId = Id
        FROM ViewType
        WHERE Title = 'list';

        IF @ViewTypeId IS NULL
        BEGIN
            RAISERROR ('ViewType with Title = ''list'' not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Get DisplayOrder for "All Items" view
        EXEC GetNextDisplayOrderForListView @ListId = @ListId, @NextDisplayOrder = @NextDisplayOrder OUTPUT;

        INSERT INTO ListView (
            ListId,
            CreatedBy,
            ViewTypeId,
            ViewName,
            DisplayOrder
        )
        VALUES (
            @ListId,
            @CreatedBy,
            @ViewTypeId,
            'All Items',
            @NextDisplayOrder
        );

        -- Create additional view for Board, Gallery, Calendar, or Form
        SET @AdditionalViewTypeId = NULL;
        SELECT @AdditionalViewTypeId = Id
        FROM ViewType
        WHERE Title = CASE @ListTypeTitle
                        WHEN 'Board' THEN 'Board'
                        WHEN 'Gallery' THEN 'Gallery'
                        WHEN 'Calendar' THEN 'Calendar'
                        WHEN 'Form' THEN 'Form'
                        ELSE NULL
                      END;

        IF @AdditionalViewTypeId IS NOT NULL
        BEGIN
            -- Get DisplayOrder for additional view
            EXEC GetNextDisplayOrderForListView @ListId = @ListId, @NextDisplayOrder = @NextDisplayOrder OUTPUT;

            INSERT INTO ListView (
                ListId,
                CreatedBy,
                ViewTypeId,
                ViewName,
                DisplayOrder
            )
            VALUES (
                @ListId,
                @CreatedBy,
                @AdditionalViewTypeId,
                @ListTypeTitle,
                @NextDisplayOrder
            );
        END;

        -- Commit transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Roll back transaction on error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- SP to create a new list view for a list
CREATE OR ALTER PROCEDURE CreateListViewForList
    @ListId INT,
    @ViewTypeId INT,
    @ViewName NVARCHAR(255),
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @NextDisplayOrder INT;

    -- Input validation
    IF @ListId IS NULL OR @ViewTypeId IS NULL OR @ViewName IS NULL OR @CreatedBy IS NULL
    BEGIN
        RAISERROR ('ListId, ViewTypeId, ViewName, and CreatedBy cannot be null.', 16, 1);
        RETURN;
    END;

    -- Validate ViewTypeId
    IF NOT EXISTS (SELECT 1 FROM ViewType WHERE Id = @ViewTypeId)
    BEGIN
        RAISERROR ('Invalid ViewTypeId.', 16, 1);
        RETURN;
    END;

    -- Validate ListId
    IF NOT EXISTS (SELECT 1 FROM List WHERE Id = @ListId)
    BEGIN
        RAISERROR ('Invalid ListId.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

        -- Get next DisplayOrder
        EXEC GetNextDisplayOrderForListView @ListId = @ListId, @NextDisplayOrder = @NextDisplayOrder OUTPUT;

        -- Create new ListView
        INSERT INTO ListView (
            ListId,
            CreatedBy,
            ViewTypeId,
            ViewName,
            DisplayOrder
        )
        VALUES (
            @ListId,
            @CreatedBy,
            @ViewTypeId,
            @ViewName,
            @NextDisplayOrder
        );

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return result
        SELECT SCOPE_IDENTITY() AS NewListViewId, 'ListView created successfully.' AS Message;
    END TRY
    BEGIN CATCH
        -- Roll back transaction on error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- SP to auto-generate dynamic columns for a new list from existing system columns
CREATE OR ALTER PROCEDURE CreateDynamicColumnsForList
    @ListId INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Input validation
    IF @ListId IS NULL OR @CreatedBy IS NULL
    BEGIN
        RAISERROR ('ListId and CreatedBy cannot be null.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

        -- Create dynamic columns from SystemColumn
        INSERT INTO ListDynamicColumn (
            ListId,
            SystemDataTypeId,
            SystemColumnId,
            ColumnName,
            ColumnDescription,
            DisplayOrder,
            IsSystemColumn,
            IsVisible,
            CreatedBy,
            CreatedAt
        )
        SELECT 
            @ListId,
            SystemDataTypeId,
            Id,
            ColumnName,
            NULL, -- ColumnDescription can be customized
            DisplayOrder,
            1, -- System column
            1, -- Visible by default
            @CreatedBy,
            GETDATE()
        FROM SystemColumn;

        -- Copy column settings
        INSERT INTO DynamicColumnSettingValue (
            DynamicColumnId,
            DataTypeSettingKey,
            KeyValue,
            CreateAt,
            UpdateAt
        )
        SELECT 
            ldc.Id,
            scsv.DataTypeSettingKeyId,
            scsv.KeyValue,
            GETDATE(),
            GETDATE()
        FROM SystemColumnSettingValue scsv
        INNER JOIN SystemColumn sc ON scsv.SystemColumnId = sc.Id
        INNER JOIN ListDynamicColumn ldc ON ldc.SystemColumnId = sc.Id
        WHERE ldc.ListId = @ListId;

        -- Commit transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Roll back transaction on error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- SP to create a new list
-- use: CreateDefaultListViewsForList / CreateDynamicColumnsForList
CREATE OR ALTER PROCEDURE CreateList
    @ListTypeId INT,
    @ListTemplateId INT = NULL,
    @ListName NVARCHAR(255),
    @Icon NVARCHAR(100) = NULL,
    @Color NVARCHAR(50) = NULL,
    @CreatedBy INT,
    @ListStatus NVARCHAR(50) = 'Active'
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @NewListId INT;

    -- Input validation
    IF @ListTypeId IS NULL OR @ListName IS NULL OR @CreatedBy IS NULL
    BEGIN
        RAISERROR ('ListTypeId, ListName, and CreatedBy cannot be null.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

        -- Create new list
        INSERT INTO List (
            ListTypeId,
            ListTemplateId,
            ListName,
            Icon,
            Color,
            CreatedBy,
            CreatedAt,
            ListStatus
        )
        VALUES (
            @ListTypeId,
            @ListTemplateId,
            @ListName,
            @Icon,
            @Color,
            @CreatedBy,
            GETDATE(),
            @ListStatus
        );

        -- Get ID of the new list
        SET @NewListId = SCOPE_IDENTITY();

        -- Call SP to create dynamic columns
        EXEC CreateDynamicColumnsForList @ListId = @NewListId, @CreatedBy = @CreatedBy;

        -- Call SP to create list views
        EXEC CreateDefaultListViewsForList @ListId = @NewListId, @ListTypeId = @ListTypeId, @CreatedBy = @CreatedBy;

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return result
        SELECT @NewListId AS NewListId, 'List created successfully.' AS Message;
    END TRY
    BEGIN CATCH
        -- Roll back transaction on error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- SP to re-order list views after one is deleted from a list
CREATE OR ALTER PROCEDURE UpdateDisplayOrderAfterListViewDeletion
    @ListId INT,
    @ListViewId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Input validation
    IF @ListId IS NULL OR @ListViewId IS NULL
    BEGIN
        RAISERROR ('ListId and ListViewId cannot be null.', 16, 1);
        RETURN;
    END;

    -- Validate ListId
    IF NOT EXISTS (SELECT 1 FROM List WHERE Id = @ListId)
    BEGIN
        RAISERROR ('Invalid ListId.', 16, 1);
        RETURN;
    END;

    -- Validate ListViewId
    IF NOT EXISTS (SELECT 1 FROM ListView WHERE Id = @ListViewId AND ListId = @ListId)
    BEGIN
        RAISERROR ('Invalid ListViewId or does not belong to the specified ListId.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        -- Begin transaction
        BEGIN TRANSACTION;

        -- Delete the specified ListView
        DELETE FROM ListView
        WHERE Id = @ListViewId AND ListId = @ListId;

        -- Resequence DisplayOrder for remaining ListViews
        WITH OrderedListViews AS (
            SELECT 
                Id,
                ROW_NUMBER() OVER (ORDER BY DisplayOrder) AS NewDisplayOrder
            FROM ListView
            WHERE ListId = @ListId
        )
        UPDATE lv
        SET DisplayOrder = olv.NewDisplayOrder
        FROM ListView lv
        INNER JOIN OrderedListViews olv ON lv.Id = olv.Id
        WHERE lv.ListId = @ListId;

        -- Commit transaction
        COMMIT TRANSACTION;

        -- Return result
        SELECT 'ListView deleted and DisplayOrder resequenced successfully.' AS Message;
    END TRY
    BEGIN CATCH
        -- Roll back transaction on error
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

--- EXECUTE ---
EXEC CreateList
    @ListTypeId = 2, -- ListType.Title = 'Board'
    @ListName = 'Kanban Board',
    @CreatedBy = 100,
    @Icon = 'board-icon.png',
    @Color = '#00FF00',
    @ListStatus = 'Active';
EXEC CreateListViewForList
    @ListId = 1,
    @ViewTypeId = 3, -- ViewType.Title = 'Gallery'
    @ViewName = 'Custom Gallery View',
    @CreatedBy = 100;
EXEC UpdateDisplayOrderAfterListViewDeletion
    @ListId = 1,
    @ListViewId = 2;