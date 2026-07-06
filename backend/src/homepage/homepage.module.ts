import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HomepageSection } from '../entities/homepage-section.entity';
import { HomepageItem } from '../entities/homepage-item.entity';
import { Song } from '../entities/song.entity';
import { Playlist } from '../entities/playlist.entity';
import { Album } from '../entities/album.entity';
import { Artist } from '../entities/artist.entity';
import { HomepageService } from './homepage.service';
import { HomepageController } from './homepage.controller';
import { PublicHomepageController } from './public-homepage.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      HomepageSection,
      HomepageItem,
      Song,
      Playlist,
      Album,
      Artist,
    ]),
  ],
  providers: [HomepageService],
  controllers: [HomepageController, PublicHomepageController],
})
export class HomepageModule {}
