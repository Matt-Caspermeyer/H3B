function gen_combat_hint( )
  local min_damage, max_damage, min_dead, max_dead, reverse_strike = Logic.dmg_params()

  -- Hack to get the new Thorn cast_sacrifice to show the hint properly - I didn't
  -- know how to get it to work "properly" as certain hints seem hardcoded.
  local apars = Logic.attack_params()

  if apars.name == "cast_sacrifice" then
    local heal = round( get_add_gain_bonus( common_apply_skill_bonus( tonumber( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_cast_sacrifice" ) )
    local giver_totalhp = Attack.act_totalhp( 0 )
    local giver_hp = round( giver_totalhp * heal / 100 )
    local cast_sacrifice_receiver = Attack.val_restore( 0, "cast_sacrifice_receiver" )
    local receiver_hp_before = Attack.act_hp( cast_sacrifice_receiver )
    local receiver_health = Attack.act_get_par( cast_sacrifice_receiver, "health" )
    local receiver_needed_hp = receiver_health - receiver_hp_before
    local giver_leftover_hp = giver_hp - receiver_needed_hp
    local count_diff = math.floor( 1 + giver_leftover_hp / receiver_health )
    local hero_leadership = Logic.hero_lu_item( "leadership", "count" )
    local receiver_leadership = Attack.act_leadership( cast_sacrifice_receiver )
    local receiver_name = Attack.act_name( cast_sacrifice_receiver )
    local receiver_lead_bonus = Logic.hero_lu_item( "sp_lead_unit_" .. receiver_name, "count" )
    local total_leadership_units = math.floor( hero_leadership / ( receiver_leadership * ( 1 - receiver_lead_bonus / 100 ) ) )
    local receiver_size = Attack.act_size( cast_sacrifice_receiver )
    local text_string

    if count_diff > 0 then
      text_string = "<label=dmg_hint_just_raise> " .. tostring( count_diff ) .. "<br>" .. "<label=dmg_hint_total_leadership> "

      if receiver_size + count_diff == total_leadership_units then
        text_string = text_string .. "<color=0,192,0>" .. total_leadership_units .. "</color> <label=dmg_hint_at_max_leadership>"

      elseif receiver_size + count_diff > total_leadership_units then
        local units_over = ( receiver_size + count_diff ) - total_leadership_units
        text_string = text_string .. "<color=192,0,0>" .. total_leadership_units .. "  (+" .. units_over .. "</color> <label=dmg_hint_over_max_leadership>"

      else
        local units_under = total_leadership_units - ( receiver_size + count_diff )
        text_string = text_string .. "<color=255,255,50>" .. total_leadership_units .. "  (-" .. units_under .. "</color> <label=dmg_hint_under_max_leadership>"
      end
    else
      text_string = "<label=dmg_hint_just_heal> " .. tostring( giver_hp )
    end

  		return text_string
  elseif apars.name == "cure2" then
    local receiver = Attack.val_restore( 0, "cast_sacrifice_receiver" )

    if Attack.act_race( receiver, "undead" ) then
      local damage = "<label=dmg_hint_dmg>"
      local dead = ""
      local ret = ""
  
      if min_dead + max_dead ~= 0 then
        dead = "<br>" .. "<label=dmg_hint_dead>"
      end

      return damage .. dead .. ret
    else
      local heal = get_add_gain_bonus( common_apply_skill_bonus( tonumber( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_cure" )
      local count = Attack.act_size( 0 )
      local dmg_type = Attack.get_custom_param( "typedmg" )
      local min_dmg, max_dmg = round( heal * count ), round( heal * count )
 			  local cure_hp = Game.Random( min_dmg, max_dmg )
 			  local real_cure = math.min( cure_hp, Attack.act_get_par( receiver, "health" ) - Attack.act_hp( receiver ) )
      local effectiveness = math.floor( real_cure / cure_hp * 100 )
 			  local res = "<label=dmg_hint_just_heal> " .. real_cure .. ".<br><label=dmg_hint_just_effectiveness> " .. effectiveness .. '%.'

  		  return res
    end
  else -- This is the normal "unhacked" section of code
    local damage = "<label=dmg_hint_dmg>"
    local dead = ""
    local ret = ""
  
    if min_dead + max_dead ~= 0 then
      dead = "<br>" .. "<label=dmg_hint_dead>"
    end

    if reverse_strike > 0 then
      ret = "<br>" .. "<label=dmg_hint_ret>"
    end
  
    return damage .. dead .. ret
  end
end


function range_to_text( a, b )
	if a == b then return tostring( a ) end

	return a .. '-' .. b
end


--Урон: Min-Max. Погибает: Min-Max существ. Если Min=Max, то выводится одно число Погибает: Min существ. Если погибает Min=0, а Max>1 то выводится Погибает до max существ. Если Min=Размеру стека, то выводится надпись Убить всех. Если враг возможно не умрет, и нанесет ответный удар, то еще добавляется надпись Враг ответит.
function gen_combat_damage ()
  local min_damage, max_damage, min_dead, max_dead, reverse_strike = Logic.dmg_params()

  return range_to_text( min_damage, max_damage )
end


function gen_combat_dead ()
  local min_damage, max_damage, min_dead, max_dead, reverse_strike = Logic.dmg_params()

  return range_to_text( min_dead, max_dead )
end


function blog_side_unit( unit, color, bel, size )
-- color=-1,0,1,2,3 без цвета, только цвет с именем, с цветом и стрелкой, только стрелка без имени, только цвет без имени
-- color=no,only,all,arrow,color без цвета, только цвет с именем, с цветом и стрелкой, только стрелка без имени, только цвет без имени
  if color == nil then color = 1 end

  -- There is a bug where sometimes blog_side_unit cannot get the unit's size, so it can also be an input
  if size == nil then
    size = Attack.act_size( unit )
  end
  --local ally=Attack.act_ally(unit)
  --if bel ~= nil then ally=Attack.act_ally(unit,bel) end
  if bel == nil then bel = Attack.act_belligerent( unit ) end
  local ally = bel == 1 or bel == 2
  --[[if Attack.act_is_spell(unit,"spell_magic_source") and not ally and not pawn then
  	ally=true
  elseif Attack.act_is_spell(unit,"spell_magic_source") and ally and not pawn then
  	ally=false
  end]]
  
  --if bel=="ally" then ally=true end 
  --if bel=="enemy" then ally=false end 
  
  local pawn = Attack.act_pawn( unit )
  local name = "<label=cpsn_" .. Attack.act_name( unit ) .. ">"
  local arrow = "<label=blog_ally_unit_img>"
  local side = "<label=blog_ally_color>"

  if ally ~= true then 
  	arrow = string.gsub( arrow, "ally", "enemy", 2 )
  	side = string.gsub( side, "ally", "enemy", 2 )
  end

  if size <= 1 then name = string.gsub( name, "cpsn", "cpn", 1 ) end
  
  if color == 1 or color == "all" then 
  	 return arrow .. side .. name .. "</color>"
 	end 

  if color == -1 or color == "no" then 
  	 return name
 	end 

  if color == 0 or color == "only" then 
   	return side .. name .. "</color>"
 	end 

  if color == 2 or color == "arrow" then 
   	return arrow
	 end 

  if color == 3 or color == "color" then 
   	return side
 	end 

  if color == 4 or color == "spell" then 
   	return "<label=blog_ally_spell_img>"
 	end 
	
  return name
end


function add_target( target, res, added_target_ids )
	local id = Attack.cell_id( Attack.get_cell( Attack.get_caa( target ) ) )

	if added_target_ids[ id ] then return res end
	--if next(added_target_ids) ~= nil then res = res..'<br>' end
	added_target_ids[ id ] = true

	if Attack.act_ally( target ) then res = res .. "<label=dmg_hint_format_ally>" else res = res .. "<label=dmg_hint_format_enemy>" end

 local min_dmg, min_dead = Attack.damage_results( target, 1 )
 local max_dmg, max_dead = Attack.damage_results( target, 2 )

 if Attack.act_size( target ) > 1 then
 	 res = res .. "<label=cpsn_"..Attack.act_name( target ) .. ">" .. ". "
 else
 	 res = res .. "<label=cpn_" .. Attack.act_name( target ) .. ">" .. ". "
 end

 res = res .. "</color><label=dmg_hint_simple_dmg> " .. range_to_text( min_dmg, max_dmg ) .. '.'

 if max_dead > 0 then
   res = res .. "<br><label=dmg_hint_simple_dead> " .. range_to_text( min_dead, max_dead ) .. '.'
	end

	return res .. '<br>'
end


function main_target_hint( target )
	 local res, targetid = ""

 	if target ~= nil
  and Attack.get_caa( target ) ~= nil
  and Attack.act_takesdmg( target )
  and Attack.act_applicable( target ) then
	   targetid = Attack.cell_id( Attack.get_cell( Attack.get_caa( target ) ) ) -- такая длинная комбинация нужна для многоклеточных атомов
	   local min_dmg, min_dead = Attack.damage_results( target, 1 )
	   local max_dmg, max_dead = Attack.damage_results( target, 2 )

	   res = "<label=dmg_hint_just_dmg> " .. range_to_text( min_dmg, max_dmg ) .. '.'

	   if max_dead > 0 then
			   res = res .. "<br><label=dmg_hint_just_dead> " .. range_to_text( min_dead, max_dead ) .. '.'
  		end

  		res = res .. '<br>'
 	end

 	return res, targetid
end


function magic_attack_hint_gen()
	 local target = Attack.get_target()

 	if Obj.name() == "spell_resurrection" then
	   local rephits = pwr_resurrection()
  		local real = math.max( 0, math.min( rephits, Attack.act_get_par( target,"health" ) * Attack.act_initsize( target ) - Attack.act_totalhp( target ) ) )
  		local raise = math.ceil( ( Attack.act_totalhp( target ) + real ) / Attack.act_get_par( target, "health" ) ) - Attack.act_size( target )

  		return "<label=dmg_hint_just_raise> " .. raise .. ".<br><label=dmg_hint_just_effectiveness> " .. math.floor(real/rephits*100) .. '%.'
 	end

 	if Obj.name() == "spell_pain_mirror" then
  		local percent_dmg = pwr_pain_mirror()
  		local last_dmg = tonum( Attack.val_restore( target, "last_dmg" ) )
  		Attack.atk_set_damage( "magic", last_dmg * percent_dmg / 100 )

  		return ( main_target_hint( target ) )
 	end

 	if Obj.name() == "spell_ghost_sword" then
		  local min_dmg, max_dmg, power = pwr_ghost_sword()
		  local k = 1 - math.floor( ( Attack.act_get_res( target, "physical" ) ) * ( 100 - power ) / 100 ) / 100
  		Attack.atk_set_damage( "physical", 0 )
		  Attack.atk_set_damage( "astral", min_dmg * k, max_dmg * k )
  		local r = main_target_hint( target )
		  Attack.atk_set_damage( "astral", 0 )
		  return r
 	end

 	if Obj.name() == "spell_sacrifice" then
 		 if Attack.get_cycle() == 0 then

 			local damage, power = pwr_sacrifice()
 		   Attack.atk_set_damage( "astral", damage, damage )
 
 		   return ( main_target_hint( target ) )
 		 else
 			  local count = math.floor( Attack.val_restore( "sacrifice_hp" ) / Attack.act_get_par( target, "health" ) )
 			  if Attack.act_is_spell( Attack.val_restore( "sacrifice_source" ), "special_magic_shield" ) then count = math.floor( count / 2 ) end
 
     	return "<label=dmg_hint_sacrifice_bonus> " .. count .. '.'
    end
  end
 
 	if Obj.name() == "spell_healing"
  and Attack.act_race( target, "undead" ) then
    local dmg_type = Logic.obj_par( Obj.name(), "typedmg" )
 		 local min_dmg, max_dmg = pwr_healing( nil, nil, true )
 	  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
 		 local res, targetid = main_target_hint( target )

		  return res
 	end
 
 	if Obj.name() == "spell_holy_rain" then
    local dmg_type = Logic.obj_par( Obj.name(), "typedmg" )
    local res, targetid = ""
  		local added_target_ids = {}

    if Attack.act_race( target, "undead" ) then
      local min_dmg, max_dmg = pwr_holy_rain( nil, true )
   	  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
 		   res, targetid = main_target_hint( target )

      res = ""
      if targetid ~= nil then res = add_target( target, res, added_target_ids ) end

    elseif Attack.act_need_cure( target )
    and Attack.act_ally( target )
    and not ( Attack.act_feature( target, "golem, magic_immunitet" ) )
    and not Attack.act_race( target, "demon" ) then
      local min_dmg, max_dmg = pwr_holy_rain( nil, false )
 			  local cure_hp = math.floor( Game.Random( min_dmg, max_dmg ) )
 			  local real_cure = math.min( cure_hp, Attack.act_get_par( target,"health" ) - Attack.act_hp( target ) )
      local effectiveness = math.floor( real_cure / cure_hp * 100 )
      res = "<label=dmg_hint_format_ally>"

      if Attack.act_size( target ) > 1 then
      	 res = res .. "<label=cpsn_"..Attack.act_name( target ) .. ">" .. ". "
      else
      	 res = res .. "<label=cpn_" .. Attack.act_name( target ) .. ">" .. ". "
      end

 			  res = res .. "</color><br><label=dmg_hint_just_heal> " .. real_cure .. ".<br><label=dmg_hint_just_effectiveness> " .. effectiveness .. '%.'
    end

   	for i = 1, 6 do
				  local target = Attack.get_target( i )

				  if target ~= nil
      and Attack.get_caa( target ) ~= nil
      and Attack.act_takesdmg( target )
      and Attack.act_applicable( target ) then
        if Attack.act_race( target, "undead" ) then
          local min_dmg, max_dmg = pwr_holy_rain( nil, true )
   	      Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
       			res = add_target( target, res, added_target_ids )

        elseif Attack.act_need_cure( target )
        and Attack.act_ally( target )
        and not ( Attack.act_feature( target, "golem, magic_immunitet" ) )
        and not Attack.act_race( target, "demon" ) then
          local min_dmg, max_dmg = pwr_holy_rain( nil, false )
     			  local cure_hp = math.floor( Game.Random( min_dmg, max_dmg ) )
     			  local real_cure = math.min( cure_hp, Attack.act_get_par( target,"health" ) - Attack.act_hp( target ) )
          local effectiveness = math.floor( real_cure / cure_hp * 100 )

          if res == "" then
            res = "<label=dmg_hint_format_ally>"
          else
            res = res .. "<br><label=dmg_hint_format_ally>"
          end
    
          if Attack.act_size( target ) > 1 then
          	 res = res .. "<label=cpsn_"..Attack.act_name( target ) .. ">" .. ". "
          else
          	 res = res .. "<label=cpn_" .. Attack.act_name( target ) .. ">" .. ". "
          end

     			  res = res .. "</color><br><label=dmg_hint_just_heal> " .. real_cure .. ".<br><label=dmg_hint_just_effectiveness> " .. effectiveness .. '%.'
        end
      end
    end

		  return res
 	end
 
  local dmg_type = Logic.obj_par( Obj.name(), "typedmg" )
  local func_name = string.gsub( Obj.name(), "^spell_", "pwr_" )
  if type( _G[ func_name ] ) == "function"
  and dmg_type ~= ""
  and dmg_type ~= nil then
 		 local min_dmg, max_dmg, par1, par2 = _G[ func_name ]()
 
 		 if Obj.name() == "spell_ice_serpent" then
 		   if Attack.act_feature( target, "freeze_immunitet" ) then min_dmg = min_dmg * freeze_im; max_dmg = max_dmg * freeze_im end
 		 end
 
 	  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )
 		 local res, targetid = main_target_hint( target )
 
 		 if Obj.name() == "spell_healing"
    and not Attack.act_race( target, "undead" ) then
 			  local cure_hp = math.floor( Game.Random( min_dmg, max_dmg + 0.45 ) )
 			  local real_cure = math.min( cure_hp, Attack.act_get_par( target,"health" ) - Attack.act_hp( target ) )
 			-- если на юните чума то берем не текущий макимум а макимальное из текущего и из параметров атома
 			-- t по атому - потому что есть прдедметы и заклинания увеличивающие здоровье
 			-- !при новой системе обновления тек. здоровья по изменению макс. это НЕ нужно, т.к. вначале юнит лечится, а потом снимается чума!
 			--[[if Attack.act_is_spell(target, "spell_plague") then 
 				local atom_cure = Attack.atom_getpar(Attack.act_name(target),"hitpoint")
 				local unit_cure = Attack.act_get_par(target,"health")
 				real_cure = math.max(atom_cure- Attack.act_hp(target),unit_cure- Attack.act_hp(target))
 			end ]]
 			  return "<label=dmg_hint_just_heal> " .. real_cure .. ".<br><label=dmg_hint_just_effectiveness> " .. math.floor( real_cure / cure_hp * 100 ) .. '%.'
 		 end
 
  		local added_target_ids = {}
 
  		if Obj.name() == "spell_lightning" --[[and Obj.spell_level() > 1]] then
      res = ""
 
      if targetid ~= nil then res = add_target( target, res, added_target_ids ) end
 
 			  local attacked_ids = {}
   			attacked_ids[ Attack.cell_id( target ) ] = true
 			  local front = { target }
 			  local count, dmg = par2, 1
 
 			  repeat
 
   		   if count == 0 then break end
   		    	count = count - 1
      				dmg = dmg * 0.5
   
   				   local new_front = {}
   				   -- Ударяем юнитов текущего фронта
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
   
   					  for i, act in ipairs( atkd ) do -- Атакуем тех, кого выбрали
   						   Attack.atk_set_damage( dmg_type, min_dmg * dmg, max_dmg * dmg )
   						   res = add_target( act, res, added_target_ids )
   						   attacked_ids[ Attack.cell_id( Attack.get_cell( act ) ) ] = true
      						-- Формируем следующий фронт
      						table.insert( new_front, act )
   					  end
   				 end
   
    				front = new_front
 
 			  until table.getn( front ) == 0
 
 		 end

  		if Obj.name() == "spell_ice_serpent" then
      res = ""

      if targetid ~= nil then res = add_target( target, res, added_target_ids ) end

			   local min_p_dmg, max_p_dmg = pwr_ice_serpent( "periphery" )
			   local epicenter = target
			   for i = 0, 5 do
				    local target = Attack.cell_adjacent( epicenter, i )

				    if target ~= nil
        and Attack.cell_present( target )
        and Attack.get_caa( target ) ~= nil
        and Attack.act_takesdmg( target )
        and Attack.act_applicable( target ) then
     					if Attack.act_feature( target, "freeze_immunitet" ) then
  						    Attack.atk_set_damage( dmg_type, min_p_dmg * freeze_im, max_p_dmg * freeze_im )   -- set custom damage for periphery
					     else
      						Attack.atk_set_damage( dmg_type, min_p_dmg, max_p_dmg )   -- set custom damage for periphery
					     end

					     res = add_target( target, res, added_target_ids )
				    end
			   end
    end

  		if Obj.name() == "spell_fire_rain"
    or Obj.name() == "spell_fire_ball" then
      res = ""

      if targetid ~= nil then res = add_target( target, res, added_target_ids ) end

			   if Obj.name() == "spell_fire_ball" then
				    local min_p_dmg, max_p_dmg = pwr_fire_ball( "periphery" )
				    Attack.atk_set_damage( dmg_type, min_p_dmg, max_p_dmg )
			   end

   			for i = 1, 6 do
				    local target = Attack.get_target( i )

				    if target ~= nil
        and Attack.get_caa( target ) ~= nil
        and Attack.act_takesdmg( target )
        and Attack.act_applicable( target ) then
     					res = add_target( target, res, added_target_ids )
				    end
			   end
		  end

		  return res
	 end

end


function spirit_attack_hint_gen()

	local res = ""
	local added_target_ids = {}

	if Attack.atk_name() == "rockfall" then

	  for i=0,Attack.get_targets_count()-1 do
	    local target = Attack.get_target(i)
	    if target ~= nil then
	      if not Attack.cell_is_empty(target) and rockfall_check_target(target) then
	        res = add_target( target, res, added_target_ids )
	      end
	    end
	  end
	  return res

	end

	local target = Attack.get_target()

	if Attack.atk_name() == "reaping" then
		Attack.atk_set_damage( "astral", tonumber(Attack.get_custom_param("kill"))*Attack.act_totalhp(target)/100.0 )
	end

	return (main_target_hint(target))

end
