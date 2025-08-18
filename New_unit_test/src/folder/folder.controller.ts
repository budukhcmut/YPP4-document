import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { FolderService } from './folder.service';
import { MyFolderDto } from './dto/fullfolder.dto';


@Controller('folders')
export class FolderController {
  constructor(private readonly folderService: FolderService) {}

async findMyFolders( accountId: number): Promise<MyFolderDto[]> {
  return await this.folderService.findMyFolders(accountId);
} }

