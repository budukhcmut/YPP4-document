import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { UserFileService } from './userfile.service';
import { UserFileQueryDto } from './dto/myuserfile.dto';
import { UserFileFullDto } from './dto/userfilefull.dto';


@Controller('user-files')
export class UserFileController {
  constructor(private readonly userFileService: UserFileService) {}

  @Get('basic/:userId')
  async getMyFiles(@Param('userId', ParseIntPipe) userId: number): Promise<UserFileQueryDto[]> {
    return this.userFileService.getMyFiles(userId);
  }

  @Get('full/:userId')
  async getMyFilesFull(@Param('userId', ParseIntPipe) userId: number): Promise<UserFileFullDto[]> {
    return this.userFileService.getMyFilesFull(userId);
  }
}
