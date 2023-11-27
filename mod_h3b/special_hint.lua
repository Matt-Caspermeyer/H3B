function gen_special_hint( unit, par )
  local text = ""
  local apars = Logic.attack_params()

  local function apply_bonus( value, max )
    value = tonumber( value )

    if Game.LocIsArena() then
      local diff_k = Attack.val_restore( unit, "diff_k" )
      local sign_diff_k = Attack.val_restore( unit, "sign_diff_k" )
      local min_stat_inc = Attack.val_restore( unit, "min_stat_inc" )
      local value_inc = 0
      
      if diff_k ~= nil
      and sign_diff_k ~= nil
      and min_stat_inc ~= nil then
        value_inc = math.max( round( math.abs( value * diff_k ) ), min_stat_inc ) * sign_diff_k
      end
  
      if max ~= nil then
        return tostring( math.min( max, value + value_inc ) )
      else
        return tostring( value + value_inc )
      end
    else
      return tostring( value )
    end
  end

  local function difficulty_level_damage( damage )
    local dmg_min, dmg_max = text_range_dec( string.gsub( damage, ",", "-" ) )
    dmg_min = apply_bonus( dmg_min )
    dmg_max = apply_bonus( dmg_max )

    return ( dmg_min .. ',' .. dmg_max )
  end
      
  if par == "fdamage" then
    local damage = difficulty_level_damage( apars.damage.fire )
    text = string.gsub( damage, ",", "-" )
  end 

  if par == "pdamage" then
    local damage = difficulty_level_damage( apars.damage.poison )
    text = string.gsub( damage, ",", "-" )
  end 

  if par == "adamage" then
    local damage = difficulty_level_damage( apars.damage.astral )
    text = string.gsub( damage, ",", "-" )
  end 

  if par == "damage" then
    local damage = difficulty_level_damage( apars.damage.physical )

    if apars.name == "gcry"
    and ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 ) then
      local dmg_min, dmg_max = text_range_dec( string.gsub( damage, ",", "-" ) )
      dmg_min = round( dmg_min * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 ) )
      dmg_max = round( dmg_max * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 ) )
      damage = tostring( dmg_min ) .. "," .. tostring( dmg_max )
    end

    text = string.gsub( damage, ",", "-" )
  end 

  if par == "mdamage" then
    local damage = difficulty_level_damage( apars.damage.magic )
    text = string.gsub( damage, ",", "-" )
  end 

  if par == "sdamage" then
    local damage = difficulty_level_damage( apars.custom_params.damage )
    text = string.gsub( damage, ",", "-" )
  end 

  if par == "ap" then
    local ap = apars.custom_params.ap
    text = apply_bonus( ap )
  end   

  if par == "cure" then
    local unit_count = AU.unitcount( unit )
    local cure = common_apply_skill_bonus( get_add_gain_bonus( tonumber( apars.custom_params.heal ), apars.script_attack ), "healer" )
    text = tostring( round( unit_count * apply_bonus( cure ) ) )
  end 

  if par == "cure2" then
    local unit_count = AU.unitcount( unit )
    local cure = common_apply_skill_bonus( get_add_gain_bonus( tonumber( apars.custom_params.heal ) * 2, apars.script_attack ), "healer" )
    text = tostring( round( unit_count * apply_bonus( cure ) ) )
  end 

  if par == "duration" then
    local attack_class = apars.class

    if attack_class == "spell"
    or ( attack_class == "spell"
    and string.find( apars.spell, "special" ) ) then 
      local spell = apars.spell
      text = apply_bonus( Logic.obj_par( spell, "duration" ) )
    else
      local duration_bonus = 0

      if apars.custom_params.rage ~= nil
      and apars.custom_params.rage ~= 0 then
        duration_bonus = tonumber( Logic.hero_lu_item( "sp_duration_special_holy_rage", "count" ) )
      else
        duration_bonus = tonumber( Logic.hero_lu_item( "sp_duration_" .. apars.script_attack, "count" ) )
      end

      text = tostring( tonumber( apply_bonus( apars.custom_params.duration ) ) + duration_bonus )
    end
  end 

  if par == "burn"
  or par == "poison"
  or par == "res"
  or par == "shock" then
    local attack_class = apars.class

    if attack_class == "spell" then 
      local spell = apars.spell
      text = apply_bonus( Logic.obj_par( spell, par ) ) .. "%"
    else
      if par == "burn" then
        text = tostring( round( get_add_gain_bonus( apply_bonus( apars.custom_params.burn ), par .. "_" .. apars.name ) ) ) .. "%"
      elseif par == "poison" then
        text = tostring( round( get_add_gain_bonus( apply_bonus( apars.custom_params.poison ), par .. "_" .. apars.name ) ) ) .. "%"
      elseif par == "res" then
        text = tostring( round( get_add_gain_bonus( apply_bonus( apars.custom_params.res ), par .. "_" .. apars.name ) ) ) .. "%"
      elseif par == "shock" then
        text = tostring( round( get_add_gain_bonus( apply_bonus( apars.custom_params.shock ), par .. "_" .. apars.name ) ) ) .. "%"
      end
    end
  end 

  if string.find( par, "health" ) then
    text = apply_bonus( apars.custom_params.health )

    if par == "health%" then text = text .. "%" end 

    if par == "health_count" then 
    	 text = tonumber( text ) * Attack.act_size( 0 ) .. "" 
    end 

    if par == "health_totem" then 
      local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )
      local total_hp = tonumber( text ) / 100 * Attack.act_totalhp( 0 )
    	 text = tostring( math.ceil( total_hp + titan_energy ) ) .. "" 
    end 
  end 

  if string.find( par, "penalty" )
  or string.find( par, "power" ) then
    local attack_class = apars.class

    if attack_class == "spell"
    or ( attack_class == "spell"
    and string.find( apars.spell, "special" ) ) then 
      local spell = apars.spell
      text = apply_bonus( Logic.obj_par( spell, string.gsub( par, "%%", "" ) ) )

      if string.find( par, "%%" ) then text = text .. "%" end 
    else
      if string.find( par, "power" ) then
        text = tostring( round( apply_bonus( get_add_gain_bonus( tonumber( apars.custom_params.power ), "power_" .. apars.script_attack ) ) ) )
      elseif string.find( par, "penalty" ) then
        text = tostring( round( apply_bonus( get_add_gain_bonus( tonumber( apars.custom_params.penalty ), "penalty_" .. apars.script_attack, false ) ) ) )
      end

      if string.find( par, "%%" ) then text = text .. "%" end 
    end
  end 

  if par == "summon" then
    local count_min, count_max = text_range_dec( apars.custom_params.count )
    local unit_count = AU.unitcount( unit )
    text = apply_bonus( count_min ) * unit_count .. "-" .. apply_bonus( count_max ) * unit_count
  end 

  if par == "lsummon"
  or par == "nlsummon"
  or par == "nheal" then
    local count_min, count_max = text_range_dec( apars.custom_params.k )

    if par == "lsummon" then
      count_min = count_min * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
      count_max = count_max * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )

    elseif par == "nlsummon"
    or par == "nheal" then
      count_min = count_min * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 )
      count_max = count_max * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 )

      if par == "nheal"
      and ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 ) then
        local min_pct, max_pct = skill_power_range_dec( "necromancy", 1 )
        count_min = count_min * min_pct / 100
        count_max = count_max * max_pct / 100
      end
    end

    local unit_count = AU.unitcount( unit )
    local unit_lead = AU.abslead( unit )

    if count_min ~= count_max then 
      text = math.floor( apply_bonus( count_min, 100 ) * unit_count * unit_lead / 100 ) .. "-" .. math.floor( apply_bonus( count_max, 100 ) * unit_count * unit_lead / 100 )
    else
      text = tostring( math.floor( apply_bonus( count_min, 100 ) * unit_count * unit_lead / 100 ) )
    end 
  end 

  if par == "necromancy_hint"
  and ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 ) then
    text = "<br><label=special_necromancy_skill_hint>"
  end

  if par == "level" then
    local attack_class = apars.class

    if attack_class == "spell"
    or ( attack_class == "spell"
    and string.find( apars.spell, "special" ) ) then 
      local spell = apars.spell
      text = "1-" .. Logic.obj_par( spell, "level" )
    else
      text = "1-" .. apars.custom_params.level
    end
  end 

  if par == "mana" then
    local count_min, count_max = text_range_dec( apars.custom_params.mana )
    local max_mana = tonumber( apars.custom_params.max )
    local unit_count = AU.unitcount( unit )
    count_min = count_min * unit_count
    count_max = count_max * unit_count
    
    if count_min > max_mana then count_min = max_mana end 
    if count_max > max_mana then count_max = max_mana end
    
    if count_min == count_max then 
      text = tostring( apply_bonus( count_min ) )
    else
      text = apply_bonus( count_min ) .. "-" .. apply_bonus( count_max )
    end 
  end 

  -- New Thorn Gift of Life Health
  if par == "thorn_gift" then
    local cure = apply_bonus( common_apply_skill_bonus( tonumber( apars.custom_params.heal ), "healer" ) )
    local bonus = tonumber( Logic.hero_lu_item( "sp_special_attacks_thorn_gift", "count" ) )
    text = "+" .. tostring( round( Attack.act_totalhp( 0 ) * ( cure + bonus ) / 100 ) )
  end

  -- New Horseman Charge
  if par == "horseman_charge" then
    local damage = tonumber( apply_bonus( apars.custom_params.rush_dmg_inc ) )
    local bonus = tonumber( Logic.hero_lu_item( "sp_special_attacks_horseman_charge", "count" ) )
    text = "+" .. tostring( damage + bonus ) .. "%"
  end

  -- New Tap Tree of Life - resistances
  if par == "ent_rooted_resist" then
    local resist = apply_bonus( tonumber( apply_bonus( apars.custom_params.resist ) ) )
    local bonus = tonumber( Logic.hero_lu_item( "sp_special_gain_ent_rooted_resist", "count" ) )
    text = "+" .. tostring( resist + bonus ) .. "%"
  end

  -- New Tap Tree of Life - health
  if par == "ent_rooted_hp" then
    local hp = apply_bonus( tonumber( apply_bonus( apars.custom_params.HP ) ) )
    local bonus = tonumber( Logic.hero_lu_item( "sp_special_gain_ent_rooted_HP", "count" ) )
    text = "+" .. tostring( hp + bonus ) .. "%"
  end

  -- New hint for Inquisitor's Holy Rage
  if par == "holy_rage" then
    local rage_min, rage_max = text_range_dec( apars.custom_params.rage )
    rage_min = get_add_gain_bonus( rage_min, "special_holy_rage" )
    rage_max = get_add_gain_bonus( rage_max, "special_holy_rage" )
    local skill_bonus = 1 + skill_power2( "rage", 1 ) / 100

    if mana_rage_gain_k == nil then
      mana_rage_gain_k = 1
    end

    rage_min = math.ceil( rage_min * skill_bonus * mana_rage_gain_k )
    rage_max = math.ceil( rage_max * skill_bonus * mana_rage_gain_k )
    local rage = tostring( apply_bonus( rage_min ) ) .. "-" .. tostring( apply_bonus( rage_max ) )

    if rage_min == 0
    and rage_max == 0 then
      text = "<color=255,66,0>" .. "NO RAGE GAIN!" .. "</color>"
    else
      text = rage
    end
  end

  -- New hint for Evil Book's Gulp
  if par == "gulp" then
    local level = Attack.act_level( 0 )
    text = "+" .. tostring( level )
  end

  -- New for Shaman's Energy Dissipation
  if par == "dissipate" then
    local dissipate = tonumber( apply_bonus( apars.custom_params.dissipate ) ) * ( 2 - apply_bonus( 1 ) )
    text = tostring( dissipate ) .. "%"
  end

  -- New hint for Phoenix Sacrifice
  if par == "sacrifice" then
    text = tostring( Attack.act_hp( 0 ) )
  end

  -- New hint for difficulty level
  if par == "difficulty_level" then
    local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/eunit' ), Game.HSP_difficulty() + 1, '|' ) ) * 100
    local maplocden = tonumber( text_dec( Game.Config( 'difficulty_k/maplocden' ), Game.HSP_difficulty() + 1, '|' ) )
    local maplocdiff = Game.MapLocDifficulty() + 1
    diff_k = diff_k + round( maplocdiff / maplocden )
    local color

    if diff_k < 100 then
      color = "<color=232,78,5>"
    else
      color = "<color=60,232,25>"
    end

    text = color .. tostring( diff_k ) .. "%"
  end

  -- New Titan Energy
  if string.find( par, "titan_energy" ) then
    local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )

    if titan_energy > 2 then
      text = " <color=0,245,255>" .. "+" .. tostring( titan_energy ) .. "</color> <label=special_titan_energy2>"
    elseif titan_energy > 1 then
      text = " <color=0,245,255>" .. "+" .. tostring( titan_energy ) .. "</color> <label=special_titan_energy1>"
    end
  end 

  -- New Titan Energy
  if string.find( par, "init_totem" ) then
    local health = apply_bonus( apars.custom_params.health )
    local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )
    local total_hp = tonumber( health ) / 100 * Attack.act_totalhp( 0 )
    local hp = math.ceil( total_hp + titan_energy )
    local init, init_base = Attack.act_get_par( 0, "initiative" )
    local init_den = apars.custom_params.init_den
    local totem_init = init_base + math.floor( hp / init_den )
    text = tostring( totem_init )
  end 

  return text
