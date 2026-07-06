import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Album } from '../entities/album.entity';
import { Genre } from '../entities/genre.entity';
import { Artist } from '../entities/artist.entity';
import { AlbumsService } from './albums.service';
import { AlbumsController } from './albums.controller';
import { PublicAlbumsController } from './public-albums.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Album, Genre, Artist])],
  providers: [AlbumsService],
  controllers: [AlbumsController, PublicAlbumsController],
})
export class AlbumsModule {}
