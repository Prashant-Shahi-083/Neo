import { Controller, Patch, Body, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DtoMapper } from '../shared/dto-mapper';

@Controller('api/v1/users')
export class PublicUsersController {
  constructor(private readonly usersService: UsersService) {}

  @UseGuards(JwtAuthGuard)
  @Patch('profile')
  async updateProfile(@Body() dto: any, @Request() req: any) {
    const updatedUser = await this.usersService.updateUser(req.user.sub, dto);
    return DtoMapper.toUserProfile(updatedUser);
  }
}
