USE GoogleDrive
GO

INSERT INTO Users (Name, Email, PasswordHash, CreatedAt, LastLogin, UsedCapacity, Capacity)
SELECT TOP 1000
    'User' + CAST(n AS NVARCHAR(255)),
    'user' + CAST(n AS NVARCHAR(255)) + '@example.com',
    HASHBYTES('SHA2_256', CAST(NEWID() AS NVARCHAR(255))),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    ABS(CHECKSUM(NEWID()) % 1000000000),
    10000000000
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM master.dbo.spt_values -- hoặc sys.all_objects nếu cần nhiều dòng hơn
) AS nums
WHERE n BETWEEN 1 AND 1000;
GO

-- 2. Populate Color table (10 rows)
INSERT INTO Color (ColorName, ColorIcon)
SELECT TOP 10
    'Color' + CAST(n AS NVARCHAR(255)),
    'icon' + CAST(n AS NVARCHAR(255)) + '.png'
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects) AS nums
WHERE n BETWEEN 1 AND 10;
GO

-- 3. Populate Permission table (3 rows)
INSERT INTO Permission (Name)
VALUES ('reader'), ('contributor'), ('owner');
GO

-- 4. Populate ObjectType table (2 rows)
INSERT INTO ObjectType (Name)
VALUES ('folder'), ('file');
GO

-- 5. Populate Folder table (1000 rows)
IF OBJECT_ID('tempdb..#TempFolder') IS NOT NULL DROP TABLE #TempFolder;
CREATE TABLE #TempFolder (
    FolderId INT,
    ParentId INT,
    OwnerId INT,
    Name NVARCHAR(255),
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    Path NVARCHAR(255),
    Status NVARCHAR(50),
    ColorId INT
);

-- Insert top-level folders (200 rows)
INSERT INTO #TempFolder (FolderId, ParentId, OwnerId, Name, CreatedAt, UpdatedAt, Path, Status, ColorId)
SELECT TOP 200
    n,
    NULL,
    u.UserId,
    'Folder' + CAST(n AS NVARCHAR(255)),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    '/' + CAST(n AS NVARCHAR(255)),
    CASE WHEN n % 10 = 0 THEN 'archived' ELSE 'active' END,
    ABS(CHECKSUM(NEWID()) % 10) + 1
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 200;

