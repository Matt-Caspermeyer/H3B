-- New function for checking to see if bonus to duration should be applied
function apply_hero_duration_bonus( target, duration, bonus, to_ally )
  if target == nil then
    target = Attack.get_target()
  end

  if target ~= nil then
    local ally = 2
    local enemy = 4
    local belligerent_base = Attack.act_belligerent()
    local belligerent_target = Attack.act_belligerent( target )
    local enemy_base = Attack.act_enemy( target, belligerent_base )
    local enemy_target = Attack.act_enemy( target, belligerent_target )
    local ally_base = Attack.act_ally( target, belligerent_base )
    local ally_target = Attack.act_ally( target, belligerent_target )
  
    if to_ally then
      if ( not ( belligerent_target == enemy ) and ally_target )
      or ( belligerent_target == ally ) then
        duration = duration + Logic.hero_lu_item( bonus, "count" )
      end
    else
      if ( not ( belligerent_base == enemy ) and enemy_target )
      or ( belligerent_target == enemy ) then
        duration = duration + Logic.hero_lu_item( bonus, "count" )
      end
    end
  end

  return duration
end

function effect_fear_onremove( caa )
	 local target = Attack.get_target()

 	if target == nil then target = 0 end 

 	if Attack.act_size( caa ) > 1 then
  		Attack.log( caa, 0.001, "add_blog_nofear_2", "name", blog_side_unit( target, 1 ) )
 	else
	  	Attack.log( caa, 0.001, "add_blog_nofear_1", "name", blog_side_unit( target, 1 ) )
 	end 

  return true
end

-- ***********************************************
-- * New! Entangle
-- ***********************************************
function effect_entangle_attack( target, pause, duration )
  if pause == nil then
    pause = 0.5
  end

  if target == nil then
    target = Attack.get_target()
  end

  if ( Attack.act_ally( target )
  or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
   	if duration == nil then
	    	duration = tonumber( Logic.obj_par( "effect_entangle", "duration" ) )
    end 

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_entangle", false )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_entangle" ) )
    local current_init, base_init = Attack.act_get_par( target, "initiative" )
    local penalty = math.floor( math.max( current_init / 2, base_init / 2 ) )
    local message

    if duration_old ~=nil
    and duration_old ~= 0 then
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_snarl_"
    else
      message = "add_blog_entangle_"
    end

    Attack.act_del_spell( target, "effect_entangle" )
    Attack.act_apply_spell_begin( target, "effect_entangle", duration, false )
    Attack.act_apply_par_spell( "dismove", 1, 0, 0, duration, false )
    Attack.act_apply_par_spell( "initiative", -penalty, 0, 0, duration, false)
    Attack.act_apply_spell_end()
 		 Attack.act_damage_addlog( target, message )
    Attack.atom_spawn( target, pause, "magic_slow", 0, true )
  end

  return true
end

-- New function for applying the bless or weakness bonus
function apply_bless_weakness_bonus( target, bonus, duration )
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

    if min_damage_base > 0 then
      if bonus > 0 then
        Attack.act_apply_dmgmax_spell( resistances[ i ], bonus, 0, 0, duration, false )
      else
        Attack.act_apply_dmgmin_spell( resistances[ i ], bonus, 0, 0, duration, false )
      end
    end
  end

  return true
end

-- New function for applying the bless effect with a hero bonus
function effect_bless_weakness_attack( target, spell, duration, dmgts, spawn_type, spawn )
  duration = res_dur( target, spell, duration, "magic" )
  Attack.act_del_spell( target, "spell_bless" )
  Attack.act_del_spell( target, "spell_weakness" )

  -- Only remove effect_weakness if casting bless, casting weakness has no effect on the similar
  -- effect_weakness cast by certain units on attack (see effect_weakness_attack)
  if string.find( spell, "bless" ) then
    Attack.act_del_spell( target, "effect_weakness" )
  end

  Attack.act_apply_spell_begin( target, spell, duration, false )

  local bonus = tonumber( Logic.hero_lu_item( string.gsub( spell, "spell_", "sp_add_damage_" ), "count" ) )

  if string.find( spell, "weakness" ) then
    bonus = -bonus
  end

  local healer = tonumber( Logic.obj_par( spell, "healer" ) )
  local sp_healer = 0
  if healer == 1
  and string.find( spell, "bless" ) then
    sp_healer = math.max( 0, tonumber( Logic.hero_lu_skill( "healer" ) ) - 2 ) -- +1 for level 3
  end

  local necromancy = tonumber( Logic.obj_par( spell, "necromancy" ) )
  local sp_necromancy = 0
  if necromancy == 1
  and string.find( spell, "weakness" ) then
	  	sp_necromancy = math.max( 0, tonumber( Logic.hero_lu_skill( "necromancy" ) ) - 2 ) -- -1 for level 3
  end

  if bonus == nil then
    bonus = 0
  end

  bonus = bonus + sp_healer - sp_necromancy

  if bonus ~= nil
  and bonus ~= 0 then
    apply_bless_weakness_bonus( target, bonus, duration )
  end

  Attack.act_apply_spell_end()

  if spawn then
    dmgts = dmgts + Game.Random() / 10
    Attack.atom_spawn( target, dmgts, spawn_type, Attack.angleto( target ) )
  end

  return true
