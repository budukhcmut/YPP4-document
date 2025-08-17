import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountRepository } from './account.repository';
import { AccountService } from './account.service';
import { AccountController } from './account.controller';
import { Account } from '../../entities/account.entity';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([Account])],
  controllers: [AccountController],
  providers: [AccountRepository, AccountService , CacheService],
  exports: [AccountService],
})
export class AccountModule {}
