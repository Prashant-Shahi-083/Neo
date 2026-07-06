import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('recommendation_config')
export class RecommendationConfig {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float', default: 1.0 })
  genreWeight: number;

  @Column({ type: 'float', default: 0.8 })
  artistWeight: number;

  @Column({ type: 'float', default: 0.5 })
  tagWeight: number;

  @Column({ type: 'int', default: 100 })
  trendingThresholdPlays: number;

  @UpdateDateColumn()
  updatedAt: Date;
}
