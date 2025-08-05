-- Use master database
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
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Activity') DROP TABLE Activity;
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Trash') DROP TABLE Trash;
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

-- Create tables in dependency order
CREATE TABLE Account (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Avatar NVARCHAR(255),
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    DateBirth DATE,
    Email NVARCHAR(255),
    Company NVARCHAR(255),
    AccountStatus NVARCHAR(50) DEFAULT 'Active',
    AccountPassword NVARCHAR(255)
);

-------- WORKSPACE --------
CREATE TABLE Workspace (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WorkspaceName NVARCHAR(255)
);

CREATE TABLE WorkspaceMember (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WorkspaceId INT FOREIGN KEY REFERENCES Workspace(Id),
    AccountId INT FOREIGN KEY REFERENCES Account(Id),
    JoinedAt DATETIME NOT NULL DEFAULT GETDATE(),
    MemberStatus NVARCHAR(50) DEFAULT 'Active',
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);
---------------------------
---------------------- SYSTEM SETTING ---------------------
-- Table for three access permissions
CREATE TABLE Permission (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(100),
    PermissionCode NVARCHAR(50) NOT NULL, -- Owner, Contributor, Reader
    PermissionDescription NVARCHAR(255),
    Icon NVARCHAR(255)
);

-- Table to store view types
CREATE TABLE ViewType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL, -- Examples: 'List', 'Form', 'Gallery', 'Calendar', 'Board'
    HeaderImage NVARCHAR(255), -- URL or file name of the image
    Icon NVARCHAR(100), -- Icon name or path
    ViewTypeDescription NVARCHAR(500) -- Description of the view type
);

-- Table for ListType
CREATE TABLE ListType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255), -- Examples: 'List', 'Form', 'Gallery', 'Calendar', 'Board'
    Icon NVARCHAR(100),
    ListTypeDescription NVARCHAR(MAX),
    HeaderImage NVARCHAR(500)
);

-- Table for ViewSetting
CREATE TABLE ViewSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) NOT NULL, -- Examples: 'StartDate', 'EndDate', 'IsPublic'
    ValueType NVARCHAR(50) NOT NULL -- Examples: 'number', 'boolean', 'datetime', 'string'

);

-- Table to define which settings are used by each view type
CREATE TABLE ViewTypeSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ViewTypeId INT FOREIGN KEY REFERENCES ViewType(Id),
    ViewSettingKeyId INT FOREIGN KEY REFERENCES ViewSettingKey(Id)
);

-- Table for data types allowed for cell values
CREATE TABLE SystemDataType (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Icon NVARCHAR(100), -- Icon name or path
    DataTypeDescription NVARCHAR(500), -- Description
    CoverImg NVARCHAR(255), -- Cover image (can be a URL)
    DisplayName NVARCHAR(100) NOT NULL, -- Examples: 'Single Text', 'Choice'
    DataTypeValue NVARCHAR(50) NOT NULL -- Examples: 'Text', 'Number', 'Boolean'
);

-- Table for column setting keys
CREATE TABLE KeySetting (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Icon NVARCHAR(100), -- Icon or symbol name
    KeyName NVARCHAR(100) NOT NULL, -- Setting name
    ValueType NVARCHAR(50) NOT NULL, -- Examples: 'text', 'number', 'datetime'
    IsDefaultValue BIT DEFAULT 0, -- True if it is a default value
    ValueOfDefault NVARCHAR(255), -- Default value if applicable
    IsShareLinkSetting BIT DEFAULT 0 -- True if used for share link
);

-- Table to define which settings apply to each column type
CREATE TABLE DataTypeSettingKey (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT FOREIGN KEY REFERENCES SystemDataType(Id),
    KeySettingId INT FOREIGN KEY REFERENCES KeySetting(Id)
);

----------------- TEMPLATE -------------------
CREATE TABLE TemplateProvider (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProviderName NVARCHAR(255)
);

-- Table for ListTemplate
CREATE TABLE ListTemplate (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255),
    HeaderImage NVARCHAR(500),
    TemplateDescription NVARCHAR(MAX),
    Icon NVARCHAR(100),
    Color NVARCHAR(50) DEFAULT '#28A745',
    Sumary NVARCHAR(MAX),
    Feature NVARCHAR(MAX),
    ListTypeId INT NOT NULL REFERENCES ListType(Id),
    ProviderId INT NOT NULL REFERENCES TemplateProvider(Id)
);

-- Table for TemplateView
CREATE TABLE TemplateView (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    ViewTypeId INT NOT NULL,
    ViewName NVARCHAR(255),
    DisplayOrder INT
);

