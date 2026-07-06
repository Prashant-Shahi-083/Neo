import {
  IsString,
  IsOptional,
  IsEnum,
  IsUUID,
  IsDateString,
} from 'class-validator';
import { AlbumStatus } from '../../entities/album.entity';

export class CreateAlbumDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsDateString()
  releaseDate?: string;

  @IsOptional()
  @IsEnum(AlbumStatus)
  status?: AlbumStatus;

  @IsUUID()
  artistId: string;

  @IsOptional()
  @IsUUID()
  genreId?: string;
}