end

function gen_special_charge( unit, par )
  local text = ""
  --<hnt=moves> // special_charge
  --<hnt=reload> // special_reload
  local apars = Logic.attack_params()
  local moves = apars.moves
  local lmoves = apars.moves_left
  local lreload = apars.reload_left
  local reload = apars.reload
  
  if moves ~= nil
  and reload ~= nil then
    if par == "text" then
      text = "<br><label=special_charge> "
    else
      if Game.LocIsArena() then 
       	if lmoves == 0 then text = text .. "<label=skill_hintNoUp_font>" end

        text = text .. lmoves .. "/" .. moves .. "."

      	 if lreload == 0 then -- готово
         	text = text .. "<br><label=hint_Dis_font><label=special_reload> " .. reload - 1 .. "."
        else
         	text = text .. "<br><color=222,194,94><label=special_reload></color> <label=skill_hintNoUp_font>" .. ( lreload ) .. "."
        end 
      else 
        text = moves .. "."
        text = text .. "<br><color=222,194,94><label=special_reload></color> " .. reload - 1 .. "."
      end 
    end 
  elseif moves ~= nil then
    if par == "text" then
      text = "<br><label=special_charge> "
    else
      if Game.LocIsArena() then 
      	if lmoves == 0 then text = text .. "<label=skill_hintNoUp_font>" end
        text = text .. lmoves .. "/" .. moves .. "."
      else 
        text = moves .. "."
      end 
    end 
  elseif reload ~= nil then
    if par == "text" then
    	 if Game.LocIsArena()
      and lreload == 0 then
    	   text = text .. "<label=hint_Dis_font>"
     	end 

      text = text .. "<br><label=special_reload> "
    else
      if Game.LocIsArena() then 
      	 if lreload == 0 then -- готово
         	text = "<label=hint_Dis_font>" .. reload - 1 .. "."
        else
         	text = "<label=skill_hintNoUp_font>" .. ( lreload ) .. "."
        end 
      else 
        text = reload - 1 .. "."
      end 

    end
  end 

  return tostring(text)
end

function gen_special_name()

		local apars = Logic.attack_params()
		local sa_name=""
			sa_name=apars.hinthead
		if sa_name~=nil then			
			sa_name=string.gsub(sa_name, "_head", "_name", 1)
		else 
		  sa_name=""
		end 
		--if string.find(spell_name,"spell") then
--			local spell_type=Logic.obj_par(spell_name,"type")
--			if spell_type=="penalty" then
--				name="<label=special_bad_font>"
--			end
--			if spell_type=="bonus" then
--				name="<label=special_good_font>"
--			end
		--else 
--		return name.."<label="..spell_name.."_name>"
	return "<label="..sa_name..">"
end

function gen_unit_par(unit,par)
	local hp=""
	local name=AU.name(unit)
	
	if par=="cur_health" then 
		hp = AU.hp(unit)
	end 
	if par=="health" then 
		hp = AU.health(unit)
	end 
	if par=="defense" then 
		hp = "???"--AU.defence(unit)
	end 
	if par=="attack" then 
		hp = "???"--AU.attack(unit)
	end 
	if par=="initiative" then 
		hp = "???"-- Attack.atom_getpar(name,"initiative")
	end 
	
	return tostring(hp)
end 
