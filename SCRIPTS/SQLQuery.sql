USE GoogleDrive
GO


-- HOME SCREEN
-- SELECT USER INFORMATION
SELECT 
	u.Name  UserName,
	u.Email  Email
FROM [User] u
WHERE u.UserId =1 

-- SELECT USER SETTING
SELECT 
	u.Name  UserName,
	s.SettingKey,
	s.SettingValue
FROM SettingUser su
JOIN [User] u ON su.UserId = u.UserId
JOIN Setting s ON su.SettingId = s.SettingId
WHERE u.UserId =1

-- SELECT LOGIN USER FILE
SELECT 
	u.Name  UserName,
	f.Name  FileName
FROM [File] f 
JOIN [User] u ON f.OwnerId = u.UserId
WHERE u.UserId =1

-- SELECT LOGIN USER FOLDER
SELECT 
	u.Name  UserName,
	fo.Name  FolderName
FROM [Folder] fo
JOIN [User] u ON fo.OwnerId = u.UserId
WHERE u.UserId =1

-- SELECT SHARED FILE WITH LOGIN USER
SELECT 
	u.Name  UserName,
	f.Name  FileName
FROM SharedUser su
JOIN [User] u ON su.UserId = u.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN [File] f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
WHERE su.UserId = 252

-- SELECT SHARED FOLDER WITH LOGIN USER
SELECT 
	u.Name  UserName,
	fo.Name  FolderName
FROM SharedUser su
JOIN [User] u ON su.UserId = u.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN [Folder] fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE su.UserId = 100


-- RECOMMENT FILE/FOLDER
SELECT TOP 10
	u.Name AS UserName,
	f.Name AS FileName,
	r.Log AS Log,
	r.DateTime AS DateTime
FROM Recent r
JOIN [User] u ON r.UserId = u.UserId
JOIN [File] f ON r.ObjectTypeId = 2 AND r.ObjectId = f.FileId
WHERE r.UserId = 319
ORDER BY r.DateTime DESC


-- RECOMMENT FOLDER
SELECT TOP 10
	u.Name AS UserName,
	fo.Name AS FolderName,
	r.Log AS Log,
	r.DateTime AS DateTime
FROM Recent r
JOIN [User] u ON r.UserId = u.UserId
JOIN [Folder] fo ON r.ObjectTypeId = 1 AND r.ObjectId = fo.FolderId
WHERE r.UserId = 2
ORDER BY r.DateTime DESC



-- TRASH SCREEN
-- SELECT FILE HAVE BEEN DELETED
SELECT 
	t.TrashId,
	ot.Name AS ObjectType,
	f.Name AS FileName,
	t.RemovedDatetime,
	t.IsPermanent
FROM Trash t
JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
JOIN [File] f ON t.ObjectTypeId = 2 AND t.ObjectId = f.FileId
WHERE t.UserId = 500;

-- SELECT FOLDER HAVE BEEN DELETED
SELECT 
	t.TrashId,
	ot.Name AS ObjectType,
	fo.Name AS FolderName,
	t.RemovedDatetime,
	t.IsPermanent
FROM Trash t
JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
JOIN Folder fo ON t.ObjectTypeId = 1 AND t.ObjectId = fo.FolderId
WHERE t.UserId = 500;

-- STARED SCREEN
-- SELECT FILE
SELECT 
	f.Name AS FileName,
	u1.Name AS FileOwnerName,
	u1.UserId AS UserId,
	ft.Name AS FileTypeName
FROM FavoriteObject fa
LEFT JOIN [File] f ON fa.ObjectTypeId = 2 AND fa.ObjectId = f.FileId
JOIN [User] u1 ON f.OwnerId = u1.UserId
JOIN FileType ft ON f.FileTypeId = ft.FileTypeId
WHERE fa.OwnerId = 100


-- PRODUCT SCREEN
-- SELECT ALL OF PRODUCT
SELECT * FROM [Product]

-- SELECT PRODUCT BOUGHT BY USER
SELECT 
	pro.Name AS ProductName,
	u.Name AS UserName,
	CASE
		WHEN po.IsPercent = 1 THEN pro.Cost * (po.Discount / 100)
		ELSE pro.Cost - po.Discount
	END AS TotalCost
FROM UserProduct up
JOIN [User] u ON up.UserId = u.UserId
JOIN Promotion po ON up.PromotionId = po.PromotionId
JOIN [Product] pro ON up.ProductId = pro.ProductId
WHERE up.UserId = 100



-- SELECT TOP 10 PAYERS
SELECT TOP 10
	pro.Name AS ProductName,
	u.Name AS UserName,
	CASE
		WHEN po.IsPercent = 1 THEN pro.Cost * (po.Discount / 100)
		ELSE pro.Cost - po.Discount
	END AS TotalCost
FROM UserProduct up
JOIN [User] u ON up.UserId = u.UserId
JOIN [Product] pro ON up.ProductId = pro.ProductId
JOIN Promotion po ON up.PromotionId = po.PromotionId
ORDER BY TotalCost DESC

-- SELECT FILE/FOLDER SHARED FOR USER WITH USERID = 500
SELECT 
	u.Name AS UserName,
	p.Name AS Permission,
	f.Name AS FileName,
	fo.Name AS FolderName
FROM SharedUser su
JOIN [User] u ON su.SharedUserId = u.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND fo.FolderId = s.ObjectId
LEFT JOIN [File] f ON s.ObjectTypeId = 2 AND f.FileId = s.ObjectId
WHERE su.SharedUserId = 500



-- SELECT TOP 5 LARGEST FILE
SELECT TOP 5
	f.Name AS FileName,
	u.Name AS Owner,
	f.Size AS FileSize
