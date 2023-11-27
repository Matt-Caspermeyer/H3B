-- New function for adding a bonus to % of chance to inflict an effect
function effect_chance( value, effect_or_feature, kind )
  local bonus = tonumber( Logic.hero_lu_item( "sp_chance_" .. effect_or_feature .. "_" .. kind, "count" ) )

  if value ~= nil
  and bonus ~= nil then
    value = value + bonus
  end

  return value
end


-- New Bear Attack
function features_bear_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    if not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and not Attack.act_feature( receiver, "plant" ) then
      local attacker_level = Attack.act_level( attacker )
      local receiver_level = Attack.act_level( receiver )
      local stun = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "stun" ) )
      local stunned = false
      local dazed = false
  
      if attacker_level ~= nil   -- attacker_level should never be nil, but you never know...
      and receiver_level ~= nil  -- receiver_level should never be nil, but you never know...
      and stun ~= nil then
        local stun_inc = tonum( Attack.get_custom_param( "stun_inc" ) )
        local stun_chance = stun + ( attacker_level - receiver_level ) * stun_inc
        local receiver_res = Attack.act_get_res( receiver, "physical" )
        stun_chance = stun_chance * ( 1 - receiver_res / 100 )
        local rnd = Game.Random( 99 )
      
        if rnd < stun_chance then
          stunned = true
          local duration = apply_difficulty_level_talent_bonus( 2 )
          local returnVal
          returnVal, dazed = effect_stun_attack( receiver, 1, duration )
        end
      end

      local bleeding = false
      local hemoraging = false

      if not Attack.act_feature( receiver, "undead" ) then
        local bleeding = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "bleeding" ) )
    
        if attacker_level ~= nil   -- attacker_level should never be nil, but you never know...
        and receiver_level ~= nil  -- receiver_level should never be nil, but you never know...
        and bleeding ~= nil then
          local bleeding_inc = tonum( Attack.get_custom_param( "bleeding_inc" ) )
          local bleeding_chance = bleeding + ( attacker_level - receiver_level ) * bleeding_inc
          local receiver_res = Attack.act_get_res( receiver, "physical" )
          bleeding_chance = bleeding_chance * ( 1 - receiver_res / 100 )
          local rnd = Game.Random( 99 )
        
          if rnd < bleeding_chance then
            bleeding = true
            local power = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_bleeding", "power" ) ) -- ��������� �����
            local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_bleeding", "duration" ) )
            duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_bleeding", false )
            local bleeding_res = Attack.act_get_res( receiver, "physical" )
            power = math.min( 80, power - bleeding_res )
      
            if power > 0 then
              scared = true
              local duration_old = tonumber( Attack.act_spell_duration( receiver, "feat_lump_bleeding" ) )
              local message = "add_blog_bleeding_"
      
              if duration_old ~=nil and duration_old ~= 0 then
                if duration_old - duration > 0 then
                  power = math.min( 80, power + duration_old - duration )
                end

                duration = math.max( duration, duration_old ) + 1
                message = "add_blog_hemoraging_"
                hemoraging = true
              end

           			Attack.act_del_spell( receiver, "feat_bleeding" )
              Attack.act_apply_spell_begin( receiver, "feat_bleeding", duration, false )
          				Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
          				Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
              Attack.act_apply_spell_end()
         			  Attack.act_damage_addlog( receiver, message )
            end
          end
        end
      end

      if bleeding
      or hemoraging then
        if stunned
        or dazed then
          if stunned
          and bleeding then
            message = "add_blog_stunned_bleeding_"
          elseif stunned
          and hemoraging then
            message = "add_blog_stunned_hemoraging_"
          elseif dazed
          and bleeding then
            message = "add_blog_dazed_bleeding_"
          elseif dazed
          and hemoraging then
            message = "add_blog_dazed_hemoraging_"
          end
  
          Attack.act_damage_addlog( receiver, message )
        end
      end
    end
  end 

	 return damage, addrage
end


-- New Unicorn Horn of Light Attack
function features_lighthorn_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and ( Attack.act_name( receiver ) ~= "unicorn"
  and Attack.act_name( receiver ) ~= "unicorn2" ) then
    local blind = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "blind" ) )
    local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_blind", "duration" ) )

    if blind ~= nil then
      if Attack.act_race( receiver ) == "undead"
      or Attack.act_race( receiver ) == "demon"
      or Attack.act_feature( receiver, "undead" )
      or Attack.act_feature( receiver, "demon" ) then
        duration = duration + 1
      end

      if Attack.act_name( receiver ) == "beholder"
      or Attack.act_name( receiver ) == "beholder2"
      or Attack.act_name( receiver ) == "cyclop" then
        blind = blind * 2
        duration = duration + 1
      end

      if Game.DayTime() > 1
      or Game.LocType( 'dungeon' ) then
        blind = blind * 2
        duration = duration + 1
      end

      -- Note that the Unicorn's Blind is consisdered an Astral Attack and so resistance type is Astral (i.e. no resistance)
      -- (as opposed to the spell that is magical)
      local resistance = "astral"
      local receiver_res = Attack.act_get_res( receiver, resistance )
      local blind_chance = blind * ( 1 - receiver_res / 100 )
      local rnd = Game.Random( 99 )
    
      if rnd < blind_chance
      and not Attack.act_feature( receiver, "eyeless" )
      and not ( Attack.act_feature( receiver, "golem" )
      or not Attack.act_name( receiver ) == "cyclop" )  -- even though cyclops are golems, they can be blinded
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" ) then
        Attack.act_animate( attacker, "power" )
       	effect_blind_attack( receiver, 1, duration )
      end
    end
  end 

  return damage, addrage
end


-- New Orc / Veteran Orc Post-Hit
function orc_posthitslave( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if ( minmax == 0 )
  and damage > 0
  and not hitbacking
  and damage < Attack.act_totalhp( receiver ) then
    local iskrit = Attack.val_restore( receiver, "critical_hit" )
    local angry = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "angry" ) )

    if angry ~= nil then
      local rnd = Game.Random( 99 )
    
      if iskrit == 1
      and rnd < angry then
     		 local new_ap
        local message
    
        if ( Attack.act_again( receiver ) ) then
          Attack.act_again( receiver, true )
          message = "add_blog_orc_posthit_1"
        else
          new_ap = Attack.act_ap( receiver ) + math.max( 1, math.ceil( Attack.act_ap( receiver ) / 2 ) )
          local current_init, base_init = Attack.act_get_par( receiver, "initiative" )
          Attack.act_set_par( receiver, "initiative", base_init + 1 )
          Attack.act_ap( receiver, new_ap )
          Attack.resort()
    
          message = "add_blog_orc_posthit_2"
        end
    
        if Attack.act_size( receiver ) > 1 then
          message = message .. "2"
        else
          message = message .. "1"
        end
    
        Attack.log( 1, message, "name", blog_side_unit( receiver ) )
        Attack.atom_spawn( receiver, 0, "magic_horn" )
      end
    end
  end

  Attack.val_store( receiver, "critical_hit", 0 )

  if Attack.act_race( attacker, "orc" )
  or Attack.act_race( receiver, "orc" ) then
  	 return damage, addrage * 1.5
  else
  	 return damage, addrage
  end
end


