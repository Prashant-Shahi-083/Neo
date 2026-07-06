export class SongArtistDto {
  name: string;
}

export class SongAlbumDto {
  title: string;
}

export class SongDto {
  id: string;
  title: string;
  audioUrl: string;
  coverUrl: string;
  durationMs: number;
  artists: SongArtistDto[];
  album?: SongAlbumDto;
}
