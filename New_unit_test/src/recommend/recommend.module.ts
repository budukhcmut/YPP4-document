import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { RecommendController } from './recommend.controller';
import { RecommendService } from './recommend.service';
import { RecommendRepository } from './recommend.repository';
import { Account } from '../../entities/account.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ActionRecent } from '../../entities/actionrecent.entity';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports : 
    [TypeOrmModule.forFeature([Account, UserFile, Folder, ActionRecent])],
  controllers: [RecommendController],
  providers: [RecommendService, RecommendRepository , CacheService],
})
export class RecommendModule {}
