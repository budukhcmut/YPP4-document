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
IF OBJECT_ID('dbo.ActionRecent', 'U') IS NOT NULL DROP TABLE dbo.ActionRecent;
IF OBJECT_ID('dbo.FavoriteEntities', 'U') IS NOT NULL DROP TABLE dbo.FavoriteObject;
IF OBJECT_ID('dbo.BannedUser', 'U') IS NOT NULL DROP TABLE dbo.BannedUser;
IF OBJECT_ID('dbo.Promotion', 'U') IS NOT NULL DROP TABLE dbo.Promotion;
IF OBJECT_ID('dbo.UserProduct', 'U') IS NOT NULL DROP TABLE dbo.UserProduct;
IF OBJECT_ID('dbo.ProductItem', 'U') IS NOT NULL DROP TABLE dbo.ProductItem;
IF OBJECT_ID('dbo.Trash', 'U') IS NOT NULL DROP TABLE dbo.Trash;
IF OBJECT_ID('dbo.FileVersion', 'U') IS NOT NULL DROP TABLE dbo.FileVersion;
IF OBJECT_ID('dbo.SharedUser', 'U') IS NOT NULL DROP TABLE dbo.SharedUser;
IF OBJECT_ID('dbo.Share', 'U') IS NOT NULL DROP TABLE dbo.Share;
IF OBJECT_ID('dbo.FileType', 'U') IS NOT NULL DROP TABLE dbo.FileType;
IF OBJECT_ID('dbo.UserFile', 'U') IS NOT NULL DROP TABLE dbo.UserFile;
IF OBJECT_ID('dbo.Folder', 'U') IS NOT NULL DROP TABLE dbo.Folder;
IF OBJECT_ID('dbo.Permission', 'U') IS NOT NULL DROP TABLE dbo.Permission;
IF OBJECT_ID('dbo.ObjectType', 'U') IS NOT NULL DROP TABLE dbo.ObjectType;
IF OBJECT_ID('dbo.UserSession', 'U') IS NOT NULL DROP TABLE dbo.UserSession;
IF OBJECT_ID('dbo.Account', 'U') IS NOT NULL DROP TABLE dbo.Account;
IF OBJECT_ID('dbo.AppSetting', 'U') IS NOT NULL DROP TABLE dbo.AppSetting;
IF OBJECT_ID('dbo.SettingUser', 'U') IS NOT NULL DROP TABLE dbo.SettingUser;
IF OBJECT_ID('dbo.Color', 'U') IS NOT NULL DROP TABLE dbo.Color;
GO

CREATE TABLE Account (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	UserImg NVARCHAR(50),
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
    PermissionName NVARCHAR(50) NOT NULL,
	PermissionPriority int
);
GO

