import { Injectable } from '@nestjs/common';

import { SettingRepository } from './setting.repository';
import { SettingUserDto } from './dto/setting.dto';


@Injectable()
export class SettingService {
  constructor(private readonly settingRepository: SettingRepository) {}

  async findUserSettings(userId: number): Promise<SettingUserDto[]> {
    return this.settingRepository.findUserSettings(userId);
  }
}
