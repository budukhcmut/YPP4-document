import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account } from '../../entities/account.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ActionRecent } from '../../entities/actionrecent.entity';
import { RecommendService } from './recommend.service';
import { RecommendRepository } from './recommend.repository';
import { CacheService } from '../../utils/cache.service';

describe('RecommendService (with database.sqlite)', () => {
  let service: RecommendService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // vẫn dùng sqlite thật
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([Account, UserFile, Folder, ActionRecent]),
      ],
      providers: [RecommendService, RecommendRepository , CacheService],
    }).compile();

    service = module.get<RecommendService>(RecommendService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getRecentFiles', () => {
    it('should return recent files for an existing user', async () => {
      const userId = 2; // Giả sử người dùng có ID 1
      const result = await service.findRecommendFiles(userId);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {    

        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('userFileName');
        expect(result[0]).toHaveProperty('actionLog');
        expect(result[0]).toHaveProperty('actionDateTime');
      }
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1; // Giả sử người dùng không tồn tại
      const result = await service.findRecommendFiles(userId);
      expect(result).toEqual([]);
    });
  });

  describe('getRecentFolders', () => {
    it('should return recent folders for an existing user', async () => {
      const userId = 3; // Giả sử người dùng có ID 3
      const result = await service.findRecommendedFolders(userId);
      

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('folderId');
        expect(result[0]).toHaveProperty('userName');
        expect(result[0]).toHaveProperty('folderName');
        expect(result[0]).toHaveProperty('actionLog');
        expect(result[0]).toHaveProperty('actionDateTime');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1; // Giả sử người dùng không tồn tại   
      const result = await service.findRecommendedFolders(userId);
      expect(result).toEqual([]);
    });
  });
});
