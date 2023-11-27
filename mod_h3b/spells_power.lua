-- ***********************************************
-- * Returns the intellect of the hero
-- ***********************************************
function HInt()
  return Logic.get_hero_intellect()
end


-- NEW! Limits a value to a certain range
function limit_value( value, min, max )
  if max ~= nil then
    value = math.min( value, max )
  end

  if min ~= nil then
    value = math.max( value, min )
  end

  return value
end


-- NEW! Gets the enemy hero level if function inputs are nil
function get_enemy_hero_stuff( level )
  local ehero_level = Logic.enemy_hero_level()
  local spell_level_min_limit = tonumber( Game.Config( "spell_power_config/spell_level_min_limit" ) )
  local spell_level_max_limit = tonumber( Game.Config( "spell_power_config/spell_level_max_limit" ) )
  local level_inc_elevel = tonumber( Game.Config( "spell_power_config/level_inc_elevel" ) )

  if ehero_level ~= nil then
    if ehero_level ~= 0 then
      local ehero_int = HInt()
      if ehero_int ~= nil then
        level = math.max( math.min( math.ceil( math.max( ehero_level, ehero_int ) / level_inc_elevel ), spell_level_max_limit ), spell_level_min_limit )
      else
        level = math.max( math.min( math.ceil( ehero_level / level_inc_elevel ), spell_level_max_limit ), spell_level_min_limit )
      end
    else
      local name = Attack.act_name( 0 )

      if string.find( name, "tower" ) then
        level = Attack.val_restore( 0, "tower_spell_level" )
        ehero_level = tonumber( Attack.val_restore( 0, "tower_level" ) )
      end
    end
  end

  return ehero_level, level
end


