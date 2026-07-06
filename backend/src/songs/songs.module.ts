import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Song } from '../entities/song.entity';
import { Album } from '../entities/album.entity';
import { Artist } from '../entities/artist.entity';
import { Genre } from '../entities/genre.entity';
import { SongsService } from './songs.service';
import { SongsController } from './songs.controller';
import { PublicSongsController } from './public-songs.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Song, Album, Artist, Genre])],
  providers: [SongsService],
  controllers: [SongsController, PublicSongsController],
})
export class SongsModule {}
