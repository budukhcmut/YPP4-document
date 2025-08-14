import { DataSource } from 'typeorm';

export async function createTables(dataSource: DataSource): Promise<void> {
  console.log('>>> Creating all tables (SQLite)…');

  try {
    // Ensure FK constraints are enforced in SQLite
    await dataSource.query('PRAGMA foreign_keys = OFF');

    // ---- DROP TABLES (children -> parents) ----
    await dataSource.query('DROP TABLE IF EXISTS SharedUser');
    await dataSource.query('DROP TABLE IF EXISTS FileVersion');
    await dataSource.query('DROP TABLE IF EXISTS SearchIndex');
    await dataSource.query('DROP TABLE IF EXISTS Term');
    await dataSource.query('DROP TABLE IF EXISTS FileContent');
    await dataSource.query('DROP TABLE IF EXISTS UserFile');
    await dataSource.query('DROP TABLE IF EXISTS Share');
    await dataSource.query('DROP TABLE IF EXISTS Trash');
    await dataSource.query('DROP TABLE IF EXISTS FavoriteObject');
    await dataSource.query('DROP TABLE IF EXISTS ActionRecent');
    await dataSource.query('DROP TABLE IF EXISTS SearchHistory');
    await dataSource.query('DROP TABLE IF EXISTS UserSession');
    await dataSource.query('DROP TABLE IF EXISTS SettingUser');
    await dataSource.query('DROP TABLE IF EXISTS UserProduct');
    await dataSource.query('DROP TABLE IF EXISTS BannedUser');
    await dataSource.query('DROP TABLE IF EXISTS Folder');
    await dataSource.query('DROP TABLE IF EXISTS FileType');
    await dataSource.query('DROP TABLE IF EXISTS ProductItem');
    await dataSource.query('DROP TABLE IF EXISTS Promotion');
    await dataSource.query('DROP TABLE IF EXISTS AppSetting');
    await dataSource.query('DROP TABLE IF EXISTS Permission');
    await dataSource.query('DROP TABLE IF EXISTS ObjectType');
    await dataSource.query('DROP TABLE IF EXISTS Color');
    await dataSource.query('DROP TABLE IF EXISTS Account');

    await dataSource.query('PRAGMA foreign_keys = ON');
    console.log('>>> All existing tables dropped');

    // ---- CREATE TABLES (parents -> children) ----

    // Account
    await dataSource.query(`
      CREATE TABLE Account (
        UserId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserName TEXT NOT NULL,
        Email TEXT UNIQUE NOT NULL,
        PasswordHash TEXT NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UserImg TEXT,
        LastLogin DATETIME,
        UsedCapacity INTEGER,
        Capacity INTEGER
      )
    `);

    // Color
    await dataSource.query(`
      CREATE TABLE Color (
        ColorId INTEGER PRIMARY KEY AUTOINCREMENT,
        ColorName TEXT,
        ColorIcon TEXT
      )
    `);

    // Permission
    await dataSource.query(`
      CREATE TABLE Permission (
        PermissionId INTEGER PRIMARY KEY AUTOINCREMENT,
        PermissionName TEXT NOT NULL,
        PermissionPriority INTEGER
      )
    `);

    // ObjectType
    await dataSource.query(`
      CREATE TABLE ObjectType (
        ObjectTypeId INTEGER PRIMARY KEY AUTOINCREMENT,
        ObjectTypeName TEXT NOT NULL
      )
    `);

    // Folder
    await dataSource.query(`
      CREATE TABLE Folder (
        FolderId INTEGER PRIMARY KEY AUTOINCREMENT,
        ParentId INTEGER,
        OwnerId INTEGER NOT NULL,
        FolderName TEXT NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UpdatedAt DATETIME,
        FolderPath TEXT,
        FolderStatus TEXT,
        ColorId INTEGER,
        FOREIGN KEY (ParentId) REFERENCES Folder(FolderId),
        FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
        FOREIGN KEY (ColorId) REFERENCES Color(ColorId)
      )
    `);

    // FileType
    await dataSource.query(`
      CREATE TABLE FileType (
        FileTypeId INTEGER PRIMARY KEY AUTOINCREMENT,
        FileTypeName TEXT NOT NULL,
        Icon TEXT
      )
    `);

    // UserFile
    await dataSource.query(`
      CREATE TABLE UserFile (
        FileId INTEGER PRIMARY KEY AUTOINCREMENT,
        FolderId INTEGER,
        OwnerId INTEGER NOT NULL,
        Size INTEGER,
        UserFileName TEXT NOT NULL,
        UserFilePath TEXT,
        UserFileThumbNailImg TEXT,
        FileTypeId INTEGER,
        ModifiedDate DATETIME,
        UserFileStatus TEXT,
        CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (FolderId) REFERENCES Folder(FolderId),
        FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
        FOREIGN KEY (FileTypeId) REFERENCES FileType(FileTypeId)
      )
    `);

    // Share
    await dataSource.query(`
      CREATE TABLE Share (
        ShareId INTEGER PRIMARY KEY AUTOINCREMENT,
        Sharer INTEGER NOT NULL,
        ObjectId INTEGER NOT NULL,
        ObjectTypeId INTEGER NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        ShareUrl TEXT,
        UrlApprove INTEGER,
        FOREIGN KEY (Sharer) REFERENCES Account(UserId),
        FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
      )
    `);

    // SharedUser
    await dataSource.query(`
      CREATE TABLE SharedUser (
        SharedUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        ShareId INTEGER,
        UserId INTEGER,
        PermissionId INTEGER,
        CreatedAt DATETIME,
        ModifiedAt DATETIME,
        FOREIGN KEY (ShareId) REFERENCES Share(ShareId),
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (PermissionId) REFERENCES Permission(PermissionId)
      )
    `);

    // FileVersion
    await dataSource.query(`
      CREATE TABLE FileVersion (
        FileVersionId INTEGER PRIMARY KEY AUTOINCREMENT,
        FileId INTEGER,
        FileVersion INTEGER NOT NULL,
        FileVersionPath TEXT,
        CreatedAt DATETIME,
        UpdateBy INTEGER,
        IsCurrent INTEGER,
        VersionFile TEXT,
        Size INTEGER,
        FOREIGN KEY (FileId) REFERENCES UserFile(FileId),
        FOREIGN KEY (UpdateBy) REFERENCES Account(UserId)
      )
    `);

    // Trash
    await dataSource.query(`
      CREATE TABLE Trash (
        TrashId INTEGER PRIMARY KEY AUTOINCREMENT,
        ObjectId INTEGER NOT NULL,
        ObjectTypeId INTEGER NOT NULL,
        RemovedDatetime DATETIME,
        UserId INTEGER,
        IsPermanent INTEGER DEFAULT 0,
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
      )
    `);

    // ProductItem
    await dataSource.query(`
      CREATE TABLE ProductItem (
        ProductId INTEGER PRIMARY KEY AUTOINCREMENT,
        ProductName TEXT NOT NULL,
        Cost REAL NOT NULL,
        Duration INTEGER NOT NULL
      )
    `);

    // Promotion
    await dataSource.query(`
      CREATE TABLE Promotion (
        PromotionId INTEGER PRIMARY KEY AUTOINCREMENT,
        PromotionName TEXT NOT NULL,
        Discount INTEGER NOT NULL,
        IsPercent INTEGER NOT NULL
      )
    `);

    // UserProduct
    await dataSource.query(`
      CREATE TABLE UserProduct (
        UserProductId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER,
        ProductId INTEGER,
        PayingDatetime DATETIME,
        IsFirstPaying INTEGER,
        PromotionId INTEGER,
        EndDatetime DATETIME,
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (ProductId) REFERENCES ProductItem(ProductId),
        FOREIGN KEY (PromotionId) REFERENCES Promotion(PromotionId)
      )
    `);

    // BannedUser
    await dataSource.query(`
      CREATE TABLE BannedUser (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER,
        BannedAt DATETIME,
        BannedUserId INTEGER,
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (BannedUserId) REFERENCES Account(UserId)
      )
    `);

    // FavoriteObject
    await dataSource.query(`
      CREATE TABLE FavoriteObject (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        OwnerId INTEGER,
        ObjectId INTEGER NOT NULL,
        ObjectTypeId INTEGER NOT NULL,
        FOREIGN KEY (OwnerId) REFERENCES Account(UserId),
        FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
      )
    `);

    // ActionRecent
    await dataSource.query(`
      CREATE TABLE ActionRecent (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER,
        ObjectId INTEGER,
        ObjectTypeId INTEGER,
        ActionLog TEXT,
        ActionDateTime DATETIME,
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (ObjectTypeId) REFERENCES ObjectType(ObjectTypeId)
      )
    `);

    // SearchHistory
    await dataSource.query(`
      CREATE TABLE SearchHistory (
        SearchId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER,
        SearchToken TEXT,
        SearchDatetime DATETIME,
        FOREIGN KEY (UserId) REFERENCES Account(UserId)
      )
    `);

    // UserSession
    await dataSource.query(`
      CREATE TABLE UserSession (
        SessionId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER,
        Token TEXT NOT NULL,
        CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        ExpiresAt DATETIME,
        FOREIGN KEY (UserId) REFERENCES Account(UserId)
      )
    `);

    // AppSetting
    await dataSource.query(`
      CREATE TABLE AppSetting (
        SettingId INTEGER PRIMARY KEY AUTOINCREMENT,
        SettingKey TEXT,
        SettingValue TEXT,
        Decription TEXT
      )
    `);

    // SettingUser
    await dataSource.query(`
      CREATE TABLE SettingUser (
        SettingUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        SettingId INTEGER,
        UserId INTEGER,
        FOREIGN KEY (UserId) REFERENCES Account(UserId),
        FOREIGN KEY (SettingId) REFERENCES AppSetting(SettingId)
      )
    `);

    // Indexes for names (from original script)
    await dataSource.query(`CREATE INDEX IF NOT EXISTS idx_file_name ON UserFile(UserFileName)`);
    await dataSource.query(`CREATE INDEX IF NOT EXISTS idx_folder_name ON Folder(FolderName)`);

    // FileContent
    await dataSource.query(`
      CREATE TABLE FileContent (
        ContentId INTEGER PRIMARY KEY AUTOINCREMENT,
        FileId INTEGER NOT NULL,
        ContentChunk TEXT NOT NULL,
        ChunkIndex INTEGER NOT NULL,
        DocumentLength INTEGER,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (FileId) REFERENCES UserFile(FileId),
        CONSTRAINT UC_FileContent UNIQUE (FileId, ChunkIndex)
      )
    `);

    // Term
    await dataSource.query(`
      CREATE TABLE Term (
        TermId INTEGER PRIMARY KEY AUTOINCREMENT,
        Term TEXT NOT NULL,
        FileContentId INTEGER NOT NULL,
        CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (FileContentId) REFERENCES FileContent(ContentId)
      )
    `);

    // SearchIndex
    await dataSource.query(`
      CREATE TABLE SearchIndex (
        SearchIndexId INTEGER PRIMARY KEY AUTOINCREMENT,
        FileContentId INTEGER NOT NULL,
        Term TEXT NOT NULL,
        TermFrequency INTEGER NOT NULL,
        TermPositions TEXT,
        Bm25Score REAL NOT NULL DEFAULT 0,
        IDF REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (FileContentId) REFERENCES FileContent(ContentId),
        CONSTRAINT UC_SearchIndex UNIQUE (FileContentId, Term),
        CONSTRAINT CHK_IDF_NonNegative CHECK (IDF >= 0)
      )
    `);

    // Indexes matching original
    await dataSource.query(`CREATE INDEX IF NOT EXISTS IX_Term_Term ON Term (Term, FileContentId)`);
    await dataSource.query(`CREATE INDEX IF NOT EXISTS IX_SearchIndex_Term ON SearchIndex (Term, FileContentId)`);

    console.log('>>> All tables created successfully!');
  } catch (error) {
    console.error('>>> Error creating tables: ', error);
    throw error;
  }
}
