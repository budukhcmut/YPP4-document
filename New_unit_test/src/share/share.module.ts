import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ShareService } from './share.service';
import { ShareController } from './share.controller';
import { Share } from '../../entities/share.entity';
import { ShareRepository } from './share.repository';

@Module({
  imports: [TypeOrmModule.forFeature([Share])],
  providers: [ShareService, ShareRepository],
  controllers: [ShareController],
})
export class ShareModule {}

import { SharedFileWithPermissionDto } from './dto/sharefilewithpermission.dto';
import { SharedFolderWithPermissionDto } from './dto/sharefolderwithpermission.dto';