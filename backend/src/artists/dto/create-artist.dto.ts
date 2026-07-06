import { IsString, IsOptional, IsBoolean } from 'class-validator';

export class CreateArtistDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  bio?: string;

  @IsOptional()
  @IsBoolean()
  isVerified?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
