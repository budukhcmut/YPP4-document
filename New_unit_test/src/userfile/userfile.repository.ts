import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';

import { UserFile } from '../../entities/userfile.entity';
import { UserFileFullDto } from './dto/userfilefull.dto';
import { Repository } from 'typeorm';
import { CacheService } from '../../common/utils/cache.service';


@Injectable()
export class UserFileRepository {
  constructor(
    @InjectRepository(UserFile)
    private readonly userFileRepository: Repository<UserFile>,
    private readonly cacheService: CacheService,
  ) {}


  async findMyFiles(userId: number): Promise<UserFileFullDto[]> {
    const cacheKey = `myFiles:${userId}`;
    const cachedFiles = await this.cacheService.get<UserFileFullDto[]>(cacheKey);
    if (cachedFiles) {
      return cachedFiles;
    }
    await this.userFileRepository.query('PRAGMA read_uncommited =1');
    const userFiles: UserFileFullDto[] = await this.userFileRepository.query(
      `
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
    `,
      [userId],
  );
      return userFiles;

  }
}
