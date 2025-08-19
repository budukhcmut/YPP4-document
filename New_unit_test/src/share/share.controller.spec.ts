import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Account } from '../../entities/account.entity';
import { Share } from '../../entities/share.entity';
import { SharedUser } from '../../entities/shareduser.entity';
import { ShareService } from './share.service';
import { ShareRepository } from './share.repository';
import { CacheService } from '../../common/utils/cache.service';

describe('ShareService (with database.sqlite)', () => {
  let controller: ShareService;

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

    controller = module.get<ShareService>(ShareService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getSharedFilesByUserId', () => {
    it('should return shared files for an existing user', async () => {
      const userId =1
      const result = await controller.findSharedFiles(userId);

      expect(Array.isArray(result)).toBe(true);
    
    });

    it('should return empty array for non-existent user', async () => {
      const userId =-1 ;
      const result = await controller.findSharedFiles(userId);
      expect(result).toEqual([]);
    });
  });
  

  describe('getSharedFilesWithPermissionByUserId', () => {
    it('should return shared files with permission for an existing user', async () => {
      const userId = 1 ;
      const result = await controller.findSharedFiles(userId);

      expect(Array.isArray(result)).toBe(true);
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1 ;
      const result = await controller.findSharedFiles(userId);
      expect(result).toEqual([]);
    });
  });

  describe('getSharedFolders', () => {
    it ('should return shared folders for an existing user', async () => {
      const userId = 1;
      const result = await controller.findSharedFolders(userId);
      
      expect(result.length).toBeGreaterThan(0);
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1;
      const result = await controller.findSharedFolders(userId);
      expect(result).toEqual([]);
    });
  }
  ); 
}) ;
