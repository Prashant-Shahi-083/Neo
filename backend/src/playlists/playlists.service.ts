import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Playlist } from '../entities/playlist.entity';
import { PlaylistSong } from '../entities/playlist-song.entity';
import { Song } from '../entities/song.entity';
import { CreatePlaylistDto } from './dto/create-playlist.dto';
import {
  UpdatePlaylistDto,
  AddSongDto,
  ReorderSongsDto,
} from './dto/update-playlist.dto';

@Injectable()
export class PlaylistsService {
  constructor(
    @InjectRepository(Playlist) private playlistRepo: Repository<Playlist>,
    @InjectRepository(PlaylistSong)
    private playlistSongRepo: Repository<PlaylistSong>,
    @InjectRepository(Song) private songRepo: Repository<Song>,
  ) {}

  async findAll(page: number = 1, limit: number = 10, search: string = '') {
    const [data, total] = await this.playlistRepo.findAndCount({
      where: search ? { title: Like(`%${search}%`) } : {},
      take: limit,
      skip: (page - 1) * limit,
      order: { createdAt: 'DESC' },
    });
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const playlist = await this.playlistRepo.findOne({
      where: { id },
      relations: { playlistSongs: { song: true } },
    });
    if (!playlist) throw new NotFoundException('Playlist not found');

    // Sort songs by position
    if (playlist.playlistSongs) {
      playlist.playlistSongs.sort((a, b) => a.position - b.position);
    }

    return playlist;
  }

  async create(dto: CreatePlaylistDto, adminUsername: string) {
    const playlist = this.playlistRepo.create({ ...dto, adminUsername });
    return this.playlistRepo.save(playlist);
  }

  async update(id: string, dto: UpdatePlaylistDto) {
    const playlist = await this.findOne(id);
    Object.assign(playlist, dto);
    return this.playlistRepo.save(playlist);
  }

  async remove(id: string) {
    const playlist = await this.findOne(id);
    await this.playlistRepo.softRemove(playlist);
    return { success: true };
  }

  // --- Song Management inside Playlist ---

  async addSong(playlistId: string, dto: AddSongDto) {
    const playlist = await this.findOne(playlistId);
    const song = await this.songRepo.findOne({ where: { id: dto.songId } });
    if (!song) throw new NotFoundException('Song not found');

    const count = playlist.playlistSongs?.length || 0;

    const ps = this.playlistSongRepo.create({
      playlist,
      song,
      position: count,
    });

    await this.playlistSongRepo.save(ps);
    // update stats cache
    playlist.statistics.plays = playlist.statistics.plays || 0; // Just touching it for updateDate
    await this.playlistRepo.save(playlist);

    return ps;
  }

  async removeSong(playlistId: string, playlistSongId: string) {
    const ps = await this.playlistSongRepo.findOne({
      where: { id: playlistSongId, playlist: { id: playlistId } },
    });
    if (!ps) throw new NotFoundException('PlaylistSong not found');
    await this.playlistSongRepo.remove(ps);
    return { success: true };
  }

  async reorderSongs(playlistId: string, dto: ReorderSongsDto) {
    const playlist = await this.findOne(playlistId);

    // orderedSongIds is an array of PlaylistSong IDs in the exact new order
    const updates = dto.orderedSongIds.map((psId, index) => {
      return this.playlistSongRepo.update(
        { id: psId, playlist: { id: playlistId } },
        { position: index },
      );
    });

    await Promise.all(updates);
    return this.findOne(playlistId); // Return sorted
  }
}
