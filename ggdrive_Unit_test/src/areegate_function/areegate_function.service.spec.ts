import { Test, TestingModule } from '@nestjs/testing';
import { AreegateFunctionService } from './areegate_function.service';

describe('AreegateFunctionService', () => {
  let service: AreegateFunctionService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [AreegateFunctionService],
    }).compile();

    service = module.get<AreegateFunctionService>(AreegateFunctionService);
  });

  const leftTable: Record<string, unknown>[] = [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' },
    { id: 3, name: 'Charlie' },
  ];

  const rightTable: Record<string, unknown>[] = [
    { userId: 1, city: 'New York' },
    { userId: 2, city: 'London' },
    { userId: 4, city: 'Paris' },
  ];

  const joinOptions: { leftKey: string; rightKey: string } = {
    leftKey: 'id',
    rightKey: 'userId',
  };

  describe('innerJoin', () => {
    it('should return joined records based on matching keys', () => {
      const result = service.innerJoin(leftTable, rightTable, joinOptions);
      expect(result).toEqual([
        { id: 1, name: 'Alice', userId: 1, city: 'New York' },
        { id: 2, name: 'Bob', userId: 2, city: 'London' },
      ]);
    });

    it('should return an empty array if no matches are found', () => {
      const leftTable: Record<string, unknown>[] = [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ];
      const rightTable: Record<string, unknown>[] = [
        { userId: 3, city: 'Paris' },
        { userId: 4, city: 'Berlin' },
      ];
      const joinOptions = { leftKey: 'id', rightKey: 'userId' };

      const result = service.innerJoin(leftTable, rightTable, joinOptions);
      expect(result).toEqual([]);
    });

    it('should return an empty array if either table is empty', () => {
      const result = service.innerJoin([], rightTable, joinOptions);
      expect(result).toEqual([]);
    });
  });

  describe('leftJoin', () => {
    it('should return all records from left table and matched records from right table', () => {
      const result = service.leftJoin(leftTable, rightTable, joinOptions);
      expect(result).toEqual([
        { id: 1, name: 'Alice', userId: 1, city: 'New York' },
        { id: 2, name: 'Bob', userId: 2, city: 'London' },
        { id: 3, name: 'Charlie', userId: null },
      ]);
    });

    it('should return all left table records if right table is empty', () => {
      const result = service.leftJoin(leftTable, [], joinOptions);
      expect(result).toEqual([
        { id: 1, name: 'Alice', userId: null },
        { id: 2, name: 'Bob', userId: null },
        { id: 3, name: 'Charlie', userId: null },
      ]);
    });

    it('should return empty array if left table is empty', () => {
      const result = service.leftJoin([], rightTable, joinOptions);
      expect(result).toEqual([]);
    });
  });

  describe('crossJoin', () => {
    it('should return all combinations of records from both tables', () => {
      const result = service.crossJoin(leftTable, rightTable);
      expect(result).toEqual([
        { id: 1, name: 'Alice', userId: 1, city: 'New York' },
        { id: 1, name: 'Alice', userId: 2, city: 'London' },
        { id: 1, name: 'Alice', userId: 4, city: 'Paris' },
        { id: 2, name: 'Bob', userId: 1, city: 'New York' },
        { id: 2, name: 'Bob', userId: 2, city: 'London' },
        { id: 2, name: 'Bob', userId: 4, city: 'Paris' },
        { id: 3, name: 'Charlie', userId: 1, city: 'New York' },
        { id: 3, name: 'Charlie', userId: 2, city: 'London' },
        { id: 3, name: 'Charlie', userId: 4, city: 'Paris' },
      ]);
    });

    it('should return an empty array if either table is empty', () => {
      const result = service.crossJoin([], rightTable);
      expect(result).toEqual([]);
      const result2 = service.crossJoin(leftTable, []);
      expect(result2).toEqual([]);
    });

    it('should return an empty array if both tables are empty', () => {
      const result = service.crossJoin([], []);
      expect(result).toEqual([]);
    });
  });
});