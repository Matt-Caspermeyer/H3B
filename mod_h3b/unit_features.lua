-- New function for adding a bonus to % of chance to inflict an effect
function effect_chance( value, effect_or_feature, kind )
  local bonus = tonumber( Logic.hero_lu_item( "sp_chance_" .. effect_or_feature .. "_" .. kind, "count" ) )

  if bonus ~= nil then
    value = value + bonus
  end

  return value
end


-- New Ogre Attack
function features_ogre_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking then
    local receiver_level = Attack.act_level( receiver )
    local stun = tonumber( Attack.get_custom_param( "stun" ) )
    local stun_inc = tonumber( Attack.get_custom_param( "stun_inc" ) )
    local stun_chance = stun + ( receiver_level - 1 ) * stun_inc
    local receiver_res = Attack.act_get_res( receiver, "physical" )
    stun_chance = stun_chance * ( 1 - receiver_res / 100 )
    local rnd = Game.Random( 100 )
  
    if damage > 0
    and ( ( rnd < stun_chance
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "undead" ) )
    or Attack.act_is_spell( receiver, "effect_stun" ) ) then
      local sleep = tonumber( Attack.get_custom_param( "sleep" ) )
      local sleep_inc = tonumber( Attack.get_custom_param( "sleep_inc" ) )
      local sleep_chance = sleep + ( 5 - receiver_level ) * sleep_inc

      if Attack.act_is_spell( receiver, "effect_stun" ) then
        sleep_chance = sleep_chance + 10
      end

      sleep_chance = sleep_chance * ( 1 - receiver_res / 100 )
      rnd = Game.Random( 100 )
  
      if rnd < sleep_chance then
        local duration = 1
     			effect_unconscious_attack( receiver, 1, duration )
     			Attack.act_damage_addlog( receiver, "add_blog_unconscious_" )
      else
        local duration = 2
      	 effect_stun_attack( receiver, 1, duration )
      end
    end
  end 

  return damage, addrage
end


-- New Archdemon Attack
function features_archdemon_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking then
    if damage > 0
    and not Attack.act_feature( receiver, "magic_immunitet" )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and not Attack.act_is_spell( receiver, "spell_ram" ) then
      local tmp_spells = {}
  
      if not Attack.act_is_spell( receiver, "spell_scare" )
      and not Attack.act_feature( receiver, "mind_immunitet" )
      and not Attack.act_feature( receiver, "undead" ) then
        table.insert( tmp_spells, spell_scare_attack )
      end
      
      if not Attack.act_is_spell( receiver, "spell_defenseless" ) then
        table.insert( tmp_spells, spell_defenseless_attack )
      end
  
      if not Attack.act_is_spell( receiver, "spell_magic_bondage" )
      and not Attack.act_feature( receiver, "mind_immunitet" ) then
        table.insert( tmp_spells, spell_magic_bondage_attack )
      end
      
      if table.getn( tmp_spells ) > 0 then
        Attack.act_aseq( 0, "cast" )
        local dmgts = Attack.aseq_time( 0, "x" )
        local cast = Game.Random( 1, table.getn( tmp_spells ) )
        local spell_level = 3
      
        if tmp_spells[ cast ] == spell_magic_bondage_attack then
          tmp_spells[ cast ]( spell_level, receiver )
        else
          tmp_spells[ cast ]( spell_level, dmgts, receiver )
        end
      
    		  Attack.log( dmgts + 0.2, "add_blog_archdemon_attack", "name", blog_side_unit( attacker, 1 ), "target", blog_side_unit( receiver, 0 ) )
      end
    end
  end 

  return damage, addrage
end


-- New Bone Dragon Attack
function features_bonedragon_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking then
    local receiver_level = Attack.act_level( receiver )
    local chance = tonumber( Attack.get_custom_param( "chance" ) )
    local receiver_chance = ( 5 - receiver_level ) * chance
    local rnd = Game.Random( 100 )
    local poison = tonumber( Attack.get_custom_param( "poison" ) )
  
    if rnd < receiver_chance
    and damage > 0
    and poison == 0
    and not Attack.act_feature( receiver, "magic_immunitet" )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and not Attack.act_is_spell( receiver, "spell_ram" ) then
      local tmp_spells = {}

      if not Attack.act_is_spell( receiver, "spell_scare" )
      and not Attack.act_feature( receiver, "mind_immunitet" )
      and not Attack.act_feature( receiver, "undead" ) then
        table.insert( tmp_spells, spell_scare_attack )
      end

      if not Attack.act_is_spell( receiver, "spell_plague" )
      and not Attack.act_feature( receiver, "demon" )
      and not Attack.act_feature( receiver, "plant" ) then
        table.insert( tmp_spells, spell_plague_attack )
      end

      if not Attack.act_is_spell( receiver, "spell_weakness" )
      and not Attack.act_feature( receiver, "plant" )
      and not Attack.act_feature( receiver, "undead" ) then
        table.insert( tmp_spells, spell_weakness_attack )
      end

      if not Attack.act_is_spell( receiver, "spell_crue_fate" )
      and Attack.act_name( receiver ) ~= "vampire2" then
        table.insert( tmp_spells, spell_crue_fate_attack )
      end

      if not Attack.act_is_spell( receiver, "spell_ram" )
      and not Attack.act_feature( receiver, "plant" )
      and not Attack.act_feature( receiver, "undead" ) then
        table.insert( tmp_spells, spell_ram_attack )
      end

      if not Attack.act_is_spell( receiver, "effect_curse" )
      and not Attack.act_feature( receiver, "plant" )
      and not Attack.act_feature( receiver, "undead" ) then
        table.insert( tmp_spells, effect_curse_attack )
      end

      if table.getn( tmp_spells ) > 0 then
        Attack.act_aseq( 0, "cast" )
        local dmgts = Attack.aseq_time( 0, "x" )
        local cast = Game.Random( 1, table.getn( tmp_spells ) )
        local spell_level = 3
  
        if tmp_spells[ cast ] == spell_plague_attack then
          tmp_spells[ cast ]( receiver, spell_level, dmgts )
        elseif tmp_spells[ cast ] == effect_curse_attack then
          tmp_spells[ cast ]( receiver, 1, 3 )
        else
          tmp_spells[ cast ]( spell_level, dmgts, receiver )
        end
  
  				  Attack.log( dmgts + 0.2, "add_blog_bonedragon_attack", "name", blog_side_unit( attacker, 1 ), "target", blog_side_unit( receiver, 0 ) )
      end
    end
  end 

  return damage, addrage
end


-- New Ent Entangle
function features_entangle( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 ) then
    local entangle = tonumber( Attack.get_custom_param( "entangle" ) )
    entangle = effect_chance( entangle, "effect", "entangle" )
    local rnd = Game.Random( 100 )
  
    if rnd < entangle
    and not Attack.act_feature( receiver, "golem" )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and Attack.act_level( receiver ) < 5 then
      effect_entangle_attack( receiver, 1, duration )
    end
  end 

  return damage, addrage
end


-- New Ent Tree of Life Tap
function features_treeoflifetap()
	 for s = 0, Attack.act_spell_count( 0 ) - 1 do
		  local spell_name = Attack.act_spell_name( 0, s )

    if spell_name == "special_rooted" then
      features_auto_dispell( 0 )
      features_regeneration()

      return true
    end
  end

  return false
