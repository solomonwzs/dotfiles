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

// src/coc-ext-crypto.ts
__markAsModule(exports);
__export(exports, {
  activate: () => activate
});
var import_coc3 = __toModule(require("coc.nvim"));
var import_path4 = __toModule(require("path"));

// src/utils/logger.ts
var import_coc2 = __toModule(require("coc.nvim"));

// src/utils/config.ts
var import_coc = __toModule(require("coc.nvim"));
function getcfg(key, defaultValue) {
  const config = import_coc.workspace.getConfiguration("coc-ext");
  return config.get(key, defaultValue);
}

// src/utils/common.ts
var import_path = __toModule(require("path"));
function stringify(value) {
  if (typeof value === "string") {
    return value;
  } else if (value instanceof String) {
    return value.toString();
  } else {
    return JSON.stringify(value, null, 2);
  }
}

// src/utils/logger.ts
var import_path2 = __toModule(require("path"));
var Logger = class {
  constructor() {
    this.channel = import_coc2.window.createOutputChannel("coc-ext");
    this.detail = getcfg("log.detail", false) === true;
    this.level = getcfg("log.level", 1);
  }
  dispose() {
    return this.channel.dispose();
  }
  logLevel(level, value) {
    var _a;
    const now = new Date();
    const str = stringify(value);
    if (this.detail) {
      const stack = (_a = new Error().stack) == null ? void 0 : _a.split("\n");
      if (stack && stack.length >= 4) {
        const re = /at ((.*) \()?([^:]+):(\d+):(\d+)\)?/g;
        const expl = re.exec(stack[3]);
        if (expl) {
          const file = import_path2.default.basename(expl[3]);
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

// src/utils/externalexec.ts
var import_child_process = __toModule(require("child_process"));
var import_path3 = __toModule(require("path"));
async function call_shell(cmd, argv, input) {
  return new Promise((resolve) => {
    const sh = import_child_process.spawn(cmd, argv, {stdio: ["pipe", "pipe", "pipe"]});
    if (input) {
      sh.stdin.write(input);
      sh.stdin.end();
    }
    let exitCode = 0;
    const data = [];
    const error = [];
    sh.stdout.on("data", (d) => {
      data.push(d);
    });
    sh.stderr.on("data", (d) => {
      error.push(d);
    });
    sh.on("close", (code) => {
      if (code) {
        exitCode = code;
      }
      resolve({
        exitCode,
        data: data.length == 0 ? void 0 : Buffer.concat(data),
        error: error.length == 0 ? void 0 : Buffer.concat(error)
      });
    });
  });
}

// src/coc-ext-crypto.ts
function get_enc_filename(filename) {
  const dir = import_path4.default.dirname(filename);
  const name = import_path4.default.basename(filename);
  return import_path4.default.join(dir, `.${name}.encrypted`);
}
async function encrypt(doc, setting) {
  const exec = setting.openssl ? setting.openssl : "openssl";
  const enc_filename = get_enc_filename(import_coc3.Uri.parse(doc.uri).fsPath);
  const argv = [
    "enc",
    "-e",
    "-aes256",
    "-pbkdf2",
    "-pass",
    `pass:${setting.password}`,
    setting.salt ? "-salt" : "-nosalt",
    "-out",
    enc_filename
  ];
  return call_shell(exec, argv, doc.textDocument.getText());
}
async function decrypt(doc, setting) {
  const exec = setting.openssl ? setting.openssl : "openssl";
  const enc_filename = get_enc_filename(import_coc3.Uri.parse(doc.uri).fsPath);
  const argv = [
    "des",
    "-d",
    "-salt",
    "-aes256",
    "-pbkdf2",
    "-pass",
    `pass:${setting.password}`,
    setting.salt ? "-salt" : "-nosalt",
    "-in",
    enc_filename
  ];
  const res = await call_shell(exec, argv);
  if (res.error != void 0 || res.data == void 0) {
    return false;
  }
  const ed = import_coc3.TextEdit.replace({
    start: {line: 0, character: 0},
    end: {line: doc.lineCount, character: 0}
  }, res.data.toString());
  await doc.applyEdits([ed]);
  return true;
}
async function activate(context) {
  context.logger.info(`coc-ext-crypto works`);
  logger.info(`coc-ext-crypto works`);
  const confpath = import_path4.default.join(import_coc3.workspace.root, ".crypto.json");
  let setting;
  try {
    const content = await import_coc3.workspace.readFile(confpath);
    setting = JSON.parse(content);
  } catch (e) {
    import_coc3.window.showMessage(`open config file ${confpath} fail`);
    return;
  }
  context.subscriptions.push(import_coc3.commands.registerCommand("ext-decrypt", async () => {
    const doc = await import_coc3.workspace.document;
    await decrypt(doc, setting);
  }), import_coc3.events.on("BufWritePost", async (bufnr) => {
    const doc = await import_coc3.workspace.document;
    const res = await encrypt(doc, setting);
    if (res.error) {
      logger.error(res.error);
    }
  }));
}