-- Insert child folders (800 rows)
INSERT INTO #TempFolder (FolderId, ParentId, OwnerId, Name, CreatedAt, UpdatedAt, Path, Status, ColorId)
SELECT TOP 800
    n + 200,
    (SELECT TOP 1 FolderId FROM #TempFolder WHERE FolderId <= 200 ORDER BY NEWID()),
    u.UserId,
    'Folder' + CAST(n + 200 AS NVARCHAR(255)),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    '',
    CASE WHEN n % 10 = 0 THEN 'archived' ELSE 'active' END,
    ABS(CHECKSUM(NEWID()) % 10) + 1
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 800;

-- Update paths for child folders
WITH FolderHierarchy AS (
    SELECT 
        FolderId,
        ParentId,
        Path
    FROM #TempFolder
    WHERE ParentId IS NULL
    UNION ALL
    SELECT 
        t.FolderId,
        t.ParentId,
        CAST(f.Path + '/' + CAST(t.FolderId AS NVARCHAR(255)) AS NVARCHAR(255))
    FROM #TempFolder t
    INNER JOIN FolderHierarchy f ON t.ParentId = f.FolderId
)
UPDATE tf
SET Path = fh.Path
FROM #TempFolder tf
INNER JOIN FolderHierarchy fh ON tf.FolderId = fh.FolderId
WHERE tf.ParentId IS NOT NULL;

-- Ensure unique paths by appending a suffix if needed
UPDATE #TempFolder
SET Path = Path + '_' + CAST(FolderId AS NVARCHAR(255))
WHERE Path IN (
    SELECT Path
    FROM #TempFolder
    GROUP BY Path
    HAVING COUNT(*) > 1
);

-- Insert into actual Folder table
INSERT INTO Folder (ParentId, OwnerId, Name, CreatedAt, UpdatedAt, Path, Status, ColorId)
SELECT ParentId, OwnerId, Name, CreatedAt, UpdatedAt, Path, Status, ColorId
FROM #TempFolder;

DROP TABLE #TempFolder;
GO

-- 6. Populate FileType table (4 rows)
INSERT INTO FileType (Name, Icon)
VALUES 
    ('docx', 'docx.png'),
    ('excel', 'excel.png'),
    ('image', 'image.png'),
    ('video', 'video.png');
GO

-- 7. Populate [File] table (1000 rows)
INSERT INTO Files (FolderId, OwnerId, Size, Name, Path, FileTypeId, ModifiedDate, Status, CreatedAt)
SELECT TOP 1000
    f.FolderId,
    u.UserId,
    ABS(CHECKSUM(NEWID()) % 1000000000),
    'File' + CAST(n AS NVARCHAR(255)),
    f.Path + '/file' + CAST(n AS NVARCHAR(255)),
    ABS(CHECKSUM(NEWID()) % 4) + 1,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    CASE WHEN n % 10 = 0 THEN 'deleted' ELSE 'active' END,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
CROSS JOIN (SELECT TOP 1000 FolderId, Path FROM Folder ORDER BY NEWID()) f
WHERE n BETWEEN 1 AND 1000;
GO

-- 8. Populate Share table (1000 rows)
INSERT INTO Share (Sharer, ObjectId, ObjectTypeId, CreatedAt, Url, UrlApprove)
SELECT TOP 1000
    u.UserId,
    o.ObjectId,
    o.ObjectTypeId,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), '2025-07-24 10:29:00'),
    'share_' + LEFT(CAST(NEWID() AS VARCHAR(36)), 8),
    CASE WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 1 ELSE 0 END
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY NEWID()) AS n
    FROM sys.objects s1 CROSS JOIN sys.objects s2
) AS nums
CROSS JOIN (
    SELECT TOP 1000 UserId
    FROM Users
    ORDER BY NEWID()
) u
CROSS JOIN (
    SELECT 
        ABS(CHECKSUM(NEWID()) % 1000) + 1 AS ObjectId,
        CASE WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 1 ELSE 2 END AS ObjectTypeId
    FROM (SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn FROM sys.objects s1 CROSS JOIN sys.objects s2) AS randomRows
) o
WHERE nums.n BETWEEN 1 AND 1000;
GO


-- 9. Populate SharedUser table (1000 rows)
INSERT INTO SharedUser (ShareId, UserId, PermissionId)
SELECT TOP 1000
    s.ShareId,
    u.UserId,
    ABS(CHECKSUM(NEWID()) % 3) + 1
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 ShareId FROM Share ORDER BY NEWID()) s
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE s.ShareId <= 1000 AND u.UserId <= 1000 AND n BETWEEN 1 AND 1000;
GO

-- 10. Populate FileVersion table (1000 rows)
INSERT INTO FileVersion (FileId, Version, Path, CreatedAt, UpdateBy, IsCurrent, VersionFile, Size)
SELECT TOP 1000
    f.FileId,
    n,
    f.Path + '/v' + CAST(n AS NVARCHAR(255)),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    u.UserId,
    CASE WHEN n % 5 = 0 THEN 1 ELSE 0 END,
    f.Path + '.bak',
    ABS(CHECKSUM(NEWID()) % 1000000000)
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 FileId, Path FROM Files ORDER BY NEWID()) f
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 1000;
GO

