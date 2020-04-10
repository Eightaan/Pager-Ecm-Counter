if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
    local ignored_levels = Global.game_settings.level_id == 'dinner' -- slaughterhouse
	    or Global.game_settings.level_id == 'man' -- undercover
	    or Global.game_settings.level_id == 'nmh' -- no mercy
	    or Global.game_settings.level_id == 'peta' -- goat simulator
	    or Global.game_settings.level_id == 'peta2' -- goat simulator day 2
	    or Global.game_settings.level_id == 'born' -- biker heist
	    or Global.game_settings.level_id == 'pbr2' -- birth of sky
	    or Global.game_settings.level_id == 'cane' -- santas workshop
	    or Global.game_settings.level_id == 'rvd2' -- reservoir dogs day 2
	    or Global.game_settings.level_id == 'des' -- henrys rock
	    or Global.game_settings.level_id == 'flat' -- panic room
	    or Global.game_settings.level_id == 'alex_2' -- rats day 2
	    or Global.game_settings.level_id == 'mia_2' -- hotline miami day 2

    HUDPAGERCounter = HUDPAGERCounter or class()

    function HUDPAGERCounter:init(hud)
	    self._hud_panel = hud.panel
        managers.hud:add_updator("CountPagers", callback(self, self, "CountPagers"))
        self._pager_panel = self._hud_panel:panel({
            name = "pager_panel",
		    visible = false,
		    w = 200,
		    h = 200
        })
	
	    self._pager_panel:set_top(50)
        self._pager_panel:set_right(self._hud_panel:w() + 11)

        local pager_box = HUDBGBox_create(self._pager_panel,{ w = 38, h = 38, }, {})
	
        pager_text = pager_box:text({
            name = "text",
            text = "0",
            valign = "center",
            align = "center",
            vertical = "center",
            w = 38,
            h = 38,
            layer = 1,
            color = Color.White,
            font = tweak_data.hud_corner.assault_font,
            font_size = tweak_data.hud_corner.numhostages_size * 0.9
        })
	
        local pager_icon = self._pager_panel:bitmap({
            name = "pager_icon",
            texture = "guis/textures/pd2/specialization/icons_atlas",
		    texture_rect = { 1 * 64, 4 * 64, 76, 64 },
		    valign = "top",
		    layer = 1,
            w = 38,
            h = 38
        })

        pager_icon:set_right(pager_box:parent():w())  
        pager_icon:set_center_y(pager_box:h() / 2)
        pager_box:set_right( pager_icon:left())

        self.total_pagers = 0
    end

    function HUDPAGERCounter:CountPagers()
	    self._pager_panel:set_visible(managers.groupai:state():whisper_mode() and not ignored_levels)
        if tonumber(pager_text:text()) ~= self.total_pagers then
            pager_text:set_text(self.total_pagers)
        end
    end

    function HUDPAGERCounter:add_pager()
	    self.total_pagers = self.total_pagers +1
    end 

    local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2

    function HUDManager:_setup_player_info_hud_pd2(...)
	    _setup_player_info_hud_pd2_original(self, ...)
	    self._hud_pager_counter = HUDPAGERCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
    end

    function HUDManager:add_pager()
	    self._hud_pager_counter:add_pager()
    end

elseif string.lower(RequiredScript) == "lib/units/interactions/interactionext" then

    local IntimitateInteractionExt_original = IntimitateInteractionExt.interact
    function IntimitateInteractionExt:interact(player)

	    if not self:can_interact(player) then IntimitateInteractionExt_original(self, player) return end
		
	    if self.tweak_data == "corpse_alarm_pager" then
		    managers.hud:add_pager()
	    end

	    IntimitateInteractionExt_original(self, player)
    end

elseif string.lower(RequiredScript) == "lib/network/handlers/unitnetworkhandler" then

    local _o_sync_teammate_progress = UnitNetworkHandler.sync_teammate_progress
    function UnitNetworkHandler:sync_teammate_progress(type_index, enabled, tweak_data_id, timer, success, sender)
	    _o_sync_teammate_progress(self, type_index, enabled, tweak_data_id, timer, success, sender)
	    if tweak_data_id == "corpse_alarm_pager" and success == true then
		    managers.hud:add_pager()
	    end	
    end
end
