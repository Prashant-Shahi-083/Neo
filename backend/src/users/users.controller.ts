import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  UseGuards,
  Request,
  ForbiddenException,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole, AccountStatus } from '../entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api/v1/admin/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Get()
  getAllUsers() {
    return this.usersService.findAll();
  }

  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Post()
  async createUser(@Body() dto: any, @Request() req: any) {
    // Only SUPER_ADMIN can create another ADMIN
    if (dto.role === UserRole.ADMIN && req.user.role !== UserRole.SUPER_ADMIN) {
      throw new ForbiddenException(
        'Only SUPER_ADMIN can create an ADMIN account',
      );
    }

    return this.usersService.create({
      username: dto.username,
      passwordHash: dto.password,
      role: dto.role || UserRole.NORMAL_USER,
      createdBy: req.user.username,
    });
  }

  @Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
  @Put(':id')
  async updateUser(
    @Param('id') id: string,
    @Body() dto: any,
    @Request() req: any,
  ) {
    const targetUser = await this.usersService.findById(id);
    if (!targetUser) throw new ForbiddenException('User not found');

    // Prevent ADMIN from editing SUPER_ADMIN or other ADMINs
    if (
      req.user.role === UserRole.ADMIN &&
      targetUser.role !== UserRole.NORMAL_USER
    ) {
      throw new ForbiddenException('Admins can only manage Normal Users');
    }

    if (
      dto.role &&
      dto.role === UserRole.ADMIN &&
      req.user.role !== UserRole.SUPER_ADMIN
    ) {
      throw new ForbiddenException('Only SUPER_ADMIN can assign ADMIN role');
    }

    return this.usersService.updateUser(id, {
      ...dto,
      updatedBy: req.user.username,
    });
  }
}
