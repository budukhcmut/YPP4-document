import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Share } from '../../entities/share.entity';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';
import { SharedFileWithPermissionDto } from './dto/sharefilewithpermission.dto';
import { SharedFolderWithPermissionDto } from './dto/sharefolderwithpermission.dto';

@Injectable()
export class ShareRepository {
  constructor(
    @InjectRepository(Share)
    private readonly shareRepository: Repository<Share>,
  ) {}

  async getSharedFiles(userId: number): Promise<SharedFileDto[]> {
    const sql = `
      SELECT
        f.FileId,
        a.UserName,
        f.UserFileName
      FROM SharedUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN UserFile f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
      WHERE su.UserId = ?
    `;
    const result = await this.shareRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      fileId: r.FileId,
      userName: r.UserName,
      userFileName: r.UserFileName,
    }));
  }

  async getSharedFolders(userId: number): Promise<SharedFolderDto[]> {
    const sql = `
      SELECT
        fo.FolderId,
        a.UserName,
        fo.FolderName
      FROM SharedUser su
      JOIN Account a ON su.UserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
      WHERE su.UserId = ?
    `;
    const result = await this.shareRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      folderId: r.FolderId,
      userName: r.UserName,
      folderName: r.FolderName,
    }));
  }

  async getSharedFilesWithPermission(
    userId: number,
  ): Promise<SharedFileWithPermissionDto[]> {
    const sql = `
      SELECT 
        a.UserName,
        p.PermissionName,
        f.FileId,
        f.UserFileName
      FROM SharedUser su
      JOIN Account a ON su.SharedUserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN Permission p ON su.PermissionId = p.PermissionId
      LEFT JOIN UserFile f ON s.ObjectTypeId = 2 AND f.FileId = s.ObjectId
      WHERE su.UserId = ?
    `;
    const result = await this.shareRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      fileId: r.FileId,
      userName: r.UserName,
      userFileName: r.UserFileName,
      permissionName: r.PermissionName,
    }));
  }

  async getSharedFoldersWithPermission(
    userId: number,
  ): Promise<SharedFolderWithPermissionDto[]> {
    const sql = `
      SELECT 
        a.UserName,
        p.PermissionName,
        fo.FolderId,
        fo.FolderName
      FROM SharedUser su
      JOIN Account a ON su.SharedUserId = a.UserId
      JOIN Share s ON su.ShareId = s.ShareId
      JOIN Permission p ON su.PermissionId = p.PermissionId
      LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND fo.FolderId = s.ObjectId
      WHERE su.UserId = ?
    `;
    const result = await this.shareRepository.query(sql, [userId]);

    return result.map((r: any) => ({
      folderId: r.FolderId,
      userName: r.UserName,
      folderName: r.FolderName,
      permissionName: r.PermissionName,
    }));
  }
}
