import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account } from '../../entities/account.entity';
import { Share } from '../../entities/share.entity';
import { SharedUser } from '../../entities/shareduser.entity';
import { ShareService } from './share.service';
import { ShareRepository } from './share.repository';

describe('ShareService (with database.sqlite)', () => {
  let service: ShareService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // vẫn dùng sqlite thật
           entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([Account, Share, SharedUser]),
      ],
      providers: [ShareService, ShareRepository],
    }).compile();

    service = module.get<ShareService>(ShareService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getSharedFilesByUserId', () => {
    it('should return shared files for an existing user', async () => {
      const result = await service.getSharedFiles(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('userFileName');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.getSharedFiles(9999);
      expect(result).toEqual([]);
    });
  });

  describe('getSharedFilesWithPermissionByUserId', () => {
    it('should return shared files with permission for an existing user', async () => {
      const result = await service.getSharedFilesWithPermission(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('userFileName');
        expect(result[0]).toHaveProperty('permissionName');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.getSharedFilesWithPermission(9999);
      expect(result).toEqual([]);
    });
  });

  describe('getSharedFoldersByUserId', () => {
    it('should return shared folders for an existing user', async () => {
      const result = await service.getSharedFolders(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('folderId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('folderName');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.getSharedFolders(9999);
      expect(result).toEqual([]);
    });
  });

  describe('getSharedFoldersWithPermissionByUserId', () => {
    it('should return shared folders with permission for an existing user', async () => {
      const result = await service.getSharedFoldersWithPermission(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('folderId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('folderName');
        expect(result[0]).toHaveProperty('permissionName');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.getSharedFoldersWithPermission(9999);
      expect(result).toEqual([]);
    });
  });
  });