-- New Giant Attack
function features_giant_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    local sleep = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "sleep" ) )

    if sleep ~= nil then
      local receiver_res = Attack.act_get_res( receiver, "physical" )
      local sleep_chance = sleep * ( 1 - receiver_res / 100 )
  
      if Attack.act_is_spell( receiver, "effect_stun" ) then
        sleep_chance = sleep_chance * 1.5
      end
  
      local rnd = Game.Random( 99 )
    
      if rnd < sleep_chance
      and not Attack.act_feature( receiver, "mind_immunitet" )
      and not Attack.act_feature( receiver, "golem" )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" )
      and not Attack.act_feature( receiver, "plant" )
      and not Attack.act_feature( receiver, "undead" ) then
        local duration = apply_difficulty_level_talent_bonus( 1 )
       	effect_unconscious_attack( receiver, 1, duration )
       	Attack.act_damage_addlog( receiver, "add_blog_unconscious_" )
      end
    end
  end 

  return damage, addrage
end


-- New Ogre Attack
function features_ogre_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and not hitbacking
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    local receiver_level = Attack.act_level( receiver )
    local stun = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "stun" ) )

    if receiver_level ~= nil  -- receiver_level should never be nil, but you never know...
    and stun ~= nil then
      local stun_inc = tonum( Attack.get_custom_param( "stun_inc" ) )
      local stun_chance = stun + ( receiver_level - 1 ) * stun_inc
      local receiver_res = Attack.act_get_res( receiver, "physical" )
      stun_chance = stun_chance * ( 1 - receiver_res / 100 )
      local rnd = Game.Random( 99 )
    
      if ( ( rnd < stun_chance
      and not Attack.act_feature( receiver, "golem" )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" )
      and not Attack.act_feature( receiver, "plant" ) )
      or Attack.act_is_spell( receiver, "effect_stun" ) ) then
        local sleep = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "sleep" ) ) )
        local sleep_inc = tonum( Attack.get_custom_param( "sleep_inc" ) )
        local sleep_chance = sleep + ( 5 - receiver_level ) * sleep_inc
  
        if Attack.act_is_spell( receiver, "effect_stun" ) then
          sleep_chance = sleep_chance + 10
        end
  
        sleep_chance = sleep_chance * ( 1 - receiver_res / 100 )
        rnd = Game.Random( 99 )
    
        if rnd < sleep_chance
        and not Attack.act_feature( receiver, "undead" )
        and not Attack.act_feature( receiver, "mind_immunitet" ) then
          local duration = apply_difficulty_level_talent_bonus( 1 )
       			effect_unconscious_attack( receiver, 1, duration )
       			Attack.act_damage_addlog( receiver, "add_blog_unconscious_" )
        else
          local duration = apply_difficulty_level_talent_bonus( 2 )
        	 effect_stun_attack( receiver, 1, duration )
        end
      end
    end
  end 

  if Attack.act_race( attacker, "orc" )
  or Attack.act_race( receiver, "orc" ) then
  	 return damage, addrage * 1.5
  else
  	 return damage, addrage
  end
end


-- New Archdemon Attack
function features_archdemon_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and damage > 0
  and not hitbacking
  and damage < Attack.act_totalhp( receiver ) then
    local receiver_level = Attack.act_level( receiver )

    if receiver_level ~= nil then  -- receiver_level should never be nil, but you never know...
      if receiver_level < 5
      and not Attack.act_feature( receiver, "magic_immunitet" )
      and not Attack.act_feature( receiver, "golem" )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" )
      and not Attack.act_is_spell( receiver, "spell_ram" ) then
        local tmp_spells = {}
  
        if takeoff_spells( receiver, "bonus", true ) then
          table.insert( tmp_spells, spell_dispell_attack )
        end
    
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
          local act = Attack.get_caa( receiver, true )
  
          for t in pairs( act.atks ) do
            if t ~= "base" then
              table.insert( tmp_spells, spell_magic_bondage_attack )
              break
            end
          end
        end
        
        if table.getn( tmp_spells ) > 0 then
          Attack.act_aseq( 0, "cast" )
          local dmgts = Attack.aseq_time( 0, "x" )
          local cast = Game.Random( 1, table.getn( tmp_spells ) )
          local spell_level = 3
        
          if tmp_spells[ cast ] == spell_dispell_attack
          or tmp_spells[ cast ] == spell_magic_bondage_attack then
            tmp_spells[ cast ]( spell_level, receiver )
          else
            tmp_spells[ cast ]( spell_level, dmgts, receiver )
          end
        
      		  Attack.log( dmgts + 0.2, "add_blog_archdemon_attack", "name", blog_side_unit( attacker, 1 ), "target", blog_side_unit( receiver, 0 ) )
        end
      end
    end
  end 

  if Attack.act_race( attacker, "demon" )
  or Attack.act_feature( attacker, "demon" )
  or Attack.act_race( receiver, "demon" )
  or Attack.act_feature( receiver, "demon" ) then
  	 return damage, addrage * 2
  else
  	 return damage, addrage
  end
end


-- New Bone Dragon Attack
function features_bonedragon_attack( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    --local receiver=Attack.get_target(1)  -- ����?
    local poison = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "poison_chance" ) )

    if poison ~= nil then
      poison = effect_chance( poison, "effect", "poison" )
      local poison_res = Attack.act_get_res( receiver, "poison" )
      local rnd = Game.Random( 99 )
      
      local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
      local poison_damage = damage * poison_chance / 200
      if rnd < poison_chance
      and not Attack.act_feature( receiver, "golem" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
        effect_poison_attack( receiver, 0, apply_difficulty_level_talent_bonus( 3 ), poison_damage, poison_damage )
      end
    end
  end 

  if ( minmax == 0 )
  and not hitbacking
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    local receiver_level = Attack.act_level( receiver )
    local chance = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "chance" ) )

    if receiver_level ~= nil  -- receiver_level should never be nil, but you never know...
    and chance ~= nil then
      local receiver_chance = ( 5 - receiver_level ) * chance
      local rnd = Game.Random( 99 )
      local poison = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "poison" ) ) )
    
      if rnd < receiver_chance
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
            tmp_spells[ cast ]( spell_level, dmgts, receiver, true )
          end
    
    				  Attack.log( dmgts + 0.2, "add_blog_bonedragon_attack", "name", blog_side_unit( attacker, 1 ), "target", blog_side_unit( receiver, 0 ) )
        end
      end
    end
  end 

  return damage, addrage
end


