import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Folder } from '../../entities/folder.entity';
import { CacheService } from '../../common/utils/cache.service'; 
import { MyFolderDto } from './dto/fullfolder.dto';



@Injectable()
export class FolderRepository {
  constructor(
    @InjectRepository(Folder)
    private readonly folderRepository: Repository<Folder>,
    private readonly cacheService: CacheService,
  ) {}

  async findMyFolders(userId: number): Promise<MyFolderDto[]> {
    const cacheKey = `myFolders:${userId}`;
    const cachedFolders = await this.cacheService.get<MyFolderDto[]>(cacheKey);
    if (cachedFolders) {
      return cachedFolders;
    }
    await this.folderRepository.query('PRAGMA read_uncommited =1') ;
    const folders : MyFolderDto[] = await this.folderRepository.query(
     `
      SELECT 
        fo.FolderId,
        a.UserName,
        fo.FolderName
      FROM Folder fo
      JOIN Account a ON fo.OwnerId = a.UserId
      WHERE a.UserId = ?
    ` , 
    [userId]);

    this.cacheService.set( cacheKey , folders) ;
   return folders ;

    
  }    
}

