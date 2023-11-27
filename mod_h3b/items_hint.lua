-- New! For generating the amount of dragonfly wings you have
function gen_dragonfly_wings()
  local count = Logic.hero_lu_item( "wing_dragonfly", "count" )

  return tostring( count )
end

-- New! Hint generator for containers (i.e. seeds, eggs, etc.)
function gen_egg_param()
  local effect_color = "<color=230,232,250>"
  local variant_color = "<color=0,187,232>"
  local stat_color = "<color=253,248,255>"
  local unit_color = "<color=240,168,4>"
  local troop = Obj.get_param( "troop" )
  local troopcnt = Obj.get_param( "troopcount" )
  local trand = Obj.get_param( "random" )
  local factor = Logic.cur_lu_item( Obj.name(), "count" )
  local altfactor = Obj.get_param( "altfactor" )

  local function fill_tables( troop, troopcnt, trand )
    local troops, troopcnts, trands = {}, {}, {}
    local numberoftroops = text_par_count( troop )
  
    for i = 1, numberoftroops do
      local substring = text_dec( troop, i )
      table.insert( troops, substring )
      local substring = text_dec( troopcnt, i )
      table.insert( troopcnts, substring )
      local substring = text_dec( trand, i )
      table.insert( trands, substring )
    end

    return troops, troopcnts, trands
  end

  local troops, troopcnts, trands = fill_tables( troop, troopcnt, trand )

  local function get_weight( trands )
    local totalweight = 0
  
    for i = 1, table.getn( trands ) do
      totalweight = totalweight + tonumber( trands[ i ] )
    end

    return totalweight
  end

  local totalweight = get_weight( trands )
  local text = ""

  local function gen_poss_text( troops, troopcnts, trands, totalweight, altfactor, indent )
    local text = ""

    for i = 1, table.getn( troops ) do
      local poss = round( tonumber( trands[ i ] ) / totalweight * 100 )
      local indentstring = ""

      if indent ~= nil then
        indentstring = "  "
      end

      if poss == 100 then
        text = text .. "<br>" .. indentstring .. "<label=itm_egg_produces> " .. stat_color .. troopcnts[ i ] .. "</color>"
      else
        text = text .. "<br>" .. indentstring .. effect_color .. tostring( poss ) .. "%</color> <label=itm_egg_produce> " .. stat_color .. troopcnts[ i ] .. "</color>"
      end
    
      if tonumber( troopcnts[ i ] ) == 1 then
        text = text .. unit_color .. " <label=cpn_" .. troops[ i ] .. "></color>"
      else
        text = text .. unit_color .. " <label=cpsn_" .. troops[ i ] .. "></color>"
      end

      local container = ""

      if string.find( Obj.name(), "egg" ) then
        container = "egg"
      elseif string.find( Obj.name(), "grave" ) then
        container = "grave"
      elseif string.find( Obj.name(), "seed" ) then
        container = "seed"
      else
        container = "container"
      end

      if altfactor == nil then
        text = text .. " <label=itm_egg_per> <label=itm_egg_" .. container .. ">"
      else
        text = text .. " <label=itm_egg_per> " .. stat_color .. altfactor .. "</color> <label=itm_egg_" .. container .. "s>"
      end
    end

    return text
  end

  local function get_alt_data()
    local troop = Obj.get_param( "alttroop" )
    local troopcnt = Obj.get_param( "alttroopcount" )
    local trand = Obj.get_param( "altrandom" )

    return troop, troopcnt, trand
  end

  if altfactor ~= nil
  and altfactor ~= "" then
    local altfactormin, altfactormax = text_range_dec( altfactor )

    if factor < altfactormin then
      if table.getn( troops ) > 1 then
        text = " <label=itm_egg_uncertain><br>"
      else
        text = "<br>"
      end

      text = text .. gen_poss_text( troops, troopcnts, trands, totalweight )
    elseif factor >= altfactormax then
      troop, troopcnt, trand = get_alt_data()
      troops, troopcnts, trands = fill_tables( troop, troopcnt, trand )
      totalweight = get_weight( trands )
      if table.getn( troops ) > 1 then
        text = " <label=itm_egg_uncertain><br>"
      else
        text = "<br>"
      end

      text = text .. gen_poss_text( troops, troopcnts, trands, totalweight, altfactor )
    else
      local num = factor - altfactormin + 1
      local den = altfactormax - altfactormin + 1
      local poss = round( num / den * 100 )

      if table.getn( troops ) > 1 then
        text = " <label=itm_egg_uncertain>"
      end

      text = text .. "<br>" .. variant_color .. tostring( 100 - poss ) .. "%</color> <label=itm_egg_variant1>"
      text = text .. gen_poss_text( troops, troopcnts, trands, totalweight, nil, true )
      troop, troopcnt, trand = get_alt_data()
      troops, troopcnts, trands = fill_tables( troop, troopcnt, trand )
      totalweight = get_weight( trands )
      text = text .. "<br>" .. variant_color .. tostring( poss ) .. "%</color> <label=itm_egg_variant2>"
      text = text .. gen_poss_text( troops, troopcnts, trands, totalweight, altfactor, true )
    end
  else
    if table.getn( troops ) > 1 then
      text = " <label=itm_egg_uncertain><br>"
    else
      text = "<br>"
    end

    text = text .. gen_poss_text( troops, troopcnts, trands, totalweight )
  end

  return text
