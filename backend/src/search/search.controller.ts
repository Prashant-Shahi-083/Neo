import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import {
  Controller,
  UseGuards as ExistingUseGuards,
  Get,
  Query,
} from '@nestjs/common';
import { SearchService } from './search.service';

@Controller('api/v1')
export class SearchController {
  constructor(private readonly searchService: SearchService) {}

  // Public Endpoint for the App
  @UseGuards(JwtAuthGuard)
  @Get('search')
  search(
    @Query('q') q: string,
    @Query('type') type?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    return this.searchService.searchAll(
      q || '',
      type,
      Number(page) || 1,
      Number(limit) || 20,
    );
  }

  // Temporary Library Endpoint for Flutter App integration
  @UseGuards(JwtAuthGuard)
  @Get('library')
  getLibrary() {
    return this.searchService.getLibrary();
  }

  // Admin Endpoints
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Get('admin/search/analytics/top')
  getTopSearches(@Query('limit') limit: string = '20') {
    return this.searchService.getTopSearches(+limit);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Get('admin/search/analytics/zero-results')
  getZeroResultSearches(@Query('limit') limit: string = '20') {
    return this.searchService.getZeroResultSearches(+limit);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Get('admin/search/analytics/recent')
  getRecentSearches(@Query('limit') limit: string = '20') {
    return this.searchService.getRecentSearches(+limit);
  }
}
