import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { Share } from '../../entities/share.entity';
import { SharedFileDto } from './dto/sharefile.dto';    
import { SharedFolderDto } from './dto/sharefolder.dto';
import { SharedFileWithPermissionDto } from './dto/sharefilewithpermission.dto';        
import { SharedFolderWithPermissionDto } from './dto/sharefolderwithpermission.dto';  


export interface ShareDto {
  ShareId: number;      
    UserName: string;
}
@Injectable()
export class ShareRepository {          
    constructor(
        @InjectRepository(Share)
        private readonly shareRepository: Repository<Share>,
    ) {}
    
    async getSharedFiles(userId: number): Promise<SharedFileDto[]> {
        const sql = `
        DECLARE @userId INT = 102
SELECT
	f.FileId,
	a.UserName,
	f.UserFileName
FROM SharedUser su
JOIN Account a ON su.UserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN UserFile f ON s.ObjectTypeId = 2 AND s.ObjectId = f.FileId
WHERE su.UserId = @userId
        `;
        const result = await this.shareRepository.query(sql, [userId]);
        return result as SharedFileDto[];
    }
    
    async getSharedFolders(userId: number): Promise<SharedFolderDto[]> {
        const sql = `
      DECLARE @userId INT = 101
SELECT
	fo.FolderId,
	a.UserName,
	fo.FolderName
FROM SharedUser su
JOIN Account a ON su.UserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Folder fo ON s.ObjectTypeId = 1 AND s.ObjectId = fo.FolderId
WHERE su.UserId = @userId

        `;
        const result = await this.shareRepository.query(sql, [userId]);
        return result as SharedFolderDto[];
    }
    
    async getSharedFilesWithPermission(userId: number): Promise<SharedFileWithPermissionDto[]> {
        const sql = `
DECLARE @userId INT = 101
SELECT 
	a.UserName,
	fo.FolderId,
	p.PermissionName,
	fo.FolderName
FROM SharedUser su
JOIN Account a ON su.SharedUserId = a.UserId
JOIN Share s ON su.ShareId = s.ShareId
JOIN Permission p ON su.PermissionId = p.PermissionId
LEFT JOIN Folder fo ON s.ObjectTypeId = 1 AND fo.FolderId = s.ObjectId
WHERE su.UserId = @userId
        `;
        const result = await this.shareRepository.query(sql, [userId]);
        return result as SharedFileWithPermissionDto[];
    }
    
    async getSharedFoldersWithPermission(userId: number): Promise<SharedFolderWithPermissionDto[]> {
        const sql = `   
        DECLARE @userId INT = 102
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
WHERE su.UserId = @userId
        `;
        const result = await this.shareRepository.query(sql, [userId]);
        return result as SharedFolderWithPermissionDto[];
    }
    }    
