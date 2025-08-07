import { Controller, Get, Query } from '@nestjs/common';
import { AreagateFunctionService } from './areegate_function.service';

@Controller('areegate-function')
export class AreagateFunctionController {
  constructor(private readonly service: AreagateFunctionService) {}

  @Get('join')
  performJoin(
    @Query('type') type: string,
    @Query('table1') table1: string,
    @Query('table2') table2: string,
    @Query('key1') key1: string,
    @Query('key2') key2: string,
  ) {
    const t1 = JSON.parse(table1);
    const t2 = JSON.parse(table2);
    switch (type.toUpperCase()) {
      case 'INNER':
        return this.service.performInnerJoin(t1, t2, key1, key2);
      case 'LEFT':
        return this.service.performLeftJoin(t1, t2, key1, key2);
      case 'RIGHT':
        return this.service.performRightJoin(t1, t2, key1, key2);
      case 'CROSS':
        return this.service.performCrossJoin(t1, t2);
      default:
        throw new Error('Unsupported join type');
    }
  }
}