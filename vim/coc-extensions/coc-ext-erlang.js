var __create = Object.create;
var __defProp = Object.defineProperty;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __markAsModule = (target) => __defProp(target, "__esModule", {value: true});
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, {get: all[name], enumerable: true});
};
var __exportStar = (target, module2, desc) => {
  if (module2 && typeof module2 === "object" || typeof module2 === "function") {
    for (let key of __getOwnPropNames(module2))
      if (!__hasOwnProp.call(target, key) && key !== "default")
        __defProp(target, key, {get: () => module2[key], enumerable: !(desc = __getOwnPropDesc(module2, key)) || desc.enumerable});
  }
  return target;
};
var __toModule = (module2) => {
  if (module2 && module2.__esModule)
    return module2;
  return __exportStar(__markAsModule(__defProp(module2 != null ? __create(__getProtoOf(module2)) : {}, "default", {value: module2, enumerable: true})), module2);
};

// src/coc-erlangls.ts
__markAsModule(exports);
__export(exports, {
  activate: () => activate
});
var import_coc3 = __toModule(require("coc.nvim"));

// src/utils/logger.ts
var import_coc2 = __toModule(require("coc.nvim"));

// src/utils/config.ts
var import_coc = __toModule(require("coc.nvim"));
function getcfg(key, defaultValue) {
  const config = import_coc.workspace.getConfiguration("coc-solomon-ext");
  return defaultValue === void 0 ? config.get(key) : config.get(key, defaultValue);
}

// src/utils/logger.ts
var import_path = __toModule(require("path"));
var Logger = class {
  constructor() {
    this.channel = import_coc2.window.createOutputChannel("coc-solomon-ext");
    this.detail = getcfg("log.detail") === true;
    const level = getcfg("log.level");
    if (level !== void 0) {
      this.level = level;
    } else {
      this.level = 1;
    }
  }
  dispose() {
    return this.channel.dispose();
  }
  logLevel(level, value) {
    var _a;
    const now = new Date();
    let str;
    if (typeof value === "string") {
      str = value;
    } else if (value instanceof String) {
      str = value.toString();
    } else {
      str = JSON.stringify(value, null, 2);
    }
    if (this.detail) {
      const stack = (_a = new Error().stack) == null ? void 0 : _a.split("\n");
      if (stack && stack.length >= 4) {
        const re = /at ((.*) \()?([^:]+):(\d+):(\d+)\)?/g;
        const expl = re.exec(stack[3]);
        if (expl) {
          const file = import_path.default.basename(expl[3]);
          const line = expl[4];
          this.channel.appendLine(`${now.toISOString()} ${level} [${file}:${line}] ${str}`);
          return;
        }
      }
    }
    this.channel.appendLine(`${now.toISOString()} ${level} ${str}`);
  }
  debug(value) {
    if (this.level > 0) {
      return;
    }
    this.logLevel("D", value);
  }
  info(value) {
    if (this.level > 1) {
      return;
    }
    this.logLevel("I", value);
  }
  warn(value) {
    if (this.level > 2) {
      return;
    }
    this.logLevel("W", value);
  }
  error(message) {
    this.logLevel("E", message);
  }
};
var logger = new Logger();

// src/coc-erlangls.ts
var client;
async function activate(context) {
  context.logger.info(`coc-erlangls works`);
  logger.info(`coc-erlangls works`);
  logger.info(import_coc3.workspace.getConfiguration("erlang_ls"));
  const config = import_coc3.workspace.getConfiguration("erlang_ls");
  const server_path = config.get("erlang_ls_path", "/bin/erlang_ls");
  const clientOptions = {
    documentSelector: [{scheme: "file", language: "erlang"}],
    initializationOptions: ""
  };
  const serverArgs = ["--transport", "stdio"];
  const serverOptions = {
    command: server_path,
    args: serverArgs,
    transport: import_coc3.TransportKind.stdio
  };
  client = new import_coc3.LanguageClient("erlang_ls", serverOptions, clientOptions);
  client.start();
  client.onReady().then(() => {
    import_coc3.window.showMessage(`coc-erlangls is ready`);
  });
}
