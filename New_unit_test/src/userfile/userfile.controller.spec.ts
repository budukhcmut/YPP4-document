import { DataSource } from 'typeorm';
import { UserFileRepository } from './userfile.repository';

describe('UserFileRepository (integration)', () => {
  let dataSource: DataSource;
  let repo: UserFileRepository;

  beforeAll(async () => {
    dataSource = new DataSource({
      type: 'sqlite',
      database: ':memory:',
      synchronize: false,
    });

    await dataSource.initialize();

    // tạo bảng với đầy đủ cột
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
        ModifiedDate TEXT,
        UserFileStatus TEXT,
        CreatedAt TEXT DEFAULT (datetime('now'))
      );
    `);

    // seed dữ liệu (đầy đủ cột)
    await dataSource.query(
      `INSERT INTO UserFile (FolderId, OwnerId, Size, UserFileName, UserFilePath, UserFileThumbNailImg, FileTypeId, ModifiedDate, UserFileStatus)
       VALUES
       (1, 10, 12345, 'file1.txt', '/files/file1.txt', '/thumbs/file1.png', 2, '2025-08-01 10:00:00', 'active'),
       (NULL, 11, 54321, 'image.png', '/files/image.png', NULL, 3, NULL, 'active');`
    );

    repo = new UserFileRepository(dataSource);
  }, 10000);

  afterAll(async () => {
    if (dataSource && dataSource.isInitialized) await dataSource.destroy();
  });

  it('trả về đầy đủ row khi FileId tồn tại', async () => {
    const rows = await repo.getFullById(1);
    expect(rows.length).toBe(1);
    expect(rows[0]).toMatchObject({
      FileId: 1,
      FolderId: 1,
      OwnerId: 10,
      Size: 12345,
      UserFileName: 'file1.txt',
      UserFilePath: '/files/file1.txt',
      UserFileThumbNailImg: '/thumbs/file1.png',
      FileTypeId: 2,
      UserFileStatus: 'active',
    });
    // CreatedAt / ModifiedDate có thể khác dạng, nên chỉ assert một số field chính
  });

  it('trả về mảng rỗng khi FileId không tồn tại', async () => {
    const rows = await repo.getFullById(9999);
    expect(rows).toEqual([]);
  });

  it('xử lý FileId = null/invalid (trả mảng rỗng hoặc throw tuỳ impl)', async () => {
    // tuỳ theo cách bạn muốn, hiện repo sẽ truyền param vào query; SQLite coi null != value -> trả rỗng
    const rows = await repo.getFullById(null as any);
    expect(rows).toEqual([]);
  });
});
