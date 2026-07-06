import { Controller, Get, Post, Body, UseGuards, Req } from '@nestjs/common';
import { ApiKeysService } from './api-keys.service';
import { CreateApiKeyDto } from './dto/create-api-key.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import { AuditLogsService } from '../audit-logs/audit-logs.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Admin - API Keys')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN)
@Controller('api/v1/admin/api-keys')
export class ApiKeysController {
  constructor(
    private readonly apiKeysService: ApiKeysService,
    private readonly auditLogsService: AuditLogsService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all API keys' })
  async findAll() {
    return this.apiKeysService.findAll();
  }

  @Post()
  @ApiOperation({ summary: 'Create a new API key' })
  async create(@Body() createApiKeyDto: CreateApiKeyDto, @Req() req: any) {
    const newKey = await this.apiKeysService.create(createApiKeyDto);
    
    await this.auditLogsService.logAction(
      'CREATE_API_KEY',
      'ApiKey',
      newKey.id,
      req.user.username,
      { name: newKey.name }
    );
    
    return newKey;
  }
}
