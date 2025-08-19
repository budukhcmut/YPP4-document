import { Injectable } from '@nestjs/common';
import { DataSource, Repository } from 'typeorm';
import { BasicInfoDto } from './dto/account.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Account } from '../../entities/account.entity';
import { CacheService } from '../../common/utils/cache.service';

@Injectable()
export class AccountRepository {
  constructor(
  @InjectRepository(Account)
  private readonly accountRepository: Repository<Account> ,
  private readonly cacheService: CacheService,
){}

  async findBasicInfo(userId: number): Promise<BasicInfoDto |null> {
    const cacheKey = `basicInfo:${userId}`;
    const cachedUser = await this.cacheService.get<BasicInfoDto>(cacheKey);
    if (cachedUser) {
      return cachedUser;
    }
    await this.accountRepository.query('PRAGMA read_uncommited =1') ;


    const user: BasicInfoDto|null = await this.accountRepository.query(`
      
      SELECT UserName, Email 
      FROM Account a
      WHERE UserId = ?
      
      `, [userId]);
    
      this.cacheService.set(cacheKey, user); 

    return user ;
    }

}
