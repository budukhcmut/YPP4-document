import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { UserFileService } from './userfile.service';
import { UserFileFullDto } from './dto/userfile.dto';

@Controller('userfile')
export class UserFileController {
  constructor(private readonly service: UserFileService) {}

  @Get(':id/full')
  getFull(@Param('id', ParseIntPipe) id: number): Promise<UserFileFullDto[]> {
    return this.service.getFullById(id);
  }
}
