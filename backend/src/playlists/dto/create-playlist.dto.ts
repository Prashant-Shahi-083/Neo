import { IsString, IsOptional, IsEnum, IsArray } from 'class-validator';
import { PlaylistType, PlaylistStatus } from '../../entities/playlist.entity';

export class CreatePlaylistDto {
  @IsString()
  title: string;

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
