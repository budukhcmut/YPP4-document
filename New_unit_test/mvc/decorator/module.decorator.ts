// module.decorator.ts
import "reflect-metadata";

export interface ModuleMetadata {
  controllers?: any[];
  providers?: any[];
  imports?: any[];
}

const MODULE_KEY = Symbol("module");

export function Module(metadata: ModuleMetadata): ClassDecorator {
  return (target: any) => {
    Reflect.defineMetadata(MODULE_KEY, metadata, target);
  };
}

export function getModuleMetadata(target: any): ModuleMetadata {
  return Reflect.getMetadata(MODULE_KEY, target) || {};
}
