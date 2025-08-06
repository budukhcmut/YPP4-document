﻿-- Use master database
USE master
-- Check if MsList database exists, create it if it doesn't
IF DB_ID('MsList') IS NULL
BEGIN
    CREATE DATABASE MsList;
END
GO

USE MsList;
GO

-- Drop tables in reverse dependency order
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ShareLinkSettingValue') DROP TABLE ShareLinkSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ShareLinkUserAccess') DROP TABLE ShareLinkUserAccess;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ShareLink') DROP TABLE ShareLink;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Scope') DROP TABLE Scope;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListMemberPermission') DROP TABLE ListMemberPermission;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TrashItem') DROP TABLE TrashItem;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ObjectType') DROP TABLE ObjectType;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListRowComment') DROP TABLE ListRowComment;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FileAttachment') DROP TABLE FileAttachment;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FavoriteList') DROP TABLE FavoriteList;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DynamicColumnSettingValue') DROP TABLE DynamicColumnSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListCellValue') DROP TABLE ListCellValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListRow') DROP TABLE ListRow;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListColumnSettingObject') DROP TABLE ListColumnSettingObject;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListViewSettingValue') DROP TABLE ListViewSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListDynamicColumn') DROP TABLE ListDynamicColumn;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SystemColumnSettingValue') DROP TABLE SystemColumnSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SystemColumn') DROP TABLE SystemColumn;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListView') DROP TABLE ListView;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateSampleCell') DROP TABLE TemplateSampleCell;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateSampleRow') DROP TABLE TemplateSampleRow;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateViewSettingValue') DROP TABLE TemplateViewSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateColumnSettingValue') DROP TABLE TemplateColumnSettingValue;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateColumn') DROP TABLE TemplateColumn;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateView') DROP TABLE TemplateView;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'List') DROP TABLE List;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListTemplate') DROP TABLE ListTemplate;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DataTypeSettingKey') DROP TABLE DataTypeSettingKey;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ViewTypeSettingKey') DROP TABLE ViewTypeSettingKey;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'KeySetting') DROP TABLE KeySetting;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ViewSettingKey') DROP TABLE ViewSettingKey;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Permission') DROP TABLE Permission;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'SystemDataType') DROP TABLE SystemDataType;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ViewType') DROP TABLE ViewType;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ListType') DROP TABLE ListType;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'WorkspaceMember') DROP TABLE WorkspaceMember;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TemplateProvider') DROP TABLE TemplateProvider;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Workspace') DROP TABLE Workspace;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Account') DROP TABLE Account;
GO

CREATE TABLE Account (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Avatar NVARCHAR(255),
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    DateBirth DATE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Company NVARCHAR(255),
    AccountStatus NVARCHAR(50),
    AccountPassword NVARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Workspace (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WorkspaceName NVARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE WorkspaceMember (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WorkspaceId INT FOREIGN KEY REFERENCES Workspace(Id),
    AccountId INT FOREIGN KEY REFERENCES Account(Id),
    JoinedAt DATETIME NOT NULL DEFAULT GETDATE(),
    MemberStatus NVARCHAR(50),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Permission (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(100),
    PermissionCode NVARCHAR(50) NOT NULL, -- Admin, Contributor, Reader
    PermissionDescription NVARCHAR(255),
    Icon NVARCHAR(255)
);


CREATE TABLE ViewType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL, -- 'List', 'Gallery', 'Calendar', 'Board'
    HeaderImage NVARCHAR(255),
    Icon NVARCHAR(100),
    ViewTypeDescription NVARCHAR(500)
);


CREATE TABLE ListType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255) NOT NULL, -- 'List', 'Form', 'Gallery', 'Calendar', 'Board'
    Icon NVARCHAR(255),
    ListTypeDescription NVARCHAR(500),
    HeaderImage NVARCHAR(255)
);

CREATE TABLE ViewSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) NOT NULL, -- Examples: 'StartDate', 'EndDate', 'IsPublic'
    ValueType NVARCHAR(50) NOT NULL -- Examples: 'number', 'boolean', 'datetime', 'string'
);

CREATE TABLE ViewTypeSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ViewTypeId INT FOREIGN KEY REFERENCES ViewType(Id),
    ViewSettingKeyId INT FOREIGN KEY REFERENCES ViewSettingKey(Id)
);