-- New common function for rounding properly (i.e. floor if value is < 0.5, ceiling otherwise
function round( value )
  local decimal = value - math.floor( value )

  if decimal >= 0.5 then
    value = math.ceil( value )
  else
    value = math.floor( value )
  end

  return value
end


-- New implementation of LUA 5.1 modulo % operator
function modulo( a, b )
  return a - math.floor( a / b ) * b
end


-- New common function for computing power increase as a function of intelligence
function int_pwr( pwr, ehero_level )
  local num = HInt()
  local mod = tonumber( Game.Config( "spell_power_config/mod" ) )
  local mod_limit = tonumber( Game.Config( "spell_power_config/mod_limit" ) )
  local den_scholar = tonumber( Game.Config( "spell_power_config/den_scholar" ) )
  local inc = tonumber( Game.Config( "spell_power_config/inc" ) )
  local inc_limit = tonumber( Game.Config( "spell_power_config/inc_limit" ) )

  if ehero_level == nil then
    mod = math.max( mod_limit, mod - tonumber( Logic.hero_lu_item( "sp_power_mod", "count" ) ) / den_scholar )
    inc = math.max( inc_limit, inc + tonumber( Logic.hero_lu_item( "sp_power_inc", "count" ) ) )
  end

  pwr = pwr * ( 1 + math.floor( num / mod ) * inc / 100 )

  return pwr
end


-- New common function for determining spell bonuses based on type
function get_sp_bonus( spell, bonus_type, ehero_level )
  local bonus = Logic.obj_par( spell, bonus_type )
  local spell_bonus = 1
  if bonus == "1"
  or bonus == "fire"
  or bonus == "physical"
  or bonus == "magic"
  or bonus == "poison"
  or bonus == "astral" then
    if ehero_level == nil then
      if bonus_type == "hero" then
        spell_bonus = 1 + tonumber( Logic.hero_lu_var( "level" ) ) / 100
      elseif bonus_type == "destroyer" then
        spell_bonus = 1 + tonumber( skill_power2( "destroyer", 1 ) ) / 100
      elseif bonus_type == "attack"
      or bonus_type == "defense"
      or bonus_type == "fire"
      or bonus_type == "physical"
      or bonus_type == "magic"
      or bonus_type == "poison"
      or bonus_type == "astral" then
        spell_bonus = 1 + tonumber( Logic.hero_lu_item( "sp_spell_" .. bonus_type, "count" ) ) / 100
      elseif bonus_type == "typedmg" then
        spell_bonus = 1 + tonumber( Logic.hero_lu_item( "sp_spell_" .. bonus, "count" ) ) / 100
      elseif bonus_type == "healer" then
        spell_bonus = 1 + tonumber( skill_power2( "healer", 1 ) ) / 100
      elseif bonus_type == "holy" then
        spell_bonus = 1 + tonumber( hero_item_count2( "sp_spell_holy", "count" ) ) / 100
      elseif bonus_type == "glory" then
        spell_bonus = 1 + tonumber( skill_power2( "glory", 3 ) ) / 100
      elseif bonus_type == "holy_rage" then
        spell_bonus = 1 + tonumber( skill_power2( "holy_rage", 3 ) ) / 100
      elseif bonus_type == "necromancy" then
    	   spell_bonus = 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100
      elseif bonus_type == "int_pwr" then
        spell_bonus = spell_bonus * ( 1 + tonumber( Logic.hero_lu_item( "sp_power_int", "count" ) ) / 100 )
      end
    else
      local ehero_int = HInt()
      if bonus_type == "hero" then
        spell_bonus = 1 + ehero_level / 100
      elseif bonus_type == "destroyer" then
        if ehero_int > ehero_level then
          spell_bonus = 1 + ehero_int / 100
        else
          spell_bonus = 1 + ehero_level / 200
        end
      else
        if ehero_int > ehero_level then
          spell_bonus = 1 + ehero_int / 200
        else
          spell_bonus = 1 + ehero_level / 400
        end
      end
    end
  end

  return spell_bonus
end


-- New common function for get skill and other multiplier bonuses
function get_spell_bonus( spell, text, ehero_level )
  local bonus_string = ""
  local sp_hero = get_sp_bonus( spell, "hero", ehero_level )
  local sp_destroyer = get_sp_bonus( spell, "destroyer", ehero_level )
  local sp_attack = get_sp_bonus( spell, "attack", ehero_level )
  local sp_defense = get_sp_bonus( spell, "defense", ehero_level )
  local sp_healer = get_sp_bonus( spell, "healer", ehero_level )
  local sp_holy = get_sp_bonus( spell, "holy", ehero_level )
  local sp_glory = get_sp_bonus( spell, "glory", ehero_level )
  local sp_holy_rage = get_sp_bonus( spell, "holy_rage", ehero_level )
  local type_damage = Logic.obj_par( spell, "typedmg" )
  local sp_fire, sp_physical, sp_magic, sp_poison, sp_astral, sp_damage = 1, 1, 1, 1, 1

  if type_damage == nil
  or type_damage == "" then
    sp_fire = get_sp_bonus( spell, "fire", ehero_level )
    sp_physical = get_sp_bonus( spell, "physical", ehero_level )
    sp_magic = get_sp_bonus( spell, "magic", ehero_level )
    sp_poison = get_sp_bonus( spell, "poison", ehero_level )
    sp_astral = get_sp_bonus( spell, "astral", ehero_level )
    sp_damage = sp_fire * sp_physical * sp_magic * sp_poison * sp_astral
  else
    sp_damage = get_sp_bonus( spell, "typedmg", ehero_level )
  end

  local int_power = 1 + ( HInt() * int_pwr( 1, ehero_level ) * get_sp_bonus( spell, "int_pwr", ehero_level ) ) / 100
  local sp_necromancy = get_sp_bonus( spell, "necromancy", ehero_level )
  local spell_bonus = sp_hero * sp_destroyer * sp_attack * sp_defense * sp_healer * sp_holy * sp_glory * sp_holy_rage * sp_damage * int_power * sp_necromancy

  if text ~= nil then
    if sp_hero > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_hero_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_hero - 1 ) * 100 ) ) )
    end
    if sp_destroyer > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_destroyer_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_destroyer - 1 ) * 100 ) ) )
    end
    if sp_attack > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_attack_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_attack - 1 ) * 100 ) ) )
    end
    if sp_defense > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_defense_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_defense - 1 ) * 100 ) ) )
    end
    if sp_healer > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_healer_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_healer - 1 ) * 100 ) ) )
    end
    if sp_holy > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_holy_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_holy - 1 ) * 100 ) ) )
    end
    if sp_glory > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_glory_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_glory - 1 ) * 100 ) ) )
    end
    if sp_holy_rage > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_holy_rage_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_holy_rage - 1 ) * 100 ) ) )
    end
    if sp_fire > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_fire_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_fire - 1 ) * 100 ) ) )
    end
    if sp_physical > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_physical_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_physical - 1 ) * 100 ) ) )
    end
    if sp_magic > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_magic_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_magic - 1 ) * 100 ) ) )
    end
    if sp_poison > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_poison_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_poison - 1 ) * 100 ) ) )
    end
    if sp_astral > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_astral_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_astral - 1 ) * 100 ) ) )
    end
    if int_power > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_int_power_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( int_power - 1 ) * 100 ) ) )
    end
    if sp_necromancy > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_necromancy_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_necromancy - 1 ) * 100 ) ) )
    end
    if spell_bonus > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_total_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( spell_bonus - 1 ) * 100 ) ) )
    end
  end

  return spell_bonus, bonus_string
