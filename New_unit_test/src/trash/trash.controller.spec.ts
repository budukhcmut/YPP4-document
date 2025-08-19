import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Trash } from '../../entities/trash.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ObjectType } from '../../entities/objecttype.entity';

import { TrashService } from './trash.service';
import { TrashRepository } from './trash.repository';
import { CacheService } from '../../common/utils/cache.service';

describe('TrashService (with database.sqlite)', () => {
  let controller: TrashService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // sqlite thật để test
           entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([Trash, UserFile, Folder, ObjectType]),
      ],
      providers: [TrashService, TrashRepository, CacheService],
    }).compile();

    controller = module.get<TrashService>(TrashService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findDeletedFiles', () => {
    it('should return deleted files for an existing user', async () => {
      const userId = 1;
      const result = await controller.findTrashFiles(userId);

      expect(Array.isArray(result)).toBe(true);
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1 ;
      const result = await controller.findTrashFiles(userId);
      expect(result).toEqual([]);
    });
  });

  describe('findDeletedFolders', () => {
    it('should return deleted folders for an existing user', async () => {
      const userId = 1;
      const result = await controller.findTrashFolders(userId);
      
       expect(Array.isArray(result)).toBe(true);
    
      
    });

    it('should return empty array for non-existent user', async () => {
      const userId = -1 ;
      const result = await controller.findTrashFolders(userId);
      expect(result).toEqual([]);
    });
  }
);
  });

