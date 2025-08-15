import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ShareService } from './share.service';
import { SharedFileDto } from './dto/sharefile.dto';
import { SharedFolderDto } from './dto/sharefolder.dto';
import { SharedFileWithPermissionDto } from './dto/sharefilewithpermission.dto';
import { SharedFolderWithPermissionDto } from './dto/sharefolderwithpermission.dto';

@Controller('share')
export class ShareController {
  constructor(private readonly shareService: ShareService) {}

  @Get('files/:userId')
  async getSharedFiles(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<SharedFileDto[]> {
    return this.shareService.getSharedFiles(userId);
  }

  @Get('folders/:userId')
  async getSharedFolders(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<SharedFolderDto[]> {
    return this.shareService.getSharedFolders(userId);
  }

  @Get('files/with-permission/:userId')
  async getSharedFilesWithPermission(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<SharedFileDto[]> {
    return this.shareService.getSharedFilesWithPermission(userId);
  }

  @Get('folders/with-permission/:userId')
  async getSharedFoldersWithPermission(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<SharedFolderDto[]> {
    return this.shareService.getSharedFoldersWithPermission(userId);
  }
}
  
