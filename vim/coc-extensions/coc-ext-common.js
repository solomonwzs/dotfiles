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
var import_coc16 = __toModule(require("coc.nvim"));

// src/lists/commands.ts
var Commands = class {
  constructor(nvim) {
    this.nvim = nvim;
    this.name = "vimcommand";
    this.description = "CocList for coc-ext-common (command)";
    this.defaultAction = "execute";
    this.actions = [];
    this.actions.push({
      name: "execute",
      execute: async (item) => {
        if (Array.isArray(item))
          return;
        const {command, shabang, hasArgs} = item.data;
        if (!hasArgs) {
          nvim.command(command, true);
        } else {
          const feedableCommand = `:${command}${shabang ? "" : " "}`;
          const mode = await nvim.call("mode");
          const isInsertMode = mode.startsWith("i");
          if (isInsertMode) {
            nvim.command(`call feedkeys("\\<C-O>${feedableCommand}", 'n')`, true);
          } else {
            await nvim.feedKeys(feedableCommand, "n", true);
          }
        }
      }
    });
    this.actions.push({
      name: "open",
      execute: async (item) => {
        if (Array.isArray(item))
          return;
        const {command} = item.data;
        if (!/^[A-Z]/.test(command))
          return;
        const res = await nvim.eval(`split(execute("verbose command ${command}"),"
")[-1]`);
        if (/Last\sset\sfrom/.test(res)) {
          const filepath = res.replace(/^\s+Last\sset\sfrom\s+/, "");
          nvim.command(`edit +/${command} ${filepath}`, true);
        }
      }
    });
  }
  async loadItems(_context) {
    const {nvim} = this;
    let list = await nvim.eval('split(execute("command"),"\n")');
    list = list.slice(1);
    const res = [];
    for (const str of list) {
      const matchArr = str.slice(4).match(/\S+/);
      if (matchArr == null) {
        continue;
      }
      const name = matchArr[0];
      const end = str.slice(4 + name.length);
      res.push({
        label: `${str.slice(0, 4)}${name}[3m${end}[23m`,
        filterText: name,
        data: {
          command: name,
          shabang: str.startsWith("!"),
          hasArgs: !end.match(/^\s*0\s/)
        }
      });
    }
    return res;
  }
};
var commands_default = Commands;

// src/lists/lists.ts
var import_coc2 = __toModule(require("coc.nvim"));

// src/utils/notify.ts
var import_coc = __toModule(require("coc.nvim"));
function showNotification(content, title, hl) {
  import_coc.window.showMessage(content);
}

