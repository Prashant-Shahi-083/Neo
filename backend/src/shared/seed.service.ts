import { Injectable, OnApplicationBootstrap, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Artist } from '../entities/artist.entity';
import { Album, AlbumStatus } from '../entities/album.entity';
import { Song, SongStatus } from '../entities/song.entity';
import { Playlist, PlaylistStatus, PlaylistType } from '../entities/playlist.entity';
import { PlaylistSong } from '../entities/playlist-song.entity';
import { HomepageSection, SectionType } from '../entities/homepage-section.entity';
import { HomepageItem, ReferenceType } from '../entities/homepage-item.entity';
import { RecommendationConfig } from '../entities/recommendation-config.entity';

@Injectable()
export class SeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @InjectRepository(Artist) private artistRepo: Repository<Artist>,
    @InjectRepository(Album) private albumRepo: Repository<Album>,
    @InjectRepository(Song) private songRepo: Repository<Song>,
    @InjectRepository(Playlist) private playlistRepo: Repository<Playlist>,
    @InjectRepository(PlaylistSong) private playlistSongRepo: Repository<PlaylistSong>,
    @InjectRepository(HomepageSection) private sectionRepo: Repository<HomepageSection>,
    @InjectRepository(HomepageItem) private itemRepo: Repository<HomepageItem>,
    @InjectRepository(RecommendationConfig) private recConfigRepo: Repository<RecommendationConfig>,
  ) {}

  async onApplicationBootstrap() {
    await this.seedProductionContent();
  }

  private async saveArtist(data: Partial<Artist>): Promise<Artist> {
    const entity = this.artistRepo.create(data as any) as any;
    return (await this.artistRepo.save(entity)) as unknown as Artist;
  }

  private async saveAlbum(data: Partial<Album>): Promise<Album> {
    const entity = this.albumRepo.create(data as any) as any;
    return (await this.albumRepo.save(entity)) as unknown as Album;
  }

  private async saveSong(data: Partial<Song>): Promise<Song> {
    const entity = this.songRepo.create(data as any) as any;
    return (await this.songRepo.save(entity)) as unknown as Song;
  }

  private async savePlaylist(data: Partial<Playlist>): Promise<Playlist> {
    const entity = this.playlistRepo.create(data as any) as any;
    return (await this.playlistRepo.save(entity)) as unknown as Playlist;
  }

  private async saveSection(data: Partial<HomepageSection>): Promise<HomepageSection> {
    const entity = this.sectionRepo.create(data as any) as any;
    return (await this.sectionRepo.save(entity)) as unknown as HomepageSection;
  }

  async seedProductionContent() {
    try {
      const songCount = await this.songRepo.count();
      if (songCount > 0) {
        this.logger.log(`Database already contains ${songCount} songs. Skipping automatic sample music seeding.`);
        return;
      }

      this.logger.log('Seeding initial production music library (Artists, Albums, Songs, Playlists, Homepage)...');

      // 1. Create Artists
      const theWeeknd = await this.saveArtist({
        name: 'The Weeknd',
        bio: 'Canadian singer and songwriter known for sonic versatility and dark lyricism.',
        photoUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
        isVerified: true,
        isActive: true,
      });

      const sia = await this.saveArtist({
        name: 'Sia',
        bio: 'Australian singer and songwriter known for powerful vocals and pop anthems.',
        photoUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=500&q=80',
        isVerified: true,
        isActive: true,
      });

      const imagineDragons = await this.saveArtist({
        name: 'Imagine Dragons',
        bio: 'American pop rock band from Las Vegas, Nevada.',
        photoUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=500&q=80',
        isVerified: true,
        isActive: true,
      });

      const duaLipa = await this.saveArtist({
        name: 'Dua Lipa',
        bio: 'English and Albanian singer and songwriter known for disco-pop influenced sound.',
        photoUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=500&q=80',
        isVerified: true,
        isActive: true,
      });

      // 2. Create Albums
      const starboyAlbum = await this.saveAlbum({
        title: 'Starboy',
        description: 'The third studio album by Canadian singer The Weeknd.',
        coverUrl: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=500&q=80',
        releaseDate: '2016-11-25',
        status: AlbumStatus.PUBLISHED,
        artist: theWeeknd,
      });

      const actingAlbum = await this.saveAlbum({
        title: 'This Is Acting',
        description: 'The seventh studio album by Australian singer and songwriter Sia.',
        coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80',
        releaseDate: '2016-01-29',
        status: AlbumStatus.PUBLISHED,
        artist: sia,
      });

      const evolveAlbum = await this.saveAlbum({
        title: 'Evolve',
        description: 'The third studio album by American pop rock band Imagine Dragons.',
        coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
        releaseDate: '2017-06-23',
        status: AlbumStatus.PUBLISHED,
        artist: imagineDragons,
      });

      const futureAlbum = await this.saveAlbum({
        title: 'Future Nostalgia',
        description: 'The second studio album by English-Albanian singer Dua Lipa.',
        coverUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=500&q=80',
        releaseDate: '2020-03-27',
        status: AlbumStatus.PUBLISHED,
        artist: duaLipa,
      });

      // 3. Create Songs
      const song1 = await this.saveSong({
        title: 'Blinding Lights',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=500&q=80',
        durationMs: 200000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: starboyAlbum,
        artists: [theWeeknd],
      });

      const song2 = await this.saveSong({
        title: 'Unstoppable',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80',
        durationMs: 217000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: actingAlbum,
        artists: [sia],
      });

      const song3 = await this.saveSong({
        title: 'Starboy (feat. Daft Punk)',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=500&q=80',
        durationMs: 230000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: starboyAlbum,
        artists: [theWeeknd],
      });

      const song4 = await this.saveSong({
        title: 'Bones',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
        durationMs: 165000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: evolveAlbum,
        artists: [imagineDragons],
      });

      const song5 = await this.saveSong({
        title: 'Levitating',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=500&q=80',
        durationMs: 203000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: futureAlbum,
        artists: [duaLipa],
      });

      const song6 = await this.saveSong({
        title: 'Save Your Tears',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=500&q=80',
        durationMs: 215000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: starboyAlbum,
        artists: [theWeeknd],
      });

      const song7 = await this.saveSong({
        title: 'Chandelier',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=500&q=80',
        durationMs: 216000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: actingAlbum,
        artists: [sia],
      });

      const song8 = await this.saveSong({
        title: 'Believer',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
        coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
        durationMs: 204000,
        bitrate: 320,
        status: SongStatus.PUBLISHED,
        album: evolveAlbum,
        artists: [imagineDragons],
      });

      // 4. Create Playlists
      const p1 = await this.savePlaylist({
        title: 'Chill Vibes',
        description: 'Relaxing tracks to unwind and focus.',
        coverUrl: 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?auto=format&fit=crop&w=500&q=80',
        adminUsername: 'admin',
        status: PlaylistStatus.PUBLIC,
        type: PlaylistType.EDITORIAL,
      });

      const p2 = await this.savePlaylist({
        title: 'Workout Bangers',
        description: 'High energy songs to get you moving.',
        coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=500&q=80',
        adminUsername: 'admin',
        status: PlaylistStatus.PUBLIC,
        type: PlaylistType.EDITORIAL,
      });

      // Add songs to playlists
      await this.playlistSongRepo.save([
        this.playlistSongRepo.create({ playlist: p1, song: song1, position: 1 } as any),
        this.playlistSongRepo.create({ playlist: p1, song: song5, position: 2 } as any),
        this.playlistSongRepo.create({ playlist: p1, song: song6, position: 3 } as any),
        this.playlistSongRepo.create({ playlist: p2, song: song2, position: 1 } as any),
        this.playlistSongRepo.create({ playlist: p2, song: song3, position: 2 } as any),
        this.playlistSongRepo.create({ playlist: p2, song: song4, position: 3 } as any),
        this.playlistSongRepo.create({ playlist: p2, song: song8, position: 4 } as any),
      ] as any);

      // 5. Create Homepage Sections
      const s1 = await this.saveSection({
        title: 'Recently Played',
        type: SectionType.HORIZONTAL_LIST,
        order: 1,
        isActive: true,
      });

      const s2 = await this.saveSection({
        title: 'Made For You',
        type: SectionType.HORIZONTAL_LIST,
        order: 2,
        isActive: true,
      });

      const s3 = await this.saveSection({
        title: 'Trending Artists',
        type: SectionType.GRID,
        order: 3,
        isActive: true,
      });

      // Add items to sections
      await this.itemRepo.save([
        this.itemRepo.create({ section: s1, referenceType: ReferenceType.SONG, referenceId: song1.id, order: 1 } as any),
        this.itemRepo.create({ section: s1, referenceType: ReferenceType.SONG, referenceId: song2.id, order: 2 } as any),
        this.itemRepo.create({ section: s1, referenceType: ReferenceType.SONG, referenceId: song3.id, order: 3 } as any),
        this.itemRepo.create({ section: s1, referenceType: ReferenceType.SONG, referenceId: song4.id, order: 4 } as any),
        this.itemRepo.create({ section: s2, referenceType: ReferenceType.SONG, referenceId: song5.id, order: 1 } as any),
        this.itemRepo.create({ section: s2, referenceType: ReferenceType.SONG, referenceId: song6.id, order: 2 } as any),
        this.itemRepo.create({ section: s2, referenceType: ReferenceType.SONG, referenceId: song7.id, order: 3 } as any),
        this.itemRepo.create({ section: s2, referenceType: ReferenceType.SONG, referenceId: song8.id, order: 4 } as any),
        this.itemRepo.create({ section: s3, referenceType: ReferenceType.ARTIST, referenceId: theWeeknd.id, order: 1 } as any),
        this.itemRepo.create({ section: s3, referenceType: ReferenceType.ARTIST, referenceId: sia.id, order: 2 } as any),
        this.itemRepo.create({ section: s3, referenceType: ReferenceType.ARTIST, referenceId: imagineDragons.id, order: 3 } as any),
        this.itemRepo.create({ section: s3, referenceType: ReferenceType.ARTIST, referenceId: duaLipa.id, order: 4 } as any),
      ] as any);

      // 6. Init Recommendation Config
      const existingConfig = await this.recConfigRepo.find();
      if (existingConfig.length === 0) {
        await this.recConfigRepo.save(
          this.recConfigRepo.create({
            genreWeight: 1.0,
            artistWeight: 0.8,
            tagWeight: 0.5,
            trendingThresholdPlays: 100,
          } as any) as any,
        );
      }

      this.logger.log('Production music database seeded successfully!');
    } catch (error) {
      this.logger.error('Error seeding production music library:', error);
    }
  }
}
