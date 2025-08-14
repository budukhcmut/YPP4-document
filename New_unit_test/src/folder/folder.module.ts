import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';


import { FolderController } from './folder.controller';
import { FolderService } from './folder.service';
import { Folder } from '../../entities/folder.entity' ;
import { FolderRepository } from './folder.repository';

@Module({
  imports: [
    TypeOrmModule.forFeature([Folder]),
  ],
  controllers: [FolderController],
  providers: [FolderService, FolderRepository],
})
export class FolderModule {}
