import { ArtistDto } from '../../artists/dto/artist.dto';

export class AlbumDto {
  id: string;
  title: string;
  releaseYear: number;
  coverUrl?: string;
  type: string;
  artist?: ArtistDto;
}
