import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Song } from '../entities/song.entity';
import { Playlist } from '../entities/playlist.entity';
import { PlaylistSong } from '../entities/playlist-song.entity';
import { HomepageSection } from '../entities/homepage-section.entity';
import { HomepageItem } from '../entities/homepage-item.entity';
import { RecommendationConfig } from '../entities/recommendation-config.entity';
import { SeedService } from './seed.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Artist,
      Album,
      Song,
      Playlist,
      PlaylistSong,
      HomepageSection,
      HomepageItem,
      RecommendationConfig,
    ]),
  ],
  providers: [SeedService],
  exports: [SeedService],
})
export class SeedModule {}
