import { Injectable } from '@nestjs/common';
import { RecommendRepository } from './recommend.repository';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Injectable()
export class RecommendService {
  constructor(private readonly recommendRepository: RecommendRepository) {}

  async findRecommendFiles(userId: number): Promise<RecommendFileDto[]> {
    return this.recommendRepository.findRecommendedFiles(userId);
  }

  async findRecommendedFolders (userId: number): Promise<RecommendFolderDto[]> {
    return this.recommendRepository.findRecommendedFolders(userId);
  }
}
