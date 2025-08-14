import { Injectable } from '@nestjs/common';
import { AccountRepository } from './account.repository';
import { BasicInfoDto } from './dto/account.dto';

@Injectable()
export class AccountService {
  constructor(private readonly accountRepo: AccountRepository) {}

  async getBasicInfo(userId: number): Promise<BasicInfoDto| null> {
    return await this.accountRepo.getBasicInfo(userId);
  }
  
}