// src/lists/lists.ts
var ExtList = class extends import_coc2.BasicList {
  constructor(nvim) {
    super(nvim);
    this.name = "ext_list";
    this.description = "CocList for coc-ext-common";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", (item) => {
      showNotification(`${item.label}, ${item.data.name}`);
    });
  }
  async loadItems(_context) {
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

// src/lists/mapkey.ts
var MapkeyList = class {
  constructor(nvim) {
    this.nvim = nvim;
    this.name = "vimmapkey";
    this.description = "CocList for coc-ext-common (map key)";
    this.defaultAction = "execute";
    this.actions = [];
    this.actions.push({
      name: "execute",
      execute: async (_item) => {
      }
    });
  }
  async loadItems(_context) {
    const {nvim} = this;
    let list = await nvim.eval('split(execute("map"),"\n")');
    list = list.slice(1);
    const res = [];
    for (const i of list) {
      res.push({
        label: i,
        data: {name: "1"}
      });
    }
    return res;
  }
};
var mapkey_default = MapkeyList;

// src/lists/rg.ts
var import_coc6 = __toModule(require("coc.nvim"));

// src/utils/externalexec.ts
var import_path = __toModule(require("path"));
var import_child_process = __toModule(require("child_process"));
async function callShell(cmd, args, input) {
  return new Promise((resolve) => {
    const stdin = input ? "pipe" : "ignore";
    const sh = import_child_process.spawn(cmd, args, {stdio: [stdin, "pipe", "pipe"]});
    if (input && sh.stdin) {
      sh.stdin.write(input);
      sh.stdin.end();
    }
    let exitCode = 0;
    const data = [];
    const error = [];
    if (sh.stdout) {
      sh.stdout.on("data", (d) => {
        data.push(d);
      });
    }
    if (sh.stderr) {
      sh.stderr.on("data", (d) => {
        error.push(d);
      });
    }
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
async function callPython(pythonDir, m, f, a) {
  return new Promise((resolve) => {
    const msg = JSON.stringify({m, f, a});
    let root_dir = process.env.COC_VIMCONFIG;
    if (!root_dir) {
      root_dir = ".";
    }
    const script = import_path.default.join(root_dir, pythonDir, "coc-ext.py");
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

// src/utils/logger.ts
var import_coc4 = __toModule(require("coc.nvim"));

// src/utils/config.ts
var import_coc3 = __toModule(require("coc.nvim"));
function getcfg(key, defaultValue) {
  const config = import_coc3.workspace.getConfiguration("coc-ext");
  return config.get(key, defaultValue);
}

// src/utils/common.ts
var import_path2 = __toModule(require("path"));
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
var import_path3 = __toModule(require("path"));
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
          const file = import_path3.default.basename(expl[3]);
          const line = expl[4];
          this.channel.appendLine(`${now.toISOString()} ${level} [${file}:${line}] ${str}`);
          return;
        }
      }
    }
    const fn = import_path3.default.basename(__filename);
    this.channel.appendLine(`${level} [${fn}] ${str}`);
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

// src/utils/icons.ts
var import_coc5 = __toModule(require("coc.nvim"));
var import_path4 = __toModule(require("path"));
var defx_has_init = false;
var defx_icons = void 0;
var default_color;
async function defx_init() {
  defx_has_init = true;
  let {nvim} = import_coc5.workspace;
  default_color = await nvim.eval('synIDattr(hlID("Normal"), "fg")');
  let loaded_defx_icons = await nvim.eval('get(g:, "loaded_defx_icons")');
  if (loaded_defx_icons != 1) {
    return;
  }
  defx_icons = await nvim.eval("defx_icons#get()");
  let colors = new Set();
  for (const i of Object.values(defx_icons.icons.exact_matches)) {
    i.hlGroup = `DefxIcoFg_${i.term_color}`;
    colors.add(i.term_color);
  }
  for (const i of Object.values(defx_icons.icons.extensions)) {
    i.hlGroup = `DefxIcoFg_${i.term_color}`;
    colors.add(i.term_color);
  }
  for (const i of Object.values(defx_icons.icons.pattern_matches)) {
    i.hlGroup = `DefxIcoFg_${i.term_color}`;
    colors.add(i.term_color);
  }
  for (const i of colors) {
    await nvim.command(`hi def DefxIcoFg_${i} ctermfg=${i}`);
  }
}
async function getDefxIcon(filetype, filepath) {
  if (!defx_has_init) {
    await defx_init();
  }
  if (!defx_icons) {
    return {
      term_color: default_color,
      icon: "\uF016",
      color: default_color.toString()
    };
  }
  const filename = import_path4.default.basename(filepath);
  let info = defx_icons.icons.exact_matches[filename];
  if (info) {
    return info;
  }
  info = defx_icons.icons.extensions[filetype];
  if (info) {
    return info;
  }
  return {
    term_color: default_color,
    icon: "\uF016",
    color: default_color.toString()
  };
}

// src/lists/rg.ts
var import_path5 = __toModule(require("path"));
var RgList = class extends import_coc6.BasicList {
  constructor(nvim) {
    super(nvim);
    this.name = "rg";
    this.description = "CocList for coc-ext-common (rg)";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", async (item, _context) => {
      await this.jumpTo(import_path5.default.resolve(item.data["name"]));
    });
    this.addAction("preview", async (item, context) => {
      let resp = await callShell("rg", [
        "-B",
        "3",
        "-C",
        "3",
        context.args[0],
        item.data["name"]
      ]);
      if (resp.exitCode != 0 || !resp.data) {
        return;
      }
      let lines = resp.data.toString().split("\n");
      this.preview({filetype: item.data["filetype"], lines}, context);
    });
  }
  async loadItems(context) {
    if (context.args.length == 0) {
      return null;
    }
    const args = [context.args[0], "--files-with-matches", "--color", "never"];
    let resp = await callShell("rg", args);
    if (resp.exitCode != 0) {
      logger.error("rg fail");
      if (resp.error) {
        showNotification(resp.error.toString());
      }
      return null;
    }
    if (!resp.data) {
      logger.error("no data");
      return null;
    }
    let list = resp.data.toString().split("\n");
    list.pop();
    const items = [];
    for (const i of list) {
      let extname = import_path5.default.extname(i).slice(1);
      let icon = await getDefxIcon(extname, i);
      let label = `${icon.icon}  ${i}`;
      items.push({
        label,
        data: {name: i, filetype: extname},
        ansiHighlights: icon.hlGroup ? [
          {
            span: [0, Buffer.byteLength(icon.icon)],
            hlGroup: icon.hlGroup
          }
        ] : void 0
      });
    }
    return items;
  }
};
var rg_default = RgList;

// src/formatter/clfformatter.ts
var import_coc7 = __toModule(require("coc.nvim"));

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
    const filepath = import_coc7.Uri.parse(document.uri).fsPath;
    const setting = {};
    if (this.setting.args) {
      for (const k in this.setting.args) {
        setting[k] = this.setting.args[k];
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
    const args = [
      "-style",
      JSON.stringify(setting),
      "--assume-filename",
      filepath
    ];
    const exec = this.setting.exec ? this.setting.exec : "clang-format";
    const resp = await callShell(exec, args, document.getText());
    if (resp.exitCode != 0) {
      showNotification(`clang-format fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("clang-format ok", "formatter");
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

// src/formatter/prettierformatter.ts
var import_coc9 = __toModule(require("coc.nvim"));

// src/utils/helper.ts
var import_coc8 = __toModule(require("coc.nvim"));
var import_path6 = __toModule(require("path"));
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
function positionInRange(pos, range) {
  return (range.start.line < pos.line || range.start.line == pos.line && range.start.character <= pos.character) && (pos.line < range.end.line || pos.line == range.end.line && pos.character <= range.end.character);
}
async function getText(mode) {
  const doc = await import_coc8.workspace.document;
  let range = null;
  if (mode === "v") {
    const text2 = (await import_coc8.workspace.nvim.call("lib#common#visual_selection", 1)).toString();
    return text2.trim();
  } else {
    const pos = await import_coc8.window.getCursorPosition();
    range = doc.getWordRangeAtPosition(pos);
  }
  let text = "";
  if (!range) {
    text = (await import_coc8.workspace.nvim.eval('expand("<cword>")')).toString();
  } else {
    text = doc.textDocument.getText(range);
  }
  return text.trim();
}
async function popup(content, title, filetype, cfg) {
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
      content: title && title.length != 0 ? `${title}

${content}` : content,
      filetype
    }
  ];
  const win = new import_coc8.FloatFactory(import_coc8.workspace.nvim);
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
    const fsPath = import_coc8.Uri.parse(document.uri).fsPath;
    const ext = import_path6.default.extname(fsPath);
    const fileName = `${fsPath}.${fnvHash(document.uri)}${ext}`;
    import_fs.default.writeFile(fileName, document.getText(), (ex) => {
      if (ex) {
        reject(new Error(`Failed to create a temporary file, ${ex.message}`));
      }
      resolve(fileName);
    });
  });
}

// src/formatter/prettierformatter.ts
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
    const args = [];
    if (this.setting.args) {
      args.push(...this.setting.args);
    }
    args.push(filepath);
    const exec = this.setting.exec ? this.setting.exec : "prettier";
    const resp = await callShell(exec, args);
    import_fs2.default.unlinkSync(filepath);
    if (resp.exitCode != 0) {
      showNotification(`prettier fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("prettier ok", "formatter");
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

// src/formatter/bazelformatter.ts
var import_coc10 = __toModule(require("coc.nvim"));
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
    const resp = await callShell(exec, [], document.getText());
    if (resp.exitCode != 0) {
      showNotification(`buildifier fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("buildifier ok", "formatter");
      return [
        import_coc10.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/luaformatter.ts
var import_coc11 = __toModule(require("coc.nvim"));
var LuaFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
    this.opts = [];
    this.opts_has_indent_width = false;
    this.opts_has_usetab = false;
    if (this.setting.args) {
      for (const i of this.setting.args) {
        this.opts.push(i);
        if (i.search("indent-width") != -1) {
          this.opts_has_indent_width = true;
        } else if (i.search("use-tab") != -1) {
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
    const resp = await callShell(exec, this.opts.concat(opts), document.getText());
    if (resp.exitCode != 0) {
      showNotification(`lua-format fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("lua-format ok", "formatter");
      return [
        import_coc11.TextEdit.replace({
          start: {line: 0, character: 0},
          end: {line: document.lineCount, character: 0}
        }, resp.data.toString())
      ];
    }
    return [];
  }
};

// src/formatter/shellformatter.ts
var import_coc12 = __toModule(require("coc.nvim"));
var ShellFormatter = class extends BaseFormatter {
  constructor(setting) {
    super(setting);
    this.setting = setting;
    this.opts = [];
    if (this.setting.args) {
      this.opts.push(...this.setting.args);
    }
  }
  supportRangeFormat() {
    return false;
  }
  async formatDocument(document, _options, _token, range) {
    if (range) {
      return [];
    }
    const exec = this.setting.exec ? this.setting.exec : "shfmt";
    const resp = await callShell(exec, this.opts, document.getText());
    if (resp.exitCode != 0) {
      showNotification(`shfmt fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("shfmt ok", "formatter");
      return [
        import_coc12.TextEdit.replace({
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
    } else if (setting.provider == "shfmt") {
      this.formatter = new ShellFormatter(setting);
    } else {
      this.formatter = null;
    }
  }
  async _provideEdits(document, options, token, range) {
    if (!this.formatter) {
      logger.error("formatter was null");
      showNotification("formatter was null", "formatter");
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

// src/utils/http.ts
var import_https = __toModule(require("https"));
async function simpleHttpsRequest(opts, data) {
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

// src/translators/bing.ts
function getParaphrase(html) {
  const re = /<span class="ht_pos">(.*?)<\/span><span class="ht_trs">(.*?)<\/span>/g;
  let expl = re.exec(html);
  const paraphrase = [];
  while (expl) {
    paraphrase.push(`${expl[1]} ${expl[2]} `);
    expl = re.exec(html);
  }
  return paraphrase.join("\n");
}
async function bingTranslate(text, sl, tl) {
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
  const resp = await simpleHttpsRequest(opts);
  if (resp.error) {
    logger.error(resp.error.message);
    return null;
  }
  if (!resp.data) {
    return null;
  }
  const ret = createTranslation("Bing", sl, tl, text);
  ret.paraphrase = getParaphrase(resp.data.toString());
  return ret;
}

// src/utils/debug.ts
var import_coc15 = __toModule(require("coc.nvim"));

// src/lightbulb/lightbulb.ts
var import_coc13 = __toModule(require("coc.nvim"));

// src/utils/symbol.ts
var import_coc14 = __toModule(require("coc.nvim"));
var symbolKind2Info = {
  1: {name: "File", icon: "\uF40E", short_name: "F"},
  2: {name: "Module", icon: "\uF0E8", short_name: "M"},
  3: {name: "Namespace", icon: "\uF668", short_name: "N"},
  4: {name: "Package", icon: "\uF487", short_name: "P"},
  5: {name: "Class", icon: "\uF0E8", short_name: "C"},
  6: {name: "Method", icon: "\uE79B", short_name: "f"},
  7: {name: "Property", icon: "\uFAB6", short_name: "p"},
  8: {name: "Field", icon: "\uF9BE", short_name: "m"},
  9: {name: "Constructor", icon: "\uF425", short_name: "c"},
  10: {name: "Enum", icon: "\uF435", short_name: "E"},
  11: {name: "Interface", icon: "\uF417", short_name: "I"},
  12: {name: "Function", icon: "\u0192", short_name: "f"},
  13: {name: "Variable", icon: "\uE79B", short_name: "v"},
  14: {name: "Constant", icon: "\uF8FE", short_name: "C"},
  15: {name: "String", icon: "\uF672", short_name: "S"},
  16: {name: "Number", icon: "\uF89F", short_name: "n"},
  17: {name: "Boolean", icon: "", short_name: "b"},
  18: {name: "Array", icon: "\uF669", short_name: "a"},
  19: {name: "Object", icon: "\uF0E8", short_name: "O"},
  20: {name: "Key", icon: "\uF805", short_name: "K"},
  21: {name: "Null", icon: "\uFCE0", short_name: "n"},
  22: {name: "EnumMember", icon: "\uF02B", short_name: "m"},
  23: {name: "Struct", icon: "\uFB44", short_name: "S"},
  24: {name: "Event", icon: "\uFACD", short_name: "e"},
  25: {name: "Operator", icon: "\u03A8", short_name: "o"},
  26: {name: "TypeParameter", icon: "\uF671", short_name: "T"}
};
async function getDocumentSymbols(bufnr0) {
  const {nvim} = import_coc14.workspace;
  const bufnr = bufnr0 ? bufnr0 : await nvim.call("bufnr", ["%"]);
  const doc = import_coc14.workspace.getDocument(bufnr);
  if (!doc || !doc.attached) {
    return null;
  }
  if (!import_coc14.languages.hasProvider("documentSymbol", doc.textDocument)) {
    return null;
  }
  const tokenSource = new import_coc14.CancellationTokenSource();
  const {token} = tokenSource;
  const docSymList = await import_coc14.languages.getDocumentSymbol(doc.textDocument, token);
  return docSymList;
}
async function getCursorSymbolList() {
  const docSymList = await getDocumentSymbols();
  if (!docSymList) {
    return null;
  }
  const pos = await import_coc14.window.getCursorPosition();
  const symList = [];
  let slist = docSymList;
  let ok = true;
  while (slist && ok) {
    ok = false;
    for (const s of slist) {
      if (positionInRange(pos, s.range)) {
        let info = symbolKind2Info[s.kind];
        symList.push({
          name: s.name,
          short_name: info.short_name,
          detail: s.detail,
          kind: info.name,
          icon: info.icon
        });
        slist = s.children;
        ok = true;
        break;
      }
    }
  }
  return symList;
}

// src/utils/debug.ts
async function debug() {
  const x = await getCursorSymbolList();
  logger.debug(x);
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

// src/translators/google.ts
function getParaphrase2(obj) {
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
async function googleTranslate(text, sl, tl) {
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
  const resp = await simpleHttpsRequest(opts);
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
  ret.paraphrase = getParaphrase2(obj);
  return ret;
}

// src/coc-ext-common.ts
var cppFmtSetting = {
  provider: "clang-format",
  args: {
    AlignConsecutiveMacros: "true",
    AlignEscapedNewlines: "Left",
    AllowShortFunctionsOnASingleLine: "Inline",
    BasedOnStyle: "Google",
    Standard: "C++11"
  }
};
var jsFmtSetting = {
  provider: "prettier",
  args: ["--config-precedence", "cli-override", "--print-width", "80"]
};
var bzlFmtSteeing = {
  provider: "bazel-buildifier"
};
var luaFmtSteeing = {
  provider: "lua-format",
  args: ["--column-table-limit=80"]
};
var shFmtSetting = {
  provider: "shfmt",
  args: ["-i", "4"]
};
var defaultFmtSetting = {
  c: cppFmtSetting,
  cpp: cppFmtSetting,
  typescript: jsFmtSetting,
  json: jsFmtSetting,
  javascript: jsFmtSetting,
  html: jsFmtSetting,
  bzl: bzlFmtSteeing,
  lua: luaFmtSteeing,
  sh: shFmtSetting,
  zsh: shFmtSetting
};
async function replaceExecText(doc, range, res) {
  var _a;
  if (res.exitCode == 0 && res.data) {
    const ed = import_coc16.TextEdit.replace(range, res.data.toString("utf8"));
    await doc.applyEdits([ed]);
  } else {
    logger.error((_a = res.error) == null ? void 0 : _a.toString("utf8"));
  }
}
async function getCursorSymbolInfo() {
  const infoList = await getCursorSymbolList();
  if (!infoList) {
    return;
  }
  let msg = "";
  let space = " ";
  for (const i of infoList) {
    const line = `[${i.short_name}] ${i.name}`;
    if (msg.length == 0) {
      msg = `\uF0DA ${line}`;
    } else {
      msg += `
${space}\uF0DA ${line}`;
      space += " ";
    }
  }
  await popup(msg);
}
function translateFn(mode) {
  return async () => {
    const text = await getText(mode);
    let trans = await googleTranslate(text, "auto", "zh-CN");
    if (!trans) {
      trans = await bingTranslate(text, "auto", "zh-CN");
    }
    if (trans) {
      await popup(trans.paraphrase, `[${trans.engine}]`);
    } else {
      await popup("translate fail", "[Error]");
    }
  };
}
function decodeStrFn(enc) {
  return async () => {
    var _a;
    const pythonDir = getcfg("pythonDir", "");
    const text = await getText("v");
    const res = await callPython(pythonDir, "coder", "decode_str", [text, enc]);
    if (res.exitCode == 0 && res.data) {
      popup(res.data.toString("utf8"), `[${enc.toUpperCase()} decode]`);
    } else {
      logger.error((_a = res.error) == null ? void 0 : _a.toString("utf8"));
    }
  };
}
function encodeStrFn(enc) {
  return async () => {
    const pythonDir = getcfg("pythonDir", "");
    const doc = await import_coc16.workspace.document;
    const range = await import_coc16.workspace.getSelectedRange("v", doc);
    if (!range) {
      return;
    }
    const text = doc.textDocument.getText(range);
    const res = await callPython(pythonDir, "coder", "encode_str", [text, enc]);
    replaceExecText(doc, range, res);
  };
}
function addFormatter(context, lang, setting) {
  const selector = [{scheme: "file", language: lang}];
  const provider = new FormattingEditProvider(setting);
  context.subscriptions.push(import_coc16.languages.registerDocumentFormatProvider(selector, provider, 1));
  if (provider.supportRangeFormat()) {
    context.subscriptions.push(import_coc16.languages.registerDocumentRangeFormatProvider(selector, provider, 1));
  }
}
async function activate(context) {
  context.logger.info(`coc-ext-common works`);
  logger.info(`coc-ext-common works`);
  logger.info(import_coc16.workspace.getConfiguration("coc-ext.common"));
  logger.info(process.env.COC_VIMCONFIG);
  const langFmtSet = new Set();
  const formatterSettings = getcfg("formatting", []);
  formatterSettings.forEach((s) => {
    s.languages.forEach((lang) => {
      langFmtSet.add(lang);
      addFormatter(context, lang, s.setting);
    });
  });
  for (const k in defaultFmtSetting) {
    if (!langFmtSet.has(k)) {
      addFormatter(context, k, defaultFmtSetting[k]);
    }
  }
  context.subscriptions.push(import_coc16.commands.registerCommand("ext-debug", debug, {sync: false}), import_coc16.workspace.registerKeymap(["n"], "ext-cursor-symbol", getCursorSymbolInfo, {
    sync: false
  }), import_coc16.workspace.registerKeymap(["n"], "ext-translate", translateFn("n"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-translate-v", translateFn("v"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-encode-utf8", encodeStrFn("utf8"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-encode-gbk", encodeStrFn("gbk"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-decode-utf8", decodeStrFn("utf8"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-decode-gbk", decodeStrFn("gbk"), {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-change-name-rule", async () => {
    const pythonDir = getcfg("pythonDir", "");
    const doc = await import_coc16.workspace.document;
    const range = await import_coc16.workspace.getSelectedRange("v", doc);
    if (!range) {
      return;
    }
    const name = doc.textDocument.getText(range);
    const res = await callPython(pythonDir, "common", "change_name_rule", [
      name
    ]);
    replaceExecText(doc, range, res);
  }, {
    sync: false
  }), import_coc16.workspace.registerKeymap(["v"], "ext-decode-mime", async () => {
    const text = await getText("v");
    const tt = decode_mime_encode_str(text);
    popup(tt, "[Mime decode]");
  }, {
    sync: false
  }), import_coc16.listManager.registerList(new lists_default(import_coc16.workspace.nvim)), import_coc16.listManager.registerList(new commands_default(import_coc16.workspace.nvim)), import_coc16.listManager.registerList(new mapkey_default(import_coc16.workspace.nvim)), import_coc16.listManager.registerList(new rg_default(import_coc16.workspace.nvim)));
}
