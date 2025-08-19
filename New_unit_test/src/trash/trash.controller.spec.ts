import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Trash } from '../../entities/trash.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ObjectType } from '../../entities/objecttype.entity';

import { TrashService } from './trash.service';
import { TrashRepository } from './trash.repository';
import { CacheService } from '../../utils/cache.service';

describe('TrashService (with database.sqlite)', () => {
  let service: TrashService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // sqlite thật để test
          entities: [__dirname + '/../../entities/*.entity{.ts,.js}'],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([Trash, UserFile, Folder, ObjectType]),
      ],
      providers: [TrashService, TrashRepository, CacheService],
    }).compile();

    service = module.get<TrashService>(TrashService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findDeletedFiles', () => {
    it('should return deleted files for an existing user', async () => {
      const userId = 1;
      const result = await service.findTrashFiles(userId);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('fileId');
        expect(result[0]).toHaveProperty('trashId');
        expect(result[0]).toHaveProperty('objectTypeName');
        expect(result[0]).toHaveProperty('userFileName');
        expect(result[0]).toHaveProperty('removedDatetime');
        expect(result[0]).toHaveProperty('isPermanent');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.findTrashFiles(9999);
      expect(result).toEqual([]);
    });
  });

  describe('findDeletedFolders', () => {
    it('should return deleted folders for an existing user', async () => {
      const userId = 1;
      const result = await service.findTrashFolders(userId);

      expect(Array.isArray(result)).toBe(true);
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('folderId');
        expect(result[0]).toHaveProperty('trashId');
        expect(result[0]).toHaveProperty('objectTypeName');
        expect(result[0]).toHaveProperty('folderName');
        expect(result[0]).toHaveProperty('removedDatetime');
        expect(result[0]).toHaveProperty('isPermanent');
      }
    });

    it('should return empty array for non-existent user', async () => {
      const result = await service.findTrashFolders(9999);
      expect(result).toEqual([]);
    });
  });
});
