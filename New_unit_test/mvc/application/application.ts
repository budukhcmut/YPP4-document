// application.ts

import { Container } from "../core/container";
import { Router } from "../core/router";
import { getModuleMetadata } from "../decorator/module.decorator";


export class Application {
  private router = new Router();

  constructor(private rootModule: any) {}

  init() {
    this.loadModule(this.rootModule);
  }

  private loadModule(moduleClass: any) {
    const metadata = getModuleMetadata(moduleClass);

    // Register providers in Container
    metadata.providers?.forEach((provider) => {
      Container.set(provider, new provider());
    });

    // Register controllers in Router
    metadata.controllers?.forEach((controller) => {
      this.router.registerController(controller);
    });

    //  load imports
    metadata.imports?.forEach((m) => this.loadModule(m));
  }

  getRouter() {
    return this.router;
  }
}
