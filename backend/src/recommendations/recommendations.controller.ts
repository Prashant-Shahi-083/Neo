import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import {
  Controller,
  UseGuards as ExistingUseGuards,
  Get,
  Put,
  Body,
  Param,
  Query,
} from '@nestjs/common';
import { RecommendationsService } from './recommendations.service';
import { RecommendationConfig } from '../entities/recommendation-config.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/recommendations')
export class RecommendationsController {
  constructor(private readonly recsService: RecommendationsService) {}

  @Get('config')
  getConfig() {
    return this.recsService.getConfig();
  }

  @Put('config')
  updateConfig(@Body() dto: Partial<RecommendationConfig>) {
    return this.recsService.updateConfig(dto);
  }

  @Get('similar-songs/:id')
  getSimilarSongs(
    @Param('id') id: string,
    @Query('limit') limit: string = '10',
  ) {
    return this.recsService.getSimilarSongs(id, +limit);
  }

  @Get('trending')
  getTrendingSongs(@Query('limit') limit: string = '10') {
    return this.recsService.getTrendingSongs(+limit);
  }
}