end


--New! Function for generating children hint
function gen_itm_kid_hint( par )
  local color = "<color=255,243,179>"
  local effect_color = "<color=230,232,250>"
  local stat_color = "<color=253,248,255>"
  local spell_color = "<color=0,187,232>"
  local spirit_color = "<color=243,107,8>"
  local unit_color = "<color=240,168,4>"
  local race_color = "<color=217,217,25>"

  -- "Quick and Dirty's"
  if par == "astral"
--  or par == "astral_resist"
  or par == "attack"
  or par == "attack_with_abbrev"
  or par == "attack_abbrev"
  or par == "base_damage"
  or par == "base_damage_with_abbrev"
  or par == "base_damage_abbrev"
  or par == "fire"
--  or par == "fire_resist"
  or par == "krit"
  or par == "krit_with_abbrev"
  or par == "krit_abbrev"
  or par == "damage"
  or par == "defense"
  or par == "defense_with_abbrev"
  or par == "defense_abbrev"
  or par == "enemy"
  or par == "health"
  or par == "health_with_abbrev"
  or par == "health_abbrev"
  or par == "init"
  or par == "init_with_abbrev"
  or par == "init_abbrev"
  or par == "lr"
  or par == "lr_with_abbrev"
  or par == "lr_abbrev"
  or par == "magic"
--  or par == "magic_resist"
  or par == "morale"
  or par == "morale_with_abbrev"
  or par == "morale_abbrev"
  or par == "physical"
--  or par == "physical_resist"
  or par == "poison"
