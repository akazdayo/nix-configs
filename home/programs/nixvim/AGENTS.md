# home/programs/nixvim

**Generated:** 2026-05-19 | **Commit:** 94337f6
Parent: [root AGENTS.md](../../../AGENTS.md)

## OVERVIEW

NixVim configuration — 23 files across 4 levels of nesting, organized by concern (opts, keymaps, LSP, plugins) and plugin category (editor, UI, other).

## STRUCTURE

```
home/programs/nixvim/
├── default.nix              # Entry: imports nixvim-module + all sub-modules
├── colorscheme.nix          # Catppuccin with transparency
├── keymaps.nix              # Global non-plugin keymaps
├── lsp.nix                  # LSP servers (12) + LSP keymaps
├── opts.nix                 # Editor options (encoding, listchars, clipboard)
└── plugins/
    ├── default.nix          # Imports ui/, other/, editor/
    ├── editor/              # Coding plugins (8)
    │   ├── default.nix
    │   ├── telescope.nix    # Fuzzy finder (+ keymaps)
    │   ├── treesitter.nix
    │   ├── cmp.nix          # Completions
    │   ├── gitsigns.nix
    │   ├── comment.nix
    │   ├── nvim-autopairs.nix
    │   ├── lsp-signature.nix
    │   └── copilot.nix
    ├── ui/                  # UI plugins (6)
    │   ├── default.nix
    │   ├── lualine.nix
    │   ├── neo-tree.nix     # File tree (+ keymaps)
    │   ├── which-key.nix
    │   ├── web-devicons.nix
    │   ├── indent-blankline.nix
    │   └── smear-cursor.nix
    └── other/               # Miscellaneous (1)
        ├── default.nix
        └── neocord.nix
```

## WHERE TO LOOK

| Task            | Location                        | Notes                                        |
| --------------- | ------------------------------- | -------------------------------------------- |
| Add a plugin    | `plugins/<category>/<name>.nix` | Register in `plugins/<category>/default.nix` |
| Add LSP server  | `lsp.nix`                       | Add to `plugins.lsp.servers` attrset         |
| Global keybind  | `keymaps.nix`                   | Plugin-specific keybinds go in plugin file   |
| Editor settings | `opts.nix`                      |                                              |

## CONVENTIONS

- **One file per plugin** — even for 4-line configs. Category determines subdirectory: `editor/` (coding), `ui/` (appearance), `other/` (integration).
- **Plugin registration**: Add to `plugins/<category>/default.nix` `imports` list. File naming uses lowercase kebab-case matching plugin name.
- **Plugins use `programs.nixvim.plugins.<name>` API**, not `extraPlugins` + Lua. Some plugins require `settings` sub-attr, others set options directly.
- **Keymaps co-located with plugin**: Telescope and neo-tree define their keymaps in the same file as plugin config. LSP keymaps live in `lsp.nix`. Global keymaps in `keymaps.nix`.
- **Raw Lua via `__raw`**: For Lua expressions that can't be expressed in Nix attrs, use `action.__raw = "..."` (only in `lsp.nix` currently).
- **Imported via `nixvim-module` specialArg**, not directly from `inputs.nixvim` — this isolates the nixvim dependency.
- **Japanese encoding**: `opts.nix` includes `sjis`, `euc-jp`, `iso-2022-jp` in `fileencodings`.

## ANTI-PATTERNS

- Using `extraPlugins` + Lua instead of `programs.nixvim.plugins.<name>` (first check if a native module exists).
- Mixing `plugins.<name>` pattern with `plugins = { <name>.enable = true; }` — choose the direct attr path form consistently.
- Omitting plugin file from `default.nix` — all new plugin files must be registered in their category's `default.nix`.

## NOTES

- This config is the **deepest subtree** in the project (4 levels: nixvim → plugins → category → individual plugins).
- The `nixvim-module` specialArg passthrough pattern is unique to this subtree — no other home-manager module uses this indirection.
- `.agents/skills/nixvim-add-plugin/SKILL.md` documents the workflow for adding or migrating plugins.
