import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';


import { FolderController } from './folder.controller';
import { FolderService } from './folder.service';
import { FolderRepository } from './folder.repository';
import { Folder } from '../../entities/folder.entity';
import { CacheService } from '../../common/utils/cache.service';

describe('AccountController (raw SQL query)', () => {
  let controller: FolderController;
  let module: TestingModule;

  beforeAll(async () => {
    module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite',
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
        }),
        TypeOrmModule.forFeature([Folder]),
      ],
      controllers: [FolderController],
      providers: [FolderRepository, FolderService , CacheService],
    }).compile();

controller = module.get<FolderController>(FolderController);
  });   

  afterAll(async () => {
    await module.close();
  });   
  
  it('should be defined', () => {
    expect(controller).toBeDefined();
  }); 
  
  describe('getMyFolders', () => {
    it('should return folders for a specific user', async () => {
      const userId = 1; // Assuming this user exists
      const result = await controller.findMyFolders(userId);
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);

    });

    it('should return an empty array for a non-existent user', async () => {
      const userId = -1; // Assuming this user does not exist
      const result = await controller.findMyFolders(userId);
      expect(result).toEqual([]);
    });
  });       

}) ;
