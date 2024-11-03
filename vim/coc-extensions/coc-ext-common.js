"use strict";
var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/coc-ext-common.ts
var coc_ext_common_exports = {};
__export(coc_ext_common_exports, {
  activate: () => activate
});
module.exports = __toCommonJS(coc_ext_common_exports);
var import_coc23 = require("coc.nvim");

// src/lists/autocmd.ts
var import_coc = require("coc.nvim");

// src/utils/common.ts
var import_url = require("url");
function getEnvHttpProxy(is_https) {
  const proxy = process.env[is_https ? "https_proxy" : "http_proxy"];
  if (proxy) {
    try {
      return new import_url.URL(proxy);
    } catch (e) {
      return void 0;
    }
  } else {
    return void 0;
  }
}
function stringify(value) {
  if (typeof value === "string") {
    return value;
  } else if (value instanceof String) {
    return value.toString();
  } else {
    return JSON.stringify(value, null, 2);
  }
}
function getRandomId(scope, sep = "-") {
  const ts = (/* @__PURE__ */ new Date()).getTime().toString(16).slice(-8);
  let r = Math.floor(Math.random() * 65535).toString(16);
  r = "0".repeat(4 - r.length) + r;
  return scope && scope.length > 0 ? `${scope}${sep}${ts}${sep}${r}` : `${ts}${sep}${r}`;
}
function strFindFirstOf(str, ch) {
  for (let i = 0; i < str.length; ++i) {
    if (ch.has(str[i])) {
      return i;
    }
  }
  return -1;
}
function strFindFirstNotOf(str, ch) {
  for (let i = 0; i < str.length; ++i) {
    if (!ch.has(str[i])) {
      return i;
    }
  }
  return -1;
}
var CocExtError = class extends Error {
  constructor(errorCode, message) {
    super(message);
    this.name = "CocExtError";
    this.errorCode = errorCode;
  }
};
CocExtError.ERR_HTTP = -1;
CocExtError.ERR_AUTH = -2;
CocExtError.ERR_KIMI = -3;
var CocExtErrnoError = class extends Error {
  constructor(err) {
    super(err.message);
    this.name = "CocExtErrnoError";
    this.errno = err.errno;
    this.code = err.code;
    this.path = err.path;
    this.syscall = err.syscall;
  }
};

// src/lists/autocmd.ts
function parseAutocmdInfo(str) {
  let lines = str.split("\n");
  let group = "";
  let event = "";
  let pattern = "";
  let setting = "";
  let infos = [];
  let res = [];
  const f_push_info = (file, line) => {
    infos.push({
      group,
      event,
      pattern,
      setting,
      file,
      line
    });
    pattern = "";
    setting = "";
  };
  const spaces = /* @__PURE__ */ new Set([" ", "	"]);
  for (const l of lines) {
    const sn = strFindFirstNotOf(l, spaces);
    if (sn == 0) {
      let arr = l.split(/\s+/);
      if (arr.length == 2 && arr[0] != "") {
        if (pattern != "") {
          f_push_info("", 0);
        }
        if (group != "") {
          res.push({
            group,
            event,
            infos
          });
          infos = [];
        }
        group = arr[0];
        event = arr[1];
      }
    } else if (sn == 4) {
      if (pattern != "") {
        f_push_info("", 0);
      }
      setting = "";
      const ltmp = l.slice(sn);
      const offset0 = strFindFirstOf(ltmp, spaces);
      if (offset0 == -1) {
        pattern = ltmp;
      } else {
        pattern = ltmp.slice(0, offset0);
        const offset1 = strFindFirstNotOf(ltmp.slice(offset0), spaces);
        if (offset1 != -1) {
          setting = ltmp.slice(offset0 + offset1);
        }
      }
    } else if (sn == 14) {
      const ltmp = l.slice(sn);
      if (setting != "") {
        setting = ltmp;
      } else {
        setting += ` ${ltmp}`;
      }
    } else if (sn == 1 && l[0] == "	") {
      let arr = l.split(/\s+/);
      if (arr.length == 7) {
        f_push_info(arr[4], parseInt(arr[6]));
      }
    }
  }
  return res;
}
var AutocmdList = class extends import_coc.BasicList {
  constructor(_nvim) {
    super();
    this.name = "autocmd";
    this.description = "CocList for coc-ext-common (autocmd)";
    this.defaultAction = "preview";
    this.actions = [];
    this.addAction("preview", async (item, context) => {
      if (!item.data) {
        return;
      }
      let lines = [];
      for (const i of item.data.infos) {
        lines.push(i.pattern);
        lines.push(`    ${i.setting}`);
        if (i.file != "") {
          lines.push(`    => ${i.file}:${i.line}`);
        }
        lines.push("");
      }
      this.preview({ filetype: "vim", lines }, context);
    });
  }
  async loadItems(_context) {
    const { nvim } = this;
    let str = await nvim.exec("verbose autocmd", true);
    const infos = parseAutocmdInfo(str);
    let max_gn_len = 0;
    let max_en_len = 0;
    for (const i of infos) {
      if (i.group.length > max_gn_len) {
        max_gn_len = i.group.length;
      }
      if (i.event.length > max_en_len) {
        max_en_len = i.event.length;
      }
    }
    const res = [];
    for (const i of infos) {
      const spaces0 = " ".repeat(max_gn_len - i.group.length + 2);
      const spaces1 = " ".repeat(max_en_len - i.event.length + 2);
      const label = `${i.group}${spaces0}${i.event}${spaces1}(${i.infos.length})`;
      res.push({
        label,
        data: i,
        ansiHighlights: [
          { span: [0, i.group.length], hlGroup: "Define" },
          {
            span: [max_gn_len + 2, max_gn_len + 2 + i.event.length],
            hlGroup: "Special"
          }
        ]
      });
    }
    return res;
  }
};

