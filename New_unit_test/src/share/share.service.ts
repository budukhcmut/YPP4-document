import { Injectable } from '@nestjs/common';
import { ShareRepository } from './share.repository';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';


@Injectable()
export class ShareService {
  constructor(private readonly shareRepository: ShareRepository) {}

  async findSharedFiles(userId: number): Promise<SharedFileDto[]> {
    return this.shareRepository.findSharedFiles(userId);
  }

  async findSharedFolders(userId: number): Promise<SharedFolderDto[]> {
    return this.shareRepository.findSharedFolders(userId);
  }

}
