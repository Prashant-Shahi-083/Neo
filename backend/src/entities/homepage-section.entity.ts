import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { HomepageItem } from './homepage-item.entity';

export enum SectionType {
  HERO_BANNER = 'HERO_BANNER',
  HORIZONTAL_LIST = 'HORIZONTAL_LIST',
  GRID = 'GRID',
  CAROUSEL = 'CAROUSEL',
}

@Entity('homepage_sections')
export class HomepageSection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'varchar', enum: SectionType })
  type: SectionType;

  @Column({ type: 'int', default: 0 })
  order: number;

  @Column({ default: true })
  isActive: boolean;

  @OneToMany(() => HomepageItem, (item) => item.section, { cascade: true })
  items: HomepageItem[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