end


-- New common function for applying spell power bonuses
function get_power_bonus( spell, parameter, level, ehero_level )
 	local power = tonumber( text_dec( Logic.obj_par( spell, parameter ), level ) )
  power = get_add_bonus( spell, power, "sp_add_power_", nil, ehero_level )
  power = get_gain_bonus( spell, power, "sp_gain_power_", nil, ehero_level )
  local spell_bonus = get_spell_bonus( spell, nil, ehero_level )
  power = power * spell_bonus

  return power
end


-- New common function for getting level
function get_level( level )
  if tonumber( level ) == 0 or level == nil then
    level = Obj.spell_level()

    if level == 0 then level = 1 end

    if Obj.where() == 6 and Obj.spell_level() ~= 0 then level = level + 1 end
  else
    level = tonumber( level )
  end

  return level
end


-- New common function for additive bonus
function get_add_bonus( spell, value, kind, text, ehero_level )
  local bonus = tonumber( Logic.hero_lu_item( string.gsub( spell, "spell_", kind ), "count" ) )
  value = value + bonus

  local bonus_string = ""
  if text ~= nil then
    if bonus > 0 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_" .. kind .. "bonus> " .. gen_dmg_common_hint( "plus_power", tostring( round( bonus ) ) )
    end
  end

  return value, bonus_string
end


-- New common function for multiplicative bonus
function get_gain_bonus( spell, value, kind, text, ehero_level )
  local bonus = tonumber( Logic.hero_lu_item( string.gsub( spell, "spell_", kind ), "count" ) )
  value = value * ( 1 + bonus / 100 )

  local bonus_string = ""
  if text ~= nil then
    if bonus > 0 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_" .. kind .. "bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( bonus ) ) )
    end
  end

  return value, bonus_string
end


-- New common function for combined add / gain bonus
function get_add_gain_bonus( value, kind, bonus )
  local add_bonus = tonumber( Logic.hero_lu_item( "sp_add_" .. kind, "count" ) )
  local gain_bonus = tonumber( Logic.hero_lu_item( "sp_gain_" .. kind, "count" ) )
  if bonus == false then
    value = ( value - add_bonus ) * ( 1 - gain_bonus / 100 )
  else
    value = ( value + add_bonus ) * ( 1 + gain_bonus / 100 )
  end

  return value
end


