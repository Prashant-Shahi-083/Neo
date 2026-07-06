import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Artist } from '../entities/artist.entity';
import { ArtistsService } from './artists.service';
import { ArtistsController } from './artists.controller';
import { PublicArtistsController } from './public-artists.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Artist])],
  providers: [ArtistsService],
  controllers: [ArtistsController, PublicArtistsController],
})
export class ArtistsModule {}
