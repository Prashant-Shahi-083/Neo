import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';

@Entity('search_queries')
export class SearchQuery {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  term: string;

  @Column({ type: 'int', default: 0 })
  resultCount: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata: any; // Could store device, user type, etc.

  @CreateDateColumn()
  createdAt: Date;
}
