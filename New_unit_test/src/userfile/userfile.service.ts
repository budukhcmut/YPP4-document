import { Injectable } from '@nestjs/common';

import { UserFileRepository } from './userfile.repository';
import { UserFileFullDto } from './dto/userfilefull.dto';


@Injectable()
export class UserFileService {
  constructor(private readonly userFileRepository: UserFileRepository) {}

  async findMyFiles(userId: number): Promise<UserFileFullDto[]> {
    return this.userFileRepository.findMyFiles(userId);
  }
}
