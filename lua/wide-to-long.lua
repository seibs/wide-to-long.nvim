local ts_parsers = require("nvim-treesitter.parsers")
local ts_queries = require("nvim-treesitter.query")
local ts_utils = require("nvim-treesitter.ts_utils")


local function isin(element, table)
    for idx, value in ipairs(table) do
        if element == value then
            return true
        end
    end
    return false
end


local function find_current_function_node()
    local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
    local wtl_query = ts_queries.get_query(filelang, "wide-to-long")

	local node = ts_utils.get_node_at_cursor()

    -- TODO will different languages need different stopping conditions here?
    while node and not isin(node:type(), {"module", "block"}) do
        for capture_id, capture_node, meta in wtl_query:iter_captures(node, 0) do
            if wtl_query.captures[capture_id] == "target-node" then
                return node
            end
        end
        node = node:parent()
    end 
end


local M = {}


function M.init()
  require("nvim-treesitter").define_modules {
    module_template = {
      module_path = "wide-to-long.internal",
      is_supported = function(lang)
        return ts_queries.get_query(lang, "wide-to-long") ~= nil
      end
    }
  }
end


function M.wide_to_long()
    local shiftwidth = vim.api.nvim_eval("&shiftwidth")
    local function_node = find_current_function_node()
    if function_node ~= nil then
        local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
        local wtl_query = ts_queries.get_query(filelang, "wide-to-long")

        local indent_level = 0
        for capture_id, capture_node, meta in wtl_query:iter_captures(function_node, 0) do
            if wtl_query.captures[capture_id] == "target-node" then
                _, indent_level, _, _ = capture_node:range()
            end
            if wtl_query.captures[capture_id] == "args" then
                local replacement = {}
                table.insert(replacement, "")
                for idx, child in ipairs(ts_utils.get_named_children(capture_node)) do
                    table.insert(
                        replacement,
                        string.format("%" .. indent_level + shiftwidth .. "s", "")
                        .. vim.treesitter.query.get_node_text(child, 0)
                        .. ","
                    )
                end
                table.insert(replacement, string.format("%" .. indent_level .. "s", ""))
                local start_row, start_col, end_row, end_col = capture_node:range()
                vim.api.nvim_buf_set_text(
                    0,
                    start_row, start_col + 1,
                    end_row, end_col - 1,
                    replacement
                )
                return 
            end
        end
    end
end


function M.long_to_wide()
    local shiftwidth = vim.api.nvim_eval("&shiftwidth")
    local function_node = find_current_function_node()
    if function_node ~= nil then
        local filelang = ts_parsers.ft_to_lang(vim.bo.filetype)
        local wtl_query = ts_queries.get_query(filelang, "wide-to-long")

        local indent_level = 0
        for capture_id, capture_node, meta in wtl_query:iter_captures(function_node, 0) do
            if wtl_query.captures[capture_id] == "args" then
                local single_line_args = ""
                for idx, child in ipairs(ts_utils.get_named_children(capture_node)) do
                    single_line_args = (
                        single_line_args
                        .. vim.treesitter.query.get_node_text(child, 0)
                        .. ", "
                    )
                end
                local start_row, start_col, end_row, end_col = capture_node:range()
                vim.api.nvim_buf_set_text(
                    0,
                    start_row, start_col + 1,
                    end_row, end_col - 1,
                    {single_line_args:sub(1, -3)}
                )
                return 
            end
        end
    end
end

return M
