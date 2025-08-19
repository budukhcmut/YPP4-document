// src/modules/account/account/account.controller.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

import { AccountController } from './account.controller';
import { AccountService } from './account.service';
import { AccountRepository } from './account.repository';
import { Account } from '../../entities/account.entity'; 
import { CacheService } from '../../common/utils/cache.service';

describe('AccountController (raw SQL query)', () => {
  let controller: AccountController;
  let module: TestingModule;

  beforeAll(async () => {
    module = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite',
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
        }),
        TypeOrmModule.forFeature([Account]),
      ],
      controllers: [AccountController],
      providers: [AccountRepository, AccountService , CacheService],
    }).compile();

    controller = module.get<AccountController>(AccountController);
  });
  
afterAll(async () => {
    await module.close(); 
  });

  it ('should be defined', () => {
    expect(controller).toBeDefined(); 
  });

describe('findBasicInfo', () => {
    it('should get basic info for a specific user', async () => {
      const userId = 1;
      const result = await controller.findBasicInfo(userId);
      expect(result).toBeDefined();
      
    });

    it('should return an empty array for a non-existent user', async () => {
      const userId = -1; // Assuming this user does not exist
      const result = await controller.findBasicInfo(userId);
      expect(result).toEqual([]);
    });
  });
}) ;
