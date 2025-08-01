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

CREATE TABLE Users (
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
    FOREIGN KEY (OwnerId) REFERENCES Users(UserId),
    FOREIGN KEY (ColorId) REFERENCES Color(ColorId)
);
GO

CREATE TABLE FileType (
    FileTypeId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL,
    Icon NVARCHAR(50)
);
GO

CREATE TABLE Files (
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
    FOREIGN KEY (OwnerId) REFERENCES Users(UserId),
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
    FOREIGN KEY (Sharer) REFERENCES Users(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SharedUser (
    SharedUserId INT PRIMARY KEY IDENTITY(1,1),
    ShareId INT,
    UserId INT,
    PermissionId INT,
    FOREIGN KEY (ShareId) REFERENCES Share(ShareId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
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
    FOREIGN KEY (FileId) REFERENCES Files(FileId),
    FOREIGN KEY (UpdateBy) REFERENCES Users(UserId)
);
GO

CREATE TABLE Trash (
    TrashId INT PRIMARY KEY IDENTITY(1,1),
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    RemovedDatetime DATETIME2,
    UserId INT,
    IsPermanent BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE Products (
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
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    FOREIGN KEY (PromotionId) REFERENCES Promotion(PromotionId)
);
GO

CREATE TABLE BannedUser (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    BannedAt DATETIME2,
    BannedUserId INT,
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (BannedUserId) REFERENCES Users(UserId)
);
GO

CREATE TABLE FavoriteObject (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OwnerId INT,
    ObjectId INT NOT NULL,
    ObjectTypeId INT NOT NULL,
    FOREIGN KEY (OwnerId) REFERENCES Users(UserId),
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
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
);
GO

CREATE TABLE SearchHistory (
SearchId INT PRIMARY KEY IDENTITY(1,1),
UserId INT,
FOREIGN KEY (UserId) REFERENCES Users(UserId),
SearchToken NVARCHAR(MAX),
SearchDatetime DATETIME,
);


CREATE TABLE Sessionss (
    SessionId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT,
    Token NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiresAt DATETIME,
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
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
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (SettingId ) REFERENCES [Setting](SettingId )
);
GO


CREATE INDEX idx_file_name ON Files(Name);
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
    FOREIGN KEY (FileId) REFERENCES Files(FileId),
    ContentChunk NVARCHAR(MAX),
    ChunkIndex INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO