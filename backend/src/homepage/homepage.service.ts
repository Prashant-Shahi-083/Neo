import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HomepageSection } from '../entities/homepage-section.entity';
import { HomepageItem, ReferenceType } from '../entities/homepage-item.entity';
import { Song } from '../entities/song.entity';
import { Playlist } from '../entities/playlist.entity';
import { Album } from '../entities/album.entity';
import { Artist } from '../entities/artist.entity';
import {
  CreateSectionDto,
  UpdateSectionDto,
  ReorderDto,
} from './dto/section.dto';
import { AddItemDto } from './dto/item.dto';
import { DtoMapper } from '../shared/dto-mapper';

@Injectable()
export class HomepageService {
  constructor(
    @InjectRepository(HomepageSection)
    private sectionRepo: Repository<HomepageSection>,
    @InjectRepository(HomepageItem) private itemRepo: Repository<HomepageItem>,
    @InjectRepository(Song) private songRepo: Repository<Song>,
    @InjectRepository(Playlist) private playlistRepo: Repository<Playlist>,
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
  ) {}

  async findAll() {
    const sections = await this.sectionRepo.find({
      relations: { items: true },
    });

    // Sort sections by order
    sections.sort((a, b) => a.order - b.order);

    // Sort items inside sections by order
    sections.forEach((section) => {
      if (section.items) section.items.sort((a, b) => a.order - b.order);
    });

    return sections;
  }

  async createSection(dto: CreateSectionDto) {
    const count = await this.sectionRepo.count();
    const section = this.sectionRepo.create({ ...dto, order: count });
    return this.sectionRepo.save(section);
  }

  async updateSection(id: string, dto: UpdateSectionDto) {
    const section = await this.sectionRepo.findOne({ where: { id } });
    if (!section) throw new NotFoundException('Section not found');
    Object.assign(section, dto);
    return this.sectionRepo.save(section);
  }

  async deleteSection(id: string) {
    const section = await this.sectionRepo.findOne({ where: { id } });
    if (!section) throw new NotFoundException('Section not found');
    await this.sectionRepo.remove(section);
    return { success: true };
  }

  async reorderSections(dto: ReorderDto) {
    const updates = dto.orderedIds.map((id, index) =>
      this.sectionRepo.update(id, { order: index }),
    );
    await Promise.all(updates);
    return this.findAll();
  }

  // --- ITEM LOGIC ---

  async addItem(sectionId: string, dto: AddItemDto) {
    const section = await this.sectionRepo.findOne({
      where: { id: sectionId },
      relations: { items: true },
    });
    if (!section) throw new NotFoundException('Section not found');

    const item = this.itemRepo.create({
      ...dto,
      section,
      order: section.items?.length || 0,
    });

    return this.itemRepo.save(item);
  }

  async removeItem(sectionId: string, itemId: string) {
    const item = await this.itemRepo.findOne({
      where: { id: itemId, section: { id: sectionId } },
    });
    if (!item) throw new NotFoundException('Item not found in section');
    await this.itemRepo.remove(item);
    return { success: true };
  }

  async reorderItems(sectionId: string, dto: ReorderDto) {
    const updates = dto.orderedIds.map((id, index) =>
      this.itemRepo.update(
        { id, section: { id: sectionId } },
        { order: index },
      ),
    );
    await Promise.all(updates);
    return { success: true };
  }

  // --- PUBLIC FEED ---

  async getPublicFeed(page: number = 1, limit: number = 10) {
    // Clamp inputs
    const safePage = Math.max(1, page);
    const safeLimit = Math.min(Math.max(1, limit), 50);
    const skip = (safePage - 1) * safeLimit;

    // Paginated query: only active sections, ordered by `order`
    const [sections, totalItems] = await this.sectionRepo.findAndCount({
      where: { isActive: true },
      relations: { items: true },
      order: { order: 'ASC' },
      skip,
      take: safeLimit,
    });

    // Sort items inside each section by order
    sections.forEach((section) => {
      if (section.items) section.items.sort((a, b) => a.order - b.order);
    });

    const totalPages = Math.ceil(totalItems / safeLimit);

    const hydratedSections: any[] = [];
    for (const section of sections) {
      const items: any[] = [];
      for (const item of section.items) {
        let hydratedData: any = null;
        if (item.referenceType === ReferenceType.SONG) {
          const song = await this.songRepo.findOne({
            where: { id: item.referenceId },
            relations: { artists: true, album: true },
          });
          if (song) hydratedData = song;
        } else if (item.referenceType === ReferenceType.PLAYLIST) {
          const playlist = await this.playlistRepo.findOne({
            where: { id: item.referenceId },
          });
          if (playlist) hydratedData = playlist;
        } else if (item.referenceType === ReferenceType.ALBUM) {
          const album = await this.albumRepo.findOne({
            where: { id: item.referenceId },
            relations: { artist: true },
          });
          if (album) hydratedData = album;
        } else if (item.referenceType === ReferenceType.ARTIST) {
          const artist = await this.artistRepo.findOne({
            where: { id: item.referenceId },
          });
          if (artist) hydratedData = artist;
        }

        if (hydratedData) {
          let mappedData = hydratedData;
          if (item.referenceType === ReferenceType.SONG)
            mappedData = DtoMapper.toSong(hydratedData);
          else if (item.referenceType === ReferenceType.PLAYLIST)
            mappedData = DtoMapper.toPlaylist(hydratedData);
          else if (item.referenceType === ReferenceType.ALBUM)
            mappedData = DtoMapper.toAlbum(hydratedData);
          else if (item.referenceType === ReferenceType.ARTIST)
            mappedData = DtoMapper.toArtist(hydratedData);

          items.push({
            ...item,
            data: mappedData,
          });
        }
      }
      hydratedSections.push({
        ...section,
        items,
      });
    }

    return {
      sections: hydratedSections,
      pagination: {
        currentPage: safePage,
        pageSize: safeLimit,
        totalItems,
        totalPages,
        hasMore: safePage < totalPages,
      },
    };
  }
}