-- 11. Populate Trash table (1000 rows)
INSERT INTO Trash (ObjectId, ObjectTypeId, RemovedDatetime, UserId, IsPermanent)
SELECT TOP 1000
    o.ObjectId,
    o.ObjectTypeId,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    u.UserId,
    CASE WHEN n % 10 = 0 THEN 1 ELSE 0 END
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
CROSS JOIN (
    SELECT TOP 500 FolderId AS ObjectId, 1 AS ObjectTypeId FROM Folder ORDER BY NEWID()
    UNION
    SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM Files ORDER BY NEWID()
) o
WHERE n BETWEEN 1 AND 1000;
GO

-- 12. Populate Product table (4 rows)
INSERT INTO Products (Name, Cost, Duration)
VALUES 
    ('30gb', 19000, 30),
    ('30gb', 190000, 365),
    ('100gb', 45000, 30),
    ('100gb', 540000, 365);
GO

-- 13. Populate Promotion table (4 rows)
INSERT INTO Promotion (Name, Discount, IsPercent)
VALUES 
    ('First Month 30gb', 5000, 0),
    ('First Year 30gb', 150000, 0),
    ('First Month 100gb', 11250, 0),
    ('First Year 100gb', 360000, 0);
GO

-- 14. Populate UserProduct table (1000 rows)
INSERT INTO UserProduct (UserId, ProductId, PayingDatetime, IsFirstPaying, PromotionId, EndDatetime)
SELECT TOP 1000
    u.UserId,
    p.ProductId,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    CASE WHEN n % 2 = 0 THEN 1 ELSE 0 END,
    pr.PromotionId,
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
CROSS JOIN (SELECT TOP 4 ProductId FROM Products ORDER BY NEWID()) p
CROSS JOIN (SELECT TOP 4 PromotionId FROM Promotion ORDER BY NEWID()) pr
WHERE n BETWEEN 1 AND 1000;
GO

-- 15. Populate BannedUser table (1000 rows)
INSERT INTO BannedUser (UserId, BannedUserId, BannedAt)
SELECT TOP 1000
    UserId,
    BannedUserId,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (
    SELECT 
        u1.UserId,
        u2.UserId AS BannedUserId,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn
    FROM Users u1
    CROSS JOIN Users u2
    WHERE u1.UserId != u2.UserId
) AS UserPairs
WHERE rn BETWEEN 1 AND 1000;
GO
-- 16. Populate FavoriteObject table (1000 rows)
INSERT INTO FavoriteObject (OwnerId, ObjectId, ObjectTypeId)
SELECT TOP 1000
    u.UserId,
    o.ObjectId,
    o.ObjectTypeId
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
CROSS JOIN (
    SELECT TOP 500 FolderId AS ObjectId, 1 AS ObjectTypeId FROM Folder ORDER BY NEWID()
    UNION
    SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM Files ORDER BY NEWID()
) o
WHERE n BETWEEN 1 AND 1000;
GO

-- 17. Populate Recent table (1000 rows)
INSERT INTO Recent (UserId, ObjectId, ObjectTypeId, Log, DateTime)
SELECT TOP 1000
    u.UserId,
    ABS(CHECKSUM(NEWID()) % 1000) + 1 AS ObjectId,
    CASE WHEN ABS(CHECKSUM(NEWID()) % 2) = 0 THEN 1 ELSE 2 END AS ObjectTypeId,
    'Accessed object: ' + CAST(ABS(CHECKSUM(NEWID()) % 1000) + 1 AS NVARCHAR(10)) AS Log,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), '2025-07-24 14:47:00') AS DateTime
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY NEWID()) AS n
    FROM sys.objects s1 CROSS JOIN sys.objects s2
) AS nums
CROSS JOIN (
    SELECT TOP 1000 UserId
    FROM Users
    ORDER BY NEWID()
) u
WHERE nums.n BETWEEN 1 AND 1000;
GO

-- 18. Populate SearchHistory table (1000 rows)
INSERT INTO SearchHistory (UserId, SearchToken, SearchDatetime)
SELECT TOP 1000
    u.UserId,
    'SearchTerm' + CAST(n AS NVARCHAR(255)),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 1000;
