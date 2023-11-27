-- New function for generating spell bonus hints
function gen_spell_bonus_hint()
  local level = get_level()
  local name = Obj.name()
 	local damage = Logic.obj_par( name, "damage" )
 	local rephits = Logic.obj_par( name, "rephits" )
 	local power = tonumber( text_dec( Logic.obj_par( name, "power" ), level ) )
 	local bonus = tonumber( text_dec( Logic.obj_par( name, "bonus" ), level ) )
 	local penalty = tonumber( text_dec( Logic.obj_par( name, "penalty" ), level ) )
 	local mana = tonumber( text_dec( Logic.obj_par( name, "mana" ), level ) )
 	local count = tonumber( text_dec( Logic.obj_par( name, "count" ), level ) )
  local dummy, text0, text1, text2, text3, text4, text5, text6, text7 = 0, "", "", "", "", "", "", "", ""

  if damage ~= nil
  and damage ~= "" then
    local min_dmg, max_dmg = text_range_dec( Logic.obj_par( name, "damage" ) )
    text0 = text0 .. "<br>" .. "<label=spell_damage> " .. gen_dmg_common_hint( "damage", 0, min_dmg, max_dmg )

   	local periphery_damage = Logic.obj_par( name, "periphery_damage" )
    if periphery_damage ~= nil
    and periphery_damage ~= "" then
      min_dmg, max_dmg = text_range_dec( Logic.obj_par( name, "periphery_damage" ) )
      text0 = text0 .. "<br>" .. "<label=spell_periphery_damage> " .. gen_dmg_common_hint( "damage", 0, min_dmg, max_dmg )
    end

    local prc_damage = tonumber( text_dec( Logic.obj_par( name, "prc_damage" ), level ) )
    if prc_damage ~= nil
    and prc_damage > 0 then
      text0 = text0 .. "<br>" .. "<label=spell_prc_armageddon> " .. gen_dmg_common_hint( "power_percent", 100 - prc_damage )
    end

    local lvl_inc = tonumber( Logic.obj_par( name, "lvl_inc" ) )
    lvl_inc = ( level - 1 ) * lvl_inc
    if lvl_inc > 0 then
      text0 = text0 .. "<br>" .. "<label=spell_level_damage> " .. gen_dmg_common_hint( "plus_power_percent", lvl_inc )
    end
  end

  if rephits ~= nil
  and rephits ~= "" then
    text0 = text0 .. "<br>" .. "<label=spell_healing_power> " .. gen_dmg_common_hint( "damage", 0, rephits, rephits )

    local prc_damage = tonumber( Logic.obj_par( name, "prc_damage" ) )
    if prc_damage ~= nil
    and prc_damage > 0 then
      text0 = text0 .. "<br>" .. "<label=spell_prc_healing> " .. gen_dmg_common_hint( "plus_power_percent", prc_damage )
    end

    local lvl_inc = tonumber( Logic.obj_par( name, "lvl_inc" ) )
    lvl_inc = ( level - 1 ) * lvl_inc
    if lvl_inc ~= nil
    and lvl_inc > 0 then
      text0 = text0 .. "<br>" .. "<label=spell_level_healing> " .. gen_dmg_common_hint( "plus_power_percent", lvl_inc )
    end
  end

  if ( damage ~= nil and damage ~= "" )
  or ( rephits ~= nil and rephits ~= "" )
  or ( power ~= nil and power ~= "" ) then
    dummy, text1 = get_add_bonus( name, 0, "sp_add_power_", true )
    dummy, text2 = get_add_bonus( name, 0, "sp_lvl_inc_", true )
    dummy, text3 = get_gain_bonus( name, 0, "sp_gain_power_", true )
    dummy, text4 = get_spell_bonus( name, true )
  end


  if ( text1 ~= ""
  or text2 ~= ""
  or text3 ~= ""
  or text4 ~= "" ) then
    if power ~= nil
    and power ~= "" then
      text0 = text0 .. "<br>" .. "<label=spell_power> " .. gen_dmg_common_hint( "value", power )
    end

    if bonus ~= nil
    and bonus ~= "" then
      text0 = text0 .. "<br>" .. "<label=spell_bonus> " .. gen_dmg_common_hint( "plus_power", bonus )
    end

    if penalty ~= nil
    and penalty ~= "" then
      text0 = text0 .. "<br>" .. "<label=spell_penalty> " .. gen_dmg_common_hint( "minus_power", penalty )
    end
  end

  if mana ~= nil
  and mana ~= "" then
    text0 = text0 .. "<br>" .. "<label=spell_mana> " .. gen_dmg_common_hint( "plus_power", mana )
  end

  dummy, text5 = int_dur( name, level, string.gsub( name, "spell_", "sp_duration_" ), true )

  local typedmg = Logic.obj_par( name, "typedmg" )
  if typedmg ~= nil then
    local kinds = { "poison", "burn", "shock", "freeze", "stun", "holy" }
    for i, infliction in pairs( kinds ) do
      local kind = tonumber( Logic.obj_par( name, infliction ) )
      if kind ~= nil then
        local dummy, temp = get_infliction( name, level, infliction, nil, true )
        text6 = text6 .. temp
      end
    end
  end

  if count ~= nil
  and count ~= "" then
    dummy, text7 = get_count_bonus( name, true )
    if dummy > 0 then
      text0 = text0 .. "<br>" .. "<label=spell_count> " .. gen_dmg_common_hint( "count", count )
    end
  end

  return text0 .. text1 .. text2 .. text3 .. text4 .. text5 .. text6 .. text7
end

-- New function for generating common summon bonus hints
function gen_spell_summon_bonus_hint()
  local level = get_level()
  local name = Obj.name()
  local damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus, text = summon_bonus( nil, name, true )

  return text
end