end


-- New function for applying damage effect
function apply_effect_damage( target, min_dmg, max_dmg, effect_type, log_damname, res_type, log_resname )
  local unit_resist_log = false

  if Attack.get_caa( target ) == nil then return true end
  
  if target ~= nil then
    local dmg_min, dmg_max

    if min_dmg == nil then
    		dmg_min = tonumber( Attack.act_spell_param( target, effect_type, "dmg_min" ) )
    else
      dmg_min = min_dmg
    end
  
    if max_dmg == nil then
    		dmg_max = tonumber( Attack.act_spell_param( target, effect_type, "dmg_max" ) )
    else
      dmg_max = max_dmg
    end
  
    if dmg_min ~= nil
    and dmg_max ~= nil then
      local typedmg = Logic.obj_par( effect_type, "typedmg" )
    		-- при получении юнитов урона огнем спадает Очарование 
     	Attack.act_del_spell( target, "effect_charm" )
    		Attack.atk_set_damage( typedmg, dmg_min, dmg_max )
      -- Each successive burn causes half damage
     	Attack.act_spell_param( target, effect_type, "dmg_min", dmg_min / 2, "dmg_max", dmg_max / 2 )
    		Attack.atom_spawn( target, 0, effect_type, 0 ,true )
    		common_cell_apply_damage( target, 1 )
      -- New! The unit's resistance allows it to potentially remove the effect
      local effect_resist_chance = Attack.act_get_res( target, res_type )
      local effect_rnd = Game.Random( 100 ) + 1
  
      if effect_rnd <= effect_resist_chance then
        Attack.act_del_spell( target, effect_type )
        unit_resist_log = true
      end
  
      local count = Attack.act_size( target )
      local damage, dead = Attack.act_damage_results( target )
      
      if dead == nil then dead = 0 end
      
      local td = ""
  
      if damage ~= nil then
        if dead > 0 then
       	  if count == dead then td = "<label=troop_defeated>" end
      
       	  Attack.log( "add_blog_" .. log_damname .. "_2", "damage", damage, "dead", dead, "name", blog_side_unit( target, -1 ), "troopdef", td )
        else
          local duration = tonumber( Attack.act_spell_duration( target, effect_type ) )
  
          if duration ~= nil and duration > 3 then
        				Attack.log( "add_blog_" .. log_damname .. "_3", "damage", damage, "dead", dead, "name", blog_side_unit( target, -1 ), "troopdef", td )
          else
        				Attack.log( "add_blog_" .. log_damname .. "_1", "damage", damage, "dead", dead, "name", blog_side_unit( target, -1 ), "troopdef", td )
          end
       	end 
      end 
    
      if unit_resist_log then
        show_unit_resist_log( count, target, log_resname )
      end
    end
  end

  return true
end


-- New function for effect resist log
function show_unit_resist_log( count, target, log_resname )
  if target ~= nil then
    if count > 1 then
      Attack.log( "add_blog_res_" .. log_resname .. "_2", "name", blog_side_unit( target, -1 ) )
    else
      Attack.log( "add_blog_res_" .. log_resname .. "_1", "name", blog_side_unit( target, -1 ) )
    end
  end

  return true
end
-- ***********************************************
-- * Corrosion
-- ***********************************************
function effect_corrosion_attack( target, pause, power, duration, options )
        -- options = 0/1 (базовый или текущий)
  if pause == nil then
    pause=1
  end

  if Attack.act_ally( target )
  or Attack.act_enemy( target ) then
    local resist,resistbase = Attack.act_get_res( target, "physical" )
    local change_resist = 0
