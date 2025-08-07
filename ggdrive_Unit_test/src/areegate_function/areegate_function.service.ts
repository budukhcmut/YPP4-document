import { Injectable } from '@nestjs/common';

@Injectable()
export class AreagateFunctionService {
  performInnerJoin(table1: any[], table2: any[], key1: string, key2: string) {
    return table1
      .filter(t1 => table2.some(t2 => t1[key1] === t2[key2]))
      .map(t1 => {
        const match = table2.find(t2 => t1[key1] === t2[key2]);
        return { ...t1, ...match };
      });
  }

  performLeftJoin(table1: any[], table2: any[], key1: string, key2: string) {
    return table1.map(t1 => {
      const match = table2.find(t2 => t1[key1] === t2[key2]);
      return match ? { ...t1, ...match } : { ...t1 };
    });
  }

  performRightJoin(table1: any[], table2: any[], key1: string, key2: string) {
    return table2.map(t2 => {
      const match = table1.find(t1 => t1[key1] === t2[key2]);
      return match ? { ...match, ...t2 } : { ...t2 };
    });
  }

  performCrossJoin(table1: any[], table2: any[]) {
    return table1.flatMap(t1 =>
      table2.map(t2 => ({
        table1: { ...t1 },
        table2: { ...t2 },
      }))
    );
  }
}