import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Song } from '../entities/song.entity';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Playlist } from '../entities/playlist.entity';
import { AuditLog } from '../entities/audit-log.entity';
import { SearchQuery } from '../entities/search-query.entity';
import { MediaUpload } from '../entities/media-upload.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(Song) private songRepo: Repository<Song>,
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Playlist) private playlistRepo: Repository<Playlist>,
    @InjectRepository(AuditLog) private auditRepo: Repository<AuditLog>,
    @InjectRepository(SearchQuery) private searchRepo: Repository<SearchQuery>,
    @InjectRepository(MediaUpload) private mediaRepo: Repository<MediaUpload>,
  ) {}

  async getDashboardMetrics() {
    const [
      totalSongs,
      totalArtists,
      totalAlbums,
      totalPlaylists,
      totalUploads,
      totalSearches,
    ] = await Promise.all([
      this.songRepo.count(),
      this.artistRepo.count(),
      this.albumRepo.count(),
      this.playlistRepo.count(),
      this.mediaRepo.count(),
      this.searchRepo.count(),
    ]);

    // Calculate database size proxy (Sum of fileSizeBytes in Songs)
    const storageData = await this.songRepo
      .createQueryBuilder('song')
      .select('SUM(song.fileSizeBytes)', 'totalBytes')
      .getRawOne();

    const totalStorageBytes = parseInt(storageData?.totalBytes || '0', 10);

    return {
      totals: {
        songs: totalSongs,
        artists: totalArtists,
        albums: totalAlbums,
        playlists: totalPlaylists,
        uploads: totalUploads,
        searches: totalSearches,
        storageBytes: totalStorageBytes,
      },
    };
  }

  async getActivityTrends() {
    // A simplified trend showing the last 7 days of audit logs
    // In PostgreSQL, we can GROUP BY DATE(createdAt)
    const rawData = await this.auditRepo
      .createQueryBuilder('audit')
      .select('DATE(audit.timestamp)', 'date')
      .addSelect('COUNT(audit.id)', 'count')
      .groupBy('DATE(audit.timestamp)')
      .orderBy('date', 'DESC')
      .limit(7)
      .getRawMany();

    return rawData
      .map((r) => ({ date: r.date, actions: parseInt(r.count, 10) }))
      .reverse();
  }
}
