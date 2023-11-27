-- New Function for computing bonuses to summoned creatures (Phoenix and Evil Book) loosely based
-- on NEW_SPELLS.LUA summon_master_effect from King's Bounty - Crossworlds: Orcs on the March
function summon_bonus( unit, spell, text, ehero_level )
  local intel
  local bonus_string = ""
  if unit ~= nil then
    intel = Attack.val_restore( unit, "intel" )
  
    if intel ~= nil then
      intel = tonumber( Attack.val_restore( unit, "intel" ) )
    else
      intel = HInt()
    end
  else
    intel = HInt()
  end

  local resistances = {}
  local str_resistances = Game.Config( 'resistances' )
  local number_resistances = text_par_count( str_resistances )
  
  if number_resistances > 1 then
    for j = 1, number_resistances do
      local sub_string = text_dec( str_resistances, j )
      table.insert( resistances, sub_string )
    end
  end

  local duration = -100  -- infinite duration
  local sp_hero = get_sp_bonus( spell, "hero", ehero_level )
  local sp_healer = get_sp_bonus( spell, "healer", ehero_level )
  local sp_destroyer = get_sp_bonus( spell, "destroyer", ehero_level )
  local sp_necromancy = get_sp_bonus( spell, "necromancy", ehero_level )
  local sp_power = get_sp_bonus( spell, "int_pwr", ehero_level )
  local sp_intel = ( 1 + intel / 100 ) * sp_power * int_pwr( 1, ehero_level )
  local hitpoint_bonus = ( sp_intel * sp_healer * sp_necromancy - 1 ) * 100
  local damage_bonus = ( sp_intel * sp_destroyer - 1 ) * 100
  local sp_defense = get_sp_bonus( spell, "defense", ehero_level )
  local defense_bonus = ( sp_intel * sp_healer * sp_defense - 1 ) * 100
  local sp_attack = get_sp_bonus( spell, "attack", ehero_level )
  local attack_bonus = ( sp_intel * sp_attack * sp_necromancy - 1 ) * 100
  local res_bonus = ( sp_intel * sp_healer * sp_necromancy - 1 ) * 100
  local start_defense_p = skill_power2( "start_defense", 1 )

  if unit ~= nil then
    Attack.act_apply_spell_begin( unit, "special_summon_bonus", duration, false )
    
    local damage_type = {}
    
    for i, v in ipairs( resistances ) do
      local min_damage_current = Attack.act_get_dmg_min( unit, v )
    
      if min_damage_current > 0 then
        table.insert( damage_type, v )
      end
    end
    
    for i, v in ipairs( damage_type ) do
      local sp_damage = get_sp_bonus( spell, v, ehero_level )
      Attack.act_apply_dmg_spell( v, 0, 0, damage_bonus * sp_damage, duration, false )
    end
  
    if unit ~= 0 then
      local current_hp = Attack.act_hp( unit )
      local new_hp = current_hp * ( hitpoint_bonus / 100 + 1 )
      local additional_hp = new_hp - current_hp
      Attack.act_attach_modificator( unit, "health", "summon_bonus_health", additional_hp, 0, 0, duration, false )
      Attack.act_hp( unit, new_hp )
      Attack.act_attach_modificator( unit, "defense", "summon_bonus_defense", 0, 0, defense_bonus, duration, false )
      Attack.act_attach_modificator( unit, "attack", "summon_bonus_attack", 0, 0, attack_bonus, duration, false )
  
      local function common_apply_res_bonus( unit, spell, res, res_bonus, duration )
        local spell_res = tonumber( Logic.obj_par( spell, "res_" .. res ) )

        if spell_res == 1 then
          local resist = Attack.act_get_res( unit, res )
          Attack.act_attach_modificator_res( unit, res, "summon_bonus_res_" .. res, 0, math.abs( resist * res_bonus / 100 ), 0, duration, false )
        end
      end

      for i, v in ipairs( resistances ) do
        common_apply_res_bonus( unit, spell, v, res_bonus, duration )
      end
  
    end

    local res_physical = tonumber( Logic.obj_par( spell, "res_physical" ) )

    if res_physical == 1
    and start_defense_p > 0 then
      local resist = Attack.act_get_res( unit, "physical" )
      Attack.act_attach_modificator_res( unit, "physical", "sc", start_defense_p, 0, 0, -100, false, 0, true )
    end

    Attack.act_apply_spell_end()
    
    return true
  else
    local sp_kid, sp_kid_speed, sp_kid_init, sp_kid_ur = 1, 0, 0, false
    local sp_skill_holy_rage, sp_skill_holy_rage_stat = 1, 0
    if spell == "spell_phoenix" then
      -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
      -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to 1
      local sp_kid_luna = Logic.hero_lu_item( "sp_kid_luna", "count" )

      if sp_kid_luna > 0 then
        sp_kid = 1 + sp_kid_luna * 0.20
        sp_kid_speed = sp_kid_luna
        sp_kid_init = sp_kid_luna
        sp_kid_ur = true
      end

      sp_skill_holy_rage = 1 + skill_power2( "holy_rage", 3 ) / 100
      sp_skill_holy_rage_stat = skill_power2( "holy_rage", 2 )
    elseif spell == "spell_evilbook" then
      -- Note that hero_lu_item_on_body does not work properly so sp_kid_... was added to
      -- SPECIAL_PARAMS.TXT as a work-around and the count for the child set to 1
      local sp_kid_aislinn = Logic.hero_lu_item( "sp_kid_aislinn", "count" )

      if sp_kid_aislinn > 0 then
        sp_kid = 1 + sp_kid_aislinn * 0.12
        sp_kid_speed = sp_kid_aislinn
        sp_kid_init = sp_kid_aislinn
        sp_kid_ur = true
      end
    end

    local damage_type = {}
  
    for i, v in ipairs( resistances ) do
      local bonus = Logic.obj_par( spell, v )
      
      if bonus ~= nil
      and bonus ~= ""
      and tonumber( bonus ) > 0 then
        table.insert( damage_type, v )
      end
    end

    local sp_astral, sp_fire, sp_magic, sp_physical, sp_poison = 1, 1, 1, 1, 1

    for i = 1, table.getn( damage_type ) do
      if damage_type[ i ] == "astral" then
        sp_astral = get_sp_bonus( spell, damage_type[ i ], ehero_level )
      elseif damage_type[ i ] == "fire" then
        sp_fire = get_sp_bonus( spell, damage_type[ i ], ehero_level )
      elseif damage_type[ i ] == "magic" then
        sp_magic = get_sp_bonus( spell, damage_type[ i ], ehero_level )
      elseif damage_type[ i ] == "physical" then
        sp_physical = get_sp_bonus( spell, damage_type[ i ], ehero_level )
      elseif damage_type[ i ] == "poison" then
        sp_poison = get_sp_bonus( spell, damage_type[ i ], ehero_level )
      end
    end

    damage_bonus = damage_bonus * sp_kid * sp_skill_holy_rage * sp_astral * sp_fire * sp_magic * sp_physical * sp_poison
    hitpoint_bonus = hitpoint_bonus * sp_kid * sp_skill_holy_rage
    defense_bonus = defense_bonus * sp_kid * sp_skill_holy_rage
    attack_bonus = attack_bonus * sp_kid * sp_skill_holy_rage

  		if text ~= nil then
      if sp_power > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_power_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_power - 1 ) * 100 ) ) )
      end
      if sp_hero > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_hero_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_hero - 1 ) * 100 ) ) )
      end
      if sp_intel > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_intel_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_intel - 1 ) * 100 ) ) )
      end
      if sp_destroyer > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_destroyer_skill_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_destroyer - 1 ) * 100 ) ) )
      end
      if sp_astral > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_astral_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_astral - 1 ) * 100 ) ) )
      end
      if sp_fire > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_fire_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_fire - 1 ) * 100 ) ) )
      end
      if sp_physical > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_physical_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_physical - 1 ) * 100 ) ) )
      end
      if sp_magic > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_magic_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_magic - 1 ) * 100 ) ) )
      end
      if sp_poison > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_poison_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_poison - 1 ) * 100 ) ) )
      end
      if sp_kid > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_base_damage_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_kid - 1 ) * 100 ) ) )
      end
      if start_defense_p > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_start_defense_p_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( start_defense_p ) ) )
      end
      if sp_kid > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_base_defense_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_kid - 1 ) * 100 ) ) )
      end
      if sp_healer > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_healer_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_healer - 1 ) * 100 ) ) )
      end
      if sp_necromancy > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_necromancy_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_necromancy - 1 ) * 100 ) ) )
      end
      if sp_skill_holy_rage > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_holy_rage_summon1> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_skill_holy_rage - 1 ) * 100 ) ) )
      end
      if sp_skill_holy_rage > 1 then
        bonus_string = bonus_string .. "<label=spell_sp_holy_rage_summon2> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( 2 * sp_skill_holy_rage - 2 ) * 100 ) ) )
      end
      if sp_skill_holy_rage_stat > 1 then
        bonus_string = bonus_string .. "<label=spell_sp_holy_rage_summon3> " .. gen_dmg_common_hint( "plus_power", tostring( round( sp_skill_holy_rage_stat ) ) )
      end
      if sp_kid > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_base_health_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_kid - 1 ) * 100 ) ) )
      end
      if sp_attack > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_attack_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_attack - 1 ) * 100 ) ) )
      end
      if sp_defense > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_sp_defense_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_defense - 1 ) * 100 ) ) )
      end
      if sp_kid > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_base_attack_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_kid - 1 ) * 100 ) ) )
      end
      if sp_kid > 1 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_krit_summon> " .. gen_dmg_common_hint( "plus_power_percent", tostring( round( ( sp_kid - 1 ) * 200 ) ) )
      end
      if sp_kid_speed > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_speed_summon> " .. gen_dmg_common_hint( "plus_power", tostring( round( sp_kid_speed ) ) )
      end
      if sp_kid_init > 0 then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_init_summon> " .. gen_dmg_common_hint( "plus_power", tostring( round( sp_kid_init ) ) )
      end
      if sp_kid_ur then
        bonus_string = bonus_string .. "<br>" .. "<label=spell_item_ur_summon>"
      end
    end

    return damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus, bonus_string
  end
end


--New! Common function for getting a spell's level
function common_get_spell_level( level )
  if level == nil then
    level = Obj.spell_level()
  else
    level = tonumber( level )
  end

  if level == 0 then level = 1 end

  return level
end

-- New! Common function for getting the belligerent and enemy hero level based on it
function common_get_belligerent( target, belligerent, ehero_level, level )
  if belligerent == nil then
    belligerent = Attack.act_belligerent( target )
  end

  if belligerent ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  return belligerent, ehero_level, level
end

-- ***********************************************
-- * Dragon Arrow
-- ***********************************************

function spell_dragon_arrow_attack( level, target, belligerent )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
    level = common_get_spell_level( level )
    local ehero_level

    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
		  Attack.act_enable_attack( target, "dragon" )
		  local count = pwr_dragon_arrow( level, ehero_level )
--		if level>1 then
			 Attack.act_charge( target, 0, "dragon" ) -- Set the initial number (1)
			 if count > 1 then -- when the count 1, it can be nothing more to do
  				Attack.act_charge( target, count-1, "dragon" )
		 	end
--		end
    Attack.atom_spawn(target, 0, "magic_dragon_slayer", Attack.angleto(target))
--        Attack.act_damage_addlog(target,"add_blog_fear_")
  end

  return true
end

--*************************************************************************
-- Necromancy
--*************************************************************************
function necro_get_unit( name, count, power )
	 local pas_unit = {}
  -- Note that this table is ordered in descending hitpoints so that the best choice is used if power is below count * hp
  local unit_array = { "bonedragon", "blackknight", "necromant", "vampire2", "bat2", "ghost2", "vampire", "bat", "ghost", "zombie2", "zombie", "spider_undead", "skeleton", "archer",  }
  local max_efficiency = 0
  local lookup_name = ',' .. name .. ','

 	-- iterates through the array and draw up a list of possible forms
	 for i, mas in ipairs( unit_array ) do
    local unit_list = Logic.obj_par( "spell_necromancy", mas )

		  if string.find( unit_list, lookup_name, 1, true ) then
      local undead_HP = Attack.atom_getpar( mas, "hitpoint" )
      local efficiency = undead_HP * count / power

      -- The idea here is to pick any units above spell power, but only pick the best unit when below
      if efficiency >= 1 then
        max_efficiency = efficiency
  			   table.insert( pas_unit, mas )
      else
        if efficiency > max_efficiency then
          max_efficiency = efficiency
  			     table.insert( pas_unit, mas )
        end
      end
		  end
	 end

  if table.getn( pas_unit ) == 0 then
    table.insert( pas_unit, unit_array[ Game.Random( 1, table.getn( unit_array ) ) ] )
  end

	 return pas_unit[ Game.Random( 1, table.getn( pas_unit ) ) ] --select the unit from the list of forms
end

function animate_dead( cell, target, dmgts, bel, unit_animate, count )
	 local ang_to_enemy = Game.Dir2Ang( Attack.act_dir( target ) )
  Attack.atom_spawn( cell, dmgts + 0.3, "effect_deadarise", 0 )
  local tx, ty, tz = Attack.act_get_center( target )
  Attack.act_move( dmgts, dmgts + 1, target, tx, ty, tz - 2.7, false ) -- raise body
  Attack.act_spawn( cell, bel, unit_animate, ang_to_enemy, count )
  Attack.act_nodraw( cell, true )
  local t = dmgts + 0.7
  Attack.act_animate( cell, "respawn", t )
  Attack.act_nodraw( cell, false, t )
	 Attack.act_fadeout( cell, t, t + .5, 1 )
  Attack.act_remove( target, 1.1 + dmgts )
end