-- New Ent Entangle
function features_entangle( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    if not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
      local entangle = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "entangle" ) )
      
      if entangle ~= nil then
        local level = tonum( Attack.get_custom_param( "level" ) )
  
        if Attack.act_level( receiver ) <= level then
          local movetype = Attack.get_custom_param( "movetype" )
          local act_mt = Attack.act_mt( receiver )
          local app_mt = true
      
          for mt = 1, text_par_count( movetype ) do
            if act_mt == tonumber( text_dec( movetype, mt ) ) then
              app_mt = false
              break
            end
          end
      
          if app_mt then
            entangle = effect_chance( entangle, "effect", "entangle" )
            local rnd = Game.Random( 99 )
        
            if rnd < entangle then
              local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_entangle", "duration" ) )
              effect_entangle_attack( receiver, 1, duration )
            end
          end
        end
      end
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

  if titan_energy ~= nil then  -- This shouldn't be needed since tonum sets nil to 0, but is here anyway
    if titan_energy > 0 then
      local power = 100 - tonum( Attack.val_restore( 0, "dissipate" ) )
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
    local bonus = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_increase_anger", "power" ) ) -- ��������� �����
    local krit_bonus = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_increase_anger", "krit_bonus" ) ) -- ��������� �����
    local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_increase_anger", "duration" ) )
    duration = apply_hero_duration_bonus( attacker, duration, "sp_duration_feat_increase_anger", true )
    local cur_bonus = 0
    local cur_krit_bonus = 0
    
  		if Attack.act_is_spell( attacker, "feat_increase_anger" ) then -- ���� ����� �����, ���� �� ���� ������
    	 cur_bonus = tonumber( Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus" ) )
     	cur_krit_bonus = tonumber( Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus" ) )
    end 
    
    if cur_bonus == nil then cur_bonus = 0 end 

    if cur_krit_bonus == nil then cur_bonus = 0 end 

    if cur_bonus < 15 then 
     	-- ����� ����������� �����, � ��� ������ ����� � �����
		   	Attack.act_del_spell( attacker, "feat_increase_anger" )
      Attack.act_apply_spell_begin( attacker, "feat_increase_anger", duration, false )
  				Attack.act_spell_param( attacker, "feat_increase_anger", "dmg_bonus", bonus + cur_bonus )
				--Attack.act_apply_par_spell("attack", bonus+cur_bonus, 0, 0, 1, false)
  				Attack.act_apply_dmg_spell( "physical", bonus + cur_bonus, 0, 0, duration, false )
  				Attack.act_apply_par_spell( "krit", krit_bonus + cur_krit_bonus, 0, 0, duration, false )
      Attack.act_apply_spell_end()
 			  Attack.act_damage_addlog( receiver, "add_blog_anger_", true )
 			  Attack.log_special( blog_side_unit( attacker, -1 ) ) -- ��������  
    end
  end 
  
  return damage,addrage
end

function features_brutality( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
  if ( minmax == 0 and Attack.get_caa( attacker ) ~= nil ) then -- ���� ��� �� �����
    local bonus = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Logic.obj_par( "feat_brutality", "power" ) ) ) ) -- ��������� �����
    local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_brutality", "duration" ) )
    duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_brutality", true )
    local cur_bonus = 0
    
  		if not Attack.act_is_spell( receiver, "feat_brutality" )
    and not hitbacking then -- ���� ����� �����, ���� �� ���� ������
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
    and not ( Attack.act_race( receiver, "demon" ) )
    and not ( Attack.act_feature( receiver, "plant" ) )
    and not ( Attack.act_feature( receiver, "golem" ) )
    and not ( Attack.act_feature( receiver, "holy" ) )
    and not ( Attack.act_feature( receiver, "pawn" ) ) then
      local k = tonum( Attack.get_custom_param( "k" ) )

      if k > 0 then 
        k = apply_difficulty_level_talent_bonus( k )

        if Game.DayTime() < 2
        and not Game.LocType( 'cemetery' )
        and not Game.LocType( 'lava' )
        and not Game.LocType( 'dungeon' ) then
          k = k / 2
        end
  
        local health = AU.health( receiver )
        local unit_count = AU.unitcount( receiver )
        local total_hp = Attack.act_totalhp( receiver )
        local remaining_hp = total_hp - round( damage )
        local remaining_count = remaining_hp / health
        local add_unit = math.min( unit_count, math.floor( unit_count - remaining_count ), math.floor( damage * k / 100 / AU.health( attacker ) ) ) -- ������� ��������

        if add_unit > 0 then
          local attacker_count = AU.unitcount( attacker )
          local heal_unit = add_unit * AU.health( attacker )  -- �� ������� ������� ��������
        		Attack.act_size( attacker, attacker_count + add_unit )
  	 	     Attack.act_cure( attacker, heal_unit, 1 )
       	  Attack.atom_spawn( attacker, 0, "effect_total_cure" )
       		 local log_msg = "add_blog_soul_"
  	     	 local special = add_unit
  	 		    Attack.act_damage_addlog( receiver, log_msg, true )
  	 		    Attack.log_special( special ) -- ��������  
          effect_temp_ooc( attacker )
        end
     	end 
   	end 
	 end 

  return damage,addrage
end


function features_vampirism( damage, addrage, attacker, receiver, minmax ) -- minmax, ������ 1 ��� 2 ��������, ��� ������� ���������� ������ ��� ����������� ���/���� ����� �� ���.���������
  if minmax == 0
  and damage > 0 then
    -- ������� ����� � ������
  	 if --[[Attack.act_need_cure(attacker) or ]]Attack.cell_need_resurrect( attacker ) then
    	 if Attack.act_enemy( receiver )
      and not ( Attack.act_feature( receiver, "undead" ) )
      and not ( Attack.act_race( receiver, "demon" ) )
      and not ( Attack.act_feature( receiver, "plant" ) )
      and not ( Attack.act_feature( receiver, "golem" ) )
      and not ( Attack.act_feature( receiver, "pawn" ) ) then
    			 local count_1 = Attack.act_size( attacker )
    	   local vamp = damage

        if Game.DayTime() < 2
        and not Game.LocType( 'cemetery' )
        and not Game.LocType( 'lava' )
        and not Game.LocType( 'dungeon' ) then
          vamp = vamp / 2
        end

        vamp = math.min( Attack.act_totalhp( receiver ), vamp )
  
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
    	   Attack.log_special( special ) -- ��������  
      end 
    end
  end

  return damage,addrage
end


function features_fire_shield( damage,addrage,attacker,receiver,minmax )
  if (minmax==0) then
    --local receiver=Attack.get_target(1)  -- ����?
    --local attacker=Attack.get_target(0)  -- ���?
    -- ������� ����� � ������
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
  local level = tonum( Attack.get_custom_param( "level" ) )

  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and not Attack.act_feature( receiver, "golem" )
  and not Attack.act_feature( receiver, "pawn" )
  and not Attack.act_feature( receiver, "boss" )
  and Attack.act_level( receiver ) <= level then
  --local receiver=Attack.get_target(1)  -- ����?
    local shock = nil
  
    if Attack.act_name( attacker ) == "archmage"
    and Attack.act_is_spell( attacker, "special_battle_mage" ) then
     	shock = tonumber( Attack.act_spell_param( attacker, "special_battle_mage", "shock" ) )
    end 

    if shock == nil then shock = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "shock" ) ) ) end

    shock = effect_chance( shock, "effect", "shock" )

    if Attack.act_is_spell( receiver, "effect_freeze" ) then
      shock = shock * 2
    end

    local rnd = Game.Random( 99 )
          
    if rnd < shock then
      local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_shock", "duration" ) )
      effect_shock_attack( receiver, 1, duration )
    end
  end 

  return damage, addrage
end


