import { Controller, Get, Param, UseGuards, Query } from '@nestjs/common';
import { AlbumsService } from './albums.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DtoMapper } from '../shared/dto-mapper';

@Controller('api/v1/albums')
export class PublicAlbumsController {
  constructor(private readonly albumsService: AlbumsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  async getAlbums(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '20',
    @Query('search') search: string = '',
  ) {
    const result = await this.albumsService.findAll(+page, +limit, search);
    return {
      ...result,
      data: result.data.map((album) => DtoMapper.toAlbum(album)),
    };
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  async getAlbum(@Param('id') id: string) {
    const album = await this.albumsService.findOne(id);
    const dto = DtoMapper.toAlbum(album);
    return dto;
  }
}
