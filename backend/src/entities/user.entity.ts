import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum UserRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
  ADMIN = 'ADMIN',
  NORMAL_USER = 'NORMAL_USER',
}

export enum AccountStatus {
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  BANNED = 'BANNED',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ nullable: true })
  displayName: string;

  @Column({ unique: true, nullable: true })
  email: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column()
  passwordHash: string;

  @Column({ type: 'varchar', enum: UserRole, default: UserRole.NORMAL_USER })
  role: UserRole;

  @Column({
    type: 'varchar',
    enum: AccountStatus,
    default: AccountStatus.ACTIVE,
  })
  accountStatus: AccountStatus;

  @Column({ nullable: true })
  refreshToken: string;

  @Column({ nullable: true })
  lastLogin: Date;

  @Column({ nullable: true })
  lastActive: Date;

  @Column({ default: 0 })
  failedLoginAttempts: number;

  @Column({ nullable: true })
  passwordChangedAt: Date;

  @Column({ nullable: true })
  createdBy: string;

  @Column({ nullable: true })
  updatedBy: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