end


-- New Shaman Dancing Axes Titan Energy Dissapation
function features_dissipate_energy()
  local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )

  if titan_energy > 0 then
    local power = 80
    local stored_energy = math.floor( titan_energy * power / 100 )
    Attack.val_store( 0, "titan_energy", stored_energy )
    local count = "1"

    if stored_energy > 1 then
      count = "2"
    end

    if stored_energy > 0 then
      Attack.log( 0, "add_blog_rte_" .. count, "name", blog_side_unit( 0, 1 ), "special", stored_energy )
    else
      Attack.log( 0, "add_blog_dte", "name", blog_side_unit( 0, 1 ) )
    end
  end

  return true
end


-- New on remove of Tree of Life Tap, enable running
function features_rooted_onremove( caa )
  Attack.act_enable_attack( caa, "run" )

  return true
end


function features_looter(damage,addrage,attacker,receiver,minmax,userdata,hitbacking)
	
	if (minmax==0) then
	local gold=10 -- 
	local damage,dead=Attack.act_damage_results(receiver)	
	if dead~=nil then 
  if dead>0 and Attack.act_human(receiver)	 then
  	local lead=Attack.act_leadership(receiver)
  	local cost=math.ceil(dead*lead*gold/100)
  	local cur_gold=Logic.hero_lu_item("money","count")
  	Logic.hero_lu_item("money","count",cur_gold+cost)
  	
  	Attack.log(.01, "looter_log", "special", cost)
  end   
  end 
  end
   
  return damage,addrage
end

