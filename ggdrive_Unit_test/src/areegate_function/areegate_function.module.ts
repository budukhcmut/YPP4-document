import { Module } from '@nestjs/common';
import { AreagateFunctionService } from './areegate_function.service';
import { AreagateFunctionController } from './areegate_function.controller';

@Module({
  providers: [AreagateFunctionService],
  controllers: [AreagateFunctionController],
})
export class AreegateFunctionModule {}