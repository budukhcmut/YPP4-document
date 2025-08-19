import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Trash } from '../../entities/trash.entity';
import { CacheService } from '../../utils/cache.service';
import { FileTrashDto } from './dto/filetrash.dto';
import { FolderTrashDto } from './dto/foldertrash.dto';

@Injectable()
export class TrashRepository {
  constructor(
    @InjectRepository(Trash)
    private readonly trashRepository: Repository<Trash>,
    private readonly cacheService: CacheService,
  ) {}

  async findTrashFiles(userId: number): Promise<FileTrashDto[]> {
    const cacheKey = `deletedFiles:${userId}`;
    const cachedFiles = await this.cacheService.get<FileTrashDto[]>(cacheKey);
    if (cachedFiles) {
      return cachedFiles;
    }

    await this.trashRepository.query('PRAGMA read_uncommitted = 1');

    const trashFiles: FileTrashDto[] = await this.trashRepository.query(
      `
      SELECT
        f.FileId,
        t.TrashId,
        ot.ObjectTypeName,
        f.UserFileName,
        t.RemovedDatetime,
        t.IsPermanent
      FROM Trash t
      JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
      JOIN UserFile f ON t.ObjectTypeId = 2 AND t.ObjectId = f.FileId
      WHERE t.UserId = ?
    `,
      [userId],
    );

   
    return trashFiles ;
  }

  async findTrashFolders(userId: number): Promise<FolderTrashDto[]> {
    const cacheKey = `deletedFolders:${userId}`;
    const cachedFolders = await this.cacheService.get<FolderTrashDto[]>(cacheKey);
    if (cachedFolders) {
      return cachedFolders;
    }

    await this.trashRepository.query('PRAGMA read_uncommitted = 1');

    const trashFolders: FolderTrashDto[] = await this.trashRepository.query(
      `
      SELECT 
        fo.FolderId,
        t.TrashId,
        ot.ObjectTypeName,
        fo.FolderName,
        t.RemovedDatetime,
        t.IsPermanent
      FROM Trash t
      JOIN ObjectType ot ON t.ObjectTypeId = ot.ObjectTypeId
      JOIN Folder fo ON t.ObjectTypeId = 1 AND t.ObjectId = fo.FolderId
      WHERE t.UserId = ?
    `,
      [userId],
    );

    return trashFolders ;
  }
}
