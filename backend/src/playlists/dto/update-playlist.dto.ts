import {
  IsString,
  IsOptional,
  IsEnum,
  IsArray,
  IsNumber,
} from 'class-validator';
import { PlaylistType, PlaylistStatus } from '../../entities/playlist.entity';

export class UpdatePlaylistDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(PlaylistType)
  type?: PlaylistType;

  @IsOptional()
  @IsEnum(PlaylistStatus)
  status?: PlaylistStatus;

  @IsOptional()
  @IsArray()
  tags?: string[];

  @IsOptional()
  @IsArray()
  categories?: string[];
}

export class AddSongDto {
  @IsString()
  songId: string;
}

export class ReorderSongsDto {
  @IsArray()
  orderedSongIds: string[];
}