// src/lists/commands.ts
var Commands = class {
  constructor(nvim) {
    this.nvim = nvim;
    this.name = "vimcmd";
    this.description = "CocList for coc-ext-common (command)";
    this.defaultAction = "execute";
    this.actions = [];
    this.actions.push({
      name: "execute",
      execute: async (item) => {
        if (Array.isArray(item))
          return;
        const { command, shabang, hasArgs } = item.data;
        if (!hasArgs) {
          nvim.command(command, true);
        } else {
          const feedableCommand = `:${command}${shabang ? "" : " "}`;
          const mode = await nvim.call("mode");
          const isInsertMode = mode.startsWith("i");
          if (isInsertMode) {
            nvim.command(
              `call feedkeys("\\<C-O>${feedableCommand}", 'n')`,
              true
            );
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
        const { command } = item.data;
        if (!/^[A-Z]/.test(command))
          return;
        const res = await nvim.eval(
          `split(execute("verbose command ${command}"),"
")[-1]`
        );
        if (/Last\sset\sfrom/.test(res)) {
          const filepath = res.replace(/^\s+Last\sset\sfrom\s+/, "");
          nvim.command(`edit +/${command} ${filepath}`, true);
        }
      }
    });
  }
  async loadItems(_context) {
    const { nvim } = this;
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
        label: `${str.slice(0, 4)}${name}\x1B[3m${end}\x1B[23m`,
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

// src/lists/lists.ts
var import_coc3 = require("coc.nvim");

// src/utils/notify.ts
var import_coc2 = require("coc.nvim");
function showNotification(content, title, hl) {
  import_coc2.window.showMessage(content);
}

// src/lists/lists.ts
var ExtList = class extends import_coc3.BasicList {
  constructor(_nvim) {
    super();
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
        data: { name: "list item 1" }
      },
      {
        label: "coc-ext-common list item 2",
        data: { name: "list item 2" }
      }
    ];
  }
};

// src/lists/highlight.ts
var import_coc6 = require("coc.nvim");

// src/utils/helper.ts
var import_coc5 = require("coc.nvim");

// src/utils/config.ts
var import_coc4 = require("coc.nvim");
function getcfg(key, defaultValue) {
  const config = import_coc4.workspace.getConfiguration("coc-ext");
  return config.get(key, defaultValue);
}

// src/utils/helper.ts
function defauleFloatWinConfig() {
  let conf = getcfg("floatConfig", {});
  return {
    autoHide: true,
    border: conf.border ? [1, 1, 1, 1] : [0, 0, 0, 0],
    close: false,
    maxHeight: conf.maxHeight,
    maxWidth: conf.maxWidth,
    highlight: conf.highlight,
    borderhighlight: conf.borderhighlight
  };
}
function positionInRange(pos, range) {
  return (range.start.line < pos.line || range.start.line == pos.line && range.start.character <= pos.character) && (pos.line < range.end.line || pos.line == range.end.line && pos.character <= range.end.character);
}
async function getText(mode, escape = true) {
  const doc = await import_coc5.workspace.document;
  let range = null;
  if (mode === "v") {
    const text2 = (await import_coc5.workspace.nvim.call("lib#common#visual_selection", [escape ? 1 : 0])).toString();
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
async function echoMessage(hl, msg) {
  const { nvim } = import_coc5.workspace;
  await nvim.exec(`echohl ${hl}`);
  await nvim.exec(`echo "${msg}"`);
  await nvim.exec(`echohl None`);
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
  const win = import_coc5.window.createFloatFactory(cfg);
  await win.show(doc);
}
async function openFile(filepath, opts) {
  const { nvim } = import_coc5.workspace;
  let open = "edit";
  let cmd = "";
  if (opts) {
    if (opts.open) {
      open = opts.open;
    }
    if (opts.key) {
      cmd = `+/${opts.key}`;
    } else if (opts.line) {
      const column = opts.column ? opts.column : 0;
      cmd = `+call\\ cursor(${opts.line},${column})`;
    }
  }
  await nvim.command(`${open} ${cmd} ${filepath}`);
}
function sleepMs(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}

// src/lists/highlight.ts
function parseHighlightInfo(str) {
  let lines = str.split("\n");
  let group_name = "";
  let desc = "";
  let last_set_file = "";
  let line = 0;
  let res = [];
  for (const l of lines) {
    let arr = l.split(/\s+/);
    if (arr.length > 0 && arr[0].length > 0) {
      if (group_name.length > 0) {
        res.push({
          group_name,
          desc,
          last_set_file,
          line
        });
      }
      group_name = arr[0];
      if (arr.length > 2) {
        desc = arr.slice(2).join(" ");
      } else {
        desc = "";
      }
      last_set_file = "";
      line = 0;
    } else if (arr.length == 7 && arr[0].length == 0 && arr[1] == "Last") {
      last_set_file = arr[4];
      line = parseInt(arr[6]);
    } else if (arr.length > 1 && arr[0].length == 0) {
      if (desc.length > 0) {
        desc += ", ";
      }
      desc += arr.slice(1).join(" ");
    }
  }
  if (group_name.length > 0) {
    res.push({
      group_name,
      desc,
      last_set_file,
      line
    });
  }
  return res;
}
var HighlightList = class extends import_coc6.BasicList {
  constructor(_nvim) {
    super();
    this.name = "highlight";
    this.description = "CocList for coc-ext-common (highlight)";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", async (item, _context) => {
      let fp = item.data["last_set_file"];
      if (fp.length == 0) {
        return;
      }
      await openFile(fp, {
        open: "sp",
        line: item.data["line"]
      });
    });
  }
  async loadItems(_context) {
    const { nvim } = this;
    let str = await nvim.exec("verbose highlight", true);
    const hiinfos = parseHighlightInfo(str);
    let max_gn_len = 0;
    for (const i of hiinfos) {
      if (i.group_name.length > max_gn_len) {
        max_gn_len = i.group_name.length;
      }
    }
    const res = [];
    for (const i of hiinfos) {
      const spaces = " ".repeat(max_gn_len - i.group_name.length + 2);
      const label = `${i.group_name}${spaces}xxx  ${i.desc}  ${i.last_set_file}:${i.line}`;
      const xoffset = i.group_name.length + spaces.length;
      const fnoffset = xoffset + 3 + 2 + i.desc.length + 2;
      res.push({
        label,
        data: { last_set_file: i.last_set_file, line: i.line },
        ansiHighlights: [
          {
            span: [xoffset, xoffset + 3],
            hlGroup: i.group_name
          },
          {
            span: [fnoffset, label.length],
            hlGroup: "Comment"
          }
        ]
      });
    }
    return res;
  }
};

// src/lists/mapkey.ts
var import_coc7 = require("coc.nvim");
function parseMapkeyInfo(str) {
  let lines = str.split("\n");
  let mode = "";
  let key = "";
  let desc = "";
  let last_set_file = "";
  let line = 0;
  let res = [];
  for (const l of lines) {
    let arr = l.split(/\s+/);
    if (arr.length == 7 && arr[0].length == 0 && arr[1] == "Last") {
      last_set_file = arr[4];
      line = parseInt(arr[6]);
    } else if (arr.length >= 3) {
      if (key.length > 0) {
        res.push({
          mode: mode.length == 0 ? " " : mode,
          key,
          desc,
          last_set_file,
          line
        });
      }
      mode = arr[0];
      key = arr[1];
      desc = arr.slice(2).join(" ");
      last_set_file = "";
      line = 0;
    }
  }
  if (key.length > 0) {
    res.push({
      mode: mode.length == 0 ? " " : mode,
      key,
      desc,
      last_set_file,
      line
    });
  }
  return res;
}
var MapkeyList = class extends import_coc7.BasicList {
  constructor(_nvim) {
    super();
    this.name = "mapkey";
    this.description = "CocList for coc-ext-common (mapkey)";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", async (item, _context) => {
      let fp = item.data["last_set_file"];
      if (fp.length == 0) {
        return;
      }
      await openFile(fp, {
        open: "sp",
        line: item.data["line"]
      });
    });
  }
  async loadItems(_context) {
    const { nvim } = this;
    let str = await nvim.exec("verbose map", true);
    const mapinfos = parseMapkeyInfo(str);
    let max_key_len = 0;
    for (const i of mapinfos) {
      if (i.key.length > max_key_len) {
        max_key_len = i.key.length;
      }
    }
    const res = [];
    for (const i of mapinfos) {
      const spaces = " ".repeat(max_key_len - i.key.length + 2);
      const label = `${i.mode}  ${i.key}${spaces}${i.desc}  ${i.last_set_file}:${i.line}`;
      const keyoffset = 3;
      const fnoffset = keyoffset + i.key.length + spaces.length + i.desc.length + 2;
      res.push({
        label,
        data: { last_set_file: i.last_set_file, line: i.line },
        ansiHighlights: [
          { span: [0, 1], hlGroup: "Define" },
          { span: [keyoffset, keyoffset + i.key.length], hlGroup: "Special" },
          { span: [fnoffset, label.length], hlGroup: "Comment" }
        ]
      });
    }
    return res;
  }
};

// src/lists/rgfiles.ts
var import_coc10 = require("coc.nvim");
var import_path4 = __toESM(require("path"));

