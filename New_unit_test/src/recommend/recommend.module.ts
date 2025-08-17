import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { RecommendController } from './recommend.controller';
import { RecommendService } from './recommend.service';
import { RecommendRepository } from './recommend.repository';
import { Account } from '../../entities/account.entity';
import { UserFile } from '../../entities/userfile.entity';
import { Folder } from '../../entities/folder.entity';
import { ActionRecent } from '../../entities/actionrecent.entity';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Module({
  controllers: [RecommendController],
  providers: [RecommendService, RecommendRepository],
  exports: [RecommendService],
})
export class RecommendModule {}
