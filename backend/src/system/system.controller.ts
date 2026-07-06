import { Controller, Get, Post, Put, Body, UseGuards, Req } from '@nestjs/common';
import { SystemService } from './system.service';
import { UpdateMaintenanceDto } from './dto/update-maintenance.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Admin - System')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN)
@Controller('api/v1/admin/system')
export class SystemController {
  constructor(
    private readonly systemService: SystemService,
    private readonly auditLogsService: AuditLogsService,
  ) {}

  @Get('health')
  @ApiOperation({ summary: 'Get server health metrics' })
  async getHealth() {
    return this.systemService.getHealth();
  }

  @Get('environment')
  @ApiOperation({ summary: 'Get deployment environment variables' })
  async getEnvironment() {
    return this.systemService.getEnvironment();
  }

  @Get('storage')
  @ApiOperation({ summary: 'Get storage usage' })
  async getStorage() {
    return this.systemService.getStorage();
  }

  @Post('storage/cleanup')
  @ApiOperation({ summary: 'Run storage cleanup' })
  async cleanupStorage(@Req() req: any) {
    await this.auditLogsService.logAction('STORAGE_CLEANUP', 'System', 'storage', req.user.username);
    return this.systemService.cleanupStorage();
  }

  @Get('database')
  @ApiOperation({ summary: 'Get database status' })
  async getDatabaseStatus() {
    return this.systemService.getDatabaseStatus();
  }

  @Post('database/backup')
  @ApiOperation({ summary: 'Trigger database backup' })
  async triggerBackup(@Req() req: any) {
    await this.auditLogsService.logAction('DATABASE_BACKUP', 'System', 'database', req.user.username);
    return this.systemService.triggerDatabaseBackup();
  }

  @Get('maintenance')
  @ApiOperation({ summary: 'Get maintenance mode settings' })
  async getMaintenance() {
    return this.systemService.getMaintenance();
  }

  @Put('maintenance')
  @ApiOperation({ summary: 'Update maintenance mode settings' })
  async updateMaintenance(@Body() dto: UpdateMaintenanceDto, @Req() req: any) {
    await this.auditLogsService.logAction('UPDATE_MAINTENANCE', 'SystemSetting', 'MAINTENANCE_MODE', req.user.username, dto);
    return this.systemService.updateMaintenance(dto);
  }
}
