import { SongDto } from '../../songs/dto/song.dto';
import { PlaylistDto } from '../../playlists/dto/playlist.dto';
import { AlbumDto } from '../../albums/dto/album.dto';
import { ArtistDto } from '../../artists/dto/artist.dto';
import { PaginationMeta } from '../../homepage/dto/homepage.dto';

export class SearchResultDataDto {
  songs: SongDto[];
  playlists: PlaylistDto[];
  albums: AlbumDto[];
  artists: ArtistDto[];
}

export class PaginatedSearchResultDto {
  query: string;
  results: SearchResultDataDto;
  pagination: PaginationMeta;
}
