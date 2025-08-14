import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';

import { UserFile } from '../../entities/userfile.entity';
import { UserFileQueryDto } from './dto/myuserfile.dto';
import { UserFileFullDto } from './dto/userfilefull.dto';
import { Repository } from 'typeorm';

@Injectable()
export class UserFileRepository {
  
  constructor(
    @InjectRepository(UserFile)
    private readonly userFileRepository: Repository<UserFile>,
  ) {}

  async getMyFiles(userId: number): Promise<UserFileQueryDto[]> {
    const sql = `
      SELECT 
        uf.FileId,
        a.UserName,
        uf.UserFileName
      FROM UserFile uf
      JOIN Account a ON uf.OwnerId = a.UserId
      WHERE a.UserId = ?
    `;
    const result = await this.userFileRepository.query(sql, [userId]);
    return result as UserFileQueryDto[];
  }

  async getMyFilesFull(userId: number): Promise<UserFileFullDto[]> {
    const sql = `
      SELECT 
        uf.FileId,
        uf.FolderId,
        uf.OwnerId,
        uf.Size,
        uf.UserFileName,
        uf.UserFilePath,
        uf.UserFileThumbNailImg,
        uf.FileTypeId,
        uf.ModifiedDate,
        uf.UserFileStatus,
        uf.CreatedAt,
        a.UserName
      FROM UserFile uf
      JOIN Account a ON uf.OwnerId = a.UserId
      WHERE a.UserId = ?
    `;
    const result = await this.userFileRepository.query(sql, [userId]);
      return result as UserFileFullDto[];
  }
}