-- New common function for computing min/max damage
function get_min_max_damage( spell, level, par, ehero_level, prc )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local min_dmg, max_dmg, duration, bonus_type, sp_bonus_type

  if par ~= nil and string.find( par, "periphery" ) then
    min_dmg, max_dmg = text_range_dec( Logic.obj_par( spell, "periphery_damage" ) )
    bonus_type = "sp_add_periphery_damage_"
    sp_bonus_type = "sp_gain_periphery_damage_"
  else
    if par ~= nil and string.find( par, "rephits" ) then
      min_dmg, max_dmg = text_range_dec( Logic.obj_par( spell, "rephits" ) )
      if prc then
        local prc_damage = Logic.obj_par( spell, "prc_damage" )
        if prc_damage ~= nil
        and prc_damage ~= "" then
          min_dmg = min_dmg * tonumber( prc_damage ) / 100
          max_dmg = max_dmg * tonumber( prc_damage ) / 100
        end
      end
    else
      min_dmg, max_dmg = text_range_dec( Logic.obj_par( spell, "damage") )
    end
    bonus_type = "sp_add_power_"
    sp_bonus_type = "sp_gain_power_"
  end

  min_dmg = get_add_bonus( spell, min_dmg, bonus_type )
  max_dmg = get_add_bonus( spell, max_dmg, bonus_type )
  duration = int_dur( spell, level, string.gsub( spell, "spell_", "sp_duration_" ) )
  local base_lvl_inc = tonumber( Logic.obj_par( spell, "lvl_inc" ) )
  base_lvl_inc = get_add_bonus( spell, base_lvl_inc, "sp_lvl_inc_" )
  local lvl_inc = 1 + ( level - 1 ) * base_lvl_inc / 100
  lvl_inc = get_gain_bonus( spell, lvl_inc, sp_bonus_type )
  local total_bonus = get_spell_bonus( spell, nil, ehero_level ) * lvl_inc
  min_dmg = round( min_dmg * total_bonus / 5 ) * 5
  max_dmg = round( max_dmg * total_bonus / 5 ) * 5

  return min_dmg, max_dmg, level, duration
end


-- New common function for computing the percent of an infliction
function get_infliction( spell, level, kind, ehero_level, text )
  local infliction = tonum( Logic.obj_par( spell, kind ) )
  local base_infliction = infliction * level
  local bonus_string = ""
  local sp_add_infliction = tonum( Logic.hero_lu_item( "sp_add_infliction_" .. kind, "count" ) )
  infliction = infliction + sp_add_infliction
  local sp_gain_infliction = 1 + tonum( Logic.hero_lu_item( "sp_gain_infliction_" .. kind, "count" ) ) / 100
  infliction = infliction * sp_gain_infliction
  local sp_attack_infliction = get_sp_bonus( spell, "attack", ehero_level )
  local sp_destroyer_infliction = get_sp_bonus( spell, "destroyer", ehero_level )
  local sp_int_infliction = 1 + HInt() / 100
  infliction = infliction * level * sp_int_infliction * sp_attack_infliction * sp_destroyer_infliction
  infliction = round( infliction )

  if text ~= nil then
    if infliction > base_infliction then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_base_infliction_" .. kind .. "> " .. gen_dmg_common_hint( kind, tostring( base_infliction ) )
    end

    if sp_int_infliction > 0 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_int_infliction_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_int_infliction - 1 ) * 100 ) ) )
    end

    if sp_add_infliction > 0 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_add_infliction_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( sp_add_infliction ) )
    end

    if sp_gain_infliction > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_gain_infliction_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_gain_infliction - 1 ) * 100 ) ) )
    end

    if sp_attack_infliction > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_attack_infliction_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_attack_infliction - 1 ) * 100 ) ) )
    end

    if sp_destroyer_infliction > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_destroyer_infliction_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_destroyer_infliction - 1 ) * 100 ) ) )
    end
  end

  infliction = limit_value( infliction, 0, 100 )

  if bonus_string == nil then
    bonus_string = ""
  end

  return infliction, bonus_string
end


