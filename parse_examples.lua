#!/usr/bin/env -S nvim -l

local lang = "vimdoc"
local query = vim.treesitter.query.parse(lang, [[
  (codeblock
    (language) @_lang
    (_) @code
    (#match? @_lang "lua")
  )
]])

local function parse(filepath, name)
  local source = vim.fn.readblob(filepath)
  local parser = vim.treesitter.get_string_parser(source, lang)

  local tree = parser:parse()[1]
  local root = tree:root()

  for id, node, metadata in query:iter_captures(root, source, 0, -1) do
    local capture_name = query.captures[id]
    if capture_name == 'code' then
      local example = vim.treesitter.get_node_text(node, source)
      local lua_parser = vim.treesitter.get_string_parser(example, 'lua')
      local lua_tree = lua_parser:parse()[1]
      local lua_root = lua_tree:root()
      if lua_root:has_error() then
        print('---', name, node:range())
        print(example)
      end
    end
  end
end

local doc_dir = vim.fs.joinpath('runtime', 'doc')

for name in vim.fs.dir(doc_dir) do
  parse(vim.fs.joinpath(doc_dir, name), name)
end