--  or par == "poison_resist"
  or par == "resist"
  or par == "resistance"
  or par == "speed"
  or par == "speed_with_abbrev"
  or par == "speed_abbrev"
  or par == "ur"
  or par == "ur_with_abbrev"
  or par == "ur_abbrev" then
    return color .. "<label=itm_kid_" .. par .. "></color>"
  elseif par == "colon_space" then
    return color .. ": </color>"
  elseif par == "comma_space_and_space" then
    return color .. ", and </color>"
  elseif par == "comma_space" then
    return color .. ", </color>"
  elseif par == "end" then
    return color .. ".<br></color>"
  elseif par == "space" then
    return color .. " </color>"
  elseif par == "space_and_space" then
    return color .. " and </color>"
  elseif par == "space_slash_space" then
    return color .. " / </color>"
  end

  local text = ""

  local function protect_text_dec( arg, i )
    local new_string, replaces = string.gsub( arg, ",", "" )

    if replaces + 1 < i then
      return nil
    else
      return text_dec( arg, i )
    end
  end

  local function get_function_parameters( par )
    local par_type = protect_text_dec( par, 1 )
    local par_type_level = tonum( protect_text_dec( par, 2 ) )
    
    return par_type, par_type_level
  end

  local function get_gain_type_value( par, par_type_level, parloc1, parloc2, unit_level )

    if parloc1 == nil then
      parloc1 = 3
    end

    if parloc2 == nil then
      parloc2 = 4
    end

    local par_gain = protect_text_dec( par, parloc1 )
    
    if par_gain == nil then
      par_gain = 1
    else
      par_gain = tonumber( par_gain )
    end
    
    local par_gain_type = protect_text_dec( par, parloc2 )

    if par_gain_type == nil
    or par_gain_type == "" then
      par_gain_type = "plus_power_percent"
    end

    local par_type_kid_level = false

    if string.find( par_gain_type, "power_percent" ) then
      par_type_kid_level = true
    end

    local kid_level = 1
    
    if par_type_kid_level == true then
      kid_level = Obj.price()
    end
    
    local value
    if unit_level == nil then
      value = math.max( math.floor( kid_level * par_type_level * par_gain ), 1 )
    else
      value = math.ceil( ( kid_level + ( 5 - unit_level ) * 5 ) * par_gain )
    end

    return par_gain_type, value
  end

  if string.find( par, "preamble" )
  or string.find( par, "postamble" ) then
    local labelname = protect_text_dec( par, 1 )
    local gender = protect_text_dec( par, 2 )
    text = text .. "<label=itm_kid_" .. gender .. "_" .. labelname .. ">"

  elseif string.find( par, "value_only" ) then
    local dummy, skill_level = get_function_parameters( par )
    
    if skill_level ~= nil then
      local skill_gain_type, value = get_gain_type_value( par, skill_level )
      text = text .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" ) .. ".<br>"
    end

  elseif string.find( par, "astral_damage" )
  or string.find( par, "fire_damage" )
  or string.find( par, "magic_damage" )
  or string.find( par, "physical_damage" )
  or string.find( par, "poison_damage" ) then
    local damage, damage_level = get_function_parameters( par )

    if damage_level ~= nil then
      local damage_gain_type, value = get_gain_type_value( par, damage_level )
      text = text .. " and " .. gen_dmg_common_hint( damage_gain_type, value, nil, nil, stat_color, "</color>" ) .. " <label=itm_kid_" .. damage .. ">" .. ".<br>"
    end

  elseif string.find( par, "astral_eresist" )
  or string.find( par, "astral_resist" )
  or string.find( par, "fire_eresist" )
  or string.find( par, "fire_resist" )
  or string.find( par, "magic_eresist" )
  or string.find( par, "magic_resist" )
  or string.find( par, "physical_eresist" )
  or string.find( par, "physical_resist" )
  or string.find( par, "poison_eresist" )
  or string.find( par, "poison_resist" ) then
    local resist, resist_level = get_function_parameters( par )

    if resist_level ~= nil then
      local resist_gain_type, value = get_gain_type_value( par, resist_level )
      text = text .. color .. "<label=itm_kid_" .. resist .. ">: </color>" .. gen_dmg_common_hint( resist_gain_type, value, nil, nil, stat_color, "</color>" ) .. ".<br>"
    end

  elseif string.find( par, "effect_" ) then
    local effect, effect_level = get_function_parameters( par )
    
    if effect_level ~= nil then
      local effect_display = protect_text_dec( par, 3 )
      local effect_gain_type, value = get_gain_type_value( par, effect_level, 4, 5 )

      if effect_display == "start" then
        text = text .. color .. "<label=itm_kid_effect> </color>" .. effect_color .. "<label=itm_kid_" .. effect .. "></color> - "

      elseif effect_display == "starts" then
        text = text .. color .. "<label=itm_kid_effects> </color>" .. effect_color .. "<label=itm_kid_" .. effect  .. "></color>"

      elseif effect_display == "comma_space" then
        text = text .. effect_color .. ", <label=" .. effect .. "_name></color> - "

      elseif effect_display == "and_name_end" then
        text = text .. effect_color .. " and <label=" .. effect .. "_name></color> - "

      elseif effect_display == "comma_and_name_end" then
        text = text .. effect_color .. ", and <label=" .. effect .. "_name></color> - "

      elseif effect_display == "bonus"
      or effect_display == "penalty"
      or effect_display == "power" then
        text = text .. color .. "<label=itm_kid_effect_" .. effect_display .. "> </color>" .. gen_dmg_common_hint( effect_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif effect_display == "blood"
      or effect_display == "burn"
      or effect_display == "charm"
      or effect_display == "corrosion"
      or effect_display == "curse"
      or effect_display == "fear"
      or effect_display == "freeze"
      or effect_display == "holy"
      or effect_display == "poison"
      or effect_display == "shock"
      or effect_display == "sleep"
      or effect_display == "slow"
      or effect_display == "stun"
      or effect_display == "weakness" then
        local infliction = string.gsub( effect_display, string.sub( effect_display, 1, 1 ), string.upper( string.sub( effect_display, 1, 1 ) ), 1 )
        text = text .. ", <label=itm_kid_effect_infliction> " .. infliction .. ": " .. gen_dmg_common_hint( effect_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif string.find( effect_display, "duration" ) then
        if effect_display == "and_duration" then
          text = text .. " and "
        elseif effect_display == "comma_and_duration" then
          text = text .. ", and "
        end
  
        text = text .. "<label=itm_kid_effect_duration> " .. gen_dmg_common_hint( "plus_power", effect_level, nil, nil, stat_color, "</color>" )

      elseif effect_display == "no_init_penalty" then
        text = text .. ", " .. stat_color .. "No Initiative Penalty</color>"

      elseif effect_display == "value" then
        text = text .. gen_dmg_common_hint( effect_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif effect_display == "end" then
        text = text .. ".<br>"
      end
    end

  elseif string.find( par, "skill_" ) then
    local skill, skill_level = get_function_parameters( par )
    
    if skill_level ~= nil then
      local skill_gain_type, value = get_gain_type_value( par, skill_level )

      if skill == "skill_scholar" then
        local mod = Game.Config( "spell_power_config/mod" )
        local den_scholar = Game.Config( "spell_power_config/den_scholar" )
        local intellect = tostring( mod - skill_level / den_scholar )
        value = value / den_scholar
        text = text .. color .. "<label=itm_kid_" .. skill .. "> </color>" .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" ) .. " for every " .. stat_color .. intellect .. "</color> Intelligence.<br>"
      elseif skill == "skill_archery"
      or skill == "skill_offense" then
        text = text .. color .. "<label=itm_kid_" .. skill .. "> </color>" .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" )

        if skill_level == 1 then
          text = text .. ".<br>"
        end
      elseif skill == "skill_navigation" then
        text = text .. color .. "<label=itm_kid_" .. skill .. "> </color>" .. gen_dmg_common_hint( "plus_power", skill_level, nil, nil, stat_color, "</color>" ) .. ", Critical Hit: " .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" ) .. ".<br>"
      elseif skill == "skill_necromancy" then
        text = text .. color .. "<label=itm_kid_" .. skill .. "> <label=itm_kid_lr>: </color>" .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" ) .. ".<br>"
      else
        text = text .. color .. "<label=itm_kid_" .. skill .. "> </color>" .. gen_dmg_common_hint( skill_gain_type, value, nil, nil, stat_color, "</color>" ) .. ".<br>"
      end
    end

  elseif string.find( par, "spell_" ) then
    local spell, spell_level = get_function_parameters( par )
    
    if spell_level ~= nil then
      local spell_display = protect_text_dec( par, 3 )
      local spell_gain_type, value = get_gain_type_value( par, spell_level, 4, 5 )

      if spell_display == "start" then
        text = text .. color .. "<label=itm_kid_spell> </color>" .. spell_color .. "<label=" .. spell .. "_name></color> - "

      elseif spell_display == "starts" then
        text = text .. color .. "<label=itm_kid_spells> </color>" .. spell_color .. "<label=" .. spell .. "_name></color>"

      elseif spell_display == "comma_space" then
        text = text .. spell_color .. ", <label=" .. spell .. "_name></color>"

      elseif spell_display == "and_name_end" then
        text = text .. spell_color .. " and <label=" .. spell .. "_name></color> - "

      elseif spell_display == "comma_and_name_end" then
        text = text .. spell_color .. ", and <label=" .. spell .. "_name></color> - "

      elseif spell_display == "bonus"
      or spell_display == "count"
      or spell_display == "distance"
      or spell_display == "mana"
      or spell_display == "penalty"
      or spell_display == "power"
      or spell_display == "prc" then
        text = text .. color .. "<label=itm_kid_spell_" .. spell_display .. "> " .. gen_dmg_common_hint( spell_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif spell_display == "burn"
      or spell_display == "freeze"
      or spell_display == "holy"
      or spell_display == "poison"
      or spell_display == "shock"
      or spell_display == "stun" then
        local infliction = string.gsub( spell_display, string.sub( spell_display, 1, 1 ), string.upper( string.sub( spell_display, 1, 1 ) ), 1 )
        text = text .. ", <label=itm_kid_spell_infliction> " .. infliction .. ": " .. gen_dmg_common_hint( spell_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif string.find( spell_display, "duration" ) then
        if spell_display == "and_duration" then
          text = text .. " and "
        elseif spell_display == "comma_and_duration" then
          text = text .. ", and "
        end
  
        text = text .. "<label=itm_kid_spell_duration> " .. gen_dmg_common_hint( "plus_power", spell_level, nil, nil, stat_color, "</color>" )

      elseif spell_display == "no_init_penalty" then
        text = text .. ", " .. stat_color .. "No Initiative Penalty</color>"

      elseif spell_display == "value" then
        text = text .. gen_dmg_common_hint( spell_gain_type, value, nil, nil, stat_color, "</color>" )
      end
    end

  elseif string.find( par, "unit_" ) then
    local unit, bonus_level = get_function_parameters( par )
    
    if bonus_level ~= 0 then
      local unit_display = protect_text_dec( par, 3 )
      local level_inc = 0

      if string.find( par, "level+" ) then
        local level_inc_string = protect_text_dec( par, 6 )
        level_inc = tonumber( string.sub( level_inc_string, 7 ) )
      end

      if unit_display == "start" then
        text = text .. color .. "<label=itm_kid_unit> </color>" .. unit_color .. "<label=" .. string.gsub( unit, "unit_", "cpsn_" ) .. "></color> - "

      elseif unit_display == "starts" then
        text = text .. color .. "<label=itm_kid_units> </color>" .. unit_color .. "<label=" .. string.gsub( unit, "unit_", "cpsn_" ) .. "></color>"

      elseif unit_display == "comma_space" then
        text = text .. unit_color .. ", <label=" .. string.gsub( unit, "unit_", "cpsn_" ) .. "></color>"

      elseif unit_display == "and_name_end" then
        text = text .. unit_color .. " and <label=" .. string.gsub( unit, "unit_", "cpsn_" ) .. "></color> - "

      elseif unit_display == "comma_and_name_end" then
        text = text .. unit_color .. ", and <label=" .. string.gsub( unit, "unit_", "cpsn_" ) .. "></color> - "

      elseif unit_display == "attack"
      or unit_display == "defense" then
        local value = tonum( protect_text_dec( par, 4 ) )
        unit = string.gsub( unit, "unit_", "" )
        local unit_level = Logic.cp_level( unit ) + level_inc
        text = text .. gen_dmg_common_hint( "plus_power", value * bonus_level * unit_level, nil, nil, stat_color, "</color>" )

      elseif unit_display == "krit"
      or unit_display == "health"
      or unit_display == "lr" then
        unit = string.gsub( unit, "unit_", "" )
        local unit_level = Logic.cp_level( unit ) + level_inc
        local unit_gain_type, value = get_gain_type_value( par, bonus_level, 4, 5, unit_level )
        text = text .. gen_dmg_common_hint( unit_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif unit_display == "value" then
        local unit_gain_type, value = get_gain_type_value( par, bonus_level, 4, 5 )
        text = text .. gen_dmg_common_hint( unit_gain_type, value, nil, nil, stat_color, "</color>" )
      end
    end

  elseif string.find( par, "_race" ) then
    local race, race_level = get_function_parameters( par )
    
    if race_level ~= 0 then
      local race_display = protect_text_dec( par, 3 )

      if race_display == "start" then
        text = text .. color .. "<label=itm_kid_race> </color>" .. race_color .. "<label=inf_" .. race .. "_heads></color> - "

      elseif race_display == "starts" then
        text = text .. color .. "<label=itm_kid_races> </color>" .. race_color .. "<label=inf_" .. race .. "_heads></color>"

      elseif race_display == "start_with_units" then
        text = text .. color .. "<label=itm_kid_race> </color>" .. race_color .. "<label=inf_" .. race .. "_heads></color>"

      elseif race_display == "comma_space" then
        text = text .. race_color .. ", <label=" .. race .. "_heads></color>"

      elseif race_display == "and_name_end" then
        text = text .. race_color .. " and <label=" .. race .. "_heads></color> - "

      elseif race_display == "comma_and_name_end" then
        text = text .. race_color .. ", and <label=" .. race .. "_heads></color> - "

      elseif race_display == "attack"
      or race_display == "defense" then
        text = text .. stat_color .. "+Unit Level</color>"

      elseif race_display == "krit"
      or race_display == "health"
      or race_display == "lr" then
        local race_gain_type, value = get_gain_type_value( par, race_level, 4, 5 )
        text = text .. gen_dmg_common_hint( race_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif race_display == "value" then
        local race_gain_type, value = get_gain_type_value( par, race_level, 4, 5 )
        text = text .. gen_dmg_common_hint( race_gain_type, value, nil, nil, stat_color, "</color>" )
      end
    end

  elseif string.find( par, "spirit_" ) then
    local spirit, spirit_level = get_function_parameters( par )

    if spirit_level ~= 0 then
      local spirit_display = protect_text_dec( par, 3 )

      if spirit_display == "start" then
        local spirit_name = protect_text_dec( par, 4 )
        text = text .. color .. "<label=itm_kid_spirit> </color>" .. spirit_color .. "<label=spirit_" .. spirit_name .. "> <label=" .. string.gsub( spirit, "spirit_", "cpsn_" ) .. "></color> - "

      elseif spirit_display == "starts" then
        text = text .. color .. "<label=itm_kid_spirits> </color>" .. spirit_color .. "<label=" .. string.gsub( spirit, "spirit_", "cpsn_" ) .. "></color>"

      elseif spirit_display == "comma_space" then
        text = text .. spirit_color .. ", <label=" .. string.gsub( spirit, "spirit_", "cpsn_" ) .. "></color>"

      elseif spirit_display == "and_name_end" then
        text = text .. spirit_color .. " and <label=" .. string.gsub( spirit, "spirit_", "cpsn_" ) .. "></color> - "

      elseif spirit_display == "comma_and_name_end" then
        text = text .. spirit_color .. ", and <label=" .. string.gsub( spirit, "spirit_", "cpsn_" ) .. "></color> - "

      elseif spirit_display == "attack"
      or spirit_display == "defense"
      or spirit_display == "krit"
      or spirit_display == "health"
      or string.find( spirit_display, "_resist" ) then
        local spirit_gain_type, value = get_gain_type_value( par, spirit_level, 4, 5 )
        text = text .. gen_dmg_common_hint( spirit_gain_type, value, nil, nil, stat_color, "</color>" )

      elseif spirit_display == "value" then
        local spirit_gain_type, value = get_gain_type_value( par, spirit_level, 4, 5 )
        text = text .. gen_dmg_common_hint( spirit_gain_type, value, nil, nil, stat_color, "</color>" )
      end
    end
  end

  return text
end

function gen_itm_menu_hint()

    local res = ""
    if Obj.where()~=2 and not Obj.props("wife") then
        res="<label=itm_main_menu>"
    end
  return res

end

function gen_itm_name()

	if Obj.props(0)~="" and Obj.props(0)~=nil then
  	if Obj.props("wife") then
   		return " ( <label=itm_wife> )"
  	end 	
  	if Obj.props("child") then
   		return " ( <label=itm_chid> )"
  	end 
  	return ""
  else 
  	return ""
  end 
end

function gen_itm_race()
 local mr = "<br><label=itm_race> "
	
 if Obj.props(0)~="" and Obj.props(0)~=nil then
   local race = Obj.race()
 	 return mr.."<label=itm_"..race..">"
 end 

 return ""

end

function gen_itm_count()
 local count=Obj.get_param("item_count")
 if count ~= "" and count ~= nil then
 	return count
 else
 	return ""
 end 
	
end

function gen_itm_item()
 local count=Obj.get_param("item_add")
 if count ~= "" and count ~= nil then
 	return "<label=itm_"..count.."_name>"
 else
 	return ""
 end 
	
end

function gen_itm_gold( par )
  local param = Obj.get_param( "gold" )

  if param ~= ""
  and param ~= nil then
    param=tonumber( param )
    local mnog=1
    if par == "level" then
 		   mnog = tonumber( Logic.hero_lu_var( "level" ) )
    end 

    return tostring(param*mnog)
  else 
    return ""
  end 

 	return ""
end

function gen_itm_param(par)
 local count=text_par_count(par)
 if count>1 then 
 	local param=Obj.get_param(text_dec(par,1))
 	local suffiks=text_dec(par,2)
 	return param..suffiks
 else 
 	return Obj.get_param(par)
 end 
 	return ""
end

function gen_itm_dragon(par)
 	local param=Obj.get_param("dragon")
 	if param~="" and param~="0" and param~=nil then
 		return "<label=cpn_"..param..">"
 	else 
 		return "<label=itm_nodragon>"
 	end 
end

function gen_itm_zlogn(par)
 	local param=Obj.get_param("use")
 	if param~="" and param~=nil then
 		local cnt=tonumber(param)
 		if cnt>=11 then return "<label=itm_egnum_st_4>" end 
 		if cnt>=8 then return "<label=itm_egnum_st_3>" end 
 		if cnt>=4 then return "<label=itm_egnum_st_2>" end 
 		if cnt>=1 then return "<label=itm_egnum_st_1>" end 
 		if cnt==0 then return "<label=itm_egnum_st_0>" end 
 	else 
 		return "<label=itm_egnum_st_0>"
 	end 
end
function gen_itm_scroll()
 local count=Obj.get_param("scroll")
 if count ~= "" and count ~= nil then
 	return "<label=spell_"..count.."_name>"
 else
 	return ""
 end 
	
end

function gen_item_text()
 local label=Obj.get_param("label")
 local text_tmp=Obj.get_param("text")
 local text = "<label="..string.gsub(label, "number", text_tmp)..">"
 	return text

end

function gen_itm_upgrade()
 local mr = "<br>"
 local upgrade = Obj.get_param("upgrade")
 if upgrade~="" and upgrade~=nil then
 	local count=text_par_count(upgrade)
 	local fnt=""
 	for i=1,count do
 		if Obj.name()==text_dec(upgrade,i) then
 			fnt="<label=itm_upgrade_cur>"
 		else
 			fnt="<label=itm_upgrade_up>"
 		end 
 		mr=mr.."<br>"..fnt.." - <label=itm_"..text_dec(upgrade,i).."_name>"
 	end 
 	return mr
 else
 	return ""
 end 
	
end

function gen_itm_state()
 local mr = ""
 local upgrade = Obj.get_param("upgrade")
 if Obj.moral()==0 and Obj.props("moral") then mr="<br><label=itm_state_out>" end 
 if Obj.upg()~=nil and Obj.upg()~="" then --Obj.moral()~=0 and
 	mr="<br><label=itm_state_upgrade>"
 end 
 
 if Obj.where()>2 and Obj.where()<5 then 
 	return mr	
 else
 	return ""
 end 
end

function gen_itm_type()
	local mr="<br><br><label=itm_type> "
	if Obj.props(0)~="" and Obj.props(0)~=nil then
   return mr.."<label=itm_"..Obj.props(0)..">"
  end 
  if Obj.props("quest") then
   return mr.."<label=itm_quest>"
  end 
  if Obj.props("wife") then
   return "" --<br><br><label=itm_wife>"
  end 
  if Obj.props("child") then
   return "" --<br><br><label=itm_child>"
  end 
  if Obj.props("map") then
   return mr.."<label=itm_map>"
  end 
  if Obj.props("usable") then
   return mr.."<label=itm_usual>"
  end 
  if Obj.props("container") then
   return mr.."<label=itm_resource>"
  end 
  
  --itm_diamond
  
  if Obj.get_param("sell")=="1" then
  	return mr.."<label=itm_diamond>"
  end
  if Obj.get_param("recept")=="1" then
  	return mr.."<label=itm_recept>"
  end

  return mr.."Unknow item type!"
end

function gen_itm_price()
  if Obj.props("quest") or Obj.props("wife") or Obj.props("child") or Obj.where()==2 then
   return ""
  else
   return "<br><label=itm_price> "..tostring(Obj.price())
  end 
  return mr.."Not price!"
end

function gen_itm_moral()

-- 0-5 5-20 20-40 --- 60-80 80-95 95-100  

  local moral = Obj.moral()
  local mr = "<br><label=itm_moral> "
	
 if Obj.props("moral") then
  if moral<=5 then
    return mr.."<label=itm_moral_l3> (" .. tostring(moral) .. ")"
  end
  if moral>5 and moral<=20 then
    return mr.."<label=itm_moral_l2> (" .. tostring(moral) .. ")"
  end
  if moral>20 and moral<=40 then
    return mr.."<label=itm_moral_l1> (" .. tostring(moral) .. ")"
  end
  if moral>40 and moral<=60 then
    return mr.."<label=itm_moral_n0> (" .. tostring(moral) .. ")"
  end
  if moral>60 and moral<=80 then
    return mr.."<label=itm_moral_h1> (" .. tostring(moral) .. ")"
  end
  if moral>80 and moral<=95 then
    return mr.."<label=itm_moral_h2> (" .. tostring(moral) .. ")"
  end
  if moral>95 then
    return mr.."<label=itm_moral_h3> (" .. tostring(moral) .. ")"
  end
 else 
	return ""
 end 	
		return ""
end

function map_image_gen()
 local map=Obj.get_param("map")
 local image=Obj.get_param("image")

 image = "<image="..string.gsub(image,"number",map)..".png>"
 return image

end
