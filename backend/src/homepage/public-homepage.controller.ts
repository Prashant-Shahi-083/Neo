import { Controller, Get, UseGuards, Query } from '@nestjs/common';
import { HomepageService } from './homepage.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/v1/homepage')
export class PublicHomepageController {
  constructor(private readonly homepageService: HomepageService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  getHomepage(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.homepageService.getPublicFeed(
      Number(page) || 1,
      Number(limit) || 10,
    );
  }
}
