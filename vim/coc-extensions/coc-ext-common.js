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

// src/coc-ext-common.ts
__markAsModule(exports);
__export(exports, {
  activate: () => activate
});
var import_coc11 = __toModule(require("coc.nvim"));

// src/lists/lists.ts
var import_coc = __toModule(require("coc.nvim"));
var ExtList = class extends import_coc.BasicList {
  constructor(nvim) {
    super(nvim);
    this.name = "ext_list";
    this.description = "CocList for coc-ext-common";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", (item) => {
      import_coc.window.showMessage(`${item.label}, ${item.data.name}`);
    });
  }
  async loadItems(context) {
    return [
      {
        label: "coc-ext-common list item 1",
        data: {name: "list item 1"}
      },
      {
        label: "coc-ext-common list item 2",
        data: {name: "list item 2"}
      }
    ];
  }
};
var lists_default = ExtList;

// src/lists/commands.ts
var import_coc2 = __toModule(require("coc.nvim"));
var CommandsList = class extends import_coc2.BasicList {
  constructor(nvim) {
    super(nvim);
    this.name = "cmd_list";
    this.description = "CocList for coc-ext-common (commands)";
    this.defaultAction = "execute";
    this.actions = [];
  }
  async loadItems(context) {
    const {nvim} = this;
    let list = await nvim.eval('split(execute("command"),"\n")');
    list = list.slice(1);
    return [];
  }
};
var commands_default = CommandsList;

// src/translators/base.ts
function createTranslation(name, sl, tl, text) {
  return {
    engine: name,
    sl,
    tl,
    text,
    explains: [],
    paraphrase: "",
    phonetic: ""
  };
}

// src/utils/logger.ts
var import_coc4 = __toModule(require("coc.nvim"));

