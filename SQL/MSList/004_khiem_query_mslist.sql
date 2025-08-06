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