-- Table for TemplateColumn
CREATE TABLE TemplateColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id),
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    ColumnName NVARCHAR(255),
    ColumnDescription NVARCHAR(MAX),
    DisplayOrder INT,
    IsVisible BIT
);

CREATE TABLE TemplateColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateColumnId INT NOT NULL REFERENCES TemplateColumn(Id),
    DataTypeSettingKeyId INT NOT NULL REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255)
);

-- Table for TemplateViewSettingValue
CREATE TABLE TemplateViewSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateViewId INT NOT NULL REFERENCES TemplateView(Id),
    ViewTypeSettingId INT NOT NULL REFERENCES ViewTypeSettingKey(Id),
    GroupByColumnId INT REFERENCES TemplateColumn(Id),
    RawValue NVARCHAR(MAX)
);
-- Table for TemplateSampleRow
CREATE TABLE TemplateSampleRow (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListTemplateId INT NOT NULL REFERENCES ListTemplate(Id),
    DisplayOrder INT
);

-- Table for TemplateSampleCell
CREATE TABLE TemplateSampleCell (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TemplateColumnId INT NOT NULL REFERENCES TemplateColumn(Id),
    TemplateSampleRowId INT NOT NULL REFERENCES TemplateSampleRow(Id),
    CellValue NVARCHAR(MAX)
);

------------------
CREATE TABLE List (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListTypeId INT NOT NULL REFERENCES ListType(Id), -- FK to ListType
    ListTemplateId INT REFERENCES ListTemplate(Id),
    ListName NVARCHAR(100) NOT NULL,
    Icon NVARCHAR(100),
    Color NVARCHAR(50),
    CreatedBy INT NOT NULL, -- FK to User or Account
    CreatedAt DATETIME DEFAULT GETDATE(),
    ListStatus NVARCHAR(50) DEFAULT 'Active' -- 'Active', 'Archived', etc.
);

-- One list can have multiple views
-- Need a trigger to automatically create a view named "All Items"
CREATE TABLE ListView (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT NOT NULL REFERENCES List(Id), -- FK to List table
    CreatedBy INT NOT NULL REFERENCES Account(Id), -- FK to Account/User table
    ViewTypeId INT NOT NULL REFERENCES ViewType(Id),
    ViewName NVARCHAR(255),
    DisplayOrder INT NOT NULL DEFAULT 0 -- Display order
);

CREATE TABLE SystemColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id),
    ColumnName NVARCHAR(100) NOT NULL,
    DisplayOrder INT,
    CreatedBy INT REFERENCES Account(Id),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CanRename BIT DEFAULT 0 --  only SystemColumn name "Title" has value = 1
);

CREATE TABLE SystemColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SystemColumnId INT NOT NULL REFERENCES SystemColumn(Id),
    DataTypeSettingKeyId INT NOT NULL REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255)
);

CREATE TABLE ListDynamicColumn (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT NOT NULL REFERENCES List(Id),
    SystemDataTypeId INT NOT NULL REFERENCES SystemDataType(Id), -- If type is 'choice', settings can specify multi-choice or single-choice
    SystemColumnId INT REFERENCES SystemColumn(Id),
    ColumnName NVARCHAR(100) NOT NULL, -- Column name displayed on UI
    ColumnDescription NVARCHAR(255), -- Short description of the column
    DisplayOrder INT NOT NULL DEFAULT 0, -- Display order in the list
    IsSystemColumn BIT NOT NULL DEFAULT 0, -- System columns cannot be modified by users
    IsVisible BIT NOT NULL DEFAULT 1, -- 1: Visible | 0: Hidden from view
    CreatedBy INT NOT NULL REFERENCES Account(Id), -- Who created this column
    CreatedAt DATETIME DEFAULT GETDATE() -- Creation timestamp
);

-- Store values for columns of type 'choice'
CREATE TABLE ListColumnSettingObject (
    Id INT PRIMARY KEY IDENTITY,
    ListDynamicColumnId INT FOREIGN KEY REFERENCES ListDynamicColumn(Id),
    DisplayName NVARCHAR(255), -- Display name
    DisplayColor NVARCHAR(20) NOT NULL DEFAULT '#28A745', -- Default color if none selected
    DisplayOrder INT NOT NULL DEFAULT 0 -- Display order in dropdown
);

-- Should also store additional values
CREATE TABLE ListViewSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListViewId INT FOREIGN KEY REFERENCES ListView(Id),
    ViewTypeSettingKeyId INT FOREIGN KEY REFERENCES ViewTypeSettingKey(Id),
    GroupByColumnId INT FOREIGN KEY REFERENCES ListDynamicColumn(Id),
    RawValue NVARCHAR(255)
);

