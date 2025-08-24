import 'reflect-metadata';
import { Container, Injectable, container } from './index';

@Injectable()
class DefaultService {
  getValue(): string {
    return 'default-value';
  }
}

@Injectable()
class DependentService {
  constructor(private defaultService: DefaultService) {}

  getDependentValue(): string {
    return `dependent-${this.defaultService.getValue()}`;
  }
}

describe('Dependency Injection Container (Singleton Only)', () => {
  beforeEach(() => {
    container.clear();

    Container.register(DefaultService);
    Container.register(DependentService);
  });

  describe('Container.register', () => {
    it('should register a service as SINGLETON by default', () => {
      class NewService {}
      Container.register(NewService);

      expect(container.has(NewService)).toBe(true);
    });
  });

  describe('Container.resolve', () => {
    it('should resolve SINGLETON service and return same instance', () => {
      const instance1 = Container.resolve(DefaultService);
      const instance2 = Container.resolve(DefaultService);

      expect(instance1).toBe(instance2);
      expect(instance1.getValue()).toBe('default-value');
    });

    it('should resolve service with dependencies', () => {
      const dependentInstance = Container.resolve(DependentService);

      expect(dependentInstance.getDependentValue()).toBe(
        'dependent-default-value',
      );
    });

    it('should throw error when trying to resolve unregistered service', () => {
      class UnregisteredService {}

      expect(() => Container.resolve(UnregisteredService)).toThrow();
    });
  });
});
