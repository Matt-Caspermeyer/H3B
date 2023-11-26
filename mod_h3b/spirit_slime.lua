-- 0x00000100 - Ordinary only, 0x0000FE00 - No ordinary, 0x00000200- castle, 0x0000FD00 - no castle

--function slime_idle()
--  local r = Game.Random()
--  if r <= 0.35 then
--    Attack.act_aseq( 0, "rare" ) -- idle 1
--    return 0
--  elseif r <= 0.65 then
--    Attack.act_aseq( 0, "extra" ) -- idle 2
--    return 1
--  else
--    Attack.act_aseq( 0, "spare" ) -- idle 3
--    return 2
--  end
--end

function slime_idle()
    Attack.act_aseq( 0, "rare" )
    return 0
end

--***********************
--      рыбный отдел
--***********************

function slime_fishes_pass_cell( c )

  return c ~= nil and Attack.cell_present(c) and Attack.cell_is_empty(c) and Attack.cell_is_pass(c)

end

function slime_fishes_passattack_cell( c )

  return c ~= nil and Attack.cell_present(c) and
	((Attack.cell_is_empty(c) and Attack.cell_is_pass(c)) or (--[[Attack.act_enemy(c) and ]]Attack.act_takesdmg(c)))

end

function slime_fishes_attack_cell( c )

  return c ~= nil and Attack.cell_present(c) and --[[Attack.act_enemy(c) and]] Attack.act_takesdmg(c)

end

function slime_fishes_damage( c, tshift, dir )

  Attack.aseq_rotate( c, Attack.act_dir(c), dir + 3 )
   --[[local dead = Attack.act_damage(c)
  if dead then
    Attack.add_exp( Attack.act_exp(c) )
  end]]
  Attack.dmg_timeshift(c,tshift)
  local potr = Attack.aseq_time( c, "x" )
  Attack.aseq_timeshift( c, tshift - potr )


end


function spawn_fishes( cell, dir, tshift )

  local len = Attack.trace(cell,dir)
  local c_next = Attack.trace(0)

  local hidden = true
  local spawned = Attack.atom_spawn( c_next, tshift, "slimefish", Game.Dir2Ang(dir) )

  for i=1, len do

    local c = c_next
    c_next = Attack.trace(i)

      if hidden then
        if slime_fishes_passattack_cell(c_next) then

          if slime_fishes_pass_cell(c) then
            Attack.act_aseq( spawned, "appear", 0, 1 )
            hidden = false
          elseif slime_fishes_attack_cell(c) then
            local potr = Attack.aseq_time( spawned ) + tshift
            slime_fishes_damage( c, potr + g_appearx, dir )
            Attack.act_aseq( spawned, "appeara", 0, 1 )
            hidden = false
          else
            Attack.act_aseq( spawned, "hidemove", 0, 1 ) -- move under ground
          end

        else
          -- jumping

          if slime_fishes_pass_cell(c) then
            Attack.act_aseq( spawned, "jump", 0, 1 )
          elseif slime_fishes_attack_cell(c) then
            local potr = Attack.aseq_time( spawned ) + tshift
            slime_fishes_damage( c, potr + g_jumpx, dir )
            Attack.act_aseq( spawned, "jumpa", 0, 1 )
          else
            Attack.act_aseq( spawned, "hidemove", 0, 1 ) -- move under ground
          end

        end

      else
        if not slime_fishes_passattack_cell(c_next) then
          -- should hide
          if slime_fishes_pass_cell(c) then
            Attack.act_aseq( spawned, "hide", 0, 1 )
          else -- if slime_fishes_attack_cell(c) then
            local potr = Attack.aseq_time( spawned ) + tshift
            slime_fishes_damage( c, potr + g_hidex, dir )
            Attack.act_aseq( spawned, "hidea", 0, 1 )

          end
          hidden = true
        else
          -- move or attack
          if slime_fishes_attack_cell(c) then
            local potr = Attack.aseq_time( spawned ) + tshift
            slime_fishes_damage( c, potr + g_attackx, dir )
            Attack.act_aseq( spawned, "attack", 0, 1 )
          else
            Attack.act_aseq( spawned, "move", 0, 1 )
          end

        end
      end

  end

  Attack.aseq_remove( spawned, "hidemove" )
  local potracheno = Attack.aseq_time( spawned )
  if potracheno == 0 then potracheno = .001 end
  Attack.atom_ttl( spawned, potracheno )

  return potracheno