CREATE TABLE SystemDataType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Icon NVARCHAR(100),
    DataTypeDescription NVARCHAR(500),
    CoverImg NVARCHAR(255),
    DisplayName NVARCHAR(100) NOT NULL, -- Examples: 'Single Text', 'Choice'
    DataTypeValue NVARCHAR(50) NOT NULL -- Examples: 'Text', 'Number', 'Boolean'
);

CREATE TABLE KeySetting (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Icon NVARCHAR(100),
    KeyName NVARCHAR(100) NOT NULL,
    ValueType NVARCHAR(50) NOT NULL, -- Examples: 'text', 'number', 'datetime'
    IsDefaultValue BIT DEFAULT 0,
    ValueOfDefault NVARCHAR(255),
    IsShareLinkSetting BIT DEFAULT 0
);

CREATE TABLE DataTypeSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT FOREIGN KEY REFERENCES SystemDataType(Id),
    KeySettingId INT FOREIGN KEY REFERENCES KeySetting(Id)
);

CREATE TABLE TemplateProvider (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProviderName NVARCHAR(255)
);

CREATE TABLE ListTemplate (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255),
    HeaderImage NVARCHAR(500),
    TemplateDescription NVARCHAR(500),
    Icon NVARCHAR(100),
    Color NVARCHAR(50),
    Sumary NVARCHAR(500),
    Feature NVARCHAR(500),
    ProviderId INT NOT NULL REFERENCES TemplateProvider(Id)
);

CREATE TABLE TemplateView (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    ViewTypeId INT NOT NULL,
    ViewName NVARCHAR(255),
    DisplayOrder INT
);

CREATE TABLE TemplateColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id),
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    ColumnName NVARCHAR(255),
    ColumnDescription NVARCHAR(500),
    DisplayOrder INT,
    IsVisible BIT
);

CREATE TABLE TemplateColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateColumnId INT NOT NULL REFERENCES TemplateColumn(Id),
    DataTypeSettingKeyId INT NOT NULL REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255)
);

CREATE TABLE TemplateViewSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateViewId INT NOT NULL REFERENCES TemplateView(Id),
    ViewTypeSettingId INT NOT NULL REFERENCES ViewTypeSettingKey(Id),
    GroupByColumnId INT REFERENCES TemplateColumn(Id),
    RawValue NVARCHAR(500)
);

CREATE TABLE TemplateSampleRow (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    DisplayOrder INT
);

CREATE TABLE TemplateSampleCell (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateColumnId INT NOT NULL REFERENCES TemplateColumn(Id),
    TemplateSampleRowId INT NOT NULL REFERENCES TemplateSampleRow(Id),
    CellValue NVARCHAR(500)
);

CREATE TABLE List (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListName NVARCHAR(100) NOT NULL,
    Icon NVARCHAR(100),
    Color NVARCHAR(50),
    WorkspaceId INT NOT NULL REFERENCES Workspace(Id), 
    CreatedBy INT NOT NULL, -- FK to User or Account
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ListStatus NVARCHAR(50)  -- 'Active', 'Archived', etc.
);

CREATE TABLE SystemColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id),
    ColumnName NVARCHAR(100) NOT NULL,
    DisplayOrder INT,
    CreatedBy INT REFERENCES Account(Id),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CanRename BIT DEFAULT 0 -- only SystemColumn name "Title" has value = 1
);

CREATE TABLE SystemColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemColumnId INT NOT NULL REFERENCES SystemColumn(Id),
    DataTypeSettingKeyId INT NOT NULL REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255)
);

CREATE TABLE ListView (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT NOT NULL REFERENCES List(Id),
    CreatedBy INT NOT NULL REFERENCES Account(Id),
    ViewTypeId INT NOT NULL REFERENCES ViewType(Id),
    ViewName NVARCHAR(255),
    DisplayOrder INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);


