import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ShareService } from './share.service';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';


@Controller('share')
export class ShareController {
  constructor(private readonly shareService: ShareService) {}

  async findSharedFiles(
    accountId: number,      
  ): Promise<SharedFileDto[]> {
    return await this.shareService.findSharedFiles(accountId);
  }

  async findSharedFolders(
    accountId: number,      
  ): Promise<SharedFolderDto[]> {
    return await this.shareService.findSharedFolders(accountId);
  }}