-- New common function for computing duration increase as a function of intelligence
function int_dur( spell, level, bonus, text )
  local dur
  local bonus_string = ""
  local duration_string = Logic.obj_par( spell, "duration" )

  if string.find( duration_string, "," ) then
    dur = tonumber( "0" .. text_dec( Logic.obj_par( spell, "duration" ), level ) )
  else
    dur = tonumber( "0" .. text_dec( Logic.obj_par( spell, "duration" ), 1 ) )
  end

  local base_duration = dur

  if dur ~= 0 then
    local num = HInt()
    local dur_bonus = 0

    if bonus ~= nil
    and bonus ~= "" then
      dur_bonus = Logic.hero_lu_item( bonus, "count" )
    end

    dur = dur + dur_bonus

    local dur_int_bonus = 0
    if Logic.obj_par( spell, "int" ) == "1" then
      local mod = math.max( 1, tonumber( Game.Config( "spell_power_config/int_duration" ) ) - tonumber( Logic.hero_lu_item( "sp_dur_mod", "count" ) ) )
      local dur_inc = tonumber( Game.Config( "spell_power_config/dur_inc" ) )
      dur_int_bonus = math.floor( num / mod ) * dur_inc
      dur = dur + dur_int_bonus
    end

    local healer = tonumber( Logic.obj_par( spell, "healer" ) )
    local sp_healer = 0
    if healer == 1 then
      sp_healer = math.max( 0, tonumber( Logic.hero_lu_skill( "healer" ) ) - 2 )  -- +1 duration at level 3
    end

    local necromancy = tonumber( Logic.obj_par( spell, "necromancy" ) )
    local sp_necromancy = 0
    if necromancy == 1 then
	    	sp_necromancy = math.max( 0, tonumber( Logic.hero_lu_skill( "necromancy" ) ) - 2 )  -- +1 duration at level 3
    end

    dur = dur + sp_healer + sp_necromancy

    if text ~= nil then
      if dur > base_duration then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_base_duration> " .. gen_dmg_common_hint( "value", tostring( base_duration ) )
      end
      if dur_bonus > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_dur_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( dur_bonus ) )
      end
      if dur_int_bonus > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_dur_int_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( dur_int_bonus ) )
      end
      if sp_healer > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_dur_healer_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( sp_healer ) )
        if spell == "spell_bless" then
          bonus_string = bonus_string .. "<br>" .. "<label=spell_dmg_healer_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( sp_healer ) )
        end
      end
      if sp_necromancy > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_dur_necromancy_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( sp_necromancy ) )
        if spell == "spell_weakness" then
          bonus_string = bonus_string .. "<br>" .. "<label=spell_dmg_necromancy_bonus> " .. gen_dmg_common_hint( "minus_power", tostring( sp_necromancy ) )
        end
      end
    end
  end

  return dur, bonus_string
end


-- New common function for computing duration as a function of target's resistance
function res_dur( target, spell, duration, res_type )
  local res_spell = Logic.obj_par( spell, "dur_res_" .. res_type )
  local new_duration = duration

  if res_spell == "1" then
    local resist = Attack.act_get_res( target, res_type )
    local spell_type = Logic.obj_par( spell, "type" )

    if spell_type == "bonus" then
      new_duration = math.max( math.ceil( duration * ( 1 + resist / 100 ) ), 1 )

      if new_duration > duration then
        Attack.log( "add_blog_resdur_bon_inc", "target", blog_side_unit( target, 0 ), "restype", string.upper( string.sub( res_type, 1, 1 ) ) .. string.sub( res_type, 2 ), "durold", tostring( duration ), "durnew", tostring( new_duration ) )
      elseif new_duration < duration then
        Attack.log( "add_blog_resdur_bon_dec", "target", blog_side_unit( target, 0 ), "restype", string.upper( string.sub( res_type, 1, 1 ) ) .. string.sub( res_type, 2 ), "durold", tostring( duration ), "durnew", tostring( new_duration ) )
      end
    else
      new_duration = math.max( math.ceil( duration * ( 1 - resist / 100 ) ), 1 )

      if new_duration > duration then
        Attack.log( "add_blog_resdur_pen_inc", "target", blog_side_unit( target, 0 ), "restype", string.upper( string.sub( res_type, 1, 1 ) ) .. string.sub( res_type, 2 ), "durold", tostring( duration ), "durnew", tostring( new_duration ) )
      elseif new_duration < duration then
        Attack.log( "add_blog_resdur_pen_dec", "target", blog_side_unit( target, 0 ), "restype", string.upper( string.sub( res_type, 1, 1 ) ) .. string.sub( res_type, 2 ), "durold", tostring( duration ), "durnew", tostring( new_duration ) )
      end
    end
  end

  return new_duration
end


