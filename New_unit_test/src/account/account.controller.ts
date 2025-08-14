// src/account/account.controller.ts
import { Controller, Get, Param } from '@nestjs/common';
import { AccountService } from './account.service';
import { BasicInfoDto } from './dto/account.dto';

@Controller('account')
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get('getBasicInfo')
  async getBasicInfo(userId: number): Promise<BasicInfoDto | null> {
    return await this.accountService.getBasicInfo(userId);
  }
}