end

function rotodir( dir, adddir )

  dir = dir + adddir
  while dir < 0 do
    dir = dir + 6
  end

  while dir >= 6 do
    dir = dir - 6
  end

  return dir

end

function slime_fishes() --////////////////////////////////

  local dir = Attack.direction()
  local cell = Attack.get_target()
  local photo = Attack.photogenic(cell)
  local r = Game.Random()

  local function dmg_fishes( cell, dir )
	  for i=0, Attack.trace(cell,dir)-1 do
	    local c = Attack.trace(i)
        if slime_fishes_attack_cell(c) then Attack.act_damage(c) end
	  end
  end

  fishes_routine(dmg_fishes, cell, dir, 0, 0)
  local start_time_r, end_time_r = 0, .1

--/////////////// Camera block
  if Attack.is_short_spirit_seq() then
  	  Attack.act_aseq( 0, "2attack1" )
    Attack.cam_track_duration(4.0)
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
	start_time_r = Attack.aseq_time(0)
	slime_idle()
	end_time_r = Attack.aseq_time(0)
  	Attack.act_aseq( 0, "attack1" )
    if Game.ArenaShape() == 4 then
    	Attack.cam_track_duration(13.2)
        if r <0.7 then
			Attack.cam_track(0, 0, "spirit_cam_ships.track" )
		else
            Attack.cam_track(0, 0, "spirit_cam_2left.track" )
		end
    else
		if (photo == 0) then
	  		Attack.cam_track(0, 255, 300, 0, cell, "slime_appear_extra_slimefish_2forest.track" )
		else
		    Attack.cam_track_duration(13.2)
		    if r <= 0.44 then
        		Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      		elseif r <= 0.88 then
        		Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      		else
        		Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      		end
      	end
    end
  end
--/////////////// End of camera block

  local fish_time = Attack.aseq_time( 0, "fish" )
  local start_time = Attack.aseq_time( 0, "start" )
  local end_time = Attack.aseq_time( 0, "end" )

  Attack.act_move( start_time, end_time, 0, cell )
  Attack.act_rotate( start_time_r, end_time_r, 0, cell )

  g_attackx = Attack.aseq_time( "slimefish", "attack", "x" )
  g_jumpx = Attack.aseq_time( "slimefish", "jumpa", "x" )
  g_hidex = Attack.aseq_time( "slimefish", "hidea", "x" )
  g_appearx = Attack.aseq_time( "slimefish", "appeara", "x" )
  g_move = Attack.aseq_time( "slimefish", "move", "" )
  --g_appear = Attack.aseq_time( "slimefish", "appear", "" )
  --g_hide = Attack.aseq_time( "slimefish", "hide", "" )
  --g_appearattack = Attack.aseq_time( "slimefish", "appeara", "" )
  --g_hideattack = Attack.aseq_time( "slimefish", "hidea", "" )

  fishes_routine(spawn_fishes, cell, dir, fish_time, g_move)

  spirit_after_hit()

  return true
end

function fishes_routine(spawn_fishes, cell, dir, fish_time, g_move)

  spawn_fishes( cell, dir, fish_time )

  local cell2 = Attack.cell_adjacent( cell, dir )
  cell2 = Attack.cell_adjacent( cell2, dir )

  local rdl = rotodir(dir, -2)
  local rdr = rotodir(dir, 2)

  local cell2left = Attack.cell_adjacent( cell2, rdl )
  local cell2rite = Attack.cell_adjacent( cell2, rdr )

  spawn_fishes( cell2left, dir, g_move * 2 + fish_time + 0.11 )
  spawn_fishes( cell2rite, dir, g_move * 2 + fish_time + 0.17 )

  cell2 = Attack.cell_adjacent( cell2, dir )
  cell2 = Attack.cell_adjacent( cell2, dir )

  cell2left = Attack.cell_adjacent( cell2, rdl )
  cell2rite = Attack.cell_adjacent( cell2, rdr )

  cell2left = Attack.cell_adjacent( cell2left, rdl )
  cell2rite = Attack.cell_adjacent( cell2rite, rdr )

  spawn_fishes( cell2left, dir, g_move * 4 + fish_time + 0.07 )
  spawn_fishes( cell2rite, dir, g_move * 4 + fish_time + 0.07 )

