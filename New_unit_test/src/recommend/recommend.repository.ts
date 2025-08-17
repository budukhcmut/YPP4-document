import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { ActionRecent } from '../../entities/actionrecent.entity';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Injectable()
export class RecommendRepository {
  constructor(
    @InjectRepository(ActionRecent)
    private readonly actionRecentRepository: Repository<ActionRecent>,
  ) {}

  async getRecommendedFiles(userId: number): Promise<RecommendFileDto[]> {
    const sql = `
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

    `;

    const result = await this.actionRecentRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      fileId: r.FileId,
      userName: r.UserName,
      userFileName: r.UserFileName,
      actionLog: r.ActionLog,
      actionDateTime: r.ActionDateTime,
    }));
  }

  async getRecommendedFolders(userId: number): Promise<RecommendFolderDto[]> {
    const sql = `
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
    `;

    const result = await this.actionRecentRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      folderId: r.FolderId,
      userName: r.UserName,
      folderName: r.FolderName,
      actionLog: r.ActionLog,
      actionDateTime: r.ActionDateTime,
    }));
  }
}
