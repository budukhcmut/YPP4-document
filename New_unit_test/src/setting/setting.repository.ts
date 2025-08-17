import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SettingUserDto } from './dto/setting.dto';
import { SettingUser } from '../../entities/settinguser.entity';

@Injectable()
export class SettingRepository {
  constructor(
    @InjectRepository(SettingUser)
    private readonly settingRepository: Repository<SettingUser>,
  ) {}

  async getUserSettings(userId: number): Promise<SettingUserDto[]> {
    const sql = `
      SELECT 
        su.SettingUserId as settingUserId,
        a.UserName as userName,
        s.SettingKey as settingKey,
        s.SettingValue as settingValue
      FROM SettingUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN AppSetting s ON su.SettingId = s.SettingId
      WHERE a.UserId = ?
    `;
    const result = await this.settingRepository.query(sql, [userId]);
    return result as SettingUserDto[];
  }
}