function features_poison( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    --local receiver=Attack.get_target(1)  -- ����?
    local poison = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "poison" ) )

    if poison ~= nil then
      poison = effect_chance( poison, "effect", "poison" )
      local poison_res = Attack.act_get_res( receiver, "poison" )
      local rnd = Game.Random( 99 )
      
      local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
      local poison_damage = damage * poison_chance / 200
      if rnd < poison_chance
      and not Attack.act_feature( receiver, "golem" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
        local duration = apply_difficulty_level_talent_bonus( 3 )
        effect_poison_attack( receiver, 0, duration, poison_damage, poison_damage )
      end
    end
  end 

  return damage, addrage
end

-- ***********************************************
-- * Stun
-- ***********************************************

function features_stun( damage, addrage, attacker, receiver, minmax )
 	if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
   	local stun = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "stun" ) ) )
   	local sleep = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "sleep" ) ) )

    if sleep ~= nil
    and sleep ~= 0 then
      local stun_chance = stun
      local receiver_res = Attack.act_get_res( receiver, "physical" )
      stun_chance = stun_chance * ( 1 - receiver_res / 100 )
      local rnd = Game.Random( 99 )
    
      if ( ( rnd < stun_chance
      and not Attack.act_feature( receiver, "golem" )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" )
      and not Attack.act_feature( receiver, "plant" ) )
      or Attack.act_is_spell( receiver, "effect_stun" ) ) then
        local sleep_chance = sleep
  
        if Attack.act_is_spell( receiver, "effect_stun" ) then
          sleep_chance = sleep_chance + 10
        end
  
        sleep_chance = sleep_chance * ( 1 - receiver_res / 100 )
        rnd = Game.Random( 99 )
    
        if rnd < sleep_chance
        and not Attack.act_feature( receiver, "undead" )
        and not Attack.act_feature( receiver, "mind_immunitet" ) then
          local duration = apply_difficulty_level_talent_bonus( 2 )
       			effect_unconscious_attack( receiver, 1, duration )
       			Attack.act_damage_addlog( receiver, "add_blog_unconscious_" )
        else
          local duration = apply_difficulty_level_talent_bonus( 3 )
        	 effect_stun_attack( receiver, 1, duration )
        end
      end
    elseif not Attack.act_pawn( receiver )
    and not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "boss,pawn" )
    and stun ~= nil
    and stun ~= 0 then
      local receiver_level = Attack.act_level( receiver )

      if receiver_level < 5 then
        if stun < 100 then
          stun = stun + ( 4 - receiver_level ) * stun
        end

        stun = effect_chance( stun, "effect", "stun" )
        local receiver_res = Attack.act_get_res( receiver, "physical" )
        local stun_chance = stun * ( 1 - receiver_res / 100 )
        local rnd = Game.Random( 99 )
    
        if rnd < stun_chance then
          local duration = apply_difficulty_level_talent_bonus( 2 )
        	 effect_stun_attack( receiver, 0, duration )
        	 return -damage, addrage
        end
      end 
    end
  end 
	
  return damage,addrage
end


function features_burn( damage, addrage, attacker, receiver, minmax )
  if minmax == 0
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    --local receiver=Attack.get_target(1)  -- ����?
    local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )

    if burn ~= nil then
      common_fire_burn_attack( receiver, burn, 0, 3, damage )
      local res = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "res" ) )
  
      if res ~= nil then
        local a = Attack.atom_spawn( receiver, 0, "magic_oilfog" )
        local dmgts1 = Attack.aseq_time( a, "x" )
        local duration = apply_difficulty_level_talent_bonus( 3 )
        Attack.act_del_spell( receiver, "effect_burning_oil" )
        Attack.act_apply_spell_begin( receiver, "effect_burning_oil", duration, false )
        Attack.act_apply_res_spell( "fire", res, 0, 0, duration, false)
        Attack.act_apply_spell_end()
      end
    end
  end 

  if Attack.act_race( attacker, "demon" )
  or Attack.act_feature( attacker, "demon" )
  or Attack.act_race( receiver, "demon" )
  or Attack.act_feature( receiver, "demon" ) then
  	 return damage, addrage * 2
  elseif Attack.act_race( attacker, "orc" )
  or Attack.act_race( receiver, "orc" ) then
  	 return damage, addrage * 1.5
  else
  	 return damage, addrage
  end
end


--*************************************************************************
--   ������ �����������
--*************************************************************************

function post_spell_dragon_slayer( damage, addrage, attacker, receiver, minmax, userdata )
		local spell = "spell_dragon_slayer"

  if Attack.act_is_spell( attacker, spell ) then
		  local level = tonumber( userdata );
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

  		local bonus_damage = pwr_dragon_slayer( level, ehero_level )
    
    if Attack.act_feature( receiver, "dragon" ) then 
      return damage * ( 1 + bonus_damage / 100 ), addrage * ( 1 + bonus_damage / 100 )
    end 
	 else       	
		  if ( minmax == 0 ) then	Attack.act_posthitmaster( attacker, "post_spell_dragon_slayer", 0 ) end
  end

 	return damage, addrage
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


function special_priest( damage, addrage, attacker, receiver, minmax, userdata )
	 if Attack.act_race( receiver, "undead" ) then
  		damage = damage * 2
  		addrage = addrage * 2

    if ( minmax == 0 )
    and damage > 0
    and damage < Attack.act_totalhp( receiver ) then
    		local holy = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "holy" ) ) )
  
      if holy ~= nil then
        local rnd = Game.Random( 99 )
    
        if rnd <= holy then
          local duration = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) ) )
          effect_holy_attack( receiver, 0, duration )
        end
      end
    end
 	end

 	return damage, addrage
end


function post_spell_demon_slayer( damage, addrage, attacker, receiver, minmax, userdata )
	 local spell = "spell_demon_slayer"

  if Attack.act_is_spell( attacker, spell ) then
		  local level = tonumber( userdata );
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

  		local bonus_damage = pwr_demon_slayer( level, ehero_level )
    
    if Attack.act_feature( receiver, "demon" ) then 
	     return damage * ( 1 + bonus_damage / 100 ), addrage * ( 1 + bonus_damage / 100 )
    end

	 else
	   if ( minmax == 0 ) then
			   Attack.act_posthitmaster( attacker, "post_spell_demon_slayer", 0 )
		  end
 	end

 	return damage, addrage
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
      local belligerent = tonumber( Attack.act_spell_param( receiver, spell, "belligerent" ) )

      if belligerent == 4 then
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
  if minmax == 0
  and damage > 0 then
  		local spell = "spell_last_hero"

    if Attack.act_is_spell( receiver, spell ) then
  		  local dam, thp = math.floor( damage + .5 ), Attack.act_totalhp( receiver )
  		  local deadA = dam >= thp--Attack.act_damage(attacker,true)
      local level = tonumber( Attack.val_restore( receiver, "spell_last_hero_cast_level" ) )
      local heroname = Attack.act_spell_param( receiver, "spell_last_hero", "heroname" )
      local belligerent = tonumber( Attack.act_spell_param( receiver, "spell_last_hero", "belligerent" ) )

  		  if deadA
      and Attack.act_size( receiver ) > 0 then
        local rephits = Attack.val_restore( receiver, "spell_last_hero_resurrection_rephits" )
        dam = thp + rephits - dam
        Attack.act_aseq( 0, "cast" )
        local dmgts = Attack.aseq_time( 0, "x" )
        local tmp_spells = {}
        table.insert( tmp_spells, spell_resurrection_attack )
       	local cell = Attack.cell_get_corpse( receiver )
        tmp_spells[ 1 ]( level, receiver, belligerent, true )
      else
        special_bonus_spell( attacker, receiver, level, heroname, belligerent )
      end

  			 local dur = Attack.act_spell_duration( receiver, spell )

  			 if dur <= 1 then
  				  Attack.act_posthitslave( receiver, "post_spell_last_hero", 0 )
  				  Attack.act_del_spell( receiver, spell )
  				else
  				  Attack.act_spell_duration( receiver, spell, dur - 1 )
  				end

  				Attack.log( 0.001, "add_blog_last_hero", "target", blog_side_unit( receiver, -1 ), "special", "<label=spell_last_hero_name></color>" )
  		  
  		  if deadA
      and Attack.act_size( receiver ) > 0 then
        return math.min( dam, thp - 1 ), addrage * math.min( dam, thp - 1 ) / damage
      else
        return damage, addrage
      end
  	 else       	
		    Attack.act_posthitslave( receiver, "post_spell_last_hero", 0 )

    		return damage, addrage
    end
  else
    return damage, addrage
  end
