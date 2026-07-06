import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Not, In } from 'typeorm';
import { RecommendationConfig } from '../entities/recommendation-config.entity';
import { Song } from '../entities/song.entity';

@Injectable()
export class RecommendationsService implements OnModuleInit {
  constructor(
    @InjectRepository(RecommendationConfig)
    private configRepo: Repository<RecommendationConfig>,
    @InjectRepository(Song) private songRepo: Repository<Song>,
  ) {}

  async onModuleInit() {
    const count = await this.configRepo.count();
    if (count === 0) {
      await this.configRepo.save(this.configRepo.create({}));
    }
  }

  async getConfig() {
    const configs = await this.configRepo.find();
    return configs[0];
  }

  async updateConfig(dto: Partial<RecommendationConfig>) {
    const config = await this.getConfig();
    Object.assign(config, dto);
    return this.configRepo.save(config);
  }

  // Content-Based Recommendation: Find similar songs based on Genre and Artists
  async getSimilarSongs(songId: string, limit: number = 10) {
    const sourceSong = await this.songRepo.findOne({
      where: { id: songId },
      relations: { genre: true, artists: true },
    });

    if (!sourceSong) return [];

    const config = await this.getConfig();

    // In a real heavy DB, we'd do a complex raw SQL query.
    // For now, we fetch a pool and rank in memory.
    const artistIds = sourceSong.artists?.map((a) => a.id) || [];

    const candidateSongs = await this.songRepo.find({
      where: { id: Not(sourceSong.id) },
      relations: { genre: true, artists: true },
      take: 200, // Bound the candidate pool
    });

    const scored = candidateSongs.map((song) => {
      let score = 0;
      // Match Genre
      if (sourceSong.genre?.id && song.genre?.id === sourceSong.genre.id) {
        score += config.genreWeight;
      }
      // Match Artists
      const commonArtists =
        song.artists?.filter((a) => artistIds.includes(a.id)).length || 0;
      score += commonArtists * config.artistWeight;

      return { song, score };
    });

    return scored
      .filter((s) => s.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit)
      .map((s) => s.song);
  }

  async getTrendingSongs(limit: number = 10) {
    // Requires a plays counter. Assuming we can order by ID for mock trending if no stats exist.
    // We will select randomly for the mock engine.
    const all = await this.songRepo.find({
      take: limit,
      relations: { artists: true },
    });
    return all.sort(() => 0.5 - Math.random());
  }
}
