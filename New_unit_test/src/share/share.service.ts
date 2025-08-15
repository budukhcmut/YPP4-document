import { Injectable } from '@nestjs/common';
import { ShareRepository } from './share.repository';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';

@Injectable()
export class ShareService {
  constructor(private readonly shareRepository: ShareRepository) {}

  async getSharedFiles(userId: number): Promise<SharedFileDto[]> {
    return this.shareRepository.getSharedFiles(userId);
  }

  async getSharedFolders(userId: number): Promise<SharedFolderDto[]> {
    return this.shareRepository.getSharedFolders(userId);
  }

  async getSharedFilesWithPermission(userId: number): Promise<SharedFileDto[]> {
    return this.shareRepository.getSharedFilesWithPermission(userId);
  }

  async getSharedFoldersWithPermission(userId: number): Promise<SharedFolderDto[]> {
    return this.shareRepository.getSharedFoldersWithPermission(userId);
  }
}