-- нет обработки не иммунитет и высокую сопротивляемость. На металл обработки тоже нет из-за Секиры и Меча
    if duration == nil then
      duration = tonumber( Logic.obj_par( "effect_corrosion", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_corrosion", false )

    if power == nil then
      power = tonumber( Logic.obj_par( "effect_corrosion", "power" ) )
    end

    if power > 100 then power = 100 end

    if options == nil then options = 0 end

    if options == 0 then
      change_resist = power * resist / 100
    else
      change_resist = power * resistbase / 100
    end

-- коррозии складываются!
--    Attack.act_del_spell(target,"effect_corrosion")
    Attack.act_apply_spell_begin( target, "effect_corrosion", duration, false )
    Attack.act_apply_res_spell( "physical", -change_resist, 0, 0, duration, false )
    Attack.act_apply_spell_end()

--    Attack.atom_spawn(target, pause, "effect_poison")
  end

  return true
end

-- ***********************************************
-- * Shock
-- ***********************************************
function effect_shock_attack( target, pause, duration )
  if pause == nil then
    pause = 1
  end

  if target == nil then
    target = Attack.get_target()
  end

  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
    local inbonus = tonumber( Logic.obj_par( "effect_shock", "inbonus" ) )

    if duration == nil then
      duration = tonumber( Logic.obj_par( "effect_shock", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_shock", false )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_shock" ) )
  
    local message
    if duration_old ~=nil and duration_old ~= 0 then
      if duration_old - duration > 0 then
        inbonus = inbonus + duration_old - duration
      end
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_jolt_"
    else
      message = "add_blog_shock_"
    end

    Attack.act_del_spell( target, "effect_shock" )
    Attack.act_apply_spell_begin( target, "effect_shock", duration, false )
    Attack.act_apply_par_spell( "initiative", -inbonus, 0, 0, duration, false )
    Attack.act_apply_par_spell( "speed", -100 , 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.resort()
  		Attack.atom_spawn( target, pause, "hll_post_archmage_lighting", 0, true )
  		Attack.act_damage_addlog( target, message )
  end

  return true
end

-- ***********************************************
-- * Святая аура на нежити
-- ***********************************************

function effect_holy_attack( target, pause, duration, power )
  if power == nil then power = tonumber( Logic.obj_par( "effect_holy", "power" ) ) end  -- назначаем бонус

  if duration == nil then
    duration = tonumber( Logic.obj_par( "effect_holy", "duration" ) )
  else
    duration = tonumber( duration )
  end 

  duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_holy", false )

		if pause==nil then pause=0 end 

 	if target==nil then
    target = Attack.get_target()
  end
		
  local duration_old = tonumber( Attack.act_spell_duration( target, "effect_holy" ) )

  local message
  if duration_old ~=nil and duration_old ~= 0 then
    duration = math.max( duration, duration_old ) + 1
    power = math.min( 80, power + duration )
    message = "add_blog_sanctified_"
  else
    message = "add_blog_holy_"
  end

		Attack.act_del_spell( target, "effect_holy" )
  Attack.act_apply_spell_begin( target, "effect_holy", duration, false )
		Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
		Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_damage_addlog( target, message )
		Attack.atom_spawn( target, pause, "effect_hard_bless", 0, true )

  return true
end

-- ***********************************************
-- * Sleep
-- ***********************************************
function effect_sleep_attack( target, pause, duration, dod )
  if pause == nil then
    pause = 1
  end

  if dod == nil then
    dod = true
  end

 	if target ~= nil then
    if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "boss,pawn" ) then
      if duration == nil then
        duration = tonumber( Logic.obj_par( "effect_sleep", "duration") )
      end

      duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_sleep", false )
      local power = tonumber( Logic.obj_par( "effect_sleep", "power" ) )
      Attack.act_apply_spell_begin( target, "effect_sleep", duration, dod )
      Attack.act_apply_par_spell( "defense", 0, 0, -power, duration, false )
   			Attack.act_skipmove( target, duration )
      Attack.act_apply_spell_end()
      Attack.atom_spawn( target, pause, "effect_sleep", Attack.angleto( target ), true )
    end
  else
    if target == nil then
    		target = Attack.get_target()
    		if Attack.act_need_cure( target )
      and string.find( Attack.act_name( target ),"bear" ) then
    			 local cur_hp = Attack.act_hp( target )
     			local max_hp = Attack.act_get_par( target ,"health" )
     			local need_cure = max_hp - cur_hp
     			Attack.act_cure( target, need_cure )
     			Attack.atom_spawn( target, 0, "effect_total_cure" )
    		end 
    end
  end

  return true
end

function sleep_onremove( caa, duration_end )
		Attack.act_skipmove( caa, 0 )

		if duration_end ~= true then --and not Attack.act_is_spell(caa,"effect_sleep") then 
  		if Attack.act_size( caa ) > 1 then 
  		  Attack.log( caa, 0.002, "add_blog_nosleep_2", "name", blog_side_unit( caa ) )
  		else 
  		  Attack.log( caa, 0.002, "add_blog_nosleep_1", "name", blog_side_unit( caa ) )
  		end 
		end 

 	return true
end

-- ***********************************************
-- * Unconscious
-- ***********************************************
function effect_unconscious_attack( target, pause, duration )
  if pause == nil then
    pause = 1
  end

  local dod = false

 	if target ~= nil then
    if ( Attack.act_ally( target )
    or Attack.act_enemy( target ) )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "plant" )
    and not Attack.act_feature( target, "undead" )
    and not Attack.act_feature( target, "boss,pawn" ) then
      if duration == nil then
        duration = tonumber( Logic.obj_par( "effect_unconscious", "duration") )
      end

      local duration_old = tonumber( Attack.act_spell_duration( target, "effect_unconscious" ) )
    
      if duration_old ~=nil
      and duration_old ~= 0 then
        duration = math.max( duration, duration_old ) + 1
      end

      if Attack.act_is_spell( target, "effect_stun" ) then
        duration = duration + 1
        local duration_stun = tonumber( Attack.act_spell_duration( target, "effect_stun" ) )
        Attack.act_del_spell( target, "effect_stun" )
        Attack.val_store( target, "duration_stun", duration_stun )
      end

      duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_unconscious", false )
      local power = tonumber( Logic.obj_par( "effect_unconscious", "power" ) )
      Attack.act_apply_spell_begin( target, "effect_unconscious", duration, dod )
      Attack.act_apply_par_spell( "defense", 0, 0, -power, duration, false )
      Attack.act_apply_par_spell( "hitback", 0, 0, -100, duration, false, 1000 )--true)
   			Attack.act_skipmove( target, duration )
      Attack.act_apply_spell_end()
      Attack.atom_spawn( target, pause, "effect_sleep", Attack.angleto( target ), true )
    end
  end

  return true
