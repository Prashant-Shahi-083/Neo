import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { SearchQuery } from '../entities/search-query.entity';
import { Song } from '../entities/song.entity';
import { Artist } from '../entities/artist.entity';
import { Album } from '../entities/album.entity';
import { Playlist } from '../entities/playlist.entity';
import { DtoMapper } from '../shared/dto-mapper';

@Injectable()
export class SearchService {
  constructor(
    @InjectRepository(SearchQuery)
    private searchQueryRepo: Repository<SearchQuery>,
    @InjectRepository(Song) private songRepo: Repository<Song>,
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Playlist) private playlistRepo: Repository<Playlist>,
  ) {}

  async searchAll(
    query: string,
    type?: string,
    page: number = 1,
    limit: number = 20,
  ) {
    if (!query || query.trim().length === 0) {
      return {
        query: query || '',
        results: { songs: [], artists: [], albums: [], playlists: [] },
        pagination: {
          currentPage: page,
          pageSize: limit,
          totalItems: 0,
          totalPages: 0,
          hasMore: false,
        },
      };
    }

    const searchStr = `%${query}%`;
    const skip = (page - 1) * limit;

    let songs: Song[] = [],
      artists: Artist[] = [],
      albums: Album[] = [],
      playlists: Playlist[] = [];
    let totalItems = 0;

    const t = type?.toLowerCase();

    if (!t || t === 'song' || t === 'songs') {
      const [res, count] = await this.songRepo.findAndCount({
        where: { title: Like(searchStr) },
        take: limit,
        skip,
        relations: { artists: true, album: true },
      });
      songs = res;
      totalItems += count;
    }

    if (!t || t === 'artist' || t === 'artists') {
      const [res, count] = await this.artistRepo.findAndCount({
        where: { name: Like(searchStr) },
        take: limit,
        skip,
      });
      artists = res;
      totalItems += count;
    }

    if (!t || t === 'album' || t === 'albums') {
      const [res, count] = await this.albumRepo.findAndCount({
        where: { title: Like(searchStr) },
        take: limit,
        skip,
        relations: { artist: true },
      });
      albums = res;
      totalItems += count;
    }

    if (!t || t === 'playlist' || t === 'playlists') {
      const [res, count] = await this.playlistRepo.findAndCount({
        where: { title: Like(searchStr) },
        take: limit,
        skip,
      });
      playlists = res;
      totalItems += count;
    }

    const hasMore =
      songs.length === limit ||
      artists.length === limit ||
      albums.length === limit ||
      playlists.length === limit;

    const totalPages = Math.ceil(totalItems / limit);

    // Log the search query asynchronously
    this.logQuery(query, totalItems).catch((err) =>
      console.error('Failed to log search query', err),
    );

    return {
      query,
      results: {
        songs: songs.map((s) => DtoMapper.toSong(s)),
        artists: artists.map((a) => DtoMapper.toArtist(a)),
        albums: albums.map((a) => DtoMapper.toAlbum(a)),
        playlists: playlists.map((p) => DtoMapper.toPlaylist(p)),
      },
      pagination: {
        currentPage: page,
        pageSize: limit,
        totalItems,
        totalPages,
        hasMore,
      },
    };
  }

  // Temporary Library Mock
  async getLibrary() {
    const [songs, playlists] = await Promise.all([
      this.songRepo.find({
        take: 20,
        relations: { artists: true, album: true },
      }),
      this.playlistRepo.find({ take: 10 }),
    ]);
    return {
      songs: songs.map((s) => DtoMapper.toSong(s)),
      playlists: playlists.map((p) => DtoMapper.toPlaylist(p)),
    };
  }

  private async logQuery(term: string, resultCount: number) {
    const q = this.searchQueryRepo.create({
      term: term.toLowerCase(),
      resultCount,
    });
    await this.searchQueryRepo.save(q);
  }

  // Admin Analytics Methods
  async getTopSearches(limit: number = 20) {
    // Group by term, order by frequency
    return this.searchQueryRepo
      .createQueryBuilder('q')
      .select('q.term', 'term')
      .addSelect('COUNT(q.id)', 'count')
      .addSelect('AVG(q.resultCount)', 'avgResults')
      .groupBy('q.term')
      .orderBy('count', 'DESC')
      .limit(limit)
      .getRawMany();
  }

  async getZeroResultSearches(limit: number = 20) {
    return this.searchQueryRepo
      .createQueryBuilder('q')
      .select('q.term', 'term')
      .addSelect('COUNT(q.id)', 'count')
      .where('q.resultCount = :rc', { rc: 0 })
      .groupBy('q.term')
      .orderBy('count', 'DESC')
      .limit(limit)
      .getRawMany();
  }

  async getRecentSearches(limit: number = 20) {
    return this.searchQueryRepo.find({
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }
}
