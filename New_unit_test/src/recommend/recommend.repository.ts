import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { ActionRecent } from '../../entities/actionrecent.entity';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';
import { CacheService } from '../../common/utils/cache.service';

@Injectable()
export class RecommendRepository {
  constructor(
    @InjectRepository(ActionRecent)
    private readonly actionRecentRepository: Repository<ActionRecent>,
    private readonly cacheService: CacheService,
  ) {}

  async findRecommendedFiles(userId: number): Promise<RecommendFileDto[]> {
    const cacheKey = `recommendedFiles:${userId}`;
    const cachedFiles = await this.cacheService.get<RecommendFileDto[]>(cacheKey);
    if (cachedFiles) {
      return cachedFiles;
    }
  await this.actionRecentRepository.query('PRAGMA read_uncommited =1');
  const sharedFiles: RecommendFileDto[] = await this.actionRecentRepository.query(
    `

      SELECT 
        f.FileId,
        a.UserName,
        f.UserFileName,
        ar.ActionLog,
        ar.ActionDateTime
      FROM ActionRecent ar 
      JOIN Account a ON ar.UserId = a.UserId
      JOIN UserFile f ON ar.ObjectTypeId = 2 AND ar.ObjectId = f.FileId
      WHERE ar.UserId = ?
      ORDER BY ar.ActionDateTime DESC
      LIMIT 10

    `,
    [userId],
  );
    return sharedFiles ;
}
    


  async findRecommendedFolders(userId: number): Promise<RecommendFolderDto[]> {
    const cacheKey = `recommendedFolders:${userId}`;
    const cachedFolders = await this.cacheService.get<RecommendFolderDto[]>(cacheKey);
    if (cachedFolders) {
      return cachedFolders;
    }
    await this.actionRecentRepository.query('PRAGMA read_uncommited =1');
    // Assuming the SQL query is similar to the one for recommended files
   const sharedFolders: RecommendFolderDto[] = await this.actionRecentRepository.query(
     `
      SELECT 
        fo.FolderId,
        a.UserName,
        fo.FolderName,
        ar.ActionLog,
        ar.ActionDateTime
      FROM ActionRecent ar
      JOIN Account a ON ar.UserId = a.UserId
      JOIN Folder fo ON ar.ObjectTypeId = 1 AND ar.ObjectId = fo.FolderId
      WHERE ar.UserId = ?
      ORDER BY ar.ActionDateTime DESC
      LIMIT 10
    `,
    [userId],
  );
 return sharedFolders;
   
  }
}
