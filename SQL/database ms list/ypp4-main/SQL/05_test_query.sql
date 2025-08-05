USE MsList
GO

------------------------------------------
-- DASHBOARD SCREEN --

-- 1. Display all lists that the logged-in user created or were shared with them
-- 2. Display all lists that the logged-in user created
-- 3. Display information of the logged-in user
-- 4. Display favorite lists of the logged-in user

-- 1. Display all lists that the logged-in user created or were shared with them
DECLARE @UserId INT = 2;  -- Replace with the ID of the logged-in user

SELECT DISTINCT 
    l.ListName,
	l.Icon,
	l.Color, 
    lmp.HighestPermissionCode, -- Extra
    lmp.GrantedByAccountId -- Extra
FROM List l
LEFT JOIN ListMemberPermission lmp ON l.Id = lmp.ListId AND lmp.AccountId = @UserId -- JOIN is still used because the creator will be added to ListMemberPermission
WHERE l.CreatedBy = @UserId 
    OR lmp.Id IS NOT NULL
    AND l.ListStatus = 'Active';
GO

-- 2. Display all lists that the logged-in user created
DECLARE @UserId INT = 2; 
SELECT 
    l.ListName,
	l.Icon,
	l.Color
FROM List l
WHERE l.CreatedBy = @UserId
    AND l.ListStatus = 'Active';
GO

-- 3. Display information of the logged-in user
DECLARE @UserId INT = 2;

SELECT 
    a.Id,
    a.FirstName,
    a.LastName,
    a.Avatar,
    a.Email,
    a.Company,
    a.AccountStatus
FROM Account a
WHERE a.Id = @UserId;
GO

-- 4. Display favorite lists of the logged-in user
DECLARE @UserId INT = 2;  -- Replace with the ID of the logged-in user

SELECT 
    l.ListName,
	l.Icon,
	l.Color
FROM FavoriteList fl
INNER JOIN List l ON fl.ListId = l.Id
WHERE fl.FavoriteListOfUser = @UserId
    AND l.ListStatus = 'Active'
ORDER BY fl.CreateAt DESC;
GO

------------------------------------------
-- LIST TYPE SELECTION SCREEN FOR CREATING A NEW LIST --

-- 1. Display all list types for selection
SELECT 
    Title,
    ListTypeDescription,
    HeaderImage
FROM ListType
ORDER BY Title;

-- 2. Display all templates 
SELECT 
    lt.Title,
    lt.HeaderImage,
    lt.Sumary
FROM ListTemplate lt
ORDER BY lt.Title;

------------------------------------------
-- LIST TYPE SELECTION SCREEN FOR CREATING A NEW LIST --
-- 1. Display information of the list type selected by the user
DECLARE @ListTypeId INT = 3;  -- Replace with the ID selected by the user

SELECT 
    Title,
    Icon,
    ListTypeDescription,
    HeaderImage
FROM ListType
WHERE Id = @ListTypeId;
GO

------------------------------------------
-- TEMPLATE SELECTION SCREEN FOR CREATING A NEW LIST BASED ON A TEMPLATE --
-- 1. Display all templates
-- 2. Display information of the selected template
-- 3. Display sample data for the selected template (Not yet implemented)

-- 1. Display all templates 
SELECT 
    lt.Title,
    lt.HeaderImage,
    lt.Sumary
FROM ListTemplate lt
ORDER BY lt.Title;

-- 2. Display information of the selected template
DECLARE @TemplateId INT = 5;  -- Replace with the ID of the template to view

SELECT 
    lt.Title,
    lt.HeaderImage,
    lt.TemplateDescription,
    lt.Icon,
    lt.Color,
    lt.Sumary,
    lt.Feature
FROM ListTemplate lt
WHERE lt.Id = @TemplateId;
GO

----------------------------------------
------------ LIST SCREEN 
-- 1. Display List information 
-- 2. Display all list views of the selected list
-- 3. Display visible Dynamic Columns
-- 4. Display all Dynamic Columns
-- 5. Display avatars of users with access to the list 