function features_increase_anger( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if ( minmax == 0 )
  and not hitbacking then
    local bonus = tonumber( Logic.obj_par( "feat_increase_anger", "power" ) ) -- назначаем бонус
    local krit_bonus = tonumber( Logic.obj_par( "feat_increase_anger", "krit_bonus" ) ) -- назначаем бонус
    local duration = tonumber( Logic.obj_par( "feat_increase_anger", "duration" ) )
    duration = apply_hero_duration_bonus( attacker, duration, "sp_duration_feat_increase_anger", true )
    local cur_bonus = 0
    local cur_krit_bonus = 0
    
  		if Attack.act_is_spell( attacker, "feat_increase_anger" ) then -- если спелл висит, ищем от него бонусы
    	 cur_bonus = tonumber( Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus" ) )
     	cur_krit_bonus = tonumber( Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus" ) )
    end 
    
    if cur_bonus == nil then cur_bonus = 0 end 

    if cur_krit_bonus == nil then cur_bonus = 0 end 

    if cur_bonus < 15 then 
     	-- потом докладываем спелл, в нем меняем бонус и атаку
		   	Attack.act_del_spell( attacker, "feat_increase_anger" )
      Attack.act_apply_spell_begin( attacker, "feat_increase_anger", duration, false )
  				Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus", bonus + cur_bonus )
				--Attack.act_apply_par_spell("attack", bonus+cur_bonus, 0, 0, 1, false)
  				Attack.act_apply_dmg_spell( "physical", bonus + cur_bonus, 0, 0, duration, false )
  				Attack.act_apply_par_spell( "krit", krit_bonus + cur_krit_bonus, 0, 0, duration, false )
      Attack.act_apply_spell_end()
 			  Attack.act_damage_addlog( receiver, "add_blog_anger_", true )
 			  Attack.log_special( blog_side_unit( attacker, -1 ) ) -- работает  
    end
  end 
  
  return damage,addrage
end

function features_brutality( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 and Attack.get_caa( attacker ) ~= nil ) then -- если это не спелл
    local bonus = Game.Random( text_range_dec( Logic.obj_par( "feat_brutality", "power" ) ) ) -- назначаем бонус
    local duration = tonumber( Logic.obj_par( "feat_brutality", "duration" ) )
    duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_brutality", true )
    local cur_bonus = 0
    
  		if not Attack.act_is_spell( receiver, "feat_brutality" )
    and not hitbacking then -- если спелл висит, ищем от него бонусы
      Attack.act_apply_spell_begin( receiver, "feat_brutality", duration, false )
  				Attack.act_apply_par_spell( "attack", 0, bonus, 0, duration, false )
      Attack.act_apply_spell_end()
   			Attack.atom_spawn( receiver, 0, "effect_brutality", Attack.angleto( receiver ), true )
    		local dmg, dead = Attack.act_damage_results( receiver )
    		if dead ~= Attack.act_size( receiver ) then
       	if Attack.act_size( receiver ) > 1 then 
       			Attack.log( receiver, 0.001, "add_blog_brutality_2", "special", blog_side_unit( attacker, 2 )..blog_side_unit( attacker,3 )..blog_side_unit( receiver, -1 ).."</color>" )
      		else
       			Attack.log( receiver, 0.001, "add_blog_brutality_1", "special", blog_side_unit( attacker, 2 )..blog_side_unit( attacker,3 )..blog_side_unit( receiver, -1 ).."</color>" )
      		end 
    		end 
    end   
  end    

  return damage, addrage
end


function features_soul_drain( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 )
  and damage > 0 then
	   if Attack.act_enemy( receiver )
    and not ( Attack.act_feature( receiver, "undead" ) )
    and not ( Attack.act_feature( receiver, "plant" ) )
    and not ( Attack.act_feature( receiver, "golem" ) )
    and not ( Attack.act_feature( receiver, "pawn" ) ) then
      local k = tonumber( Attack.get_custom_param( "k" ) )
  
      if k > 0 then 
        local health = AU.health( receiver )
        local unit_count = AU.unitcount( receiver )
        local total_hp = Attack.act_totalhp( receiver )
        local remaining_hp = total_hp - round( damage )
        local remaining_count = remaining_hp / health
        local add_unit = math.min( unit_count, math.floor( unit_count - remaining_count ), math.floor( damage * k / 100 / AU.health( attacker ) ) ) -- сколько закилято

        if add_unit > 0 then
          local attacker_count = AU.unitcount( attacker )
          local heal_unit = add_unit * AU.health( attacker )  -- на сколько лечения осталось
        		Attack.act_size( attacker, attacker_count + add_unit )
  	 	     Attack.act_cure( attacker, heal_unit, 1 )
       	  Attack.atom_spawn( attacker, 0, "effect_total_cure" )
       		 local log_msg = "add_blog_soul_"
  	     	 local special = add_unit
  	 		    Attack.act_damage_addlog( receiver, log_msg, true )
  	 		    Attack.log_special( special ) -- работает  
        end
     	end 
   	end 
	 end 

  return damage,addrage
end


function features_vampirism( damage, addrage, attacker, receiver, minmax ) -- minmax, равный 1 или 2 означает, что функция вызывается только для определения мин/макс урона во всп.подсказке
  if minmax == 0
  and damage > 0 then
    -- сколько хитов у вампов
  	 if --[[Attack.act_need_cure(attacker) or ]]Attack.cell_need_resurrect( attacker ) then
    	 if Attack.act_enemy( receiver )
      and not ( Attack.act_feature( receiver,"undead" ) )
      and not ( Attack.act_feature( receiver, "plant" ) )
      and not ( Attack.act_feature( receiver, "golem" ) )
      and not ( Attack.act_feature( receiver, "pawn" ) ) then
    			 local count_1 = Attack.act_size( attacker )
    	   local vamp = math.min( Attack.act_totalhp( receiver ), damage )
    	   local hp1 = Attack.act_totalhp( attacker )
     	  Attack.act_resurrect( attacker, math.floor( vamp +.5 ) )
     	  local count_2 = Attack.act_size( attacker )
       	Attack.atom_spawn( attacker, 0, "effect_total_cure" )
        local log_msg = "add_blog_vamp_"
      		local special = count_2 - count_1
    
        if count_2 == count_1  then
          log_msg = log_msg .. "0"
          special = Attack.act_totalhp( attacker ) - hp1
        end
    
    	   Attack.act_damage_addlog( receiver, log_msg, true )
    	   Attack.log_special( special ) -- работает  
      end 
    end
  end

  return damage,addrage
end


function features_fire_shield( damage,addrage,attacker,receiver,minmax )
  if (minmax==0) then
    --local receiver=Attack.get_target(1)  -- кого?
    --local attacker=Attack.get_target(0)  -- кто?
    -- сколько хитов у вампов
    local min_dmg,max_dmg
   	if receiver~= nil then
--	if Attack.cell_dist(attacker,receiver)==1 then
     	if Attack.act_name(receiver)=="cerberus" then
      		min_dmg,max_dmg=text_range_dec(Logic.obj_par("feat_fire_shield","cerberus"))
     	else 
      		min_dmg,max_dmg=text_range_dec(Logic.obj_par("feat_fire_shield","phoenix"))
      end
      local count=Attack.act_size(receiver)
      local dmg_type = Logic.obj_par("feat_fire_shield","typedmg")
--    if Attack.act_need_cure(attacker) then
--     Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)
     --local a = Attack.atom_spawn(receiver, 0, "magic_haste")
      local dmgts = Attack.aseq_time(a, "x")
--     common_cell_apply_damage(attacker, dmgts)
--    end
--    end
    end
 	end

  return damage,addrage
end


function features_shock( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 ) and damage > 0 then
  --local receiver=Attack.get_target(1)  -- кого?
    local shock = nil
  
    if Attack.act_name( attacker ) == "archmage"
    and Attack.act_is_spell( attacker, "special_battle_mage" ) then
     	shock = tonumber( Attack.act_spell_param( attacker, "special_battle_mage", "shock" ) )
    end 

    if shock == nil then shock = tonumber( Attack.get_custom_param( "shock" ) ) end

    shock = effect_chance( shock, "effect", "shock" )
    local rnd = Game.Random( 100 )
          
    if rnd < shock
    and not Attack.act_feature( receiver, "golem" )
    and Attack.act_level( receiver ) < 5
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then 
      effect_shock_attack( receiver, 1, duration )
    end
  end 

  return damage, addrage
end


function features_poison( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0 then
    --local receiver=Attack.get_target(1)  -- кого?
    local poison = tonumber( Attack.get_custom_param( "poison" ) )
    poison = effect_chance( poison, "effect", "poison" )
    local poison_res = Attack.act_get_res( receiver, "poison" )
    local rnd = Game.Random( 100 )
    
    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local poison_damage = damage * poison_chance / 200
    if rnd < poison_chance
    and not Attack.act_feature( receiver, "golem" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      effect_poison_attack( receiver, 0, 3, poison_damage, poison_damage )
    end
  end 

  return damage, addrage
end

-- ***********************************************
-- * Stun
-- ***********************************************

function features_stun( damage, addrage, attacker, receiver, minmax )
 	if ( minmax == 0 ) and damage > 0 then
   	local stun = tonum( Attack.get_custom_param( "stun" ) )

    if stun < 100 then
      local receiver_level = Attack.act_level( receiver )
      stun = stun + ( 4 - receiver_level ) * stun
    end

    stun = effect_chance( stun, "effect", "stun" )
   	local rnd = Game.Random( 100 )
    local stun_res = Attack.act_get_res( receiver, "physical" )
    local stun_chance = math.max( 0, stun - stun_res )

    if not Attack.act_pawn( receiver )
    and not Attack.act_feature( receiver, "undead" )
    and not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "boss,pawn" )
    and Attack.act_level( receiver ) < 5
    and rnd < stun_chance then
    	 effect_stun_attack( receiver, 0, 1 )
    	 return -damage, addrage
    end 
  end 
	
  return damage,addrage
end


function features_burn( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )  and damage > 0 then
    --local receiver=Attack.get_target(1)  -- кого?
    local burn = tonumber( Attack.get_custom_param( "burn" ) )
    common_fire_burn_attack( receiver, burn, 0, 3, damage )
    local res = tonumber( Attack.get_custom_param( "res" ) )

    if res ~= nil then
      local a = Attack.atom_spawn( receiver, 0, "magic_oilfog" )
      local dmgts1 = Attack.aseq_time( a, "x" )
      local duration = 3
      Attack.act_del_spell( receiver, "effect_burning_oil" )
      Attack.act_apply_spell_begin( receiver, "effect_burning_oil", duration, false )
      Attack.act_apply_res_spell( "fire", res, 0, 0, duration, false)
      Attack.act_apply_spell_end()
    end
  end 

  return damage, addrage
end


--*************************************************************************
--   Раздел постспеллов
--*************************************************************************

function post_spell_dragon_slayer(damage,addrage,attacker,receiver,minmax,userdata )

		local spell = "spell_dragon_slayer"
		
    --local receiver=Attack.get_target(1)  -- кого?
    --local attacker=Attack.get_target(0)  -- кто?
    
    if Attack.act_is_spell(attacker,spell) then
    
		local level=tonumber(userdata);

  		local bonus_damage = pwr_dragon_slayer(level)
    
    	if Attack.act_feature(receiver,"dragon") then 
      	return damage*(1+bonus_damage/100),addrage*(1+bonus_damage/100)
    	end 
	else       	
		    if (minmax==0) then	Attack.act_posthitmaster(attacker,"post_spell_dragon_slayer",0) end
  	end
	return damage,addrage
end


function features_holy_attack(damage,addrage,attacker,receiver,minmax,userdata)
	
	if Attack.act_is_spell(attacker,"special_holy_rage") then
		if Attack.act_race(receiver,"undead") then
			local bonus=50
			--tonumber(userdata)
			damage=damage*(1+bonus/100)
			addrage=addrage*(1+bonus/100)
		end  
	else
		 if (minmax==0) then	Attack.act_posthitmaster(attacker,"special_holy_rage",0) end
	end 
	
	return damage,addrage
end 


function special_priest(damage,addrage,attacker,receiver,minmax,userdata)

	if Attack.act_race(receiver,"undead") then
		damage = damage * 2
		addrage = addrage * 2
	end
	return damage, addrage

end


function post_spell_demon_slayer(damage,addrage,attacker,receiver,minmax,userdata )

	local spell = "spell_demon_slayer"
		
    --local receiver=Attack.get_target(1)  -- кого?
    --local attacker=Attack.get_target(0)  -- кто?

    if Attack.act_is_spell(attacker,spell) then
    
		local level=tonumber(userdata);

  		local bonus_damage = pwr_demon_slayer(level)
    
    	if Attack.act_feature(receiver,"demon") then 
	      	return damage*(1+bonus_damage/100),addrage*(1+bonus_damage/100)
    	end

	else

	    if (minmax==0) then
			Attack.act_posthitmaster(attacker,"post_spell_demon_slayer",0)
		end

  	end

	return damage,addrage

end


function post_spell_mana_source( damage, addrage, attacker, receiver, minmax, userdata )
	 if ( minmax == 0 )
  and damage > 0 then
		  local spell = "spell_magic_source"

    if Attack.act_is_spell( receiver, spell ) then
		    local level = tonumber( userdata );

      if mana_rage_gain_k == nil then
        mana_rage_gain_k = 1
      end

  		  local mana = tonumber( Attack.val_restore( receiver, "spell_magic_source_mana_gain" ) )
  		  local cast_mana_rage_gain_k = tonumber( Attack.val_restore( receiver, "spell_magic_source_mana_rage_gain_k" ) )

      if mana_rage_gain_k ~= cast_mana_rage_gain_k then
        mana = math.ceil( mana * mana_rage_gain_k )
      end

      local cur_mana, max_mana, add_mana

      if Attack.act_spell_param( receiver, spell, "belligerent" ) == 4 then
  			   cur_mana = Logic.enemy_lu_item( "mana", "count" )
		  	   max_mana = Logic.enemy_lu_item( "mana", "limit" )
			     add_mana = math.min( mana, max_mana - cur_mana )
			     Logic.enemy_lu_item( "mana", "count", cur_mana + add_mana )
      else
  			   cur_mana = Logic.hero_lu_item( "mana", "count" )
		  	   max_mana = Logic.hero_lu_item( "mana", "limit" )
			     add_mana = math.min( mana, max_mana - cur_mana )
			     Logic.hero_lu_item( "mana", "count", cur_mana + add_mana )
      end

  	   local heroname = Attack.act_spell_param( receiver, spell, "heroname" )

			   if add_mana > 0 then
		      local dur = Attack.act_spell_duration( receiver, "spell_magic_source" )

			     if dur <= 1 then
					     Attack.act_posthitslave( receiver, "post_spell_mana_source", 0 )
					     Attack.act_del_spell( receiver, "spell_magic_source" )
				    else
				      Attack.act_spell_duration( receiver, "spell_magic_source", dur - 1 )
				    end

  			   if Attack.act_size( receiver ) > 1 then 
		  		    Attack.log( 0.001, "add_blog_mana_source_2", "name", blog_side_unit( receiver ), "special", blog_side_unit( receiver, 3 ) .. "<label=spell_magic_source_name></color>", "target", add_mana, "hero_name", heroname )
			     else 
				      Attack.log( 0.001, "add_blog_mana_source_1", "name", blog_side_unit( receiver ), "special" , blog_side_unit( receiver, 3 ) .. "<label=spell_magic_source_name></color>", "target", add_mana, "hero_name", heroname )
			     end 
			   end
			   return damage,addrage
		  else       	
		    Attack.act_posthitslave( receiver, "post_spell_mana_source", 0 )
  		  return damage, addrage
  	 end
  else
    return damage, addrage
	 end
end


function post_spell_last_hero( damage, addrage, attacker, receiver, minmax )
		local spell = "spell_last_hero"

  if Attack.act_is_spell( receiver, spell ) then
  		local dam, thp = math.floor( damage + .5 ), Attack.act_totalhp( receiver )
		  local deadA = dam >= thp--Attack.act_damage(attacker,true)
--[[		  if deadA
    and Attack.act_size( receiver ) > 0 then
   			if minmax == 0 then
			     local dur = Attack.act_spell_duration( receiver, spell )
			     if dur <= 1 then
					     Attack.act_posthitslave( receiver, "post_spell_last_hero", 0 )
					     Attack.act_del_spell( receiver, spell )
				    else
				      Attack.act_spell_duration( receiver, spell, dur - 1 )
				    end
				    Attack.log( 0.001, "add_blog_last_hero", "target", blog_side_unit( receiver, -1 ), "special", "<label=spell_last_hero_name></color>" )
			   end
			   return thp - 1
		  end]]
   	if minmax == 0 then
  		  if deadA
      and Attack.act_size( receiver ) > 0 then
        Attack.act_aseq( 0, "cast" )
        local dmgts = Attack.aseq_time( 0, "x" )
        local level = tonumber( Attack.val_restore( receiver, "spell_last_hero_cast_level" ) )
        local tmp_spells = {}
        table.insert( tmp_spells, spell_resurrection_attack )
        tmp_spells[ 1 ]( level, receiver )
      else
        special_bonus_spell( attacker, receiver )
      end
  			 local dur = Attack.act_spell_duration( receiver, spell )
  			 if dur <= 1 then
  				  Attack.act_posthitslave( receiver, "post_spell_last_hero", 0 )
  				  Attack.act_del_spell( receiver, spell )
  				else
  				  Attack.act_spell_duration( receiver, spell, dur - 1 )
  				end
  				Attack.log( 0.001, "add_blog_last_hero", "target", blog_side_unit( receiver, -1 ), "special", "<label=spell_last_hero_name></color>" )
  		  return damage, addrage
    end
	 else       	
		  Attack.act_posthitslave( receiver, "post_spell_last_hero", 0 )
  		return damage, addrage
  end
end


-- NEW - based on special_spell, casts random beneficial spells
function special_bonus_spell( attacker, receiver )
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local level = tonumber( Attack.val_restore( receiver, "spell_last_hero_cast_level" ) )
  local heroname = Attack.act_spell_param( receiver, "spell_last_hero", "heroname" )
  local belligerent = Attack.act_spell_param( receiver, "spell_last_hero", "belligerent" )

  local spellf1 = { spell_stone_skin_attack, 
                    spell_bless_attack, 
                    spell_adrenalin_attack, 
                    spell_haste_attack, 
                    spell_reaction_attack, 
                    spell_magic_source_attack }

  local spelln1 = { "spell_stone_skin",
                    "spell_bless",
                    "spell_adrenalin",
                    "spell_haste",
                    "spell_reaction",
                    "spell_magic_source" }

  local spellf2 = { spell_stone_skin_attack, 
                    spell_bless_attack, 
                    spell_adrenalin_attack, 
                    spell_haste_attack, 
                    spell_reaction_attack, 
                    spell_magic_source_attack, 
                    spell_divine_armor_attack }

  local spelln2 = { "spell_stone_skin",
                    "spell_bless",
                    "spell_adrenalin",
                    "spell_haste",
                    "spell_reaction",
                    "spell_magic_source",
                    "spell_divine_armor" }

  local spellf3 = { spell_stone_skin_attack, 
                    spell_bless_attack, 
                    spell_adrenalin_attack, 
                    spell_haste_attack, 
                    spell_reaction_attack, 
                    spell_magic_source_attack, 
                    spell_divine_armor_attack,
                    spell_invisibility }

  local spelln3 = { "spell_stone_skin",
                    "spell_bless",
                    "spell_adrenalin",
                    "spell_haste",
                    "spell_reaction",
                    "spell_magic_source",
                    "spell_divine_armor",
                    "spell_invisibility" }

  local tmp_spells = {}

  if not Attack.act_feature( receiver, "undead" )
  and not Attack.act_feature( receiver, "plant" )
  and Attack.cell_need_resurrect( receiver ) then
    table.insert( tmp_spells, spell_resurrection_attack )
  end

  if Attack.act_need_charge_or_reload( receiver ) then
    table.insert( tmp_spells, spell_gifts_attack )
  end

  if Attack.act_is_thrower( receiver )
  and not Attack.act_is_spell( receiver, "spell_accuracy" ) then
    table.insert( tmp_spells, spell_accuracy_attack )
  end

  if Attack.act_feature( receiver, "archer" )
  and not Attack.act_is_spell( receiver, "spell_dragon_arrow" ) then
    table.insert( tmp_spells, spell_dragon_arrow_attack )
  end

  if Attack.act_feature( attacker, "dragon" )
  and not Attack.act_is_spell( receiver, "spell_dragon_slayer" ) then
    table.insert( tmp_spells, spell_dragon_slayer_attack )
  end

  if Attack.act_feature( attacker, "demon" )
  and not Attack.act_is_spell( receiver, "spell_demon_slayer" ) then
    table.insert( tmp_spells, spell_demon_slayer_attack )
  end

  if not Attack.act_feature( receiver, "demon" )
  and not Attack.act_is_spell( receiver, "spell_fire_breath" ) then
    table.insert( tmp_spells, spell_fire_breath_attack )
  end

  for ii = 0, Attack.act_spell_count( receiver ) - 1 do
    local spell_name = Attack.act_spell_name( receiver, ii )
    local spell_type = Logic.obj_par( spell_name,"type" )
    if spell_type == "penalty"
    and string.find( spell_name, "^totem_" ) == nil
    and level > 2 then
      table.insert( tmp_spells, spell_dispel_attack )
    end
  end

  if level == 1 then
    for i = 1, table.getn( spellf1 ) do
      if not Attack.act_is_spell( receiver, spelln1[ i ] ) then
        table.insert( tmp_spells, spellf1[ i ] )
      end
    end
  end

  if level == 2 then
    for i = 1, table.getn( spellf2 ) do
      if not Attack.act_is_spell( receiver, spelln2[ i ] ) then
        table.insert( tmp_spells, spellf2[ i ] )
      end
    end
  end

  if level == 3 then
    for i = 1,table.getn( spellf3 ) do
      if not Attack.act_is_spell( receiver, spelln3[ i ] ) then
        table.insert( tmp_spells, spellf3[ i ] )
      end
    end
  end

  if table.getn( tmp_spells ) > 0 then
    local cast = Game.Random( 1, table.getn( tmp_spells ) )
    if tmp_spells[ cast ] == spell_haste_attack
    or tmp_spells[ cast ] == spell_bless_attack then
      tmp_spells[ cast ]( level, dmgts, receiver )
    else
      tmp_spells[ cast ]( level, receiver, belligerent, heroname )
    end
  
    Attack.log_label( '' )
  
    return true
  else
    return false
  end

end

-- ***********************************************
-- * Freeze or Burn
-- ***********************************************

function special_bowman( damage, addrage, attacker, receiver, minmax )
	 local freeze_im = 0.75 --25%
 	local freeze = tonumber( Attack.get_custom_param( "freeze" ) )
  freeze = effect_chance( freeze, "effect", "freeze" )
	 local dragon = tonumber( Attack.get_custom_param( "dragon" ) )
	
 	if dragon == 1 then	
	  	return feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
 	end 

 	if minmax == 0 and damage ~= 0 then -- damage=0 когда мы промахиваемся
		  local burn = tonumber( Attack.get_custom_param( "burn" ) )
    burn = effect_chance( burn, "effect", "burn" )
  		--	if burn==nil then burn=100 end
  		--	if freeze==nil then freeze=100 end
    common_fire_burn_attack( receiver, burn, 0, 3, damage, true )
  		local cold_fear = Attack.act_get_res( receiver, "fire" )
    local freeze_res = Attack.act_get_res( receiver, "physical" )
    local freeze_chance = math.max( 0, freeze - freeze_res )
    local rnd = Game.Random( 100 )

  		if ( rnd < freeze_chance or ( cold_fear >= 50 and freeze > 10 ) )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "freeze_immunitet" )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
   			effect_freeze_attack( receiver, 0, 3 )
   			--Attack.log_label("add_blog_freeze_") -- работает
  		end
	 end

 	if freeze > 0
  and Attack.act_feature( receiver, "freeze_immunitet" ) then
  		damage = damage * freeze_im
  		addrage = addrage * freeze_im
  end

 	local dragon = Attack.get_custom_param( "dragon" )
  if dragon == "1" then
  		return feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
 	end 

  return damage,addrage
end

function feat_dragon_arrow(damage,addrage,attacker,receiver,minmax)
	
	local dragon=Attack.get_custom_param("dragon")
  if dragon=="1" then

  if damage<0 then
    damage=0
  end

	local k = AU.attack( attacker ) - AU.defence( receiver )
	local k2 = AU.attack( attacker )

  if k>=0 and k<60 then
    damage = damage /(1+k*0.0333)
  end
  if k>=60 then
    damage = damage /3
  end
  if k<0 and k>=-60 then
    damage = damage * (1-k*0.0333)
  end
  if k<-60 then
    damage = damage * 3
  end

  if damage<0 then
    damage=0
  end

 	  if k2<60 then
    	damage = damage *(1+k2*0.0333)
  	end
  	if k2>=60 then
    	damage = damage *3
  	end
  end 

  return damage
end

-- ***********************************************
-- * Poison or Unbaff
-- ***********************************************

function special_archer( damage, addrage, attacker, receiver, minmax )
	 local dragon=tonumber( Attack.get_custom_param( "dragon" ) )
	
 	if dragon == 1 then	
	  	return feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
 	end 

 	if ( minmax == 0 ) and damage > 0 then
	   local poison = tonumber( Attack.get_custom_param( "poison" ) )
   	local tranc = tonumber( Attack.get_custom_param( "tranc" ) )
   	local spell_name = ""
    --	if burn==nil then burn=100 end 
    --	if freeze==nil then freeze=100 end
    local poison_res = Attack.act_get_res( receiver, "poison" )
   	local rnd = Game.Random( 100 )

    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local poison_damage = damage * poison_chance / 200
    if rnd < poison_chance
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "poison_immunitet" ) then
    	 effect_poison_attack( receiver, 0, 3, poison_damage, poison_damage )
    end 

    if tranc > 0 then
      local spells_to_delete = {}
     	local spell_count = Attack.act_spell_count( receiver )
      for i = 0, spell_count - 1 do 
      	 spell_name = Attack.act_spell_name( receiver, i )
      	 local spell_type = Logic.obj_par( spell_name, "type" )
      	 if spell_type == "bonus"
        and string.find( spell_name, "^totem_" ) == nil then 
     					table.insert( spells_to_delete, spell_name );
  	 	  	end 
    		end 
    		local spell_del_count = table.getn( spells_to_delete )
    		if spell_del_count > 0 then
     			local del_spell = Game.Random( 1, spell_del_count )
     			Attack.act_del_spell( receiver, spells_to_delete[ del_spell ] )
    		  Attack.act_damage_addlog( receiver, "add_blog_unbaff_" )
    		  Attack.log_special( "<label="..spells_to_delete[ del_spell ].."_name>" ) -- работает  
     			Attack.atom_spawn( receiver, 0, "magic_dispel", 0, true )
      end
    end
	 end 
	
 	local dragon = Attack.get_custom_param( "dragon" )
  if dragon == "1" then
  	 local attack = Attack.act_get_par( attacker )
 	  if attack < 60 then
     	damage = damage * ( 1 + attack * 0.0333 )
   	end
   	if attack >= 60 then
     	damage = damage * 3
   	end
  end 
	
  return damage, addrage
end


-- ***********************************************
-- * Кровотечение 
-- ***********************************************

function features_bleeding( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
 	if minmax == 0 then	
    local power = tonumber( Logic.obj_par( "feat_bleeding", "power" ) ) -- назначаем бонус
    local duration = tonumber( Logic.obj_par( "feat_bleeding", "duration" ) )
    duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_bleeding", false )
		
  		if not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "undead" )
    and not Attack.act_feature( receiver, "golem" )
    and not hitbacking and Attack.act_enemy( receiver )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
      local bleeding_res = Attack.act_get_res( receiver, "physical" )
      power = math.min( 80, power - bleeding_res )
      if power > 0 then
        local duration_old
        duration_old = tonumber( Attack.act_spell_duration( target, "feat_lump_bleeding" ) )
  
        local message
        if duration_old ~=nil and duration_old ~= 0 then
          if duration_old - duration > 0 then
            power = math.min( 80, power + duration_old - duration )
          end
          duration = math.max( duration, duration_old ) + 1
          message = "add_blog_hemoraging_"
        else
          message = "add_blog_bleeding_"
        end
  
     			Attack.act_del_spell( receiver, "feat_bleeding" )
        Attack.act_apply_spell_begin( receiver, "feat_bleeding", duration, false )
    				Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
    				Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
        Attack.act_apply_spell_end()
   			  Attack.act_damage_addlog( receiver, message )
    	   Attack.log_special( blog_side_unit( receiver, -1 ) ) -- работает
      end
  		end 
  end 

  return damage,addrage
end

-- ***********************************************
-- * Атаки алхимика в комплексе
-- ***********************************************

function special_alchemist( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 ) and damage > 0 then
   	local poison = tonumber( Attack.get_custom_param( "poison" ) )
    local poison_res = Attack.act_get_res( receiver, "poison" )
  		local burn = tonumber( Attack.get_custom_param( "burn" ) )
    local burn_res = Attack.act_get_res( receiver, "fire" )
  		local holy = tonumber( Attack.get_custom_param( "holy" ) )
    local rnd = Game.Random( 100 )

    if poison == 10 then
      local a = Attack.atom_spawn( 0, 0, "hll_acidcannon1", Attack.angleto( 0, receiver ) )
      local atk_x = Attack.aseq_time( 0, "x" )                   -- x time of attacker
 	    local acid_x = Attack.aseq_time( a, "x" )
   	  local acid_y = Attack.aseq_time( a, "y" )
     	Attack.aseq_timeshift( 0, acid_x - atk_x )
    end 
    
    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local poison_damage = damage * poison_chance / 200
    if rnd < poison_chance
    and not Attack.act_feature( receiver, "golem" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = 3
      effect_poison_attack( receiver, 0, duration, poison_damage, poison_damage )
      --Attack.atom_spawn(receiver, 0, "hll_shaman_post")
    end

    local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
    local burn_damage = damage * burn_chance / 200
    if rnd < burn_chance
    and not string.find( Attack.act_name( receiver ), "orb" )
    and not string.find( Attack.act_name( receiver ), "cyclop" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = 3
      effect_burn_attack( receiver, 0, duration, burn_damage, burn_damage )
    end

    if rnd <= holy then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = 3
      effect_holy_attack( receiver, 0, duration )
    end
  end

  return damage, addrage
end

function features_weakness( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 ) then
    --local receiver=Attack.get_target(1)  -- кого?
    local weakness = tonumber( Attack.get_custom_param( "weakness" ) )
    weakness = effect_chance( weakness, "effect", "weakness" )
    local rnd = Game.Random( 100 )
  
    if rnd < weakness
    and not Attack.act_feature( receiver, "golem" )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and Attack.act_level( receiver ) < 5 then
      effect_weakness_attack( receiver, 1, 1 )
    end
  end 

  return damage, addrage
end

-- ***********************************************
-- * Push or Stun
-- ***********************************************

function special_cyclop( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then
   	local stun = tonumber( Attack.get_custom_param( "stun" ) )
   	local push = tonumber( Attack.get_custom_param( "push" ) )
	
--	if burn==nil then burn=100 end 
--	if freeze==nil then freeze=100 end
				
    local stun_res = Attack.act_get_res( i, "physical" )
   	local rnd = Game.Random( 100 ) + 1
    if rnd <= ( math.max( 0, stun - stun_res ) ) and damage > 0
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature(receiver,"pawn")
    and not Attack.act_feature(receiver,"boss") then
    	 effect_stun_attack( receiver, 0, 1 )
    end 

    if rnd <= push then --and not Attack.act_feature(receiver,"freeze_immunitet") then
     	local t = receiver --Attack.get_target()
     	local dir = Attack.act_dir( 0 ) --cell_dir( t )
     	local c = Attack.cell_adjacent( t, dir )
     	local push1 = Attack.cell_present( c ) and Attack.cell_is_empty( c )
     	Attack.act_aseq( 0, "attack" )
     	local movtime0 = Attack.aseq_time( 0, "x" )

     	if push1 then
       	local movtime1 = Attack.aseq_time( 0, "y" )

--    Attack.atk_set_damage(dmg_type,min_dmg,max_dmg) --
      		if Attack.act_get_par( t, "dismove" ) == 0 then
        		Attack.act_move( movtime0, movtime1, t, c )
      		end
--      common_cell_apply_damage(t, (movtime0+movtime1)/2)
     	end

--     	if (not push1) then
  --    Attack.atk_set_damage(dmg_type,min_dmg*2,max_dmg*2) --
  --    common_cell_apply_damage(t, movtime0)
--     	end  
  	 --effect_freeze_attack(receiver,0,3)
   	end 
 	end 
	
  return damage,addrage
end

-- ***********************************************
-- * Бешенство
-- ***********************************************

function features_rabid( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then		
    local level = tonumber( Logic.obj_par( "feat_rabid", "level" ) ) -- назначаем бонус
 	  local duration = tonumber( Logic.obj_par( "feat_rabid", "duration" ) )
  		local rabid = tonumber( Attack.get_custom_param( "rabid" ) )
    rabid = effect_chance( rabid, "feat", "rabid" )

  		if duration == nil then duration = tonumber( Attack.get_custom_param( "duration" ) ) end 
		
    duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_rabid", false )
  		local rnd = Game.Random( 100 )

  		if rnd < rabid
    and Attack.act_level( receiver ) <= level
    and not Attack.act_feature( receiver, "undead" )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "plant" )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver,"boss" ) then
    		Attack.act_belligerent( receiver, 16 )
   			Attack.act_del_spell( receiver, "feat_rabid" )
      Attack.act_apply_spell_begin( receiver, "feat_rabid", duration, false )
  				Attack.act_spell_param( receiver, "feat_rabid", "rabid", 1 )
      Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
  				Attack.atom_spawn( receiver, 0, "effect_bullhead", 0, true )
      Attack.act_apply_spell_end()
  		  Attack.act_damage_addlog( receiver, "add_blog_rabid_" )
  		  Attack.log_special( blog_side_unit( receiver, -1 ) ) -- работает  
  		end 
 	end 

  return damage, addrage
end

function features_rabid_onremove(caa)

  -- возвращаем все как было
  Attack.act_belligerent(caa, Attack.act_belligerent( caa, nil ))
  Attack.atom_spawn(caa, 0, "effect_bullhead", 0, true)
			if Attack.act_size(caa)>1 then 
				Attack.log(0.001,"add_blog_norabid_2","name",blog_side_unit(caa))
			else 
				Attack.log(0.001,"add_blog_norabid_1","name",blog_side_unit(caa))
			end 
  return true

end


-- ***********************************************
-- * Проклятье
-- ***********************************************

function features_curse( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then		
    local level = tonumber( Logic.obj_par( "effect_curse", "level" ) )
		  local duration = tonumber( Logic.obj_par( "effect_curse", "duration" ) )
		  local curse = tonumber( Attack.get_custom_param( "curse" ) )
    curse = effect_chance( curse, "effect", "curse" )
		  local rnd = Game.Random( 100 )

  		if ( rnd < curse )
    and not Attack.act_feature( receiver, "golem" )
    and ( Attack.act_level( receiver ) <= level )
    and not ( Attack.act_feature( receiver, "undead" ) )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
   			effect_curse_attack( receiver, 1, duration )
  		end 
 	end 

  return damage, addrage
end

-- ***********************************************
-- * Усыпление 
-- ***********************************************

function features_sleep( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then		
    local level = tonumber( Logic.obj_par( "effect_sleep", "level" ) )
    local duration = tonumber( Attack.get_custom_param( "duration" ) )

    if duration == nil then duration = tonumber( Logic.obj_par( "effect_sleep", "duration" ) ) end 
    
    local special = tonumber( Attack.get_custom_param( "special" ) )		
  		local dod = Attack.get_custom_param( "dod" )
  		local ddd = true

 			if dod == "yes" then ddd = true else ddd = false end

  		local sleep = tonumber( Attack.get_custom_param( "sleep" ) )		
    sleep = effect_chance( sleep, "effect", "sleep" )
    local level2_chance = 50
    level2_chance = effect_chance( level2_chance, "effect", "sleep" )
    local level3_chance = 25
    level3_chance = effect_chance( level3_chance, "effect", "sleep" )
    local level4_chance = 10
    level4_chance = effect_chance( level4_chance, "effect", "sleep" )
   	local rnd = Game.Random( 100 )

  	 if special == 0 then
		    if ( rnd < sleep )
      and not Attack.act_feature( receiver, "golem" )
      and ( Attack.act_level( receiver ) <= level )
      and not ( Attack.act_feature( receiver, "undead" ) )
      and not ( Attack.act_feature( receiver, "mind_immunitet" ) )
      and damage > 0
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" ) then
     			effect_sleep_attack( receiver, 2, duration, ddd )     
     			Attack.act_damage_addlog( receiver, "add_blog_sleep_" )
    		end 
   	else
      if not ( Attack.act_feature( receiver, "undead" ) )
      and not Attack.act_feature( receiver, "golem" )
      and not ( Attack.act_feature( receiver, "mind_immunitet" ) )
      and damage > 0
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" ) then
     			if Attack.act_level( receiver ) == 1 then
      				effect_sleep_attack( receiver, 2, duration, ddd )
      				Attack.act_damage_addlog( receiver, "add_blog_sleep_" )
     			end	
  
     			if Attack.act_level( receiver ) == 2 and rnd < level2_chance then
      				effect_sleep_attack( receiver, 2, duration, ddd )
      				Attack.act_damage_addlog( receiver, "add_blog_sleep_" )
     			end	
  
     			if Attack.act_level( receiver ) == 3 and rnd < level3_chance then
      				effect_sleep_attack( receiver, 2, duration, ddd )
      				Attack.act_damage_addlog(receiver,"add_blog_sleep_")
     			end	
  
     			if Attack.act_level( receiver ) == 4 and rnd < level4_chance then
      				effect_sleep_attack( receiver, 2, duration, ddd )
      				Attack.act_damage_addlog( receiver, "add_blog_sleep_" )
     			end	
    		end 	
   	end 
 	end 

  return damage,addrage
end

-- ***********************************************
-- * Очарование
-- ***********************************************

function features_charm( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then		
    local level = tonumber( Logic.obj_par( "effect_charm", "level" ) )
		  local duration = tonumber( Logic.obj_par( "effect_charm", "duration" ) )
		  local charm = tonumber( Attack.get_custom_param( "charm" ) )
    charm = effect_chance( charm, "effect", "charm" )
  		local rnd = Game.Random( 100 )

  		if ( rnd < charm )
    and not Attack.act_feature( receiver, "golem" )
    and ( Attack.act_level( receiver ) <= level )
    and not ( Attack.act_feature( receiver, "undead" ) )
    and ( Attack.act_feature( receiver, "humanoid" ) )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver,"boss" ) then
  			 local caster_count = Attack.act_size( attacker )	-- сколько магов
  		--лидерство магов и цели 
   			local caster_lead = Attack.act_leadership( attacker )
   			local target_lead = Attack.act_leadership( receiver )
   			local target_count = Attack.act_size( receiver )
  		-- сколько можно соблазнить по лидерству
  			 if caster_lead * caster_count > target_lead * target_count
      and Attack.act_level( receiver ) < 5 then
    				--local dmgts = Attack.aseq_time(target, "x")
    				effect_charm_attack( receiver, 0, duration )
  		  		Attack.log_label( "charm_" )
    				return CHARM, 0
  			 end 
  		end 
 	end 

  Attack.log_label( "" )

  return damage, addrage
end

function features_regeneration()
	 if Attack.act_need_cure( 0 ) then
	   local cur_hp = Attack.act_hp( 0 )
	   local max_hp = Attack.act_get_par( 0, "health" )
				Attack.atom_spawn( 0, 0, "effect_total_cure" )
				--dmgts = Attack.aseq_time("hll_priest_heal_post", "y")
				Attack.act_cure( 0, max_hp - cur_hp, 0 )
    Attack.log_label( "add_blog_regen_1" ) -- работает
    Attack.act_aseq( 0, "idle" )	
    Attack.val_store( 0, "gizmo_priority", 0 )

 			if Attack.act_size( 0 ) > 0 then 
	  			Attack.log( "add_blog_regen_2", "name", blog_side_unit( 0 ) )
 			else 
	  			Attack.log( "add_blog_regen_1", "name", blog_side_unit( 0 ) )
 			end 
  end 

  return true
end

function features_auto_dispell( tend )
		if takeoff_spells( 0, "penalty" ) then 		
	  	Attack.act_aseq( 0, "special" )	
--		  	local dmgts = Attack.aseq_time(0, "x")

 			if Attack.act_size( 0 ) > 0 then 
				  Attack.log( tend + .05, "add_blog_autodispell_2", "name", blog_side_unit( 0 ) )
			 else 
  				Attack.log( tend + .05, "add_blog_autodispell_1", "name", blog_side_unit( 0 ) )
			 end 
--			Attack.atom_spawn(0, dmgts, "magic_dispel")
		end
			    
  return true
end


function features_devil_fear( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if minmax == 0
  and not hitbacking then
--				Attack.aseq_remove(attacker,"attack")
        --Attack.atom_spawn(receiver, 0, "magic_dispel")
--  			Attack.act_aseq(attacker, "special" )	        
		  local fear = tonumber( Attack.get_custom_param( "fear" ) )
    fear = effect_chance( fear, "effect", "fear" )
  		local level = tonumber( Attack.get_custom_param( "level" ) )
  		local duration = tonumber( Attack.get_custom_param( "duration" ) )
  		local rnd = Game.Random( 0,100 )

  		if rnd < fear
    and Attack.act_level( receiver ) <= level
    and not Attack.act_feature( receiver, "mind_immunitet" )
    and not Attack.act_feature( receiver, "undead" )
    and damage > 0
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
      Attack.act_apply_spell_begin( receiver, "effect_fear", duration, false )
      Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
      Attack.act_apply_spell_end()
 					Attack.act_damage_addlog( receiver, "add_blog_fear_" )
	 				Attack.atom_spawn( receiver, 0, "magic_scare", Attack.angleto( receiver ), true )
		 			Attack.act_damage_addlog( receiver, "add_blog_fear_" )
      return -damage, addrage
    end
	 end
	
  return damage,addrage
end


function features_feeling_of_comradeship()

	local attack, attack_base = Attack.act_get_par(0, "attack")
	local max_bonus=11 -- максимум, который можно получить базовой атаки включая базовую
	local need_count=30 -- количество крестьян, дающих +1 атаки
	
	Attack.act_attach_modificator(0, "attack", "comradeship_mod", math.min(math.floor(Attack.act_size(0)/need_count),max_bonus - attack_base))
	return true

end


-- ***********************************************
-- * медведь
-- ***********************************************

function bear_slave(damage,addrage,attacker,receiver,minmax,userdata,hitbacking)

    local dam, addrg = damage, addrage

	if minmax == 0 then
		dam, addrg = features_brutality(damage,addrage,attacker,receiver,minmax,userdata,hitbacking)
					   
		if Attack.act_is_spell(receiver, "effect_sleep") then
			return -dam, addrg
		end
	end

	return dam, addrg

end

function bear_after_move(pass)

	if not pass and Attack.val_restore("was_action") == "0" and not Attack.act_is_spell(0, "effect_sleep") then
		effect_sleep_attack(0, 0, 3, true)
		if Attack.act_size(0)>1 then 
			Attack.log(0.001,"add_blog_bsleep_2","name",blog_side_unit(0,1))
		else
			Attack.log(0.001,"add_blog_bsleep_1","name",blog_side_unit(0,1))
		end 
	end
	return true

end


function features_decay( wtm, tshift, dead )
	 local level = 2
 	if dead == true then
  		local a = Attack.atom_spawn( 0, tshift, "magic_decay" )
  		local dmgts = Attack.aseq_time( a, "x" ) + tshift
 	  Attack.act_damage_addlog( 0, "add_blog_decay_", true )
--	  Attack.log_special(blog_side_unit(receiver,false)) -- работает  

  		for c = 0, Attack.cell_count() - 1 do
   	  local i = Attack.cell_get(c)
		
    		if Attack.cell_dist( 0, i ) == 1
      and ( Attack.act_enemy( i ) or Attack.act_ally( i ) ) then  -- can receive this attack
     			if not ( Attack.act_race( i, "demon" ) )
        and not ( Attack.act_feature( i, "plant" ) )
        and not ( Attack.act_feature( i, "golem" ) )
        and not Attack.act_feature( i, "pawn" )
        and not Attack.act_feature( i, "boss" ) then
--      local rnd=Game.Random(0,100)+1
  --    if rnd<=var then
         	spell_plague_attack(i,level,dmgts)
        end 
      end
  		end
  end

 	return true
end


function features_bone_creature( damage, addrage, attacker, receiver, minmax )
	 if Attack.get_custom_param( "arrows" ) == "1" then
		  return damage * .3, addrage * .3
	 end

	 return damage, addrage
end

-- New for wood creatures
function features_wood_creature( damage, addrage, attacker, receiver, minmax )
	 if Attack.get_custom_param( "arrows" ) == "1" then
		  return damage * .4, addrage * .4
	 end

	 return damage, addrage
end


-- New for stone creatures
function features_stone_creature( damage, addrage, attacker, receiver, minmax )
	 if Attack.get_custom_param( "arrows" ) == "1" then
		  return damage * .2, addrage * .2
	 end

	 return damage, addrage
end


function features_initiative_penalty()

	for i=1,Attack.act_count()-1 do
		if Attack.act_enemy(i) and Attack.act_level(i) < 5 then
			Attack.act_attach_modificator(i,"initiative","initiative_penalty",-1)
		end
	end

	return true

end


function black_dragon_ondamage(wnm,ts,dead)

	if dead then
		for i=1,Attack.act_count()-1 do
			Attack.act_del_modificator(i,"initiative_penalty")
		end
	end
	return true

end

function features_evasion(damage,addrage,attacker,receiver,minmax)

	if minmax == 0 then	
	-- просто проверка - если не висит спелл, то снимаем скрипт
		if not Attack.act_is_spell(receiver, "feat_evasion") then Attack.act_posthitmaster(receiver, "feat_evasion",0) end	
	end 
	
	return damage,addrage

end


function features_saturation( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if minmax == 0
  and not hitbacking
  and damage > 10 then
    local charges = tonum( Attack.val_restore( 0, "charges" ) )

    if charges == 0 then
			   Attack.act_charge( attacker )
			   Attack.act_enable_attack( 0, "gulp", false )
  		  charges = Attack.get_custom_param( "charge" )

  		  if tonum( charges ) then 
        Attack.val_store( 0, "charges", charges )
      end
    end
	 end 
	
 	return damage, addrage
end


function post_magic_shield(damage,addrage,attacker,receiver,minmax,userdata)
	
	if Attack.act_is_spell(receiver,"special_magic_shield") then
		damage=damage*.5
		addrage=addrage*.5
	else
		 if (minmax==0) then Attack.act_posthitslave(receiver,"post_magic_shield",0) end
	end 
	
	return damage,addrage
end 

function features_dragon_slayer(damage,addrage,attacker,receiver,minmax,userdata )

    --local receiver=Attack.get_target(1)  -- кого?
    --local attacker=Attack.get_target(0)  -- кто?
    
 		local bonus_damage = tonumber(Attack.get_custom_param("dragonslayer"))
    
  	if Attack.act_feature(receiver,"dragon") then 
     	return damage*(1+bonus_damage/100),addrage*(1+bonus_damage/100)
   	end 
	  	
	return damage,addrage
end
