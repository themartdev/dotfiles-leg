local wezterm = require("wezterm")
local act = wezterm.action

local config = {}
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Config
-- config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "City Lights (Gogh)"
config.color_scheme = "tokyonight_night"
config.window_background_opacity = 0.85
config.font = wezterm.font_with_fallback({
	{ family = "JetBrains Mono", scale = 1 },
	{ family = "Fira Code Nerd Font", scale = 1 },
})
config.font_size = 17
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.6,
}
config.front_end = "WebGpu"

-- === BEGIN NVIM INTEGRATION ===

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

-- if you *ARE* lazy-loading smart-splits.nvim (not recommended)
-- you have to use this instead, but note that this will not work
-- in all cases (e.g. over an SSH connection). Also note that
-- `pane:get_foreground_process_name()` can have high and highly variable
-- latency, so the other implementation of `is_vim()` will be more
-- performant as well.

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end
-- === END NVIM INTEGRATION ===

-- Theme
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	-- Send C-a when pressing C-a twice
	{ key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "c", mods = "LEADER", action = act.ActivateCopyMode },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "=", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- Nvim integration
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),

	-- Tab keybindings
	{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "[", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "t", mods = "LEADER", action = act.ShowTabNavigator },

	-- Key table for moving tabs around
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },

	-- Rename tab
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "New tab title",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

config.key_tables = {
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

--- Generates a rounded pill
--- @param opts table
local pill = function(opts)
	local def = {
		header = opts.header or "",
		body = opts.body or "",
		do_plug = opts.do_plug,
		color = opts.color or { AnsiColor = "Red" },
		bg = opts.bg or { Color = "#333" },
	}

	local base = wezterm.format({
		"ResetAttributes",
		{ Background = (def.do_plug and def.bg) or "Default" },
		{ Foreground = def.color },
		{ Text = "" },
		"ResetAttributes",
		{ Foreground = { AnsiColor = "Black" } },
		{ Background = def.color },
		{ Text = def.header },
		{ Text = "  " },
		"ResetAttributes",
		{ Background = def.bg },
		{ Text = " " },
		{ Text = def.body },
		{ Text = " " },
		"ResetAttributes",
	})

	return base
end

config.use_fancy_tab_bar = false
config.status_update_interval = 1000
wezterm.on("update-right-status", function(window, pane)
	local leader_indicator = ""
	if window:leader_is_active() then
		leader_indicator = wezterm.format({
			{ Background = { AnsiColor = "Black" } },
			{ Foreground = { AnsiColor = "Red" } },
			{ Text = "" },
			"ResetAttributes",
			{ Attribute = { Intensity = "Bold" } },
			{ Foreground = { Color = "#000" } },
			{ Background = { AnsiColor = "Red" } },
			{ Text = "LEADER" },
			"ResetAttributes",
			{ Background = { AnsiColor = "Black" } },
			{ Foreground = { AnsiColor = "Red" } },
			{ Text = "" },
		})
	end

	-- Key table
	local key_table_indicator = ""
	if window:active_key_table() then
		key_table_indicator = wezterm.format({
			{ Foreground = { AnsiColor = "Black" } },
			{ Background = { AnsiColor = "Aqua" } },
			{ Text = " " .. window:active_key_table() .. " " },
		})
	end

	-- Workspace name
	local ws = "  " .. window:active_workspace() .. "  "

	-- CWD
	local pretty_cwd = function(s)
		local path = ""
		if s ~= nil then
			path = s.path
		end
		local home = os.getenv("HOME")
		if home ~= nil then
			path = string.gsub(path, home, "~")
		end
		return path
	end
	local cwd = pretty_cwd(pane:get_current_working_dir())

	-- CMD
	local pretty_cmd = function(s)
		return string.gsub(s or "", "(.*[/\\])(.*)", "%2")
	end
	local cmd = pretty_cmd(pane:get_foreground_process_name())

	-- Time
	local time = wezterm.strftime("%H:%M")

	window:set_right_status(leader_indicator .. key_table_indicator .. ws .. pill({
		header = wezterm.nerdfonts.md_folder,
		body = cwd,
		color = { AnsiColor = "Green" },
	}) .. pill({
		do_plug = true,
		header = wezterm.nerdfonts.md_code_greater_than,
		body = cmd,
		color = { AnsiColor = "Fuchsia" },
	}) .. pill({
		do_plug = true,
		header = wezterm.nerdfonts.md_clock,
		body = time,
		color = { AnsiColor = "White" },
	}))
end)

--

-- and finally, return the configuration to wezterm
return config
