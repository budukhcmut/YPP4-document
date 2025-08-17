import { Injectable } from '@nestjs/common';
import { RecommendRepository } from './recommend.repository';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Injectable()
export class RecommendService {
  constructor(private readonly recommendRepository: RecommendRepository) {}

  async getFileRecommendations(userId: number): Promise<RecommendFileDto[]> {
    return this.recommendRepository.getRecommendedFiles(userId);
  }

  async getFolderRecommendations(userId: number): Promise<RecommendFolderDto[]> {
    return this.recommendRepository.getRecommendedFolders(userId);
  }
}
