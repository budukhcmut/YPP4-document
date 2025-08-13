import { Injectable } from '@nestjs/common';
import { DataSource } from 'typeorm';
import { UserFileFullDto } from './dto/userfile.dto';

@Injectable()
export class UserFileRepository {
  constructor(private readonly dataSource: DataSource) {}

  async getFullById(fileId: number): Promise<UserFileFullDto[]> {
    const sql = `
      SELECT
        FileId,
        FolderId,
        OwnerId,
        Size,
        UserFileName,
        UserFilePath,
        UserFileThumbNailImg,
        FileTypeId,
        ModifiedDate,
        UserFileStatus,
        CreatedAt
      FROM UserFile
      WHERE FileId = ?
    `;
    return this.dataSource.query(sql, [fileId]) as Promise<UserFileFullDto[]>;
  }
}
