import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { UserFileService } from './userfile.service';
import { UserFileFullDto } from './dto/userfilefull.dto';


@Controller('user-files')
export class UserFileController {
  constructor(private readonly userFileService: UserFileService) {}

  async findMyFiles( accountId: number): Promise<UserFileFullDto[]> {
    return await this.userFileService.findMyFiles(accountId);
  }}
