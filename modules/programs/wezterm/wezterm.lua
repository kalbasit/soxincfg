-- Some/most of there were copied from these sources:
-- - https://github.com/pinpox/nixos/blob/61fb1d887efd474bff6293c2440299a251fc46eb/home-manager/modules/wezterm/wezterm.lua


local wezterm = require 'wezterm';

-- Show date and battery level at the right of the tab bar
-- TODO Add tab decorations and hostname
-- https://wezfurlong.org/wezterm/config/lua/window/set_right_status.html
wezterm.on("update-right-status", function(window, pane)
	-- "Wed Mar 3 08:14"
	local date = wezterm.strftime("📆  %a %b %-d %H:%M ");

  -- TODO: The battery is showing up as '. 00%'
	local bat = ""
	for _, b in ipairs(wezterm.battery_info()) do
		bat = "⚡" .. string.format("%.0f%%", b.state_of_charge * 100)
	end

	window:set_right_status(wezterm.format({
		{Text=bat .. "   "..date},
	}));
end)

return {
  color_scheme = "Gruvbox Dark",
}
