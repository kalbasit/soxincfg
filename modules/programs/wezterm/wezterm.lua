-- Example configurations:
-- - https://github.com/pinpox/nixos/blob/61fb1d887efd474bff6293c2440299a251fc46eb/home-manager/modules/wezterm/wezterm.lua


local wezterm = require 'wezterm';

-- Copied from -> https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html
wezterm.on("update-right-status", function(window, pane)
  -- "Wed Mar 3 08:14"
  local date = wezterm.strftime("%a %b %-d %H:%M ");

  local bat = ""
  for _, b in ipairs(wezterm.battery_info()) do
    bat = "🔋 " .. string.format("%.0f%%", b.state_of_charge * 100)
  end

  window:set_right_status(wezterm.format({
    {Text=bat .. "   "..date},
  }));
end)

return {
  check_for_updates = false, -- since it's installed by Nix, let Nix manage its updates.
  color_scheme = "Gruvbox Dark",
  font_size = 10,
}
