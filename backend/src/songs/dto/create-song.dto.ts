import {
  IsString,
  IsOptional,
  IsBoolean,
  IsEnum,
  IsUUID,
  IsArray,
  IsNumber,
} from 'class-validator';
import { SongStatus } from '../../entities/song.entity';

export class CreateSongDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsOptional()
  @IsString()
  coverUrl?: string;

  @IsOptional()
  @IsNumber()
  durationMs?: number;

  @IsOptional()
  @IsString()
  language?: string;

  @IsOptional()
  @IsBoolean()
  isExplicit?: boolean;

  @IsOptional()
  @IsString()
  lyrics?: string;

  @IsOptional()
  @IsString()
  composer?: string;

  @IsOptional()
  @IsString()
  producer?: string;

  @IsOptional()
  @IsString()
  isrc?: string;

  @IsOptional()
  @IsEnum(SongStatus)
  status?: SongStatus;

  @IsOptional()
  @IsUUID()
  albumId?: string;

  @IsOptional()
  @IsUUID()
  genreId?: string;

  @IsOptional()
  @IsArray()
  @IsUUID('4', { each: true })
  artistIds?: string[];
}
