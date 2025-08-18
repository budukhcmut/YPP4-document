import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';


import { FolderController } from './folder.controller';
import { FolderService } from './folder.service';
import { Folder } from '../../entities/folder.entity' ;
import { FolderRepository } from './folder.repository';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([Folder]),],
  controllers: [FolderController],
  providers: [FolderService, FolderRepository, CacheService],
})
export class FolderModule {}
