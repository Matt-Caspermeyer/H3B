-- 0x00000100 - Ordinary only, 0x0000FE00 - No ordinary, 0x00000200- castle, 0x0000FD00 - no castle

function therock_idle()
  local r = Game.Random()
  if r <= 0.35 then
    Attack.act_aseq( 0, "rare" ) -- fist strike
    return 0
  elseif r <= 0.65 then
    Attack.act_aseq( 0, "extra" ) -- electro muscles
    return 1
  else
    Attack.act_aseq( 0, "spare" ) -- digging
    return 2
  end
end

function therock_posthit( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if Attack.act_feature( receiver, "mage" )
  or string.find( Attack.act_name( receiver ), "^arena_tower" ) then
		  return 2 * damage, 2 * addrage
 	end

 	return damage,addrage
end

--////////////////////////////////
--////////   QUAKE      //////////
--////////////////////////////////

function therock_quake() 
  local r = Game.Random()
--  local stunning_prob = tonumber( "0" .. Attack.get_custom_param("stunning") )
  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i )
    and Attack.act_takesdmg( i ) then
      local dead = Attack.act_damage( i )
      if not dead then
        local power = tonumber( "0" .. Attack.get_custom_param( "bleeding" ) ) -- назначаем бонус
        local duration = tonumber( "0" .. Attack.get_custom_param( "duration" ) ) + Logic.hero_lu_item( "sp_duration_feat_bleeding", "count" )
        if Game.Random( 99 ) < power then
          therock_bleeding( i, power, duration )
        end
      end

--      if not dead and Game.Random(100) < stunning_prob then
--          Attack.act_apply_spell_begin( i, "spirit_therock_stunning", 3, false )
--        --Attack.act_apply_par_spell( "attack", 0, -power, 0, 3, false)
--      Attack.act_apply_spell_end()
--      end
    end
  end

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2attack1" )
    Attack.cam_track_duration(3.6)
    if Game.ArenaShape() == 4 then
      if r <0.7 then
     			Attack.cam_track(0, 0, "spirit_cam_short_ships.track" )
    		else
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
    		end
    else
      if r <= 0.44 then
        Attack.cam_track(0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.88 then
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track(0, 0, "spirit_cam_short_2right.track" )
      end
    end
  else
    Attack.act_aseq( 0, "appear" )
    local idletype = therock_idle()
    Attack.act_aseq( 0, "attack1" )
    Attack.setnodimming()
    Attack.setnodimming( 0 )
    if Game.ArenaShape() == 1 then --//  castle
      if idletype == 0 then
        Attack.cam_track(0, 0, "therock_appear_rare_quake_castle.track" )
      elseif idletype == 1 then
        Attack.cam_track(0, 0, "therock_appear_extra_quake_castle.track" )
      else
        Attack.cam_track(0, 0, "therock_appear_spare_quake_castle.track" )
      end
    elseif Game.ArenaShape() == 3 then --// item
      if idletype == 0 then
        Attack.cam_track_duration(8.2) 
        Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      elseif idletype == 1 then
        Attack.cam_track_duration(9.4) 
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      else
         Attack.cam_track_duration(9.4) 
         Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      end
    elseif Game.ArenaShape() == 4 then  --// ships
      Attack.cam_track_duration(8.5)
      if (photo == 3) then 
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      elseif (photo == 2) then
        Attack.cam_track(0, 0, "spirit_cam_ships.track" )
      elseif (photo == 1) then
        Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      else
        Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      end
    else
      if idletype == 0 then
        Attack.cam_track(0, 0, "rock_rare_quake.track" )
      elseif idletype == 1 then
        Attack.cam_track(0, 0, "rock_extra_quake.track" )
      else
        Attack.cam_track(0, 0, "rock_spare_quake.track" )
      end
    end
  end

  local shake_time = Attack.aseq_time( 0, "quake" )

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i )
    and Attack.act_takesdmg( i ) then
      --[[local dead = Attack.act_damage(i)
      if dead then
        Attack.add_exp( Attack.act_exp(i) )
      end]]
      Attack.dmg_timeshift( i, shake_time )
      Attack.atom_spawn( i, shake_time, "thespikes_quake" )
      local hit_x = Attack.aseq_time( i, "x" )
      Attack.aseq_timeshift( i, shake_time - hit_x )
    end
  end

  spirit_after_hit()

  return true
end


