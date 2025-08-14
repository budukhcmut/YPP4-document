import { DataSource } from 'typeorm';

export async function insertSampleData(dataSource: DataSource): Promise<void> {
  console.log('>>> Inserting sample data...');

  try {
    // Tắt ràng buộc khóa ngoại để xóa dữ liệu an toàn
    await dataSource.query('PRAGMA foreign_keys = OFF');

    // Xóa dữ liệu từ các bảng (xóa từ bảng con trước để tránh lỗi khóa ngoại)
    await dataSource.query('DELETE FROM SearchIndex');
    await dataSource.query('DELETE FROM Term');
    await dataSource.query('DELETE FROM FileContent');
    await dataSource.query('DELETE FROM SharedUser');
    await dataSource.query('DELETE FROM FileVersion');
    await dataSource.query('DELETE FROM UserFile');
    await dataSource.query('DELETE FROM Share');
    await dataSource.query('DELETE FROM Trash');
    await dataSource.query('DELETE FROM FavoriteObject');
    await dataSource.query('DELETE FROM ActionRecent');
    await dataSource.query('DELETE FROM SearchHistory');
    await dataSource.query('DELETE FROM UserSession');
    await dataSource.query('DELETE FROM SettingUser');
    await dataSource.query('DELETE FROM UserProduct');
    await dataSource.query('DELETE FROM BannedUser');
    await dataSource.query('DELETE FROM Folder');
    await dataSource.query('DELETE FROM FileType');
    await dataSource.query('DELETE FROM ProductItem');
    await dataSource.query('DELETE FROM Promotion');
    await dataSource.query('DELETE FROM AppSetting');
    await dataSource.query('DELETE FROM Permission');
    await dataSource.query('DELETE FROM ObjectType');
    await dataSource.query('DELETE FROM Color');
    await dataSource.query('DELETE FROM Account');

    // Reset sequence tự động tăng của SQLite
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="SearchIndex"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Term"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="FileContent"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="SharedUser"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="FileVersion"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="UserFile"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Share"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Trash"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="FavoriteObject"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="ActionRecent"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="SearchHistory"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="UserSession"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="SettingUser"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="UserProduct"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="BannedUser"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Folder"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="FileType"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="ProductItem"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Promotion"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="AppSetting"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Permission"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="ObjectType"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Color"');
    await dataSource.query('DELETE FROM sqlite_sequence WHERE name="Account"');

    // Bật lại ràng buộc khóa ngoại
    await dataSource.query('PRAGMA foreign_keys = ON');

    console.log('>>> Đã xóa dữ liệu cũ thành công!');

    // Chèn dữ liệu (bảng cha trước, bảng con sau)
    await dataSource.query(`
      INSERT INTO Account (UserName, Email, PasswordHash, CreatedAt, UserImg, LastLogin, UsedCapacity, Capacity)
      VALUES
        ('John Doe', 'john.doe@example.com', 'hash123', '2025-08-13 21:38:00', 'https://example.com/avatars/john.jpg', '2025-08-13 21:00:00', 100, 1000),
        ('Jane Smith', 'jane.smith@example.com', 'hash456', '2025-08-13 21:38:00', 'https://example.com/avatars/jane.jpg', '2025-08-13 21:01:00', 200, 2000),
        ('Mike Johnson', 'mike.johnson@example.com', 'hash789', '2025-08-13 21:38:00', NULL, '2025-08-13 21:02:00', 300, 3000)
    `);

    await dataSource.query(`
      INSERT INTO Color (ColorName, ColorIcon)
      VALUES
        ('Red', 'red_icon.png'),
        ('Blue', 'blue_icon.png'),
        ('Green', 'green_icon.png')
    `);

    await dataSource.query(`
      INSERT INTO Permission (PermissionName, PermissionPriority)
      VALUES
        ('Read', 1),
        ('Write', 2),
        ('Admin', 3)
    `);

    await dataSource.query(`
      INSERT INTO ObjectType (ObjectTypeName)
      VALUES
        ('File'),
        ('Folder'),
        ('Share')
    `);

    await dataSource.query(`
      INSERT INTO Folder (ParentId, OwnerId, FolderName, CreatedAt, UpdatedAt, FolderPath, FolderStatus, ColorId)
      VALUES
        (NULL, 1, 'Root Folder', '2025-08-13 21:38:00', '2025-08-13 21:38:00', '/root', 'Active', 1),
        (1, 2, 'Sub Folder', '2025-08-13 21:38:00', '2025-08-13 21:38:00', '/root/sub', 'Active', 2),
        (NULL, 3, 'Documents', '2025-08-13 21:38:00', '2025-08-13 21:38:00', '/docs', 'Active', 3)
    `);

    await dataSource.query(`
      INSERT INTO FileType (FileTypeName, Icon)
      VALUES
        ('PDF', 'pdf_icon.png'),
        ('Image', 'image_icon.png'),
        ('Text', 'text_icon.png')
    `);

    await dataSource.query(`
      INSERT INTO UserFile (FolderId, OwnerId, Size, UserFileName, UserFilePath, UserFileThumbNailImg, FileTypeId, ModifiedDate, UserFileStatus, CreatedAt)
      VALUES
        (1, 1, 1024, 'Document.pdf', '/root/document.pdf', 'thumb1.jpg', 1, '2025-08-13 21:38:00', 'Active', '2025-08-13 21:38:00'),
        (2, 2, 2048, 'Photo.jpg', '/root/sub/photo.jpg', 'thumb2.jpg', 2, '2025-08-13 21:38:00', 'Active', '2025-08-13 21:38:00'),
        (3, 3, 512, 'Notes.txt', '/docs/notes.txt', 'thumb3.jpg', 3, '2025-08-13 21:38:00', 'Active', '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO Share (Sharer, ObjectId, ObjectTypeId, CreatedAt, ShareUrl, UrlApprove)
      VALUES
        (1, 1, 1, '2025-08-13 21:38:00', 'https://share.com/file1', 1),
        (2, 2, 2, '2025-08-13 21:38:00', 'https://share.com/folder2', 0),
        (3, 3, 1, '2025-08-13 21:38:00', 'https://share.com/file3', 1)
    `);

    await dataSource.query(`
      INSERT INTO SharedUser (ShareId, UserId, PermissionId, CreatedAt, ModifiedAt)
      VALUES
        (1, 2, 1, '2025-08-13 21:38:00', '2025-08-13 21:38:00'),
        (2, 3, 2, '2025-08-13 21:38:00', '2025-08-13 21:38:00'),
        (3, 1, 3, '2025-08-13 21:38:00', '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO FileVersion (FileId, FileVersion, FileVersionPath, CreatedAt, UpdateBy, IsCurrent, VersionFile, Size)
      VALUES
        (1, 1, '/root/document_v1.pdf', '2025-08-13 21:38:00', 1, 1, 'document_v1.pdf', 1024),
        (2, 1, '/root/sub/photo_v1.jpg', '2025-08-13 21:38:00', 2, 1, 'photo_v1.jpg', 2048),
        (3, 1, '/docs/notes_v1.txt', '2025-08-13 21:38:00', 3, 1, 'notes_v1.txt', 512)
    `);

    await dataSource.query(`
      INSERT INTO Trash (ObjectId, ObjectTypeId, RemovedDatetime, UserId, IsPermanent)
      VALUES
        (1, 1, '2025-08-13 21:38:00', 1, 0),
        (2, 2, '2025-08-13 21:38:00', 2, 0),
        (3, 1, '2025-08-13 21:38:00', 3, 1)
    `);

    await dataSource.query(`
      INSERT INTO ProductItem (ProductName, Cost, Duration)
      VALUES
        ('Basic Plan', 10.0, 30),
        ('Pro Plan', 20.0, 30),
        ('Premium Plan', 50.0, 90)
    `);

    await dataSource.query(`
      INSERT INTO Promotion (PromotionName, Discount, IsPercent)
      VALUES
        ('Summer Sale', 10, 1),
        ('New User', 5, 0),
        ('Loyalty Discount', 15, 1)
    `);

    await dataSource.query(`
      INSERT INTO UserProduct (UserId, ProductId, PayingDatetime, IsFirstPaying, PromotionId, EndDatetime)
      VALUES
        (1, 1, '2025-08-13 21:38:00', 1, 1, '2025-09-12 21:38:00'),
        (2, 2, '2025-08-13 21:38:00', 0, 2, '2025-09-12 21:38:00'),
        (3, 3, '2025-08-13 21:38:00', 1, 3, '2025-11-11 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO BannedUser (UserId, BannedAt, BannedUserId)
      VALUES
        (1, '2025-08-13 21:38:00', 2),
        (2, '2025-08-13 21:38:00', 3),
        (3, '2025-08-13 21:38:00', 1)
    `);

    await dataSource.query(`
      INSERT INTO FavoriteObject (OwnerId, ObjectId, ObjectTypeId)
      VALUES
        (1, 1, 1),
        (2, 2, 2),
        (3, 3, 1)
    `);

    await dataSource.query(`
      INSERT INTO ActionRecent (UserId, ObjectId, ObjectTypeId, ActionLog, ActionDateTime)
      VALUES
        (1, 1, 1, 'Viewed file', '2025-08-13 21:38:00'),
        (2, 2, 2, 'Created folder', '2025-08-13 21:38:00'),
        (3, 3, 1, 'Shared file', '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO SearchHistory (UserId, SearchToken, SearchDatetime)
      VALUES
        (1, 'document', '2025-08-13 21:38:00'),
        (2, 'image', '2025-08-13 21:38:00'),
        (3, 'pdf', '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO UserSession (UserId, Token, CreatedAt, ExpiresAt)
      VALUES
        (1, 'token1', '2025-08-13 21:38:00', '2025-08-14 21:38:00'),
        (2, 'token2', '2025-08-13 21:38:00', '2025-08-14 21:38:00'),
        (3, 'token3', '2025-08-13 21:38:00', '2025-08-14 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO AppSetting (SettingKey, SettingValue, Decription)
      VALUES
        ('theme', 'dark', 'Application theme setting'),
        ('language', 'en', 'Default language setting'),
        ('max_upload_size', '10485760', 'Maximum upload size in bytes')
    `);

    await dataSource.query(`
      INSERT INTO SettingUser (SettingId, UserId)
      VALUES
        (1, 1),
        (2, 2),
        (3, 3)
    `);

    await dataSource.query(`
      INSERT INTO FileContent (FileId, ContentChunk, ChunkIndex, DocumentLength, CreatedAt)
      VALUES
        (1, 'Sample PDF content.', 1, 28, '2025-08-13 21:38:00'),
        (2, 'Sample image content.', 1, 30, '2025-08-13 21:38:00'),
        (3, 'Sample text content.', 1, 29, '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO Term (Term, FileContentId, CreatedAt)
      VALUES
        ('sample', 1, '2025-08-13 21:38:00'),
        ('image', 2, '2025-08-13 21:38:00'),
        ('text', 3, '2025-08-13 21:38:00')
    `);

    await dataSource.query(`
      INSERT INTO SearchIndex (FileContentId, Term, TermFrequency, TermPositions, Bm25Score, IDF)
      VALUES
        (1, 'sample', 1, '1', 1.2, 1.0),
        (2, 'image', 1, '1', 1.3, 1.1),
        (3, 'text', 1, '1', 1.4, 1.2)
    `);

    console.log('>>> Done !');
  } catch (error) {
    console.error('>>> Error : ', error);
    throw error;
  } finally {
    // Đảm bảo bật lại ràng buộc khóa ngoại
    await dataSource.query('PRAGMA foreign_keys = ON');
  }
}