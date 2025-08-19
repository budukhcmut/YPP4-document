import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';

import { SettingService } from './setting.service';
import { SettingRepository } from './setting.repository';
import { SettingUser } from '../../entities/settinguser.entity';
import { AppSetting } from '../../entities/appsetting.entity';
import { Account } from '../../entities/account.entity';
import { CacheService } from '../../common/utils/cache.service';


describe('SettingService (with database.sqlite)', () => {
  let controller: SettingService;
  let module: TestingModule;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: 'database.sqlite', // giữ nguyên sqlite file
           entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true,
        }),
        TypeOrmModule.forFeature([Account, AppSetting, SettingUser]),
      ],
      providers: [SettingService, SettingRepository, CacheService],
    }).compile();

    controller = module.get<SettingService>(SettingService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getUserSettings', () => {
    it('should return user settings for an existing user', async () => {
      const result = await controller.findUserSettings(1);

      expect(Array.isArray(result)).toBe(true);
     
    });

    it('should return empty array for non-existent user', async () => {
      const result = await controller.findUserSettings(9999);
      expect(result).toEqual([]);
    });
  });
});
