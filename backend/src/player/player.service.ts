import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Song, SongStatus } from '../entities/song.entity';

@Injectable()
export class PlayerService {
  constructor(
    @InjectRepository(Song)
    private readonly songRepository: Repository<Song>,
  ) {}

  async getPlaybackMetadata(songId: string) {
    const song = await this.songRepository.findOne({
      where: { id: songId, status: SongStatus.PUBLISHED },
      relations: { artists: true, album: true },
    });

    if (!song) {
      throw new NotFoundException(`Song with ID ${songId} not found or not available`);
    }

    return {
      track: {
        id: song.id,
        title: song.title,
        durationMs: song.durationMs,
        bitrate: song.bitrate,
        isrc: song.isrc,
      },
      streamUrl: song.audioUrl,
      duration: song.durationMs ? Math.floor(song.durationMs / 1000) : 0,
      artwork: song.coverUrl,
      artist: song.artists && song.artists.length > 0 ? song.artists[0] : null,
      album: song.album || null,
    };
  }
}
