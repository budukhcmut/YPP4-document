import { Injectable } from '@nestjs/common';
import { FolderRepository, FolderDto } from './folder.repository';
import { MyFolderDto } from './dto/fullfolder.dto';

@Injectable()
export class FolderService {
  constructor(private readonly folderRepository: FolderRepository) {}

  async getMyFolders(userId: number): Promise<FolderDto[]> {
    return await this.folderRepository.getMyFolders(userId);
  }

  async getMyFoldersFull(userId: number): Promise<MyFolderDto[]> {
    return await this.folderRepository.getMyFoldersFull(userId);
  }   
}
