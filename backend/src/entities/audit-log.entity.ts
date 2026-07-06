import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity('admin_audit_logs')
export class AuditLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  action: string;

  @Column()
  entityType: string;

  @Column()
  entityId: string;

  @Column()
  adminUsername: string;

  @Column({ type: 'jsonb', nullable: true })
  changes: any;

  @Column({ nullable: true })
  ipAddress: string;

  @Column({ nullable: true })
  device: string;

  @Column({ default: 'SUCCESS' })
  status: string;

  @CreateDateColumn()
  timestamp: Date;
}
