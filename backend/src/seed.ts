import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { UsersService } from './users/users.service';
import { UserRole, AccountStatus } from './entities/user.entity';
import * as bcrypt from 'bcrypt';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const usersService = app.get(UsersService);

  const username = process.env.ADMIN_USERNAME || 'admin';
  const password = process.env.ADMIN_PASSWORD || 'Admin@123';
  const passwordHash = await bcrypt.hash(password, 10);

  const existing = await usersService.findByUsername(username);
  if (!existing) {
    await usersService.create({
      username,
      passwordHash,
      role: UserRole.SUPER_ADMIN,
      accountStatus: AccountStatus.ACTIVE,
    });
    console.log(
      `[Seed] Created new SUPER_ADMIN user: "${username}" with password: "${password}"`,
    );
  } else {
    existing.passwordHash = passwordHash;
    existing.role = UserRole.SUPER_ADMIN;
    existing.accountStatus = AccountStatus.ACTIVE;
    await usersService.create(existing);
    console.log(
      `[Seed] Successfully reset password and privileges for existing SUPER_ADMIN user: "${username}" to password: "${password}"`,
    );
  }

  await app.close();
}

bootstrap();
