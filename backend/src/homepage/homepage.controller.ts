import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { UserRole } from '../entities/user.entity';
import {
  Controller,
  UseGuards as ExistingUseGuards,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
} from '@nestjs/common';
import { HomepageService } from './homepage.service';
import {
  CreateSectionDto,
  UpdateSectionDto,
  ReorderDto,
} from './dto/section.dto';
import { AddItemDto } from './dto/item.dto';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SUPER_ADMIN, UserRole.ADMIN)
@Controller('api/v1/admin/homepage')
export class HomepageController {
  constructor(private readonly homepageService: HomepageService) {}

  @Get()
  findAll() {
    return this.homepageService.findAll();
  }

  @Post('sections')
  createSection(@Body() dto: CreateSectionDto) {
    return this.homepageService.createSection(dto);
  }

  @Put('sections/reorder')
  reorderSections(@Body() dto: ReorderDto) {
    return this.homepageService.reorderSections(dto);
  }

  @Put('sections/:id')
  updateSection(@Param('id') id: string, @Body() dto: UpdateSectionDto) {
    return this.homepageService.updateSection(id, dto);
  }

  @Delete('sections/:id')
  deleteSection(@Param('id') id: string) {
    return this.homepageService.deleteSection(id);
  }

  // ITEMS

  @Post('sections/:id/items')
  addItem(@Param('id') id: string, @Body() dto: AddItemDto) {
    return this.homepageService.addItem(id, dto);
  }

  @Put('sections/:id/items/reorder')
  reorderItems(@Param('id') id: string, @Body() dto: ReorderDto) {
    return this.homepageService.reorderItems(id, dto);
  }

  @Delete('sections/:id/items/:itemId')
  removeItem(@Param('id') id: string, @Param('itemId') itemId: string) {
    return this.homepageService.removeItem(id, itemId);
  }
}
