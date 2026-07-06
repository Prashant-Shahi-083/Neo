import { IsString, IsEnum, IsOptional } from 'class-validator';
import { ReferenceType } from '../../entities/homepage-item.entity';

export class AddItemDto {
  @IsEnum(ReferenceType)
  referenceType: ReferenceType;

  @IsString()
  referenceId: string;

  @IsOptional()
  @IsString()
  customTitle?: string;

  @IsOptional()
  @IsString()
  customSubtitle?: string;

  @IsOptional()
  @IsString()
  customImageUrl?: string;
}