end


-- NEW - based on special_spell, casts random beneficial spells
function special_bonus_spell( attacker, receiver, level, heroname, belligerent )
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )

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
      table.insert( tmp_spells, spell_dispell_attack )
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
    Attack.log_label( '' )
  
    local cast = Game.Random( 1, table.getn( tmp_spells ) )
    if tmp_spells[ cast ] == spell_haste_attack
    or tmp_spells[ cast ] == spell_bless_attack then
      tmp_spells[ cast ]( level, dmgts, receiver, belligerent )
    elseif tmp_spells[ cast ] == spell_dispell_attack then
      tmp_spells[ cast ]( level, receiver, belligerent, true )
    elseif tmp_spells[ cast ] == spell_magic_source_attack then
      tmp_spells[ cast ]( level, receiver, belligerent, heroname, true )
    else
      tmp_spells[ cast ]( level, receiver, belligerent, heroname )
    end
  
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
 	local freeze = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "freeze" ) ) )
  freeze = effect_chance( freeze, "effect", "freeze" )
	 local dragon = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "dragon" ) ) )
	
 	if dragon == 1 then	
	  	return feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
 	end 

 	if minmax == 0 and damage ~= 0 then -- damage=0 ����� �� �������������
		  local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )

    if burn ~= nil
    and damage > 0
    and damage < Attack.act_totalhp( receiver ) then
      burn = effect_chance( burn, "effect", "burn" )
    		--	if burn==nil then burn=100 end
    		--	if freeze==nil then freeze=100 end
      local duration = apply_difficulty_level_talent_bonus( 3 )
      common_fire_burn_attack( receiver, burn, 0, duration, damage, true )
    		local cold_fear = Attack.act_get_res( receiver, "fire" )
      local freeze_res = Attack.act_get_res( receiver, "physical" )
      local freeze_chance = math.max( 0, freeze - freeze_res )
      local rnd = Game.Random( 99 )
  
    		if ( rnd < freeze_chance or ( cold_fear >= 50 and freeze > 10 ) )
      and not Attack.act_feature( receiver, "golem" )
      and not Attack.act_feature( receiver, "freeze_immunitet" )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" ) then
        local duration = apply_difficulty_level_talent_bonus( 3 )
     			effect_freeze_attack( receiver, 0, duration )
     			--Attack.log_label("add_blog_freeze_") -- ��������
    		end
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

function feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
	 local dragon = Attack.get_custom_param( "dragon" )

  if dragon == "1" then
    if damage < 0 then
      damage = 0
    end

    local kdmg = att_rec_stuff( attacker, receiver )
    damage = damage * kdmg
  end 

  return damage
end

-- ***********************************************
-- * Poison or Unbaff
-- ***********************************************

function special_archer( damage, addrage, attacker, receiver, minmax )
	 local dragon = tonumber( Attack.get_custom_param( "dragon" ) )
	
 	if dragon == 1 then	
	  	return feat_dragon_arrow( damage, addrage, attacker, receiver, minmax )
 	end 

 	if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
	   local poison = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "poison" ) ) )
   	local tranc = tonum( Attack.get_custom_param( "tranc" ) )
   	local spell_name = ""
    --	if burn==nil then burn=100 end 
    --	if freeze==nil then freeze=100 end
    local poison_res = Attack.act_get_res( receiver, "poison" )
   	local rnd = Game.Random( 99 )
    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local poison_damage = damage * poison_chance / 200

    if rnd < poison_chance
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "poison_immunitet" ) then
      local duration = apply_difficulty_level_talent_bonus( 3 )
    	 effect_poison_attack( receiver, 0, duration, poison_damage, poison_damage )
    end 

    if tranc > 0 then
      local spells_to_delete = {}
     	local spell_count = Attack.act_spell_count( receiver )
      for i = 0, spell_count - 1 do 
      	 spell_name = Attack.act_spell_name( receiver, i )
      	 local spell_type = Logic.obj_par( spell_name, "type" )
      	 if spell_type == "bonus"
        and string.find( spell_name, "^totem_" ) == nil
        and string.find( spell_name, "special_summon_bonus" ) == nil then 
     					table.insert( spells_to_delete, spell_name );
  	 	  	end 
    		end 

    		local spell_del_count = table.getn( spells_to_delete )

    		if spell_del_count > 0 then
     			local del_spell = Game.Random( 1, spell_del_count )
     			Attack.act_del_spell( receiver, spells_to_delete[ del_spell ] )
    		  Attack.act_damage_addlog( receiver, "add_blog_unbaff_" )
    		  Attack.log_special( "<label=" .. spells_to_delete[ del_spell ] .. "_name>" ) -- ��������  
     			Attack.atom_spawn( receiver, 0, "magic_dispel", 0, true )
      end
    end
	 end 
	
  return damage, addrage
end


-- ***********************************************
-- * ������������ 
-- ***********************************************

function features_bleeding( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
 	if minmax == 0
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
  		if not Attack.act_feature( receiver, "plant" )
    and not Attack.act_feature( receiver, "undead" )
    and not Attack.act_feature( receiver, "golem" )
    and not hitbacking and Attack.act_enemy( receiver )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" ) then
      local power = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_bleeding", "power" ) ) -- ��������� �����
      local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "feat_bleeding", "duration" ) )
      duration = apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_bleeding", false )
      local bleeding_res = Attack.act_get_res( receiver, "physical" )
      power = math.min( 80, power - bleeding_res )

      if power > 0 then
        local duration_old
        duration_old = tonumber( Attack.act_spell_duration( receiver, "feat_lump_bleeding" ) )
        local message = "add_blog_bleeding_"

        if duration_old ~=nil and duration_old ~= 0 then
          if duration_old - duration > 0 then
            power = math.min( 80, power + duration_old - duration )
          end
          duration = math.max( duration, duration_old ) + 1
          message = "add_blog_hemoraging_"
        end
  
     			Attack.act_del_spell( receiver, "feat_bleeding" )
        Attack.act_apply_spell_begin( receiver, "feat_bleeding", duration, false )
    				Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
    				Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
        Attack.act_apply_spell_end()
   			  Attack.act_damage_addlog( receiver, message )
    	   Attack.log_special( blog_side_unit( receiver, -1 ) ) -- ��������
      end
  		end 
  end 

  return damage, addrage
end

-- ***********************************************
-- * ����� �������� � ���������
-- ***********************************************

