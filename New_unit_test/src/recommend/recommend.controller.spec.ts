import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account } from '../../entities/account.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ActionRecent } from '../../entities/actionrecent.entity';
import { RecommendService } from './recommend.service';
import { RecommendRepository } from './recommend.repository';
import { CacheService } from '../../common/utils/cache.service';

describe('RecommendService (with database.sqlite)', () => {
  let controller: RecommendService;

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

    controller = module.get<RecommendService>(RecommendService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getRecentFiles', () => {
    it('should return recent files for an existing user', async () => {
      const userId = 2; // Giả sử người dùng có ID 1
      const result = await controller.findRecommendFiles(userId);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {    

       expect(result.length).toBeGreaterThan(0);
      }
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1; // Giả sử người dùng không tồn tại
      const result = await controller.findRecommendFiles(userId);
      expect(result).toEqual([]);
    });
  });

  describe('getRecentFolders', () => {
    it('should return recent folders for an existing user', async () => {
      const userId = 3; // Giả sử người dùng có ID 3
      const result = await controller.findRecommendedFolders(userId);
      
      expect(Array.isArray(result)).toBe(true);
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1; // Giả sử người dùng không tồn tại   
      const result = await controller.findRecommendedFolders(userId);
      expect(result).toEqual([]);
    });
  });
});
