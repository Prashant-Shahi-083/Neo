import {
  IsString,
  IsEnum,
  IsBoolean,
  IsNumber,
  IsOptional,
} from 'class-validator';
import { SectionType } from '../../entities/homepage-section.entity';

export class CreateSectionDto {
  @IsString()
  title: string;

  @IsEnum(SectionType)
  type: SectionType;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateSectionDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsEnum(SectionType)
  type?: SectionType;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class ReorderDto {
  @IsString({ each: true })
  orderedIds: string[];
}
