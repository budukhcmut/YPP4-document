import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { BasicInfoDto } from './dto/account.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Account } from '../../entities/account.entity';
import { CacheService } from '../../utils/cache.service';

@Injectable()
export class AccountRepository {
  constructor(
  @InjectRepository(Account)
  private readonly accountRepository: Repository<Account> ,
  private readonly cacheService: CacheService,
){}

  async getBasicInfo(userId: number): Promise<BasicInfoDto| null> {
    const user: BasicInfoDto[] = await this.accountRepository.query(`
      SELECT UserName, Email 
      FROM Account a
      WHERE UserId = ?
      
      `, [userId]);
    
    return user.length > 0 ? user[0] : null;
    }
}
