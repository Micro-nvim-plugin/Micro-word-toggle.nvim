local M = {}

-- Define the default 'antonym' dictionary
-- This is a simple Lua table, with the original wotd on the left and the replacement word on the right
local default_cycles = {
  -- basic boolean
  {"true", "false"},
  {"yes", "no"},
  {"on", "off"},
  {"open", "close"},

  -- compare symbol
  {"and", "or"},

  {"<", ">"},
  {"<=", ">="},
  {"==", "!="},
  {"&&", "||"},
  {"&", "|"},

  -- other
  -- log level
  {"debug", "info", "warn", "error"},
  -- variable Modifier
  {"public", "private", "protected"},
  -- todo status
  {"todo", "fixme", "note", "hack", "bug"}
}

-- Allow users to customize settings (merging the default dictionary with the user dictionary)
M.config = {
	dict = {},
}

M.setup = function(opts)
	-- If the user provides pairs, we merge them into the config
	-- (simplified here, ethier by directly overwriting or appending)
	opts = opts or {}

  local all_cycles = vim.list_extend({}, default_cycles)
  if opts.dict then
    vim.list_extend(all_cycles, opts.dict)
  end

  local lookup = {}
  for _, group in ipairs(all_cycles) do
    for i, word in ipairs(group) do
      -- Unify the word to lowercase
      local current_word = word:lower()

      local next_index = (i % #group) + 1
      local next_val = group[next_index]:lower()
      lookup[current_word] = next_val
    end
  end

	M.config.dict = lookup;
end

-- Helper function: Adjust new_word according to the case of the first letter of old_word
-- such as "True" -> "False" if dictionary has "true" -> "false" and the word to be replaced is "True"
local function match_case(old_word, new_word)
	-- if the word is uppercase then keep it uppercase
	if old_word == old_word:upper() then
		return new_word:upper()
	end

	if old_word:sub(1, 1):match("%u") then
		return new_word:sub(1, 1):upper() .. new_word:sub(2)
	end

	return new_word
end

M.toggle = function()
	-- Get the current word under the cursor
	local word = vim.fn.expand("<cword>")
	local key = word:lower()

	-- If the word is in the dictionary, toggle it
	local replacement = M.config.dict[key]

	if replacement then
		local final_word = match_case(word, replacement)
		vim.cmd('normal! "_ciw' .. final_word)
	else
		print("Micro-toggle: No toggle found. Word='"..word.."' Key='"..key.."' Found='"..(replacement or "nil").."'")
	end
end

return M