CREATE TABLE ListRow (
    Id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    ListId INT NOT NULL REFERENCES List(Id), -- FK to the list containing this row
    DisplayOrder INT NOT NULL DEFAULT 0, -- Display order (row sorting)
    ModifiedAt DATETIME, -- Last modified timestamp
    CreatedBy INT NOT NULL REFERENCES Account(Id), -- Who created this row
    CreatedAt DATETIME DEFAULT GETDATE(), -- Creation timestamp
    ListRowStatus NVARCHAR(50) DEFAULT 'Active' -- Status: Active, Archived, Deleted, etc.
);

-- Store the value of a row in a specific column
CREATE TABLE ListCellValue (
    Id INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    ListRowId INT NOT NULL REFERENCES ListRow(Id), -- FK to the row containing the value
    ListColumnId INT NOT NULL REFERENCES ListDynamicColumn(Id), -- FK to the corresponding dynamic column
    CellValue NVARCHAR(MAX), -- Input value (text, number, JSON, etc.)
    CreatedBy INT NOT NULL REFERENCES Account(Id), -- Who created this value
    CreatedAt DATETIME DEFAULT GETDATE() -- Creation timestamp
);

-- Store values for column settings
CREATE TABLE DynamicColumnSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DynamicColumnId INT FOREIGN KEY REFERENCES ListDynamicColumn(Id),
    DataTypeSettingKey INT FOREIGN KEY REFERENCES DataTypeSettingKey(Id),
    KeyValue NVARCHAR(255),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE FavoriteList (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    FavoriteListOfUser INT FOREIGN KEY REFERENCES Account(Id),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE FileAttachment (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListRowId INT FOREIGN KEY REFERENCES ListRow(Id),
    FileAttachmentName NVARCHAR(255),
    FileUrl NVARCHAR(500),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListRowComment (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListRowId INT FOREIGN KEY REFERENCES ListRow(Id),
    Content NVARCHAR(MAX),
    CreatedBy INT FOREIGN KEY REFERENCES Account(Id),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Trash (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EntityType NVARCHAR(50), -- 'List', 'ListItem', 'FileAttachment'
    EntityId INT, -- ID of the deleted entity
    UserDeleteId INT FOREIGN KEY REFERENCES Account(Id),
    DeletedAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Activity (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    ListRowId INT FOREIGN KEY REFERENCES ListRow(Id),
    ListCommentId INT FOREIGN KEY REFERENCES ListRowComment(Id),
    ActionType NVARCHAR(100),
    Note NVARCHAR(MAX),
    CreatedBy INT FOREIGN KEY REFERENCES Account(Id),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ListMemberPermission (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    AccountId INT FOREIGN KEY REFERENCES Account(Id), -- The user receiving the permission
    HighestPermissionId INT FOREIGN KEY REFERENCES Permission(Id),
    HighestPermissionCode NVARCHAR(50),
    GrantedByAccountId INT FOREIGN KEY REFERENCES Account(Id),
    Note NVARCHAR(MAX),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);
CREATE TABLE Scope (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50) NOT NULL UNIQUE, -- e.g., 'PUBLIC', 'AUTHORIZED', 'SPECIFIC'
    DisplayName NVARCHAR(100) NOT NULL,       -- Display name
    ScopeDescription NVARCHAR(255),         -- Optional description
    Icon NVARCHAR(100)                 -- Icon name or path
);

CREATE TABLE ShareLink (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ListId INT FOREIGN KEY REFERENCES List(Id),
    TargetUrl NVARCHAR(500),
    ScopeId INT FOREIGN KEY REFERENCES Scope(Id),
    PermissionId INT FOREIGN KEY REFERENCES Permission(Id),
    ExpirationDate DATETIME,
    LinkStatus NVARCHAR(50) DEFAULT 'Active',
    IsLoginRequired BIT,
    LinkPassword NVARCHAR(255),
    CreatedBy INT FOREIGN KEY REFERENCES Account(Id),
    CreateAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateAt DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE ShareLinkUserAccess (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ShareLinkId INT NOT NULL FOREIGN KEY REFERENCES ShareLink(Id),
    AccountId INT NULL FOREIGN KEY REFERENCES Account(Id),
    Email NVARCHAR(255) NOT NULL
);

CREATE TABLE ShareLinkSettingValue (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ShareLinkId INT NOT NULL REFERENCES ShareLink(Id),         
    KeySettingId INT NOT NULL REFERENCES KeySetting(Id), 
    KeyValue NVARCHAR(255) NOT NULL                    
);
GO
