import { Container } from "../core/container";

const CONTROLLER_METADATA = Symbol('CONTROLLER_METADATA');

export function Controller(prefix: string = ''): ClassDecorator {
  return (target: any) => {
    Reflect.defineMetadata(CONTROLLER_METADATA, prefix, target);
    Container.register(target); 
  };
}

export function getControllerPrefix(target: any): string {
  return Reflect.getMetadata(CONTROLLER_METADATA, target);
}
