import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Album } from '../entities/album.entity';
import { Artist } from '../entities/artist.entity';
import { Genre } from '../entities/genre.entity';
import { CreateAlbumDto } from './dto/create-album.dto';
import { UpdateAlbumDto } from './dto/update-album.dto';
import { AuditLogsService } from '../audit-logs/audit-logs.service';

@Injectable()
export class AlbumsService {
  constructor(
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
    @InjectRepository(Genre) private genreRepo: Repository<Genre>,
    private auditLogsService: AuditLogsService,
  ) {}

  async findAll(page: number = 1, limit: number = 10, search: string = '') {
    const [data, total] = await this.albumRepo.findAndCount({
      where: search ? { title: Like(`%${search}%`) } : {},
      relations: { artist: true, genre: true },
      take: limit,
      skip: (page - 1) * limit,
      order: { releaseDate: 'DESC' },
    });
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const album = await this.albumRepo.findOne({
      where: { id },
      relations: { artist: true, genre: true },
    });
    if (!album) throw new NotFoundException('Album not found');
    return album;
  }

  async getMetadataForm() {
    const artists = await this.artistRepo.find({
      select: { id: true, name: true },
      order: { name: 'ASC' },
    });
    const genres = await this.genreRepo.find({
      select: { id: true, name: true },
      order: { name: 'ASC' },
    });
    return { artists, genres };
  }

  async create(dto: CreateAlbumDto, adminUsername: string) {
    const artist = await this.artistRepo.findOne({
      where: { id: dto.artistId },
    });
    if (!artist) throw new NotFoundException('Artist not found');

    let genre: Genre | null = null;
    if (dto.genreId) {
      genre = await this.genreRepo.findOne({ where: { id: dto.genreId } });
    }

    const album = new Album();
    Object.assign(album, dto);
    album.artist = artist;
    album.genre = genre as any;

    const saved = await this.albumRepo.save(album);
    await this.auditLogsService.logAction(
      'CREATE',
      'Album',
      saved.id,
      adminUsername,
      dto,
    );
    return saved;
  }

  async update(id: string, dto: UpdateAlbumDto, adminUsername: string) {
    const album = await this.findOne(id);

    if (dto.artistId) {
      const artist = await this.artistRepo.findOne({
        where: { id: dto.artistId },
      });
      if (!artist) throw new NotFoundException('Artist not found');
      album.artist = artist;
    }

    if (dto.genreId !== undefined) {
      if (dto.genreId) {
        const genre = await this.genreRepo.findOne({
          where: { id: dto.genreId },
        });
        if (!genre) throw new NotFoundException('Genre not found');
        album.genre = genre;
      } else {
        album.genre = null as any;
      }
    }

    Object.assign(album, dto);

    const updated = await this.albumRepo.save(album);
    await this.auditLogsService.logAction(
      'UPDATE',
      'Album',
      id,
      adminUsername,
      dto,
    );
    return updated;
  }

  async uploadCover(id: string, fileUrl: string, adminUsername: string) {
    const album = await this.findOne(id);
    album.coverUrl = fileUrl;
    await this.albumRepo.save(album);
    await this.auditLogsService.logAction(
      'UPDATE_COVER',
      'Album',
      id,
      adminUsername,
      { coverUrl: fileUrl },
    );
    return album;
  }

  async remove(id: string, adminUsername: string) {
    const album = await this.findOne(id);
    await this.albumRepo.softRemove(album);
    await this.auditLogsService.logAction('DELETE', 'Album', id, adminUsername);
    return { message: 'Album deleted successfully' };
  }
}
