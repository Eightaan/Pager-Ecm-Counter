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
    
	HUDECMCounter = HUDECMCounter or class()

    function HUDECMCounter:init(hud)
	    self._hud_panel = hud.panel
	    self._ecm_panel = self._hud_panel:panel({
		    name = "ecm_counter_panel",
		    visible = false,
		    w = 200,
		    h = 200
	    })
	
	    self._ecm_panel:set_top(100)
        self._ecm_panel:set_right(self._hud_panel:w() + 11)
		
	    local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})
	
	    self._text = ecm_box:text({
		    name = "text",
		    text = "0",
		    valign = "center",
		    align = "center",
		    vertical = "center",
		    w = 38,
		    h = 38,
		    layer = 1,
		    color = Color.white,
		    font = tweak_data.hud_corner.assault_font,
		    font_size = tweak_data.hud_corner.numhostages_size * 0.9
	    })

	    local ecm_icon = self._ecm_panel:bitmap({
		    name = "ecm_icon",
		    texture = "guis/textures/pd2/skilltree/icons_atlas",
		    texture_rect = { 1 * 64, 4 * 64, 64, 64 },
		    valign = "top",
		    layer = 1,
		    w = 38,
		    h = 38		
	    })
	
	    ecm_icon:set_right(ecm_box:parent():w())
	    ecm_icon:set_center_y(ecm_box:h() / 2)
	    ecm_box:set_right(ecm_icon:left())
    end
	
    function HUDECMCounter:update(t)  
	    self._ecm_panel:set_visible(managers.groupai:state():whisper_mode() and t > 0 and not ignored_levels)	
	    if t > 0 then
		    self._text:set_text(string.format("%.fs", t))
		    self._text:set_color(Color(1, 1, 1))
        end	
    end
 
    local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
    function HUDManager:_setup_player_info_hud_pd2(...)
	    _setup_player_info_hud_pd2_original(self, ...)
	    self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
    end
	
    function HUDManager:update_ecm(t)
	    self._hud_ecm_counter:update(t)
    end

elseif string.lower(RequiredScript) == "lib/units/equipment/ecm_jammer/ecmjammerbase" then

    local setup_original = ECMJammerBase.setup
    local sync_setup_original = ECMJammerBase.sync_setup
    local destroy_original = ECMJammerBase.destroy
    local load_original = ECMJammerBase.load
    local update_original = ECMJammerBase.update
	
    function ECMJammerBase:_check_new_ecm()
	    if not ECMJammerBase._max_ecm or ECMJammerBase._max_ecm:battery_life() < self:battery_life() then
		    ECMJammerBase._max_ecm = self
	    end
    end
 
    function ECMJammerBase:sync_setup(upgrade_lvl, ...)
	    sync_setup_original(self, upgrade_lvl, ...)
	    self:_check_new_ecm()
    end
	
    function ECMJammerBase:setup(battery_life_upgrade_lvl, ...)
	    setup_original(self, battery_life_upgrade_lvl, ...)
	    self:_check_new_ecm()
    end
	
    function ECMJammerBase:destroy(...)
	    if ECMJammerBase._max_ecm == self then
		    ECMJammerBase._max_ecm = nil
		    managers.hud:update_ecm(0)
	    end
		
	    return destroy_original(self, ...)
    end
	
    function ECMJammerBase:load(...)
	    load_original(self, ...)
	    self:_check_new_ecm()
    end
	
    function ECMJammerBase:update(unit, t, ...)
	    update_original(self, unit, t, ...)
	    if ECMJammerBase._max_ecm == self then
		    managers.hud:update_ecm(self:battery_life())
	    end 
    end
end
