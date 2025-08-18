import { Injectable } from '@nestjs/common';

import { FolderRepository } from './folder.repository';
import { MyFolderDto } from './dto/fullfolder.dto';

@Injectable()
export class FolderService {
  constructor(private readonly folderRepository: FolderRepository) {}

  async findMyFolders(userId: number): Promise<MyFolderDto[]> {
    return await this.folderRepository.findMyFolders(userId);
  }
}



