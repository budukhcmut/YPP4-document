import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';


import { UserFile } from '../../entities/userfile.entity';
import { UserFileController } from './userfile.controller';
import { UserFileRepository } from './userfile.repository';
import { UserFileService } from './userfile.service';
import { CacheService } from '../../common/utils/cache.service';




describe('UserFileRepository', () => {
    let controller: UserFileController; 
    let module: TestingModule;

    beforeAll(async () => {
      module = await Test.createTestingModule({
            imports: [
              TypeOrmModule.forRoot({
                type: 'sqlite',
                database: 'database.sqlite',
                entities: [__dirname + '/**/*.entity{.ts,.js}'],
              }),
              TypeOrmModule.forFeature([UserFile]),
            ],
            controllers: [UserFileController],
            providers: [UserFileRepository, UserFileService , CacheService],
          }).compile();

      controller = module.get<UserFileController>(UserFileController);
    });
    afterAll(async () => {
      await module.close();
    });
    it('should be defined', () => {
      expect(controller).toBeDefined();
    });
    

    describe('getMyFilesFull', () => {
      it('should return full file details for a specific user', async () => {
        const userId = 1; // Assuming this user exists
        const result = await controller.findMyFiles(userId);
        expect(result).toBeDefined();
        expect(Array.isArray(result)).toBe(true);
      });

      it('should return an empty array for a non-existent user', async () => {
        const userId = -1; // Assuming this user does not exist
        const result = await controller.findMyFiles(userId);
        expect(result).toEqual([]);
      });
    });
  });


      