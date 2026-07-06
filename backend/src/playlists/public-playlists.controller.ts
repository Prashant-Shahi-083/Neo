import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { PlaylistsService } from './playlists.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DtoMapper } from '../shared/dto-mapper';

@Controller('api/v1/playlists')
export class PublicPlaylistsController {
  constructor(private readonly playlistsService: PlaylistsService) {}

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  async getPlaylist(@Param('id') id: string) {
    const playlist = await this.playlistsService.findOne(id);
    return DtoMapper.toPlaylist(playlist);
  }
}