GO

-- 19. Populate [Session] table (1000 rows)
INSERT INTO Sessionss (UserId, Token, CreatedAt, ExpiresAt)
SELECT TOP 1000
    u.UserId,
    NEWID(),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 30), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 1000;
GO

-- 20. Populate Setting table (30 rows)
INSERT INTO Setting (SettingKey, SettingValue, Decription)
VALUES 
    ('Layout', 'List', 'view as list'),
    ('Layout', 'Board', 'view as board'),
    ('ViewSetting', 'Name', ''),
    ('ViewSetting', 'ModifiedDatetime', ''),
    ('ViewSetting', 'ModifiedDatetimeByMe', ''),
    ('ViewSetting', 'ViewDateTiemByMe', ''),
    ('ArrangementText', 'A to Z', ''),
    ('ArrangementText', 'Z To A', ''),
    ('ArrangementDate', 'recent to last', ''),
    ('ArrangementDate', 'Last to recent', ''),
    ('StartPage', 'Home', ''),
    ('StartPage', 'My Drive', ''),
    ('Theme', 'Light', ''),
    ('Theme', 'Dark', ''),
    ('Theme', 'System', ''),
    ('Density', 'Comfortable', ''),
    ('Density', 'Cozy', ''),
    ('Density', 'Compact', ''),
    ('OpenPDFs', 'New tab', ''),
    ('OpenPDFs', 'Preview', ''),
    ('Upload', 'Yes', ''),
    ('Upload', 'No', ''),
    ('Preview Cards', 'Yes', ''),
    ('Preview Cards', 'No', ''),
    ('Sound', 'Yes', ''),
    ('Sound', 'No', ''),
    ('NotificationBrowser', 'Yes', ''),
    ('NotificationBrowser', 'No', ''),
    ('NotificationEmail', 'Yes', ''),
    ('NotificationEmail', 'No', '');
GO

-- 21. Populate SettingUser table (1000 rows)
INSERT INTO SettingUser (UserId, SettingId)
SELECT TOP 1000
    u.UserId,
    s.SettingId
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM Users ORDER BY NEWID()) u
CROSS JOIN (SELECT TOP 30 SettingId FROM Setting ORDER BY NEWID()) s
WHERE n BETWEEN 1 AND 1000;
GO

-- 22. Populate FileContent table (1000 rows)
INSERT INTO FileContent (FileId, ContentChunk, ChunkIndex, CreatedAt)
SELECT TOP 1000
    f.FileId,
    'Content chunk for file' + CAST(n AS NVARCHAR(255)),
    n,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 FileId FROM Files ORDER BY NEWID()) f
WHERE n BETWEEN 1 AND 1000;
GO

-- 23. Populate SearchIndex table (1000 rows)
INSERT INTO SearchIndex (ObjectId, ObjectTypeId, Term, TermFrequency, DocumentLength)
SELECT TOP 1000
    ObjectId,
    ObjectTypeId,
    'Term' + CAST(ROW_NUMBER() OVER (ORDER BY ObjectId, ObjectTypeId) AS NVARCHAR(255)),
    ABS(CHECKSUM(NEWID()) % 10) + 1,
    ABS(CHECKSUM(NEWID()) % 1000) + 1
FROM (
    SELECT TOP 500 FolderId AS ObjectId, 1 AS ObjectTypeId FROM Folder ORDER BY NEWID()
    UNION
    SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM Files ORDER BY NEWID()
) AS Objects;
GO

-- 24. Populate TermIDF table (1000 rows)
INSERT INTO TermIDF (Term, IDF, LastUpdated)
SELECT TOP 1000
    'Term' + CAST(n AS NVARCHAR(255)),
    CAST(ABS(CHECKSUM(NEWID()) % 100) AS FLOAT) / 10,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
WHERE n BETWEEN 1 AND 1000;
GO