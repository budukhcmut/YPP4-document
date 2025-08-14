import { Injectable } from '@nestjs/common';
import { UserFileRepository } from './userfile.repository';
import { UserFileQueryDto } from './dto/myuserfile.dto';
import { UserFileFullDto } from './dto/userfilefull.dto';


@Injectable()
export class UserFileService {
  constructor(private readonly userFileRepository: UserFileRepository) {}

  async getMyFiles(userId: number): Promise<UserFileQueryDto[]> {
    return this.userFileRepository.getMyFiles(userId);
  }

  async getMyFilesFull(userId: number): Promise<UserFileFullDto[]> {
    return this.userFileRepository.getMyFilesFull(userId);
  }
}
