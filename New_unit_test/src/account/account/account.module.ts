import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountRepository } from './account.repository';
import { AccountService } from './account.service';
import { AccountController } from './account.controller';
import { Account } from 'src/account/account/entities/account.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Account])],
  controllers: [AccountController],
  providers: [AccountRepository, AccountService],
  exports: [AccountService],
})
export class AccountModule {}
