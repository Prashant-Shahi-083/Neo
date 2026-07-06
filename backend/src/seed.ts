import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { UsersService } from './users/users.service';
import { UserRole } from './entities/user.entity';
import * as bcrypt from 'bcrypt';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const usersService = app.get(UsersService);

  const existing = await usersService.findByUsername('admin');
  if (!existing) {
    const passwordHash = await bcrypt.hash('password123', 10);
    await usersService.create({
      username: 'admin',
      passwordHash: passwordHash,
      role: UserRole.SUPER_ADMIN,
    });
    console.log('Created admin user.');
  } else {
    console.log('Admin user already exists.');
  }

  await app.close();
}

bootstrap();
