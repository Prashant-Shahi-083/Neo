import { IsString, IsArray, ArrayMinSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateApiKeyDto {
  @ApiProperty()
  @IsString()
  name: string;

  @ApiProperty()
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(1)
  scopes: string[];
}