CREATE TABLE ListDynamicColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT NOT NULL REFERENCES List(Id),
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id),
    SystemColumnId INT REFERENCES SystemColumn(Id),
    ColumnName NVARCHAR(100) NOT NULL,
    ColumnDescription NVARCHAR(255),
    DisplayOrder INT NOT NULL DEFAULT 0,
    IsSystemColumn BIT NOT NULL DEFAULT 0,
    IsVisible BIT NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL REFERENCES Account(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ColumnSettingObject (
    Id INT PRIMARY KEY IDENTITY,
    ColumnId INT,
    DisplayName NVARCHAR(255),
    DisplayColor NVARCHAR(20),
    DisplayOrder INT NOT NULL DEFAULT 0, 
    Context NVARCHAR(50) NOT NULL, -- TEMPLATE: template's object | LIST: list's object
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListViewSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListViewId INT FOREIGN KEY REFERENCES ListView(Id),
    ViewTypeSettingKeyId INT FOREIGN KEY REFERENCES ViewTypeSettingKey(Id),
    GroupByColumnId INT FOREIGN KEY REFERENCES ListDynamicColumn(Id),
    RawValue NVARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListRow (
    Id INT IDENTITY(1,1) PRIMARY KEY, 
    ListId INT NOT NULL REFERENCES List(Id),
    DisplayOrder INT NOT NULL DEFAULT 0,
    ModifiedAt DATETIME,
    CreatedBy INT NOT NULL REFERENCES Account(Id),
    ListRowStatus NVARCHAR(50),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListCellValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListRowId INT NOT NULL REFERENCES ListRow(Id),
    ListColumnId INT NOT NULL REFERENCES ListDynamicColumn(Id),
    CellValue NVARCHAR(500),
    CreatedBy INT NOT NULL REFERENCES Account(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE DynamicColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DynamicColumnId INT FOREIGN KEY REFERENCES ListDynamicColumn(Id),
    DataTypeSettingKeyId INT FOREIGN KEY REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE FavoriteList (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    AccountId INT FOREIGN KEY REFERENCES Account(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE FileAttachment (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListRowId INT FOREIGN KEY REFERENCES ListRow(Id),
    FileAttachmentName NVARCHAR(255),
    FileUrl NVARCHAR(500),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListRowComment (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListRowId INT FOREIGN KEY REFERENCES ListRow(Id),
    Content NVARCHAR(500) NOT NULL,
    CreatedBy INT FOREIGN KEY REFERENCES Account(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ObjectType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50),
    DisplayName NVARCHAR(255),
    Icon NVARCHAR(100)
);

CREATE TABLE TrashItem (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ObjectTypeId INT FOREIGN KEY REFERENCES ObjectType(Id), -- 'List', 'ListRow', 'File'
    ObjectId INT, -- ID of the deleted object
    UserDeleteId INT FOREIGN KEY REFERENCES Account(Id),
    DeletedAt DATETIME NOT NULL DEFAULT GETDATE(),
    OriginalPath NVARCHAR(255)
);

CREATE TABLE ListMemberPermission (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    AccountId INT FOREIGN KEY REFERENCES Account(Id), -- The user receiving the permission
    HighestPermissionId INT FOREIGN KEY REFERENCES Permission(Id),
    GrantedBy INT FOREIGN KEY REFERENCES Account(Id),
    Note NVARCHAR(500),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Scope (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50) NOT NULL UNIQUE, -- e.g., 'PUBLIC', 'AUTHORIZED', 'SPECIFIC'
    DisplayName NVARCHAR(100) NOT NULL,
    ScopeDescription NVARCHAR(255),
    Icon NVARCHAR(100)
);

CREATE TABLE ShareLink (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    TargetUrl NVARCHAR(500),
    ScopeId INT FOREIGN KEY REFERENCES Scope(Id),
    PermissionId INT FOREIGN KEY REFERENCES Permission(Id),
    LinkStatus NVARCHAR(50),
    CreatedBy INT FOREIGN KEY REFERENCES Account(Id),
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ShareLinkUserAccess (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ShareLinkId INT NOT NULL FOREIGN KEY REFERENCES ShareLink(Id),
    AccountId INT NULL FOREIGN KEY REFERENCES Account(Id),
    Email NVARCHAR(255) NOT NULL   ,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ShareLinkSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ShareLinkId INT NOT NULL REFERENCES ShareLink(Id),         
    KeySettingId INT NOT NULL REFERENCES KeySetting(Id), 
    KeyValue NVARCHAR(255) NOT NULL                    
);
GO