FROM [File] f 
JOIN [User] u ON f.OwnerId = u.UserId
ORDER BY f.Size DESC

-- SELECT BANNED USER
SELECT 
	BU.Id AS BanId,
	Banned.Name AS BannedUserName,
	Banner.Name AS BannedByUserName,
	BU.BannedAt
FROM BannedUser BU
JOIN [User] Banned ON BU.UserId = Banned.UserId
JOIN [User] Banner ON BU.BannedUserId = Banner.UserId
ORDER BY BU.BannedAt DESC;

-- SELECT PRODUCT BOUGHT BY USER
SELECT 
	p.Name AS ProductName,
	u.Name AS UserName,
	up.PayingDatetime,
	up.EndDatetime,
	pr.Name AS PromotionName
FROM UserProduct up
JOIN [Product] p ON up.ProductId = p.ProductId
JOIN [User] u ON up.UserId = u.UserId
JOIN Promotion pr ON up.PromotionId = pr.PromotionId
WHERE u.UserId = 100

-- SELECT FILE/FOLDER SHARE BY USER
SELECT 
	u.Name AS UserName,
	f.Name AS FileName,
	fo.Name AS FolderName
FROM Share s
JOIN [User] u ON s.Sharer = u.UserId
JOIN ObjectType ot ON s.ObjectTypeId = ot.ObjectTypeId
LEFT JOIN [File] f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
LEFT JOIN [Folder] fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE s.Sharer = 100



-- SELECT USER WAS SHARED OBJECT WITH OBJECTID = 654
SELECT 
	u.Name AS UserName,
	f.Name AS FileName,
	fo.Name AS FolderName,
	p.Name AS PermissionName
FROM Share s
JOIN SharedUser su ON s.ShareId = su.ShareId
JOIN [User] u ON su.UserId = u.UserId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN [File] f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
LEFT JOIN [Folder] fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE s.ObjectId = 654


-- USER MANAGEMENT: RETRIEVE THE NAMES AND EMAIL ADDRESSES OF ALL USERS WHO HAVE USED MORE THAN 5% OF THEIR STORAGE CAPACITY
SELECT 
	u.Name AS UserName,
	u.Email AS UserEmail
FROM [User] u
WHERE ((CAST(u.UsedCapacity AS FLOAT) / u.Capacity) * 100) > 5



-- FOLDER STRUCTURE: LIST ALL FOLDERS OWNED BY A SPECIFIC USER (E.G., USERID = 1), INCLUDING THEIR FULL PATH AND THE NAME OF THE COLOR ASSOCIATED WITH EACH FOLDER
SELECT 
	fo.Path,
	c.ColorName,
	u.Name AS UserName
FROM [Folder] fo
JOIN [User] u ON fo.OwnerId = u.UserId
JOIN Color c ON fo.ColorId = c.ColorId
WHERE fo.OwnerId = 20

-- Example 
SELECT
ft.Name , f.Name , u.UserId , fo.Name 
FROM [FavoriteObject] fa
JOIN [User] u ON fa.OwnerId =u.UserId
LEFT JOIN [File] f ON fa.ObjectTypeId =2 AND fa.ObjectId = f.FileId  
LEFT JOIN [Folder] fo ON fa.ObjectTypeId = 1 AND fa.ObjectId = fo.FolderId
JOIN FileType ft ON ft.FileTypeId = f.FileTypeId
WHERE fa.OwnerId = 252

-- Find folder constraint keyword "file"
SELECT s.Term , fo.Name ,s.DocumentLength ,s.TermFrequency
FROM SearchIndex  s
JOIN [Folder] fo ON s.ObjectId = fo.FolderId AND s.ObjectTypeId = 1
WHERE s.Term = 'file' 

-- Find 3 files have highest score about TF-IDF for keyword "security"
SELECT TOP 3
s.ObjectId ,f.Name ,s.ObjectTypeId , s.TermFrequency*t.IDF AS TFIDFScored

FROM SearchIndex s 
JOIN TermIDF t ON s.Term = t.Term 
JOIN [File] f ON s.ObjectId = f.FileId
WHERE s.Term = 'security' AND s.ObjectTypeId = 2
ORDER BY TFIDFScored DESC 

-- With each file , find keyword have highest TFIDF Score 
WITH TFIDF_Ranked AS (
    SELECT 
        s.ObjectId AS FileId,
        f.Name AS FileName,
        s.Term,
        s.TermFrequency,
        t.IDF,
        (s.TermFrequency * t.IDF) AS TF_IDF_Score,
        ROW_NUMBER() OVER (PARTITION BY s.ObjectId ORDER BY (s.TermFrequency * t.IDF) DESC) AS rn
    FROM SearchIndex s
    JOIN TermIDF t ON s.Term = t.Term
    JOIN [File] f ON s.ObjectId = f.FileId
    WHERE s.ObjectTypeId = 1
)
SELECT *
FROM TFIDF_Ranked
WHERE rn = 1;

-- Find all file have more than 3 keyword and each keyword have tf-idf score > 2

SELECT 
s.ObjectId AS FileId, COUNT(s.ObjectId) AS High_TFIDF_TermCount
FROM SearchIndex s 
JOIN TermIDF t ON s.Term = t.Term 
WHERE (t.IDF*s.TermFrequency) > 2 AND s.ObjectTypeId =2   
GROUP BY s.ObjectId
HAVING COUNT(s.ObjectId) > 0 

--
SELECT * FROM SearchIndex 
SELECT * FROM TermIDF

-- Example

FROM SearchIndex s 
JOIN TermIDF t ON s.Term = t.Term
WHERE s.ObjectTypeId = 2
GROUP BY s.ObjectId