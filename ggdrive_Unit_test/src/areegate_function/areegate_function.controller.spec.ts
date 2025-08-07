import { Test, TestingModule } from '@nestjs/testing';
import { AreagateFunctionController } from './areegate_function.controller';
import { AreagateFunctionService } from './areegate_function.service';

describe('AreagateFunctionController', () => {
  let controller: AreagateFunctionController;
  let service: AreagateFunctionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AreagateFunctionController],
      providers: [AreagateFunctionService], // Sử dụng service thực thay vì mock nếu cần
    }).compile();

    controller = module.get<AreagateFunctionController>(AreagateFunctionController);
    service = module.get<AreagateFunctionService>(AreagateFunctionService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should perform INNER JOIN via controller', () => {
    const table1 = [{ id: 1, name: 'Alice' }];
    const table2 = [{ id: 1, role: 'Admin' }];
    const result = controller.performJoin('INNER', JSON.stringify(table1), JSON.stringify(table2), 'id', 'id');
    expect(result).toEqual([{ id: 1, name: 'Alice', role: 'Admin' }]);
  });

  it('should perform LEFT JOIN via controller', () => {
    const table1 = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }];
    const table2 = [{ id: 1, role: 'Admin' }];
    const result = controller.performJoin('LEFT', JSON.stringify(table1), JSON.stringify(table2), 'id', 'id');
    expect(result).toEqual([
      { id: 1, name: 'Alice', role: 'Admin' },
      { id: 2, name: 'Bob' },
    ]);
  });

  it('should perform RIGHT JOIN via controller', () => {
    const table1 = [{ id: 1, name: 'Alice' }];
    const table2 = [{ id: 1, role: 'Admin' }, { id: 3, role: 'Guest' }];
    const result = controller.performJoin('RIGHT', JSON.stringify(table1), JSON.stringify(table2), 'id', 'id');
    expect(result).toEqual([
      { id: 1, name: 'Alice', role: 'Admin' },
      { id: 3, role: 'Guest' },
    ]);
  });

  it('should perform CROSS JOIN via controller', () => {
    const table1 = [{ id: 1, name: 'Alice' }];
    const table2 = [{ id: 1, role: 'Admin' }];
    const result = controller.performJoin('CROSS', JSON.stringify(table1), JSON.stringify(table2), 'id', 'id');
    expect(result).toEqual([{ table1: { id: 1, name: 'Alice' }, table2: { id: 1, role: 'Admin' } }]);
  });
});