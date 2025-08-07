import { Injectable } from '@nestjs/common';

export interface JoinOptions {
  leftKey: string;
  rightKey: string;
}

@Injectable()
export class AreegateFunctionService {
  innerJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
    joinOptions: JoinOptions,
  ): Record<string, unknown>[] {
    const result: Record<string, unknown>[] = [];

    for (const left of leftTable) {
      for (const right of rightTable) {
        if (left[joinOptions.leftKey] === right[joinOptions.rightKey]) {
          result.push({ ...left, ...right });
        }
      }
    }

    return result;
  }

  leftJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
    joinOptions: JoinOptions,
  ): Record<string, unknown>[] {
    const result: Record<string, unknown>[] = [];

    for (const left of leftTable) {
      let hasMatch: boolean = false;

      for (const right of rightTable) {
        if (left[joinOptions.leftKey] === right[joinOptions.rightKey]) {
          result.push({ ...left, ...right });
          hasMatch = true;
        }
      }

      if (!hasMatch) {
        result.push({ ...left, [joinOptions.rightKey]: null });
      }
    }

    return result;
  }

  crossJoin(
    leftTable: Record<string, unknown>[],
    rightTable: Record<string, unknown>[],
  ) {
    const result: Record<string, unknown>[] = [];

    if (leftTable.length === 0 || rightTable.length === 0) {
      return result;
    }

    for (const left of leftTable) {
      for (const right of rightTable) {
        result.push({ ...left, ...right });
      }
    }

    return result;
  }
}