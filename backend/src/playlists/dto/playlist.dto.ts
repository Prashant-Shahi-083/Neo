import { SongDto } from '../../songs/dto/song.dto';

export class PlaylistDto {
  id: string;
  title: string;
  description: string;
  coverUrl: string;
  playlistSongs?: { song: SongDto }[];
}
