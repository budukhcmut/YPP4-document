import 'reflect-metadata';
import { Container, Newable, Scope } from '../core/container';


export function Injectable(option?: { scope?: Scope }) {
  return function (provider: Newable) {
    const scope = option?.scope || Scope.SINGLETON;
    Container.register(provider, scope);
  };
}
