var __create = Object.create;
var __defProp = Object.defineProperty;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __markAsModule = (target) => __defProp(target, "__esModule", {value: true});
var __export = (target, all) => {
  __markAsModule(target);
  for (var name in all)
    __defProp(target, name, {get: all[name], enumerable: true});
};
var __exportStar = (target, module2, desc) => {
  __markAsModule(target);
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
  return __exportStar(__defProp(module2 != null ? __create(__getProtoOf(module2)) : {}, "default", {value: module2, enumerable: true}), module2);
};

// src/index.ts
__export(exports, {
  activate: () => activate
});
var import_coc3 = __toModule(require("coc.nvim"));

// src/commands/manager.ts
var import_coc2 = __toModule(require("coc.nvim"));

// src/config.ts
var import_coc = __toModule(require("coc.nvim"));
function getcfg(key, defaultValue) {
  const config = import_coc.workspace.getConfiguration("ext");
  return defaultValue === void 0 ? void 0 : config.get(key, defaultValue);
}

// src/commands/manager.ts
var Manager = class {
  constructor(nvim) {
    this.nvim = nvim;
    this.floatwin = new import_coc2.FloatFactory(this.nvim);
  }
  setKeymapMode(mode) {
    this.keymapMode = mode;
    return this;
  }
  setActionMode(mode) {
    this.actionMode = mode;
    return this;
  }
  async show(text) {
    if (text == void 0 || !(text.trim().length > 0))
      text = await this.getText();
    if (!text)
      return;
    switch (this.actionMode) {
      case "popup":
        await this.popup(text);
        break;
      case "echo":
        await this.echo(text);
        break;
      case "replace":
        await this.replace(text);
        break;
      default:
        break;
    }
  }
  async getText() {
    const doc = await import_coc2.workspace.document;
    let range = null;
    if (this.keymapMode === "n") {
      const pos = await import_coc2.window.getCursorPosition();
      range = doc.getWordRangeAtPosition(pos);
    } else {
      range = await import_coc2.workspace.getSelectedRange("v", doc);
    }
    let text = "";
    if (!range) {
      text = (await import_coc2.workspace.nvim.eval('expand("<cword>")')).toString();
    } else {
      text = doc.textDocument.getText(range);
    }
    return text.trim();
  }
  async popup(content) {
    if (content.length == 0)
      return;
    const docs = [
      {
        content,
        filetype: "markdown"
      }
    ];
    await this.floatwin.show(docs, this.floatWinConfig);
  }
  async echo(content) {
    import_coc2.workspace.nvim.call("coc#util#echo_messages", ["MoreMsg", content.split("\n")], true);
  }
  async replace(content) {
    if (content.length == 0) {
      import_coc2.window.showMessage("No paraphrase for replacement", "error");
    }
    this.nvim.pauseNotification();
    this.nvim.command("let reg_tmp=@a", true);
    this.nvim.command(`let @a='${content}'`, true);
    this.nvim.command('normal! viw"ap', true);
    this.nvim.command("let @a=reg_tmp", true);
    await this.nvim.resumeNotification();
  }
  get floatWinConfig() {
    return {
      autoHide: true,
      border: getcfg("window.enableBorder") ? [1, 1, 1, 1] : [0, 0, 0, 0],
      close: false,
      maxHeight: getcfg("window.maxHeight"),
      maxWidth: getcfg("window.maxWidth")
    };
  }
};
var manager_default = Manager;

// src/index.ts
async function activate(context) {
  context.logger.info(`coc-ext works`);
  const {nvim} = import_coc3.workspace;
  const manager = new manager_default(nvim);
  context.subscriptions.push(import_coc3.commands.registerCommand("ext.text", async (text) => {
    await manager.setKeymapMode("n").setActionMode("popup").show(text);
  }, {sync: false}));
}
