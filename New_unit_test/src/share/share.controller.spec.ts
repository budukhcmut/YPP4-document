import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account } from '../../entities/account.entity';
import { Share } from '../../entities/share.entity';
import { SharedUser } from '../../entities/shareduser.entity';
import { ShareService } from './share.service';
import { ShareRepository } from './share.repository';
import { CacheService } from '../../utils/cache.service';

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
      providers: [ShareService, ShareRepository , CacheService],
    }).compile();

    service = module.get<ShareService>(ShareService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getSharedFilesByUserId', () => {
    it('should return shared files for an existing user', async () => {
      const result = await service.findSharedFiles(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('userFileName');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.findSharedFiles(9999);
      expect(result).toEqual([]);
    });
  });
  

  describe('getSharedFilesWithPermissionByUserId', () => {
    it('should return shared files with permission for an existing user', async () => {
      const result = await service.findSharedFiles(1);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('userFileName');
        expect(result[0]).toHaveProperty('permissionNamell');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.findSharedFiles(9999);
      expect(result).toEqual([]);
    });
  });

  describe('getSharedFolders', () => {
    it ('should return shared folders for an existing user', async () => {
      const userId = 1;
      const result = await service.findSharedFolders(userId);
      
      expect(result.length).toBeGreaterThan(0);
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1;
      const result = await service.findSharedFolders(userId);
      expect(result).toEqual([]);
    });
  }
  ); 
}) ;
