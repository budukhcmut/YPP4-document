import 'reflect-metadata';

const PARAMS_METADATA = Symbol('PARAMS_METADATA');

export type ParamSource = 'param' | 'query' | 'body';

export interface ParamDefinition {
  index: number;
  type: ParamSource;
  key? : string ;
}

function createParamDecorator(type: ParamSource) {
  return (key?: string): ParameterDecorator => {
    return (target, propertyKey, parameterIndex) => {
      const existingParams: ParamDefinition[] =
        Reflect.getMetadata(PARAMS_METADATA, target, propertyKey!) || [];

      existingParams.push({ index: parameterIndex, type, key });
      Reflect.defineMetadata(PARAMS_METADATA, existingParams, target, propertyKey!);
    };
  };
}

export const Param = createParamDecorator('param');
export const Query = createParamDecorator('query');
export const Body = createParamDecorator('body');

// helper
export function getParamsMetadata(target: any, propertyKey: string | symbol): ParamDefinition[] {
  return Reflect.getMetadata(PARAMS_METADATA, target, propertyKey) || [];
}