end

function unconscious_onremove( caa, duration_end )
		Attack.act_skipmove( caa, 0 )

		if duration_end ~= true then
  		if Attack.act_size( caa ) > 1 then 
  		  Attack.log( caa, 0.002, "add_blog_nosleep_2", "name", blog_side_unit( caa ) )
  		else 
  		  Attack.log( caa, 0.002, "add_blog_nosleep_1", "name", blog_side_unit( caa ) )
  		end 
  else
    local duration = 3
    local duration_stun = Attack.val_restore( caa, "duration_stun" )

    if duration_stun ~= nil then
      duration = duration + duration_stun
    end

    effect_stun_attack( caa, 1, duration )
    
  		if Attack.act_size( caa ) > 1 then 
  		  Attack.log( caa, 0.002, "add_blog_nounconscious_2", "name", blog_side_unit( caa ) )
  		else 
  		  Attack.log( caa, 0.002, "add_blog_nounconscious_1", "name", blog_side_unit( caa ) )
  		end
		end 

 	return true
end

-- ***********************************************
-- * Slow
-- ***********************************************
function effect_slow_attack( target, pause, duration )
  if pause == nil then
    pause = 1
  end

  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
    if duration == 0
    or duration == nil then
      duration = tonumber( Logic.obj_par( "effect_slow", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_slow", false )

    local speedbonus = tonumber( Logic.obj_par( "effect_slow", "speedbonus" ) )
    local speed = Attack.act_get_par( target, "speed" )

    --if speed == 1 then speedbonus = 0 end

    Attack.act_del_spell( target, "spell_haste" )
    Attack.act_del_spell( target, "spell_slow" )
    Attack.act_apply_spell_begin( target, "spell_slow", duration, false )
    Attack.act_apply_par_spell( "speed", -speedbonus , 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.act_damage_addlog( target, "add_blog_slow_" )
    Attack.atom_spawn( target, pause, "magic_slow", 0, true )
  end

  return true

end

-- ***********************************************
-- * Poison
-- ***********************************************
function effect_poison_attack( target, pause, duration, min_dmg, max_dmg )
  if pause == nil then
    pause=1
  end

 	if target ~= nil
  and --[[(Attack.act_ally(target) or Attack.act_enemy(target))]] Attack.get_caa( target ) ~= nil then
    local poisonresist = Attack.act_get_res( target, "poison" )
    if ( poisonresist < 80 )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "undead" )
    and not Attack.act_feature( target, "plant" )
    and not Attack.act_feature( target, "boss,poison_immunitet" ) then
      if duration == nil then
        duration = tonumber( Logic.obj_par( "effect_poison", "duration" ) )
      end

      duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_poison", false )

      local power = tonumber( Logic.obj_par( "effect_poison", "power" ) )
      local attack = Attack.act_get_par( target, "attack" )

      local dmg_min, dmg_max
      if min_dmg == nil or max_dmg == nil then
      	 dmg_min, dmg_max = text_range_dec( Logic.obj_par( "effect_poison", "damage" ) )
      else
        dmg_min, dmg_max  = min_dmg, max_dmg
      end

      dmg_min = dmg_min * ( 1 + poisonresist / ( 100 - poisonresist ) )
      dmg_max = dmg_max * ( 1 + poisonresist / ( 100 - poisonresist ) )

      local dmg_min_old, dmg_max_old, duration_old
      dmg_min_old = tonumber( Attack.act_spell_param( target, "effect_poison", "dmg_min" ) )
      dmg_max_old = tonumber( Attack.act_spell_param( target, "effect_poison", "dmg_max" ) )
      duration_old = tonumber( Attack.act_spell_duration( target, "effect_poison" ) )

      if dmg_min_old ~= nil then
        dmg_min = dmg_min + dmg_min_old
      end

      if dmg_max_old ~= nil then
        dmg_max = dmg_max + dmg_max_old
      end

      local message
      if duration_old ~=nil and duration_old ~= 0 then
        if duration_old - duration > 0 then
          power = power + duration_old - duration
        end

        duration = math.max( duration, duration_old ) + 1
        message = "add_blog_noxious_"
      else
        message = "add_blog_poison_"
      end

      Attack.act_del_spell( target, "effect_poison" )
      Attack.act_apply_spell_begin( target, "effect_poison", duration, false )
      Attack.act_apply_par_spell( "attack", -attack / 100 * power , 0, 0, duration, false )
      Attack.act_apply_spell_end()
   	  Attack.act_spell_param( target, "effect_poison", "dmg_min", dmg_min, "dmg_max", dmg_max )
      Attack.atom_spawn( target, pause, "effect_poison", 0, true )
      Attack.act_damage_addlog( target, message )
    end
  else
    if target == nil then
      apply_effect_damage( Attack.get_target(), min_dmg, max_dmg, "effect_poison", "dampoison", "poison", "poison" )
    end
  end

  return true
end


-- ***********************************************
-- * Burn
-- ***********************************************
function effect_burn_attack( target, pause, duration, min_dmg, max_dmg )
  --local target = Attack.get_target()
	 if pause==nil then
		  pause=1
	 end
	
 	if target ~= nil
  and Attack.get_caa( target ) ~= nil then
  		local fireresist = Attack.act_get_res( target, "fire" )
  		if fireresist < 80
    and not string.find( Attack.act_name( target ), "orb" )
    and not string.find( Attack.act_name( target ), "cyclop" )
    and not Attack.act_feature( target, "boss,fire_immunitet" ) then
   			if duration == nil then
    				duration = tonumber( Logic.obj_par( "effect_burn", "duration" ) )
   			end

      duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_burn", false )

   			local power = tonumber (Logic.obj_par( "effect_burn", "power" ) )
   			local defense = Attack.act_get_par( target, "defense" )

      local dmg_min, dmg_max
      if min_dmg == nil or max_dmg == nil then
     			dmg_min, dmg_max = text_range_dec( Logic.obj_par( "effect_burn", "damage" ) )
      else
        dmg_min, dmg_max = min_dmg, max_dmg
      end

      dmg_min = dmg_min * ( 1 + fireresist / ( 100 - fireresist ) )
      dmg_max = dmg_max * ( 1 + fireresist / ( 100 - fireresist ) )

      local dmg_min_old, dmg_max_old, duration_old
      dmg_min_old = tonumber( Attack.act_spell_param( target, "effect_burn", "dmg_min" ) )
      dmg_max_old = tonumber( Attack.act_spell_param( target, "effect_burn", "dmg_max" ) )
      duration_old = tonumber( Attack.act_spell_duration( target, "effect_burn" ) )

      if dmg_min_old ~= nil then
        dmg_min = dmg_min + dmg_min_old
      end

      if dmg_max_old ~= nil then
        dmg_max = dmg_max + dmg_max_old
      end

      local message
      if duration_old ~=nil and duration_old ~= 0 then
        if duration_old - duration > 0 then
          power = power + duration_old - duration
        end
        duration = math.max( duration, duration_old ) + 1
        message = "add_blog_ablaze_"
      else
        message = "add_blog_burn_"
      end

   			Attack.act_del_spell( target, "effect_burn" )
   			Attack.act_apply_spell_begin( target, "effect_burn", duration, false )
   			Attack.act_apply_par_spell( "defense", -defense / 100 * power , 0, 0, duration, false)
   			Attack.act_apply_spell_end()
   			Attack.act_spell_param( target, "effect_burn", "dmg_min", dmg_min, "dmg_max", dmg_max )
   			Attack.atom_spawn( target, pause, "effect_burn", 0, true )
   			Attack.act_damage_addlog( target, message )
  		end
 	else
    if target == nil then
      apply_effect_damage( Attack.get_target(), min_dmg, max_dmg, "effect_burn", "damfire", "fire", "burn" )
  	 end
	 end

 	return true
end

-- ***********************************************
-- * Stun
-- ***********************************************
function effect_stun_attack( target, pause, duration )
  --local target = Attack.get_target()
  if pause == nil then
    pause = 1
  end

  if target == nil then
    target = Attack.get_target()
  end

  if ( Attack.act_ally( target )
  or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "undead" )
  and not Attack.act_feature( target, "plant" )
  and not Attack.act_feature( target, "boss,pawn" ) then
    local inbonus = tonumber( Logic.obj_par( "effect_stun", "inbonus" ) )
    local speedbonus = tonumber( Logic.obj_par( "effect_stun", "speedbonus" ) )

   	if duration == nil then
	    	duration = tonumber( Logic.obj_par( "effect_stun", "duration" ) )
   	end 

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_stun", false )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_stun" ) )
  
    local message
    if duration_old ~=nil
    and duration_old ~= 0 then
      if duration_old - duration > 0 then
        inbonus = inbonus + duration_old - duration
        speedbonus = speedbonus + duration_old - duration
      end
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_daze_"
    else
      message = "add_blog_stun_"
    end

    Attack.act_del_spell( target, "effect_stun" )
    Attack.act_apply_spell_begin( target, "effect_stun", duration, false )
    Attack.act_apply_par_spell( "disreload", 10, 0, 0, duration, false )
    Attack.act_apply_par_spell( "disspec", 10, 0, 0, duration, false )
    Attack.act_apply_par_spell( "initiative", -inbonus, 0, 0, duration, false )
    Attack.act_apply_par_spell( "speed", -speedbonus , 0, 0, duration, false )
    Attack.act_apply_spell_end()
 		 Attack.act_damage_addlog( target, message )
    Attack.atom_spawn( target, pause, "effect_stun", 0, true )
  end

  return true
