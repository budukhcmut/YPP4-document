USE master;
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'GoogleDrive')
BEGIN
    ALTER DATABASE GoogleDrive SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GoogleDrive;
END;
GO


-- Create database
CREATE DATABASE GoogleDrive;
GO

USE GoogleDrive;
GO


IF OBJECT_ID('dbo.TermIDF', 'U') IS NOT NULL DROP TABLE dbo.TermIDF;
IF OBJECT_ID('dbo.SearchIndex', 'U') IS NOT NULL DROP TABLE dbo.SearchIndex;
IF OBJECT_ID('dboSearchHistory', 'U') IS NOT NULL DROP TABLE dbo.SearchHistory;
IF OBJECT_ID('dbo.Recent', 'U') IS NOT NULL DROP TABLE dbo.Recent;
IF OBJECT_ID('dbo.FavoriteEntities', 'U') IS NOT NULL DROP TABLE dbo.FavoriteObject;
IF OBJECT_ID('dbo.BannedUser', 'U') IS NOT NULL DROP TABLE dbo.BannedUser;
IF OBJECT_ID('dbo.Promotion', 'U') IS NOT NULL DROP TABLE dbo.Promotion;
IF OBJECT_ID('dbo.UserProduct', 'U') IS NOT NULL DROP TABLE dbo.UserProduct;
IF OBJECT_ID('dbo.[Product]', 'U') IS NOT NULL DROP TABLE dbo.[Product];
IF OBJECT_ID('dbo.Trash', 'U') IS NOT NULL DROP TABLE dbo.Trash;
IF OBJECT_ID('dbo.FileVersion', 'U') IS NOT NULL DROP TABLE dbo.FileVersion;
IF OBJECT_ID('dbo.SharedUser', 'U') IS NOT NULL DROP TABLE dbo.SharedUser;
IF OBJECT_ID('dbo.Share', 'U') IS NOT NULL DROP TABLE dbo.Share;
IF OBJECT_ID('dbo.FileType', 'U') IS NOT NULL DROP TABLE dbo.FileType;
IF OBJECT_ID('dbo.[File]', 'U') IS NOT NULL DROP TABLE dbo.[File];
IF OBJECT_ID('dbo.Folder', 'U') IS NOT NULL DROP TABLE dbo.Folder;
IF OBJECT_ID('dbo.Permission', 'U') IS NOT NULL DROP TABLE dbo.Permission;
IF OBJECT_ID('dbo.ObjectType', 'U') IS NOT NULL DROP TABLE dbo.ObjectType;
IF OBJECT_ID('dbo.[Session]', 'U') IS NOT NULL DROP TABLE dbo.[Session];
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];
IF OBJECT_ID('dbo.[Setting]', 'U') IS NOT NULL DROP TABLE dbo.[Setting];
IF OBJECT_ID('dbo.[SettingUser]', 'U') IS NOT NULL DROP TABLE dbo.[SettingUser];
IF OBJECT_ID('dbo.[Color]', 'U') IS NOT NULL DROP TABLE dbo.[Color];
GO

CREATE TABLE [User] (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    LastLogin DATETIME,
	UsedCapacity bigint,
	Capacity bigint
);
GO


CREATE TABLE Color(
	ColorId INT PRIMARY KEY IDENTITY(1,1),
	ColorName NVARCHAR(50),
	ColorIcon NVARCHAR(50)
)
GO

