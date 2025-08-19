import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { SettingRepository } from './setting.repository';
import { SettingService } from './setting.service';
import { SettingController } from './setting.controller';
import { SettingUser } from '../../entities/settinguser.entity';
import { AppSetting } from '../../entities/appsetting.entity';
import { Account } from '../../entities/account.entity';
import { CacheService } from '../../common/utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([SettingUser, AppSetting, Account])],
  providers: [SettingService, SettingRepository , CacheService],
  controllers: [SettingController],
})
export class SettingModule {}