-- New function for generating common hints
function gen_dmg_common_hint( par, value, min_dmg, max_dmg, sel_fnt, def_fnt )
  if sel_fnt == nil then
    sel_fnt = Game.Config( "txt_font_config/hint_sel" )
  end
  
  if def_fnt == nil then
    def_fnt = Game.Config( "txt_font_config/hint_sys" )
  end

  if string.find( par, "value" )
  or string.find( par, "level" )
  or string.find( par, "time" )
  or string.find( par, "lead" )
  or string.find( par, "count" ) then
    return sel_fnt .. tostring( value ) .. def_fnt
  elseif string.find( par, "parentheses_power_percent" ) then
    return sel_fnt .. "(" .. tostring( value ) .. "%" .. ")" .. def_fnt
  elseif string.find( par, "one_minus_power" ) then
    return sel_fnt .. "1-" .. tostring( value ) .. def_fnt
  elseif string.find( par, "minus_power_percent" ) then
    return sel_fnt .. "-" .. tostring( value ) .. "%" .. def_fnt
  elseif string.find( par, "minus_power" ) then
    return sel_fnt  .. "-" .. tostring( value ) .. def_fnt
  elseif string.find( par, "plus_power_percent" ) then
    return sel_fnt .. "+" .. tostring( value ) .. "%" .. def_fnt
  elseif string.find( par, "plus_power" ) then
    return sel_fnt  .. "+" .. tostring( value ) .. def_fnt
  elseif string.find( par, "poison" )
  or string.find( par, "burn" )
  or string.find( par, "shock" )
  or string.find( par, "freeze" )
  or string.find( par, "stun" )
  or string.find( par, "prc" )
  or string.find( par, "power" ) then
    return sel_fnt .. tostring( value ) .. "%" .. def_fnt
  elseif string.find( par, "holy" ) then
    return sel_fnt .. "-" .. tostring( value ) .. "%" .. def_fnt
  elseif string.find( par, "range_pct" ) then
    if min_dmg == max_dmg then
      return sel_fnt .. tostring( min_dmg ) .. "%" .. def_fnt
    else
      return sel_fnt .. tostring( min_dmg ) .. "-" .. tostring( max_dmg ) .. "%" .. def_fnt
    end
  else
    if min_dmg == max_dmg then
      return sel_fnt .. tostring( min_dmg ) .. def_fnt
    else
      return sel_fnt .. tostring( min_dmg ) .. "-" .. tostring( max_dmg ) .. def_fnt
    end
  end
end

function gen_dmg_necromancy( par )
  local level = tonumber( text_dec( par, 1 ) )
  local power = pwr_necromancy( tonumber( level ) )
  local text, text2 = "", ""

  if string.find( par, "skill_hint" ) then
    text2 = "<br><label=spell_necromancy_skill_hint>"
  elseif string.find( par, "necro_heal_hint" ) then
    text2 = "<br><label=spell_necromancy_heal_hint>"
  elseif ( tonumber( skill_power( "necromancy", 4 ) ) > 0 )
  and string.find( par, "heal_power" ) then
    local min_pct, max_pct = skill_power_range_dec( "necromancy", 1 )
    local min_power = round( power * min_pct / 100 )
    local max_power = round( power * max_pct / 100 )
    text2 = gen_dmg_common_hint( "damage", nil, min_power, max_power )
  elseif ( tonumber( skill_power( "necromancy", 4 ) ) > 0 )
  and string.find( par, "necro_skill_power" ) then
    local min_pct, max_pct = skill_power_range_dec( "necromancy", 1 )
    text2 = gen_dmg_common_hint( "range_pct", nil, min_pct, max_pct )
  end

  if ( tonumber( skill_power( "necromancy", 4 ) ) > 0 )
  and text2 ~= "" then
    text = text2
  elseif text2 == "" then
    text = gen_dmg_common_hint( "value", power )
  end

  return text
end

function gen_dmg_dragon_arrow( level )
  local power = pwr_dragon_arrow( tonumber( level ) )
  local text = gen_dmg_common_hint( "value", power )

  return text
end

function gen_dmg_trap( par )
  local level = tonumber( par )
  local min_dmg, max_dmg, duration, poison = pwr_trap( level )
  local text = gen_dmg_common_hint( par, poison, min_dmg, max_dmg )

  return text
end

function gen_dmg_demonologist( par )
  local level = tonumber( text_dec( par, 1 ) )
  local lead, time, lvl, power = pwr_demonologist( level )
  local text

		if string.find( par, "level" ) then
    text = gen_dmg_common_hint( par, lvl )
		elseif string.find( par, "time" ) then
    text = gen_dmg_common_hint( par, time )
		elseif string.find( par, "lead" ) then
    text = gen_dmg_common_hint( par, lead ) .. " " .. gen_dmg_common_hint( "parentheses_power_percent", round( power ) )
		end

  return text
end

