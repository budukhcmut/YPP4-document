// src/core/module_loader.ts
import { Container } from "./container";
import { getModuleMetadata } from "../decorator/module.decorator";

import express, { Request, Response, NextFunction } from "express";
import { getControllerMetadata } from "../decorator/controller/controller.decorator";
import { getRoutes, RouteDefinition } from "../decorator/route/router.decorator";

export class ModuleLoader {
  static initModule(moduleClass: any) {
    const metadata = getModuleMetadata(moduleClass);

    // register providers
    metadata.providers?.forEach((p: any) => Container.register(p));

    // init controllers
    const app = express();
    metadata.controllers?.forEach((controllerClass: any) => {
      const prefix = getControllerMetadata(controllerClass) || "";
      const instance = Container.resolve<any>(controllerClass);



      const routes: RouteDefinition[] = getRoutes(controllerClass);
      routes.forEach((route) => {
        // @ts-ignore
        app[route.requestMethod](
          `${prefix}${route.path}`,
          async (req: Request, res: Response, next: NextFunction) => {
            try {
              const args = ModuleLoader.resolveParams(instance, route.methodName, req, res);
              const result = await instance[route.methodName](...args);
              res.json(result);
            } catch (err) {
              next(err);
            }
          }
        );
      });
    });

    return app;
  }

  private static resolveParams(controllerInstance: any, methodName: string | symbol, req: Request, res: Response) {
    const paramMeta = Reflect.getMetadata('PARAMS_METADATA', controllerInstance, methodName) || [];
    const args: any[] = [];
    paramMeta.forEach((p: any) => {
      switch (p.type) {
        case 'param':
          args[p.index] = req.params[p.key!];
          break;
        case 'query':
          args[p.index] = req.query[p.key!];
          break;
        case 'body':
          args[p.index] = req.body;
          break;
      }
    });
    return args;
  }
}