function special_alchemist( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
   	local poison = tonum( Attack.get_custom_param( "poison" ) )
    local poison_res = Attack.act_get_res( receiver, "poison" )
  		local burn = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) ) )
    local burn_res = Attack.act_get_res( receiver, "fire" )
  		local holy = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "holy" ) ) )
    local rnd = Game.Random( 99 )

    if poison == 10 then
      local a = Attack.atom_spawn( 0, 0, "hll_acidcannon1", Attack.angleto( 0, receiver ) )
      local atk_x = Attack.aseq_time( 0, "x" )                   -- x time of attacker
 	    local acid_x = Attack.aseq_time( a, "x" )
   	  local acid_y = Attack.aseq_time( a, "y" )
     	Attack.aseq_timeshift( 0, acid_x - atk_x )
    end 
    
    poison = apply_difficulty_level_talent_bonus( poison )
    local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
    local poison_damage = damage * poison_chance / 200

    if rnd < poison_chance
    and not Attack.act_feature( receiver, "golem" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = apply_difficulty_level_talent_bonus( 3 )
      effect_poison_attack( receiver, 0, duration, poison_damage, poison_damage )
      --Attack.atom_spawn(receiver, 0, "hll_shaman_post")
    end

    local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
    local burn_damage = damage * burn_chance / 200

    if rnd < burn_chance
    and not string.find( Attack.act_name( receiver ), "orb" )
    and not string.find( Attack.act_name( receiver ), "cyclop" ) then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = apply_difficulty_level_talent_bonus( 3 )
      effect_burn_attack( receiver, 0, duration, burn_damage, burn_damage )
    end

    if rnd <= holy then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
      local duration = apply_difficulty_level_talent_bonus( 3 )
      effect_holy_attack( receiver, 0, duration )
    end
  end

  return damage, addrage
end

function features_weakness( damage, addrage, attacker, receiver, minmax )
  if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver ) then
    --local receiver=Attack.get_target(1)  -- ����?
    local weakness = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "weakness" ) ) )
    weakness = effect_chance( weakness, "effect", "weakness" )
    local rnd = Game.Random( 99 )
  
    if rnd < weakness
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature( receiver, "pawn" )
    and not Attack.act_feature( receiver, "boss" )
    and Attack.act_level( receiver ) < 5 then
      local duration = apply_difficulty_level_talent_bonus( 1 )
      effect_weakness_attack( receiver, 1, duration )
    end
  end 

  return damage, addrage
end

-- ***********************************************
-- * Push or Stun
-- ***********************************************

function special_cyclop( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then
   	local stun = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "stun" ) ) )
   	local push = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "push" ) ) )
    local stun_res = Attack.act_get_res( i, "physical" )
   	local rnd = Game.Random( 99 )

    if rnd < ( math.max( 0, stun - stun_res ) )
    and damage > 0
    and damage < Attack.act_totalhp( receiver )
    and not Attack.act_feature( receiver, "golem" )
    and not Attack.act_feature(receiver,"pawn")
    and not Attack.act_feature(receiver,"boss") then
      local duration = apply_difficulty_level_talent_bonus( 1 )
    	 effect_stun_attack( receiver, 0, duration )
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

      		if Attack.act_get_par( t, "dismove" ) == 0 then
        		Attack.act_move( movtime0, movtime1, t, c )
      		end
     	end
   	end 
 	end 
	
  return damage,addrage
end

-- ***********************************************
-- * ���������
-- ***********************************************

function features_rabid( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and not Attack.act_feature( receiver, "undead" )
  and not Attack.act_feature( receiver, "golem" )
  and not Attack.act_feature( receiver, "plant" )
  and not Attack.act_feature( receiver, "pawn" )
  and not Attack.act_feature( receiver,"boss" ) then
    local level = tonumber( Logic.obj_par( "feat_rabid", "level" ) ) -- ��������� �����
 	  local duration = tonumber( Logic.obj_par( "feat_rabid", "duration" ) )
  		local rabid = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "rabid" ) ) )
    rabid = effect_chance( rabid, "feat", "rabid" )

  		if duration == nil then duration = tonum( Attack.get_custom_param( "duration" ) ) end 
		
    duration = apply_difficulty_level_talent_bonus( apply_hero_duration_bonus( receiver, duration, "sp_duration_feat_rabid", false ) )
  		local rnd = Game.Random( 99 )

  		if rnd < rabid
    and Attack.act_level( receiver ) <= level then
    		Attack.act_belligerent( receiver, 16 )
   			Attack.act_del_spell( receiver, "feat_rabid" )
      Attack.act_apply_spell_begin( receiver, "feat_rabid", duration, false )
  				Attack.act_spell_param( receiver, "feat_rabid", "rabid", 1 )
      Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
  				Attack.atom_spawn( receiver, 0, "effect_bullhead", 0, true )
      Attack.act_apply_spell_end()
  		  Attack.act_damage_addlog( receiver, "add_blog_rabid_" )
  		  Attack.log_special( blog_side_unit( receiver, -1 ) ) -- ��������  
  		end 
 	end 

  return damage, addrage
end

function features_rabid_onremove(caa)

  -- ���������� ��� ��� ����
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
-- * ���������
-- ***********************************************

function features_curse( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and not Attack.act_feature( receiver, "golem" )
  and not ( Attack.act_feature( receiver, "undead" ) )
  and not Attack.act_feature( receiver, "pawn" )
  and not Attack.act_feature( receiver, "boss" ) then
    local level = tonumber( Logic.obj_par( "effect_curse", "level" ) )
		  local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_curse", "duration" ) )
		  local curse = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "curse" ) ) )
    curse = effect_chance( curse, "effect", "curse" )
		  local rnd = Game.Random( 99 )

  		if ( rnd < curse )
    and ( Attack.act_level( receiver ) <= level ) then
   			effect_curse_attack( receiver, 1, duration )
  		end 
 	end 

  return damage, addrage
end

-- ***********************************************
-- * ��������� 
-- ***********************************************

function features_sleep( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 ) then		
    local level = tonumber( Logic.obj_par( "effect_sleep", "level" ) )
    local duration = tonumber( Attack.get_custom_param( "duration" ) )

    if duration == nil then duration = tonum( Logic.obj_par( "effect_sleep", "duration" ) ) end 
    
    duration = apply_difficulty_level_talent_bonus( duration )
    local special = tonum( Attack.get_custom_param( "special" ) )		
  		local dod = Attack.get_custom_param( "dod" )
  		local ddd = true

 			if dod == "yes" then ddd = true else ddd = false end

  		local sleep = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "sleep" ) )	)
    sleep = effect_chance( sleep, "effect", "sleep" )
    local level2_chance = 50
    level2_chance = effect_chance( level2_chance, "effect", "sleep" )
    local level3_chance = 25
    level3_chance = effect_chance( level3_chance, "effect", "sleep" )
    local level4_chance = 10
    level4_chance = effect_chance( level4_chance, "effect", "sleep" )
   	local rnd = Game.Random( 99 )

  	 if special == 0 then
		    if ( rnd < sleep )
      and not Attack.act_feature( receiver, "golem" )
      and ( Attack.act_level( receiver ) <= level )
      and not ( Attack.act_feature( receiver, "undead" ) )
      and not ( Attack.act_feature( receiver, "mind_immunitet" ) )
      and damage > 0
      and damage < Attack.act_totalhp( receiver )
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
      and damage < Attack.act_totalhp( receiver )
      and not Attack.act_feature( receiver, "pawn" )
      and not Attack.act_feature( receiver, "boss" ) then
     			if Attack.act_level( receiver ) == 1
     			or ( Attack.act_level( receiver ) == 2 and rnd < level2_chance )
     			or ( Attack.act_level( receiver ) == 3 and rnd < level3_chance )
     			or ( Attack.act_level( receiver ) == 4 and rnd < level4_chance ) then
      				effect_sleep_attack( receiver, 2, duration, ddd )
      				Attack.act_damage_addlog( receiver, "add_blog_sleep_" )
     			end	
    		end 	
   	end 
 	end 

  return damage,addrage
end

-- ***********************************************
-- * ����������
-- ***********************************************

