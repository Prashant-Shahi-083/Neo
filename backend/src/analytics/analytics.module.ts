import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Song } from '../entities/song.entity';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Playlist } from '../entities/playlist.entity';
import { AuditLog } from '../entities/audit-log.entity';
import { SearchQuery } from '../entities/search-query.entity';
import { MediaUpload } from '../entities/media-upload.entity';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Song,
      Artist,
      Album,
      Playlist,
      AuditLog,
      SearchQuery,
      MediaUpload,
    ]),
  ],
  providers: [AnalyticsService],
  controllers: [AnalyticsController],
})
export class AnalyticsModule {}
