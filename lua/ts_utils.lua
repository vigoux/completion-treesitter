-- Treesitter utils

local api = vim.api
local ts = vim.treesitter

local M = {
}

local function read_query_file(fname)
  return table.concat(vim.fn.readfile(fname), '\n')
end

function M.get_query(ft, query_name)
  local query_files = api.nvim_get_runtime_file(string.format('queries/%s/%s.scm', ft, query_name), false)
  if #query_files > 0 then
    return ts.parse_query(ft, read_query_file(query_files[1]))
  end
end

function M.prepare_match(query, match)
  local object = {}
  for id, node in pairs(match) do
    local name = query.captures[id] -- name of the capture in the query
    if string.len(name) == 1 then
      object.kind = name
      object.full = node
    else
      object[name] = node
    end
  end

  return object
end

local function get_parser(bufnr)
  if M.has_parser() then
    local buf = bufnr or api.nvim_get_current_buf()
    if not M[buf] then
      local parser = ts.get_parser(0)
      M[buf] = {parser=parser, cache={}};
    end
    return M[buf].parser
  end
end

function M.get_definition(tree, node)
  local parser = get_parser()
  local node_text = M.get_node_text(node)
  local final_query = M.prepare_def_query(string.format('(eq? @def "%s")', node_text))

  local tsquery = ts.parse_query(parser.lang, final_query)
  local row_start, _, row_end, _ = tree:range()
  local _, _, node_start = node:start()
  -- Get current context, and search upwards
  local current_context = node
  repeat
    current_context = M.smallestContext(tree, current_context)
    for _, match in tsquery:iter_matches(current_context, parser.bufnr, row_start, row_end) do
      local prepared = M.prepare_match(tsquery, match)
      local def = prepared.def
      local _, _, def_start = def:start()

      if def_start <= node_start then
        return def, current_context
      end
    end

    current_context = current_context:parent()
  until current_context == nil

  return node, tree
end

function M.prepare_def_query(ident_text)
  local def_query = api.nvim_buf_get_var(0, 'completion_def_query')
  local final_query = ""

  for _, subquery in ipairs(def_query) do
    final_query = final_query .. string.format("(%s %s)", subquery, ident_text)
  end

  return final_query
end

-- Copied from runtime treesitter.lua
function M.get_node_text(node, bufnr, line)
  local start_row, start_col, end_row, end_col = node:range()
  if start_row ~= end_row then
    local index
    if line ~= nil and line >= start_row then
      index = line - start_row + 1
    else
      index = 1
    end
    return api.nvim_buf_get_lines(bufnr, start_row, end_row, false)[line or 1]
  else
    local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row+1, true)[1]
    return string.sub(line, start_col+1, end_col)
  end
end

function M.tree_root(bufnr)
  return get_parser(bufnr):parse():root()
end

function M.has_parser(lang)
  local lang = lang or api.nvim_buf_get_option(0, 'filetype')
  return #lang > 0 and #api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
end

-- is dest in a parent of source
function M.is_parent(source, dest)
  local current = source
  while current ~= nil do
    if current == dest then
      return true
    end

    current = current:parent()
  end

  return false
end

function M.expression_at_point(tsroot)
  local tsroot = tsroot or M.tree_root()

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_node = tsroot:named_descendant_for_range(cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2])
  return current_node
end

function M.smallestContext(tree, source)
  -- Step 1 get current context
  local contexts = api.nvim_buf_get_var(get_parser().bufnr, 'completion_context_query')
  local current = source
  while current ~= nil and not vim.tbl_contains(contexts, current:type()) do
    current = current:parent()
  end

  return current or tree
end

function M.parse_query(query)
  return ts.parse_query(get_parser().lang, query)
end

return M
