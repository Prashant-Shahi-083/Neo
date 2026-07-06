import {
  Entity,
  Column,
  PrimaryColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('system_settings')
export class SystemSetting {
  @PrimaryColumn()
  key: string;

  @Column({ type: 'jsonb' })
  value: any;

  @UpdateDateColumn()
  updatedAt: Date;
}
