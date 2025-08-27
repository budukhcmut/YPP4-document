// router.ts
import { IncomingMessage, ServerResponse } from "http";
import { parse } from "url";
import "reflect-metadata";
import { Container } from "./container";
import { getControllerPrefix } from "../decorator/controller.decorator";
import { getRoutes, RouteDefinition } from "../decorator/router.decorator";

interface RouteHandler {
  method: string;
  path: string;
  handler: Function;
  controllerInstance: any;
  handlerName : string |symbol ;
  paramNames: string[]; // lưu các param dynamic :id, :userId ...
}

export class Router {
  private routes: RouteHandler[] = [];

  registerController(controllerClass: any) {  
    const prefix = getControllerPrefix(controllerClass);
    const routes: RouteDefinition[] = getRoutes(controllerClass);
    const controllerInstance = Container.get(controllerClass);

    for (const route of routes) {
      const fullPath = `${prefix}${route.path}`;
      const paramNames = fullPath
        .split("/")
        .filter((p) => p.startsWith(":"))
        .map((p) => p.slice(1)); // get param name 

      this.routes.push({
        method: route.method.toUpperCase(),
        path: fullPath,
        handler: (controllerInstance as any)[route.handlerName].bind(controllerInstance),
        controllerInstance,
        handlerName: route.handlerName,
        paramNames,
      });
    }
  }

  async handler(req: IncomingMessage, res: ServerResponse) {
    const parsedUrl = parse(req.url || "", true);
    const pathname = parsedUrl.pathname || "/";
    const method = req.method?.toUpperCase() || "";

    const route = this.routes.find((r) => r.method === method && this.matchPath(r.path, pathname));
    if (!route) {
      res.statusCode = 404;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ message: "Not Found" }));
      return;
    }

    // parse body JSON
    let bodyData = "";
    await new Promise<void>((resolve) => {
      req.on("data", (chunk) => (bodyData += chunk));
      req.on("end", () => resolve());
    });

    let body: any = {};
    try {
      if (bodyData) body = JSON.parse(bodyData);
    } catch {
      body = {};
    }

    // build args from metadata
    const paramsMeta: any[] =
      Reflect.getMetadata("params", route.controllerInstance, route.handlerName) || [];
    const args: any[] = [];

    const urlParts = pathname.split("/").filter(Boolean);
    const routeParts = route.path.split("/").filter(Boolean);

    for (const meta of paramsMeta) {
      switch (meta.type) {
        case "param": {
          const idx = routeParts.findIndex((p) => p === `:${meta.name}`);
          args[meta.index] = idx !== -1 ? urlParts[idx] : undefined;
          break;
        }
        case "query":
          args[meta.index] = meta.name ? parsedUrl.query[meta.name] : parsedUrl.query;
          break;
        case "body":
          args[meta.index] = meta.name ? body[meta.name] : body;
          break;
      }
    }

    try {
      const result = await route.handler(...args);

      res.statusCode = 200;
      
      // POST deafault return 201
      if (method === "POST") res.statusCode = 201;

      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(result));
    } catch (err: any) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ message: err.message || "Internal Server Error" }));
    }
  }

  // match route with param dynamic
  private matchPath(routePath: string, actualPath: string): boolean {
    const routeParts = routePath.split("/").filter(Boolean);
    const actualParts = actualPath.split("/").filter(Boolean);

    if (routeParts.length !== actualParts.length) return false;

    return routeParts.every((part, i) => part.startsWith(":") || part === actualParts[i]);
  }
}
