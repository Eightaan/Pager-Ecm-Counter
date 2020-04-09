-- Because some mods force it to be hidden even when not using their version of the hostagebox
local HUDAssaultCorner_init = HUDAssaultCorner.init
function HUDAssaultCorner:init(...)
	HUDAssaultCorner_init(self, ...)
	local hostages_panel = self._hud_panel:child("hostages_panel")
	if alive(hostages_panel) then
		hostages_panel:set_alpha(1)
	end
end