end

function slime_fishes_highlight()

  local function spawn_fishes( cell, dir )

	  local len = Attack.trace(cell,dir)

	  for i=0,len-1 do

	    local c = Attack.trace(i)

          if slime_fishes_pass_cell(c) then Attack.cell_select(c, "fishsmall"..dir) end
          if slime_fishes_attack_cell(c) then Attack.cell_select(c, "avenemy") end

	  end

  end

  local dir = Attack.direction()
  local cell = Attack.get_target()

  Attack.cell_select( cell, "fishbig"..dir )
  fishes_routine(spawn_fishes, cell, dir, 0, 0)

  return true

end


function slime_fishes_calc_cells()

  Attack.direction(true) -- enable direction selection mode

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty(cell) then
      if Attack.cell_is_pass(cell) then
        Attack.marktarget(cell,false)
      end
    end
  end
  return true
end

--***********************
--     туман
--***********************
-- fog   --////////////////////////////////

function slimefog_selmove_h() --ftag:chga -- selegd

  return Attack.change_attack(0)

end

function slimefog_selmove() --ftag:chga -- selegd

  return Attack.change_attack(1)

end

function slimefog_hackmove()


  -- no more moves?
  -- убираем блок по ресту в камменты
  --[[local rest = Game.SpiritRest( "slime" )
  if rest == 0 then

--	local time = Attack.val_restore("fog_time")
--	if time == nil then time = tonumber( Attack.get_custom_param("time")) end 
--	if time == 0 then
    local acnt = Attack.act_attach( 0 )
    for i=0,acnt-1 do
      Attack.act_remove( Attack.act_attach( 0, i ), 1 )
    end
    Attack.act_remove( 0, 1 )
    return true

  end]]


  local found = nil
  local maxcnt = 0

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    local curcnt = 0

    if Attack.act_nonhuman( cell ) then
      curcnt = 1.5
    end

    for dir=0,5 do
      local c = Attack.cell_adjacent( cell, dir )
      if Attack.act_nonhuman( c ) then
        curcnt = curcnt + 1
      end
    end

    if curcnt > maxcnt then
      found = cell
      maxcnt = curcnt
    end
  end

  local movetime = 1
  local mypos = Attack.get_cell(0)
  if found ~= nil and Attack.cell_id(found) ~= Attack.cell_id(mypos) then

    local dir = Game.Ang2Dir( Attack.angleto( 0, found ) )
    local cell = Attack.cell_adjacent( 0, dir )
    if Attack.cell_present( cell ) then
      Attack.act_move( 0, movetime, 0, cell )
      spawn_splashes( 0, cell, movetime )
      mypos = cell
    end

  end


  -- proceed damage here

  local min_dmg,max_dmg = text_range_dec(Attack.val_restore("damage"))
  local dmg_type, was_damage = "poison"--Attack.get_custom_param("typedmg")
  Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)

  for dir=0,5 do
    local c = Attack.cell_adjacent( mypos, dir )
      if --[[Attack.act_nonhuman(c) and]] Attack.act_takesdmg(c) then
        common_cell_apply_damage(c, movetime)
        was_damage = true
     end
  end
  if --[[Attack.act_nonhuman(mypos) and]] Attack.act_takesdmg(mypos) then
    common_cell_apply_damage(mypos, movetime)
    was_damage = true
  end

  if was_damage then Attack.log_label("") else Attack.log_label("null") end

	local time = Attack.val_restore("time")
	if was_damage then time = time - 1 end
	if time <= 0 then
		local t = Attack.aseq_time(0) + .2
	    local acnt = Attack.act_attach( 0 )
	    for i=0,acnt-1 do
	      Attack.act_remove( Attack.act_attach( 0, i ), t )
	    end
	    Attack.act_remove( 0, t )
	end
	Attack.val_store("time", time)

  return true

