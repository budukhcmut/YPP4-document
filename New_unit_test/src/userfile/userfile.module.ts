import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';


import { UserFile } from '../../entities/userfile.entity';
import { UserFileRepository } from './userfile.repository';
import { UserFileService } from './userfile.service';
import { UserFileController } from './userfile.controller';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([UserFile])],
  providers: [UserFileRepository, UserFileService , CacheService],
  controllers: [UserFileController],
  exports: [UserFileService],
})
export class UserFileModule {}
