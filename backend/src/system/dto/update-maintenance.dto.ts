import { IsBoolean, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateMaintenanceDto {
  @ApiProperty()
  @IsBoolean()
  isEnabled: boolean;

  @ApiProperty()
  @IsString()
  message: string;

  @ApiProperty()
  @IsString()
  estimatedTime: string;

  @ApiProperty()
  @IsBoolean()
  emergencyLock: boolean;
}
