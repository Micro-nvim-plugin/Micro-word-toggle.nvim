local M = {}

-- 1. Define the default 'antonym' dictionary
-- This is a simple Lua table, with the original wotd on the left and the replacement word on the right
local default_dict = {
	["true"] = "false",
	-- ["false"] = "true",
	["yes"] = "no",
	["max"] = "min",
}

-- Allow users to customize settings (merging the default dictionary with the user dictionary)
M.config = {
	dict = {},
}

M.setup = function(opts)
	-- If the user provides pairs, we merge them into the config
	-- (simplified here, ethier by directly overwriting or appending)
	opts = opts or {}
	-- "force" means that if there is a key conflict, the right side (opts.dict) will override the left side (default_dict)
	local user_dict = vim.tbl_deep_extend("force", {}, default_dict, opts.dict or {})

	-- Automatically generate bidirectional mapping
	local final_dict = {}
	for k, v in pairs(user_dict) do
		-- Forward entry
		final_dict[k] = v
		-- Backward entry
		if not final_dict[v] then
			final_dict[v] = k
		end
	end

	M.config.dict = final_dict
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
		-- print("Debug: Word='"..word.."' Key='"..key.."' Found='"..(replacement or "nil").."'")
		print("Micro-toggle: No toggle found for '" .. key .. "'")
	end
end

return M