function spell_necromancy_attack()
  local target = Attack.get_target()
 	local cell = Attack.cell_get_corpse( target )

  if cell == nil then
    cell = target
  end

  local ehero_level, level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff()
  end

	 local power = pwr_necromancy( level, ehero_level )

  if ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 )
  and ( Attack.act_feature( target, "undead" )
  or Attack.act_feature( cell, "undead" ) )
  and ( Attack.cell_has_ally_corpse( cell )
  or Attack.act_ally( target ) )
  and not Attack.act_temporary( cell ) then
    local percent = Game.Random( skill_power_range_dec( "necromancy", 1 ) )
    power = power * percent / 100

   	local count_1, count, hp = Attack.act_size( target ), 0, Attack.act_hp( target )

	   if Attack.get_caa( cell ) == nil then count_1 = 0 end

    Attack.atom_spawn( target, 0, "hll_priest_resur_cast" )
    Attack.cell_resurrect( target, power )
    local count_2 = Attack.act_size( target )

    if count_2 > count_1 then count = count_2 - count_1 end

    if count_2 < count_1 then count = count_2 end

   	local N

    if Attack.act_size( target ) > 1 then N = '2' else N = '1' end

    if count_1 == count_2 then
 	   	Attack.log( "add_blog_sheal_" .. N, "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_necromancy_name>", "special", Attack.act_hp( target ) - hp, "target", blog_side_unit( target, -1 ) )
	   else
   	 	Attack.log( "add_blog_sres_"  .. N, "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_necromancy_name>", "special", count, "target", blog_side_unit( target, -1 ) )
   	end

    return true
  else
  	 local animate_count_base = Attack.act_initsize( cell )	--how many units in the carcass
  	 local unit_animate = necro_get_unit( actor_name( cell ), animate_count_base, power )
  	 local undead_HP = Attack.atom_getpar( unit_animate, "hitpoint" )
  	 -- how much can be raised by health
  	 local animate_count = round( power / undead_HP )
  	 -- реально
  	 local animate_real = math.min( animate_count, animate_count_base )
  
  	 if animate_real ~= 0 then
      animate_dead( target, cell, 0, 0, unit_animate, animate_real )
  
  		  if animate_real > 1 then
  			   Attack.log( "add_blog_snecro_2", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_necromancy_name>", "targeta", blog_side_unit( cell, 0 ), "target", blog_side_unit( target, 0 ), "special", animate_real )
  		  else
  			   Attack.log( "add_blog_snecro_1", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_necromancy_name>", "targeta", blog_side_unit( cell, 0 ), "target", blog_side_unit( target, 0 ), "special", animate_real )
  		  end
  
  		  return true
    else
  		  return false
  	 end
  end
end


--*************************************************************************
-- Plague
--*************************************************************************
-- New! Common function for applying plague attack effects
function common_plague_attack( target, duration, power, level, dmgts )
  if Attack.act_name( target ) ~= "" then
    local spell = "spell_plague"
  
    if Attack.act_race( target ) ~= "undead" then
      duration = res_dur( dmgts + 0.1, target, spell, duration, "poison" )
    end
  
    Attack.act_apply_spell_begin( target, spell, duration, false )
    -- on non-undead throw fines
    if Attack.act_race( target ) ~= "undead" then
      Attack.act_apply_par_spell( "health", 0, -power, 0, duration, false )
   	 	Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
  		  Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
  		end
  
  		Attack.act_spell_param( target, spell, "level", level )
  		Attack.act_posthitmaster( target, "post_spell_plague", duration )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts , "magic_greenfly", Attack.angleto( target ), true )
  
    return true
  else
    return false
  end
end

function spell_plague_attack( target, level, dmgts )
  level = common_get_spell_level( level )
 	local duration = 0
	 local type_trigger = 10

 	if target ~= nil then type_trigger = 0 end -- call the function with the intended target

  if target == nil then target=Attack.get_target() end

  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

 	if Attack.act_is_spell( target, "spell_plague" ) and type_trigger == 10 then type_trigger = 1 end -- самовызов зараженного юнита

 	if not Attack.act_is_spell( target, "spell_plague" ) and type_trigger == 10 then type_trigger = 2 end -- заклинание

  -- Spell Attack
	 if type_trigger == 2 then
		  duration = int_dur( "spell_plague", level, "sp_duration_plague", nil, ehero_level )
	 end

  -- Necromancer Attack
  if type_trigger == 0 then
  	 level = tonumber( level )
--		  duration = int_dur( "spell_plague", level, "sp_duration_plague" )
   	duration = tonumber( "0" .. text_dec( Logic.obj_par( "spell_plague", "duration" ), level ) )
    if Attack.act_enemy( target ) then
      duration = duration + Logic.hero_lu_item( "sp_duration_special_plague", "count" )
    end
  end

 	if dmgts == nil then dmgts = 0 end

  local power = pwr_plague( level, ehero_level )

 	-- first block. If the goal is not - we take the selection.
 	--if target==nil then target = Attack.get_target() end

		-- if for no spell - impose
    --if not Attack.act_is_spell(target,"spell_plague") then
  if type_trigger ~= 1 then
    common_plague_attack( target, duration, power, level, dmgts )
    -- если есть заклинание - заражаем незараженных соседей:
		else
			 if target==nil then target=0 end

		  for i = 0, 5 do
    		level = tonumber( Attack.act_spell_param( target, "spell_plague", "level" ) )
--  		  duration = int_dur( "spell_plague", level, "sp_duration_plague" )
    		duration = tonumber( "0" .. text_dec( Logic.obj_par( "spell_plague", "duration" ), level ) )

    		local trg = Attack.cell_adjacent( target, i )
    		if ( Attack.act_enemy( trg )
      or Attack.act_ally( trg ) )
      and Attack.act_level( trg ) < 5
      and Attack.act_applicable( trg ) then
        if not Attack.act_is_spell( trg, "spell_plague" ) then
          local rnd = Game.Random( 99 )     -- ели он не заражен
          if rnd < 50 then
            common_plague_attack( trg, duration, power, level, dmgts )
    				  end
        end
    		end
    end
		end

  return true
end


--*************************************************************************
--   Post plague
--*************************************************************************

function post_spell_plague( damage, addrage, attacker, receiver, minmax )
		if minmax == 0
  and not ( Attack.act_feature( receiver, "plant" )
  or Attack.act_feature( receiver, "golem" )
  or Attack.act_feature( receiver, "demon" ) )
  and Attack.cell_dist( attacker, receiver ) == 1 then
			 local target_spell_level = 0
			 local level = tonumber( Attack.act_spell_param( attacker, "spell_plague", "level" ) )

				if not Attack.act_is_spell( receiver, "spell_plague" )
    and level ~= nil then
					 spell_plague_attack( receiver, level, 0 )
				end
		end

  return damage, addrage
end

function spell_plague_onremove( caa )
		Attack.act_posthitmaster( caa, "post_spell_plague", 0 )

  return true
end

-- ***********************************************
-- * Plague
-- ***********************************************
function spell_plague_attack1( target, level, dmgts )
 	local duration = 0

  if level == nil
  and Attack.get_target() ~= nil then
  	 level = Obj.spell_level()
		  duration = int_dur( "spell_plague", level, "sp_duration_plague" )
  else
  	 level = tonumber( level )
		  duration = int_dur( "spell_plague", level, "sp_duration_plague" )
  end

  if level == 0 then level = 1 end

 	if dmgts == nil then dmgts = 0 end

  local power = pwr_plague( level )

 	-- first block. If the goal is not - we take the selection.
 	if target == nil then target = Attack.get_target() end

		-- if for no spell - impose
  if not Attack.act_is_spell( target, "spell_plague" ) then
    common_plague_attack( target, duration, power, level, dmgts )
    -- если есть заклинание - заражаем незараженных соседей:
		else
		  for i = 0, 5 do
		  	 if target == nil then target = 0 end

    		local trg = Attack.cell_adjacent( target, i )
    		level = tonumber( Attack.act_spell_param( target, "spell_plague", "level" ) )

    		if ( Attack.act_enemy( trg )
      or Attack.act_ally( trg ) )
      and Attack.act_level( trg ) < 5
      and Attack.act_applicable( trg ) then
        if not Attack.act_is_spell( trg, "spell_plague" ) then
          local rnd = Game.Random( 99 )     -- ели он не заражен

          if rnd < 50 then
            common_plague_attack( trg, duration, power, level, dmgts )
    				  end
        end
      end
    end
		end

  return true
end


--New! Common function for the Demon / Dragon Slayer spells
function common_slayer_attack( target, spell, duration, script, level, effect )
  local dmgts = Game.Random() / 10
  duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
  Attack.act_del_spell( target, spell )
  Attack.act_apply_spell_begin( target, spell, duration, false )
  Attack.act_posthitmaster( target, script, duration, level )
  Attack.act_apply_spell_end()
  Attack.atom_spawn( target, dmgts, effect, Attack.angleto( target ) )

  return true
end


-- ***********************************************
-- * Demon Slayer
-- ***********************************************

function spell_demon_slayer_attack( level, target, belligerent )
  level = common_get_spell_level( level )

  if target == nil then target = Attack.get_target() end

  local ehero_level

  local spell = "spell_demon_slayer"
  local duration
  
  local function get_duration( target )
    if target ~= nil then
      duration = Attack.val_restore( target, "spell_last_hero_demon_slayer_duration" )
    end
  
    if duration == nil then
      duration = int_dur( spell, level, "sp_duration_demon_slayer", nil, ehero_level )
    end

    return duration
  end

  local script = Logic.obj_par( spell, "script" )

  if ( target ~= nil ) then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration = get_duration( target )
    common_slayer_attack( target, spell, duration, script, tostring( level ), "effect_demonslayer" )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration = get_duration( i )
        common_slayer_attack( i, spell, duration, script, tostring( level ), "effect_demonslayer" )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Dragon Slayer
-- ***********************************************

function spell_dragon_slayer_attack( level, target, belligerent )
  level = common_get_spell_level( level )

  if target == nil then target = Attack.get_target() end

  local ehero_level

  local spell = "spell_dragon_slayer"
  local duration
  
  local function get_duration( target )
    if target ~= nil then
      duration = Attack.val_restore( target, "spell_last_hero_dragon_slayer_duration" )
    end
  
    if duration == nil then
      duration = int_dur( spell, level, "sp_duration_dragon_slayer", nil, ehero_level )
    end

    return duration
  end

  local script = Logic.obj_par( spell, "script" )

  if ( target ~= nil ) then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration = get_duration( target )
    common_slayer_attack( target, spell, duration, script, tostring( level ), "effect_dragonslayer" )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration = get_duration( i )
        common_slayer_attack( i, spell, duration, script, tostring( level ), "effect_dragonslayer" )
      end
    end
  end

  return true
end



-- ***********************************************
-- * Resurrection
-- ***********************************************

function spell_resurrection_attack( level, target, belligerent, last_hero )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
    level = common_get_spell_level( level )
    local ehero_level
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
   	local count_1, count, hp = Attack.act_size( target ), 0, Attack.act_hp( target )

	   if Attack.get_caa( target ) == nil then count_1 = 0 end

    local rephits = Attack.val_restore( target, "spell_last_hero_resurrection_rephits" )

    if rephits == nil then
      rephits = pwr_resurrection( level, ehero_level )
    end

    Attack.atom_spawn( target, 0, "hll_priest_resur_cast" )
    Attack.cell_resurrect( target, rephits )
    local count_2 = Attack.act_size( target )
    --Attack.log_label("add_blog_burn")

    --if count_1==count_2 then count=count_1 end
    if count_2 > count_1 then count = count_2 - count_1 end

    if count_2 < count_1 then count = count_2 end

   	local N

    if Attack.act_size( target ) > 1 then N = '2' else N = '1' end

    if last_hero ~= true then
      local heroname = blog_side_unit( target, 4 ) .. Attack.hero_name()
  
      if count_1 == count_2 then
   	   	Attack.log( "add_blog_sheal_" .. N, "hero_name", heroname, "spell", blog_side_unit( target, 3 ) .. "<label=spell_resurrection_name>", "special", Attack.act_hp( target ) - hp, "target", blog_side_unit( target, -1 ) )
  	   else
     	 	Attack.log( "add_blog_sres_"  .. N, "hero_name", heroname, "spell", blog_side_unit( target, 3 ) .. "<label=spell_resurrection_name>", "special", count, "target", blog_side_unit( target, -1 ) )
     	end
    end
  end

  return true
end

-- ***********************************************
-- * Gifts
-- ***********************************************

function spell_gifts_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
    Attack.act_del_modificator( target, "disreload_lc_", true )
    Attack.act_reload( target )
    Attack.act_charge( target, 0 )
    Attack.atom_spawn( target, 0, "magic_cornucopia", Attack.angleto( target ) )
  end

  return true
end

function calccells_gifts()
  local ehero_level, level
  level = common_get_spell_level( level )

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

	 local lvl = tonumber( text_dec( Logic.obj_par( "spell_gifts", "level" ), level ) )

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_ally( i )
    and Attack.act_applicable( i )
    and Attack.act_level( i ) <= lvl
    and Attack.act_need_charge_or_reload( i ) then
      Attack.marktarget( i )            -- select it
    end
  end

  return true
end

-- ***********************************************
-- * Magic Bondage
-- ***********************************************

function spell_magic_bondage_attack( level, target )
  if target == nil then target = Attack.get_target() end

  level = common_get_spell_level( level )
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local duration = int_dur( "spell_magic_bondage", level, "sp_duration_magic_bondage", nil, ehero_level )

  local function common_magic_bondage_attack( target, spell, special, duration, spawn )
    local dmgts = Game.Random() / 10
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    Attack.act_del_spell( target, special )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_par_spell( "disreload", 10, 0, 0, duration, false)
    Attack.act_apply_par_spell( "disspec", 10, 0, 0, duration, false)
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, spawn, Attack.angleto( target ) )

    return true
  end

  if ( target ~= nil ) then
    common_magic_bondage_attack( target, "spell_magic_bondage", "special_stupid", duration, "magic_bondage" )
  else
    local acnt = Attack.act_count()
    local lvl = tonumber( text_dec( Logic.obj_par( "spell_magic_bondage", "level" ), level ) )
    for i = 1, acnt - 1 do
      if Attack.act_enemy( i )
      and Attack.act_applicable( i )
      and ( Attack.act_level( i ) <= lvl ) then
        common_magic_bondage_attack( i, "spell_magic_bondage", "special_stupid", duration, "magic_bondage" )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Scare
-- ***********************************************

function spell_scare_attack( lvl, dmgts, target )
 	if dmgts == nil then dmgts = 0 end

  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	local level = common_get_spell_level( lvl )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_scare"
    local duration = int_dur( spell, level, "sp_duration_scare", nil, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, "effect_fear" )
    Attack.act_apply_spell_begin( target, "effect_fear", duration, false )
    Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, "magic_scare", Attack.angleto( target ) )
    Attack.act_damage_addlog( target, "add_blog_fear_" )
  end

  return true
end

-- ***********************************************
-- * Cruel Fate
-- ***********************************************

