import { Module } from '@nestjs/common';
import { AreegateFunctionService } from './areegate_function.service';
import { AreegateFunctionController } from './areegate_function.controller';

@Module({
  controllers: [AreegateFunctionController],
  providers: [AreegateFunctionService],
})
export class AreegateFunctionModule {}