-- New! Function for applying bleeding to targets
function therock_bleeding( target, power, duration )
  if target ~= nil then
    if not Attack.act_feature( target, "plant" )
    and not Attack.act_feature( target, "undead" )
    and not Attack.act_feature( target, "golem" )
    and Attack.act_enemy( target )
    and not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" ) then
      local bleeding_res = Attack.act_get_res( target, "physical" )
      power = math.min( 80, power - bleeding_res )
      if power > 0 then
        local duration_old = tonumber( Attack.act_spell_duration( target, "feat_lump_bleeding" ) )
  
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
  
       	Attack.act_del_spell( target, "feat_lump_bleeding" )
        Attack.act_apply_spell_begin( target, "feat_lump_bleeding", duration, false )
       	Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false )
       	Attack.act_apply_par_spell( "defense", 0, -power, 0, duration, false )
        Attack.act_apply_spell_end()
     	  Attack.act_damage_addlog( target, message )
        Attack.log_special( blog_side_unit( target, -1 ) ) -- работает
      end
      return true
    end 
  end 

  return false
end

--////////////////////////////////
--////////   SWORD      //////////
--////////////////////////////////

function therock_lump()
  local r = Game.Random()
  local target = Attack.get_target()
  local photo = Attack.photogenic( target )
  Attack.act_damage( target )
  local power = tonumber( "0" .. Attack.get_custom_param( "bleeding" ) ) -- назначаем бонус
  local duration = tonumber( "0" .. Attack.get_custom_param( "duration" ) ) + Logic.hero_lu_item( "sp_duration_feat_bleeding", "count" )
		
  therock_bleeding( target, power, duration )

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2attack2" )
    Attack.cam_track_duration(8.0)
    if Game.ArenaShape() == 4 then
      if r <0.7 then
     			Attack.cam_track(0, 0, "spirit_cam_short_ships.track" )
    		else
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
    		end
    else
      if r <= 0.33 then
        Attack.cam_track(0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.88 then
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track(0, 0, "spirit_cam_short_2right.track" )
      end
    end
  else
    Attack.act_aseq( 0, "appear" )
    local after_appear = Attack.aseq_time(0)
    local idletype = therock_idle()
    Attack.act_aseq( 0, "attack2" )
    Attack.setnodimming()
    Attack.setnodimming( 0, target )
--///////      if target ~= nil then
    if Game.ArenaShape() == 0 then
      if (photo > 0) then
        Attack.cam_track_duration(11.5)
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      else
        if idletype == 0 then
          Attack.cam_track(0, 225, 245, 0, target, "rock_rare_lump.track" )
        elseif idletype == 1 then
          Attack.cam_track(0, 255, 275, 0, target, "rock_extra_lump.track" )
        elseif idletype == 2 then
          Attack.cam_track(0, 255, 275, 0, target, "rock_spare_lump.track" )
        end
      end
    elseif Game.ArenaShape() == 1 then
      if idletype == 0 then
        Attack.cam_track(0, 225, 245, 0, target, "therock_appear_rare_lump_castle.track" )
      elseif idletype == 1 then
        Attack.cam_track(0, 255, 275, 0, target, "therock_appear_extra_lump_castle.track" )
      elseif idletype == 2 then
        Attack.cam_track(0, 255, 275, 0, target, "therock_appear_spare_lump_castle.track" )
      end
    elseif (Game.ArenaShape() == 3) or (Game.ArenaShape() == 4) then
      Attack.cam_track_duration(11.5)
      if (photo == 2) or (photo == 3) then
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      elseif (photo == 1) then
        Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      else
        Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      end
    else 
      if idletype == 0 then
        Attack.cam_track(0, 225, 245, 0, target, "therock_appear_rare_lump_2forest.track" )
      elseif idletype == 1 then
        Attack.cam_track(0, 255, 275, 0, target, "therock_appear_extra_lump_2forest.track" )
      elseif idletype == 2 then
        Attack.cam_track(0, 255, 275, 0, target, "therock_appear_spare_lump_2forest.track" )
      end
    end
--//      end
  end

  local start_time = Attack.aseq_time( 0, "start" )
  local end_time = Attack.aseq_time( 0, "end" )
  local hit_time = Attack.aseq_time( 0, "lump" )

  if target ~= nil then
    Attack.act_move( start_time, end_time, 0, target )
    --[[local dead = Attack.act_damage( target )
    if dead then
      Attack.add_exp( Attack.act_exp(target) )
    end]]
    Attack.dmg_timeshift(target,hit_time)
    local hit_x = Attack.aseq_time( target, "x" )
    Attack.aseq_timeshift( target, hit_time - hit_x )
  end

  spirit_after_hit()

  return true
end


function therock_lump_select()
  local acnt = Attack.act_count()

  for i=1,acnt-1 do
    if Attack.act_enemy(i) and Attack.act_takesdmg(i) then
      Attack.marktarget(i)
    end
  end

  return true
end


--////////////////////////////////
--////////   ROCKFALL     ////////
--////////////////////////////////

function rockfall_check_target(target)
 	return Attack.act_name(target)=="devatron" or (Attack.act_enemy(target) and Attack.act_takesdmg(target))
end

function therock_rockfall()
  local r = Game.Random()
  local n = tonumber( "0" .. Attack.get_custom_param("square") )
  local target = nil
  local temp = nil
  local photo = Attack.photogenic(Attack.get_target())
  
--  for i=0,n-1 do
--    local target = Attack.get_target(i)
--    if target ~= nil then
--      if not Attack.cell_is_empty(target) and rockfall_check_target(target) then
--        local dead = Attack.act_damage( target )
--        local stunning_prob = tonumber( "0" .. Attack.get_custom_param("stunning") )
--        local rnd=Game.Random(100)
--        if not dead and rnd < stunning_prob then
--          effect_stun_attack( target, 0, 3 )
--          Attack.act_apply_spell_end()
--        end
--      end
--    end
--  end

  -- spawn spirit at target

  if Attack.is_short_spirit_seq() then
   	Attack.act_aseq( 0, "2attack3" )
   	Attack.cam_track_duration(3.6)
  		if Game.ArenaShape() == 4 then
		    if r <0.7 then
    				Attack.cam_track(0, 0, "spirit_cam_short_ships.track" )
   			else
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
   			end
  		else
   			if (photo == 0) then
    				Attack.cam_track(0, 0, "spirit_cam_short_centre.track" )
   			elseif (photo == 1) then
    				Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
   			else
    				Attack.cam_track(0, 0, "spirit_cam_short_2right.track" )
   			end
  		end
  else
	   Attack.act_aseq( 0, "appear" )
   	local idletype = therock_idle()
   	Attack.act_aseq( 0, "attack3" )
--//	Attack.setnodimming()
   	Attack.setnodimming(0)

    for i=0,n-1 do
      temp = Attack.get_target(i)
      if temp ~= nil then
        if (target == nil) then
          target = temp
        end
        Attack.setnodimming( temp )
      end
    end

   	if target ~= nil then
    		if (photo == 0) then
     			if Game.ArenaShape() == 0 then
      				if idletype == 0 then
       					Attack.cam_track(0, 135, 165, 0, target, "rock_rare_rockfall.track" )
      				elseif idletype == 1 then
       					Attack.cam_track(0, 160, 190, 0, target, "rock_extra_rockfall.track" )
      				elseif idletype == 2 then
       					Attack.cam_track(0, 155, 185, 0, target, "rock_spare_rockfall.track" )
      				end
     			elseif Game.ArenaShape() == 1 then
      				if idletype == 0 then
       					if r <= 0.33 then
        						Attack.cam_track(0, 140, 165, 0, target, "therock_appear_rare_rockfall_castle.track" )
       					else
        						Attack.cam_track(0, 0, "therock_appear_spare_rockfall_castle_still.track" )
       					end
      				elseif idletype == 1 then
       					if r <= 0.33 then
        						Attack.cam_track(0, 160, 190, 0, target, "therock_appear_extra_rockfall_castle.track" )
       					else
        						Attack.cam_track(0, 0, "therock_appear_spare_rockfall_castle_still.track" )
       					end
      				elseif idletype == 2 then
       					if r <= 0.33 then
        						Attack.cam_track(0, 170, 185, 0, target, "therock_appear_spare_rockfall_castle.track" )
       					else
        						Attack.cam_track(0, 0, "therock_appear_spare_rockfall_castle_still.track" )
       					end
      				end
     			elseif Game.ArenaShape() == 4 then
      				Attack.cam_track_duration(8.0)
      				Attack.cam_track(0, 0, "spirit_cam_ships.track" )
     			else
      				Attack.cam_track_duration(8.0)
      				Attack.cam_track(0, 0, "spirit_cam_centre.track" )
     			end
    		elseif (photo == 2) then
     			if Game.ArenaShape() == 0 then
      				if idletype == 0 then
       					Attack.cam_track(0, 140, 165, 0, target, "therock_appear_rare_rockfall_2forest.track" )
      				elseif idletype == 1 then
       					Attack.cam_track(0, 160, 190, 0, target, "therock_appear_extra_rockfall_2forest.track" )
      				else
       					Attack.cam_track(0, 170, 185, 0, target, "therock_appear_spare_rockfall_2forest.track" )
      				end
     			elseif Game.ArenaShape() == 4 then
      				Attack.cam_track_duration(8.0)
      				Attack.cam_track(0, 0, "spirit_cam_ships.track" )
     			else
      				Attack.cam_track(0, 0, "therock_appear_spare_rockfall_castle_still.track" )
     			end
    		else
     			Attack.cam_track(0, 0, "therock_appear_spare_rockfall_castle_still.track" )
    		end
   	end
  end

--/////////////////////// camera end
  local drop_time = Attack.aseq_time( 0, "drop" )

  for i = 0, n - 1 do
    target = Attack.get_target( i )
    if target ~= nil then
      local cempt = Attack.cell_is_empty( target )
      if cempt or rockfall_check_target( target ) then
        local deviation = Game.Random()
        local a = Attack.atom_spawn( target, drop_time + deviation, "therock_droprocks" )
        Attack.act_aseq( a, "idle" )
        local hit_time = Attack.aseq_time( a, "bumc" ) + drop_time + deviation
        if not cempt then
          --[[local dead = Attack.act_damage( target )
          if dead then
            Attack.add_exp( Attack.act_exp(target) )
          end]]
          local hit_x = Attack.aseq_time( target, "x" )
          Attack.aseq_timeshift( target, hit_time - hit_x )
          Attack.dmg_timeshift( target, hit_time )
          local dead = Attack.act_damage( target )

          if not dead
          and not Attack.act_pawn( target )
          and not Attack.act_feature( target, "golem" )
          and not Attack.act_feature( target, "plant" )
          and not Attack.act_feature( target, "undead" )
          and not Attack.act_feature( target, "boss" ) then
            local stunning_prob = tonumber( "0" .. Attack.get_custom_param( "stunning" ) )
            local rnd = Game.Random( 99 )
         			local stun_res = Attack.act_get_res( target, "physical" )
            local stun_chance = math.max( 0, stunning_prob - stun_res )
            if rnd < stun_chance then
              local duration = tonumber( "0" .. Attack.get_custom_param( "duration" ) )
              effect_stun_attack( target, hit_time + 2, duration )
            end
          end
        end
      end
    end
  end

  spirit_after_hit()

  return true
end


function therock_rockfall_select()
  local n = tonumber( "0" .. Attack.get_custom_param("square") )
  Attack.multiselect(n)
  local ccnt = Attack.cell_count()

  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty(cell) then
      if Attack.cell_is_pass(cell) then
        Attack.marktarget(cell,false)
      end
    elseif (Attack.act_enemy(cell) and Attack.act_takesdmg(cell)) or Attack.act_ally(cell) then
      Attack.marktarget(cell,false)
    end
  end

  return true
end


function therock_wall_calccells()
  Attack.direction(true) -- enable direction selection mode
  Attack.multiselect(3)
  local ccnt = Attack.cell_count()

  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then
      Attack.marktarget(cell)
    end
  end

  return true
end


function wrap(x,a,b)
  if ( b==nil ) then return x - math.floor(x/a)*a;
  else return wrap( x-a, b-a ) + a; end
end


--////////////////////////////////
--////////   THE WALL     ////////
--////////////////////////////////


function therock_wall() 
  local r = Game.Random()
  local after_appear = 0
  local target = Attack.get_target()
  local photo = Attack.photogenic(target)
  
  if (target == nil) then return false end

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2attack4" )
    Attack.cam_track_duration(6.2)
  		if Game.ArenaShape() == 4 then
		    if r <0.7 then
    				Attack.cam_track(0, 0, "spirit_cam_short_ships.track" )
   			else
        Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
			   end
  		else
   			if (photo == 0) then
    				Attack.cam_track(0, 0, "spirit_cam_short_centre.track" )
   			elseif (photo == 1) then
    				Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
   			else
    				Attack.cam_track(0, 0, "spirit_cam_short_2right.track" )
   			end
  		end
  else
  		Attack.act_aseq( 0, "appear" )
  		local idletype = therock_idle()
  		after_appear = Attack.aseq_time(0)
  		Attack.act_aseq( 0, "attack4" )
  		Attack.setnodimming( 0 )
      
--	  if target ~= nil then
--		    if (photo == 0) then

  		if Game.ArenaShape() == 0 then
   			if (photo == 0) then
    				if idletype == 0 then
     					Attack.cam_track(0, 82, 116, 0, target, "therock_appear_rare_thewall_2forest.track" )
    				elseif idletype == 1 then
     					Attack.cam_track(0, 130, 156, 0, target, "therock_appear_extra_thewall_2forest.track" )
    				else
     					Attack.cam_track(0, 130, 156, 0, target, "therock_appear_extra_thewall_2forest.track" )
    				end
   			else
    				Attack.cam_track_duration(6.3)
    				Attack.cam_track(0, 0, "spirit_cam_centre.track" )
   			end
  		elseif Game.ArenaShape() == 1 then
      if (photo == 0) then
    				if idletype == 0 then
     					Attack.cam_track(0, 82, 110, 0, target, "therock_appear_rare_thewall_castle.track" )
    				elseif idletype == 1 then
     					Attack.cam_track(0, 130, 156, 0, target, "therock_appear_extra_thewall_castle.track" )
    				else
     					Attack.cam_track(0, 130, 156, 0, target, "therock_appear_extra_thewall_castle.track" )
    				end
   			else
    				Attack.cam_track_duration(6.3)
    				Attack.cam_track(0, 0, "spirit_cam_centre.track" )
   			end	
  		else
	     Attack.cam_track_duration(6.3)
		    if r <0.4 then
    				Attack.cam_track(0, 0, "spirit_cam_centre.track" )
   			else
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
   			end
  		end
  end
--end
--////// camera block end /////////
--end

  Attack.act_rotate( after_appear, after_appear + 10./25., 0, target )
  local health = tonumber( "0" .. Attack.get_custom_param( "health" ) )
  local defense = tonumber( Attack.get_custom_param( "wall_def" ) )
  local res_all = tonumber( Attack.get_custom_param( "res_all" ) )
  local ttl = tonumber( "0" .. Attack.get_custom_param( "ttl" ) )
  --Корректировка направления стены (поворот на 180, если необходимо)
  local wall_direction = Game.Dir2Ang( Attack.direction() ) + math.rad( 90 )
  --local sx, sy = Attack.act_get_center( 0 )
  --local tx, ty = Attack.act_get_center( target )
  local spirit_direction = Attack.angleto( 0, target ) --math.atan2(tx-sx, ty-sy) + math.pi
  --находим разницу между wall_direction и spirit_direction
  local diff_ang = wrap( wall_direction - spirit_direction, -math.pi, math.pi )

  if math.abs( diff_ang ) > math.pi / 2 then wall_direction = wall_direction + math.rad( 180 ) end

  local wall = Attack.atom_spawn( Attack.get_target(), after_appear, "thewall", wall_direction );
  Attack.act_hp( wall, health )
  Attack.act_set_par( wall, "health", health )
  Attack.act_set_par( wall, "defense", defense )
  Attack.act_attach_modificator_res( wall, "fire", "wall_res_fire", res_all, 0, 0, -100, false )
  Attack.act_attach_modificator_res( wall, "magic", "wall_res_magic", res_all, 0, 0, -100, false )
  Attack.act_attach_modificator_res( wall, "physical", "wall_res_physical", res_all, 0, 0, -100, false )
  Attack.act_attach_modificator_res( wall, "poison", "wall_res_poison", res_all, 0, 0, -100, false )
  Attack.val_store( wall, "moves", ttl )
  Attack.act_aseq( wall, "appear" )
  Attack.aseq_timeshift( wall, after_appear ) --ставим начало анимации на момент появления стены
  spirit_after_hit()
  Attack.log_label("add_log_stonewall") -- работает
  Attack.log_special(health)

  return true
end


function thewall_attack()
  local ttl = Attack.val_restore( 0, "moves" )
  ttl = ttl - 1
  if ttl == 0 then Attack.act_kill() else Attack.val_store( 0, "moves", ttl ) end

  return true
end