function spell_crue_fate_attack( lvl, dmgts, target )
	 if dmgts == nil then dmgts = 0 end

  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	local level = common_get_spell_level( lvl )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_crue_fate"
    local duration = int_dur( spell, level, "sp_duration_crue_fate", nil, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, "magic_cruelfate", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Pain Mirror
-- ***********************************************

function spell_pain_mirror_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
   	level = common_get_spell_level( level )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

  	 local percent_dmg = pwr_pain_mirror( level, ehero_level )
    local last_dmg = tonum( Attack.val_restore( target, "last_dmg" ) )
    local a = Attack.atom_spawn( target, 0, "magic_mirror", Attack.angleto( target ) - 0.5 )
    local dmgts = Attack.aseq_time( a, "x" )
    Attack.atk_set_damage( "magic", last_dmg * percent_dmg / 100 )
    common_cell_apply_damage( target, dmgts )
  end

  return true
end

-- ***********************************************
-- * Last Hero
-- ***********************************************

function spell_last_hero_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local ehero_level
    local belligerent
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    local spell = "spell_last_hero"
    local duration = int_dur( spell, level, "sp_duration_last_hero", nil, ehero_level )
    duration = res_dur( 0.1, target, spell, duration, "magic" )
    local script = Logic.obj_par( spell, "script" )
    local hit = 1;
    Attack.act_del_spell( target, spell )
			 Attack.val_store( target, "spell_last_hero_cast_level", level )
    store_power_on_target( target, level, ehero_level )
    Attack.act_apply_spell_begin( target, spell, duration, false )
			 Attack.act_spell_param( target, spell, "heroname", Attack.hero_name() )
			 Attack.act_spell_param( target, spell, "belligerent", belligerent )
    Attack.act_posthitslave( target, script, duration, "super" )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_last_hero", Attack.angleto( target ) )
  end

  return true
end

function spell_last_hero_onremove( caa, duration_end )
		Attack.act_posthitmaster( caa, "post_spell_last_hero", 0 )

  return true
end


function store_power_on_target( target, level, ehero_level )
  local power, penalty = pwr_stone_skin( level, ehero_level )
  local spell = "spell_stone_skin"
  local duration = int_dur( spell, level, "sp_duration_stone_skin", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_stone_skin_power", power )
		Attack.val_store( target, "spell_last_hero_stone_skin_penalty", penalty )
		Attack.val_store( target, "spell_last_hero_stone_skin_duration", duration )

  spell = "spell_bless"
  duration = int_dur( spell, level, "sp_duration_bless", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_bless_duration", duration )

  spell = "spell_accuracy"
  duration = int_dur( spell, level, "sp_duration_accuracy", nil, ehero_level )
  local bonus = pwr_accuracy( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_accuracy_duration", duration )
		Attack.val_store( target, "spell_last_hero_accuracy_bonus", bonus )

  spell = "spell_adrenalin"
  power = tonumber( pwr_adrenalin( level, ehero_level ) )
  duration = int_dur( spell, level, "sp_duration_adrenalin", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_adrenalin_power", power )
		Attack.val_store( target, "spell_last_hero_adrenalin_duration", duration )

  spell = "spell_demon_slayer"
  duration = int_dur( spell, level, "sp_duration_demon_slayer", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_demon_slayer_duration", duration )

  spell = "spell_dragon_slayer"
  duration = int_dur( spell, level, "sp_duration_dragon_slayer", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_dragon_slayer_duration", duration )

  power = pwr_fire_breath( level, ehero_level )
  spell = "spell_fire_breath"
  duration = int_dur( spell, level, "sp_duration_fire_breath", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_fire_breath_power", power )
		Attack.val_store( target, "spell_last_hero_fire_breath_duration", duration )

  spell = "spell_haste"
  duration = int_dur( spell, level, "sp_duration_haste", nil, ehero_level )
  local speedbonus, kritbonus = pwr_haste( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_haste_duration", duration )
		Attack.val_store( target, "spell_last_hero_haste_speedbonus", speedbonus )
		Attack.val_store( target, "spell_last_hero_haste_kritbonus", kritbonus )

  spell = "spell_reaction"
  duration = int_dur( spell, level, "sp_duration_reaction", nil, ehero_level )
  local moralbonus = pwr_warcry( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_reaction_duration", duration )
		Attack.val_store( target, "spell_last_hero_reaction_moralbonus", moralbonus )

  local rephits = pwr_resurrection( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_resurrection_rephits", rephits )

  spell = "spell_magic_source"
  duration = int_dur( spell, level, "sp_duration_magic_source", nil, ehero_level )
  local penalty, mana = pwr_magic_source( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_magic_source_duration", duration )
		Attack.val_store( target, "spell_last_hero_magic_source_penalty", penalty )
		Attack.val_store( target, "spell_last_hero_magic_source_mana", mana )

  spell = "spell_divine_armor"
  duration = int_dur( spell, level, "sp_duration_divine_armor", nil, ehero_level )
  local resistbonus = pwr_divine_armor( level, ehero_level )
		Attack.val_store( target, "spell_last_hero_divine_armor_duration", duration )
		Attack.val_store( target, "spell_last_hero_divine_armor_resistbonus", resistbonus )

  spell = "spell_invisibility"
  duration = int_dur( spell, level, "sp_duration_invisibility", nil, ehero_level )
		Attack.val_store( target, "spell_last_hero_invisibility_duration", duration )

  return true
end


-- ***********************************************
-- * Magic Source
-- ***********************************************

function spell_magic_source_attack( level, target, belligerent, heroname, enchanted_hero )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local ehero_level

    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )

    if heroname == nil then
      heroname = Attack.hero_name()
    end

    if mana_rage_gain_k == nil then
      mana_rage_gain_k = 1
    end

    local spell = "spell_magic_source"

    local duration, penalty, mana

    if enchanted_hero == true then
      duration = Attack.val_restore( target, "spell_last_hero_magic_source_duration" )
  		  penalty = Attack.val_restore( target, "spell_last_hero_magic_source_penalty" )
  		  mana = Attack.val_restore( target, "spell_last_hero_magic_source_mana" )
    else
      duration = int_dur( spell, level, "sp_duration_magic_source", nil, ehero_level )
      penalty, mana = pwr_magic_source( level, ehero_level )
    end

    duration = res_dur( 0.1, target, spell, duration, "magic" )
    local script = Logic.obj_par( spell, "script" )
    local defense, basedefense = Attack.act_get_par( target, "defense" )
    Attack.val_store( target, "spell_magic_source_mana_gain", mana )
    Attack.val_store( target, "spell_magic_source_mana_rage_gain_k", mana_rage_gain_k )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_par_spell( "defense", 0, penalty, 0, duration, false )
			 Attack.act_spell_param( target, spell, "heroname", heroname )
			 Attack.act_spell_param( target, spell, "belligerent", belligerent )
    Attack.act_posthitslave( target, script, duration, tostring( level ) )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_mana_shield", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Target
-- ***********************************************

function spell_target_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
   	level = common_get_spell_level( level )
    local duration = int_dur( "spell_target", level, "sp_duration_target", nil, ehero_level )
    Attack.act_del_spell( target, "spell_target" )
    Attack.act_apply_spell_begin( target, "spell_target", duration, false )
    Attack.act_spell_param( target, "spell_target", "lvl", text_dec( Logic.obj_par( "spell_target", "lvl" ), level ) )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_target", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Berserker
-- ***********************************************

function spell_berserker_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local ehero_level

    if Attack.act_belligerent( target ) ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_berserker"
    local duration = int_dur( spell, level, "sp_duration_berserker", nil, ehero_level )
    duration = res_dur( 0.1, target, spell, duration, "magic" )
    local level, power = pwr_berserker( level, ehero_level )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
    Attack.act_apply_par_spell( "attack", 0, power, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_lioncup", Attack.angleto( target ) )
  end

  return true
end

function spell_berserker_onremove(target,duration_end)
  if duration_end~=true then
	 		if Attack.act_size(target)>1 then
		   	Attack.log(0.001,"add_blog_nobers_2","name",blog_side_unit(target,1))
		  else
			   Attack.log(0.001,"add_blog_nobers_1","name",blog_side_unit(target,1))
		  end
  end

  return true
end

function spell_berserker_duration_end()
  local target = Attack.get_target()
  Attack.atom_spawn( target, 0, "magic_lioncup", Attack.angleto( target ) )

  return true
end

-- ***********************************************
-- * Adrenalin
-- ***********************************************

function spell_adrenalin_attack( level, target, belligerent )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
   	level = common_get_spell_level( level )
    local ehero_level
    local loggg = 0

    if belligerent == nil then
      belligerent = Attack.act_belligerent( target )
    else
      loggg = 2
    end

    if belligerent ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_adrenalin"
    local power = Attack.val_restore( target, "spell_last_hero_adrenalin_power" )
    local duration = Attack.val_restore( target, "spell_last_hero_adrenalin_duration" )

    if power == nil
    or duration == nil then
      power = tonumber( pwr_adrenalin( level, ehero_level ) )
      duration = int_dur( spell, level, "sp_duration_adrenalin", nil, ehero_level )
    end

    local cur_ap = Attack.act_ap( target )

   	local new_ap;
	   if ( Attack.act_again( target ) ) then
      new_ap = power -- meaning unit was added to the list - just set him right number of points instead of adding them to the current

      if loggg == 0 then
    		  loggg = 1
      end
	   else
      new_ap = power + cur_ap
    end

    Attack.act_ap( target, new_ap ) -- вынес функцию сюда, т.к. act_apply_spell_end() восстанавливает разность ОД, т.е. по сути аннулирует эффект от вызова этой функции двумя строками ниже

    duration = res_dur( 0.1, target, spell, duration, "magic" )

    --New! Adds unlimited retaliation to the unit for the duration specified in SPELLS.TXT
    if duration > 0 then
      local current_hitback, base_hitback = Attack.act_get_par( target, "hitback" )
  
      if current_hitback < 2 then  --only do this if the hitback is under 2, otherwise the unit won't retaliate at all!
        Attack.act_del_spell( target, spell )
        Attack.act_apply_spell_begin( target, spell, duration, false )
        Attack.act_apply_par_spell( "hitback", ( 2 - current_hitback ), 0, 0, duration, false )
        Attack.act_apply_spell_end()
      end
    end

    Attack.atom_spawn( target, 0, "magic_horn", Attack.angleto( target ) )

    if loggg == 1 then
    	 Attack.log_label( "add_blog_sadrenlin" )
    	--Attack.log("add_blog_sadrenlin_2")
    else
    	 Attack.log_label( "" )
    end
  end

  return true
end

-- ***********************************************
-- * Hypnosis
-- ***********************************************

function spell_hypnosis_attack( lvl, dmgts )
	 if dmgts == nil then dmgts = 0 end

	 local level = common_get_spell_level( lvl )
  local target = Attack.get_target()
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  --local bl=1
  --if Attack.act_belligerent(target) == 1 or Attack.act_belligerent(target) == 2 then bl = 4 end
  local bl = Attack.act_belligerent()

  if bl == 0 then bl = 4 end

  Attack.act_belligerent( target, bl )
  local spell = "spell_hypnosis"
  local moves = int_dur( spell, level, "sp_duration_hypnosis", nil, ehero_level )
  moves = res_dur( dmgts + 0.1, target, spell, moves, "magic" )
  Attack.act_apply_spell_begin( target, spell, moves, false )
  Attack.act_apply_spell_end()
  Attack.atom_spawn( target, dmgts, "magic_hypnosis", Attack.angleto( target ) )
	 Attack.log_label( "add_blog_shypnos" )

  return true
end

function spell_hypnosis_onremove( caa )
  -- return to the initial
  Attack.act_belligerent(caa, Attack.act_belligerent( caa, nil ))
		if Attack.act_size(caa)>1 then
				Attack.log(0.001,"add_blog_nocharm_2","name",blog_side_unit(caa))
		end
		if Attack.act_size(caa)==1 then
				Attack.log(0.001,"add_blog_nocharm_1","name",blog_side_unit(caa))
		end

  return true
end


-- ***********************************************
-- * Fire Breath
-- ***********************************************
function spell_fire_breath_attack( level, target, belligerent )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local ehero_level
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    local spell = "spell_fire_breath"
		  local power = Attack.val_restore( target, "spell_last_hero_fire_breath_power" )
		  local duration = Attack.val_restore( target, "spell_last_hero_fire_breath_duration" )

    if power == nil
    or duration == nil then
      power = pwr_fire_breath( level, ehero_level )
      duration = int_dur( spell, level, "sp_duration_fire_breath", nil, ehero_level )
    end

    duration = res_dur( 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    local mindfire = Attack.act_get_dmg_min( target, "fire" )
    local mindpoison = Attack.act_get_dmg_min( target, "poison" )
    local mindmagic = Attack.act_get_dmg_min( target, "magic" )
    local mindphysical = Attack.act_get_dmg_min( target, "physical" )
    local maxdfire = Attack.act_get_dmg_max( target, "fire" )
    local maxdpoison = Attack.act_get_dmg_max( target, "poison" )
    local maxdmagic = Attack.act_get_dmg_max( target, "magic" )
    local maxdphysical = Attack.act_get_dmg_max( target, "physical" )
  		local max_dmg = ( maxdfire + maxdpoison + maxdmagic + maxdphysical ) * power / 100
    local min_dmg = ( mindfire + mindpoison + mindmagic + mindphysical ) * power / 100
    Attack.act_apply_spell_begin( target, "spell_fire_breath", duration, false )
    Attack.act_apply_dmgmax_spell( "fire", max_dmg, 0, 0, duration, false)
    Attack.act_apply_dmgmin_spell( "fire", min_dmg, 0, 0, duration, false)
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_breath" )

  end

  return true
end

-- ***********************************************
-- * Star Force
-- ***********************************************

    --local d = Attack.atom_spawn(target, time_first_effect, damage_effect )    -- эффект урона
  --local dmgtd = Attack.aseq_time(d, "x")
  --common_cell_apply_damage(target, time_first_effect+dmgtd)   -- apply damage

-- atk_set_damage("resistname", damagemin [, damagemax])

function spell_magic_missle_attack()
  local target = Attack.get_target()
  if (target ~= nil) then
    local count = tonumber(Attack.get_custom_param("count"))
    common_cell_attack(target, "magic_missile")
  end

  return true
end


-- ***********************************************
-- * Stone Skin
-- ***********************************************
function spell_stone_skin_attack( level, target, belligerent )
  level = common_get_spell_level( level )
  local spell = "spell_stone_skin"
  local ehero_level
  local power, penalty, duration

  local function get_bonus( target )
    power = Attack.val_restore( target, "spell_last_hero_stone_skin_power" )
  		penalty = Attack.val_restore( target, "spell_last_hero_stone_skin_penalty" )
    duration = Attack.val_restore( target, "spell_last_hero_stone_skin_duration" )
  
    if power == nil
    or penalty == nil
    or duration == nil then
      power, penalty = pwr_stone_skin( level, ehero_level )
      duration = int_dur( spell, level, "sp_duration_stone_skin", nil, ehero_level )
    end

    return power, penalty, duration
  end

  local function common_stone_skin( target, spell, power, penalty, duration )
    local dmgts0 = Game.Random() / 10
    duration = res_dur( dmgts0 + 0.1, target, spell, duration, "magic" )
    local initiative, initiativebase = Attack.act_get_par( target, "initiative" )
  
    if initiative < 2 then
      penalty = 0
    end

    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_res_spell( "physical", power, 0, 0, duration, false)
    Attack.act_apply_par_spell( "initiative", -penalty, 0, 0, duration, false)
    Attack.act_apply_par_spell( "defense", 0, 0, power, duration, false)
    Attack.act_apply_spell_end()
    local a = Attack.atom_spawn( target, dmgts0, "magic_stoneskin" )
    local dmgts = Attack.aseq_time( a, "x" )
    local dmgts2 = Attack.aseq_time( a, "y" )
    Attack.act_set_diff_tex( target, "stone_skin.dds", dmgts )
    Attack.act_set_diff_tex( target, "", dmgts2 )
  end

  if target == nil then target = Attack.get_target() end

  if target ~= nil  then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    power, penalty, duration = get_bonus( target )
    common_stone_skin( target, spell, power, penalty, duration )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        power, penalty, duration = get_bonus( i )
        common_stone_skin( i, spell, power, penalty, duration )
      end
    end
  end

  return true
end

function spell_stone_skin_onremove( caa )
  Attack.act_set_diff_tex( caa, "", 1 )

  return true
end

-- ***********************************************
-- * Dispell
-- ***********************************************
function takeoff_spells( target, type, check_only )
	 local spells_to_delete = {}

	 for i = 0, Attack.act_spell_count( target ) - 1 do
		  local spell_name = Attack.act_spell_name( target, i )
		  local spell_type = Logic.obj_par( spell_name, "type" )
		  if spell_type == type
    and string.find( spell_name, "^totem_" ) == nil
    and not string.find( spell_name, "special_difficulty" )
    and not string.find( spell_name, "special_rooted" )
    and not string.find( spell_name, "special_summon_bonus" ) then
-- 			Attack.act_del_spell(target, spell_name)
			   table.insert( spells_to_delete, spell_name );
		  end
	 end

	 if check_only then
    return table.getn( spells_to_delete ) > 0, spells_to_delete
  end

	 for k, v in ipairs( spells_to_delete ) do
		  Attack.act_del_spell( target, v )
	 end

 	return table.getn( spells_to_delete ) > 0
end


function spell_dispell_attack( level, target, belligerent, enchanted_hero )
  if target == nil then target = Attack.get_target() end

 	level = common_get_spell_level( level )
  local ehero_level
  belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
  local mode = text_dec( Logic.obj_par( "spell_dispell", "spell" ), level )

  if ( target ~= nil ) then
	   if mode == "all" then
      takeoff_spells( target, "penalty" )
      takeoff_spells( target, "bonus" )
--	     Attack.act_del_spell( target )
	   else
     	local type

      if enchanted_hero == nil then
  	     if Attack.act_ally( target ) then
          type = "penalty" -- Remove all of their penalty-spell
  	     else
          type = "bonus"
        end -- с противника снимаем все bonus-заклинания
      else
  	     if Attack.act_ally( target, belligerent ) then
          type = "penalty" -- Remove all of their penalty-spell
  	     else
          type = "bonus"
        end -- с противника снимаем все bonus-заклинания
      end

		    if ( Attack.act_is_spell( target, "spell_hypnosis" )
      or Attack.act_is_spell( target, "effect_charm" ) )
      and Logic.obj_par( "spell_hypnosis", "type" ) == type then -- гипноз снимаем в первую очередь
			     Attack.act_del_spell( target, "spell_hypnosis" )
			     Attack.act_del_spell( target, "effect_charm" )

		      if Attack.act_ally( target ) then
          type = "penalty" -- Remove all of their penalty-spel
		      else
          type = "bonus"
        end -- с противника снимаем все bonus-заклинания
		    end
	     takeoff_spells( target, type )
	   end
	   Attack.atom_spawn( target, 0, "magic_dispel" )
  end

  return true
end

-- ***********************************************
-- * Oil Fog
-- ***********************************************

function spell_oil_fog_attack( lvl, dmgts )
 	if dmgts == nil then dmgts = 0 end

  local target = Attack.get_target()

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, lvl = get_enemy_hero_stuff( lvl )
    end

    local spell = "spell_oil_fog"
    local min_dmg, max_dmg, duration, power = pwr_oil_fog( lvl, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "fire" )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
    local a = Attack.atom_spawn( target, dmgts, "magic_oilfog" )
    local dmgts1 = Attack.aseq_time( a, "x" )
    common_cell_apply_damage( target, dmgts1 + dmgts )
    Attack.act_del_spell( target, spell )
    local resist, resistbase = Attack.act_get_res( target, "fire" )

    if ( resist <= -1 * power ) or ( resist >= 80 ) then
      power = 0
    else
      power = power + resist
    end

    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_res_spell( "fire", -power, 0, 0, duration, false)
    Attack.act_apply_spell_end()
  end

  return true
end


-- ***********************************************
-- * Poison Resist
-- ***********************************************
function spell_poison_resist_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
    local ehero_level

    if Attack.act_belligerent( target ) ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local duration = tonumber(Attack.get_custom_param("duration"))
    local resistbonus = tonumber(Attack.get_custom_param("resistbonus"))

    Attack.act_del_spell(target,"spell_poison_resist")

    local resist,resistbase = Attack.act_get_res(target,"poison")

    if resistbonus <= resist then
      resistbonus = 0
    else
      if resist>=0 then
        resistbonus = resistbonus-resist
      end
    end

    Attack.act_apply_spell_begin( target, "spell_poison_resist", duration, false )
    Attack.act_apply_res_spell( "poison", resistbonus, 0, 0, duration, false)
    Attack.act_apply_spell_end()
    Attack.atom_spawn(target, 0, "magic_antisnakes" )
  end

  return true
end

--New! Common function for Haste / Slow spells
function common_haste_slow_attack( target, spell1, spell2, duration, value, dmgts, spawn, krit )
  dmgts = dmgts + Game.Random() / 10
  duration = res_dur( dmgts + 0.1, target, spell1, duration, "magic" )
  Attack.act_del_spell( target, spell1 )
  Attack.act_del_spell( target, spell2 )
  Attack.act_apply_spell_begin( target, spell1, duration, false )
  Attack.act_apply_par_spell( "speed", value, 0, 0, duration, false)
  Attack.act_apply_par_spell( "initiative", value, 0, 0, duration, false)

  if spell1 == "spell_haste" then
    Attack.act_apply_par_spell( "krit", krit, 0, 0, duration, false)
  end

  Attack.act_apply_spell_end()
  if spell1 == "spell_haste" then
    Attack.atom_spawn( target, dmgts, spawn, Attack.angleto( target ) )
  else
    Attack.val_store( target, "krit_slow", krit )
    Attack.atom_spawn( target, dmgts, spawn )
  end

  return true
end

-- ***********************************************
-- * Haste
-- ***********************************************
function spell_haste_attack( level, dmgts, target, belligerent )
 	level = common_get_spell_level( level )
  local ehero_level

  if target == nil then target = Attack.get_target() end

  if dmgts == nil then dmgts = 0 end

  local spell = "spell_haste"
  local duration, speedbonus, kritbonus

  local function get_bonus( target )
  		duration = Attack.val_restore( target, "spell_last_hero_haste_duration" )
		  speedbonus = Attack.val_restore( target, "spell_last_hero_haste_speedbonus" )
		  kritbonus = Attack.val_restore( target, "spell_last_hero_haste_kritbonus" )

    if duration == nil
    or speedbonus == nil
    or kritbonus == nil then
      duration = int_dur( spell, level, "sp_duration_haste", nil, ehero_level )
      speedbonus, kritbonus = pwr_haste( level, ehero_level )
    end

    return duration, speedbonus, kritbonus
  end

  if target ~= nil  then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration, speedbonus, kritbonus = get_bonus( target )
    common_haste_slow_attack( target, spell, "spell_slow", duration, speedbonus, dmgts, "magic_reaction", kritbonus )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration, speedbonus, kritbonus = get_bonus( i )
        common_haste_slow_attack( i, spell, "spell_slow", duration, speedbonus, dmgts, "magic_reaction", kritbonus )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Slow
-- ***********************************************
function spell_slow_attack( lvl, dmgts )
 	if dmgts == nil then dmgts = 0 end

	 local level = common_get_spell_level( lvl )
  local target = Attack.get_target()
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local spell = "spell_slow"
  local duration = int_dur( spell, level, "sp_duration_slow", nil, ehero_level )
  local speedlow, kritlow = pwr_slow( level, ehero_level )

  if ( target ~= nil ) then
    common_haste_slow_attack( target, spell, "spell_haste", duration, -speedlow, dmgts, "magic_slow", kritlow )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_enemy( i )
      and Attack.act_applicable( i ) then
        common_haste_slow_attack( i, spell, "spell_haste", duration, -speedlow, dmgts, "magic_slow", kritlow )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Fire Resist
-- ***********************************************
function spell_fire_resist_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
    local duration = tonumber(Attack.get_custom_param("duration"))
    local resistbonus = tonumber(Attack.get_custom_param("resistbonus"))

    Attack.act_del_spell(target,"spell_fire_resist")

    local resist,resistbase = Attack.act_get_res(target,"fire")

    if resistbonus <= resist then
      resistbonus = 0
    else
      if resist>=0 then
        resistbonus = resistbonus-resist
      end
    end

    Attack.act_apply_spell_begin( target, "spell_fire_resist", duration, false )
    Attack.act_apply_res_spell( "fire", resistbonus, 0, 0, duration, false)
    Attack.act_apply_spell_end()
    Attack.atom_spawn(target, 0, "magic_antifire" )
  end

  return true
end


--New! Common function for applying burn attack
function common_fire_burn_attack( target, burn, dmgts, duration, damage, label, spell )
  local burn_res = Attack.act_get_res( target, "fire" )
  local burn_rnd = Game.Random( 99 )
  local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
  local dmg

  if damage == nil then
    dmg = tonum( Attack.val_restore( target, "sdmg" ) )
  else
    dmg = damage
  end

  local burn_damage = dmg * burn_chance / 200

  if burn_rnd < burn_chance
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "fire_immunitet" ) then
    if spell ~= nil then
      duration = res_dur( dmgts + 0.1, target, spell, duration, "fire" )
    end

  	 effect_burn_attack( target, dmgts, duration, burn_damage, burn_damage )

    if label == true then
   			Attack.log_label("")
    end
  end

  return true
end


-- ***********************************************
-- * Fire arrow
-- ***********************************************

function spell_fire_arrow_attack( lvl, dmgts )
  local ehero_level

  local target = Attack.get_target()

  if Attack.act_belligerent() ~= 1 then
    ehero_level, lvl = get_enemy_hero_stuff( lvl )
  end

		if dmgts == nil then dmgts = 0 end

  local spell = "spell_fire_arrow"
  local min_dmg, max_dmg, burn, duration = pwr_fire_arrow( lvl, ehero_level )
  local dmg_type = Logic.obj_par( spell, "typedmg" )
  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
  local a = Attack.atom_spawn( target, dmgts, "magic_firearrow", Attack.angleto( target ) + 2.5 )
  local dmgts1 = Attack.aseq_time( a, "x" )
  common_cell_apply_damage( target, dmgts + dmgts1 )
  common_fire_burn_attack( target, burn, dmgts + dmgts1 + 1, duration, nil, nil, spell )

  return true
end

-- ***********************************************
-- * Healing
-- ***********************************************

function spell_cure_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local ehero_level

    if Attack.act_belligerent( target ) ~= 1 then
      if not Attack.act_feature( target, "undead" ) then
        ehero_level, level = get_enemy_hero_stuff( level )
      end
    end

		  Attack.log_label( "null" )
    local min_dmg, max_dmg = pwr_healing( level, ehero_level, Attack.act_race( target, "undead" ) )
    local dmg_type = Logic.obj_par( "spell_healing", "typedmg" )
    Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
    if ( Attack.act_race( target, "undead" ) ) then
      common_cell_attack( target, "hll_priest_heal_post" )
      Attack.log_label( "" )
    elseif ( Attack.act_need_cure( target ) ) then
  				if level == 3 then
        Attack.act_del_spell( target, "effect_poison" )
								Attack.act_del_spell( target, "spell_weakness" )
								Attack.act_del_spell( target, "spell_infection" )
								Attack.act_del_spell( target, "effect_weakness" )
								Attack.act_del_spell( target, "special_plague" )
								Attack.act_del_spell( target, "spell_plague" )
								Attack.act_del_spell( target, "special_disease" )
								Attack.act_del_spell( target, "effect_infection" )
						end

      local cure_hp = Game.Random( min_dmg, max_dmg + 0.45 )
      local max_hp = Attack.act_get_par( target, "health" )
      local cur_hp = Attack.act_hp( target )

      if cure_hp > max_hp - cur_hp then cure_hp = max_hp - cur_hp end

      local a = Attack.atom_spawn( target, 0, "hll_priest_heal_post" )
      local dmgts = Attack.aseq_time( a, "x" )
      Attack.act_cure( target, cure_hp, dmgts )

      if Attack.act_size( target ) > 1 then
       	Attack.log( "add_blog_sheal_2", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_healing_name>", "special", cure_hp, "target", blog_side_unit( target, -1 ) )
      else
       	Attack.log( "add_blog_sheal_1", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_healing_name>", "special", cure_hp, "target", blog_side_unit( target, -1 ) )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Magic Axe
-- ***********************************************

function spell_magic_axe_attack( lvl, dmgts )
  if dmgts == nil then dmgts = 0 end

  local target = Attack.get_target()

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, lvl = get_enemy_hero_stuff( lvl )
    end

    local min_dmg, max_dmg, count = pwr_magic_axe( lvl, ehero_level )
    local dmg_type = Logic.obj_par( "spell_magic_axe","typedmg" )
    local atomX = Attack.aseq_time( "magicaxe", "x" )
    local unitX = Attack.aseq_time( target, "damage", "x" )
    Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
	   local interval = 2

    for i = 0, count - 1 do
      local t = i * interval -- время спауна топора
	     Attack.atom_spawn( target, t + dmgts, "magicaxe", Attack.angleto( target ) )
	     if i == count - 1 then
	    	  common_cell_apply_damage( target, t + atomX + dmgts )
		    else
	    	  Attack.act_animate( target, "damage", t + atomX - unitX + dmgts )
		    end
    end
  end

  return true
end


-- ***********************************************
-- * Smile Skull
-- ***********************************************

function spell_smile_skull_attack( lvl, dmgts )
	 if dmgts == nil then dmgts = 0 end

  local target = Attack.get_target()

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, lvl = get_enemy_hero_stuff( lvl )
    end

    local spell = "spell_smile_skull"
    local min_dmg, max_dmg, poison, duration = pwr_smile_skull( lvl, ehero_level )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    local poison_rnd = Game.Random( 99 )
    Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
    local a = Attack.atom_spawn( target, dmgts, "magic_skull", Attack.angleto( target ) )
    local dmgts1 = Attack.aseq_time( a, "x" )
    common_cell_apply_damage( target, dmgts1 + dmgts )
    local poison_res = Attack.act_get_res( target, "poison" )
    -- poisons unit in 3 moves. He takes damage 1-5 * power and loses 5 May * power attack
    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local dmg = tonum( Attack.val_restore( target, "sdmg" ) )
    local poison_damage = dmg * poison_chance / 200

    if poison_rnd < poison_chance
    and not Attack.act_feature( target, "golem" ) then
      duration = res_dur( dmgts + dmgts1 + 1.1, target, spell, duration, "poison" )
      effect_poison_attack( target, dmgts1 + 1 + dmgts, duration, poison_damage, poison_damage )
    end
    --hll_post_archmage_lighting
    return true
  end

  return true
end


-- ***********************************************
-- * Fire Ball
-- ***********************************************

function spell_fire_ball_attack()
  local target = Attack.get_target()                            -- epicentre

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level = get_enemy_hero_stuff()
    end

    local spell = "spell_fire_ball"
    local a = Attack.atom_spawn( target, 0, "magic_fireball", 5.5 )          -- summon fireball in epicentre
    local dmgts = Attack.aseq_time( a, "x" )
    local min_e_dmg, max_e_dmg, burn, duration = pwr_fire_ball( "epicentre", level, ehero_level )
    local min_p_dmg, max_p_dmg, burn_p, duration_p = pwr_fire_ball( "periphery", level, ehero_level )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
--      if (Attack.act_enemy(target)) then                          -- contains enemy
    Attack.atk_set_damage( dmg_type, min_e_dmg, max_e_dmg )
    common_cell_apply_damage( target, dmgts )                       -- apply damage in epicentre
    common_fire_burn_attack( target, burn, dmgts + 1, duration, nil, nil, spell )
--    end
    local n = 7

    for i = 1, n - 1 do
      target = Attack.get_target( i )
      if ( target ~= nil ) then
        Attack.atk_set_damage( dmg_type, min_p_dmg, max_p_dmg )   -- set custom damage for periphery
        common_cell_apply_damage( target, dmgts )       -- apply damage
        common_fire_burn_attack( target, burn_p, dmgts + 1, duration_p, nil, nil, spell )
      end
    end
  end

  return true
end



-- ***********************************************
-- * Fire Rain
-- ***********************************************

function spell_fire_rain_attack()
  local target = Attack.get_target()                -- epicentre

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level = get_enemy_hero_stuff()
    end

    local spell = "spell_fire_rain"
    local min_dmg, max_dmg, burn, duration = pwr_fire_rain( level, ehero_level )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    local n = 7

    for i = 0, n - 1 do
      target = Attack.get_target( i )
      if ( target ~= nil ) then
        Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
        local deviation = Game.Random()
        local a = Attack.atom_spawn( target, deviation, "hll_firerain", 2.0 )    -- summon fire rain
        local dmgts = Attack.aseq_time( a, "x" )
        common_cell_apply_damage( target, deviation + dmgts )                     -- apply damage
        common_fire_burn_attack( target, burn, dmgts + 2 + deviation, duration, nil, nil, spell )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Ice Serpent
-- ***********************************************

function spell_ice_serpent_highlight()
  local target = Attack.get_target()

  if ( not Attack.cell_is_empty( target ) )
  and Attack.act_enemy( target )
  and Attack.act_takesdmg( target )
  and Attack.act_applicable( target ) then       -- can receive this attack
   	Attack.cell_select( target,"avenemy" )
  	 for i = 0, 5 do
  		  local cell = Attack.cell_adjacent( target, i )
  		  if cell ~= nil then
			     if ( not Attack.cell_is_empty( cell ) ) --[[and Attack.act_enemy(cell)]]
        and Attack.act_takesdmg( cell )
        and Attack.act_applicable( cell ) then
  		    		Attack.cell_select( cell, "avenemy" )
		     	else
		  		    Attack.cell_select( cell, "destination" )
		  	   end
		    end
  	 end
  end

  return true
end

freeze_im=0.75 --25%

function common_freeze_attack( target, spell, freeze, dmgts, duration )
  local freeze_rnd = Game.Random( 99 )
  local cold_fear = Attack.act_get_res( target, "fire" )
  local freeze_res = Attack.act_get_res( target, "physical" )

  if Attack.act_feature( target, "fire_immunitet" )
  or Attack.act_race( target, "demon" ) then
    cold_fear = cold_fear + Game.Random( 10, 50 )
    freeze_res = 0
  end

  if ( freeze_rnd < ( freeze - freeze_res + cold_fear )
  or cold_fear >= 50 )
  and not Attack.act_pawn( target )
  and not Attack.act_feature( target, "pawn" )
  and not Attack.act_feature( target, "boss" )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "freeze_immunitet" ) then
    duration = res_dur( dmgts + 0.1, target, spell, duration, "physical", nil, true )
    effect_freeze_attack( target, dmgts, duration )
  end

  return true
end

function common_freeze_im_vul( target, min_dmg, max_dmg )
  if max_dmg == nil then
    max_dmg = min_dmg
  end

  if Attack.act_feature( target, "freeze_immunitet" ) then
    min_dmg = min_dmg * freeze_im
    max_dmg = max_dmg * freeze_im
  elseif Attack.act_feature( target, "fire_immunitet" )
  or Attack.act_race( target, "demon" ) then
    local physical_res = limit_value( Attack.act_get_res( target, "physical" ), 0, 95 )
    min_dmg = min_dmg * ( 1 + physical_res / ( 100 - physical_res ) ) * ( 1 - physical_res / 100 / 2 )
    max_dmg = max_dmg * ( 1 + physical_res / ( 100 - physical_res ) ) * ( 1 - physical_res / 100 / 2 )
    local fire_res = limit_value( Attack.act_get_res( target, "fire" ), 0, 95 )
    min_dmg = min_dmg * ( 1 + fire_res / 100 / 2 )
    max_dmg = max_dmg * ( 1 + fire_res / 100 / 2 )
  end

  return min_dmg, max_dmg
end

function spell_ice_serpent_attack( level, dmgt, target )
  if dmgt == nil then dmgt = 0 end

  if target == nil then target = Attack.get_target() end                                -- epicentre

  if ( target ~= nil ) then
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_ice_serpent"
    local a = Attack.atom_spawn( target, dmgt, "magic_icedragon" )              -- summon iceball in epicentre
    local dmgts = Attack.aseq_time( a, "x" ) + dmgt
    local min_e_dmg, max_e_dmg, freeze, duration = pwr_ice_serpent( "epicentre", level, ehero_level )
    local min_p_dmg, max_p_dmg, freeze_p, duration_p = pwr_ice_serpent( "periphery", level, ehero_level )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    min_e_dmg, max_e_dmg = common_freeze_im_vul( target, min_e_dmg, max_e_dmg )
    Attack.atk_set_damage( dmg_type, min_e_dmg, max_e_dmg )
    common_cell_apply_damage( target, dmgts )                       -- apply damage in epicentre
    common_freeze_attack( target, spell, freeze, dmgts + 1, duration )
 	  local epicenter = target

  	 for i = 0, 5 do
  	   target = Attack.cell_adjacent( epicenter, i )
      --target = Attack.get_target(i)
      if target ~= nil
      and Attack.cell_present( target )
      and Attack.get_caa( target ) ~= nil
      and not Attack.act_equal( 0, target ) then
        local min_dmg, max_dmg = common_freeze_im_vul( target, min_p_dmg, max_p_dmg )
        Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )   -- set custom damage for periphery
        common_cell_apply_damage( target, dmgts )       -- apply damage
        common_freeze_attack( target, spell, freeze_p, dmgts + 1, duration_p )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Teleport
-- ***********************************************

function spell_teleport_attack()
  local cycle = Attack.get_cycle()

  if (cycle == 0) then
    local target = Attack.get_target()
    Attack.val_store("teleport_source", target)
--    Attack.val_store("teleport_target_cell", Attack.cell_id(target))
    Attack.next(0)
  elseif (cycle == 1) then
    local source = Attack.val_restore("teleport_source")
    local target = Attack.get_target()

    if ((source ~= nil) and (target ~= nil)) then
      Attack.act_aseq(source, "telein")
      Attack.atom_spawn(source, 0, "hll_telein" )
      local t = Attack.aseq_time(source)
      Attack.act_aseq(source, "teleout" )
      Attack.atom_spawn(target, t, "hll_teleout" )
      Attack.act_teleport(source, target, t)
   	  Attack.log("hero_casts_a_spell_2","hero_name",blog_side_unit(source,4)..Attack.hero_name(),"spell","<label=spell_teleport_name>","targeta",blog_side_unit(source,0))
    end
  end

  return true
end


-- ***********************************************
-- * Lightning
-- ***********************************************

function spell_lightning_attack( lvl, dmgts )
 	local target = Attack.get_target()
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, lvl = get_enemy_hero_stuff( lvl )
  end

	 if dmgts == nil then dmgts = 0 end

  local function common_shock( target, spell, dmgts, duration, shock )
    dmgts = dmgts + Game.Random() / 10
   	local shock_rnd = Game.Random( 99 )
    local shock_res = Attack.act_get_res( target, "magic" )

    if Attack.act_is_spell( target, "effect_freeze" ) then
      shock = shock * 2
    end

    local shock_chance = math.min( 100, shock * ( 1 - shock_res / 100 ) )

   	if shock_rnd < shock_chance
    and not Attack.act_feature( target, "golem" ) then
      duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
	  	  effect_shock_attack( target, dmgts, duration )
   	end

    return true
  end

  local spell = "spell_lightning"
 	local min_dmg, max_dmg, shock, count, duration = pwr_lightning( lvl, ehero_level )
 	local dmg_type = Logic.obj_par( spell, "typedmg" )
 	local dmg = Game.Random( min_dmg, max_dmg )
 	Attack.atk_set_damage( dmg_type, dmg )
 	local a = Attack.atom_spawn( target, dmgts, "magic_lightning" )
 	local dmgts1 = Attack.aseq_time( a, "x" )
 	local interval = Attack.aseq_time( "magic_lightning", "z" )
 	common_cell_apply_damage( target, dmgts1 + dmgts )
  common_shock( target, spell, dmgts1 + 1 + dmgts, duration, shock )
	 local attacked_ids = {}
 	attacked_ids[ Attack.cell_id( target ) ] = true
	 local front = { target }

 	repeat

   	if count == 0 then break end

   	count = count - 1
  		dmgts = dmgts + interval
  		dmg = dmg * 0.5

  		local new_front = {}
  		-- Hit the front of the current units
  		for k, target in ipairs( front ) do
   			local mind, atkd = 1e10, {}
  	 		for i = 1, Attack.act_count() - 1 do
  		  		local d = Attack.cell_mdist( target, i )
  				  if d <= 4. * 1.8 + .1
        and ( Attack.act_enemy( i )
        or Attack.act_ally( i ) )
        and Attack.act_applicable( i )
        and Attack.act_takesdmg( i )
  						and attacked_ids[ Attack.cell_id( Attack.get_cell( i ) ) ] == nil then
  					   if math.abs( mind - d ) < .1 then table.insert( atkd, i )
  					   elseif d < mind then mind = d; atkd = { i } end
  				  end
  		  end

  		  for i, act in ipairs( atkd ) do -- We attack those who have chosen
  				  Attack.atk_set_damage( dmg_type, dmg )
  				  local d = math.min( 4, math.max( 1, round( Attack.cell_mdist( target, act ) / 1.8 + .5 ) ) )
  				  local a = Attack.atom_spawn( target, dmgts, "lightning_bolt" .. d .. "hx", Attack.angleto( target,act ) )
    				local dmgts1 = Attack.aseq_time( a, "x" )
    				common_cell_apply_damage( act, dmgts1 + dmgts )
        common_shock( act, spell, dmgts1 + 1 + dmgts, duration, shock )
    				attacked_ids[ Attack.cell_id( Attack.get_cell( act ) ) ] = true
  		  		-- Form the next front
    				table.insert( new_front, act )
  		 	end
  		end

  		front = new_front

 	until table.getn( front ) == 0

	--hll_post_archmage_lighting
	 return true
end

-- ***********************************************
-- * Weakness
-- ***********************************************

function spell_weakness_attack( lvl, dmgts, target )
 	if dmgts == nil then dmgts = 0 end

 	local level = common_get_spell_level( lvl )

  if target == nil then target = Attack.get_target() end

  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local spell = "spell_weakness"
  local duration = int_dur( spell, level, "sp_duration_weakness", nil, ehero_level )

  if target ~= nil  then
    effect_bless_weakness_attack( target, spell, duration, dmgts, "magic_sword", true )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_enemy( i )
      and Attack.act_applicable( i ) then
        effect_bless_weakness_attack( i, spell, duration, 0, "magic_sword", true )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Bless
-- ***********************************************

function spell_bless_attack( level, dmgts, target, belligerent )
 	level = common_get_spell_level( level )

  if target == nil then target = Attack.get_target() end

  local ehero_level

  if dmgts == nil then dmgts = 0 end

--		local healer_bonus = tonumber( Logic.hero_lu_skill( "healer" ) )

--		if healer_bonus > 0 then healer_bonus = 1 end

  local spell = "spell_bless"
  local duration

  local function get_duration( target )
    if target ~= nil then
    		duration = Attack.val_restore( target, "spell_last_hero_bless_duration" )
    end
  
    if duration == nil then
      duration = int_dur( spell, level, "sp_duration_bless", nil, ehero_level )-- + healer_bonus
    end
  
    return duration
  end
  
  if target ~= nil  then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration = get_duration( target )
    effect_bless_weakness_attack( target, spell, duration, dmgts, "magic_bless", true )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration = get_duration( i )
        effect_bless_weakness_attack( i, spell, duration, 0, "magic_bless", true )
      end
    end
  end

  return true
end


-- New common function for applying damage bonuses (or penalties)
function apply_common_damage_bonus( target, bonus, duration )
  local resistances = {}
  local str_resistances = Game.Config( 'resistances' )
  local number_resistances = text_par_count( str_resistances )

  if number_resistances > 1 then
    for j = 1, number_resistances do
      local sub_string = text_dec( str_resistances, j )
      table.insert( resistances, sub_string )
    end
  end

  for i = 1, table.getn( resistances ) do
    local min_damage_current, min_damage_base = Attack.act_get_dmg_min( target, resistances[ i ] )
    local max_damage_current, max_damage_base = Attack.act_get_dmg_max( target, resistances[ i ] )

    if min_damage_base > 0 then
      Attack.act_apply_dmgmin_spell( resistances[ i ], min_damage_base * bonus, 0, 0, duration, false )
      Attack.act_apply_dmgmax_spell( resistances[ i ], max_damage_base * bonus, 0, 0, duration, false )
    end
  end

  return true
end


-- ***********************************************
-- * Pacifism
-- ***********************************************
function spell_pacifism_attack( level, target )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
   	level = common_get_spell_level( level )
    local ehero_level

    if Attack.act_belligerent( target ) ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_pacifism"
    local duration = int_dur( spell, level, "sp_duration_pacifism", nil, ehero_level )
    duration = res_dur( 0.1, target, spell, duration, "magic" )
    local bonus, penalty = pwr_pacifism( level, ehero_level )
    Attack.act_del_spell( target, spell )
    local bhealth, bhealth = Attack.act_get_par( target, "health" )
    local hbonus = bhealth * bonus / 100
    Attack.act_apply_spell_begin( target, spell, duration, false )
    apply_common_damage_bonus( target, -penalty / 100, duration )
    Attack.act_apply_par_spell( "health", hbonus, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_dove", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Defenseless
-- ***********************************************
function spell_defenseless_attack( lvl, dmgts, target )
 	if dmgts == nil then dmgts = 0 end

  local level = common_get_spell_level( lvl )

  if target == nil then target = Attack.get_target() end

  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local spell = "spell_defenseless"
  local duration = int_dur( spell, level, "sp_duration_defenseless", nil, ehero_level )
  local less = pwr_defenseless( level, ehero_level )

  local function common_defenseless_attack( target, spell, duration, less, dmgts )
    dmgts = dmgts + Game.Random() / 10
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_par_spell( "defense", 0, 0, -less, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, "magic_shield", Attack.angleto( target ) )

    return true
  end

  if ( target ~= nil ) then
    common_defenseless_attack( target, spell, duration, less, dmgts )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_enemy( i )
      and Attack.act_applicable( i ) then
        common_defenseless_attack( i, spell, duration, less, dmgts )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Divine Armor
-- ***********************************************

function spell_divine_armor_attack( level, target, belligerent )
  if target == nil then target = Attack.get_target() end

  if (target ~= nil) then
   	level = common_get_spell_level( level )
    local ehero_level
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    local spell = "spell_divine_armor"
    local duration = Attack.val_restore( target, "spell_last_hero_divine_armor_duration" )
		  local resistbonus = Attack.val_restore( target, "spell_last_hero_divine_armor_resistbonus" )

    if duration == nil
    or resistbonus == nil then
      duration = int_dur( spell, level, "sp_duration_divine_armor", nil, ehero_level )
      resistbonus = pwr_divine_armor( level, ehero_level )
    end

    duration = res_dur( 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    local curfire, firebase = Attack.act_get_res( target, "fire" )
    local curphysical, physicalbase = Attack.act_get_res( target, "physical" )
    local curmagic, magicbase = Attack.act_get_res( target, "magic" )
    local curpoison, poisonbase = Attack.act_get_res( target, "poison" )
    local bonfire = resistbonus
    local bonphysical = resistbonus
    local bonmagic = resistbonus
    local bonpoison = resistbonus

    if firebase<bonfire then
      bonfire = bonfire-firebase
    else
      bonfire = 0
    end

    if physicalbase<bonphysical then
      bonphysical = bonphysical-physicalbase
    else
      bonphysical = 0
    end

    if magicbase<bonmagic then
      bonmagic = bonmagic-magicbase
    else
      bonmagic = 0
    end

    if poisonbase<bonpoison then
      bonpoison = bonpoison-poisonbase
    else
      bonpoison = 0
    end

    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_res_spell( "fire", bonfire, 0, 0, duration, false )
    Attack.act_apply_res_spell( "physical", bonphysical, 0, 0, duration, false )
    Attack.act_apply_res_spell( "magic", bonmagic, 0, 0, duration, false )
    Attack.act_apply_res_spell( "poison", bonpoison, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, 0, "magic_armor", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Accuracy
-- ***********************************************
function spell_accuracy_attack( level, target, belligerent )
 	level = common_get_spell_level( level )

  if target == nil then target = Attack.get_target() end

  local belligerent, ehero_level
  local spell = "spell_accuracy"
  local duration, bonus

  local function get_bonus( target )
    if target ~= nil then
    		duration = Attack.val_restore( target, "spell_last_hero_accuracy_duration" )
  		  bonus = Attack.val_restore( target, "spell_last_hero_accuracy_bonus" )
    end
  
    if duration == nil
    or bonus == nil then
      duration = int_dur( spell, level, "sp_duration_accuracy", nil, ehero_level )
      bonus = pwr_accuracy( level, ehero_level )
    end

    return duration, bonus
  end

  local function common_accuracy_attack( target, spell, duration, bonus, spawn )
    local dmgts = Game.Random() / 10
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    apply_common_damage_bonus( target, bonus / 100, duration )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, spawn, Attack.angleto( target ) )

    return true
  end

  if ( target ~= nil ) then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration, bonus = get_bonus( target )
    common_accuracy_attack( target, spell, duration, bonus, "magic_accuracy" )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration, bonus = get_bonus( i )
        common_accuracy_attack( i, spell, duration, bonus, "magic_accuracy" )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Pygmy
-- ***********************************************

function spell_pygmy_attack( lvl, dmgts, target )
 	if dmgts == nil then dmgts = 0 end

  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	local level = common_get_spell_level( lvl )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_pygmy"
    local duration = int_dur( spell, level, "sp_duration_pygmy", nil, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    local unit_level = Attack.act_level( target )

    if unit_level > 4 then
      duration = math.max( duration - 2, 1 )
    end

    local penalty = pwr_pygmy( level, ehero_level )
    local health = Attack.act_get_par( target,"health" )
    local cur_health = Attack.act_hp( target )
    Attack.act_del_spell( target, spell )
		  Attack.act_enable_attack( target, "longattack", false )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_small( target, 1.1 )
    apply_common_damage_bonus( target, -penalty / 100, duration )
    Attack.act_apply_par_spell( "health", -health * penalty / 100, 0, 0, duration, false )
    Attack.act_hp( target, cur_health - cur_health * penalty / 100 )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, "magic_pygmy", Attack.angleto( target ) )
  end

  return true
end

function spell_pygmy_onremove(caa)
 	Attack.act_enable_attack(caa,"longattack")
	 Attack.act_small(caa,1,false)

  return true
end
-- ***********************************************
-- * Blind
-- ***********************************************
function spell_blind_attack( lvl, dmgts, target )
 	if dmgts == nil then dmgts = 0 end

  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	local level = common_get_spell_level( lvl )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_blind"
    local duration = int_dur( spell, level, "sp_duration_blind", nil, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    local unit_level = Attack.act_level( target )

    if unit_level > 4 then
      duration = math.max( duration - 2, 1 )
    end

    Attack.act_apply_spell_begin( target, spell, duration, true )
    Attack.act_skipmove( target, duration )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, dmgts, "magic_blind" )
  end

  return true
end

function spell_blind_attack_onremove(caa)
  Attack.act_skipmove(caa,0)

  return true
end

-- ***********************************************
-- * Reaction
-- ***********************************************
function spell_reaction_attack( level, target, belligerent )
  if target == nil then target = Attack.get_target() end

 	level = common_get_spell_level( level )
  local ehero_level
  local spell = "spell_reaction"
  local duration, moralbonus
  
  local function get_bonus( target )
    if target ~= nil then
  		  duration = Attack.val_restore( target, "spell_last_hero_reaction_duration" )
  		  moralbonus = Attack.val_restore( target, "spell_last_hero_reaction_moralbonus" )
    end
  
    if duration == nil
    or moralbonus == nil then
      duration = int_dur( spell, level, "sp_duration_reaction", nil, ehero_level )
      moralbonus = pwr_warcry( level, ehero_level )
    end

    return duration, moralbonus
  end

  local function common_reaction_attack( target, spell, duration, bonus, spawn )
    local current_value, base_value = Attack.act_get_par( target, "moral" )
    local att_def_bonus, krit_bonus = get_moral_modifier( current_value + bonus, current_value )
    local dmgts = Game.Random() / 10
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    Attack.act_del_spell( target, spell )
    Attack.act_apply_spell_begin( target, spell, duration, false )
    Attack.act_apply_par_spell( "moral", bonus, 0, 0, duration, false)

    if krit_bonus > 0 then
      Attack.act_apply_par_spell( "krit", 0, 0, krit_bonus, duration, false)
    end

    Attack.act_apply_spell_end()
--    Attack.resort()
    Attack.atom_spawn( target, dmgts, spawn, Attack.angleto( target ) )

    return true
  end

  if ( target ~= nil ) then
    belligerent, ehero_level, level = common_get_belligerent( target, belligerent, ehero_level, level )
    duration, moralbonus = get_bonus( target )
    common_reaction_attack( target, spell, duration, moralbonus, "magic_warcry" )
  else
    local acnt = Attack.act_count()
    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i ) then
        belligerent, ehero_level, level = common_get_belligerent( i, belligerent, ehero_level, level )
        duration, moralbonus = get_bonus( i )
        common_reaction_attack( i, spell, duration, moralbonus, "magic_warcry" )
    	 end
    end
 	end

  return true
end

-- ***********************************************
-- * Sacrifice
-- ***********************************************

function spell_sacrifice_attack()
  local cycle = Attack.get_cycle()
 	local level = common_get_spell_level( level )
 	local damage, power = pwr_sacrifice( level )
	 local count, count_1, dead = 0, 0, 0
  local source, target

  if ( cycle == 0 ) then
   	local source = Attack.get_target()
    Attack.val_store( "sacrifice_source", source )
    Attack.val_store( "sacrifice_hp", math.min( damage, Attack.act_totalhp( source ) ) * power / 100 )
    Attack.next( 0 )
  elseif ( cycle == 1 ) then
    source = Attack.val_restore( "sacrifice_source" )
    local magic_shield = Attack.act_is_spell( source, "special_magic_shield" )
    target = Attack.get_target()

    if ( ( source ~= nil )
    and ( target ~= nil ) ) then
    		count = round( Attack.val_restore( "sacrifice_hp" ) / Attack.act_get_par( target, "health" ) )
      local a = Attack.atom_spawn( source, 0, "magic_dagger", Attack.angleto( source ) )
      local dmgts = Attack.aseq_time( a, "x" )
		    Attack.atk_set_damage( "astral", damage, damage )
      common_cell_apply_damage( source, dmgts )
      local b = Attack.atom_spawn( target, dmgts, "hll_priest_resur_cast" )
      local dmgtr = Attack.aseq_time( b, "x" )
     	-- At this point in target with the growths should count the number of units on
				  -- If the victim hanging shield Maga - growth is half as damage to half

				  if magic_shield then count = math.floor( count / 2 ) end

      Attack.act_size( target, Attack.act_size( target ) + count )
      Attack.act_initsize( target, Attack.act_initsize( target ) + count )
    end
  end

  if cycle == 1 then
    damage, dead = Attack.act_damage_results( source )
   	if dead == 0 then
    		Attack.log_label( "null" )
     	Attack.log( "add_blog_ssacr_1", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( source, 3 ) .. "<label=spell_sacrifice_name>", "targeta", blog_side_unit( source, -1 ), "name", blog_side_unit( target, -1 ), "special", damage, "names", count )
    else
      Attack.log( "add_blog_ssacr_2", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( source, 3 ) .. "<label=spell_sacrifice_name>", "targeta", blog_side_unit( source, -1 ), "name", blog_side_unit( target, -1 ), "special", damage, "names", count, "target", dead )
   	end
  end

  return true
end

-- ***********************************************
-- * Geyser
-- ***********************************************

function lerp(x,y,t) return x+(y-x)*t end

function spell_geyser_attack( level, dmgts, target )
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  if dmgts == nil then dmgts = 0 end

  local spell = "spell_geyser"
 	local a = Attack.atom_spawn( Attack.cell_get(), dmgts, "magic_armageddon_spawn" )
	 local spawn_shift = Attack.aseq_time( a, "x" ) + dmgts
 	local min_dmg, max_dmg, count, freeze, stun, duration = pwr_geyser( level, ehero_level )
	 local dmg_type = Logic.obj_par( spell, "typedmg" )
 	--Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)
	 local start_up = Attack.aseq_time( "magic_armageddon", "w" )
 	local end_up   = Attack.aseq_time( "magic_armageddon","x" )
 	local start_down = Attack.aseq_time( "magic_armageddon","y" )
 	local end_down   = Attack.aseq_time( "magic_armageddon","z" )
 	local begin, end_ = 1, Attack.act_count() - 1

 	if target ~= nil then begin = target; end_ = target; count = 1 end

 	for i = begin, end_ do
  		if target ~= nil
    or ( Attack.act_takesdmg( i )
    and Attack.act_applicable( i )
    and Attack.act_enemy( i ) ) then
		    local t = dmgts + Game.Random( 100 ) / 100. - 1.
		   	Attack.atom_spawn( i, t, "magic_armageddon" )
			   local hit_time = t + end_down

   			if not Attack.act_pawn( i ) then
    				local tx, ty, tz = Attack.act_get_center( i ) -- Memorize the initial position
				    Attack.act_move( t + start_up, t + end_up, i, tx, ty, tz + 3 ) -- Raise the enemy
    				Attack.act_rotate( t + end_up, t + start_down, i, Game.Dir2Ang( Attack.act_dir( i ) ) + 2 * math.pi * ( 2 * math.random( 0, 1 ) - 1 ) )
				    --Attack.act_falldown( t+start_up, t+end_up, i, tz+3)
    				local t1 = t + lerp( end_up, start_down, 1/6. )
				    local t2 = t + lerp( end_up, start_down, 3/6. )
    				local t3 = t + lerp( end_up, start_down, 5/6. )
    				Attack.act_move( t+end_up, t1, i, tx, ty, tz + 2.7 )
    				Attack.act_move( t1, t2, i, tx, ty, tz + 3.3 )
    				Attack.act_move( t2, t3, i, tx, ty, tz + 2.7 )
    				Attack.act_move( t3, t + start_down, i, tx, ty, tz + 3 )
    				Attack.act_falldown( t + start_down, hit_time, i, tz ) -- Returns to where he was
   			end

   			if Attack.act_feature( i, "freeze_immunitet" ) then
    				Attack.atk_set_damage( dmg_type, min_dmg * freeze_im, max_dmg * freeze_im )
      else
       	Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
    	 end

   			common_cell_apply_damage( i, hit_time )

   			if not Attack.act_pawn( i ) then
        local dead = Attack.act_damage( i )
        if dead ~= nil then
       			if not dead then
            common_freeze_attack( i, spell, freeze, hit_time + 1, duration )
       			end
    
          local rnd = Game.Random( 99 )
       			local stun_res = Attack.act_get_res( i, "physical" )
          if not dead
          and not Attack.act_feature( i, "plant" )
          and not Attack.act_feature( i, "golem" )
          and rnd < ( math.max( 0, stun - stun_res ) ) then
            effect_stun_attack( i, hit_time + 2, res_dur( hit_time + 2.1, target, spell, duration, "physical" ) )
          end
        end
      end

   			count = count - 1

   			if count == 0 then break end
  		end
	 end

	-- Spawn remaining columns
 	if count > 0 then
	   local free_cells = {}

		  for i = 0, Attack.cell_count() - 1 do
		    local c = Attack.cell_get( i )
		    if Attack.cell_is_pass( c )
      and Attack.cell_is_empty( c ) then
				    table.insert( free_cells, c )
		    end
		  end

  		for i = 1,count do
		    if table.getn( free_cells ) == 0 then break end

		    local n = math.random( 1, table.getn( free_cells ) )
   			Attack.atom_spawn( table.remove( free_cells, n ), Game.Random( 100 ) / 100., "magic_armageddon" )
  		end
	 end

 	return true
end

-- ***********************************************
-- * Ghost Sword
-- ***********************************************

function spell_ghost_sword_attack( lvl, dmgts )
  local target = Attack.get_target()
  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, lvl = get_enemy_hero_stuff( lvl )
  end

		if dmgts == nil then dmgts = 0 end

  local min_dmg, max_dmg, power = pwr_ghost_sword( lvl, ehero_level )
  local dmg_type = Logic.obj_par( "spell_ghost_sword", "typedmg" )

  if target ~= nil then
    Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
    local target = Attack.get_target()
   -- Temporary corrosion
    effect_corrosion_attack( target, 0, power, 2 )
    local a = Attack.atom_spawn( target, dmgts, "magic_blade", Attack.angleto( target ) + 2.5 )
    local dmgts1 = Attack.aseq_time( a, "x" )
  		common_cell_apply_damage( target, dmgts1 + dmgts )
    Attack.act_del_spell( target, "effect_corrosion" )
  end

  -- Sets fire to the unit in 3 moves. He takes damage 1-5 * power and loses 5 +5 * power protection
  --hll_post_archmage_lighting
  return true
end


-- ***********************************************
-- * Phoenix call
-- ***********************************************

function ang_to_nearest_enemy(target, func)
  local nearest_dist, nearest_enemy = 10e10, nil

  for i=1,Attack.act_count()-1 do
   	if func(i) then
    		local d = Attack.cell_dist(target,i)

  	  	if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
   	end
  end

  if nearest_enemy ~= nil then return Attack.angleto(target, nearest_enemy) end
end

function spell_phoenix_call()
  local ehero_level, level
 	level = common_get_spell_level( level )
  local target = Attack.get_target()

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local unit_name = text_dec( Logic.obj_par( "spell_phoenix", "unit_name" ), level )

  for i = 1, Attack.act_count() - 1 do
    if string.sub( actor_name( i ), 1, 7 ) == "phoenix" --[[and Attack.val_restore(i,"lifes")>=0]] and Attack.act_belligerent( i ) == Attack.act_belligerent() then
--[[        local e = 0
	     local fade_time = 1
	     Attack.act_fadeout(i, e, e + fade_time)
    	 Attack.act_remove(i, e + fade_time + .01)]]
	     Attack.act_kill( i, true, false )
    end
  end

  --Find the nearest enemy
  local ang_to_enemy = ang_to_nearest_enemy( target, Attack.act_enemy )

  if ang_to_enemy ~= nil then
   	Attack.act_spawn( target, 0, unit_name, ang_to_enemy )
  else
   	Attack.act_spawn( target, 0, unit_name )
  end

  Attack.val_store( target, "intel", HInt() )
  summon_bonus( target, "spell_phoenix", nil, ehero_level )

  if Attack.act_belligerent() == 1 then -- Think only of their feniksoff
   	Game.GVSNumInc( "units_kupleno", unit_name, 1 )
  end

  Attack.act_aseq( target, "appear" );
  Attack.val_store( target, "lifes", 1 );

  if ehero_level == nil then
    Attack.val_store( target, "ehero_level", 0 );
  else
    Attack.val_store( target, "ehero_level", ehero_level );
  end

  fix_hitback( target )
  apply_hero_attack_defense_bonuses( target )
  Attack.resort( target )
 	Attack.log_label( "null" )
	 Attack.log( "add_blog_phoen", "hero_name", blog_side_unit( target, 4 )..Attack.hero_name(), "targeta", blog_side_unit( target, 0 ) )
--  Attack.atom_spawn(target, 0, "magic_greenfly")

  return true
end

function phoenix_ondamage( wnm, ts, dead )
 	if dead then
    local lifes = Attack.val_restore( 0, "lifes" );

    if lifes == 0 then
		    local e = wnm--ts+Attack.aseq_time(0,"death","")
		    local fade_time = 1
		    Attack.act_fadeout( 0, e, e + fade_time )
	    	Attack.act_remove( 0, e + fade_time + .01 )
	    	--Attack.act_kill(0, true, false)
    end
--    	Attack.val_store(0,"lifes",lifes-1);
 	end

 	return true
end

function phoenix_onmove( tend )
 	if Attack.act_hp( 0 ) <= 0 then
	  	local has_allies = false
  		for i = 1, Attack.act_count() - 1 do
		    if Attack.act_belligerent( i, nil ) == 1
      and Attack.act_hp( i ) > 0 then
		      has_allies = true
		      break
		    end
		  end

  		if not has_allies then
	     Attack.act_kill( 0, true, false )
  		end
 	end

 	return true
end



-- ***********************************************
-- * Phantom
-- ***********************************************

function spell_phantom_attack()
  local cycle = Attack.get_cycle()
 	local target
 	local count=0

  if ( cycle == 0 ) then
    local target = Attack.get_target()
    Attack.val_store( "source_unit", target )
    Attack.next( 0 )
  elseif ( cycle == 1 ) then
    local source = Attack.val_restore( "source_unit" )
   	local level = common_get_spell_level( level )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    target = Attack.get_target()

    --Find the nearest enemy
    local nearest_dist, nearest_enemy = 10e10, nil
    for i = 1, Attack.act_count() - 1 do
     	if Attack.act_enemy( i ) then
      		local d = Attack.cell_dist( target, i )

      		if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
     	end
    end

    local angle = 0

    if nearest_enemy ~= nil then angle = Attack.angleto( target, nearest_enemy ) end

    local spell = "spell_phantom"
    count = round( Attack.act_totalhp( source ) * ( pwr_phantom( level, ehero_level ) / 100 ) / ( Attack.act_get_par( source, "health" ) ) )
    local moves = int_dur( spell, level, "sp_duration_phantom", nil, ehero_level )
--    local moves = text_dec(Logic.obj_par(spell,"duration"),level)
    Attack.act_spawn( target, 0, actor_name( source ), angle, count )
    Attack.act_enable_attack( target, "split", false ); Attack.val_store( target, "clone", 1 )
    Attack.act_enable_attack( target, "transform", false )
  --Attack.act_skipmove(target,-1)
    Attack.resort( target ) -- Immediately went to phantom
  --Attack.act_aseq(target,"appear");
    local effect1 = Attack.atom_spawn( source, 0, "magic_phantom_source" )
    local y = Attack.aseq_time( effect1, "x" )
    local effect2 = Attack.atom_spawn( target, y, "magic_phantom" )
    local x = Attack.aseq_time( effect2, "x" )
   	Attack.act_nodraw( target, true )
   	Attack.act_nodraw( target, false, x + y )
   	Attack.act_transparency( target, .7 )
    fix_hitback( target )
    apply_hero_attack_defense_bonuses( target )
    Attack.act_apply_spell_begin( target, spell, moves, false )
    Attack.act_apply_spell_end()
	--add_blog_sfantom_2
  end
  	--		Attack.log_label("add_blog_sfantom_2") -- Works
	--		Attack.log_special(count)

 	Attack.log_label( "null" )

		if cycle == 1 then
	 		Attack.log( "add_blog_sfantom_2", "hero_name", blog_side_unit( target, 4 ) .. Attack.hero_name(), "spell", blog_side_unit( target, 3 ) .. "<label=spell_phantom_name>", "target", blog_side_unit( target, 0 ), "special", count )
		end

  return true
end

function spell_phantom_onremove(caa)
  if Attack.act_hp(caa) > 0 then Attack.act_kill(caa,false,false) end -- Kill the phantom only when he was alive, and then double poluchaets ¤ ¤ Death

  local t = Attack.aseq_time(caa)
  local fade_time = 2
  Attack.act_fadeout(caa, t, t + fade_time)
		Attack.log(0.001,"add_blog_nophant","name",blog_side_unit(caa))
  Attack.act_remove(caa, t + fade_time + .01)

  return true
end

-- ***********************************************
-- * Kamikaze
-- ***********************************************

function spell_kamikaze_attack()
  local target = Attack.get_target()

  if (target ~= nil) then
   	local level = common_get_spell_level( level )
  		local min_dmg,max_dmg,dur=pwr_kamikaze()
    --Attack.act_del_spell( target, "spell_kamikaze" )
    Attack.act_apply_spell_begin( target, "spell_kamikaze", dur, false )
  		Attack.val_store( target, "min", min_dmg )
  		Attack.val_store( target, "max", max_dmg )
		  Attack.act_attach_atom( target, "kamikazebomb", 0 )
    Attack.act_apply_spell_end()
        --Attack.atom_spawn(target, 0, "magic_lioncup", Attack.angleto(target))
  end

  return true
end

function spell_bomb_explode_attack()
 	local tar = Attack.get_target()
		a = Attack.atom_spawn(tar, 0, "effect_bomb" )
		local dmgts = Attack.aseq_time(a, "x")
		local dmg_type = Logic.obj_par("spell_kamikaze","typedmg")
		--local level = tonumber(Attack.val_restore( "level" ))
  Attack.atk_set_damage(dmg_type,min_dmg/math.max(1,Attack.act_size(0)),max_dmg/math.max(1,Attack.act_size(0)))
  --Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)

  if Attack.act_hp(tar)>0 then
    common_cell_apply_damage(tar, dmgts, true)
			 local count=Attack.act_size(tar)
			 local damage,dead=Attack.act_damage_results(tar)

 			if dead>0 then
	  			local td=""

   			if count==dead then td="<label=troop_defeated>" end

    		Attack.log(0.001,"add_blog_skam_2","damage",damage,"dead",dead,"target",blog_side_unit(tar,-1),"troopdef",td,"name",blog_side_unit(tar,1))
  		else
   			Attack.log(0.001,"add_blog_skam_1","damage",damage,"target",blog_side_unit(tar,-1),"name",blog_side_unit(tar,1))
  		end
		else
		 	Attack.log(0.001,"add_blog_skam_0","name",unit_name)
		end

  for c=0,Attack.cell_count()-1 do
    local i = Attack.cell_get(c)
    if (Attack.act_enemy(i) or Attack.act_ally(i) or Attack.act_pawn(i)) and Attack.cell_dist(tar,i)==1 then
      if Attack.act_applicable(i) and Attack.act_takesdmg(i) then      -- can receive this attack
        common_cell_apply_damage(i, dmgts, true)
      		local count=Attack.act_size(i)
    				local damage,dead=Attack.act_damage_results(i)
    				if damage ~= nil then
--add_blog_skam_2=^blog_td0^[Name]: works bomb and cause [damage] damage. [Target]: [dead] dies. [Troopdef]
      				if dead>0 then
       					local td=""

       	 			if count==dead then td="<label=troop_defeated>" end

    			     Attack.log(0.001,"add_blog_skam_02","damage",damage,"dead",dead,"troopdef",td,"name",blog_side_unit(i,0))
  			     else
  			 	     Attack.log(0.001,"add_blog_skam_01","damage",damage,"name",blog_side_unit(i,0))
  		 	    end
  	 		  end
      end
    end
  end

	return true
end

function spell_kamikaze_onremove(target,duration_end,on_dmg)
	 if duration_end or on_dmg or Attack.act_hp(target) <= 0 then --взрываем бомбу
  		--local cell = Attack.get_cell(0)
  		--local color=blog_side_unit(cell,"arrow")..blog_side_unit(cell,"color")
  		min_dmg=tonumber(Attack.val_restore(target, "min")) --/Attack.act_size(0)
  		max_dmg=tonumber(Attack.val_restore(target, "max")) --/Attack.act_size(0)
  		unit_name=blog_side_unit(target,1)
  		Game.ExecSpell("spell_bomb_explode",Attack.cell_id(Attack.get_cell(target)),nil)
  end

 	Attack.act_deattach_atom( target, "kamikazebomb", 0 )

 	return true
end


-- ***********************************************
-- * Ram
-- ***********************************************

function spell_ram_attack( lvl, dmgts, target, nolog )
 	if dmgts == nil then dmgts = 0 end

  if target == nil then target = Attack.get_target() end

  if ( target ~= nil ) then
   	local level = common_get_spell_level( lvl )
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_ram"
   	local duration = int_dur( spell, level, "sp_duration_ram", nil, ehero_level )
    duration = res_dur( dmgts + 0.1, target, spell, duration, "magic" )
    local unit_level = Attack.act_level( target )

    if unit_level > 4 then
      duration = math.max( duration - 2, 1 )
    end

    takeoff_spells( target, "penalty" )
    takeoff_spells( target, "bonus" )
--		  Attack.act_del_spell( target )
    Attack.act_apply_spell_begin( target, spell, duration, false )--true )
    Attack.act_apply_par_spell("autofight", 1, 0, 0, duration, false )--true)
    Attack.act_apply_par_spell( "hitback", 0, 0, -100, duration, false, 1000 )--true)
    --Attack.act_posthitslave(target, "ram_posthit", duration)
    Attack.act_apply_spell_end()
    --Attack.atom_spawn(target, 0, "magic_lioncup", Attack.angleto(target))
    Attack.val_store( target,"initial_tag", actor_name( target ) )
    local l = 1
   	Attack.act_fadeout( target, 0, l )
    Attack.act_change_tag( target,"ram",l )
   	Attack.atom_spawn( target, 0, "magic_ram" )
    Attack.atom_spawn( target, l - Attack.aseq_time( "magic_ram", "x" ), "magic_ram", Attack.angleto( target ) )
   	Attack.act_fadeout( target, l, l*2, 1 )

    if nolog == nil then
     	Attack.log_label( "add_blog_sram" )
    end
  end

  return true
end

function actor_name( act )
 	local name = Attack.act_name( act )

	 if name == "ram" then return Attack.val_restore( act, "initial_tag" ) end

 	return name
end

function spell_ram_onremove(target,duration_end,on_dmg)
 	local itag = Attack.val_restore(target,"initial_tag")

	 if --[[Attack.act_name(target) == "ram" and]] (not on_dmg and Attack.act_hp(target) > 0) or duration_end then -- возможны след. причины вызова этой ф-ии: конец действия, снятие по удару, диспел и смерть юнита
	   local t = Attack.aseq_time(target)
	   e = t + 1
  		Attack.act_fadeout(target, t, e)
  		t = e
   	Attack.act_change_tag(target, itag, t)
   	Attack.atom_spawn(target, 0, "magic_ram_end")
	   Attack.atom_spawn(target, t - Attack.aseq_time("magic_ram", "x"), "magic_ram_end", Attack.angleto(target))
   	e = t + 1
		  Attack.act_fadeout(target, t, e, 1)
--[[    	if  then
 			Attack.act_animate(target,"death",Attack.aseq_time( itag, "teleout", ))
		end]]-- bracketed comment

		--Attack.log_label("null")

  end

 	if Attack.act_hp(target) > 0 then
    if Attack.act_size(target)>1 then
     	Attack.log(0.001,"add_blog_noram_2","name",blog_side_unit(target,1),"target","<label=cpsn_"..itag..">")
    else
    		Attack.log(0.001,"add_blog_noram_1","name",blog_side_unit(target,1),"target","<label=cpn_"..itag..">")
    end
  end

 	return true
end

function ram_ondmg( wnm, ts, dead )
 	if dead then
	  	local s, l = ts+2, 1
  		local itag = Attack.val_restore(0,"initial_tag")
  		Attack.atk_min_time(s+l--[[+Attack.aseq_time(itag, "death", "")]]+.01)
  		Attack.act_fadeout(0, s, s+l)
  		Attack.atom_spawn(0, s, "magic_ram_end")
  		Attack.act_change_tag(0, itag, s+l)
	   --Attack.atom_spawn(0, s+l - Attack.aseq_time("magic_ram", "x"), "magic_ram_end", Attack.angleto(0))
  		Attack.act_fadeout(0, s+l, s+l*2, 1)
 	end

 	return true
end


-- ***********************************************
-- * Evil Book
-- ***********************************************

function spell_evilbook_attack()
  local target = Attack.get_target()

  if (target ~= nil) then
    local ehero_level, level
   	level = common_get_spell_level( level )

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local atom = "evilbook" .. level
    Attack.act_spawn( target, 0, atom )
    Attack.val_store( target, "intel", HInt() )
    summon_bonus( target, "spell_evilbook", nil, ehero_level )
    Attack.act_animate( target, "appear" )
    fix_hitback( target )
    apply_hero_attack_defense_bonuses( target )
    Attack.resort( target )
  end

  Attack.log_label( "null" )
 	Attack.log( "add_blog_phoen", "hero_name", blog_side_unit( target, 4 )..Attack.hero_name(), "targeta", blog_side_unit( target, 0 ) )

  return true
end

function spell_evilbook_onremove(target,duration_end)
 	if Attack.act_hp(target) > 0 then
	   local t = Attack.aseq_time(target)
	   e = t + 1
  		Attack.act_fadeout(target, t, e)
  		t = e
  		local itag = Attack.val_restore(target,"initial_tag")
   	Attack.act_change_tag(target, itag, t)
   	e = t + 1
  		Attack.act_fadeout(target, t, e, 1)
--[[    	if  then
			 Attack.act_animate(target,"death",Attack.aseq_time( itag, "teleout", ))
		end]]
  end

 	return true
end

function evilbook_ondmg(wnm,ts,dead)
--[[	local s, l = wnm, 1
	 Attack.act_fadeout(target, s, s+l)
  Attack.act_change_tag(target,Attack.val_restore(target,"initial_tag"),s+l)
 	Attack.act_fadeout(target, s+l, s+l*2, 1)]]

 	return true
end

-- ***********************************************
-- * Trap
-- ***********************************************

function spell_trap_attack()
 	local level = common_get_spell_level( level )
 	local target = Attack.get_target()
	 local trap = Attack.atom_spawn( target, 0, "trap" )
 	Attack.act_aseq( trap, "appear" )
 	Attack.cell_set_trap( target, trap )
 	local min_dmg, max_dmg, duration, poison = pwr_trap( level )
 	Attack.val_store( trap, "min", min_dmg )
 	Attack.val_store( trap, "max", max_dmg )
 	Attack.val_store( trap, "level", level )
 	Attack.val_store( trap, "time_last", duration )
 	Attack.val_store( trap, "duration", duration ) -- this is for setting the poison duration
 	Attack.val_store( trap, "poison", poison ) -- this is for setting the poison duration
 	Attack.log_label( "add_blog_trap" )

 	return true
end

function special_trap()
 	local cell = Attack.get_cell( 0 )
 	local color = blog_side_unit( cell, "arrow" ) .. blog_side_unit( cell, "color" )
 	--Attack.atom_spawn(0, 0, "magic_dispel" )
 	local min_dmg = tonumber( Attack.val_restore( "min" ) )
 	local max_dmg = tonumber( Attack.val_restore( "max" ) )
 	local duration = tonumber( Attack.val_restore( "duration" ) )
 	local poison = tonumber( Attack.val_restore( "poison" ) )
 	local dmg_type = Logic.obj_par( "spell_trap", "typedmg" )
 	local level = tonumber( Attack.val_restore( "level" ) )
  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
  local start = 0
  local dmgts = start + Attack.aseq_time( "trap", "death", "x" )
  common_cell_apply_damage( cell, dmgts )
  --Attack.act_kill()
 	Attack.cell_set_trap( cell, nil, start )
  local poison_res = Attack.act_get_res( cell, "poison" )
  local poison_rnd = Game.Random( 99 )
  local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
  local dmg = tonum( Attack.val_restore( cell, "sdmg" ) )
  local poison_damage = dmg * poison_chance / 200

  if poison_rnd < poison_chance
  and not Attack.act_feature( cell, "golem" )
  and not Attack.act_feature( cell, "undead" )
  and not Attack.act_feature( cell, "plant" )
  and not Attack.act_feature( cell, "poison_immunitet" ) then
    duration = res_dur( dmgts + 1.1, cell, "spell_trap", duration, "poison" )
    effect_poison_attack( cell, dmgts + 1, duration, poison_damage, poison_damage )
  end

 	local count = Attack.act_size( cell )
	 local damage, dead = Attack.act_damage_results( cell )
--add_blog_trap_2=^blog_td0^[Spell] activated and causes [damage] damage. [Target]: [dead] dies. [Troopdef]
 	if dead > 0 then
  		local td=""

  		if count == dead then td = "<label=troop_defeated>" end

    Attack.log( "add_blog_trap_2", "spell", color.."<label=spell_trap_name>", "damage", damage, "dead", dead, "target", blog_side_unit( cell, -1 ), "troopdef", td )
  else
   	Attack.log( "add_blog_trap_1", "spell", color.."<label=spell_trap_name>", "damage", damage, "target", blog_side_unit( cell, -1 ) )
  end

 	return true
end

function special_trap_attack()
 	local caa = Attack.get_caa( Attack.get_cell( 0 ) )

 	if caa ~= nil then
  		local mt = Attack.act_mt( caa )

  		if mt == 0 or mt == 2 then special_trap(); return true end
  	end

 	return false
end

function trap_time()
	 --special_trap_attack()
 	totem_time()

 	return true
end

function select_attack0()
 	return Attack.change_attack(0)
end

function select_attack1()
	 return Attack.change_attack(1)
end

-- ***********************************************
-- * Shroud
-- ***********************************************

function spell_shroud_attack()
  local level = common_get_spell_level( level )
  local target, atom = Attack.get_target()

  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local duration = int_dur( "spell_shroud", level, "sp_duration_shroud", nil, ehero_level )
  local penalty  = pwr_shroud( level, ehero_level )
  local cid = Attack.cell_id( Attack.get_cell( target ) )
  for i = 1, Attack.act_count() - 1 do
   	if Attack.act_name( i ) == "shroud"
    and Attack.cell_id( Attack.get_cell( i ) ) == cid then
      if Attack.act_size( i ) <= 0 then break end -- Shroud dead

    		atom = i
  		  break
   	end
  end

  if atom == nil then
   	atom = Attack.atom_spawn(target, 0, "shroud")
   	Attack.act_aseq(atom,"appear")
  end

  Attack.val_store( atom, "belligerent", Attack.act_belligerent() )
  Attack.val_store( atom, "time_last",  duration )
  Attack.val_store( atom, "penalty", penalty )
  Attack.val_store( atom, "power", penalty )

  return true

end

--[[function shroud_mods()

 	local mod = shroud_takeoff()
	 local penalty = Attack.val_restore("penalty")

 	for i=1, Attack.act_count()-1 do
	  	for r=0,Logic.resistance()-1 do
    		Attack.act_attach_dmg_modificator_to_throw_attacks(i, Logic.resistance(r), mod, 0, -penalty)
   	end
  end

 	return true
end

function shroud_takeoff() -- This action removes the veil from all units
	 local mod = Attack.act_name(0)..Attack.act_uid(0)

  for i=1, Attack.act_count()-1 do
   	Attack.act_del_modificator(i, mod, true)
  end

  return mod
end

function shroud_turn()
  local ttl = Attack.val_restore( 0, "moves" )
  ttl = ttl - 1

  if ttl == 0 then
    shroud_takeoff()
    Attack.log("add_blog_nopelena","name",blog_side_unit(0))
   	Attack.act_remove(0, .5)
  else
    Attack.val_store( 0, "moves", ttl )
  end

  return true
end]]

-- ***********************************************
-- * Light power
-- ***********************************************

function spell_light_power_attack()
  local level = common_get_spell_level( level )
  local cure_hp = text_dec( Logic.obj_par( "spell_light_power", "cure_hp" ), level )
  local damage  = text_dec( Logic.obj_par( "spell_light_power", "damage" ), level )
 	local center = Attack.get_target()
  local a = Attack.atom_spawn( center, 0, "magic_fireball" ) -- Need a normal effect
 	local dmgts = Attack.aseq_time( a, "x" )
 	Attack.atk_set_damage( "magic", damage * 2. )

 	for i = 0, 6 do
	   local t = Attack.get_target( i )
	   if t ~= nil
    and ( Attack.act_enemy( t )
    or Attack.act_ally( t ) ) then
		    local race = Attack.act_race( t )
		    if race ~= "undead"
      and race ~= "demon"
      and Attack.act_need_cure( t ) then --Лечение
				    Attack.atom_spawn( t, 0, "effect_total_cure" )
    				Attack.act_cure( t, cure_hp )
		    end
		    if race == "undead" and i == 0 then --Коцаем нежить в центральной клетке
				    common_cell_apply_damage( t, dmgts )
		    end
  		end
 	end

 	Attack.atk_set_damage( "magic", damage ) -- Damage to the outer cells of less
 	local busy_cells = {}

 	for d = 0, 5 do
	   local t = Attack.cell_adjacent( center, d )
	   if t ~= nil
    and ( Attack.act_enemy( t )
    or Attack.act_ally( t ) ) then
		    local race = Attack.act_race( t )
	    	if race == "undead" then
				    common_cell_apply_damage( t, dmgts ) -- коцаем
    				-- Бежим!
	       for k, i in { 6, 5, 7 } do -- определяем, можно ли вообще куда-нить бежать
					     local c = Attack.cell_adjacent( t, math.mod( d + i, 6 ) )
     					if c ~= nil
          and Attack.cell_present( c )
          and Attack.cell_is_empty( c )
          and not busy_cells[ Attack.cell_id( c ) ] then
					       Attack.aseq_rotate( t, c )
      						Attack.aseq_start( t, "start", "move" )
      						Attack.act_aseq( t, "stop" )
   					    busy_cells[ Attack.cell_id( c ) ] = true
   					    break
     					end
	       end
	    	end
  		end
 	end

 	return true
end

-- ***********************************************
-- * Holy Rain
-- ***********************************************

function spell_holy_rain_attack( level, target )
  if target == nil then target = Attack.get_target() end
  local center = target
  local dmg, dmgts = 0, 0
  local spell = "spell_holy_rain"

  if ( target ~= nil ) then
   	level = common_get_spell_level( level )
    local a = Attack.atom_spawn( target, 0, "effect_lightpower" )
    dmgt = Attack.aseq_time( a, "x" )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    local n = Attack.get_targets_count()

    for i = 0, n - 1 do
      local tgt = Attack.get_target( i )

      if tgt ~= nil then
        local min_dmg, max_dmg, holy, duration = pwr_holy_rain( level, Attack.act_race( tgt, "undead" ) )
  
        if Attack.act_enemy( tgt )
        or Attack.act_ally( tgt ) then
          if (Attack.act_race( tgt, "undead" ) ) then
            Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
            local b = Attack.atom_spawn( tgt, dmgt, "effect_hard_bless" )
            dmgs = Attack.aseq_time( b, "x" )
            common_cell_apply_damage( tgt, dmgt + dmgs )
  							   effect_holy_attack( tgt, dmgt + dmgs + 0.1, res_dur( dmgt + dmgs + 0.2, tgt, spell, duration, "magic" ), holy )
          elseif ( Attack.cell_need_resurrect( tgt ) )
          and not ( Attack.act_race( tgt, "demon" ) )
          and not ( Attack.act_is_spell( tgt, "special_summon_bonus" ) )
          and Attack.act_ally( tgt ) then
            local rephits = round( Game.Random( min_dmg, max_dmg ) )
   	        local count_1, count, hp = Attack.act_size( tgt ), 0, Attack.act_hp( tgt )
            Attack.atom_spawn( tgt, dmgt, "hll_priest_resur_cast" )
            Attack.cell_resurrect( tgt, rephits )
            local count_2 = Attack.act_size( tgt )

            if count_2 > count_1 then count = count_2 - count_1 end
        
            if count_2 < count_1 then count = count_2 end
        
           	local N
        
            if Attack.act_size( tgt ) > 1 then N = '2' else N = '1' end
        
            local heroname = blog_side_unit( tgt, 4 ) .. Attack.hero_name()
            
            if count_1 == count_2 then
           	 	Attack.log( dmgt + 0.5, "add_blog_sheal_" .. N, "hero_name", heroname, "spell", blog_side_unit( tgt, 3 ) .. "<label=spell_holy_rain_name>", "special", Attack.act_hp( tgt ) - hp, "target", blog_side_unit( tgt, -1 ) )
          	 else
             	Attack.log( dmgt + 0.5, "add_blog_sres_"  .. N, "hero_name", heroname, "spell", blog_side_unit( tgt, 3 ) .. "<label=spell_holy_rain_name>", "special", count, "target", blog_side_unit( tgt, -1 ) )
            end
          end
        end
      end
    end
  end

 	local busy_cells = {}

 	for d = 0, 5 do
	   local t = Attack.cell_adjacent( center, d )
	   if t ~= nil
    and ( Attack.act_enemy( t )
    or Attack.act_ally( t ) ) then
		    local race = Attack.act_race( t )
	    	if race == "undead"
      and Attack.act_get_par( t, "dismove" ) == 0 then
       	--			common_cell_apply_damage(t, dmgts) -- коцаем
    				-- Run!
	    	  for k, i in { 6, 5, 7 } do -- Determines whether you can do anywhere thread running
     					local c = Attack.cell_adjacent( t, math.mod( d + i, 6 ) )
     					if c ~= nil
          and Attack.cell_present( c )
          and Attack.cell_is_pass( c )
          and Attack.cell_is_empty( c )
          and not busy_cells[ Attack.cell_id( c ) ] then
   					    Attack.aseq_rotate( t, c )
      						Attack.aseq_start( t, "start", "move" )
      						Attack.act_aseq( t, "stop", false, true )
						      Attack.act_damage_addlog( t, "add_blog_run_" )
   					    busy_cells[ Attack.cell_id( c ) ] = true
			   		    break
     					end
	       end
	    	end
  		end
 	end

  return true
end

-- ***********************************************
-- * Invisibility
-- ***********************************************

function spell_invisibility( level, target, belligerent )
 	if target == nil then target = Attack.get_target() end

 	level = common_get_spell_level( level )
  local ehero_level

  local loggg = 1

  if belligerent == nil then
    belligerent = Attack.act_belligerent( target )
  else
    loggg = 0
  end

  if belligerent ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

 	for i = 1, Attack.act_count() - 1 do -- Remove all their invisibility
	   if Attack.act_ally( i ) then
 		  	Attack.act_del_spell( i, "spell_invisibility" )
	  	end
 	end

  local spell = "spell_invisibility"
  local duration = Attack.val_restore( target, "spell_last_hero_invisibility_duration" )

  if duration == nil then
    duration = int_dur( spell, level, "sp_duration_invisibility", nil, ehero_level )
  end

  duration = res_dur( 0.1, target, spell, duration, "magic" )
  Attack.act_apply_spell_begin( target, spell, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_transparency( target, .5 )
 	Attack.atom_spawn( target, 0, "magic_invisi" )
 	Attack.act_onattack( target, "spell_invisibility_onatack" )

  if loggg == 1 then
    if Attack.act_size( target ) > 1 then
    		Attack.log_label( "add_blog_sinvis_2" )
    else
    		Attack.log_label( "add_blog_sinvis_1" )
    end
  end

	 return true
end


function spell_invisibility_onremove(target,duration_end)
  if Attack.act_hp(target) <= 0 then return true end

  Attack.act_transparency(target, 1.)
  Attack.act_fadeout(target, 0., 1., 1., .5)
  Attack.act_onattack(target, "")

  if Attack.act_size(target)>1 then
   	Attack.log("add_blog_noinvis_2","name",blog_side_unit(target,1))
  else
  	 Attack.log("add_blog_noinvis_1","name",blog_side_unit(target,1))
  end

  return true
end

function spell_invisibility_onatack()
	 Attack.act_del_spell( 0, "spell_invisibility" )

 	return true
end

-- ***********************************************
-- * Demonologist
-- ***********************************************

function spell_demonologist()
 	local target = Attack.get_target()

  local ehero_level, level
 	level = common_get_spell_level( level )

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

  local lead, time = pwr_demonologist( level, ehero_level )
  local unit = Logic.obj_par( "spell_demonologist", "units" .. level )
  local par_count = text_par_count( unit )
  unit = text_dec( unit, Game.Random( 1, par_count ) )
	 local a = Attack.atom_spawn( target, 0, "demon_portal" )
 	Attack.act_aseq( a, "appear" )
 	Attack.val_store( a, "belligerent", Attack.act_belligerent() )
 	Attack.val_store( a, "time", time )
 	Attack.val_store( a, "unit", unit )
 	Attack.val_store( a, "count", math.ceil( lead / Attack.atom_getpar( unit, "leadership" ) ) )
	 Attack.cell_passability( target, 2 ) -- Forbidden to walk on this cage
 	Attack.log_label( "add_blog_demongate" )

	 return true
end

function demon_portal()
 	local time = tonumber( Attack.val_restore( "time" ) ) - 1
 	if time <= 0 then
	  	Attack.act_kill()
	  	local x = Attack.aseq_time( 0, "x" )
	  	local y = Attack.aseq_time( 0, "y" )
	  	local z = Attack.aseq_time( 0, "z" )
	  	local count = tonumber( Attack.val_restore( "count" ) )
    local unit = Attack.val_restore( "unit" )
	  	Attack.act_spawn( 0, Attack.val_restore( "belligerent" ), unit, 0, count )
	  	local target = Attack.get_caa( Attack.get_cell( 0 ) )
	  	Attack.act_nodraw( target, true )
	  	Attack.act_nodraw( target, false, x )
	  	local tx, ty, tz = Attack.act_get_center( target )
	  	Attack.act_move( 0, 0.1, target, tx, ty, tz - 1.2 * ( 1 + ( Attack.act_level( target ) - 2 ) * 0.3 ) ) -- поднимаем врага
	  	Attack.act_move( x, y, target, tx,ty,tz ) -- поднимаем врага
	  	Attack.act_fadeout( target, x, y, 0.5, 0 )
	  	Attack.act_fadeout( target, y, z, 1, 0.5 )
	  	local bel = Attack.val_restore( "belligerent" )
	  	Attack.act_belligerent( target, bel )
	  	--Attack.act_ap(target,Attack.act_get_par(target,"speed"))
	  	Attack.resort( target )
    fix_hitback( target )
    apply_hero_attack_defense_bonuses( target )
	  	Attack.cell_passability( 0, 0 )
	  	Attack.log( "add_blog_demon_summon_" .. loadstring ( "if " .. count .. ">1 then return 2 else return 1 end" )(),	"name", blog_side_unit( target, 2, bel ) .. blog_side_unit( target, 3, bel ), "target", blog_side_unit( target, 0, bel ), "special", count )
 	else
	  	Attack.val_store( "time", time )
 	end

	 return true
end

-- ***********************************************
-- * Tactics
-- ***********************************************

function spell_army_disposition()
 	local target = Attack.get_target()
 	local cycle = Attack.get_cycle()

 	if cycle == 0 then
  		Attack.val_store("source", Attack.get_target())
  		Attack.next(0)
 	else
  		local source = Attack.val_restore("source")
		  if Attack.get_caa(source) ~= nil then
		    local target = Attack.get_target()
   			local effect1 = Attack.atom_spawn(source, 0, "effect_unit_out", 0)
   			local effect2 = Attack.atom_spawn(target, 0, "effect_unit_in", 0)
			   Attack.act_teleport(source, target, 0)
  		end
 	end

	 return true
end

-- ***********************************************
-- * Armageddon
-- ***********************************************

function spell_armageddon_attack()
  local ccnt, cx, cy = Attack.cell_count(), 0, 0
  for i = 0, ccnt - 1 do
    local c = Attack.cell_get( i )
    local x,y = Attack.act_get_center( c )
    cx = cx + x
    cy = cy + y
  end

  local center = Attack.find_nearest_cell( cx / ccnt, cy / ccnt )

  if ( center ~= nil and Attack.cell_present( center ) ) then
    local ehero_level, level
   	level = common_get_spell_level( level )
  
    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local spell = "spell_armageddon"
   	local level = common_get_spell_level( level )
   	local min_dmg, max_dmg, burn, duration, prc = pwr_armageddon( level, ehero_level )
    local dmg_type = Logic.obj_par( spell, "typedmg" )
    local y = Attack.aseq_time( "magic_fireaxle", "y" )
    local z = Attack.aseq_time( "magic_fireaxle", "z" )

   	for i = 0, ccnt - 1 do
    		local c = Attack.cell_get( i )
    		local d = Attack.cell_dist( center, c )
    		local atom, t

    		if d == 0 then
        atom = "magic_fireaxle"
        t = 0
      else
        atom = "magic_fireground_"..math.random( 1, 3 )
        t = z + y * ( d - 1 )
      end

    		local a = Attack.atom_spawn( c, t, atom, Game.Dir2Ang( math.random( 0,5 ) ) )
    		local dmgts = Attack.aseq_time( a, "x" ) + t

   			if Attack.act_ally( c ) then
    				-- Attack.atk_set_damage(dmg_type,min_dmg/2,max_dmg/2)
    				Attack.atk_set_damage( dmg_type, round( min_dmg / 100 * prc / 5 ) * 5, round( max_dmg / 100 * prc / 5 ) * 5 )
   			else
			    	Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
   			end

    		if common_cell_apply_damage( c, dmgts ) then
        common_fire_burn_attack( c, burn, dmgts + 1, duration, nil, nil, spell )
    		end
    end
  end

  return true
end