-- 1. Display List information
DECLARE @UserId INT = 2;
DECLARE @ListId INT = 2;

-- Check access permission
IF EXISTS (
    SELECT 1
    FROM ListMemberPermission
    WHERE ListId = @ListId AND AccountId = @UserId
)
BEGIN
    -- User has access: show list info
    SELECT 
        l.Id AS ListId,
        l.ListName,
        CASE 
            WHEN l.CreatedBy = @UserId THEN 'My List'
            ELSE NULL
        END AS Ownership,
        CASE 
            WHEN f.Id IS NOT NULL THEN 'Yes'
            ELSE 'No'
        END AS IsFavorite,
        'Has access' AS AccessStatus
    FROM List l
    LEFT JOIN FavoriteList f 
        ON l.Id = f.ListId AND f.FavoriteListOfUser = @UserId
    WHERE l.Id = @ListId;
END
ELSE
BEGIN
    -- User has no access: return notice
    SELECT 
        NULL AS ListId,
        NULL AS ListName,
        NULL AS Ownership,
        NULL AS IsFavorite,
        'No access' AS AccessStatus;
END
GO

-- 2. Display all list views of the selected list
DECLARE @UserId INT = 2;
DECLARE @ListId INT = 2;

-- Check if the user has access
IF EXISTS (
    SELECT 1 
    FROM ListMemberPermission 
    WHERE ListId = @ListId AND AccountId = @UserId
)
BEGIN
    -- User has access: show all views of the list
		SELECT
			lv.Id,
			lv.ListId,
			lv.ViewName,
			lv.DisplayOrder
		FROM ListView lv
		WHERE lv.ListId = @ListId
		ORDER BY lv.DisplayOrder;
END
ELSE
BEGIN
    -- User has no access
    SELECT 
        NULL AS ListViewId,
        NULL AS ViewName,
        NULL AS ViewType,
        NULL AS DisplayOrder,
        NULL AS IsDefault,
        NULL AS CreatedAt,
        'No access to this list' AS AccessStatus;
END
GO
-- 3. Display visible Dynamic Columns
DECLARE @ListId INT = 2; 

SELECT  
	sd.Icon,
	dc.ColumnName,
	dc.IsVisible,
	dc.DisplayOrder
FROM ListDynamicColumn dc
JOIN SystemDataType sd ON dc.SystemDataTypeId = sd.Id
WHERE dc.ListId = @ListId
	AND dc.IsVisible = 1
ORDER BY dc.DisplayOrder;
GO 

-- 4. Display all Dynamic Columns
DECLARE @ListId INT = 2; 

SELECT  
	dc.ColumnName,
	dc.IsVisible,
	dc.DisplayOrder
FROM ListDynamicColumn dc
WHERE dc.ListId = @ListId
ORDER BY dc.DisplayOrder;
GO 

-- 5. Display avatars of users with access to the list 
DECLARE @ListId INT = 2; 
SELECT
	a.Avatar, 
	a.FirstName
FROM ListMemberPermission lmp
JOIN Account A on lmp.AccountId = a.Id
WHERE lmp.ListId = @ListId
GO

----------------------------------------
------------ ADD COLUMN SCREEN ---------
-- 1. Display all Data Types of the Column.
-- 2. Display Key Settings corresponding to that Data Type.
-----------------------------------------
-- 1. Display all Data Types of the Column.
SELECT
	sd.CoverImg,
	sd.DataTypeDescription,
	sd.Icon,
	sd.DisplayName
FROM SystemDataType sd
GO

-- 2. Display Key Settings corresponding to that Data Type.
DECLARE @SystemDataTypeId INT = 1;
SELECT 
	sd.DisplayName,
	ks.KeyName,
	ks.ValueType
FROM KeySetting ks 
JOIN DataTypeSettingKey dsk ON ks.Id = dsk.KeySettingId
JOIN SystemDataType sd ON dsk.SystemDataTypeId = sd.Id
WHERE dsk.SystemDataTypeId = @SystemDataTypeId

------------------



