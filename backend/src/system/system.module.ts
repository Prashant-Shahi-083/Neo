import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemSetting } from '../entities/system-setting.entity';
import { SystemController } from './system.controller';
import { SystemService } from './system.service';
import { AuditLogsModule } from '../audit-logs/audit-logs.module';

@Module({
  imports: [TypeOrmModule.forFeature([SystemSetting]), AuditLogsModule],
  controllers: [SystemController],
  providers: [SystemService],
})
export class SystemModule {}
