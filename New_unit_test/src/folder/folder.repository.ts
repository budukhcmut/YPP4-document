import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Folder } from '../../entities/folder.entity';
import { MyFolderDto } from './dto/fullfolder.dto';
import { MyFolderQueryDto } from './dto/myfolder.dto';


export interface FolderDto {
  FolderId: number;
  UserName: string;
  FolderName: string;
}

@Injectable()
export class FolderRepository {
  constructor(
    @InjectRepository(Folder)
    private readonly folderRepository: Repository<Folder>,
  ) {}

  async getMyFolders(userId: number): Promise<FolderDto[]> {
    const sql = `
      SELECT 
        fo.FolderId,
        a.UserName,
        fo.FolderName
      FROM Folder fo
      JOIN Account a ON fo.OwnerId = a.UserId
      WHERE a.UserId = ?
    `;
    const result = await this.folderRepository.query(sql, [userId]);
    return result as FolderDto[];}

    async getMyFoldersFull(userId: number): Promise<MyFolderDto[]> {  
    const sql = `
      SELECT 
        fo.FolderId,
        fo.OwnerId,
        fo.FolderName,
        fo.FolderPath,
        fo.CreatedAt,
        a.UserName
      FROM Folder fo
      JOIN Account a ON fo.OwnerId = a.UserId
      WHERE a.UserId = ?
    `;    
    const result = await this.folderRepository.query(sql, [userId]);
    return result as MyFolderDto[]; 
}
    
}

