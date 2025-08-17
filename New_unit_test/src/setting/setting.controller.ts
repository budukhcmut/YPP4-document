import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { SettingService } from './setting.service';
import { SettingUserDto } from './dto/setting.dto';

@Controller('setting')
export class SettingController {
  constructor(private readonly settingService: SettingService) {}

  @Get('user/:userId')
  async getUserSettings(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<SettingUserDto[]> {
    return this.settingService.getUserSettings(userId);
  }
}
