
USE GoogleDrive
GO

-- Home screen
-- 1.SELECT User information
DECLARE @userId INT = 1
SELECT 
	a.UserName AS UserName,
	a.Email AS Email
FROM Account a
WHERE a.UserId = @userId 

-- 2.SELECT User Setting
DECLARE @userId INT = 1;
SELECT 
	su.SettingUserId,
	a.UserName AS UserName,
	s.SettingKey,
	s.SettingValue
FROM SettingUser su
JOIN Account a ON su.UserId = a.UserId
JOIN AppSetting s ON su.SettingId = s.SettingId
WHERE a.UserId = @userId

-- 3.RECOMMENT file
DECLARE @userId INT = 2
SELECT TOP 10
	f.FileId,
	a.UserName,
	f.UserFileName,
	ar.ActionLog,
	ar.ActionDateTime
FROM ActionRecent ar 
JOIN Account a ON ar.UserId = a.UserId
JOIN UserFile f ON ar.ObjectTypeId = 2 AND ar.ObjectId = f.FileId
WHERE ar.UserId = @userId
ORDER BY ar.ActionDateTime DESC

SELECT * FROM ActionRecent

-- 4.RECOMMENT folder
DECLARE @userId INT = 3
SELECT TOP 10
	fo.FolderId,
	a.UserName,
	fo.FolderName,
	ar.ActionLog,
	ar.ActionDateTime
FROM ActionRecent ar
JOIN Account a ON ar.UserId = a.UserId
JOIN Folder fo ON ar.ObjectTypeId = 1 AND ar.ObjectId = fo.FolderId
WHERE ar.UserId = @userId  
ORDER BY ar.ActionDateTime DESC


-- My Drive Screen
-- 1.SELECT login user file
DECLARE @LoginUser INT = 1 
SELECT 
	uf.FileId,
	a.UserName,
	uf.UserFileName
FROM UserFile uf 
JOIN Account a ON uf.OwnerId = a.UserId
WHERE a.UserId = @LoginUser

-- 2.SELECT login user folder
DECLARE @userId INT = 1
SELECT 
	fo.FolderId,
	a.UserName,
	fo.FolderName
FROM Folder fo
JOIN Account a ON fo.OwnerId = a.UserId
WHERE a.UserId = @userId

-- Share with me Screen
-- 1.SELECT shared file with login user
DECLARE @userId INT = 102
SELECT
	f.FileId,
	a.UserName,
	f.UserFileName
FROM SharedUser su
JOIN Account a ON su.UserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN UserFile f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
WHERE su.UserId = @userId



-- 2.SELECT shared folder with login user
DECLARE @userId INT = 101
SELECT
	fo.FolderId,
	a.UserName,
	fo.FolderName
FROM SharedUser su
JOIN Account a ON su.UserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE su.UserId = @userId


-- Trash screen
-- 1.SELECT file have been deleted
DECLARE @userId INT = 704
SELECT
	f.FileId,
	t.TrashId,
	ot.ObjectTypeName,
	f.UserFileName,
	t.RemovedDatetime,
	t.IsPermanent
FROM Trash t
JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
JOIN UserFile f ON t.ObjectTypeId = 2 AND t.ObjectId = f.FileId
WHERE t.UserId = @userId;


-- 2.SELECT folder have been deleted
DECLARE @userId INT = 1
SELECT 
	fo.FolderId,
	t.TrashId,
	ot.ObjectTypeName,
	fo.FolderName,
	t.RemovedDatetime,
	t.IsPermanent
FROM Trash t
JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
JOIN Folder fo ON t.ObjectTypeId = 1 AND t.ObjectId = fo.FolderId
WHERE t.UserId = @userId;

-- Starred screen
-- 1.SELECT file
DECLARE @userId INT = 794
SELECT 
	f.FileId,
	f.UserFileName,
	a.UserName AS FileOwnerName,
	a.UserId AS UserId,
	ft.FileTypeName
FROM FavoriteObject fa
LEFT JOIN UserFile f ON fa.ObjectTypeId = 2 AND fa.ObjectId = f.FileId
LEFT JOIN Account a ON f.OwnerId = a.UserId 
JOIN FileType ft ON f.FileTypeId = ft.FileTypeId
WHERE fa.OwnerId = @userId



-- Product Screen
-- SELECT all of product
SELECT
	ProductId,
	ProductName,
	Cost,
	Duration
FROM ProductItem

-- SELECT Product bought by user
DECLARE @userId INT = 100
SELECT 
	pro.ProductId,
	pro.ProductName,
	a.UserId,
	a.UserName,
	CASE
		WHEN po.IsPercent = 1 THEN pro.Cost - (pro.Cost * (po.Discount / 100))
		ELSE pro.Cost - po.Discount
	END AS TotalCost
