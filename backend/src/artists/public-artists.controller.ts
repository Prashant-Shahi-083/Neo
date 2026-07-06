import { Controller, Get, Param, UseGuards, Query } from '@nestjs/common';
import { ArtistsService } from './artists.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DtoMapper } from '../shared/dto-mapper';

@Controller('api/v1/artists')
export class PublicArtistsController {
  constructor(private readonly artistsService: ArtistsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  async getArtists(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '20',
    @Query('search') search: string = '',
  ) {
    const result = await this.artistsService.findAll(+page, +limit, search);
    return {
      ...result,
      data: result.data.map((artist) => DtoMapper.toArtist(artist)),
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  async getArtist(@Param('id') id: string) {
    const artist = await this.artistsService.findOne(id);
    return DtoMapper.toArtist(artist);
  }
}
