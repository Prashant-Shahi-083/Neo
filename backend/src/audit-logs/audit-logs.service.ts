import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../entities/audit-log.entity';

@Injectable()
export class AuditLogsService {
  constructor(
    @InjectRepository(AuditLog)
    private readonly auditLogRepo: Repository<AuditLog>,
  ) {}

  async logAction(
    action: string,
    entityType: string,
    entityId: string,
    adminUsername: string,
    changes?: any,
  ) {
    const log = this.auditLogRepo.create({
      action,
      entityType,
      entityId,
      adminUsername,
      changes,
    });
    await this.auditLogRepo.save(log);
  }

  async getAllLogs() {
    return this.auditLogRepo.find({
      order: { timestamp: 'DESC' },
      take: 100, // Limit for performance
    });
  }
}
