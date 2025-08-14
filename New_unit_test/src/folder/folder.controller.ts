import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { FolderService } from './folder.service';
import { FolderDto } from './folder.repository';


@Controller('folders')
export class FolderController {
  constructor(private readonly folderService: FolderService) {}

  @Get('my/:userId')
  async getMyFolders(
    @Param('userId', ParseIntPipe) userId: number
  ): Promise<FolderDto[]> {
    return this.folderService.getMyFolders(userId);
  }
  @Get('full/:userId')
  async getMyFoldersFull(
    @Param('userId', ParseIntPipe) userId: number
  ): Promise<FolderDto[]> {
    return this.folderService.getMyFoldersFull(userId 
  )
}
}

