import { Controller, Get, Post, Put, Delete, Body, Param, ParseIntPipe } from '@nestjs/common';
import { AccountService } from './account.service';
import { Account } from '../entities/account.entity';

@Controller('account')
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Post()
  create(@Body() account: Account): Account {
    return this.accountService.create(account);
  }

  @Get()
  findAll(): Account[] {
    return this.accountService.findAll();
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number): Account {
    return this.accountService.findOne(id);
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() account: Account,
  ): Account {
    return this.accountService.update(id, account);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number): void {
    this.accountService.remove(id);
  }
}