import { UserProfileDto } from '../users/dto/user-profile.dto';
import { SongDto } from '../songs/dto/song.dto';
import { PlaylistDto } from '../playlists/dto/playlist.dto';
import { AlbumDto } from '../albums/dto/album.dto';
import { ArtistDto } from '../artists/dto/artist.dto';

export class DtoMapper {
  static toUserProfile(user: any): UserProfileDto {
    return {
      id: user.id,
      username: user.username,
      displayName: user.displayName || user.username,
      email: user.email || '',
      avatar: user.avatarUrl || '',
      role: user.role,
      createdAt: user.createdAt?.toISOString() || new Date().toISOString(),
      premium: user.role === 'SUPER_ADMIN' || user.role === 'ADMIN',
    };
  }

  static toSong(song: any): SongDto {
    return {
      id: song.id,
      title: song.title,
      audioUrl: song.audioUrl || '',
      coverUrl: song.coverUrl || '',
      durationMs: song.durationMs || 0,
      artists: song.artists?.map((a) => ({ name: a.name })) || [],
      album: song.album ? { title: song.album.title } : undefined,
    };
  }

  static toPlaylist(playlist: any): PlaylistDto {
    return {
      id: playlist.id,
      title: playlist.title,
      description: playlist.description || '',
      coverUrl: playlist.coverUrl || '',
      playlistSongs:
        playlist.playlistSongs?.map((ps) => ({
          song: DtoMapper.toSong(ps.song),
        })) || [],
    };
  }

  static toAlbum(album: any): AlbumDto {
    return {
      id: album.id,
      title: album.title,
      releaseYear: album.releaseYear || new Date().getFullYear(),
      coverUrl: album.coverUrl || '',
      type: album.type || 'ALBUM',
      artist: album.artist ? DtoMapper.toArtist(album.artist) : undefined,
    };
  }

  static toArtist(artist: any): ArtistDto {
    return {
      id: artist.id,
      name: artist.name,
      bio: artist.bio || '',
      imageUrl: artist.imageUrl || '',
    };
  }
}
