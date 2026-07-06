import { Injectable, UnauthorizedException } from '@nestjs/common';
import { DtoMapper } from '../shared/dto-mapper';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User, AccountStatus } from '../entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(username: string, pass: string): Promise<any> {
    const user = await this.usersService.findByUsername(username);
    if (!user) return null;

    if (user.accountStatus !== AccountStatus.ACTIVE) {
      throw new UnauthorizedException('Account is not active.');
    }

    const isMatch = await bcrypt.compare(pass, user.passwordHash);
    if (isMatch) {
      const { passwordHash, refreshToken, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { username: user.username, sub: user.id, role: user.role };
    const accessToken = this.jwtService.sign(payload);

    // Generate Refresh Token
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    // Save refresh token to user
    const userEntity = await this.usersService.findById(user.id);
    if (userEntity) {
      userEntity.refreshToken = refreshToken;
      userEntity.lastLogin = new Date();
      await this.usersService.create(userEntity); // save() equivalent
    }

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
      role: user.role,
    };
  }

  async refresh(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken);
      const user = await this.usersService.findById(payload.sub);

      if (
        !user ||
        user.refreshToken !== refreshToken ||
        user.accountStatus !== AccountStatus.ACTIVE
      ) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      const newPayload = {
        username: user.username,
        sub: user.id,
        role: user.role,
      };
      const newAccessToken = this.jwtService.sign(newPayload);
      const newRefreshToken = this.jwtService.sign(newPayload, {
        expiresIn: '7d',
      });

      user.refreshToken = newRefreshToken;
      await this.usersService.create(user);

      return {
        access_token: newAccessToken,
        refresh_token: newRefreshToken,
        role: user.role,
      };
    } catch (e) {
      throw new UnauthorizedException('Token expired or invalid');
    }
  }

  async getProfile(userId: string) {
    const user = await this.usersService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return DtoMapper.toUserProfile(user);
  }

  async logout(userId: string) {
    const user = await this.usersService.findById(userId);
    if (user) {
      user.refreshToken = '';
      await this.usersService.create(user);
    }
    return { success: true };
  }
}
