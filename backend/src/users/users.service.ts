import {
  Injectable,
  OnModuleInit,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole, AccountStatus } from '../entities/user.entity';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService implements OnModuleInit {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async onModuleInit() {
    await this.seedSuperAdmin();
  }

  private async seedSuperAdmin() {
    const existing = await this.usersRepository.findOne({
      where: { username: 'admin' },
    });
    if (!existing) {
      const passwordHash = await bcrypt.hash('admin123', 10);
      const superAdmin = this.usersRepository.create({
        username: 'admin',
        passwordHash,
        role: UserRole.SUPER_ADMIN,
        accountStatus: AccountStatus.ACTIVE,
      });
      await this.usersRepository.save(superAdmin);
      this.logger.log(
        'Default SUPER_ADMIN seeded (username: admin, password: admin123)',
      );
    }
  }

  async findAll() {
    return this.usersRepository.find({
      select: {
        id: true,
        username: true,
        role: true,
        accountStatus: true,
        lastLogin: true,
        failedLoginAttempts: true,
        createdAt: true,
      },
      order: { createdAt: 'DESC' },
    });
  }

  async findByUsername(username: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { username } });
  }

  async findById(id: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id } });
  }

  async create(user: Partial<User>): Promise<User> {
    if (user.passwordHash && !user.passwordHash.startsWith('$2b$')) {
      user.passwordHash = await bcrypt.hash(user.passwordHash, 10);
    }
    const newUser = this.usersRepository.create(user);
    return this.usersRepository.save(newUser);
  }

  async updateUser(id: string, updateData: Partial<User>) {
    const user = await this.findById(id);
    if (!user) throw new NotFoundException('User not found');

    if (updateData.passwordHash) {
      updateData.passwordHash = await bcrypt.hash(updateData.passwordHash, 10);
      updateData.passwordChangedAt = new Date();
    }

    Object.assign(user, updateData);
    return this.usersRepository.save(user);
  }
}
