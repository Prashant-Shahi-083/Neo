import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ApiKey } from '../entities/api-key.entity';
import { CreateApiKeyDto } from './dto/create-api-key.dto';
import * as crypto from 'crypto';

@Injectable()
export class ApiKeysService {
  constructor(
    @InjectRepository(ApiKey)
    private readonly apiKeyRepo: Repository<ApiKey>,
  ) {}

  async findAll() {
    return this.apiKeyRepo.find({
      order: { createdAt: 'DESC' },
    });
  }

  async create(dto: CreateApiKeyDto) {
    // Generate a secure API key
    const rawKey = crypto.randomBytes(32).toString('hex');
    const prefix = 'neo_';
    const keyString = `${prefix}${rawKey}`;

    const newKey = this.apiKeyRepo.create({
      name: dto.name,
      scopes: dto.scopes,
      keyString: keyString, // Storing raw for MVP copy capability
    });

    return this.apiKeyRepo.save(newKey);
  }
}