function get_count_bonus( spell_name, text )
		local count_bonus, holy_rage_bonus = 0, 0
  local sp_holy_rage = tonum( Logic.obj_par( spell_name, "holy_rage" ) )

  if sp_holy_rage == 1 then
    holy_rage_bonus = round( skill_power2( "holy_rage", 3 ) )
  end

  local bonus_string = ""

  if spell_name == "spell_dragon_arrow" then
    count_bonus = math.floor( HInt() / tonumber( Game.Config( "spell_power_config/int_duration" ) ) )
  end

  if text ~= nil then
    if count_bonus > 0 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_count_bonus> " .. gen_dmg_common_hint( "plus_power", tostring( count_bonus ) )
    end
    if holy_rage_bonus > 1 then
      bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_holy_rage_add_bonus> " .. gen_dmg_common_hint( "plus_power_percent", tostring( holy_rage_bonus ) )
    end
  end

  return count_bonus, bonus_string, holy_rage_bonus
end


-- **********************************************************************************
-- * Multi function calculation taking into account the level of damage and intellect
-- **********************************************************************************

function pwr_dragon_arrow( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

		local int_bonus, dummy, holy_rage_bonus = get_count_bonus( "spell_dragon_arrow" )
		local count = round( ( tonumber( "0" .. text_dec( Logic.obj_par( "spell_dragon_arrow", "count" ), level ) ) + int_bonus ) * ( 1 + holy_rage_bonus / 100 ) )

  return count
end

function pwr_necromancy( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = math.ceil( get_power_bonus( "spell_necromancy", "power", level, ehero_level ) )

  return power
end

function pwr_trap( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_trap", level, nil, ehero_level )
  local poison = get_infliction( "spell_trap", level, "poison", ehero_level )

  return min_dmg, max_dmg, duration, poison
end


function pwr_kamikaze( level, ehero_level )
  local min_dmg, max_dmg, level = get_min_max_damage( "spell_kamikaze", level, nil, ehero_level )
		local dur = tonumber( "0" .. text_dec( Logic.obj_par( "spell_kamikaze", "time" ), level ) )

  return min_dmg, max_dmg, dur
end

function pwr_ram( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local level = tonumber("0" .. text_dec(Logic.obj_par("spell_ram","level"),level))

  return level
end

function pwr_demonologist( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = get_power_bonus( "spell_demonologist", "power", level, ehero_level )
  local time = tonumber( "0" .. text_dec( Logic.obj_par( "spell_demonologist", "time" ), level ) )
  local lvl = text_dec( Logic.obj_par( "spell_demonologist", "level" ), level )
  local heroLeadership

  if ehero_level ~= nil then
    local max_enemy_leadership = 0
    for a = 1, Attack.act_count() - 1 do
      if Attack.act_enemy( a )
      and not Attack.act_pawn( a )
      and not Attack.act_feature( a, "pawn" )
      and not Attack.act_feature( a, "boss" ) then
        local unit_initleadership = Attack.act_leadership( a ) * Attack.act_initsize( a )
        if unit_initleadership > max_enemy_leadership then
          max_enemy_leadership = unit_initleadership
        end
      end
    end
    heroLeadership = max_enemy_leadership
  else
    heroLeadership = tonumber( Logic.hero_lu_item( "leadership", "count" ) )
  end

  local lead = round( heroLeadership * power / 100 )

  return lead, time, lvl, power
end

function pwr_evilbook( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

 	local level = tonumber( "0" .. text_dec(Logic.obj_par( "spell_evilbook", "level" ), level ) )
  local kill = tonumber( "0" .. text_dec(Logic.obj_par( "spell_evilbook", "kill" ), level ) )

  return level,kill
end

function pwr_plague( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_plague", "power", level, ehero_level ) )
  power = limit_value( power, 0, 80 )

  return power
end

function pwr_berserker( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_berserker", "power", level, ehero_level ) )
  local level = tonumber( "0" .. text_dec( Logic.obj_par( "spell_berserker", "level" ), level ) )

  return level, power

end

function pwr_pain_mirror( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_pain_mirror", "power", level, ehero_level ) )

  return power
end

function pwr_phantom( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_phantom", "power", level, ehero_level ) )

  return power
end

function pwr_fire_breath( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_fire_breath", "power", level, ehero_level ) )

		return power
end

function pwr_stone_skin( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local penalty = tonumber("0" .. text_dec(Logic.obj_par("spell_stone_skin","penalty"),level))-Logic.hero_lu_item("sp_add_penalty_stone_skin","count")
  local power = round( get_power_bonus( "spell_stone_skin", "power", level, ehero_level ) )
  power = limit_value( power, 0, 80 )

  return power, penalty

end

function pwr_magic_source( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local penalty = round( get_power_bonus( "spell_magic_source", "power", level, ehero_level ) )
  local mana = round( get_power_bonus( "spell_magic_source", "mana", level, ehero_level ) )

  if mana_rage_gain_k == nil then
    mana_rage_gain_k = 1
  end

  mana = math.ceil( mana * mana_rage_gain_k )

  return penalty, mana
end


function pwr_dragon_slayer( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_dragon_slayer", "power", level, ehero_level ) )

  return power
end

function pwr_demon_slayer( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_demon_slayer", "power", level, ehero_level ) )

  return power
end

function pwr_shroud( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local penalty = round( get_power_bonus( "spell_shroud", "power", level, ehero_level ) )
  penalty = limit_value( penalty, 0, 80 )

  return penalty
end

function pwr_ghost_sword( level, ehero_level ) -- clings lowering rezistens spell and causes damage. Spell then removes it.
  local min_dmg, max_dmg, level = get_min_max_damage( "spell_ghost_sword", level, nil, ehero_level )
  local power = tonumber("0" .. text_dec(Logic.obj_par("spell_ghost_sword","power"),level))

  return min_dmg, max_dmg, power
end

function pwr_warcry( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_reaction", "bonus", level, ehero_level ) )

  return power
end

function pwr_hypnosis( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local lvl = tonumber( "0" .. text_dec( Logic.obj_par( "spell_hypnosis", "level" ), level ) )
  local power = get_power_bonus( "spell_hypnosis", "power", level, ehero_level )
  local heroLeadership = tonumber( Logic.hero_lu_item( "leadership", "count" ) )
  local lead = round( heroLeadership * power / 100 )

  return lvl, lead, power
end

function pwr_blind( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = tonumber( "0" .. text_dec( Logic.obj_par( "spell_blind", "level" ), level ) )

  return power
end

function pwr_crue_fate( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = tonumber( "0" .. text_dec( Logic.obj_par( "spell_crue_fate", "level" ), level ) )

  return power
end

function pwr_magic_bondage( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = tonumber( "0" .. text_dec( Logic.obj_par( "spell_magic_bondage", "level" ), level ) )

  return power
end

function pwr_pygmy( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_pygmy", "power", level, ehero_level ) )
  power = limit_value( power, 0, 80 )

  return power
end

function pwr_accuracy( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_accuracy", "power", level, ehero_level ) )

  return power
end

function pwr_slow( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_slow", "penalty", level, ehero_level ) )
  power = power + hero_item_count2( "sp_spell_speed", "count" )
  local krit = round( get_power_bonus( "spell_slow", "krit", level, ehero_level ) )

  return power, krit
end

function pwr_haste( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_haste", "bonus", level, ehero_level ) )
  power = power + hero_item_count2( "sp_spell_speed", "count" )
  local krit = round( get_power_bonus( "spell_haste", "krit", level, ehero_level ) )

  return power, krit
end

function pwr_divine_armor( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local power = round( get_power_bonus( "spell_divine_armor", "power", level, ehero_level ) )
  power = limit_value( power, 0, 80 )

  return power
end

function pwr_defenseless( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local def = round( get_power_bonus( "spell_defenseless", "power", level, ehero_level ) )
  def = limit_value( def, 0, 80 )

  return def
end

function pwr_adrenalin( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local bonus = round( get_power_bonus( "spell_adrenalin", "bonus", level, ehero_level ) )

  return bonus
end

function pwr_pacifism( level, ehero_level )
  level = get_level( level )

  if ehero_level ~= nil then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local bonus = round( get_power_bonus( "spell_pacifism", "power", level, ehero_level ) )
  local penalty = round( get_power_bonus( "spell_pacifism", "penalty", level, ehero_level ) )
  penalty = limit_value( penalty, 0, 80 )

  return bonus, penalty
end

function pwr_resurrection( level, ehero_level )
  local ref, dummy, level = get_min_max_damage( "spell_resurrection", level, "rephits", ehero_level )

  return ref
end

function pwr_healing( level, ehero_level, prc )
  local min_dmg, max_dmg, level = get_min_max_damage( "spell_healing", level, "rephits", ehero_level, prc )

  return min_dmg, max_dmg
end

function pwr_oil_fog( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_oil_fog", level, nil, ehero_level )
  local power = round( get_power_bonus( "spell_oil_fog", "power", level, ehero_level ) )
  power = limit_value( power, 0, 100 )

  return min_dmg, max_dmg, duration, power
end

function pwr_fire_ball( par, level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_fire_ball", level, par, ehero_level )
  local burn = get_infliction( "spell_fire_ball", level, "burn", ehero_level )

  return min_dmg, max_dmg, burn, duration
end

function pwr_ice_serpent( par, level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_ice_serpent", level, par, ehero_level )
  local freeze = get_infliction( "spell_ice_serpent", level, "freeze", ehero_level )

  return min_dmg, max_dmg, freeze, duration
end

function pwr_sacrifice( level, ehero_level )
  local damage, dummy, level = get_min_max_damage( "spell_sacrifice", level, nil, ehero_level )
  local power = round( get_power_bonus( "spell_sacrifice", "power", level, ehero_level ) )

  return damage, power
end

function pwr_fire_rain( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_fire_rain", level, nil, ehero_level )
  local burn = get_infliction( "spell_fire_rain", level, "burn", ehero_level )

  return min_dmg, max_dmg, burn, duration
end

function pwr_lightning( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_lightning", level, nil, ehero_level )
  local shock = get_infliction( "spell_lightning", level, "shock", ehero_level )
  local count = tonumber( text_dec(Logic.obj_par( "spell_lightning", "count" ), level ) )

  return min_dmg, max_dmg, shock, count, duration
end

function pwr_fire_arrow( level, ehero_level ) -- returns the result as a minimum
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_fire_arrow", level, nil, ehero_level )
  local burn = get_infliction( "spell_fire_arrow", level, "burn", ehero_level )

  return min_dmg, max_dmg, burn, duration
end

function pwr_smile_skull( level, ehero_level ) -- returns the result as a minimum
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_smile_skull", level, nil, ehero_level )
  local poison = get_infliction( "spell_smile_skull", level, "poison", ehero_level )

  return min_dmg, max_dmg, poison, duration
end

function pwr_magic_axe( level, ehero_level )
  local min_dmg, max_dmg, count = get_min_max_damage( "spell_magic_axe", level, nil, ehero_level )

  return min_dmg, max_dmg, count
end

function pwr_geyser( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_geyser", level, nil, ehero_level )
  local freeze = get_infliction( "spell_geyser", level, "freeze", ehero_level )
  local stun = get_infliction( "spell_geyser", level, "stun", ehero_level )
  local count = tonumber( text_dec( Logic.obj_par( "spell_geyser", "count" ), level ) )

  return min_dmg, max_dmg, count, freeze, stun, duration
end

function pwr_armageddon( level, ehero_level )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_armageddon", level, nil, ehero_level )
  local prc = 100 - get_power_bonus( "spell_armageddon", "prc_damage", level, ehero_level )
  local add_prc = Logic.hero_lu_item( "sp_add_penalty_armageddon", "count" )
  prc = prc - add_prc
  local sp_prc = 1 - Logic.hero_lu_item( "sp_gain_prc_armageddon", "count" ) / 100
  prc = math.ceil( prc * sp_prc )
  prc = limit_value( prc, 0, 95 )

  local burn = get_infliction( "spell_armageddon", level, "burn", ehero_level )

  return min_dmg, max_dmg, burn, duration, prc
end

function pwr_holy_rain( level, prc )
  local min_dmg, max_dmg, level, duration = get_min_max_damage( "spell_holy_rain", level, "rephits", nil, prc )
  local holy = get_infliction( "spell_holy_rain", level, "holy" )

  return min_dmg, max_dmg, holy, duration
end
