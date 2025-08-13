import { Module } from '@nestjs/common';
import { UserfileController } from './userfile.controller';
import { UserfileService } from './userfile.service';

@Module({
  controllers: [UserfileController],
  providers: [UserfileService]
})
export class UserfileModule {}