CREATE TABLE ObjectType (
    ObjectTypeId INT PRIMARY KEY IDENTITY(1,1),
    ObjectTypeName NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Folder (
    FolderId INT PRIMARY KEY IDENTITY(1,1),
    ParentId INT,
    OwnerId INT NOT NULL,
    FolderName NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME,
    FolderPath VARCHAR(50),
	FolderStatus VARCHAR(50),
	ColorId int,
    FOREIGN KEY (ParentId) REFERENCES Folder(FolderId),
    FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
    FOREIGN KEY (ColorId) REFERENCES Color(ColorId)
);
GO

CREATE TABLE FileType (
    FileTypeId INT PRIMARY KEY IDENTITY(1,1),
    FileTypeName NVARCHAR(50) NOT NULL,
    Icon NVARCHAR(50)
);
GO

CREATE TABLE UserFile (
    FileId INT PRIMARY KEY IDENTITY(1,1),
    FolderId INT,
    OwnerId INT NOT NULL,
    Size BIGINT,
    UserFileName NVARCHAR(50) NOT NULL,
    UserFilePath NVARCHAR(MAX),
	UserFileThumbNailImg NVARCHAR(50),
    FileTypeId INT,
    ModifiedDate DATETIME,
    UserFileStatus NVARCHAR(50),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (FolderId) REFERENCES Folder(FolderId),
    FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
    FOREIGN KEY (FileTypeId) REFERENCES FileType(FileTypeId)
);
GO

CREATE TABLE Share (
    ShareId INT PRIMARY KEY IDENTITY(1,1),
    Sharer INT NOT NULL,
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
	ShareUrl varchar(50),
	UrlApprove bit,
    FOREIGN KEY (Sharer) REFERENCES Account(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SharedUser (
    SharedUserId INT PRIMARY KEY IDENTITY(1,1),
    ShareId INT,
    UserId INT,
    PermissionId INT,
	CreatedAt DATETIME, 
	ModifiedAt DATETIME,
    FOREIGN KEY (ShareId) REFERENCES Share(ShareId),
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (PermissionId) REFERENCES Permission(PermissionId)
);
GO

CREATE TABLE FileVersion (
    FileVersionId INT PRIMARY KEY IDENTITY(1,1),
    FileId INT,
    FileVersion INT NOT NULL,
    FileVersionPath NVARCHAR(MAX),
    CreatedAt DATETIME2,
    UpdateBy INT,
    IsCurrent BIT,
    VersionFile NVARCHAR(MAX),
    Size BIGINT,
    FOREIGN KEY (FileId) REFERENCES UserFile(FileId),
    FOREIGN KEY (UpdateBy) REFERENCES Account(UserId)
);
GO

CREATE TABLE Trash (
    TrashId INT PRIMARY KEY IDENTITY(1,1),
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    RemovedDatetime DATETIME2,
    UserId INT,
    IsPermanent BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE ProductItem (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(50) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL,
    Duration INT NOT NULL
);
GO

CREATE TABLE Promotion (
    PromotionId INT PRIMARY KEY IDENTITY(1,1),
    PromotionName NVARCHAR(50) NOT NULL,
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
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (ProductId) REFERENCES ProductItem(ProductId),
    FOREIGN KEY (PromotionId) REFERENCES Promotion(PromotionId)
);
GO

CREATE TABLE BannedUser (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    BannedAt DATETIME2,
    BannedUserId INT,
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (BannedUserId) REFERENCES Account(UserId)
);
GO

CREATE TABLE FavoriteObject (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OwnerId INT,
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE ActionRecent (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    ObjectId INT,
	ObjectTypeId INT,
    ActionLog NVARCHAR(MAX),
    ActionDateTime DATETIME2,
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SearchHistory (
	SearchId INT PRIMARY KEY IDENTITY(1,1),
	UserId INT,
	FOREIGN KEY (UserId) REFERENCES Account(UserId),
	SearchToken NVARCHAR(MAX),
	SearchDatetime DATETIME,
);


CREATE TABLE UserSession (
    SessionId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    Token NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiresAt DATETIME,
    FOREIGN KEY (UserId) REFERENCES Account(UserId)
);
GO

CREATE TABLE AppSetting(
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
    FOREIGN KEY (UserId) REFERENCES Account(UserId),
    FOREIGN KEY (SettingId ) REFERENCES AppSetting(SettingId )
);
GO


CREATE INDEX idx_file_name ON UserFile(UserFileName);
CREATE INDEX idx_folder_name ON Folder(FolderName);
GO


CREATE TABLE FileContent (
    ContentId INT PRIMARY KEY IDENTITY(1,1),
    FileId INT NOT NULL,
    ContentChunk NVARCHAR(MAX) NOT NULL,
    ChunkIndex INT NOT NULL,
    DocumentLength INT NULL, -- Nullable to allow trigger to set it
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FileId) REFERENCES UserFile(FileId),
    CONSTRAINT UC_FileContent UNIQUE (FileId, ChunkIndex)
);
GO

-- Table to store unique terms and their associated content
CREATE TABLE Term (
    TermId INT PRIMARY KEY IDENTITY(1,1),
    Term NVARCHAR(50) NOT NULL,
    FileContentId INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (FileContentId) REFERENCES FileContent(ContentId)
);
GO

-- Table to store search index with BM25 scores and IDF
CREATE TABLE SearchIndex (
    SearchIndexId INT PRIMARY KEY IDENTITY(1,1),
    FileContentId INT NOT NULL,
    Term NVARCHAR(50) NOT NULL,
    TermFrequency INT NOT NULL,
    TermPositions NVARCHAR(MAX),
    Bm25Score FLOAT NOT NULL DEFAULT 0,
    IDF FLOAT NOT NULL DEFAULT 0,
    FOREIGN KEY (FileContentId) REFERENCES FileContent(ContentId),
    CONSTRAINT UC_SearchIndex UNIQUE (FileContentId, Term),
    CONSTRAINT CHK_IDF_NonNegative CHECK (IDF >= 0)
);
GO
--select * from term
--select * from SearchIndex
--select * from FileContent
CREATE NONCLUSTERED INDEX IX_Term_Term ON Term (Term, FileContentId);
CREATE NONCLUSTERED INDEX IX_SearchIndex_Term ON SearchIndex (Term, FileContentId);
GO
