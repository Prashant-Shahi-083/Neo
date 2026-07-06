import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, In } from 'typeorm';
import { Song, SongStatus } from '../entities/song.entity';
import { Album } from '../entities/album.entity';
import { Artist } from '../entities/artist.entity';
import { Genre } from '../entities/genre.entity';
import { CreateSongDto } from './dto/create-song.dto';
import { UpdateSongDto } from './dto/update-song.dto';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
const ffmpeg = require('fluent-ffmpeg');
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class SongsService {
  private readonly logger = new Logger(SongsService.name);

  constructor(
    @InjectRepository(Song) private songRepo: Repository<Song>,
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
    @InjectRepository(Genre) private genreRepo: Repository<Genre>,
    private auditLogsService: AuditLogsService,
  ) {}

  async findAll(page: number = 1, limit: number = 10, search: string = '') {
    const [data, total] = await this.songRepo.findAndCount({
      where: search ? { title: Like(`%${search}%`) } : {},
      relations: { album: true, genre: true, artists: true },
      take: limit,
      skip: (page - 1) * limit,
      order: { createdAt: 'DESC' },
    });
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const song = await this.songRepo.findOne({
      where: { id },
      relations: { album: true, genre: true, artists: true },
    });
    if (!song) throw new NotFoundException('Song not found');
    return song;
  }

  async getMetadataForm() {
    const albums = await this.albumRepo.find({
      select: { id: true, title: true },
      order: { title: 'ASC' },
    });
    const artists = await this.artistRepo.find({
      select: { id: true, name: true },
      order: { name: 'ASC' },
    });
    const genres = await this.genreRepo.find({
      select: { id: true, name: true },
      order: { name: 'ASC' },
    });
    return { albums, artists, genres };
  }

  async create(dto: CreateSongDto, adminUsername: string) {
    let album: Album | null = null;
    let genre: Genre | null = null;
    let artists: Artist[] = [];
    if (dto.albumId)
      album = await this.albumRepo.findOne({ where: { id: dto.albumId } });
    if (dto.genreId)
      genre = await this.genreRepo.findOne({ where: { id: dto.genreId } });
    if (dto.artistIds && dto.artistIds.length > 0) {
      artists = await this.artistRepo.find({
        where: { id: In(dto.artistIds) },
      });
    }

    const song = new Song();
    Object.assign(song, dto);
    song.album = album as any;
    song.genre = genre as any;
    song.artists = artists;

    const saved = await this.songRepo.save(song);
    await this.auditLogsService.logAction(
      'CREATE',
      'Song',
      saved.id,
      adminUsername,
      dto,
    );
    return saved;
  }

  async update(id: string, dto: UpdateSongDto, adminUsername: string) {
    const song = await this.findOne(id);

    if (dto.albumId !== undefined) {
      song.album = dto.albumId
        ? ((await this.albumRepo.findOne({
            where: { id: dto.albumId },
          })) as any)
        : null;
    }
    if (dto.genreId !== undefined) {
      song.genre = dto.genreId
        ? ((await this.genreRepo.findOne({
            where: { id: dto.genreId },
          })) as any)
        : null;
    }
    if (dto.artistIds) {
      song.artists = await this.artistRepo.find({
        where: { id: In(dto.artistIds) },
      });
    }

    Object.assign(song, dto);

    const updated = await this.songRepo.save(song);
    await this.auditLogsService.logAction(
      'UPDATE',
      'Song',
      id,
      adminUsername,
      dto,
    );
    return updated;
  }

  async remove(id: string, adminUsername: string) {
    const song = await this.findOne(id);
    await this.songRepo.softRemove(song);
    await this.auditLogsService.logAction('DELETE', 'Song', id, adminUsername);
    return { message: 'Song deleted successfully' };
  }

  async uploadCover(id: string, fileUrl: string, adminUsername: string) {
    const song = await this.findOne(id);
    song.coverUrl = fileUrl;
    await this.songRepo.save(song);
    await this.auditLogsService.logAction(
      'UPDATE_COVER',
      'Song',
      id,
      adminUsername,
      { coverUrl: fileUrl },
    );
    return song;
  }

  async uploadAudio(
    id: string,
    file: Express.Multer.File,
    adminUsername: string,
  ) {
    const song = await this.findOne(id);
    song.status = SongStatus.PROCESSING;
    song.audioUrl = `/uploads/songs/${file.filename}`;
    song.fileSizeBytes = file.size;
    await this.songRepo.save(song);

    // Fire and forget audio processing
    this.processAudio(song, file.path, adminUsername).catch((err) => {
      this.logger.error(`Error processing audio for song ${song.id}`, err);
    });

    return song;
  }

  private async processAudio(
    song: Song,
    filePath: string,
    adminUsername: string,
  ) {
    try {
      // 1. Extract Metadata using FFprobe
      const metadata: any = await new Promise((resolve, reject) => {
        ffmpeg.ffprobe(filePath, (err, metadata) => {
          if (err) reject(err);
          else resolve(metadata);
        });
      });

      if (metadata.format) {
        song.durationMs = Math.round((metadata.format.duration || 0) * 1000);
        song.bitrate = metadata.format.bit_rate;
        song.audioFormat = metadata.format.format_name;
      }
      if (metadata.streams && metadata.streams[0]) {
        song.sampleRate = metadata.streams[0].sample_rate;
      }

      // 2. Generate 30s Preview
      const previewFileName = `preview-${path.basename(filePath)}`;
      const previewPath = path.join(path.dirname(filePath), previewFileName);

      await new Promise((resolve, reject) => {
        ffmpeg(filePath)
          .setStartTime('00:00:00')
          .setDuration(30)
          .output(previewPath)
          .on('end', resolve)
          .on('error', reject)
          .run();
      });
      song.previewUrl = `/uploads/songs/${previewFileName}`;

      // 3. Mock Waveform
      const peaks = Array.from({ length: 100 }, () => Math.random());
      song.waveformUrl = peaks;
      song.status = SongStatus.PUBLISHED;

      await this.songRepo.save(song);
      await this.auditLogsService.logAction(
        'AUDIO_PROCESSED',
        'Song',
        song.id,
        adminUsername,
        { duration: song.durationMs },
      );
    } catch (error) {
      song.status = SongStatus.DRAFT;
      await this.songRepo.save(song);
      throw error;
    }
  }
}
