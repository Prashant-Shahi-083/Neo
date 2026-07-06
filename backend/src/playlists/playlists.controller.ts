import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import {
  Controller,
  UseGuards as ExistingUseGuards,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  Request,
} from '@nestjs/common';
import { PlaylistsService } from './playlists.service';
import { CreatePlaylistDto } from './dto/create-playlist.dto';
import {
  UpdatePlaylistDto,
  AddSongDto,
  ReorderSongsDto,
} from './dto/update-playlist.dto';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/playlists')
export class PlaylistsController {
  constructor(private readonly playlistsService: PlaylistsService) {}

  @Get()
  findAll(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('search') search: string = '',
  ) {
    return this.playlistsService.findAll(+page, +limit, search);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.playlistsService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreatePlaylistDto, @Request() req) {
    return this.playlistsService.create(
      dto,
      req.user?.username || 'System Admin',
    );
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdatePlaylistDto) {
    return this.playlistsService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.playlistsService.remove(id);
  }

  @Post(':id/songs')
  addSong(@Param('id') id: string, @Body() dto: AddSongDto) {
    return this.playlistsService.addSong(id, dto);
  }

  @Delete(':id/songs/:psId')
  removeSong(@Param('id') id: string, @Param('psId') psId: string) {
    return this.playlistsService.removeSong(id, psId);
  }

  @Put(':id/songs/reorder')
  reorderSongs(@Param('id') id: string, @Body() dto: ReorderSongsDto) {
    return this.playlistsService.reorderSongs(id, dto);
  }
}
