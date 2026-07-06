import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SearchQuery } from '../entities/search-query.entity';
import { Song } from '../entities/song.entity';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Playlist } from '../entities/playlist.entity';
import { SearchService } from './search.service';
import { SearchController } from './search.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([SearchQuery, Song, Artist, Album, Playlist]),
  ],
  providers: [SearchService],
  controllers: [SearchController],
})
export class SearchModule {}
