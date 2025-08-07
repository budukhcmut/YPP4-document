import { Controller } from '@nestjs/common';
import { JoinOptions, AreegateFunctionService } from './areegate_function.service';

@Controller('areegate_function')
export class AreegateFunctionController {
  constructor(private readonly queryUtilsService: AreegateFunctionService) {}

  innerJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
    joinOptions: JoinOptions,
  ) {
    return this.AreegateFunctionService.innerJoin(leftTable, rightTable, joinOptions);
  }

  leftJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
    joinOptions: JoinOptions,
  ) {
    return this.AreegateFunctionService.leftJoin(leftTable, rightTable, joinOptions);
  }

  crossJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
  ) {
    return this.AreegateFunctionService.crossJoin(leftTable, rightTable);
  }
}