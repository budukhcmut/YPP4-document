// router.ts
import express, { Express, Request, Response, NextFunction } from 'express';
import { Container } from './container';
import { getControllerPath, getRoutes, RouteDefinition } from './decorators';

/**
 * Register controllers into an Express app
 * controllers: array of controller classes (constructors)
 */
export function registerControllers(
  app: Express,
  container: Container,
  controllers: any[],
) {
  controllers.forEach((ControllerClass) => {
    const basePath = getControllerPath(ControllerClass) || '';
    // Get instance from container (singleton)
    const controllerInstance = container.resolve(ControllerClass);

    const routes: RouteDefinition[] = getRoutes(ControllerClass);

    routes.forEach((route) => {
      const fullPath = joinPaths(basePath, route.path);

      // verify handler exists
      const handler = (controllerInstance as any)[route.handlerName];
      if (typeof handler !== 'function') {
        throw new Error(
          `Handler ${route.handlerName} not found on controller ${ControllerClass.name}`,
        );
      }

      // wrap handler to inject req/res/next and bind 'this' properly
      const wrapped = async (req: Request, res: Response, next: NextFunction) => {
        try {
          // if handler returns value, send JSON; else if it handled res, do nothing
          const result = await handler.call(controllerInstance, req, res, next);
          if (!res.headersSent && result !== undefined) {
            res.json(result);
          }
        } catch (err) {
          next(err);
        }
      };

      // apply middlewares if any
      const middlewares = route.middlewares ?? [];

      // register route
      (app as any)[route.method](fullPath, ...middlewares, wrapped);
      console.log(`[ROUTE] ${route.method.toUpperCase()} ${fullPath} -> ${ControllerClass.name}.${route.handlerName}`);
    });
  });
}

function joinPaths(a: string, b: string) {
  const pa = a.endsWith('/') ? a.slice(0, -1) : a;
  const pb = b.startsWith('/') ? b : `/${b}`;
  const joined = (pa + pb).replace(/\/+/g, '/');
  return joined === '' ? '/' : joined;
}
