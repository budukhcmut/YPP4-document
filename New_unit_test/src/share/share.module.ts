import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ShareService } from './share.service';
import { ShareController } from './share.controller';
import { Share } from '../../entities/share.entity';
import { ShareRepository } from './share.repository';
import { Account } from '../../entities/account.entity';
import { SharedUser } from '../../entities/shareduser.entity';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([Share , SharedUser , Account])],
  providers: [ShareService, ShareRepository , CacheService],
  controllers: [ShareController],
})
export class ShareModule {}

