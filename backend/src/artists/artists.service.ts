import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Artist } from '../entities/artist.entity';
import { CreateArtistDto } from './dto/create-artist.dto';
import { UpdateArtistDto } from './dto/update-artist.dto';
import { AuditLogsService } from '../audit-logs/audit-logs.service';

@Injectable()
export class ArtistsService {
  constructor(
    @InjectRepository(Artist)
    private artistRepo: Repository<Artist>,
    private auditLogsService: AuditLogsService,
  ) {}

  async findAll(page: number = 1, limit: number = 10, search: string = '') {
    const [data, total] = await this.artistRepo.findAndCount({
      where: search ? { name: Like(`%${search}%`) } : {},
      take: limit,
      skip: (page - 1) * limit,
      order: { createdAt: 'DESC' },
    });
    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: string) {
    const artist = await this.artistRepo.findOne({ where: { id } });
    if (!artist) throw new NotFoundException('Artist not found');
    return artist;
  }

  async create(dto: CreateArtistDto, adminUsername: string) {
    const artist = this.artistRepo.create(dto);
    const saved = await this.artistRepo.save(artist);
    await this.auditLogsService.logAction(
      'CREATE',
      'Artist',
      saved.id,
      adminUsername,
      dto,
    );
    return saved;
  }

  async update(id: string, dto: UpdateArtistDto, adminUsername: string) {
    const artist = await this.findOne(id);
    const updated = await this.artistRepo.save({ ...artist, ...dto });
    await this.auditLogsService.logAction(
      'UPDATE',
      'Artist',
      id,
      adminUsername,
      dto,
    );
    return updated;
  }

  async uploadImage(id: string, fileUrl: string, adminUsername: string) {
    const artist = await this.findOne(id);
    artist.photoUrl = fileUrl;
    await this.artistRepo.save(artist);
    await this.auditLogsService.logAction(
      'UPDATE_IMAGE',
      'Artist',
      id,
      adminUsername,
      { photoUrl: fileUrl },
    );
    return artist;
  }

  async remove(id: string, adminUsername: string) {
    const artist = await this.findOne(id);
    await this.artistRepo.softRemove(artist);
    await this.auditLogsService.logAction(
      'DELETE',
      'Artist',
      id,
      adminUsername,
    );
    return { message: 'Artist deleted successfully' };
  }
}
