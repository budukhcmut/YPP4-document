import { Injectable } from '@nestjs/common';
import { UserFileRepository } from './userfile.repository';
import { UserFileFullDto } from './dto/userfile.dto';

@Injectable()
export class UserFileService {
  constructor(private readonly repo: UserFileRepository) {}

  async getFullById(fileId: number): Promise<UserFileFullDto[]> {
    return this.repo.getFullById(fileId);
  }
}
