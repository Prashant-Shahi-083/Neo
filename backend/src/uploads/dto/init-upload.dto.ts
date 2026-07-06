import { IsString, IsNumber, IsNotEmpty } from 'class-validator';

export class InitUploadDto {
  @IsString()
  @IsNotEmpty()
  filename: string;

  @IsNumber()
  fileSize: number;

  @IsString()
  @IsNotEmpty()
  mimeType: string;
}
