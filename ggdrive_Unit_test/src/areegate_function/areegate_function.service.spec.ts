import { Test, TestingModule } from '@nestjs/testing';
import { AreagateFunctionService } from './areegate_function.service';

describe('AreagateFunctionService', () => {
  let service: AreagateFunctionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AreagateFunctionService],
    }).compile();

    service = module.get<AreagateFunctionService>(AreagateFunctionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should perform INNER JOIN correctly', () => {
    const table1 = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    const table2 = [{ id: 1, role: 'Admin' }, { id: 3, role: 'Guest' }];
    const result = service.performInnerJoin(table1, table2, 'id', 'id');
    expect(result).toEqual([{ id: 1, name: 'Alice', role: 'Admin' }]);
  });

  it('should perform LEFT JOIN correctly', () => {
    const table1 = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    const table2 = [{ id: 1, role: 'Admin' }, { id: 3, role: 'Guest' }];
    const result = service.performLeftJoin(table1, table2, 'id', 'id');
    expect(result).toEqual([
      { id: 1, name: 'Alice', role: 'Admin' },
      { id: 2, name: 'Bob' },
    ]);
  });

  it('should perform RIGHT JOIN correctly', () => {
    const table1 = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    const table2 = [{ id: 1, role: 'Admin' }, { id: 3, role: 'Guest' }];
    const result = service.performRightJoin(table1, table2, 'id', 'id');
    expect(result).toEqual([
      { id: 1, name: 'Alice', role: 'Admin' },
      { id: 3, role: 'Guest' },
    ]);
  });

  it('should perform CROSS JOIN correctly', () => {
    const table1 = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    const table2 = [{ id: 1, role: 'Admin' }, { id: 3, role: 'Guest' }];
    const result = service.performCrossJoin(table1, table2);
    expect(result).toEqual([
      { table1: { id: 1, name: 'Alice' }, table2: { id: 1, role: 'Admin' } },
      { table1: { id: 1, name: 'Alice' }, table2: { id: 3, role: 'Guest' } },
      { table1: { id: 2, name: 'Bob' }, table2: { id: 1, role: 'Admin' } },
      { table1: { id: 2, name: 'Bob' }, table2: { id: 3, role: 'Guest' } },
    ]);
  });
});