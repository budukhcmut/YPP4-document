// src/account/account.controller.ts
import { Controller, Get, Param } from '@nestjs/common';
import { AccountService } from './account.service';

@Controller('account')
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get(':id/basic-info')
  getBasicInfo(@Param('id') id: number) {
    return this.accountService.getBasicInfo(id);
  }
}