FROM UserProduct up
JOIN Account a ON up.UserId = a.UserId
JOIN Promotion po ON up.PromotionId = po.PromotionId
JOIN ProductItem pro ON up.ProductId = pro.ProductId
WHERE up.UserId = @userId



-- SELECT Top 10 Payers 
SELECT TOP 10
	a.UserId,
	pro.ProductName,
	a.UserName,
	CASE
		WHEN po.IsPercent = 1 THEN pro.Cost * (po.Discount / 100)
		ELSE pro.Cost - po.Discount
	END AS TotalCost
FROM UserProduct up
JOIN Account a ON up.UserId = a.UserId
JOIN ProductItem pro ON up.ProductId = pro.ProductId
JOIN Promotion po ON up.PromotionId = po.PromotionId
ORDER BY TotalCost DESC

-- SELECT folder shared for user with userid = 101
DECLARE @userId INT = 101
SELECT 
	a.UserName,
	fo.FolderId,
	p.PermissionName,
	fo.FolderName
FROM SharedUser su
JOIN Account a ON su.SharedUserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND fo.FolderId = s.ObjectId
WHERE su.UserId = @userId

-- SELECT file shared for user with userid = 102
DECLARE @userId INT = 102
SELECT 
	a.UserName,
	p.PermissionName,
	f.FileId,
	f.UserFileName
FROM SharedUser su
JOIN Account a ON su.SharedUserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN UserFile f ON s.ObjectTypeId = 2 AND f.FileId = s.ObjectId
WHERE su.UserId = @userId


-- SELECT top 5 largest file of login-user 
DECLARE @userId INT = 4
SELECT DISTINCT TOP 5
	f.UserFileName,
	a.UserName AS OwnerName,
	f.Size AS FileSize
FROM UserFile f
JOIN Account a ON f.OwnerId = a.UserId
WHERE f.OwnerId = @userId
ORDER BY f.Size DESC



-- SELECT banned user of login-user
DECLARE @userId INT = 533
SELECT 
	BU.Id AS BanId,
	Banned.UserName AS BannedUserName,
	Banner.UserName AS BannedByUserName,
	BU.BannedAt
FROM BannedUser BU
JOIN Account Banned ON BU.UserId = Banned.UserId
JOIN Account Banner ON BU.BannedUserId = Banner.UserId
WHERE BU.UserId = @userId
ORDER BY BU.BannedAt DESC;

-- SELECT product bought by user 
DECLARE @userId INT = 100
SELECT 
	p.ProductId,
	p.ProductName,
	a.UserName,
	up.PayingDatetime,
	up.EndDatetime,
	pr.PromotionName
FROM UserProduct up
JOIN ProductItem p ON up.ProductId = p.ProductId
JOIN Account a ON up.UserId = a.UserId
JOIN Promotion pr ON up.PromotionId = pr.PromotionId
WHERE a.UserId = @userId

-- SELECT file share by user
DECLARE @userId INT = 100
SELECT 
	a.UserName,
	f.UserFileName
FROM Share s
JOIN Account a ON s.Sharer = a.UserId
JOIN ObjectType ot ON s.ObjectTypeId = ot.ObjectTypeId
LEFT JOIN UserFile f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
WHERE s.Sharer = @userId

-- SELECT folder share by user
DECLARE @userId INT = 1
SELECT 
	a.UserName,
	fo.FolderName
FROM Share s
JOIN Account a ON s.Sharer = a.UserId
JOIN ObjectType ot ON s.ObjectTypeId = ot.ObjectTypeId
LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE s.Sharer = @userId




-- SELECT user was shared object with objectId = 5 and objectType is folder
DECLARE @objectId INT = 5
SELECT 
	a.UserName,
	fo.FolderName,
	p.PermissionName
FROM Share s
JOIN SharedUser su ON s.ShareId = su.ShareId
JOIN Account a ON su.UserId = a.UserId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE s.ObjectId = @objectId



-- User Management: Retrieve the names and email addresses of all users who have used more than 50% of their storage capacity.
SELECT TOP 5
	a.UserName,
	a.Email AS UserEmail,
	(a.Capacity - a.UsedCapacity) AS AllowCapicity
FROM Account a
WHERE ((CAST(a.UsedCapacity AS FLOAT) / a.Capacity) * 100) > 50



-- Folder Structure
DECLARE @userId INT = 20
SELECT 
	fo.FolderPath,
	c.ColorName,
	a.UserName