// src/utils/externalexec.ts
var import_path = __toESM(require("path"));
var import_child_process = require("child_process");
async function callShell(cmd, args, input, opts) {
  return new Promise((resolve) => {
    const stdin = input ? "pipe" : "ignore";
    const sh = (0, import_child_process.spawn)(cmd, args, {
      stdio: [stdin, "pipe", "pipe"],
      shell: opts == null ? void 0 : opts.shell
    });
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
    const msg = JSON.stringify({ m, f, a });
    let root_dir = process.env.COC_VIMCONFIG;
    if (!root_dir) {
      root_dir = ".";
    }
    const script = import_path.default.join(root_dir, pythonDir, "coc_ext.py");
    const py = (0, import_child_process.spawn)("python3", [script], { stdio: ["pipe", "pipe", "pipe"] });
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

// src/utils/icons.ts
var import_coc8 = require("coc.nvim");
var import_path2 = __toESM(require("path"));
var defx_has_init = false;
var defx_icons = void 0;
var default_color;
async function defx_init() {
  defx_has_init = true;
  let { nvim } = import_coc8.workspace;
  default_color = await nvim.eval(
    'synIDattr(hlID("Normal"), "fg")'
  );
  let loaded_defx_icons = await nvim.eval(
    'get(g:, "loaded_defx_icons")'
  );
  if (loaded_defx_icons != 1) {
    return;
  }
  defx_icons = await nvim.eval("defx_icons#get()");
  let colors = /* @__PURE__ */ new Set();
  for (const i of Object.values(
    defx_icons.icons.exact_matches
  )) {
    i.hlGroup = `DefxIcoFg_${i.term_color}`;
    colors.add(i.term_color);
  }
  for (const i of Object.values(
    defx_icons.icons.extensions
  )) {
    i.hlGroup = `DefxIcoFg_${i.term_color}`;
    colors.add(i.term_color);
  }
  for (const i of Object.values(
    defx_icons.icons.pattern_matches
  )) {
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
  const filename = import_path2.default.basename(filepath);
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

// src/utils/logger.ts
var import_coc9 = require("coc.nvim");
var import_path3 = __toESM(require("path"));
var Logger = class {
  constructor() {
    this.channel = import_coc9.window.createOutputChannel("coc-ext");
    this.detail = getcfg("log.detail", false) === true;
    this.level = getcfg("log.level", 1);
  }
  dispose() {
    return this.channel.dispose();
  }
  logLevel(level, value) {
    var _a;
    const now = /* @__PURE__ */ new Date();
    const str = stringify(value);
    if (this.detail) {
      const stack = (_a = new Error().stack) == null ? void 0 : _a.split("\n");
      if (stack && stack.length >= 4) {
        const re = /at ((.*) \()?([^:]+):(\d+):(\d+)\)?/g;
        const expl = re.exec(stack[3]);
        if (expl) {
          const file = import_path3.default.basename(expl[3]);
          const line = expl[4];
          this.channel.appendLine(
            `${now.toISOString()} ${level} [${file}:${line}] ${str}`
          );
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
  append(message) {
    const str = stringify(message);
    this.channel.append(str);
  }
};
var logger = new Logger();

// src/lists/rgfiles.ts
var RgfilesList = class extends import_coc10.BasicList {
  constructor(_nvim) {
    super();
    this.name = "rgfiles";
    this.description = "CocList for coc-ext-common (rg files)";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", async (item, context) => {
      await openFile(item.data["name"], {
        key: context.args[0]
      });
    });
    this.addAction("preview", async (item, context) => {
      const resp = await callShell(
        "rg",
        [
          "-B",
          "3",
          "-C",
          "3",
          "--color",
          "never",
          "--context-separator",
          "\\\\n================\\\\n",
          context.args[0],
          item.data["name"]
        ],
        void 0,
        { shell: true }
      );
      if (resp.exitCode != 0 || !resp.data) {
        logger.error("rg fail");
        return;
      }
      const lines = resp.data.toString().split("\n");
      this.preview({ bufname: item.data["name"], lines }, context);
      const prew_wid = await this.nvim.call("coc#list#get_preview", 0);
      await this.nvim.call("matchadd", [
        "Search",
        `\\v${context.args[0]}`,
        9,
        -1,
        { window: prew_wid }
      ]);
    });
    this.addAction("ctrl-x", this.actionOpenSplit);
  }
  async actionOpenSplit(item, context) {
    await openFile(item.data["name"], {
      open: "sp",
      key: context.args[0]
    });
  }
  async loadItems(context) {
    if (context.args.length == 0) {
      return null;
    }
    const pattern = `"${context.args[0].replace(/"/g, '\\"')}"`;
    const args = [
      "--files-with-matches",
      "--color",
      "never",
      "--count-matches",
      pattern
    ];
    const resp = await callShell("rg", args, void 0, { shell: true });
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
      const arr = i.split(":");
      const extname = import_path4.default.extname(arr[0]).slice(1);
      const icon = await getDefxIcon(extname, arr[0]);
      const label = `${icon.icon}  ${arr[0]}  [${arr[1]}]`;
      const offset0 = Buffer.byteLength(icon.icon);
      const offset1 = offset0 + 2 + Buffer.byteLength(arr[0]) + 2;
      items.push({
        label,
        data: { name: arr[0] },
        ansiHighlights: [
          {
            span: [0, offset0],
            hlGroup: icon.hlGroup ? icon.hlGroup : "Normal"
          },
          {
            span: [offset1, offset1 + arr[1].length + 2],
            hlGroup: "Number"
          }
        ]
      });
    }
    return items;
  }
};

// src/lists/rgwords.ts
var import_coc11 = require("coc.nvim");
var import_path5 = __toESM(require("path"));
var RgwordsList = class extends import_coc11.BasicList {
  constructor(_nvim) {
    super();
    this.name = "rgwords";
    this.description = "CocList for coc-ext-common (rg words)";
    this.defaultAction = "open";
    this.actions = [];
    this.addAction("open", async (item, context) => {
      await openFile(item.data["name"], {
        line: item.data["line"],
        key: context.args[0]
      });
    });
    this.addAction("preview", async (item, context) => {
      const resp = await callShell("cat", [item.data["name"]]);
      if (resp.exitCode != 0 || !resp.data) {
        return;
      }
      const lines = resp.data.toString().split("\n");
      this.preview(
        {
          lines,
          lnum: item.data["line"],
          bufname: item.data["name"]
        },
        context
      );
      const prew_wid = await this.nvim.call("coc#list#get_preview", 0);
      await this.nvim.call("matchadd", [
        "Search",
        `\\v${context.args[0]}`,
        9,
        -1,
        { window: prew_wid }
      ]);
      await this.nvim.call("matchadd", [
        "TermCursor",
        `\\%${item.data["line"]}l`,
        8,
        -1,
        { window: prew_wid }
      ]);
    });
    this.addAction("ctrl-x", this.actionOpenSplit);
  }
  async actionOpenSplit(item, context) {
    await openFile(item.data["name"], {
      open: "sp",
      key: context.args[0]
    });
  }
  async loadItems(context) {
    if (context.args.length == 0) {
      return null;
    }
    const pattern = `"${context.args[0].replace(/"/g, '\\"')}"`;
    const args = ["--color", "never", "--json", pattern];
    const resp = await callShell("rg", args, void 0, { shell: true });
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
      const match = JSON.parse(i);
      if (match.type != "match") {
        continue;
      }
      const filename = match.data.path.text;
      const line = match.data.line_number;
      const strline = line.toString();
      const extname = import_path5.default.extname(filename).slice(1);
      const icon = await getDefxIcon(extname, filename);
      const label = `${icon.icon}  ${filename}:${strline}:${match.data.lines.text}`;
      const offset0 = Buffer.byteLength(icon.icon);
      const offset1 = offset0 + 2 + Buffer.byteLength(filename);
      const offset2 = offset1 + 2 + strline.length;
      items.push({
        label,
        data: { name: filename, line },
        ansiHighlights: [
          {
            span: [0, offset0],
            hlGroup: icon.hlGroup ? icon.hlGroup : "Normal"
          },
          {
            span: [offset0, offset1],
            hlGroup: "Directory"
          },
          {
            span: [offset1, offset2],
            hlGroup: "Number"
          }
        ]
      });
    }
    return items;
  }
};

// src/formatter/clfformatter.ts
var import_coc12 = require("coc.nvim");

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
    const filepath = import_coc12.Uri.parse(document.uri).fsPath;
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
      setting["UseTab"] = options.insertSpaces ? false : true;
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
        import_coc12.TextEdit.replace(
          {
            start: { line: 0, character: 0 },
            end: { line: document.lineCount, character: 0 }
          },
          resp.data.toString()
        )
      ];
    }
    return [];
  }
};

// src/formatter/prettierformatter.ts
var import_coc13 = require("coc.nvim");
var filetype2Parser = {
  javascript: "babel-flow",
  xml: "html"
};
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
    const args = [];
    if (this.setting.args) {
      args.push(...this.setting.args);
    }
    const { nvim } = import_coc13.workspace;
    const filetype = await nvim.eval("&filetype");
    const parser = filetype2Parser[filetype];
    if (parser) {
      args.push(`--parser=${parser}`);
    } else {
      args.push(`--parser=${filetype}`);
    }
    const exec = this.setting.exec ? this.setting.exec : "prettier";
    const resp = await callShell(exec, args, document.getText());
    if (resp.exitCode != 0) {
      showNotification(`prettier fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("prettier ok", "formatter");
      return [
        import_coc13.TextEdit.replace(
          {
            start: { line: 0, character: 0 },
            end: { line: document.lineCount, character: 0 }
          },
          resp.data.toString()
        )
      ];
    }
    return [];
  }
};

// src/formatter/bazelformatter.ts
var import_coc14 = require("coc.nvim");
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
        import_coc14.TextEdit.replace(
          {
            start: { line: 0, character: 0 },
            end: { line: document.lineCount, character: 0 }
          },
          resp.data.toString()
        )
      ];
    }
    return [];
  }
};

// src/formatter/luaformatter.ts
var import_coc15 = require("coc.nvim");
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
    const resp = await callShell(
      exec,
      this.opts.concat(opts),
      document.getText()
    );
    if (resp.exitCode != 0) {
      showNotification(`lua-format fail, ret ${resp.exitCode}`, "formatter");
      if (resp.error) {
        logger.error(resp.error.toString());
      }
    } else if (resp.data) {
      showNotification("lua-format ok", "formatter");
      return [
        import_coc15.TextEdit.replace(
          {
            start: { line: 0, character: 0 },
            end: { line: document.lineCount, character: 0 }
          },
          resp.data.toString()
        )
      ];
    }
    return [];
  }
};

// src/formatter/shellformatter.ts
var import_coc16 = require("coc.nvim");
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
        import_coc16.TextEdit.replace(
          {
            start: { line: 0, character: 0 },
            end: { line: document.lineCount, character: 0 }
          },
          resp.data.toString()
        )
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
var import_https = __toESM(require("https"));
var import_http = __toESM(require("http"));

// src/utils/file.ts
var import_fs = __toESM(require("fs"));
async function fsAccess(path6, mode) {
  return new Promise((resolve) => {
    import_fs.default.access(path6, mode, (err) => {
      err ? resolve(new CocExtErrnoError(err)) : resolve(null);
    });
  });
}

// src/utils/http.ts
async function simpleHttpsProxy(host, port, target_host) {
  return new Promise((resolve) => {
    import_http.default.request({ host, port, path: target_host, method: "CONNECT" }).on("connect", (resp, socket, _head) => {
      if (resp.statusCode == 200) {
        resolve({ agent: new import_https.default.Agent({ socket }) });
      } else {
        resolve({
          error: new CocExtError(CocExtError.ERR_HTTP, "connect fail")
        });
      }
    }).on("error", (error) => {
      resolve({ error });
    }).end();
  });
}
async function simpleHttpRequest(opts, is_https, data) {
  const request = is_https ? import_https.default.request : import_http.default.request;
  return new Promise((resolve) => {
    const req = request(opts, (resp) => {
      const buf = [];
      resp.on("data", (chunk) => {
        buf.push(chunk);
      }).on("end", () => {
        resolve({
          statusCode: resp.statusCode,
          headers: resp.headers,
          body: Buffer.concat(buf)
        });
      });
    }).on("error", (error) => {
      resolve({
        error
      });
    }).on("timeout", () => {
      resolve({
        error: new CocExtError(
          CocExtError.ERR_HTTP,
          `query ${opts.hostname ? opts.hostname : opts.host} timeout`
        )
      });
    });
    if (data) {
      req.write(data);
    }
    req.end();
  });
}
async function genHttpRequestArgs(req) {
  if (!req.proxy) {
    return req.args;
  } else if (req.args.protocol == "https:") {
    const agent = await simpleHttpsProxy(
      req.proxy.host,
      req.proxy.port,
      `${req.args.host}:${req.args.port ? req.args.port : 443}`
    );
    if (agent.error) {
      return agent.error;
    }
    const opts = Object.assign({}, req.args);
    opts.agent = agent.agent;
    return opts;
  } else {
    const opts = Object.assign({}, req.args);
    opts.headers = Object.assign({}, req.args.headers);
    var path6 = `http://${req.args.host}`;
    if (opts.port) {
      path6 += `:${opts.port}`;
    }
    if (opts.path) {
      path6 += opts.path;
    }
    opts.host = req.proxy.host;
    opts.port = req.proxy.port;
    opts.path = path6;
    opts.headers.Host = req.args.host;
    return opts;
  }
}
async function sendHttpRequest(req) {
  const res = await genHttpRequestArgs(req);
  if (res instanceof Error) {
    return { error: res };
  } else {
    return simpleHttpRequest(res, req.args.protocol == "https:", req.data);
  }
}
async function sendHttpRequestWithCallback(req, cb) {
  const res = await genHttpRequestArgs(req);
  if (res instanceof Error) {
    return res;
  } else {
    return new Promise((resolve) => {
      const request = req.args.protocol == "https:" ? import_https.default.request : import_http.default.request;
      const r = request(res, (resp) => {
        resp.on("data", (chunk) => {
          if (cb.onData) {
            cb.onData(chunk, resp);
          }
        }).on("end", () => {
          if (cb.onEnd) {
            cb.onEnd(resp);
          }
          resolve(null);
        });
      }).on("error", (error) => {
        if (cb.onError) {
          cb.onError(error);
        }
        resolve(error);
      }).on("timeout", () => {
        if (cb.onTimeout) {
          cb.onTimeout();
        }
        resolve(
          new CocExtError(
            CocExtError.ERR_HTTP,
            `query ${req.args.host} timeout`
          )
        );
      });
      if (req.data) {
        r.write(req.data);
      }
      r.end();
    });
  }
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
async function bingTranslate(text, sl, tl, proxy_url) {
  const proxy = proxy_url ? { host: proxy_url.hostname, port: parseInt(proxy_url.port) } : void 0;
  const req = {
    args: {
      host: "cn.bing.com",
      path: `/dict/SerpHoverTrans?q=${encodeURIComponent(text)}`,
      method: "GET",
      timeout: 1e3,
      headers: {
        Host: "cn.bing.com",
        Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5"
      },
      protocol: "https:"
    },
    proxy
  };
  const resp = await sendHttpRequest(req);
  if (resp.error) {
    logger.error(resp.error.message);
    return null;
  }
  if (resp.statusCode != 200 || !resp.body || resp.body.length == 0) {
    logger.error(`bing, status: ${resp.statusCode}`);
    return null;
  }
  const ret = createTranslation("Bing", sl, tl, text);
  ret.paraphrase = getParaphrase(resp.body.toString());
  return ret;
}

// src/utils/debug.ts
var import_coc19 = require("coc.nvim");

// src/lightbulb/lightbulb.ts
var import_coc17 = require("coc.nvim");

// src/utils/symbol.ts
var import_coc18 = require("coc.nvim");
var symbolKind2Info = {
  1: { name: "File", icon: "\uF40E", short_name: "F" },
  2: { name: "Module", icon: "\uF0E8", short_name: "M" },
  3: { name: "Namespace", icon: "\uF668", short_name: "N" },
  4: { name: "Package", icon: "\uF487", short_name: "P" },
  5: { name: "Class", icon: "\uF0E8", short_name: "C" },
  6: { name: "Method", icon: "\uE79B", short_name: "f" },
  7: { name: "Property", icon: "\uFAB6", short_name: "p" },
  8: { name: "Field", icon: "\uF9BE", short_name: "m" },
  9: { name: "Constructor", icon: "\uF425", short_name: "c" },
  10: { name: "Enum", icon: "\uF435", short_name: "E" },
  11: { name: "Interface", icon: "\uF417", short_name: "I" },
  12: { name: "Function", icon: "\u0192", short_name: "f" },
  13: { name: "Variable", icon: "\uE79B", short_name: "v" },
  14: { name: "Constant", icon: "\uF8FE", short_name: "C" },
  15: { name: "String", icon: "\uF672", short_name: "S" },
  16: { name: "Number", icon: "\uF89F", short_name: "n" },
  17: { name: "Boolean", icon: "", short_name: "b" },
  18: { name: "Array", icon: "\uF669", short_name: "a" },
  19: { name: "Object", icon: "\uF0E8", short_name: "O" },
  20: { name: "Key", icon: "\uF805", short_name: "K" },
  21: { name: "Null", icon: "\uFCE0", short_name: "n" },
  22: { name: "EnumMember", icon: "\uF02B", short_name: "m" },
  23: { name: "Struct", icon: "\uFB44", short_name: "S" },
  24: { name: "Event", icon: "\uFACD", short_name: "e" },
  25: { name: "Operator", icon: "\u03A8", short_name: "o" },
  26: { name: "TypeParameter", icon: "\uF671", short_name: "T" }
};
async function getDocumentSymbols(bufnr0) {
  const { nvim } = import_coc18.workspace;
  const bufnr = bufnr0 ? bufnr0 : await nvim.call("bufnr", ["%"]);
  const doc = import_coc18.workspace.getDocument(bufnr);
  if (!doc || !doc.attached) {
    return null;
  }
  if (!import_coc18.languages.hasProvider("documentSymbol", doc.textDocument)) {
    return null;
  }
  const tokenSource = new import_coc18.CancellationTokenSource();
  const { token } = tokenSource;
  const docSymList = await import_coc18.languages.getDocumentSymbol(
    doc.textDocument,
    token
  );
  return docSymList;
}
async function getCursorSymbolList() {
  const docSymList = await getDocumentSymbols();
  if (!docSymList) {
    return null;
  }
  const pos = await import_coc18.window.getCursorPosition();
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
async function debug(cmd, ...args) {
  logger.debug(cmd);
  logger.debug(args);
  let channel = import_coc19.window.createOutputChannel("debug");
  channel.show();
  for (let i = 0; i < 100; ++i) {
    channel.appendLine(`=> ${i}`);
    await sleepMs(50);
  }
}

// src/utils/decoder.ts
var import_util = require("util");
function decodeMimeEncodeStr(str) {
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
      const decoder2 = new import_util.TextDecoder(charset);
      text += decoder2.decode(buf);
      charset = i[0];
      buf = i[1];
    }
  }
  const decoder = new import_util.TextDecoder(charset);
  text += decoder.decode(buf);
  return text;
}

// src/translators/google.ts
function getParaphrase2(obj) {
  const paraphrase = [];
  const dict = obj["dict"];
  if (dict) {
    const words = [];
    for (const i of dict) {
      const pos = i["pos"];
      for (const e of i["entry"]) {
        words.push(e["word"]);
      }
      const terms = words.join(", ");
      paraphrase.push(`${pos}: ${terms}`);
    }
  } else {
    for (const i of obj["sentences"]) {
      paraphrase.push(i["trans"]);
    }
  }
  return paraphrase.join("\n");
}
async function googleTranslate(text, sl, tl, proxy_url) {
  const host = "translate.google.com";
  const proxy = proxy_url ? { host: proxy_url.hostname, port: parseInt(proxy_url.port) } : void 0;
  const req = {
    args: {
      host,
      path: `/translate_a/single?client=gtx&sl=auto&tl=${tl}&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&dj=1&q=${encodeURIComponent(text)}`,
      method: "GET",
      timeout: 1e3,
      headers: {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"
      },
      protocol: "https:"
    },
    proxy
  };
  const resp = await sendHttpRequest(req);
  if (resp.error) {
    logger.error(resp.error.message);
    return null;
  }
  if (resp.statusCode != 200 || !resp.body || resp.body.length == 0) {
    logger.error(`google, status: ${resp.statusCode}`);
    return null;
  }
  const obj = JSON.parse(resp.body.toString());
  if (!obj) {
    return null;
  }
  const ret = createTranslation("Google", sl, tl, text);
  ret.paraphrase = getParaphrase2(obj);
  return ret;
}

// src/leaderf/highlight.ts
var import_coc20 = require("coc.nvim");
async function highlightSource() {
  const { nvim } = import_coc20.workspace;
  let str = await nvim.exec("verbose highlight", true);
  const hiinfos = parseHighlightInfo(str);
  let max_gn_len = 0;
  for (const i of hiinfos) {
    if (i.group_name.length > max_gn_len) {
      max_gn_len = i.group_name.length;
    }
  }
  let lines = [];
  for (const i of hiinfos) {
    const spaces = " ".repeat(max_gn_len - i.group_name.length + 2);
    lines.push(
      `${i.group_name}${spaces}xxx  ${i.desc}  <${i.last_set_file}:${i.line}>`
    );
  }
  const var_name = getRandomId("__coc_leader_highligt", "_");
  await nvim.setVar(var_name, lines);
  await nvim.command(`Leaderf! highlight ${var_name}`);
}

// src/leaderf/leaderf.ts
async function leader_recv(cmd, ..._args) {
  if (cmd == "highlight") {
    await highlightSource();
  }
}

// src/ai/kimi.ts
var import_coc22 = require("coc.nvim");

// src/ai/base.ts
var import_coc21 = require("coc.nvim");
var BaseAiChannel = class {
  constructor() {
    this.channel = null;
    this.bufnr = -1;
  }
  async showChannel(name, filetye) {
    if (!this.channel) {
      this.channel = import_coc21.window.createOutputChannel(name);
    }
    let { nvim } = import_coc21.workspace;
    let winid = await nvim.call("bufwinid", name);
    if (winid == -1) {
      this.channel.show();
      winid = await nvim.call("bufwinid", name);
      this.bufnr = await nvim.call("bufnr", name);
      await nvim.call("coc#compat#execute", [winid, "setl wrap"]);
      await nvim.call("win_execute", [winid, `set ft=${filetye}`]);
    } else {
      await nvim.call("win_gotoid", [winid]);
    }
    await nvim.call("win_execute", [winid, "norm G"]);
  }
};

// src/ai/kimi.ts
var KimiChat = class extends BaseAiChannel {
  constructor(refresh_token) {
    super();
    this.refresh_token = refresh_token;
    this.rtoken = refresh_token;
    this.chat_id = "";
    this.headers = {
      "Content-Type": "application/json",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.77 Safari/537.36 Edg/91.0.864.41",
      Origin: "https://kimi.moonshot.cn",
      Referer: "https://kimi.moonshot.cn/"
    };
    this.channel = null;
    this.name = "";
    this.winid = -1;
    this.bufnr = -1;
    this.urls = [];
  }
  async bufferLines() {
    const doc = import_coc22.workspace.getDocument(this.bufnr);
    if (doc == null) {
      return -1;
    }
    return (await doc.buffer.lines).length;
  }
  addUrl(url) {
    this.urls.push(url);
    return this.urls.length;
  }
  // private checkLineNr2Segment(line: number) {
  //   for (const i of this.segments) {
  //     if (i.start <= line && line <= i.end) {
  //       return i;
  //     }
  //   }
  //   return null;
  // }
  parseRefId(s) {
    const regex0 = new RegExp(/^\[\^([0-9]*)\^\]$/);
    const arr0 = regex0.exec(s);
    if (arr0 && arr0.length >= 2) {
      return { type: "ref_card", id: parseInt(arr0[1]) };
    }
    const regex1 = new RegExp(/^\[([0-9]*)\]$/);
    const arr1 = regex1.exec(s);
    if (arr1 && arr1.length >= 2) {
      return { type: "search_plus", id: parseInt(arr1[1]) };
    }
    return { type: "none", id: -1 };
  }
  async getRef() {
    const doc = await import_coc22.workspace.document;
    const pos = await import_coc22.window.getCursorPosition();
    const lines = await doc.buffer.lines;
    const line = lines[pos.line];
    if (!line) {
      return null;
    }
    let start = pos.character;
    while (start >= 0) {
      let ch = line[start];
      if (!ch || ch == "[")
        break;
      start -= 1;
    }
    if (start < 0) {
      return null;
    }
    let end = pos.character;
    while (end < line.length) {
      let ch = line[end];
      if (!ch || ch == "]")
        break;
      end += 1;
    }
    if (end >= line.length) {
      return null;
    }
    const text = line.substring(start, end + 1);
    const ref = this.parseRefId(text);
    if (ref.type == "none") {
      return null;
    } else if (ref.type == "ref_card") {
      const query = this.getRefCardQuery(pos, start, lines, ref.id);
      if (query == null) {
        return null;
      }
      const card = await this.refCard(query);
      if (card instanceof Error) {
        logger.error(card);
        return null;
      }
      let text2 = `${card.ref_doc.title}

${card.ref_doc.url}`;
      if (card.ref_doc.rag_segments) {
        text2 += "\n\n";
        for (const seg of card.ref_doc.rag_segments) {
          text2 += seg.text.replace(/<\/?label>/gi, "");
        }
      }
      return text2;
    } else if (ref.type == "search_plus") {
      if (ref.id > 0 && ref.id - 1 < this.urls.length) {
        return this.urls[ref.id - 1];
      }
    }
    return null;
  }
  getRefCardQuery(pos, start, lines, ref_id) {
    let line_start = pos.line - 1;
    let segment_id = "";
    for (; line_start >= 0; --line_start) {
      const l = lines[line_start];
      if (l.length > 6 && l.slice(0, 6) == ">> id:") {
        segment_id = l.slice(6).trim();
        break;
      }
    }
    if (segment_id.length == 0) {
      return null;
    }
    let index = 0;
    for (let i = line_start + 1; i <= pos.line; ++i) {
      const l = lines[i];
      for (let j = 0; j < l.length; ) {
        const p = l.indexOf("[^", j);
        if (p == -1) {
          break;
        }
        index += 1;
        if (pos.line == i && start == p) {
          return {
            idx_s: 1,
            idx_z: 0,
            index,
            ref_id,
            segment_id
          };
        } else {
          j = p + 1;
        }
      }
    }
    return null;
  }
  async openAutoScroll() {
    let { nvim } = import_coc22.workspace;
    this.winid = await nvim.call("bufwinid", `Kimi-${this.chat_id}`);
  }
  closeAutoScroll() {
    this.winid = -1;
  }
  getHeaders() {
    this.headers["X-Traffic-Id"] = Array.from(
      { length: 20 },
      () => Math.floor(Math.random() * 36).toString(36)
    ).join("");
    return this.headers;
  }
  append(text, newline = true) {
    if (this.channel) {
    } else if (this.chat_id && this.name) {
      this.channel = import_coc22.window.createOutputChannel(`Kimi-${this.chat_id}`);
    } else {
      return;
    }
    if (newline) {
      this.channel.appendLine(text);
    } else {
      this.channel.append(text);
    }
    if (this.winid != -1) {
      let { nvim } = import_coc22.workspace;
      nvim.call("win_execute", [this.winid, "norm G"]);
    }
  }
  appendUserInput(datetime, text) {
    this.append(`
>> ${datetime}`);
    let lines = text.split("\n");
    for (const i of lines) {
      this.append(`>> ${i}`);
    }
  }
  async show() {
    if (this.channel || this.chat_id && this.name) {
      await this.showChannel(`Kimi-${this.chat_id}`, "kimichat");
    }
  }
  async getAccessToken() {
    this.headers["Authorization"] = `Bearer ${this.rtoken}`;
    const refresh_req = {
      args: {
        host: "kimi.moonshot.cn",
        path: "/api/auth/token/refresh",
        method: "GET",
        protocol: "https:",
        headers: this.getHeaders(),
        timeout: 1e3
      }
    };
    const resp = await sendHttpRequest(refresh_req);
    if (resp.statusCode == 200 && resp.body) {
      const obj = JSON.parse(resp.body.toString());
      this.headers["Authorization"] = `Bearer ${obj["access_token"]}`;
    }
    return resp.statusCode ? resp.statusCode : -1;
  }
  getChatId() {
    return this.chat_id;
  }
  setChatIdAndName(chat_id, name) {
    this.chat_id = chat_id;
    this.name = name;
  }
  async sendHttpRequest(req) {
    if (!this.headers["Authorization"] && await this.getAccessToken() != 200) {
      return new CocExtError(CocExtError.ERR_AUTH, "[Kimi] Auth fail");
    }
    let resp = await sendHttpRequest(req);
    if (resp.statusCode == 401) {
      if (await this.getAccessToken() != 200) {
        return new CocExtError(CocExtError.ERR_AUTH, "[Kimi] Auth fail");
      }
      resp = await sendHttpRequest(req);
    }
    return resp;
  }
  async createChatId(name) {
    const req = {
      args: {
        host: "kimi.moonshot.cn",
        path: "/api/chat",
        method: "POST",
        protocol: "https:",
        headers: this.getHeaders(),
        timeout: 1e3
      },
      data: JSON.stringify({ name, is_example: false })
    };
    const resp = await this.sendHttpRequest(req);
    if (resp instanceof Error) {
      logger.error(resp);
      return -1;
    }
    if (resp.statusCode == 200 && resp.body) {
      const obj = JSON.parse(resp.body.toString());
      this.chat_id = obj["id"];
      this.name = name;
    }
    return resp.statusCode ? resp.statusCode : -1;
  }
  async chatList() {
    const req = {
      args: {
        host: "kimi.moonshot.cn",
        path: "/api/chat/list",
        method: "POST",
        protocol: "https:",
        headers: this.getHeaders(),
        timeout: 1e3
      },
      data: JSON.stringify({ kimiplus_id: "", offset: 0, size: 50 })
    };
    const resp = await this.sendHttpRequest(req);
    if (resp instanceof Error) {
      return resp;
    }
    if (resp.statusCode == 200 && resp.body) {
      let obj = JSON.parse(resp.body.toString());
      if (obj["items"]) {
        return obj["items"];
      } else {
        return [];
      }
    } else {
      return new CocExtError(
        CocExtError.ERR_KIMI,
        `[Kimi] statusCode: ${resp.statusCode}, error: ${resp.error}, path: ${req.args.path}`
      );
    }
  }
  async refCard(query) {
    const req = {
      args: {
        host: "kimi.moonshot.cn",
        path: "/api/chat/segment/v2/rag-refs",
        method: "POST",
        protocol: "https:",
        headers: this.getHeaders(),
        timeout: 1e3
      },
      data: JSON.stringify({ with_rag_segs: true, query: [query] })
    };
    const resp = await this.sendHttpRequest(req);
    if (resp instanceof Error) {
      return resp;
    }
    if (resp.statusCode == 200 && resp.body) {
      const obj = JSON.parse(resp.body.toString());
      return obj["items"][0];
    }
    return new CocExtError(
      CocExtError.ERR_KIMI,
      `query ref fail, path: ${req.args.path}`
    );
  }
  async chatScroll() {
    const req = {
      args: {
        host: "kimi.moonshot.cn",
        path: `/api/chat/${this.chat_id}/segment/scroll`,
        method: "POST",
        protocol: "https:",
        headers: this.getHeaders(),
        timeout: 1e3
      },
      data: JSON.stringify({ last: 50 })
    };
    const resp = await this.sendHttpRequest(req);
    if (resp instanceof Error) {
      return resp;
    }
    if (resp.statusCode == 200 && resp.body) {
      let obj = JSON.parse(resp.body.toString());
      if (obj["items"]) {
        return obj["items"];
      } else {
        return [];
      }
    } else {
      return new CocExtError(
        CocExtError.ERR_KIMI,
        `statusCode: ${resp.statusCode}, error: ${resp.error}, path: ${req.args.path}`
      );
    }
  }
  async chat(text) {
    if (this.chat_id.length == 0) {
      return;
    }
    this.appendUserInput((/* @__PURE__ */ new Date()).toISOString(), text);
    let statusCode = -1;
    const cb = {
      onData: (chunk, rsp) => {
        if (rsp.statusCode != 200) {
          return;
        }
        try {
          chunk.toString().split("\n").forEach((line) => {
            if (line.length == 0) {
              return;
            }
            const data = JSON.parse(line.slice(5));
            if (data.event == "cmpl") {
              if (data.text) {
                this.append(data.text, false);
              }
            } else if (data.event == "resp") {
              this.append(`>> id:${data.id}
`);
            } else if (data.event == "search_plus") {
              if (data.msg && data.msg.type == "get_res" && data.msg.title && data.msg.url) {
                const idx = this.addUrl(data.msg.url);
                this.append(`[${idx}] ${data.msg.title}`);
              }
            } else if (data.event == "all_done") {
              this.append(" (END)");
            }
          });
        } catch (e) {
          logger.error(e);
        }
      },
      onEnd: (rsp) => {
        statusCode = rsp.statusCode ? rsp.statusCode : -1;
      },
      onError: (err) => {
        this.append(" (ERROR) ");
        this.append(err.message);
        statusCode = -1;
      },
      onTimeout: () => {
        statusCode = -1;
      }
    };
    const req = {
      args: {
        host: "kimi.moonshot.cn",
        path: `/api/chat/${this.chat_id}/completion/stream`,
        method: "POST",
        protocol: "https:",
        headers: this.getHeaders()
      },
      data: JSON.stringify({
        messages: [
          {
            role: "user",
            content: text
          }
        ],
        refs: [],
        user_search: true
      })
    };
    await sendHttpRequestWithCallback(req, cb);
    if (statusCode == 401) {
      if (await this.getAccessToken() != 200) {
        logger.error("Authorization Expired");
        return;
      }
      await sendHttpRequestWithCallback(req, cb);
    }
    logger.info(statusCode);
  }
  // public async debug() {
  //   console.log(await this.getAccessToken());
  //   console.log(await this.createChatId('Kimi'));
  //   console.log(this.chat_id);
  //   const req: HttpRequest = {
  //     args: {
  //       host: 'kimi.moonshot.cn',
  //       path: `/api/chat/${this.chat_id}/completion/stream`,
  //       method: 'POST',
  //       protocol: 'https:',
  //       headers: this.getHeaders(),
  //     },
  //     data: JSON.stringify({
  //       messages: [
  //         {
  //           role: 'user',
  //           content: '你是翻译员，请翻译成中文：I has a pen',
  //         },
  //       ],
  //       refs: [],
  //       user_search: true,
  //     }),
  //   };
  //   sendHttpRequestWithCallback(req, {
  //     onData: (chunk: Buffer) => {
  //       console.log(chunk.toString());
  //     },
  //   });
  // }
};
var kimiChat = new KimiChat(
  process.env.MY_KIMI_REFRESH_TOKEN ? process.env.MY_KIMI_REFRESH_TOKEN : ""
);

// src/ai/groq.ts
var GroqChat = class extends BaseAiChannel {
  constructor(api_key) {
    super();
    this.api_key = api_key;
    this.headers = {
      Authorization: `Bearer ${this.api_key}`,
      "Content-Type": "application/json"
    };
    const proxy_url = getEnvHttpProxy(true);
    this.proxy = proxy_url ? { host: proxy_url.hostname, port: parseInt(proxy_url.port) } : void 0;
  }
  async show() {
    await this.showChannel("GroqChat", "groqchat");
  }
  async debug() {
    const req = {
      args: {
        host: "api.groq.com",
        path: "/openai/v1/chat/completions",
        method: "POST",
        protocol: "https:",
        headers: this.headers
      },
      data: JSON.stringify({
        messages: [
          {
            role: "user",
            content: "what is tiktoken?"
          }
        ],
        model: "llama-3.1-70b-versatile"
      }),
      proxy: this.proxy
    };
    const resp = await sendHttpRequest(req);
    if (resp.error) {
      logger.error(`query fail, ${resp.error.message}`);
      return null;
    }
    if (resp.statusCode != 200 || !resp.body || resp.body.length == 0) {
      logger.error(`groq, status: ${resp.statusCode}`);
      return null;
    }
    const obj = JSON.parse(resp.body.toString());
    logger.debug(obj);
  }
};
var groqChat = new GroqChat(
  process.env.MY_GROQ_API_KEY ? process.env.MY_GROQ_API_KEY : ""
);

// src/coc-ext-common.ts
var import_fs2 = __toESM(require("fs"));
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
var prettierFmtSetting = {
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
  bzl: bzlFmtSteeing,
  c: cppFmtSetting,
  cpp: cppFmtSetting,
  html: prettierFmtSetting,
  javascript: prettierFmtSetting,
  json: prettierFmtSetting,
  lua: luaFmtSteeing,
  markdown: prettierFmtSetting,
  sh: shFmtSetting,
  typescript: prettierFmtSetting,
  xml: prettierFmtSetting,
  yaml: prettierFmtSetting,
  zsh: shFmtSetting
};
async function replaceExecText(doc, range, res) {
  var _a;
  if (res.exitCode == 0 && res.data) {
    const ed = import_coc23.TextEdit.replace(range, res.data.toString("utf8"));
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
function hlPreview() {
  return async () => {
    const s = await getText("v");
    const regex = new RegExp(/(([c]?term|gui)([fb]g)?=[#\w0-9]*)/gi);
    const arr = Array.from(s.matchAll(regex), (m) => m[0]);
    if (arr.length == 0) {
      return;
    }
    const { nvim } = import_coc23.workspace;
    await nvim.exec(
      "hi HlPreview cterm=None ctermfg=None ctermbg=None gui=None guifg=None guibg=None"
    );
    let hl = "hi HlPreview";
    for (const i of arr) {
      hl += " ";
      hl += i;
    }
    await nvim.exec(hl);
    popup(
      "< TEXT text Text \n> TEXT text Text \n< TEXT text Text ",
      void 0,
      "hlpreview"
    );
  };
}
function translateFn(mode) {
  const proxy = getEnvHttpProxy(true);
  return async () => {
    const text = await getText(mode);
    let trans = await bingTranslate(text, "auto", "zh-CN", proxy);
    if (!trans) {
      trans = await googleTranslate(text, "auto", "zh-CN", proxy);
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
    const range = await import_coc23.window.getSelectedRange("v");
    if (!range) {
      return;
    }
    const pythonDir = getcfg("pythonDir", "");
    const doc = await import_coc23.workspace.document;
    const text = doc.textDocument.getText(range);
    const res = await callPython(pythonDir, "coder", "encode_str", [text, enc]);
    replaceExecText(doc, range, res);
  };
}
function addFormatter(context, lang, setting) {
  const selector = [{ scheme: "file", language: lang }];
  const provider = new FormattingEditProvider(setting);
  context.subscriptions.push(
    import_coc23.languages.registerDocumentFormatProvider(selector, provider, 1)
  );
  if (provider.supportRangeFormat()) {
    context.subscriptions.push(
      import_coc23.languages.registerDocumentRangeFormatProvider(selector, provider, 1)
    );
  }
}
async function groq_open() {
  await groqChat.show();
  await groqChat.debug();
  return 0;
}
async function kimi_open() {
  if (kimiChat.getChatId().length == 0) {
    let chat_list = await kimiChat.chatList();
    if (chat_list instanceof Error) {
      logger.error(chat_list);
      echoMessage("ErrorMsg", chat_list.message);
      return -1;
    }
    let items = chat_list.map((i) => {
      return { label: i.name, chat_id: i.id, description: i.updated_at };
    });
    items.push({ label: "Create", chat_id: "", description: "" });
    let choose = await import_coc23.window.showQuickPick(items, { title: "Choose Chat" });
    if (!choose || choose.chat_id.length == 0) {
      let new_name = await import_coc23.window.requestInput("Name", "", {
        position: "center"
      });
      if (new_name.length == 0) {
        return -1;
      }
      const statusCode = await kimiChat.createChatId(new_name);
      if (statusCode != 200) {
        logger.error(`createChatId fail, statusCode: ${statusCode}`);
        return -1;
      }
    } else {
      kimiChat.setChatIdAndName(choose.chat_id, choose.label);
      const items2 = await kimiChat.chatScroll();
      if (items2 instanceof Error) {
        logger.error(items2);
      } else {
        for (const item of items2) {
          if (item.role == "user") {
            kimiChat.appendUserInput(item.created_at, item.content);
          } else {
            kimiChat.append(`>> id:${item.id}
`);
            if (item.search_plus) {
              for (const search of item.search_plus) {
                if (search.msg.type == "get_res") {
                  let idx = -1;
                  if (search.msg.url) {
                    idx = kimiChat.addUrl(search.msg.url);
                  }
                  kimiChat.append(`[${idx}] ${search.msg.title}`);
                }
              }
              kimiChat.append("");
            }
            kimiChat.append(item.content);
          }
        }
      }
    }
  }
  await kimiChat.show();
  return 0;
}
function kimi_chat(mode) {
  return async () => {
    const text = await getText(mode);
    let ret = await kimi_open();
    if (ret != 0) {
      return;
    }
    await kimiChat.openAutoScroll();
    await kimiChat.chat(text);
    kimiChat.closeAutoScroll();
  };
}
function kimi_ref() {
  return async () => {
    const text = await kimiChat.getRef();
    if (text) {
      popup(text, "", "markdown");
    }
  };
}
async function activate(context) {
  context.logger.info(`coc-ext-common works`);
  logger.info(`coc-ext-common works`);
  logger.info(import_coc23.workspace.getConfiguration("coc-ext.common"));
  logger.info(process.env.COC_VIMCONFIG);
  const err = await fsAccess("/tmp/not_exist", import_fs2.default.constants.F_OK);
  logger.debug(err instanceof Error);
  const langFmtSet = /* @__PURE__ */ new Set();
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
  context.subscriptions.push(
    // {
    //   dispose() {
    //     clearInterval(timer);
    //   },
    // },
    import_coc23.commands.registerCommand("ext-debug", debug, { sync: true }),
    import_coc23.commands.registerCommand("ext-groq", groq_open, { sync: true }),
    import_coc23.commands.registerCommand("ext-kimi", kimi_open, { sync: true }),
    import_coc23.commands.registerCommand("ext-leaderf", leader_recv, { sync: true }),
    import_coc23.workspace.registerKeymap(["n"], "ext-cursor-symbol", getCursorSymbolInfo, {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["n"], "ext-translate", translateFn("n"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-translate-v", translateFn("v"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-kimi", kimi_chat("v"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["n"], "ext-kimi-ref", kimi_ref(), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-encode-utf8", encodeStrFn("utf8"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-encode-gbk", encodeStrFn("gbk"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-decode-utf8", decodeStrFn("utf8"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(["v"], "ext-decode-gbk", decodeStrFn("gbk"), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(
      ["v"],
      "ext-decode-base64",
      decodeStrFn("base64"),
      {
        sync: false
      }
    ),
    import_coc23.workspace.registerKeymap(["v"], "ext-hl-preview", hlPreview(), {
      sync: false
    }),
    import_coc23.workspace.registerKeymap(
      ["v"],
      "ext-copy-xclip",
      async () => {
        const text = await getText("v", false);
        await callShell("xclip", ["-selection", "clipboard", "-i"], text);
      },
      { sync: false }
    ),
    import_coc23.workspace.registerKeymap(
      ["v"],
      "ext-change-name-rule",
      async () => {
        const range = await import_coc23.window.getSelectedRange("v");
        if (!range) {
          return;
        }
        const pythonDir = getcfg("pythonDir", "");
        const doc = await import_coc23.workspace.document;
        const name = doc.textDocument.getText(range);
        const res = await callPython(pythonDir, "common", "change_name_rule", [
          name
        ]);
        replaceExecText(doc, range, res);
      },
      {
        sync: false
      }
    ),
    import_coc23.workspace.registerKeymap(
      ["v"],
      "ext-decode-mime",
      async () => {
        const text = await getText("v");
        const tt = decodeMimeEncodeStr(text);
        popup(tt, "[Mime decode]");
      },
      {
        sync: false
      }
    ),
    import_coc23.listManager.registerList(new ExtList(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new Commands(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new MapkeyList(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new RgfilesList(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new RgwordsList(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new AutocmdList(import_coc23.workspace.nvim)),
    import_coc23.listManager.registerList(new HighlightList(import_coc23.workspace.nvim))
    // sources.createSource({
    //   name: 'coc-ext-common completion source', // unique id
    //   doComplete: async () => {
    //     const items = await getCompletionItems();
    //     return items;
    //   },
    // })
    // workspace.registerAutocmd({
    //   event: 'InsertLeave',
    //   request: true,
    //   callback: () => {
    //     window.showMessage(`registerAutocmd on InsertLeave`);
    //   },
    // })
  );
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  activate
});
