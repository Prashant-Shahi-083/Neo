import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RecommendationConfig } from '../entities/recommendation-config.entity';
import { Song } from '../entities/song.entity';
import { Artist } from '../entities/artist.entity';
import { RecommendationsService } from './recommendations.service';
import { RecommendationsController } from './recommendations.controller';

@Module({
  imports: [TypeOrmModule.forFeature([RecommendationConfig, Song, Artist])],
  providers: [RecommendationsService],
  controllers: [RecommendationsController],
})
export class RecommendationsModule {}