FROM Folder fo
JOIN Account a ON fo.OwnerId = a.UserId
JOIN Color c ON fo.ColorId = c.ColorId
WHERE fo.OwnerId = @userId

-- SELECT children of folder
DECLARE @FolderId INT = 1;
WITH RecursiveFolders AS (
	SELECT FolderId, FolderName, ParentId, FolderPath
	FROM Folder
	WHERE FolderId = @FolderId
	UNION ALL
	SELECT f.FolderId, f.FolderName, f.ParentId, f.FolderPath
	FROM Folder f
	INNER JOIN RecursiveFolders rf ON f.ParentId = rf.FolderId
	WHERE f.FolderPath LIKE rf.FolderPath + '/%'
)
SELECT 
	rf.FolderName,
	rf.ParentId,
	rf.FolderPath,
	fo.FolderName AS ParentFolderName
FROM RecursiveFolders rf
LEFT JOIN Folder fo ON rf.ParentId = fo.FolderId
WHERE rf.FolderId != 1
ORDER BY rf.FolderPath;

-- Full-text search query
SELECT 
	uf.FileId,
	uf.UserFileName,
	s.Term,
	s.TermFrequency,
	s.TermPositions
FROM SearchIndex s
JOIN FileContent fc ON s.FileContentId = fc.ContentId
JOIN UserFile uf ON fc.FileId = uf.FileId
WHERE s.Term IN ('project', 'proposal', 'employ')
ORDER BY s.Bm25Score

-- Sort UserFile By ShareUser
DECLARE @Sharer INT = 2
DECLARE @shared INT = 102
SELECT 
	uf.FileId,
	ft.Icon,
	uf.UserFileName AS NameOfFile,
	a1.UserName AS SharerName,
	s.CreatedAt AS ShareDateTime,
	a.UserName AS sharedName
FROM SharedUser su
JOIN Share s ON su.ShareId = s.ShareId
LEFT JOIN UserFile uf ON s.ObjectTypeId = 2 AND s.ObjectId = uf.FileId
JOIN FileType ft ON uf.FileTypeId = ft.FileTypeId
JOIN Account a ON su.UserId = a.UserId
JOIN Account a1 ON s.Sharer = a1.UserId
WHERE su.UserId = @shared AND s.Sharer = @Sharer

SELECT * FROM SharedUser

-- Sort UserFile by FileType
DECLARE @OwnerId INT = 1
DECLARE @FileType INT = 3
SELECT 
	uf.FileId,
	ft.Icon,
	uf.UserFileName,
	a.UserName AS OwnerName,
	uf.CreatedAt
FROM UserFile uf
JOIN FileType ft ON uf.FileTypeId = ft.FileTypeId
JOIN Account a ON uf.OwnerId = a.UserId
WHERE uf.FileTypeId = @FileType AND uf.OwnerId = @OwnerId

-- Sort by Action recent
WITH RecentObjects AS (
	SELECT 
		ar.ObjectId,
		ar.ObjectTypeId,
		ar.ActionDateTime,
		ar.ActionLog,
		CASE 
			WHEN ar.ObjectTypeId = 1 THEN 'Folder'
			WHEN ar.ObjectTypeId = 2 THEN 'File'
			ELSE 'Unknown'
		END AS ObjectType,
		uf.OwnerId AS FileOwnerId,
		f.OwnerId AS FolderOwnerId
	FROM ActionRecent ar
	LEFT JOIN UserFile uf ON ar.ObjectId = uf.FileId AND ar.ObjectTypeId = 2
	LEFT JOIN Folder f ON ar.ObjectId = f.FolderId AND ar.ObjectTypeId = 1
	WHERE (uf.OwnerId = 11 OR f.OwnerId = 11)
)
SELECT 
	ro.ObjectId,
	ro.ObjectTypeId,
	ro.ObjectType,
	CASE 
		WHEN ro.ObjectType = N'File' THEN uf.UserFileName
		WHEN ro.ObjectType = N'Folder' THEN f.FolderName
		ELSE NULL
	END AS ObjectName,
	ro.ActionLog,
	ro.ActionDateTime
FROM RecentObjects ro
LEFT JOIN UserFile uf ON ro.ObjectId = uf.FileId AND ro.ObjectTypeId = 2
LEFT JOIN Folder f ON ro.ObjectId = f.FolderId AND ro.ObjectTypeId = 1
WHERE ro.FileOwnerId = 11 OR ro.FolderOwnerId = 11
ORDER BY ro.ActionDateTime DESC;

SELECT * FROM ActionRecent
SELECT * FROM UserFile
SELECT * FROM Folder WHERE OwnerId = 11 AND FolderId = 37
