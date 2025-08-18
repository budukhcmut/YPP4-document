import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { SettingUserDto } from './dto/setting.dto';
import { SettingUser } from '../../entities/settinguser.entity';
import { CacheService } from '../../utils/cache.service';

@Injectable()
export class SettingRepository {
  constructor(
    @InjectRepository(SettingUser)
    private readonly settingRepository: Repository<SettingUser>,
    private readonly cacheService: CacheService,
  ) {}

  async findUserSettings(userId: number): Promise<SettingUserDto[]> {
    const cacheKey = `userSettings:${userId}`;
    const cachedSettings = await this.cacheService.get<SettingUserDto[]>(cacheKey);
    if (cachedSettings) {
      return cachedSettings;  
    }
    await this.settingRepository.query('PRAGMA read_uncommited =1');
    const userSettings: SettingUserDto[] = await this.settingRepository.query(
      `
      SELECT 
        su.SettingUserId as settingUserId,
        a.UserName as userName,
        s.SettingKey as settingKey,
        s.SettingValue as settingValue
      FROM SettingUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN AppSetting s ON su.SettingId = s.SettingId
      WHERE a.UserId = ?
    `,

    [userId]) ;
  
    return userSettings;
  }
}