function gen_dmg_kamikaze( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, dur = pwr_kamikaze(level)
  local text = gen_dmg_common_hint( par, dur, min_dmg, max_dmg )

  return text
end

function gen_dmg_evilbook( par )
  local level = tonumber( text_dec( par, 1 ) )
  local level, kill = pwr_evilbook( level )
  local damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus = summon_bonus( nil, "spell_evilbook" )
  local text

  if string.find( par, "kill" ) then
    text = gen_dmg_common_hint( "value", kill )
  elseif string.find( par, "damage" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( damage_bonus ) )
  elseif string.find( par, "add_hp" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( hitpoint_bonus ) )
  elseif string.find( par, "defense" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( defense_bonus ) )
  elseif string.find( par, "attack" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( attack_bonus ) )
  elseif string.find( par, "resistance" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( res_bonus ) )
  elseif string.find( par, "krit" ) then
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_aislinn = Logic.hero_lu_item( "sp_kid_aislinn", "count" )

    if sp_kid_aislinn > 0 then
      text = "<label=spell_krit_summon>" .. gen_dmg_common_hint( "plus_power_percent", sp_kid_aislinn * 12 )
    else
      text = ""
    end
  elseif string.find( par, "init" ) then
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_aislinn = Logic.hero_lu_item( "sp_kid_aislinn", "count" )

    if sp_kid_aislinn > 0 then
      text = "<label=spell_init_summon>" .. gen_dmg_common_hint( "plus_power", sp_kid_aislinn )
    else
      text = ""
    end
  elseif string.find( par, "speed" ) then
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_aislinn = Logic.hero_lu_item( "sp_kid_aislinn", "count" )

    if sp_kid_aislinn > 0 then
      text = "<label=spell_speed_summon>" .. gen_dmg_common_hint( "plus_power", sp_kid_aislinn )
    else
      text = ""
    end
  elseif string.find( par, "unlimited_retaliation" ) then
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_aislinn = Logic.hero_lu_item( "sp_kid_aislinn", "count" )

    if sp_kid_aislinn > 0 then
      text = "<label=spell_unlimited_retaliation_summon>"
    else
      text = ""
    end
  else
    text = gen_dmg_common_hint( "one_minus_power", level )
  end

  return text
end

function gen_dmg_phoenix( par )
  local level = tonumber( text_dec( par, 1 ) )
  level = get_level( level )
  local damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus = summon_bonus( nil, "spell_phoenix" )
  local text

  if string.find( par, "damage" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( damage_bonus ) )
  elseif string.find( par, "add_hp" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( hitpoint_bonus ) )
  elseif string.find( par, "defense" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( defense_bonus ) )
  elseif string.find( par, "attack" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( attack_bonus ) )
  elseif string.find( par, "resistance" ) then
    text = gen_dmg_common_hint( "plus_power_percent", math.floor( res_bonus ) )
  elseif string.find( par, "krit" ) then
    local power = 0
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_luna = Logic.hero_lu_item( "sp_kid_luna", "count" )

    if sp_kid_luna > 0 then
      power = 20 * sp_kid_luna
    end

    if skill_power2( "holy_rage", 3 ) > 0 then
      power = power + skill_power2( "holy_rage", 3 )
    end

    if power > 0 then
      text = "<label=spell_krit_summon>" .. gen_dmg_common_hint( "plus_power_percent", 2 * power )
    else
      text = ""
    end
  elseif string.find( par, "init" ) then
    local power = 0

    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_luna = Logic.hero_lu_item( "sp_kid_luna", "count" )

    if sp_kid_luna > 0 then
      power = sp_kid_luna
    end

    if skill_power2( "holy_rage", 2 ) > 0 then
      power = power + skill_power2( "holy_rage", 2 )
    end

    if power > 0 then
      text = "<label=spell_init_summon>" .. gen_dmg_common_hint( "plus_power", power )
    else
      text = ""
    end
  elseif string.find( par, "speed" ) then
    local power = 0
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    local sp_kid_luna = Logic.hero_lu_item( "sp_kid_luna", "count" )

    if sp_kid_luna > 0 then
      power = sp_kid_luna
    end

    if skill_power2( "holy_rage", 2 ) > 0 then
      power = power + skill_power2( "holy_rage", 2 )
    end

    if power > 0 then
      text = "<label=spell_speed_summon>" .. gen_dmg_common_hint( "plus_power", power )
    else
      text = ""
    end
  elseif string.find( par, "unlimited_retaliation" ) then
    -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
    -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to the bonus multiple
    if Logic.hero_lu_item( "sp_kid_luna", "count" ) > 0 then
      text = "<label=spell_unlimited_retaliation_summon>"
    else
      text = ""
    end
  else
    text = gen_dmg_common_hint( "one_minus_power", level )
  end

  return text
end

function gen_dmg_plague( level )
  local power = pwr_plague( tonumber( level ) )
  local text = gen_dmg_common_hint( "minus_power_percent", power )

  return text
end

function gen_dmg_fire_breath( level )
  local power = pwr_fire_breath( tonumber( level ) )
  local text = gen_dmg_common_hint( "plus_power_percent", power )

  return text
end

function gen_dmg_pain_mirror( level )
  local power = pwr_pain_mirror( tonumber( level ) )
  local text = gen_dmg_common_hint( "power", power )

  return text
end

function gen_dmg_berserker( par )
  local level = tonumber( text_dec( par, 1 ) )
  local level, power = pwr_berserker( level )
  local text

  if string.find( par, "power" ) then
    text = gen_dmg_common_hint( "plus_power_percent", power )
  else
    text = gen_dmg_common_hint( "one_minus_power", level )
  end

  return text
end

function gen_dmg_invisibility( level )
  local lvl = tonumber( text_dec( Logic.obj_par( "spell_invisibility", "level" ), tonumber( level ) ) )
  local text = gen_dmg_common_hint( "one_minus_power", lvl )

  return text
end

function gen_dmg_scare( level )
  local lvl = tonumber( text_dec( Logic.obj_par( "spell_scare", "level" ), tonumber( level ) ) )
  local text = gen_dmg_common_hint( "one_minus_power", lvl )

  return text
end

function gen_dmg_stone_skin( par )
  local level = tonumber( text_dec( par, 1 ) )
  local power, penalty = pwr_stone_skin( level )
  local text

  if string.find( par, "power" ) then
    text = gen_dmg_common_hint( "plus_power_percent", power )
  else
    if tonumber( penalty ) == 0 then
      text = gen_dmg_common_hint( "value", "No Penalty" )
    else
      text = gen_dmg_common_hint( "minus_power", penalty )
    end
  end

  return text
end

function gen_dmg_last_hero( level )
  level = get_level( level )
  local lvl = tonumber( text_dec( Logic.obj_par( "spell_last_hero", "level" ), level ) )
  local text = gen_dmg_common_hint( "one_minus_power", lvl )

  return text
end

function gen_dmg_gifts( level )
  level = get_level( level )
  local lvl = tonumber( text_dec( Logic.obj_par( "spell_gifts", "level" ), level ) )
  local text = gen_dmg_common_hint( "one_minus_power", lvl )

  return text
end

function gen_dmg_phantom( par )
 	local level = tonumber( text_dec( par, 1 ) )
  local power = pwr_phantom( tonumber( level ) )
  local text

  if string.find(par,"level") then
  	 local lvl = tonumber( text_dec( Logic.obj_par( "spell_phantom", "level" ), level ) )
    text = gen_dmg_common_hint( "one_minus_power", lvl )
  else
    text = gen_dmg_common_hint( "power", power )
 	end

  return text
end

function gen_dmg_demon_slayer( level )
  local power = pwr_demon_slayer( tonumber( level ) )
  local text = gen_dmg_common_hint( "power", power )

  return text
end

function gen_dmg_dragon_slayer( level )
  local power = pwr_dragon_slayer( tonumber( level ) )
  local text = gen_dmg_common_hint( "power", power )

  return text
end

function gen_dmg_ghost_sword( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, power = pwr_ghost_sword( level )
  local text = gen_dmg_common_hint( par, power, min_dmg, max_dmg )

  return text
end

function gen_dmg_magic_source( par )
  local level = tonumber( text_dec( par, 1 ) )
  local penalty, mana = pwr_magic_source( level )
  local text

  if string.find( par, "mana" ) then
    if mana == 0 then
      text = "<color=255,66,0>" .. "NO MANA GAIN!" .. "</color>"
    else
      text = gen_dmg_common_hint( "plus_power", mana )
    end
  else
    text = gen_dmg_common_hint( "plus_power_percent", penalty )
  end

  return text
end

function gen_dmg_shroud( level )
  local penalty = pwr_shroud( level )
  local text = gen_dmg_common_hint( "minus_power_percent", penalty )

  return text
end

function gen_dmg_teleport( level )
  local dist = text_dec( Logic.obj_par( "spell_teleport", "dist" ), tonumber( level ) )
  local text = gen_dmg_common_hint( "value", dist )

  return text
end

function gen_dmg_armageddon( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, burn, duration, prc = pwr_armageddon( level )
  local text = ""

  if string.find( par, "ally_damage" ) then
    text = gen_dmg_common_hint( par, burn, round( min_dmg * prc / 100 / 5 ) * 5, round( max_dmg * prc / 100 / 5 ) * 5 )
  else
    text = gen_dmg_common_hint( par, burn, min_dmg, max_dmg )
  end

  return text
end

function gen_dmg_holy_rain( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, holy = pwr_holy_rain( tonumber( level ), string.find( par, "true" ) )
  local text = gen_dmg_common_hint( par, holy, min_dmg, max_dmg )

  return text
end

function gen_dmg_warcry( level )
  local bonus = pwr_warcry( tonumber( level ) )
  local text = gen_dmg_common_hint( "plus_power", bonus )

  return text
end

function gen_dmg_magic_bondage( level )
  local bonus = pwr_magic_bondage( tonumber( level ) )
  local text = gen_dmg_common_hint( "one_minus_power", bonus )

  return text
end

function gen_dmg_blind( level )
  local bonus = pwr_blind( tonumber( level ) )
  local text = gen_dmg_common_hint( "one_minus_power", bonus )

  return text
end

function gen_dmg_ram( level )
  local bonus = pwr_ram( tonumber( level ) )
  local text = gen_dmg_common_hint( "one_minus_power", bonus )

  return text
end

function gen_dmg_crue_fate( level )
  local bonus = pwr_crue_fate( tonumber( level ) )
  local text = gen_dmg_common_hint( "one_minus_power", bonus )

  return text
end

function gen_dmg_hypnosis( par )
 	local level = tonumber( text_dec( par, 1 ) )
	 local lvl, lead, power = pwr_hypnosis( level )
  local text

	 if string.find( par, "level" ) then
    text = gen_dmg_common_hint( "one_minus_power", lvl )
  else
    text = gen_dmg_common_hint( "value", lead ) .. " " .. gen_dmg_common_hint( "parentheses_power_percent", round( power ) )
  end

  return text
end

function gen_dmg_pygmy( par )
	 local level = tonumber( text_dec( par, 1 ) )
  local bonus = pwr_pygmy( tonumber( level ) )
  local text

	 if string.find( par, "level" ) then
    local lvl = tonumber( text_dec( Logic.obj_par( "spell_pygmy", "level" ), level ) )
    text = gen_dmg_common_hint( "one_minus_power", lvl )
  else
    text = gen_dmg_common_hint( "minus_power_percent", bonus )
  end

  return text
end

function gen_dmg_accuracy( level )
  local bonus = pwr_accuracy( tonumber( level ) )
  local text = gen_dmg_common_hint( "plus_power_percent", bonus )

  return text
end

function gen_dmg_slow( par )
	 local level = tonumber( text_dec( par, 1 ) )
  local bonus, krit = pwr_slow( tonumber( level ) )
  local text = ""

  if string.find( par, "krit" ) then
    text = gen_dmg_common_hint( "plus_power_percent", krit )
  else
    text = gen_dmg_common_hint( "minus_power", bonus )
  end

  return text
end

function gen_dmg_haste( par )
	 local level = tonumber( text_dec( par, 1 ) )
  local bonus, krit = pwr_haste( tonumber( level ) )
  local text = ""

  if string.find( par, "krit" ) then
    text = gen_dmg_common_hint( "plus_power_percent", krit )
  else
    text = gen_dmg_common_hint( "plus_power", bonus )
  end

  return text
end

function gen_dmg_divine_armor( par )
  level = tonumber( par )
  local bonus = pwr_divine_armor( level )
  local text = gen_dmg_common_hint( "power", bonus )

  return text
end

function gen_dmg_defenseless( level )
  local bonus = pwr_defenseless( level )
  local text = gen_dmg_common_hint( "minus_power_percent", bonus )

  return text
end

function gen_dmg_adrenalin( level )
  local bonus = pwr_adrenalin( level )
  local text = gen_dmg_common_hint( "value", bonus )

  return text
end

function gen_dmg_pacifism( par )
  local level = tonumber( text_dec( par, 1 ) )
  local bonus, penalty = pwr_pacifism( level )
  local text

  if string.find( par, "bonus" ) then
    text = gen_dmg_common_hint( "plus_power_percent", bonus )
  else
    text = gen_dmg_common_hint( "minus_power_percent", penalty )
  end

  return text
end

function gen_dmg_resurrection( par )
	 local level = tonumber( text_dec( par, 1 ) )
	 local ref = pwr_resurrection( level )
  local text

	 if string.find( par, "level" ) then
    local lvl = tonumber( text_dec( Logic.obj_par( "spell_resurrection", "level" ), level ) )
    text = gen_dmg_common_hint( "one_minus_power", lvl )
  else
    text = gen_dmg_common_hint( "value", ref )
  end

  return text
end

function gen_dmg_healing( par )
	 local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg = pwr_healing( level, nil, string.find( par, "prc" ) )
  local text = gen_dmg_common_hint( "damage", 0, min_dmg, max_dmg )

  return text
end

function gen_dmg_oil_fog( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, dur, power = pwr_oil_fog( level )
  local text

	 if string.find( par, "power" ) then
    text = gen_dmg_common_hint( "minus_power", power )
  else
    text = gen_dmg_common_hint( par, power, min_dmg, max_dmg )
  end

  return text
end

function gen_dmg_lightning( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, shock = pwr_lightning( level )
  local text = gen_dmg_common_hint( par, shock, min_dmg, max_dmg )

  return text
end

function gen_dmg_magic_axe( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, count = pwr_magic_axe( level )
  local text = gen_dmg_common_hint( par, count, min_dmg, max_dmg )

  return text
end

function gen_dmg_fire_ball( par )
  local min_dmg, max_dmg, burn = pwr_fire_ball( par )
  local text = gen_dmg_common_hint( par, burn, min_dmg, max_dmg )

  return text
end

function gen_dmg_ice_serpent( par )
  local min_dmg, max_dmg, freeze = pwr_ice_serpent( par )
  local text = gen_dmg_common_hint( par, freeze, min_dmg, max_dmg )

  return text
end

function gen_dmg_sacrifice( par )
  local level = tonumber( text_dec( par, 1 ) )
	 local damage, power = pwr_sacrifice( tonumber( level ) )
  local text

  if string.find( par, "power" ) then
    text = gen_dmg_common_hint( "power", power )
  else
    text = gen_dmg_common_hint( "value", damage )
  end

  return text
end

function gen_dmg_fire_arrow( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, burn = pwr_fire_arrow( level )
  local text = gen_dmg_common_hint( par, burn, min_dmg, max_dmg )

  return text
end

function gen_dmg_geyser( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, count, freeze, stun = pwr_geyser( level )
  local text

  if string.find( par, "count" ) then
    text = gen_dmg_common_hint( par, count )
  else
    if string.find( par, "freeze" ) then
      text = gen_dmg_common_hint( par, freeze, min_dmg, max_dmg )
    else
      text = gen_dmg_common_hint( par, stun, min_dmg, max_dmg )
    end
  end

  return text
end


function gen_dmg_fire_rain( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, burn = pwr_fire_rain( level )
  local text = gen_dmg_common_hint( par, burn, min_dmg, max_dmg )

  return text
end

function gen_dmg_bless()
  local healer = tonumber( Logic.obj_par( "spell_bless", "healer" ) )
  local sp_healer, text = 0, ""
  if healer == 1 then
    sp_healer = tonumber( Logic.hero_lu_skill( "healer" ) )

    if sp_healer > 2 then
      sp_healer = 1
    else
      sp_healer = 0
    end

    if sp_healer > 0 then
      text = gen_dmg_common_hint( "plus_power", sp_healer )
      text = "Max Damage: " .. text .. "."
    end
  end

  return text
end

function gen_dmg_weakness()
  local necromancy = tonumber( Logic.obj_par( "spell_weakness", "necromancy" ) )
  local sp_necromancy, text = 0, ""
  if necromancy == 1 then
	  	sp_necromancy = tonumber( Logic.hero_lu_skill( "necromancy" ) )

    if sp_necromancy > 2 then
      sp_necromancy = 1
    else
      sp_necromancy = 0
    end

    if sp_necromancy > 0 then
      text = gen_dmg_common_hint( "minus_power", sp_necromancy )
      text = "Min Damage: " .. text .. "."
    end
  end

  return text
end

function gen_dmg_smile_skull( par )
  local level = tonumber( text_dec( par, 1 ) )
  local min_dmg, max_dmg, poison = pwr_smile_skull( level )
  local text = gen_dmg_common_hint( par, poison, min_dmg, max_dmg )

  return text
end

-- ***************************************
-- * block Hint konstuktoov
-- ***************************************

function gen_spell_end()
  local mana=""
  local duration=""
  local sc=""
  local school=""

  if ( Obj.where() == 1 )
  and ( Logic.obj_par( Obj.name(), "duration" ) ~= "0" )
  or ( Obj.where() == 6 )
  and ( Logic.obj_par( Obj.name(), "duration" ) ~= "0" ) then
    local level = Obj.spell_level()

    if level == 0 then level = 1 end

    if Obj.where() == 6
    and Obj.spell_level() ~= 0 then level = level + 1 end

-- MUST MAKE shell script with intelligence!
    dur = gen_spell_duration( Obj.name(), level )
--    dur=tonumber(text_dec(Logic.obj_par(Obj.name(),"duration"),level))
--    if int~="1" then
--[[    if spell~="spell_adrenalin" or Logic.obj_par(Obj.name(),"int")=="1" then
      dur=dur + math.ceil(HInt()/tonumber(Game.Config("spell_power_config/int_duration")))-1
    end]]
--    end
    duration = "<label=spell_hintMD_font>" .. "<label=spell_hint_d> " .. dur .. "     "
    --Game.Config("txt_font_config/hint_cap").."<label=spell_hint_d> ".."<label=hint_Def_font>"..dur.."  "
  end

  if Obj.where() == 5 then
--    local dur = tonumber(Attack.act_spell_duration(cellunit,spellnaмe))
    duration = "<label=spell_hintMD_font>" .. "<label=spell_hint_d> " .. 2
    --Game.Config("txt_font_config/hint_cap").."<label=spell_hint_d> ".."<label=hint_Def_font>".."2"
  end

  if Obj.spell_level()>0 and (Obj.where()==2 or Obj.where()==6 or Obj.where()==1) then
    local up=0
    if Obj.where()==6 then up=1 end

    local mc = Obj.spell_mana(Obj.spell_level()+up)
--    mc = gen_mana_discount( spell, mc ) --this displays correctly, but mana cost still uses spells.txt
    mana="<label=spell_hintMD_font>".."<label=spell_hint_mana> "..mc
    --Game.Config("txt_font_config/hint_cap").."<label=spell_hint_m> ".."<label=hint_Def_font>"..mc
  end

  spell_end = mana
  --duration..mana

  return spell_end
end

function gen_spell_school()
  local sc=""
  local school=""

  -- 1-2-book store 5-unit
  if Obj.where()==2 then
    sc = Obj.spell_school()

    if sc == 1 then
      sc="<label=spell_hint_MOrd>"
    end
    if sc == 2 then
      sc="<label=spell_hint_MDis>"
    end
    if sc == 3 then
      sc="<label=spell_hint_MCha>"
    end
    if sc == 4 then
      sc="<label=spell_hint_MAdv>"
    end
    school="<br><label=spell_hint_TM_font><label=spell_hint_s> <label=hint_Def_font>"..sc
  end

  return school
end

function gen_spell_name()
  local sn = ""

  if Obj.where()==1 then     -- 1-2-book store 5-unit
    sn = Game.Config("txt_font_config/spell_cap")
  end

  return sn
end

function gen_spell_level()
  local lvl=Obj.spell_level()
  local level="<label=spell_hintLev_font>"
--  local lll=""
--  local sl=Game.Config("txt_font_config/hint_def")

  if Obj.where()<5 then     -- 1-2-book store 5-unit
    level=level.."<label=spell_level> "

    if lvl==0 then lvl=1 end

    for i=1,lvl do
      level=level.."I"
    end
    if Obj.spell_level()== 0 then
      level=level.." <label=spell_scroll>".."<br>"
    else
      level=level.."<br>"
    end
   	return level..Game.Config("txt_font_config/hint_def")
  end

  if Obj.where()==6 then
    if lvl==0 then
      level = level.."<label=spell_next_scroll>"
    else
      lvl = lvl + 1
      level=level.."<label=spell_level> "
      for i=1,lvl do
        level=level.."I"
      end
      level=level.."<br>"
    end
    return level..Game.Config("txt_font_config/hint_def")
  end

  if Obj.where()==5 then
    return Game.Config("txt_font_config/hint_def")
  end
end

function gen_spell_desc()
  local desc=""
  -- 1-2-book store 5-unit
  if Obj.where()~=5 then
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_desc>"
  else
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_small>"
  end

  return desc
end

function gen_spell_desc_complex()
  local level=Obj.spell_level()

  if level==0 then level=1 end

  if Obj.where()==6 and Obj.spell_level()~=0 then level=level+1 end

  local desc=""
  -- 1-2-book store 5-unit
  if Obj.where()~=5 then
    count = text_dec(Logic.obj_par(Obj.name(),"unit_count"),level)
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_desc_"..count..">"
  else
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_small>"
  end

  return desc
end

function gen_spell_desc_combo()
  local level=Obj.spell_level()
  if level==0 then level=1 end

  if Obj.where()==6 and Obj.spell_level()~=0 then level=level+1 end

  local desc=""
  -- 1-2-book store 5-unit
  if Obj.where()~=5 then
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_desc_"..level..">"
  else
    desc = Game.Config("txt_font_config/hint_def").."<label="..Obj.name().."_small>"
  end

  return desc
end


-- ***************************************
-- * block new hint-konstuktoov
-- ***************************************
function gen_spell_desc_new( par )
-- par = simple,complex,multi
  local desc = ""
  local spell = Obj.name()
  local level = Obj.spell_level()
  local dur = ""
  local round = ""
  local duration = 0

  local function protect_text_dec( arg, i )
    local new_string, replaces = string.gsub( arg, ",", "" )
    if replaces + 1 < i then
      return text_dec( arg, 1 )
    else
      return text_dec( arg, i )
    end
  end

  if level == 0 then level = 1 end

  -- 1-2-book store 5-6-pumping unit
  if Obj.where() < 5 then
    if par == "simple" then
      desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">"
    end

    if par == "complex" then
      local count = text_dec( Logic.obj_par( spell, "unit_count" ), level )
      desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">" .. " " .. "<label=spell_C" .. count .. ">"
    end

    if par == "complex0" then
    	 local count = ""
--      if spell=="spell_gifts" or spell=="spell_target" then
--      	count="one"
--      else
--      	count = text_dec(Logic.obj_par(spell,"unit_count"),level)
--      end
      if count == "all" then
        desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">" .. "<label=spell_C" .. count .. ">"
      else
      	 if spell == "spell_bless" then
      		  if level == 3 then
      			   desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_"..level..">".."<label=spell_Call>"
      		  else
      			   desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<label=" .. spell .. "_text_" .. level .. ">"
      		  end
      	 else
      		  desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>"
      	 end
      end
    end

    if par == "multi" then
      --local count = text_dec(Logic.obj_par(Obj.name(),"unit_count"),level)
      desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc_" .. level .. ">"
    end

    duration = tonumber( "0" .. protect_text_dec( Logic.obj_par( spell, "duration" ), level ) )

    if duration ~= 0 then
      duration = gen_spell_duration( spell, level )
--      duration = tonumber("0" .. text_dec(Logic.obj_par(spell,"duration"),level))
--[[      if spell~="spell_adrenalin"  and Logic.obj_par(spell,"int")=="1" then
        duration = duration + math.floor(HInt()/tonumber(Game.Config("spell_power_config/int_duration")))
      end]]

      if duration < 10 then
        round = "<label=spell_hint_round_" .. duration .. ">"
      else
        round = "<label=spell_hint_round_10>"
      end

      dur = Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=spell_duration>" .. " " .. Game.Config( "txt_font_config/hint_sel" ) .. duration .. Game.Config( "txt_font_config/hint_sys" ) .. " " .. round
    else
      dur = ""
    end

    local mc = Obj.spell_mana( level )
    if mc < 0 then
    	 local tmp = Logic.hero_lu_item( "mana", "limit" )
    	 mc = -1 * tmp * mc / 100
    end
--    mc = gen_mana_discount( spell, mc ) --this displays correctly, but mana cost still uses spells.txt
    local mana = Game.Config( "txt_font_config/hint_sys" ) .. "<label=spell_hint_mana>" .. " " .. "<image=book_mana_icon.png> " .. "<label=hint_Sel_font>" .. mc

    if Obj.spell_level() ~= 0 then
      desc = desc .. dur .. "<br>" .. mana
    else
      if dur ~= "" then
        desc = desc .. dur
      end
    end
  end

  if Obj.where() == 5 then
    desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. Obj.name() .. "_small>"
  end

  if Obj.where() == 6 then
    level = level + 1
    if Obj.spell_level() ~= 0 then
      if par == "simple" then
        desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">"
      end

      if par == "complex" then
        local count = text_dec( Logic.obj_par( spell, "unit_count" ), level )
        desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">" .. " " .. "<label=spell_C" .. count .. ">"
      end

      if par == "complex0" then
    	   local count = ""
        if spell == "spell_gifts"
        or spell == "spell_target" then
      	   count = "one"
        else
      	   count = text_dec( Logic.obj_par( spell, "unit_count" ), level )
        end

        if count == "all" then
          desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=" .. spell .. "_text_" .. level .. ">" .. "<label=spell_C" .. count .. ">"
        else
      	   if spell == "spell_bless" then
      		    desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>" .. Game.Config( "txt_font_config/hint_sys" ) .. "<label=" .. spell .. "_text_" .. level .. ">"
      	   else
      		    desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc>"
      	   end
        end
      end

      if par == "multi" then
        desc = Game.Config( "txt_font_config/hint_def" ) .. "<label=" .. spell .. "_desc_" .. level .. ">"
      end

      duration = tonumber( "0" .. protect_text_dec( Logic.obj_par( spell, "duration" ), level ) )

      if duration ~= 0 then
        duration = gen_spell_duration( spell, level )
--        duration = tonumber("0" .. text_dec(Logic.obj_par(spell,"duration"),level))
--[[        if spell~="spell_adrenalin"  and Logic.obj_par(spell,"int")=="1" then
          duration = duration + math.floor(HInt()/tonumber(Game.Config("spell_power_config/int_duration")))
        end]]
        if duration < 10 then
          round = "<label=spell_hint_round_" .. duration .. ">"
        else
          round = "<label=spell_hint_round_10>"
        end
        dur = Game.Config( "txt_font_config/hint_sys" ) .. "<br>" .. "<label=spell_duration>" .. " " .. Game.Config( "txt_font_config/hint_sel" ) .. duration .. Game.Config( "txt_font_config/hint_sys" ) .. " " .. round
      else
        dur = ""
      end

      local mc = Obj.spell_mana( level )
      if mc < 0 then
    	   local tmp = Logic.hero_lu_item( "mana", "limit" )
    	   mc = -1 * tmp * mc / 100
      end

--      mc = gen_mana_discount( spell, mc ) --this displays correctly, but mana cost still uses spells.txt
      local mana = "<label=hint_TM_font>" .. "<label=spell_hint_mana>" .. " " .. "<image=book_mana_icon.png> " .. "<label=hint_Sel_font>" .. mc

      desc = desc .. dur .. "<br>" .. mana
    end
    --Requirements for pumping
    local cur_cr = Logic.hero_lu_item( "crystals", "count" )
    local need_cr = Obj.spell_crystals( Obj.spell_level() + 1 )
    local descUp = "<label=spell_up_need>" .. " " .. "<image=book_crystals_icon.png>"

    if need_cr > cur_cr
    or gen_spell_skill() ~= "false" then
      descUp = "<label=spell_hintNoUp_font>" .. descUp
    else
      descUp = Game.Config( "txt_font_config/hint_sys" ) .. descUp
    end

    if need_cr > cur_cr then
      descUp = descUp .. " " .. need_cr
    else
      descUp = descUp .. Game.Config( "txt_font_config/hint_sel" ) .. " " .. need_cr
    end

    if gen_spell_skill() ~= "false" then
      descUp = descUp .. gen_spell_skill()
    end

    if need_cr <= cur_cr
    and gen_spell_skill() == "false" then
      descUp = descUp .. "<br><label=spell_hintYesUp_font>"
      if Obj.spell_level() == 0 then
        descUp = descUp .. "<label=spell_Memorize>"
      else
        descUp = descUp .. "<label=spell_Upgrade>"
      end
    end

			 desc=desc .. "<br>" .. descUp

  end -- конец накнопочного хинта

  return desc
end

function gen_spell_mana()
  local mana=""
  local level=Obj.spell_level()

  if level==0 then level=1 end

  if Obj.where()==6 and Obj.spell_level()~=0 then level=level+1 end

  if Obj.spell_level()>0 and (Obj.where()==2 or Obj.where()==6 or Obj.where()==1) then
    local up=0

    if Obj.where()==6 then up=1 end

    local mc = Obj.spell_mana(Obj.spell_level()+up)
--    mc = gen_mana_discount( spell, mc ) --this displays correctly, but mana cost still uses spells.txt
    mana="<label=spell_hint_mana> "..mc
  --Game.Config("txt_font_config/hint_cap").."<label=spell_hint_m> ".."<label=hint_Def_font>"..mc
  end

  return mana
end

function gen_spell_skill()
  local result = "false"
  local skill=0
  local level=Obj.spell_level()
  local school=Obj.spell_school()

  if school==1 and level>=Logic.hero_lu_skill("order") then
    local itogo="<label=skill_hintNoUp_font>"
    local sk_need_name="<label=skill_".."order".."_name>"
    local sk_need_level=level+1
    result=itogo.."<br>'"..sk_need_name.."' "..sk_need_level.." <label=skill_level_need>"
  end

  if school==2 and level>=Logic.hero_lu_skill("dist") then
    local itogo="<label=skill_hintNoUp_font>"
    local sk_need_name="<label=skill_".."dist".."_name>"
    local sk_need_level=level+1
    result=itogo.."<br>'"..sk_need_name.."' "..sk_need_level.." <label=skill_level_need>"
  end

  if school==3 and level>=Logic.hero_lu_skill("chaos") then
    local itogo="<label=skill_hintNoUp_font>"
    local sk_need_name="<label=skill_".."chaos".."_name>"
    local sk_need_level=level+1
    result=itogo.."<br>'"..sk_need_name.."' "..sk_need_level.." <label=skill_level_need>"
  end

  return result
end

function get_spell_name()
--	if string.find(Obj.name(),"spell") or string.find(Obj.name(),"effect") or string.find(Obj.name(),"special") then
  return "<label="..Obj.name().."_name>"
--  else
--    return "<label="..Obj.name().."_head>"
--  end
end

function gen_spell_del_hint()
  local res = ""

	 if Obj.where()==1 and Obj.spell_level()==0 then
	   if Game.InsideBuilding() then
	    	res = "<label=spell_sell_scroll>"
	   else
  	   res = "<label=spell_delete_scroll>"
    end
  end

	 if Obj.where()==1 and Obj.spell_level()>1 then
   	res = "<label=spell_level_cast>"
  end

  return res
end

function gen_spell_caption()
  local sc = Obj.spell_school()
  local name=Game.Config("txt_font_config/hint_cap")

  if Obj.where()==1 then     -- 1-2-book store 5-unit
    return name
  end

	 if Obj.where()==2 then     -- 1-2-book store 5-unit
   	if sc == 1 then
     	name="<label=spell_CapMOrd_font>"
  	 end
  	 if sc == 2 then
     	name="<label=spell_CapMDis_font>"
  	 end
  	 if sc == 3 then
     	name="<label=spell_CapMCha_font>"
  	 end
  	 if sc == 4 then
     	name="<label=spell_CapMAdv_font>"
  	 end
	 end

	 if Obj.where()==5 then     -- 1-2-book store 5-unit
		  local spell_name=Obj.name()
		--if string.find(spell_name,"spell") then
			 local spell_type=Logic.obj_par(spell_name,"type")
			 if spell_type=="penalty" then
				  name="<label=spell_bad_font>"
			 end
			 if spell_type=="bonus" then
				 name="<label=spell_good_font>"
			 end
		--else

		--end
	 end

  return name
  --sc
end

function gen_arm_prc()
  local level = get_level( nil )
  local min_dmg, max_dmg, burn, duration, prc = pwr_armageddon( level )
--  local prc = tonumber( text_dec( Logic.obj_par( "spell_armageddon", "prc_damage" ), level ) )
  local text = gen_dmg_common_hint( "power", prc )

  return text
end

function gen_lvl_target()
  local level = get_level( nil )

 	return "1-" .. text_dec( Logic.obj_par( "spell_target", "lvl" ), level )
end

function gen_lvl_target2()
	 return "1-" .. Attack.act_spell_param( 0, "spell_target", "lvl" )
end

-- HOMM3 Babies Functions
function gen_spell_duration( spell, level )
  -- Assumes that the bonus is of the format "sp_duration_spellname" - refer to spells.txt and special_params.txt
  local bonus = string.gsub( spell, "spell_", "sp_duration_" )
  local dur = int_dur( spell, level, bonus )

  return dur
end

--[[ --Mana use seems to be hardcoded, so even though the hint can be changed the value still uses the one in spells.txt
function gen_mana_discount( spell, mana_cost )
  if spell=="spell_stone_skin" then
    mana_cost = math.ceil( mana_cost / ( 1 + Logic.hero_lu_item("sp_mana_stone_skin","count")/50 ) )
  end

  return mana_cost
end]]
