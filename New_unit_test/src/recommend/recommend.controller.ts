import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { RecommendService } from './recommend.service';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Controller('recommend')
export class RecommendController {
  constructor(private readonly recommendService: RecommendService) {}

  async findRecommendedFiles(
    accountId: number,
  ): Promise<RecommendFileDto[]> {
    return await this.recommendService.findRecommendFiles(accountId);
  }

  async findRecommendedFolders(
    accountId: number,
  ): Promise<RecommendFolderDto[]> {
    return await this.recommendService.findRecommendedFolders(accountId);
  }
}