end

function slimefog_move() -- slimefog attack (move body to enemies)

  -- do nothing here?
  return true

end

function spawn_splashes( fog, where, tshift )

  local acnt = Attack.act_attach( fog )
  for i=0,acnt-1 do
    Attack.act_remove( Attack.act_attach( fog, i ), tshift )
  end

  for dir=0,5 do
    local c = Attack.cell_adjacent( where, dir )
      if Attack.cell_present(c)--[[ and (Attack.cell_is_empty(c) or Attack.act_nonhuman(c))]] then
        local splash = Attack.atom_spawn(c,tshift,"slimesplashes")
        Attack.act_attach( fog, splash, tshift+0.001 )
     end
  end
  if Attack.cell_present(where)--[[ and (Attack.cell_is_empty(where) or Attack.act_nonhuman(where))]] then
    local splash = Attack.atom_spawn(where,tshift,"slimesplashes")
    Attack.act_attach( fog, splash, tshift+0.001 )
  end


end
--/////////////////////////////////////////////////////
function slime_fog() --////////////////////////////////

  local cell = Attack.get_target()
  local photo = Attack.photogenic(cell)
  local r = Game.Random()

  local start_time_r, end_time_r = 0, .1

  if Attack.is_short_spirit_seq() then
		Attack.act_aseq( 0, "2attack2" )
		Attack.cam_track_duration(4.0)
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
		start_time_r = Attack.aseq_time(0)
		slime_idle()
		end_time_r = Attack.aseq_time(0)
		Attack.act_aseq( 0, "attack2" )
    	if Game.ArenaShape() == 4 then
    		Attack.cam_track_duration(13.2)
        	if r <0.7 then
				Attack.cam_track(0, 0, "spirit_cam_ships.track" )
			else
            	Attack.cam_track(0, 0, "spirit_cam_2left.track" )
			end
    	else
			if (photo == 0) then
	  			Attack.cam_track(0, 255, 320, 0, cell, "slime_appear_extra_fog_forest.track" )
			else
		    	Attack.cam_track_duration(13.2)
		    	if r <= 0.44 then
        			Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      			elseif r <= 0.88 then
        			Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      			else
        			Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      			end
      		end
    	end	

--/////////////// End of camera block
  end

  -- remove an existent cloud
  for act=1, Attack.act_count()-1 do
  	if Attack.act_name(act) == "slimefog" then
	    local acnt = Attack.act_attach( act )
	    for i=0,acnt-1 do
	      Attack.act_remove( Attack.act_attach( act, i ), 0 )
	    end
	    Attack.act_remove( act, 0 )
	    break
	end
  end


  local fog_time = Attack.aseq_time( 0, "fog" )
  local start_time = Attack.aseq_time( 0, "start" )
  local end_time = Attack.aseq_time( 0, "end" )
  local dir = Attack.direction()

  Attack.act_move( start_time, end_time, 0, cell )
  Attack.act_rotate( start_time_r, end_time_r, 0, cell )
  local fog = Attack.atom_spawn(cell,fog_time,"slimefog")
  Attack.val_store(fog, "damage", Attack.get_custom_param("dmg.0")..'-'..Attack.get_custom_param("dmg.1"))
  Attack.val_store(fog, "time", Attack.get_custom_param("time"))
-- запускаем счетчик ходов

  spawn_splashes( fog, cell, fog_time + 0.5 )

  spirit_after_hit()
  
  Attack.log(fog_time, "slime_fog", "name", "<label=cpn_slime>", "target", "<label=cpn_slimefog>")
  return true

end

function slime_fog_calc_cells()

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    if Attack.cell_present(cell) then
      Attack.marktarget(cell,false)
    end
  end
  Attack.multiselect(7)
  return true
end


---------------------------------
-------------ѕлювокк-------------
---------------------------------