// src/utils/config.ts
var import_coc3 = __toModule(require("coc.nvim"));
function getcfg(key, defaultValue) {
  const config = import_coc3.workspace.getConfiguration("coc-ext");
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
    this.channel = import_coc4.window.createOutputChannel("coc-ext");
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

// src/utils/http.ts
var import_https = __toModule(require("https"));
async function simple_https_request(opts, data) {
  return new Promise((resolve) => {
    const req = import_https.default.request(opts, (resp) => {
      const buf = [];
      resp.on("data", (chunk) => {
        buf.push(chunk);
      });
      resp.on("end", () => {
        resolve({
          statusCode: resp.statusCode,
          data: Buffer.concat(buf),
          error: void 0
        });
      });
    }).on("error", (err) => {
      resolve({
        statusCode: void 0,
        data: void 0,
        error: err
      });
    });
    if (data) {
      req.write(data);
    }
    req.end();
  });
}

// src/translators/google.ts
function getParaphrase(obj) {
  const paraphrase = [];
  const dict = obj["dict"];
  if (dict) {
    for (const i of dict) {
      const pos = i["pos"];
      const terms = i["terms"].join(", ");
      paraphrase.push(`${pos}: ${terms}`);
    }
  } else {
    for (const i of obj["sentences"]) {
      paraphrase.push(i["trans"]);
    }
  }
  return paraphrase.join("\n");
}
async function google_translate(text, sl, tl) {
  const host = "translate.googleapis.com";
  const opts = {
    hostname: host,
    path: `/translate_a/single?client=gtx&sl=auto&tl=${tl}&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dj=1&q=${encodeURIComponent(text)}`,
    method: "GET",
    timeout: 1e3,
    headers: {
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
    }
  };
  const resp = await simple_https_request(opts);
  if (resp.error) {
    logger.error(resp.error.message);
    return null;
  }
  if (!resp.data || resp.statusCode != 200) {
    logger.error(`status: ${resp.statusCode}`);
    return null;
  }
  const obj = JSON.parse(resp.data.toString());
  if (!obj) {
    return null;
  }
  const ret = createTranslation("Google", sl, tl, text);
  ret.paraphrase = getParaphrase(obj);
  return ret;
}

// src/translators/bing.ts
function getParaphrase2(html) {
  const re = /<span class="ht_pos">(.*?)<\/span><span class="ht_trs">(.*?)<\/span>/g;
  let expl = re.exec(html);
  const paraphrase = [];
  while (expl) {
    paraphrase.push(`${expl[1]} ${expl[2]} `);
    expl = re.exec(html);
  }
  return paraphrase.join("\n");
}
async function bing_translate(text, sl, tl) {
  const opts = {
    hostname: "cn.bing.com",
    path: `/dict/SerpHoverTrans?q=${encodeURIComponent(text)}`,
    method: "GET",
    timeout: 1e3,
    headers: {
      Host: "cn.bing.com",
      Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language": "en-US,en;q=0.5"
    }
  };
  const resp = await simple_https_request(opts);
  if (resp.error) {
    logger.error(resp.error.message);
    return null;
  }
  if (!resp.data) {
    return null;
  }
  const ret = createTranslation("Bing", sl, tl, text);
  ret.paraphrase = getParaphrase2(resp.data.toString());
  return ret;
}

// src/utils/helper.ts
var import_coc5 = __toModule(require("coc.nvim"));
var import_path3 = __toModule(require("path"));
var import_util = __toModule(require("util"));
var import_fs = __toModule(require("fs"));
function defauleFloatWinConfig() {
  return {
    autoHide: true,
    border: getcfg("window.enableBorder", false) ? [1, 1, 1, 1] : [0, 0, 0, 0],
    close: false,
    maxHeight: getcfg("window.maxHeight", void 0),
    maxWidth: getcfg("window.maxWidth", void 0)
  };
}
async function getText(mode) {
  const doc = await import_coc5.workspace.document;
  let range = null;
  if (mode === "v") {
    const text2 = (await import_coc5.workspace.nvim.call("lib#common#visual_selection", 1)).toString();
    return text2.trim();
  } else {
    const pos = await import_coc5.window.getCursorPosition();
    range = doc.getWordRangeAtPosition(pos);
  }
  let text = "";
  if (!range) {
    text = (await import_coc5.workspace.nvim.eval('expand("<cword>")')).toString();
  } else {
    text = doc.textDocument.getText(range);
  }
  return text.trim();
}
async function popup(content, filetype, cfg) {
  if (content.length == 0) {
    return;
  }
  if (!filetype) {
    filetype = "text";
  }
  if (!cfg) {
    cfg = defauleFloatWinConfig();
  }
  const doc = [
    {
      content,
      filetype
    }
  ];
  const win = new import_coc5.FloatFactory(import_coc5.workspace.nvim);
  await win.show(doc, cfg);
}
function fnvHash(data, seed = 0) {
  const fnvPrime = BigInt(2166136261);
  let hash = BigInt(seed);
  const func = function(x) {
    hash = BigInt.asUintN(32, hash * fnvPrime);
    hash ^= BigInt(x);
  };
  if (typeof data === "string") {
    const enc = new import_util.TextEncoder();
    const bytes = enc.encode(data);
    bytes.forEach(func);
  } else if (data instanceof String) {
    const enc = new import_util.TextEncoder();
    const bytes = enc.encode(data.toString());
    bytes.forEach(func);
  } else {
    data.forEach(function(x) {
      hash = BigInt.asUintN(32, hash * fnvPrime);
      hash ^= BigInt(x);
    });
  }
  return Number(hash);
}
function getTempFileWithDocumentContents(document) {
  return new Promise((resolve, reject) => {
    const fsPath = import_coc5.Uri.parse(document.uri).fsPath;
    const ext = import_path3.default.extname(fsPath);
    const fileName = `${fsPath}.${fnvHash(document.uri)}${ext}`;
    import_fs.default.writeFile(fileName, document.getText(), (ex) => {
      if (ex) {
        reject(new Error(`Failed to create a temporary file, ${ex.message}`));
      }
      resolve(fileName);
    });
  });
}

// src/utils/decoder.ts
var import_util2 = __toModule(require("util"));
function decode_mime_encode_str(str) {
  const re = /=\?(.+?)\?([BbQq])\?(.+?)\?=/g;
  const res = [];
  let expl = re.exec(str);
  while (expl) {
    res.push(expl);
    expl = re.exec(str);
  }
  if (res.length == 0) {
    return "";
  }
  const list = [];
  for (const s of res) {
    const charset2 = s[1];
    const encoding = s[2];
    const text2 = s[3];
    if (encoding === "B" || encoding === "b") {
      list.push([charset2, Buffer.from(text2, "base64")]);
    } else {
      const buf2 = [];
      const re0 = /(=[A-F0-9]{2}|.)/g;
      let expl2 = re0.exec(text2);
      while (expl2) {
        if (expl2[1].length == 3) {
          buf2.push(parseInt(expl2[1].slice(1), 16));
        } else {
          buf2.push(expl2[1].charCodeAt(0));
        }
        expl2 = re0.exec(text2);
      }
      list.push([charset2, Buffer.from(buf2)]);
    }
  }
  if (list.length == 0) {
    return "";
  }
  let charset = list[0][0];
  let buf = list[0][1];
  let text = "";
  for (const i of list.slice(1)) {
    if (i[0] === charset) {
      buf = Buffer.concat([buf, i[1]]);
    } else {
      const decoder2 = new import_util2.TextDecoder(charset);
      text += decoder2.decode(buf);
      charset = i[0];
      buf = i[1];
    }
  }
  const decoder = new import_util2.TextDecoder(charset);
  text += decoder.decode(buf);
  return text;
}

// src/utils/externalexec.ts
var import_child_process = __toModule(require("child_process"));
var import_path4 = __toModule(require("path"));
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
async function call_python(module2, func, argv) {
  return new Promise((resolve) => {
    const msg = JSON.stringify({
      module: module2,
      func,
      argv
    });
    let root_dir = process.env.COC_VIMCONFIG;
    if (!root_dir) {
      root_dir = ".";
    }
    const script = import_path4.default.join(root_dir, "pythonx", "coc-ext.py");
    const py = import_child_process.spawn("python3", [script], {stdio: ["pipe", "pipe", "pipe"]});
    py.stdin.write(msg);
    py.stdin.end();
    let exitCode = 0;
    const data = [];
    const error = [];
    py.stdout.on("data", (d) => {
      data.push(d);
    });
    py.stderr.on("data", (d) => {
      error.push(d);
    });
    py.on("close", (code) => {
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

// src/formatter/formatprovider.ts
var import_coc10 = __toModule(require("coc.nvim"));

// src/formatter/clfformatter.ts
var import_coc6 = __toModule(require("coc.nvim"));

// src/formatter/baseformatter.ts
var BaseFormatter = class {
  constructor(s) {
    this.s = s;
    this.setting = s;
  }
};

// src/formatter/clfformatter.ts
var ClfFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
  }
  supportRangeFormat() {
    return false;
  }
  async formatDocument(document, options, _token, range) {
    if (range) {
      return [];
    }
    const filepath = import_coc6.Uri.parse(document.uri).fsPath;
    const setting = {};
    if (this.setting.clangFormStyle) {
      for (const k in this.setting.clangFormStyle) {
        setting[k] = this.setting.clangFormStyle[k];
      }
    }
    if (options.tabSize !== void 0 && !setting["IndentWidth"]) {
      setting["IndentWidth"] = options.tabSize.toString();
    }
    if (options.insertSpaces !== void 0 && !setting["UseTab"]) {
      setting["UseTab"] = options.insertSpaces ? "false" : "true";
    }
    if (!setting["BasedOnStyle"]) {
      setting["BasedOnStyle"] = "Google";
    }
    const argv = [
      "-style",
      JSON.stringify(setting),
      "--assume-filename",
      filepath
    ];
    const exec = this.setting.exec ? this.setting.exec : "clang-format";
    const resp = await call_shell(exec, argv, document.getText());
    if (resp.exitCode != 0) {
      import_coc6.window.showMessage(`clang-format fail, ret ${resp.exitCode}`);
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      import_coc6.window.showMessage("clang-format ok");
      return [
        import_coc6.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/prettierformatter.ts
var import_coc7 = __toModule(require("coc.nvim"));
var import_fs2 = __toModule(require("fs"));
var PrettierFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
  }
  supportRangeFormat() {
    return false;
  }
  async formatDocument(document, _options, _token, range) {
    if (range) {
      return [];
    }
    const filepath = await getTempFileWithDocumentContents(document);
    const argv = [];
    if (this.setting.prettierOptions) {
      argv.push(...this.setting.prettierOptions);
    }
    argv.push(filepath);
    const exec = this.setting.exec ? this.setting.exec : "prettier";
    const resp = await call_shell(exec, argv);
    import_fs2.default.unlinkSync(filepath);
    if (resp.exitCode != 0) {
      import_coc7.window.showMessage(`prettier fail, ret ${resp.exitCode}`);
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      import_coc7.window.showMessage("prettier ok");
      return [
        import_coc7.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/bazelformatter.ts
var import_coc8 = __toModule(require("coc.nvim"));
var BazelFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
  }
  supportRangeFormat() {
    return false;
  }
  async formatDocument(document, _options, _token, range) {
    if (range) {
      return [];
    }
    const exec = this.setting.exec ? this.setting.exec : "buildifier";
    const resp = await call_shell(exec, [], document.getText());
    if (resp.exitCode != 0) {
      import_coc8.window.showMessage(`buildifier fail, ret ${resp.exitCode}`);
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      import_coc8.window.showMessage("buildifier ok");
      return [
        import_coc8.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/luaformatter.ts
var import_coc9 = __toModule(require("coc.nvim"));
var LuaFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
    this.opts = [];
    this.opts_has_indent_width = false;
    this.opts_has_usetab = false;
    if (this.setting.luaFormatOptions) {
      for (const i in this.setting.luaFormatOptions) {
        this.opts.push(this.setting.luaFormatOptions[i]);
        if (this.setting.luaFormatOptions[i].search("indent-width") != -1) {
          this.opts_has_indent_width = true;
        } else if (this.setting.luaFormatOptions[i].search("use-tab") != -1) {
          this.opts_has_usetab = true;
        }
      }
    }
  }
  supportRangeFormat() {
    return false;
  }
  async formatDocument(document, options, _token, range) {
    if (range) {
      return [];
    }
    const opts = [];
    if (options.tabSize !== void 0 && !this.opts_has_indent_width) {
      opts.push(`--indent-width=${options.tabSize}`);
    }
    if (options.insertSpaces !== void 0 && !this.opts_has_usetab) {
      if (options.insertSpaces) {
        opts.push("--no-use-tab");
      } else {
        opts.push("--use-tab");
      }
    }
    const exec = this.setting.exec ? this.setting.exec : "lua-format";
    const resp = await call_shell(exec, this.opts.concat(opts), document.getText());
    if (resp.exitCode != 0) {
      import_coc9.window.showMessage(`lua-format fail, ret ${resp.exitCode}`);
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      import_coc9.window.showMessage("lua-format ok");
      return [
        import_coc9.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/formatprovider.ts
var FormattingEditProvider = class {
  constructor(setting) {
    if (setting.provider == "clang-format") {
      this.formatter = new ClfFormatter(setting);
    } else if (setting.provider == "prettier") {
      this.formatter = new PrettierFormatter(setting);
    } else if (setting.provider == "bazel-buildifier") {
      this.formatter = new BazelFormatter(setting);
    } else if (setting.provider == "lua-format") {
      this.formatter = new LuaFormatter(setting);
    } else {
      this.formatter = null;
    }
  }
  async _provideEdits(document, options, token, range) {
    if (!this.formatter) {
      logger.error("formatter was null");
      import_coc10.window.showMessage("formatter was null");
      return [];
    }
    return this.formatter.formatDocument(document, options, token, range);
  }
  supportRangeFormat() {
    if (this.formatter) {
      return this.formatter.supportRangeFormat();
    }
    return false;
  }
  provideDocumentFormattingEdits(document, options, token) {
    return this._provideEdits(document, options, token);
  }
  provideDocumentRangeFormattingEdits(document, range, options, token) {
    return this._provideEdits(document, options, token, range);
  }
};

// src/coc-ext-common.ts
function translateFn(mode) {
  return async () => {
    const text = await getText(mode);
    let trans = await google_translate(text, "auto", "zh-CN");
    if (!trans) {
      trans = await bing_translate(text, "auto", "zh-CN");
    }
    if (trans) {
      await popup(`[${trans.engine}]

${trans.paraphrase}`, "ui_float");
    } else {
      await popup(`[Error]

translate fail`);
    }
  };
}
function decodeStrFn(enc) {
  return async () => {
    var _a;
    const text = await getText("v");
    const res = await call_python("coder", "decode_str", [text, enc]);
    if (res.exitCode == 0 && res.data) {
      popup(`[${enc.toUpperCase()} decode]

${res.data.toString("utf8")}`);
    } else {
      logger.error((_a = res.error) == null ? void 0 : _a.toString("utf8"));
    }
  };
}
function encodeStrFn(enc) {
  return async () => {
    var _a;
    const doc = await import_coc11.workspace.document;
    const range = await import_coc11.workspace.getSelectedRange("v", doc);
    if (!range) {
      return;
    }
    const text = doc.textDocument.getText(range);
    const res = await call_python("coder", "encode_str", [text, enc]);
    if (res.exitCode == 0 && res.data) {
      const ed = import_coc11.TextEdit.replace(range, res.data.toString("utf8"));
      await doc.applyEdits([ed]);
    } else {
      logger.error((_a = res.error) == null ? void 0 : _a.toString("utf8"));
    }
  };
}
async function activate(context) {
  context.logger.info(`coc-ext-common works`);
  logger.info(`coc-ext-common works`);
  logger.info(import_coc11.workspace.getConfiguration("coc-ext.common"));
  logger.info(process.env.COC_VIMCONFIG);
  const formatterSettings = getcfg("formatting", []);
  formatterSettings.forEach((s) => {
    s.languages.forEach((lang) => {
      const selector = [{scheme: "file", language: lang}];
      const provider = new FormattingEditProvider(s.setting);
      context.subscriptions.push(import_coc11.languages.registerDocumentFormatProvider(selector, provider, 1));
      if (provider.supportRangeFormat()) {
        context.subscriptions.push(import_coc11.languages.registerDocumentRangeFormatProvider(selector, provider, 1));
      }
    });
  });
  context.subscriptions.push(import_coc11.commands.registerCommand("ext-debug", async () => {
    const id = await import_coc11.workspace.nvim.call("ui#window#new", {
      position: "top"
    });
    const w = import_coc11.workspace.nvim.createWindow(id);
    logger.info(w.id);
    const doc = await import_coc11.workspace.document;
    const ed = import_coc11.TextEdit.replace({
      start: {line: 0, character: 0},
      end: {line: doc.lineCount, character: 0}
    }, "hello world");
    await doc.applyEdits([ed]);
    await import_coc11.workspace.nvim.command("setlocal nomodifiable");
  }, {sync: false}), import_coc11.workspace.registerKeymap(["n"], "ext-translate", translateFn("n"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-translate-v", translateFn("v"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-encode-utf8", encodeStrFn("utf8"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-encode-gbk", encodeStrFn("gbk"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-decode-utf8", decodeStrFn("utf8"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-decode-gbk", decodeStrFn("gbk"), {
    sync: false
  }), import_coc11.workspace.registerKeymap(["v"], "ext-decode-mime", async () => {
    const text = await getText("v");
    const tt = decode_mime_encode_str(text);
    popup(`[Mime decode]

${tt}`, "ui_float");
  }, {
    sync: false
  }), import_coc11.listManager.registerList(new lists_default(import_coc11.workspace.nvim)), import_coc11.listManager.registerList(new commands_default(import_coc11.workspace.nvim)));
}
