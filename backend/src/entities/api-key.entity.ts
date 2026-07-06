import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum ApiKeyStatus {
  ACTIVE = 'ACTIVE',
  DISABLED = 'DISABLED',
  EXPIRED = 'EXPIRED',
}

@Entity('api_keys')
export class ApiKey {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  keyString: string;

  @Column('simple-array')
  scopes: string[];

  @Column({ nullable: true })
  expires: Date;

  @Column({
    type: 'varchar',
    enum: ApiKeyStatus,
    default: ApiKeyStatus.ACTIVE,
  })
  status: ApiKeyStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
