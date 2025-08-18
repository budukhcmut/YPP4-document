import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';

import { SettingService } from './setting.service';
import { SettingUserDto } from './dto/setting.dto';

@Controller('setting')
export class SettingController {
  constructor(private readonly settingService: SettingService) {}

  async findUserSettings(userId: number): Promise<SettingUserDto []> {
      return await this.settingService.findUserSettings(userId);
    }

}
