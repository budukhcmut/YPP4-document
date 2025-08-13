import { Injectable } from '@nestjs/common';
import { AccountRepository } from './account.repository';

@Injectable()
export class AccountService {
  constructor(private readonly accountRepo: AccountRepository) {}

  async getBasicInfo(userId: number) {
    return this.accountRepo.findBasicInfoByUserId(userId);
  }
  
}