function find_t_vx_vy(angle,dist,y0,y,g)--дл€ заданного начального угла полЄта angle и рассто€ни€ dist до точки приземлени€ на высоте y при начальной высоте y0 возвращает врем€ полЄта, а также x,y-составл€ющие начальной скорости

  if g == nil then g = 9.81 end

  local tg_a = math.tan(angle)
  local e = y0 - y + tg_a * dist
  local t = math.sqrt( 2 * e / g )
  local vx = dist * math.sqrt( g / ( 2 * e ) )

  return t, vx, vx * tg_a

end

function find_x_y_by_t(t,vx,vy,y0,g)--возвращает координаты объекта дл€ времени t и заданных параметров полета

  if g == nil then g = 9.81 end

  return vx * t, y0 + vy * t - (g * t*t) / 2

end

function slime_spittle()
  local r = Game.Random()
  local target = Attack.get_target()
  local photo = Attack.photogenic(target)
  local start_time_r, end_time_r = 0, .1
  Attack.act_damage( target );

  if Attack.is_short_spirit_seq() then
	   Attack.act_aseq( 0, "2attack3" )
  		Attack.cam_track_duration(4.0)
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
	   start_time_r = Attack.aseq_time(0)
	   slime_idle()
 	  end_time_r = Attack.aseq_time(0)
	   Attack.act_aseq( 0, "attack3" )

--/////////////// Camera block
    if Game.ArenaShape() == 4 then
    		Attack.cam_track_duration(13.2)
        if r <0.7 then
      				Attack.cam_track(0, 0, "spirit_cam_ships.track" )
     			else
          Attack.cam_track(0, 0, "spirit_cam_2left.track" )
     			end
    else
 			  if (photo == 0) then
	  			  Attack.cam_track(0, 260, 290, 0, target, "slime_appear_extra_spit_forest.track" )
   			else
		    	 Attack.cam_track_duration(13.2)
		    	 if r <= 0.44 then
        		Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      		elseif r <= 0.88 then
        		Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      		else
        		Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      		end
      end
    end

--/////////////// End of camera block
  end

  Attack.act_rotate( start_time_r, end_time_r, 0, target )
  local spittle_start = Attack.aseq_time( 0, "start" );
  local spittle = Attack.atom_spawn(0, spittle_start, "slime_spit", Attack.angleto(0, target))
  local time_step = 1./25. --временной шаг дл€ разбиени€ процесса полЄта на дискретные анимац. последо-ти
  local dist = Attack.cell_mdist(0, target)
  local sx, sy, y0 = Attack.act_attachment_pos( 0, "throw", Attack.angleto(0, target) ) --Attack.act_get_center( 0 )
  local tx, ty, yd = Attack.act_get_center( target )
  local dx, dy = (tx-sx)/dist, (ty-sy)/dist --вектор направлени€ плевка
  local t, vx, vy = find_t_vx_vy(math.rad(45), dist, y0, yd + 1)
  local steps = math.ceil( t/time_step )

  if steps <= 0 then return false end

  Attack.atom_ttl( spittle, t+.01 )
  local hit_time = t + spittle_start
  local step = t / steps
  t = step
  --local prev = nil
  for i = 1, steps--[[+1]] do
    local l, z = find_x_y_by_t(t, vx, vy, y0)
    local x, y = sx + dx * l, sy + dy * l
    --if prev ~= nil then
	   Attack.act_transformto( t - step + spittle_start, t + spittle_start, spittle, x, y, z )
    --end

    if i == steps then Attack.atom_spawn(target, t + spittle_start, "slime_spittle_poison", Attack.angleto(0, target)) end

    --prev = pos
    t = t + step

  end

