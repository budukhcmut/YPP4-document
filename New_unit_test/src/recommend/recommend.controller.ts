import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { RecommendService } from './recommend.service';
import { RecommendFileDto } from './dto/recommendfile.dto';
import { RecommendFolderDto } from './dto/recmmendfolder.dto';

@Controller('recommend')
export class RecommendController {
  constructor(private readonly recommendService: RecommendService) {}

  @Get('files/:userId')
  async getFileRecommendations(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<RecommendFileDto[]> {
    return this.recommendService.getFileRecommendations(userId);
  }

  @Get('folders/:userId')
  async getFolderRecommendations(
    @Param('userId', ParseIntPipe) userId: number,
  ): Promise<RecommendFolderDto[]> {
    return this.recommendService.getFolderRecommendations(userId);
  }
}
