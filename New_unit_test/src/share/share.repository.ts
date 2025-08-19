import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Share } from '../../entities/share.entity';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';
import { CacheService } from '../../common/utils/cache.service';


@Injectable()
export class ShareRepository {
  constructor(
    @InjectRepository(Share)
    private readonly shareRepository: Repository<Share>,
    private readonly cacheService: CacheService,
  ) {}

  async findSharedFiles(userId: number): Promise<SharedFileDto[]> {
    const cacheKey = `sharedFiles:${userId}`;
    const cachedFiles = await this.cacheService.get<SharedFileDto[]>(cacheKey);
    if (cachedFiles) {
      return cachedFiles;
    }
    await this.shareRepository.query('PRAGMA read_uncommited =1');
    const sharedFiles: SharedFileDto[] = await this.shareRepository.query(
    
     `
      SELECT
        f.FileId,
        a.UserName,
        f.UserFileName
      FROM SharedUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN UserFile f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
      WHERE su.UserId = ?
    `,
    [userId],
    );
    return sharedFiles;
  }

  async findSharedFolders(userId: number): Promise<SharedFolderDto[]> {
    
    const cacheKey = `sharedFolders:${userId}`;
    const cachedFolders = await this.cacheService.get<SharedFolderDto[]>(cacheKey);
    if (cachedFolders) {
      return cachedFolders;
    }
    await this.shareRepository.query('PRAGMA read_uncommited =1');
    // Assuming the SQL query is similar to the one for shared files
      const sharedFolders: SharedFolderDto[] = await this.shareRepository.query(

     `
      SELECT
        fo.FolderId,
        a.UserName,
        fo.FolderName
      FROM SharedUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
      WHERE su.UserId = ?
    `,
    [userId],
    );
    return sharedFolders;



  

  }
}
