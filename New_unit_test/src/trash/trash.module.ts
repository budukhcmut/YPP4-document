import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TrashController } from './trash.controller';
import { TrashService } from './trash.service';
import { TrashRepository } from './trash.repository';
import { Trash } from 'src/entities/trash.entity';
import { Account } from 'src/entities/account.entity';
import { ObjectType } from 'src/entities/objecttype.entity';
import { CacheService } from '../../utils/cache.service';

@Module({
  imports: [TypeOrmModule.forFeature([Trash , Account , ObjectType])],
  controllers: [TrashController],
  providers: [TrashService , TrashRepository , CacheService],
})
export class TrashModule {}