CREATE TABLE Permission (
    PermissionId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE ObjectType (
    ObjectTypeId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Folder (
    FolderId INT PRIMARY KEY IDENTITY(1,1),
    ParentId INT,
    OwnerId INT NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME,
    Path VARCHAR(50),
	Status VARCHAR(50),
	ColorId int,
    FOREIGN KEY (ParentId) REFERENCES Folder(FolderId),
    FOREIGN KEY (OwnerId) REFERENCES [User](UserId),
    FOREIGN KEY (ColorId) REFERENCES Color(ColorId)
);
GO

CREATE TABLE FileType (
    FileTypeId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Icon NVARCHAR(50)
);
GO

CREATE TABLE [File] (
    FileId INT PRIMARY KEY IDENTITY(1,1),
    FolderId INT,
    OwnerId INT NOT NULL,
    Size BIGINT,
    Name NVARCHAR(50) NOT NULL,
    Path NVARCHAR(MAX),
    FileTypeId INT,
    ModifiedDate DATETIME,
    Status NVARCHAR(50),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (FolderId) REFERENCES Folder(FolderId),
    FOREIGN KEY (OwnerId) REFERENCES [User](UserId),
    FOREIGN KEY (FileTypeId) REFERENCES FileType(FileTypeId)
);
GO

CREATE TABLE Share (
    ShareId INT PRIMARY KEY IDENTITY(1,1),
    Sharer INT NOT NULL,
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	Url varchar(50),
	UrlApprove bit,
    FOREIGN KEY (Sharer) REFERENCES [User](UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SharedUser (
    SharedUserId INT PRIMARY KEY IDENTITY(1,1),
    ShareId INT,
    UserId INT,
    PermissionId INT,
    FOREIGN KEY (ShareId) REFERENCES Share(ShareId),
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (PermissionId) REFERENCES Permission(PermissionId)
);
GO

CREATE TABLE FileVersion (
    FileVersionId INT PRIMARY KEY IDENTITY(1,1),
    FileId INT,
    Version INT NOT NULL,
    Path NVARCHAR(MAX),
    CreatedAt DATETIME2,
    UpdateBy INT,
    IsCurrent BIT,
    VersionFile NVARCHAR(MAX),
    Size BIGINT,
    FOREIGN KEY (FileId) REFERENCES [File](FileId),
    FOREIGN KEY (UpdateBy) REFERENCES [User](UserId)
);
GO

CREATE TABLE Trash (
    TrashId INT PRIMARY KEY IDENTITY(1,1),
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    RemovedDatetime DATETIME2,
    UserId INT,
    IsPermanent BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE [Product] (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Duration INT NOT NULL
);
GO

CREATE TABLE Promotion (
    PromotionId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Discount INT NOT NULL,
    IsPercent BIT NOT NULL
);
GO

CREATE TABLE UserProduct (
    UserProductId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    ProductId INT,
    PayingDatetime DATETIME2,
    IsFirstPaying BIT,
    PromotionId INT,
    EndDatetime DATETIME2,
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (ProductId) REFERENCES [Product](ProductId),
    FOREIGN KEY (PromotionId) REFERENCES Promotion(PromotionId)
);
GO

CREATE TABLE BannedUser (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    BannedAt DATETIME2,
    BannedUserId INT,
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (BannedUserId) REFERENCES [User](UserId)
);
GO

CREATE TABLE FavoriteObject (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OwnerId INT,
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    FOREIGN KEY (OwnerId) REFERENCES [User](UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE Recent (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    ObjectId INT,
	ObjectTypeId INT,
    Log NVARCHAR(MAX),
    DateTime DATETIME2,
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SearchHistory (
SearchId INT PRIMARY KEY IDENTITY(1,1),
UserId INT,
FOREIGN KEY (UserId) REFERENCES [User](UserId),
SearchToken NVARCHAR(MAX),
SearchDatetime DATETIME,
);


CREATE TABLE [Session] (
    SessionId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    Token NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiresAt DATETIME,
    FOREIGN KEY (UserId) REFERENCES [User](UserId)
);
GO

CREATE TABLE Setting(
    SettingId INT PRIMARY KEY IDENTITY(1,1),
    SettingKey VARCHAR(MAX),
    SettingValue VARCHAR(MAX),
    Decription VARCHAR(MAX)
);
GO

CREATE TABLE SettingUser(
    SettingUserId INT PRIMARY KEY IDENTITY(1,1),
    SettingId INT,
    UserId INT,
    FOREIGN KEY (UserId) REFERENCES [User](UserId),
    FOREIGN KEY (SettingId ) REFERENCES [Setting](SettingId )
);
GO


CREATE INDEX idx_file_name ON [File](Name);
CREATE INDEX idx_folder_name ON Folder(Name);
GO


-- Drop SearchIndex and create with no TermPositions
;
GO

CREATE TABLE SearchIndex (
    SearchIndexId INT PRIMARY KEY IDENTITY(1,1),
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    Term NVARCHAR(50) NOT NULL,
    TermFrequency INT NOT NULL,
    DocumentLength INT NOT NULL,
    TermPositions NVARCHAR(MAX),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId),
    CONSTRAINT UC_SearchIndex UNIQUE (ObjectId, ObjectTypeId, Term)
);
GO

-- Indexes for performance
CREATE NONCLUSTERED INDEX IX_SearchIndex_Term ON SearchIndex (Term, ObjectTypeId);
GO

-- Create TermIDF table to store precomputed IDF values

CREATE TABLE TermIDF (
    TermIDFId INT PRIMARY KEY IDENTITY(1,1),
    Term NVARCHAR(50) NOT NULL UNIQUE, -- Matches SearchIndex.Term
    IDF FLOAT NOT NULL, -- Precomputed IDF value: log((N - n(t) + 0.5) / (n(t) + 0.5) + 1)
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(), -- Tracks when IDF was last recalculated
    CONSTRAINT CHK_IDF_NonNegative CHECK (IDF >= 0)
);
GO

-- Index for faster term lookups
CREATE NONCLUSTERED INDEX IX_TermIDF_Term ON TermIDF (Term);
GO

CREATE TABLE FileContent (
    ContentId INT PRIMARY KEY IDENTITY(1,1),
    FileId INT NOT NULL,
    FOREIGN KEY (FileId) REFERENCES [File](FileId),
    ContentChunk NVARCHAR(MAX),
    ChunkIndex INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO




INSERT INTO [User] (Name, Email, PasswordHash, CreatedAt, LastLogin, UsedCapacity, Capacity)
SELECT TOP 1000
    'User' + CAST(n AS NVARCHAR(255)),
    'user' + CAST(n AS NVARCHAR(255)) + '@example.com',
    HASHBYTES('SHA2_256', CAST(NEWID() AS NVARCHAR(255))),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE()),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    ABS(CHECKSUM(NEWID()) % 1000000000),
    10000000000
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
INSERT INTO [File] (FolderId, OwnerId, Size, Name, Path, FileTypeId, ModifiedDate, Status, CreatedAt)
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
    FROM [User]
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
CROSS JOIN (SELECT TOP 1000 FileId, Path FROM [File] ORDER BY NEWID()) f
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
CROSS JOIN (
    SELECT TOP 500 FolderId AS ObjectId, 1 AS ObjectTypeId FROM Folder ORDER BY NEWID()
    UNION
    SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM [File] ORDER BY NEWID()
) o
WHERE n BETWEEN 1 AND 1000;
GO

-- 12. Populate Product table (4 rows)
INSERT INTO [Product] (Name, Cost, Duration)
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
CROSS JOIN (SELECT TOP 4 ProductId FROM [Product] ORDER BY NEWID()) p
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
    FROM [User] u1
    CROSS JOIN [User] u2
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
CROSS JOIN (
    SELECT TOP 500 FolderId AS ObjectId, 1 AS ObjectTypeId FROM Folder ORDER BY NEWID()
    UNION
    SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM [File] ORDER BY NEWID()
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
    FROM [User]
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
WHERE n BETWEEN 1 AND 1000;
GO

-- 19. Populate [Session] table (1000 rows)
INSERT INTO [Session] (UserId, Token, CreatedAt, ExpiresAt)
SELECT TOP 1000
    u.UserId,
    NEWID(),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE()),
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 30), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
CROSS JOIN (SELECT TOP 1000 UserId FROM [User] ORDER BY NEWID()) u
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
CROSS JOIN (SELECT TOP 1000 FileId FROM [File] ORDER BY NEWID()) f
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
  
-- 24. Populate TermIDF table (1000 rows)
INSERT INTO TermIDF (Term, IDF, LastUpdated)
SELECT TOP 1000
    'Term' + CAST(n AS NVARCHAR(255)),
    CAST(ABS(CHECKSUM(NEWID()) % 100) AS FLOAT) / 10,
    DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 365), GETDATE())
FROM (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
      FROM sys.objects s1 CROSS JOIN sys.objects s2) AS nums
WHERE n BETWEEN 1 AND 1000;
GO  SELECT TOP 500 FileId AS ObjectId, 2 AS ObjectTypeId FROM [File] ORDER BY NEWID()
) AS Objects;
GO