function features_charm( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 )
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and not Attack.act_feature( receiver, "golem" )
  and not ( Attack.act_feature( receiver, "undead" ) )
  and not Attack.act_feature( receiver, "pawn" )
  and not Attack.act_feature( receiver,"boss" ) then
    local level = tonumber( Logic.obj_par( "effect_charm", "level" ) )
		  local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_charm", "duration" ) )
		  local charm = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "charm" ) ) )
    charm = effect_chance( charm, "effect", "charm" )
  		local rnd = Game.Random( 99 )

  		if ( rnd < charm )
    and ( Attack.act_level( receiver ) <= level )
    and ( Attack.act_feature( receiver, "humanoid" ) ) then
  			 local caster_count = Attack.act_size( attacker )	-- ������� �����
  		--��������� ����� � ���� 
   			local caster_lead = Attack.act_leadership( attacker )
   			local target_lead = Attack.act_leadership( receiver )
   			local target_count = Attack.act_size( receiver )
  		-- ������� ����� ���������� �� ���������
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
    Attack.log_label( "add_blog_regen_1" ) -- ��������
    Attack.act_aseq( 0, "idle" )	

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
  and damage > 0
  and damage < Attack.act_totalhp( receiver )
  and not hitbacking
  and not Attack.act_feature( receiver, "mind_immunitet" )
  and not Attack.act_feature( receiver, "undead" )
  and not Attack.act_feature( receiver, "pawn" )
  and not Attack.act_feature( receiver, "boss" ) then
		  local fear = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "fear" ) ) )
    fear = effect_chance( fear, "effect", "fear" )
  		local level = tonumber( Attack.get_custom_param( "level" ) )
  		local duration = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) ) )
  		local rnd = Game.Random( 99 )

  		if rnd < fear
    and Attack.act_level( receiver ) <= level then
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
--[[	 local attack, attack_base = Attack.act_get_par( 0, "attack" )
 	local max_bonus = 11 -- ��������, ������� ����� �������� ������� ����� ������� �������
 	local need_count = 30 -- ���������� ��������, ������ +1 �����
  local new_attack = math.min( math.floor( Attack.act_size( 0 ) / need_count ), max_bonus - attack_base )]]
  local new_attack = math.floor( math.sqrt( Attack.act_size( 0 ) ) )
	
	 Attack.act_attach_modificator( 0, "attack", "comradeship_mod", new_attack )

 	return true
end


-- ***********************************************
-- * �������
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

function bear_after_move( pass )
	 if not pass
  and Attack.val_restore( "was_action" ) == "0"
  and not Attack.act_is_spell( 0, "effect_sleep" )
  and not Attack.act_is_spell( 0, "effect_unconscious" ) then
  		effect_sleep_attack( 0, 0, 3, true )

  		if Attack.act_size( 0 ) > 1 then 
			   Attack.log( 0.001, "add_blog_bsleep_2", "name", blog_side_unit( 0, 1 ) )
  		else
		   	Attack.log( 0.001, "add_blog_bsleep_1", "name", blog_side_unit( 0, 1 ) )
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
--	  Attack.log_special(blog_side_unit(receiver,false)) -- ��������  

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

-- New for Demons
function features_demon_creature( damage, addrage, attacker, receiver )
  if Attack.act_race( attacker, "demon" )
  or Attack.act_feature( attacker, "demon" )
  or Attack.act_race( receiver, "demon" )
  or Attack.act_feature( receiver, "demon" ) then
  	 return damage, addrage * 2
  else
  	 return damage, addrage
  end
end

-- New for Orcs
function features_orc_creature( damage, addrage, attacker, receiver )
  if Attack.act_race( attacker, "orc" )
  or Attack.act_race( receiver, "orc" ) then
  	 return damage, addrage * 1.5
  else
  	 return damage, addrage
  end
end

-- New for Shamans
function shaman_posthitslave( damage, addrage, attacker, receiver, minmax )
	 damage, addrage = features_orc_creature( damage, addrage, attacker, receiver )
  damage, addrage = features_mage( damage, addrage, attacker, receiver, minmax )

  return damage, addrage
end

-- New for Mages
function features_mage( damage, addrage, attacker, receiver, minmax )
	 if ( minmax == 0 )
  and damage > 0 then
    local unit_level = Attack.act_level( receiver )
    local unit_lead = Attack.act_leadership( receiver )
    local unit_count = Attack.act_size( receiver )

    if unit_lead == 1 then
      unit_lead = Attack.act_totalhp( receiver ) / unit_count
    end

    if mana_rage_gain_k == nil then
      mana_rage_gain_k = 1
    end

  		local mana = math.ceil( ( damage^(1/4) ) * mana_rage_gain_k )

    if mana > 0 then
      local prob = math.min( 100, math.ceil( unit_level * ( ( unit_lead * unit_count )^(1/3) ) * mana_rage_gain_k ) )
      local chance = Game.Random( 99 )
  
      if chance < prob then
        local cur_mana, max_mana, add_mana
    
        if AU.is_human( receiver ) then
      		  cur_mana = Logic.hero_lu_item( "mana", "count" )
    		    max_mana = Logic.hero_lu_item( "mana", "limit" )
    			   add_mana = math.min( mana, max_mana - cur_mana )
    			   Logic.hero_lu_item( "mana", "count", cur_mana + add_mana )
        else
          local ehero_level = tonum( Logic.enemy_hero_level() )
    
          if ehero_level > 0 then
        		  cur_mana = Logic.enemy_lu_item( "mana", "count" )
    		      max_mana = Logic.enemy_lu_item( "mana", "limit" )
    			     add_mana = math.min( mana, max_mana - cur_mana )
    			     Logic.enemy_lu_item( "mana", "count", cur_mana + add_mana )
          else
            add_mana = 0
          end
        end
    
    			 if add_mana > 0 then
      		  if Attack.act_size( receiver ) > 1 then 
    		      Attack.log( 0.001, "add_blog_mage_feature_2", "name", blog_side_unit( receiver ), "target", add_mana )
    			   else 
    				    Attack.log( 0.001, "add_blog_mage_feature_1", "name", blog_side_unit( receiver ), "target", add_mana )
    			   end 
    			 end
      end
    end
	 end

  return damage, addrage
end


-- New Blue Dragon zap
function features_zap( damage, addrage, attacker, receiver, minmax, userdata, hitbacking, hitback_enabled )
	 if ( minmax == 0 )
  and damage > 0 then
    local zapprob = apply_difficulty_level_talent_bonus( 25 )  -- note that this shoul
    local chance = Game.Random( 99 )
    
    if chance < zapprob then
      BLUEDRAGON_CELL_ID = Attack.act_uid( receiver )
    end
	 end

  return damage, addrage
end


-- New Bone Dragon Morale Penalty
function features_morale_penalty()
	 for i = 1, Attack.act_count() - 1 do
		  if Attack.act_enemy( i )
    and not Attack.act_feature( i, "undead" )
    and not Attack.act_feature( i, "golem" )
    and not Attack.act_feature( i, "plant" )
    and not Attack.act_feature( i, "holy" )
    and not Attack.act_feature( i, "mind_immunitet" )
    and not Attack.act_feature( i, "pawn,boss" ) then
			   Attack.act_del_modificator( i, "moral_penalty" )
			   Attack.act_del_modificator( i, "attack_bd" )
			   Attack.act_del_modificator( i, "defense_bd" )
			   Attack.act_del_modificator( i, "krit_bd" )
      local morale = AU.moral( Attack.get_caa( i ) )
      local current_value, base_value = Attack.act_get_par( i, "moral" )
      local penalty = -1

      if Attack.act_level( i ) < 3 then
        penalty = -3
      elseif Attack.act_level( i ) < 5 then
        penalty = -2
      end

			   Attack.act_attach_modificator( i, "moral", "moral_penalty", penalty, 0, 0, -100, false )
      local att_def_penalty, krit_penalty = get_moral_modifier( current_value + penalty, current_value )
      
      if att_def_penalty < 0 then
        Attack.act_attach_modificator( i, "attack", "attack_bd", 0, 0, att_def_penalty, -100, false )
        Attack.act_attach_modificator( i, "defense", "defense_bd", 0, 0, att_def_penalty, -100, false )
      end

      if krit_penalty < 0 then
        Attack.act_attach_modificator( i, "krit", "krit_bd", 0, 0, krit_penalty, -100, false )
      end
  		end
 	end

 	return true
