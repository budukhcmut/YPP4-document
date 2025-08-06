-- Get all current list members
    DECLARE @ListId INT;
    SET @ListId = 1;
    SELECT 
        a.Avatar,
        a.FirstName,
        a.LastName,
        lmp.HighestPermissionId
    FROM 
        ListMemberPermission lmp
    LEFT JOIN 
        Account a ON a.Id = lmp.AccountId
    WHERE 
        lmp.ListId = @ListId
    ORDER BY
        lmp.UpdatedAt
    
    -- Get all sharelinks of a list and its shared account
    DECLARE @ListId INT;
    SET @ListId = 1;
    SELECT 
        sl.Id, sl.TargetUrl, p.PermissionName, s.Icon, a.Avatar, slua.AccountId, slua.Email
    FROM 
        ShareLink sl
    INNER JOIN 
        Scope s ON sl.ScopeId = s.Id
    INNER JOIN 
        Permission p ON sl.PermissionId = p.Id
    LEFT JOIN 
        ShareLinkUserAccess slua ON sl.Id = slua.ShareLinkId AND s.Code != 'AUTHORIZED'
    LEFT JOIN 
        Account a ON slua.AccountId = a.Id
    WHERE 
        sl.ListId = @ListId 
    ORDER BY
        sl.ScopeId ASC,
        sl.PermissionId DESC

   -- Get all settings of a sharelink
    DECLARE @ShareLinkId INT;
    SET @ShareLinkId = 1;
    SELECT 
        ks.Id, ks.KeyName, ks.Icon, ks.ValueType, ks.ValueOfDefault, slsv.KeyValue
    FROM 
        KeySetting ks
    LEFT JOIN 
        ShareLinkSettingValue slsv 
            ON ks.Id = slsv.KeySettingId 
            AND slsv.ShareLinkId = @ShareLinkId
    WHERE 
        ks.IsShareLinkSetting = 1

-- SCREEN: TRASH 
-- Get all trash items of a user based on createdBy of original object
    DECLARE @AccountId INT;
    SET @AccountId = 1;

    SELECT 
        ti.Id, 
        ti.ObjectId, 
        ti.ObjectTypeId, 
        ot.Icon, 
        ti.UserDeleteId, 
        ti.DeletedAt,
        -- Optional: Show who originally created the object
        COALESCE(l.CreatedBy, lr.CreatedBy, lr_for_file.CreatedBy) AS OriginalCreatedBy
    FROM 
        TrashItem ti
    INNER JOIN
        ObjectType ot ON ti.ObjectTypeId = ot.Id
    LEFT JOIN
        List l ON ti.ObjectId = l.Id AND ti.ObjectTypeId = 1 -- LIST
    LEFT JOIN
        ListRow lr ON ti.ObjectId = lr.Id AND ti.ObjectTypeId = 2 -- LISTROW
    LEFT JOIN
        FileAttachment fa ON ti.ObjectId = fa.Id AND ti.ObjectTypeId = 3 -- FILE
    LEFT JOIN
        ListRow lr_for_file ON fa.ListRowId = lr_for_file.Id AND ti.ObjectTypeId = 3 -- JOIN ListRow for FileAttachment
    WHERE
        (
            (ti.ObjectTypeId = 1 AND l.CreatedBy = @AccountId) OR
            (ti.ObjectTypeId = 2 AND lr.CreatedBy = @AccountId) OR  
            (ti.ObjectTypeId = 3 AND lr_for_file.CreatedBy = @AccountId)
        )
    ORDER BY
        ti.DeletedAt

 -- Get sample data of a template
    DECLARE @TemplateId INT;
    SET @TemplateId = 1;
    SELECT
        tcol.Id AS colId,
        tcol.ColumnName,
        sdt.Icon AS DataTypeIcon,
        trow.Id rowid,
        tcell.CellValue
    FROM 
        TemplateColumn tcol
    INNER JOIN
        SystemDataType sdt ON tcol.SystemDataTypeId = sdt.Id
    INNER JOIN
        TemplateSampleRow trow ON tcol.ListTemplateId = trow.ListTemplateId
    LEFT JOIN 
        TemplateSampleCell tcell 
            ON tcol.Id = tcell.TemplateColumnId 
            AND trow.Id = tcell.TemplateSampleRowId
    WHERE 
        tcol.ListTemplateId = @TemplateId
    ORDER BY
        tcol.DisplayOrder ASC,
        trow.DisplayOrder ASC,

    -- Get all views of a template and their setting value
    DECLARE @TemplateId INT;
    SET @TemplateId = 2;
    SELECT
        tv.Id AS TemplateViewId, 
        tv.ViewName, 
        tv.ViewTypeId,
        vt.Icon, 
        vs.SettingKey,
        tvs.GroupByColumnId, 
        tvs.RawValue
    FROM 
        TemplateView tv
    INNER JOIN
        ViewType vt ON tv.ViewTypeId = vt.Id
    LEFT JOIN 
        TemplateViewSettingValue tvs ON tv.Id = tvs.TemplateViewId
    LEFT JOIN 
        ViewTypeSettingKey vts ON tvs.ViewTypeSettingId = vts.Id
    LEFT JOIN
        ViewSettingKey vs ON vts.ViewSettingKeyId = vs.Id
    WHERE
        tv.ListTemplateId = @TemplateId
    ORDER BY
        tv.DisplayOrder ASC


    -- Get all columns of a template and their setting value
    DECLARE @TemplateId INT;
    SET @TemplateId = 1;
    SELECT
        tc.Id, tc.ColumnName, sdt.Icon, ks.KeyName, ks.ValueType, tcsv.KeyValue
    FROM 
        TemplateColumn tc
    INNER JOIN
        SystemDataType sdt ON tc.SystemDataTypeId = sdt.Id
    LEFT JOIN
        TemplateColumnSettingValue tcsv ON tc.Id = tcsv.TemplateColumnId
    LEFT JOIN 
        DataTypeSettingKey dtsk ON tcsv.DataTypeSettingKeyId = dtsk.Id
    LEFT JOIN 
        KeySetting ks ON dtsk.KeySettingId =  ks.Id
    WHERE 
        tc.ListTemplateId = @TemplateId
    ORDER BY
        tc.DisplayOrder ASC
    