-- если резист к €ду не мексимальный, то отравл€ем
  if not Attack.act_feature( target, "golem" ) then
   	local poisonresist = Attack.act_get_res(target,"poison")
    local dmg_min = tonumber( Attack.get_custom_param( "poison_min" ) )
    local dmg_min2 = tonumber( Attack.get_custom_param( "damage.poison.0" ) )
    local dmg_max = tonumber( Attack.get_custom_param( "poison_max" ) )
    local duration = 3 + Logic.hero_lu_item( "sp_duration_effect_poison", "count" )
    if poisonresist<80 then
      local dmg_min_old, dmg_max_old, duration_old
      dmg_min_old = tonumber( Attack.act_spell_param( target, "spirit_slime_poison", "dmg_min" ) )
      dmg_max_old = tonumber( Attack.act_spell_param( target, "spirit_slime_poison", "dmg_max" ) )
      duration_old = tonumber( Attack.act_spell_duration( target, "spirit_slime_poison" ) )
  
      if dmg_min_old ~= nil then
        dmg_min = dmg_min + dmg_min_old / 4
      end
  
      if dmg_max_old ~= nil then
        dmg_max = dmg_max + dmg_max_old / 4
      end
  
      if duration_old ~=nil and duration_old ~= 0 then
        duration = math.max( duration, duration_old ) + 1
      end
  
    	 local power=tonumber(Logic.obj_par("spirit_slime_poison","power"))
    		Attack.act_apply_spell_begin( target, "spirit_slime_poison", duration, false )
      Attack.act_apply_par_spell( "attack", 0, -power, 0, duration, false)
     	Attack.act_apply_spell_end()
     	Attack.act_spell_param( target, "spirit_slime_poison", "dmg_min", dmg_min, "dmg_max", dmg_max )  -- считывает параметры атаки спирита и записывает их в параметры навешенного заклинани€
   	end 
  	
    Attack.act_apply_spell_begin( target, "spirit_slime_poison", duration, false )
    Attack.act_apply_par_spell( "attack", 0, -20, 0, duration, false)
    Attack.act_apply_spell_end()
    Attack.act_spell_param( target, "spirit_slime_poison", "dmg_min", dmg_min, "dmg_max", dmg_max )
  end

  --[[local dead = Attack.act_damage( target )
  if dead then
    Attack.add_exp( Attack.act_exp(target) )
  end]]
  Attack.dmg_timeshift(target, hit_time)
  local hit_x = Attack.aseq_time( target, "x" )
  Attack.aseq_timeshift( target, hit_time - hit_x )
  spirit_after_hit()

  return true
end


function slime_spittle_poison_attack()
  local target = Attack.get_target()

  if Attack.get_caa(target) ~= nil then
	   Attack.atk_set_damage("poison",
	  	Attack.act_spell_param(target, "spirit_slime_poison", "dmg_min"),
	  	Attack.act_spell_param(target, "spirit_slime_poison", "dmg_max"))
	  	Attack.atom_spawn(target, 0, "effect_poison",0,true)
	  	-- при срабаттывании отравлени€ —лиима снимаетс€ с юнита ќчарование
 	  Attack.act_del_spell(target,"effect_charm")
	   common_cell_apply_damage(target, 1)
 			local count=Attack.act_size(target)    
	 		local damage,dead=Attack.act_damage_results(target)

 			if dead==nil then dead=0 end
--add_blog_trap_2=^blog_td0^[spell] срабатывает и наносит [damage] урона. [target]: [dead] погибает. [troopdef]	
 			local td=""
 			if damage ~= nil then
	  			if dead>0 then
			   		if count==dead then td="<label=troop_defeated>" end
  
     			Attack.log("add_blog_dampoison_2","damage",damage,"dead",dead,"name",blog_side_unit(target,-1),"troopdef",td)
	  			else
	    			Attack.log("add_blog_dampoison_1","damage",damage,"dead",dead,"name",blog_side_unit(target,-1),"troopdef",td)
   			end
		 	end
  end

  return true
end


--///////////////////////////////
--//////////// GLOT  ////////////
--///////////////////////////////



