# Which-key

Plugin spec in `lua/default/plugins.lua`. There is deliberately **no** `after/plugin/which-key.lua` — the whole configuration is the spec's `opts`, so lazy.nvim owns the `setup()` call and the `VeryLazy` gate.

## Purpose

After a prefix, which-key pops up the possible continuations with the `desc` of each mapping. This config declares **79 `<leader>` mappings in normal mode alone**, or 100 counting every mode plus the buffer-local ones present in a given buffer — so it replaces having to remember them.

The tree is lopsided, which is exactly why a popup helps. Counting normal-mode globals per prefix: `<leader>s` 22 (21 telescope pickers plus the substitute-word map), `<leader>t` 11 (neotest), `<leader>p` 8 (split between telescope, goto-preview and netrw), `<leader>g` 7, `<leader>n` 7 (noice), `<leader>v` 3, and the rest one or two each. On top of that, xcodebuild contributes 19 (18 normal + 1 visual) that are buffer-local to Swift/ObjC — they show up in the 100, never in the 79.

> **`timeoutlen` was deliberately not lowered**, and stays at its default of 1000. The temptation with a leader tree this deep is to shorten the wait. But the wait was never the problem: the problem was not knowing which key comes next, and a shorter `timeoutlen` only makes the ambiguity resolve faster — it tells you nothing. Worse, a short window makes deliberately-typed sequences *fail*. which-key answers the actual question instead. The keymap moves that *were* made (see [keymaps.md](keymaps.md#recent-moves-and-why)) are a different fix for a different problem — a complete mapping sitting on a prefix, which costs the timeout on *every* use.

## Spec

| Option | Value | Effect |
|---|---|---|
| `event` | `VeryLazy` | Loads after startup is done. It does not appear in the startup profile at all — zero measured cost |
| `preset` | `helix` | Bottom-anchored, full-width popup, in the style of the Helix editor |
| `delay` | function | `0` when you are already mid-sequence, `200` ms on the first press |

```lua
delay = function(ctx)
    return ctx.plugin and 0 or 200
end
```

The two values are the point: the first press still behaves like plain Vim (press and go, no popup flashing at you), but once the popup is open the next level appears instantly.

## Groups

Registered through `opts.spec`. Descriptions of individual keys come from the `desc` on each `vim.keymap.set` call, not from here — this table only names the prefixes.

| Prefix | Group | Mode |
|---|---|---|
| `<leader>a` | diagnostics / harpoon | n |
| `<leader>c` | code | n |
| `<leader>D` | debug UI | n |
| `<leader>F` | flutter | n |
| `<leader>g` | git / goto | n |
| `<leader>l` | lsp toggles | n |
| `<leader>m` | lint | n |
| `<leader>n` | noice | n |
| `<leader>s` | search (telescope) | n |
| `<leader>t` | test | n |
| `<leader>v` | view / edit config | n |
| `<leader>x` | xcodebuild | n, v |

`<leader>x` is the only group declared for visual mode as well, because `<leader>xt` (run selected tests) has a visual-mode mapping — see [swift.md](../languages/swift.md).

> **A prefix does not need to be in this table to work.** which-key discovers every mapping on its own and shows its `desc`; a group entry only adds a human-readable label for the prefix itself. Prefixes owning a single mapping — `<leader>e` (neo-tree), `<leader>f` (format), `<leader>u` (undotree), `<leader>A` (harpoon add), `<leader>X` (xcodebuild picker) — have nothing to label. `<leader>p` and `<leader>r` do have several members each but no group, because what they hold is mixed (find-files, paste and netrw under `p`; rename and restart-LSP under `r`) and no single name describes them.

## Commands

| Command | Action |
|---|---|
| `:WhichKey` | Show all mappings |
| `:WhichKey <prefix>` | Show the mappings under one prefix |
| `:checkhealth which-key` | Reports mappings with no `desc`, and duplicate or overlapping keys |

> `:checkhealth which-key` is the quickest way to find a keymap that was added without a `desc` — it shows up in the popup as a bare right-hand side otherwise.
