import { SongDto } from '../../songs/dto/song.dto';
import { PlaylistDto } from '../../playlists/dto/playlist.dto';

export class PaginationMeta {
  currentPage: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
  hasMore: boolean;
}

export class HomepageSectionDto {
  id: string;
  title: string;
  type: string; // e.g. 'SONGS', 'PLAYLISTS'
  items: (SongDto | PlaylistDto)[];
}

export class HomepageDto {
  sections: HomepageSectionDto[];
  pagination: PaginationMeta;
}