end

-- ***********************************************
-- * Weakness
-- ***********************************************
function effect_weakness_attack( target, pause, duration )
  --local target = Attack.get_target()
  if pause == nil then
    pause = 1
  end

  if target == nil then
    target = Attack.get_target()
  end

  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
   	if duration == nil then
	    	duration = tonumber( Logic.obj_par( "effect_weakness", "duration" ) )
    end 

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_weakness", false )
    local power = tonumber( Logic.obj_par( "effect_weakness", "power" ) )
    power = power + Logic.hero_lu_item( "sp_power_effect_weakness", "count" )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_weakness" ) )

    local message
    if duration_old ~=nil and duration_old ~= 0 then
      if duration_old - duration > 0 then
        power = math.min( 80, power + duration_old - duration )
      end
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_weaker_"
    else
      message = "add_blog_weakness_"
    end

    Attack.act_del_spell( target, "effect_weakness" )
    Attack.act_apply_spell_begin( target, "effect_weakness", duration, false )
    Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
    Attack.act_apply_spell_end()
 		 Attack.act_damage_addlog( target, message )
    Attack.atom_spawn( target, pause, "effect_weakness", 0, true )
  end

  return true
end

-- ***********************************************
-- * Freeze
-- ***********************************************
function effect_freeze_attack(target,pause,duration)
--  local target = Attack.get_target()
  if pause==nil then
    pause=1
  end

  if target==nil then
    target = Attack.get_target()
  end

  if Attack.get_caa(target) == nil then return true end

  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
    if duration == 0
    or duration == nil then
      duration = tonumber( Logic.obj_par( "effect_freeze", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_freeze", false )
    local speedbonus = tonumber( Logic.obj_par( "effect_freeze", "speedbonus" ) )
    local speed = Attack.act_get_par( target, "speed" )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_freeze" ) )
  
    local message
    if duration_old ~=nil and duration_old ~= 0 then
      if duration_old - duration > 0 then
        speedbonus = speedbonus + duration_old - duration
      end
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_bitter_"
    else
      message = "add_blog_freeze_"
    end

    Attack.resort()
    Attack.act_del_spell( target, "effect_freeze" )
    Attack.act_apply_spell_begin( target, "effect_freeze", duration, false )
    Attack.act_apply_par_spell( "speed", -speedbonus , 0, 0, duration, false )
    Attack.act_apply_par_spell( "initiative", -100, 0, 0, duration, false )
    Attack.act_apply_spell_end()
  		Attack.act_damage_addlog( target, message )
    Attack.atom_spawn( target, pause, "effect_freeze", 0, true )
  end

  return true

end

-- ***********************************************
-- * Curse 
-- ***********************************************
function effect_curse_attack( target, pause, duration )
  --local target = Attack.get_target()
  if pause == nil then
    pause = 0
  end

  if target == nil then
    target = Attack.get_target()
  end

  local power = tonumber( Logic.obj_par( "effect_curse", "power" ) )
  
  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn" ) then
   	if duration == nil then
      duration = tonumber( Logic.obj_par( "effect_curse", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_curse", false )
    local duration_old = tonumber( Attack.act_spell_duration( target, "effect_curse" ) )
  
    local message
    if duration_old ~=nil and duration_old ~= 0 then
      if duration_old - duration > 0 then
        power = math.min( 80, power + duration_old - duration )
      end
      duration = math.max( duration, duration_old ) + 1
      message = "add_blog_execrate_"
    else
      message = "add_blog_curse_"
    end

    Attack.act_del_spell( target, "effect_curse" )
    Attack.act_apply_spell_begin( target, "effect_curse", duration, false )
 			Attack.act_apply_par_spell( "moral", -power, 0, 0, duration, false )
    Attack.act_apply_spell_end()
	 		Attack.act_damage_addlog( target, message )
    Attack.atom_spawn( target, pause, "effect_curse", 0, true )
  end

  return true
end

-- ***********************************************
-- * Charm
-- ***********************************************
function effect_charm_attack( target, pause, duration, effect )

  --local target = Attack.get_target()
  if pause == nil then pause = 1 end

  if target == nil then target = Attack.get_target() end

  if effect==nil then effect="effect_charm" end 
  
  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "boss,pawn,mind_immunitet" ) then
    if duration == nil then duration = tonumber( Logic.obj_par( "effect_charm", "duration" ) ) end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_charm", false )
    Attack.act_del_spell( target, "effect_charm" )
    Attack.act_apply_spell_begin( target, "effect_charm", duration, false )
 			Attack.act_spell_param( target, "effect_charm", "effect", effect )
    Attack.act_apply_spell_end()
    local bl = Attack.act_belligerent()
    if bl == 0 then bl = 4 end
    Attack.act_belligerent( target, bl )
    Attack.atom_spawn(target, pause, effect, Attack.angleto(target), true)

    return true
  end

  return false
end

function effect_charm_onremove(caa)

  -- возвращаем все как было
  Attack.act_belligerent(caa, Attack.act_belligerent( caa, nil ))
  --local effect = Attack.act_spell_param(caa, "effect_charm", "effect")
  --if effect==nil then effect = "effect_charm" end 
  --Attack.atom_spawn(caa, 1, effect, 0, true)

			if Attack.act_size(caa)>1 then 
				Attack.log(caa,0.001,"add_blog_nocharm_2","name",blog_side_unit(caa))
			else 
				Attack.log(caa,0.001,"add_blog_nocharm_1","name",blog_side_unit(caa))
			end 

  return true

end

-- ***********************************************
-- * Shock
-- ***********************************************
function effect_blood_attack( target, pause, duration )
  --local target = Attack.get_target()
  if pause == nil then
    pause = 1
  end

  if target == nil then
    target = Attack.get_target()
  end

  if ( Attack.act_ally( target ) or Attack.act_enemy( target ) )
  and not Attack.act_feature( target, "boss,pawn" ) then
    if duration == nil then
      duration = tonumber( Logic.obj_par( "effect_blood", "duration" ) )
    end

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_effect_blood", true )
    local inbonus = tonumber( Logic.obj_par( "effect_blood", "inbonus" ) )
    local moral = tonumber( Logic.obj_par( "effect_blood", "moral" ) )
    Attack.act_del_spell( target, "effect_blood" )
    Attack.act_apply_spell_begin( target, "effect_blood", duration, false )
    Attack.act_apply_par_spell( "initiative", inbonus, 0, 0, duration, false )
    Attack.act_apply_par_spell( "moral", moral, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.atom_spawn( target, pause, "magic_haste" )
  end

  return true
end

-- ***********************************************
-- * OOC
-- ***********************************************
function effect_ooc()

	for i=0,Attack.get_targets_count()-1 do
		local target = Attack.get_target(i)
		Attack.atom_spawn(target, 0, "effect_out_of_control", 0)
		Attack.log(.01, "out_of_control_log", "special", "<label=cpsn_"..Attack.act_name(target)..">")
	end

	return true

end

function effect_buc()

	for i=0,Attack.get_targets_count()-1 do
		local target = Attack.get_target(i)
		Attack.atom_spawn(target, 0, "effect_control", 0)
		Attack.log(.01, "return_control_log", "special", "<label=cpsn_"..Attack.act_name(target)..">")
	end

	return true

end

function effect_temp_ooc( target, damage )
 	local duration = tonumber( Logic.obj_par( "effect_temp_ooc", "duration" ) )

  if duration == nil then duration = -100 end 

  if Attack.act_temporary( target ) then
    local hero_leadership = Logic.hero_lu_item( "leadership", "count" )
    local target_leadership = Attack.act_leadership( target )
    local target_name = Attack.act_name( target )
    local target_lead_bonus = Logic.hero_lu_item( "sp_lead_unit_" .. target_name, "count" )
    local total_leadership_units = math.floor( hero_leadership / ( target_leadership * ( 1 - target_lead_bonus / 100 ) ) )
    local target_size = Attack.act_size( target )

    if damage ~= nil then
      damage = round( damage )
      local target_health = Attack.act_get_par( target, "health" )
      local target_hp = Attack.act_hp( target )
      local killed = math.floor( damage / target_health )
      
      if modulo( damage, target_health ) >= target_hp then
        killed = killed + 1
      end

      target_size = target_size - killed
    end
  
    if target_size > total_leadership_units
    and Attack.act_belligerent( target ) == 1 then
    		Attack.act_belligerent( target, 16 )
      Attack.act_attach_modificator( target, "autofight", "temp_ooc", 1, 0, 0, duration, true, 100 )
		    Attack.atom_spawn( target, 0, "effect_out_of_control", 0 )
      Attack.act_posthitmaster( target, "posthitmaster_effect_temp_ooc", duration )
      Attack.act_posthitslave( target, "posthitslave_effect_temp_ooc", duration )
		    Attack.log( .01, "out_of_control_log", "special", "<label=cpsn_" .. target_name .. ">" )
    elseif target_size <= total_leadership_units
    and Attack.act_belligerent( target ) == 16 then
      Attack.act_belligerent( target, Attack.act_belligerent( target, nil ) )
      Attack.act_del_modificator( target, "temp_ooc" )
      Attack.act_posthitmaster( target, "posthitmaster_effect_temp_ooc", 0 )
      Attack.act_posthitslave( target, "posthitslave_effect_temp_ooc", 0 )
      Attack.act_attach_modificator( target, "hitback", "temp_ooc_hitback", 0, 0, -100, -100, false, 1000, true )
		    Attack.atom_spawn( target, 0, "effect_control", 0 )
		    Attack.log( .01, "return_control_log", "special", "<label=cpsn_" .. target_name .. ">" )
    end
  end 

  return true
end


function posthitmaster_effect_temp_ooc( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and hitbacking then
    effect_temp_ooc( attacker )
  end 

  return damage, addrage
end


function posthitslave_effect_temp_ooc( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0 then
    effect_temp_ooc( receiver, damage )
  end 

  return damage, addrage
end