function slime_glot() --////////////////////////////////
  local target = Attack.get_target()
  local photo = Attack.photogenic( target )
  local r = Game.Random()
  local start_time_r, end_time_r = 0, .1

  if Attack.is_short_spirit_seq() then
	   Attack.act_aseq( 0, "2attack4" )
  		Attack.cam_track_duration( 4.0 )

    if Game.ArenaShape() == 4 then
      if r <0.7 then
    				Attack.cam_track( 0, 0, "spirit_cam_short_ships.track" )
			   else
       	Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
			   end
    else
      if r <= 0.40 then
        Attack.cam_track( 0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.60 then
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track( 0, 0, "spirit_cam_short_2right.track" )
     	end
  		end
  else
	   Attack.act_aseq( 0, "appear" )
	   start_time_r = Attack.aseq_time( 0 )
	   slime_idle()
 	  end_time_r = Attack.aseq_time( 0 )
 	  Attack.act_aseq( 0, "attack4" )

   	if Game.ArenaShape() == 4 then
    		Attack.cam_track_duration( 13.2 )

      if r <0.7 then
				    Attack.cam_track( 0, 0, "spirit_cam_ships.track" )
			   else
       	Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
			   end
   	else
   			if (photo == 0) then
	  			  Attack.cam_track( 0, 255, 300, 0, target, "slime_appear_extra_slimefish_2forest.track" )
			   else
		    	 Attack.cam_track_duration( 13.2 )

 		    	if r <= 0.40 then
         	Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
       	elseif r <= 0.60 then
        		Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
       	else
        		Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
       	end
      end
    end
  end

  local start_time = Attack.aseq_time( 0, "start" )
  local end_time = Attack.aseq_time( 0, "end" )
  Attack.act_move( start_time, end_time, 0, target )
  Attack.act_rotate( start_time_r, end_time_r, 0, target )
  local t = Attack.aseq_time( 0,"armour" )
  local atom = Attack.atom_spawn( target, t, "glot", 1.57 )
  Attack.act_animate( atom, "appear", t )
  Attack.act_set_armour( target, atom, t )
  Attack.val_store( atom, "balls", 5 )
  local health = tonumber( "0" .. Attack.get_custom_param( "health" ) )
  Attack.act_hp( atom, health )
  Attack.act_set_par( atom, "health", health )
  local duration = tonumber( "0" .. Attack.get_custom_param("duration") )
  local res_all = tonumber( Attack.get_custom_param( "res_all" ) )
  Attack.act_attach_modificator_res( atom, "fire", "glot_res_fire", res_all, 0, 0, duration, false )
  Attack.act_attach_modificator_res( atom, "magic", "glot_res_magic", res_all, 0, 0, duration, false )
  Attack.act_attach_modificator_res( atom, "physical", "glot_res_physical", res_all, 0, 0, duration, false )
  Attack.act_attach_modificator_res( atom, "poison", "glot_res_poison", res_all, 0, 0, duration, false )
  Attack.act_apply_spell_begin( target, "spirit_slime_glot", duration, false )
  Attack.act_apply_par_spell( "dismove", 1, 0, 0, duration, false)
  Attack.act_apply_spell_end()
 	Attack.log( "slime_glot", "name", "<label=cpn_glot>", "target", blog_side_unit( target, -1 ) )
  spirit_after_hit()
  
  return true

end

function glot_idle()
	 local n = math.max( 1, math.floor( Attack.act_hp( 0 ) * 5 / Attack.act_get_par( 0, "health" ) ) )
	 Attack.val_store( "balls", n )
	 Atom.animate( "idle" .. n )

end

function glot_ondamage( wnm, ts, dead )
	 if dead then
	   Attack.val_store( "dead", 1 )
		  local cl = Attack.get_caa( Attack.get_cell( 0 ) )
		  Attack.act_del_spell( cl, "spirit_slime_glot" )
	end

	return true
end

function spirit_slime_glot_onremove( target, duration_end )
	 local arm = Attack.act_get_armour( target )

	 if arm ~= nil
  and Attack.act_hp( arm ) > 0
  and Attack.val_restore( arm, "dead" ) ~= 1 then
	   Attack.act_set_armour( target, nil )
	 end

 	--Attack.log("slime_glot_remove","name","<label=cpn_glot>")
 	return true
end

function gen_glot_health()
	 local hp = 0
 	local target = Attack.act_get_armour( 0 )
	 if target ~= nil then 
  		hp = Attack.act_hp( target )
 	end 
		
 	return hp
end
