import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';


import { UserFile } from '../../entities/userfile.entity';
import { UserFileRepository } from './userfile.repository';
import { UserFileService } from './userfile.service';
import { UserFileController } from './userfile.controller';

@Module({
  imports: [TypeOrmModule.forFeature([UserFile])],
  providers: [UserFileRepository, UserFileService],
  controllers: [UserFileController],
  exports: [UserFileService],
})
export class UserFileModule {}