end


function bone_dragon_ondamage( wnm, ts, dead )
	 if dead then
		  for i = 1, Attack.act_count() - 1 do
			   Attack.act_del_modificator( i, "moral_penalty" )
			   Attack.act_del_modificator( i, "attack_bd" )
			   Attack.act_del_modificator( i, "defense_bd" )
			   Attack.act_del_modificator( i, "krit_bd" )
		  end
	 end

 	return true
end


-- New Unicorn Magic Aura - for Unicorns
function features_magic_aura()
	 for i = 1, Attack.act_count() - 1 do
		  if Attack.act_ally( i )
    and not ( Attack.act_name( i ) == "unicorn" )
    and not ( Attack.act_name( i ) == "unicorn2" ) then
			   Attack.act_del_modificator( i, "magic_aura_1" )
      local bonus = apply_difficulty_level_talent_bonus( 20 )
      Attack.act_attach_modificator_res( i, "magic", "magic_aura_1", bonus, 0, 0, -100, false )
    end
  end

  return true
end


function unicorn_ondamage( wnm, ts, dead )
	 if dead then
		  for i = 1, Attack.act_count() - 1 do
			   Attack.act_del_modificator( i, "magic_aura_1" )
		  end
	 end

 	return true
end


-- New Unicorn Magic Aura2 - for Black Unicorns
function features_magic_aura2()
	 for i = 1, Attack.act_count() - 1 do
		  if Attack.act_enemy( i )
    and not ( Attack.act_name( i ) == "unicorn" )
    and not ( Attack.act_name( i ) == "unicorn2" ) then
			   Attack.act_del_modificator( i, "magic_aura_2" )
      local penalty = apply_difficulty_level_talent_bonus( 30 )
      Attack.act_attach_modificator_res( i, "magic", "magic_aura_2", -penalty, 0, 0, -100, false )
    end
  end

  return true
end


function unicorn2_ondamage( wnm, ts, dead )
	 if dead then
		  for i = 1, Attack.act_count() - 1 do
			   Attack.act_del_modificator( i, "magic_aura_2" )
		  end
	 end

 	return true
end


-- New Undead penalties based on day
function features_undead_penalty()
  if Game.DayTime() < 2
  and not Game.LocType( 'cemetery' )
  and not Game.LocType( 'lava' )
  and not Game.LocType( 'dungeon' ) then
  	 for i = 1, Attack.act_count() - 1 do
  		  if Attack.act_race( i ) == "undead"
      or Attack.act_feature( i, "undead" ) then
			     Attack.act_del_modificator( i, "undead_health_penalty" )
        local penalty = 25 * ( 2 - apply_difficulty_level_talent_bonus( 100 ) / 100 )

        if Attack.act_name( i ) == "ghost"
        or Attack.act_name( i ) == "ghost2" then
          penalty = penalty + 25 * ( 2 - apply_difficulty_level_talent_bonus( 100 ) / 100 )
        end

        Attack.act_attach_modificator( i, "health", "undead_health_penalty", 0, 0, -penalty, -100, false )
      end
    end
  end

  return true
end


-- Looks like you can only call 1 subturn modificator function so special callers are here
function vampire_subturn_modificator()
  transform_modificators()
  features_undead_penalty()
  
  return true
end


function bonedragon_subturn_modificator()
  features_morale_penalty()
  features_undead_penalty()
  
  return true
end


-- New! This is a slave function to features_zap and is called during the subturn to execute the retaliatory damage
function zap_apply_damage()
  if BLUEDRAGON_CELL_ID ~= nil
  and BLUEDRAGON_CELL_ID == Attack.act_uid( 0 ) then
    BLUEDRAGON_CELL_ID = nil
    Attack.act_aseq( 0, "spare" )
    local dmgts = Attack.aseq_time( 0, "x" )
    local shock = Attack.get_custom_param( "zapshock" )

    -- These checks are for when get_custom param doesn't seem to be working properly
    if shock == nil
    or shock == "" then
      shock = 75  -- this value (and the ones below) should match the zap* and custom_params of zap in BLUEDRAGON.ATOM
    end

    shock = apply_difficulty_level_talent_bonus( shock )
    shock = effect_chance( shock, "effect", "shock" )
    local typedmg = Attack.get_custom_param( "zaptypedmg" )

    if typedmg == nil
    or shock == "" then
      typedmg = "astral"
    end

    local level = tonum( Attack.get_custom_param( "zaplevel" ) )

    if level == nil
    or shock == "" then
      level = 5
    end

    local dmg_min_max = Attack.get_custom_param( "zapdamage" )

    if dmg_min_max == nil
    or shock == "" then
      dmg_min_max = "140-170"
    end

    local dmg_min, dmg_max = text_range_dec( dmg_min_max )
    local acnt = Attack.act_count()
    
    for j = 1, acnt - 1 do
      if ( Attack.act_enemy( j )
      or Attack.act_ally( j ) )
      and Attack.cell_dist( 0, j ) == 1 then
        local rnd = Game.Random( 99 )
		      Attack.atk_set_damage( typedmg, dmg_min, dmg_max )
        common_cell_apply_damage( j, dmgts )
        
        if Attack.act_is_spell( j, "effect_freeze" ) then
          shock = shock * 2
        end
        
        local shock_res = Attack.act_get_res( j, "astral" )
        local shock_chance = math.min( 100, shock * ( 1 - shock_res / 100 ) )
        
        if rnd < shock_chance
        and Attack.act_level( j ) <= level
        and not Attack.act_feature( j, "golem" ) then
          local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_shock", "duration" ) )
          effect_shock_attack( j, dmgts, duration )
        end
      end
    end
  end

  return true
end


function features_initiative_penalty()
	 for i = 1, Attack.act_count() - 1 do
		  if Attack.act_enemy( i )
    and Attack.act_level( i ) < 5 then
			   Attack.act_del_modificator( i, "initiative_penalty" )
      local penalty = -1

      if Attack.act_level( i ) < 3 then
        penalty = -2
      end

			   Attack.act_attach_modificator( i, "initiative", "initiative_penalty", penalty )
  		end
 	end

	 return true
end


function black_dragon_ondamage( wnm, ts, dead )
 	if dead then
  		for i = 1, Attack.act_count() - 1 do
			   Attack.act_del_modificator( i, "initiative_penalty" )
		  end
	 end

	 return true
end


function features_evasion(damage,addrage,attacker,receiver,minmax)

	if minmax == 0 then	
	-- ������ �������� - ���� �� ����� �����, �� ������� ������
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
        Attack.val_store( 0, "charges", apply_difficulty_level_talent_bonus( charges ) )
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
 	local bonus_damage = tonum( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "dragonslayer" ) ) )
   
  if Attack.act_feature( receiver, "dragon" ) then 
   	return damage * ( 1 + bonus_damage / 100 ), addrage * ( 1 + bonus_damage / 100 )
  end 
	  	
 	return damage,addrage
end
