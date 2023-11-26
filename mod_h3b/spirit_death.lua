-- 0x00000100 - Ordinary only, 0x0000FE00 - No ordinary, 0x00000200- castle, 0x0000FD00 - no castle

function death_appear_idle()

  Attack.act_aseq( 0, "appear" )

  Attack.act_aseq( 0, "rare" )

end

--////////////////////////////////
--/////////   REAPING   //////////
--////////////////////////////////
function death_reaping()  

	local target = Attack.get_target()
  local photo = Attack.photogenic(Attack.get_target())
  local r = Game.Random()
	local kill=tonumber(Attack.get_custom_param("kill"))
	if (target == nil) then return false end

	local target_totalhp = (Attack.act_size(target)-1)*(Attack.act_get_par(target,"health")) + Attack.act_hp(target)
	--for i=0,Logic.resistance()-1 do
  --local dmg_type = Logic.resistance( i )
	--local dmg_min = Attack.act_get_dmg_min( 0, dmg_type )
	--local dmg_max = Attack.act_get_dmg_max( 0, dmg_type )
	Attack.atk_set_damage( "astral", kill*target_totalhp/100.0, kill*target_totalhp/100.0 )
	--end
   	local dead = Attack.act_damage( target )

  if Attack.is_short_spirit_seq() then
	Attack.act_aseq( 0, "2reaping" )
	Attack.act_fadeout(0, 0, 1./25., 0., 0.)
	Attack.cam_track_duration(8.8)
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
	  death_appear_idle()

	  --local after_appear = Attack.aseq_time(0)
	  Attack.act_aseq( 0, "reaping" )

	--/////////////// Camera block
    if Game.ArenaShape() == 4 then  -- castle
    	Attack.cam_track_duration(16.0)
        if r <0.7 then
			Attack.cam_track(0, 0, "spirit_cam_ships.track" )
		else
            Attack.cam_track(0, 0, "spirit_cam_2left.track" )
		end
--    elseif Game.ArenaShape() == 5 then  -- water
--    	Attack.cam_track_duration(16.0)
--        if r <0.4 then
--			Attack.cam_track(0, 0, "spirit_cam_centre.track" )
--		elseif r <0.7 then
--            Attack.cam_track(0, 0, "spirit_cam_2right.track" )
--		else
--            Attack.cam_track(0, 0, "spirit_cam_2left.track" )
--		end
    else
		if (photo == 0) then
	  		Attack.cam_track(0,225,248,0,target,"death_appear_rare_reaping_forest.track" )
		else
		    Attack.cam_track_duration(16.0)
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

	local start_time_r = Attack.aseq_time(0,"r0")
	local end_time_r = Attack.aseq_time(0,"r1")
	Attack.act_rotate( start_time_r, end_time_r, 0, target )

	local hand_time = Attack.aseq_time(0,"hand")
	local hand = Attack.atom_spawn(0, hand_time, "deadhand", Attack.angleto(0, target))
	--Attack.act_aseq( hand, "idle" )
    Attack.act_move( hand_time, Attack.aseq_time(0,"handstop"), hand, target )

	local lift_time = Attack.aseq_time(0,"lift")
	local liftstop_time = Attack.aseq_time(0,"liftstop")
	local drop_time = Attack.aseq_time(0,"drop")
	local hit_time = drop_time + 3.0/25.0
    local tx,ty,tz = Attack.act_get_center(target) -- запоминаем начальное положение
    Attack.act_move( lift_time, liftstop_time, target, tx,ty,tz+2.7 ) -- поднимаем врага
    Attack.act_falldown( drop_time, hit_time, target, tz) -- возвращаем туда, где был

    --[[if dead then
      Attack.add_exp( Attack.act_exp(target) )
    end]]
    Attack.dmg_timeshift(target,hit_time)
    local hit_x = Attack.aseq_time( target, "x" )
    Attack.aseq_timeshift( target, hit_time - hit_x )

  spirit_after_hit()

  return true

end

--////////////////////////////////
--///////// TIME RETURN //////////
--////////////////////////////////
function death_time_return()  --////////////////////////////////

	local target = Attack.get_target()
  	local photo = Attack.photogenic(target)
  	local r = Game.Random()
	if (target == nil) then return false end

	if Attack.act_time_return(target) then

		if Attack.is_short_spirit_seq() then
			Attack.act_aseq( 0, "2timeshift" )
			Attack.act_fadeout(0, 0, 1./25., 0., 0.)
			Attack.cam_track_duration(8.8)
    		if Game.ArenaShape() == 4 then
        		if r <0.5 then
					Attack.cam_track(0, 0, "spirit_cam_short_ships.track" )
				else
            		Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
				end
    		else
      			if r <= 0.40 then
      				  Attack.cam_track(0, 0, "spirit_cam_short_centre.track" )
      			elseif r <= 0.60 then
      				  Attack.cam_track(0, 0, "spirit_cam_short_2left.track" )
      			else
      				  Attack.cam_track(0, 0, "spirit_cam_short_2right.track" )
     		 	end
  			end
		else
			death_appear_idle()
            Attack.act_aseq( 0, "timeshift" )
    		if Game.ArenaShape() == 4 then
    			Attack.cam_track_duration(16.0)
        		if r <0.7 then
					Attack.cam_track(0, 0, "spirit_cam_ships.track" )
				else
            		Attack.cam_track(0, 0, "spirit_cam_2left.track" )
				end
    		else
				Attack.cam_track_duration(16.0)
		    	if r <= 0.40 then
        			Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      			elseif r <= 0.60 then
        			Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      			else
        			Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      			end
    		end
        end

		local y = Attack.aseq_time( 0, "y" )
		local target_in_past = Attack.act_time_return( target, y )

		local x = Attack.aseq_time( 0, "x" )
		local tstart_x = Attack.aseq_time( "deathtimestart", "x" )
		local tstop_x  = Attack.aseq_time( "deathtimestop" , "x" )
		Attack.atom_spawn( target        , x - tstart_x, "deathtimestart" )
		Attack.atom_spawn( target_in_past, x - tstop_x , "deathtimestop"  )

		Attack.act_aseq( target, "telein" )
		Attack.aseq_timeshift( target, y - Attack.aseq_time( target ) )
		Attack.act_aseq( target, "teleout" )

		Attack.log("death_time_return","name","<label=cpn_death>", "target", blog_side_unit(target,0))
	  
	  spirit_after_hit()
	  return true

	end

	return false

end

--////////////////////////////////
--///////// BLACK HOLE //////////
--////////////////////////////////
function death_blackhole()  --////////////////////////////////
  local photo = Attack.photogenic( Attack.get_target() )
  local r = Game.Random()
  local level_influence = tonumber( Attack.get_custom_param( "level_influence" ) ) / 100
  local dmg_type = "astral"
  local dmg_min = Attack.act_get_dmg_min( 0, dmg_type )
  local dmg_max = Attack.act_get_dmg_max( 0, dmg_type )
  local acnt = Attack.act_count()

  for i = 1, acnt - 1 do
    if Attack.act_enemy( i )
    and Attack.act_takesdmg( i )
    and not Attack.act_feature( i, "pawn" ) then
	     local moral = Attack.act_get_par( i, "moral" )
		    --local dmg = Game.Random( dmg_min, dmg_max ) * (1-moral_influence) + Game.Random( dmg_min, dmg_max ) * (3-moral)/6 * moral_influence
--		    local dmg = 1 + ( Attack.act_level( i ) - 1 ) / 4 * level_influence
		    local dmg = 1 + Attack.act_level( i ) / 5 * level_influence
    		Attack.atk_set_damage( dmg_type, dmg_min * dmg, dmg_max * dmg )
    		Attack.act_damage(i)
	   end
  end

  if Attack.is_short_spirit_seq() then
  		Attack.act_aseq( 0, "2blackhole" )
  		Attack.act_fadeout( 0, 0, 1./25., 0., 0. )
  		Attack.cam_track_duration( 8.8 )
    if Game.ArenaShape() == 4 then
      if r < 0.5 then
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
    death_appear_idle()
    Attack.act_aseq( 0, "blackhole" )

--/////////////// Camera block
    if Game.ArenaShape() == 4 then       -- ships
    	 Attack.cam_track_duration( 14.0 )
      if r < 0.7 then
     			Attack.cam_track( 0, 0, "spirit_cam_ships.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
    elseif Game.ArenaShape() == 5 then       -- water
     	Attack.cam_track_duration( 14.0 )
      if r < 0.4 then
			     Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
		    elseif r < 0.7 then
        Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
    else
    		if ( photo == 0 ) then
	  		   Attack.cam_track( 0, 0, 0, 0, 0, "death_appear_spare_blackhole_forest.track" )
		    else
		      Attack.cam_track_duration( 14.0 )
		      if r <= 0.44 then
          Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
        elseif r <= 0.88 then
        		Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
        else
        		Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
        end
      end
    end
--/////////////// End of camera block
  end

  local hit_time = Attack.aseq_time( 0, "x" )

  for i = 1, acnt - 1 do
    if Attack.act_enemy( i )
    and Attack.act_takesdmg( i )
    and not Attack.act_feature( i,"pawn" ) then
      Attack.dmg_timeshift( i, hit_time )
      local hit_x = Attack.aseq_time( i, "x" )
      Attack.aseq_timeshift( i, hit_time - hit_x )
   	  local dist = Attack.cell_mdist( 0, i )
   	  local atom_name

   	  if dist < 6 then atom_name = "deathblackhole_short"
	     elseif dist < 9 then atom_name = "deathblackhole_middle" else atom_name = "deathblackhole_long" end

      Attack.atom_spawn( i, hit_time - Attack.aseq_time( atom_name, "x" ), atom_name, Attack.angleto( 0, i ) )
    end
  end

  spirit_after_hit()

  return true
end

--//////////////////////////////
--/////// RAGE /////////////////
--//////////////////////////////
function death_rage_gain()  --////////////////////////////////
  local r = Game.Random()

  for t = 0, 18 do
    local i = Attack.get_target( t )
    if i ~= nil
    and Attack.act_enemy( i )
    and Attack.act_takesdmg( i )
    and not Attack.act_feature( i,"pawn" ) then
      Attack.act_damage( i )
    end
  end

  if Attack.is_short_spirit_seq() then
	   Attack.act_aseq( 0, "2harvest" )
	   Attack.act_fadeout( 0, 0, 1. / 25., 0., 0. )
    Attack.cam_track_duration( 4.8 )
    if r < 0.4 then
		    Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
	   elseif r < 0.7 then
      Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
	   else
      Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
	   end
  else
    death_appear_idle()
    Attack.act_aseq( 0, "harvest" )

--/////////////// Camera block
    if Game.ArenaShape() == 5 then  -- water
    	 Attack.cam_track_duration( 12.0 )
      if r < 0.4 then
			     Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
		    elseif r < 0.7 then
        Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
	   else
    		local cell = Attack.get_target()
    		i = Attack.photogenic( cell )
	     if ( i == 0 ) then
			     Attack.cam_track( 0, 0, 0, 0, 0, "death_appear_rare_harvest_forest.track" )
		    else
    		  Attack.cam_track_duration( 12.0 )
        if r < 0.4 then
				      Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
			     elseif r < 0.7 then
          Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
			     else
          Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
			     end
		    end
    end
--/////////////// End of camera block
  end

  local hit_time = Attack.aseq_time( 0, "x" )
  local start_time_r = Attack.aseq_time( 0, "r0" )
  local end_time_r = Attack.aseq_time( 0,"r1" )
  Attack.act_rotate( start_time_r, end_time_r, 0, Attack.get_target() )
  local at_least_one_unit = false
 
  for t = 0, 18 do
    local i = Attack.get_target( t )

    if i ~= nil
    and Attack.act_enemy( i )
    and Attack.act_takesdmg( i )
    and not Attack.act_feature( i,"pawn" ) then
      --[[local dead = Attack.act_damage(i)
      if dead then
        Attack.add_exp( Attack.act_exp(i) )
      end]]
      Attack.dmg_timeshift( i, hit_time )
      local hit_x = Attack.aseq_time( i, "x" )
      Attack.aseq_timeshift( i, hit_time - hit_x )
   	  local dist = Attack.cell_mdist( 0, i )
	     local atom_name

	     if dist < 6 then
        atom_name = "deathharvest_short"
	     elseif dist < 9 then
        atom_name = "deathharvest_middle"
      else
        atom_name = "deathharvest_long"
      end

      Attack.atom_spawn( i, hit_time - Attack.aseq_time( atom_name, "x" ), atom_name, Attack.angleto( 0, i ) )
      at_least_one_unit = true
    end
  end

  spirit_after_hit() --здесь происходит вычитание rage

  if at_least_one_unit then --нужен хотя бы один юнит для сбора ярости, иначе - ярость не увеличиваем
    if mana_rage_gain_k == nil then
      mana_rage_gain_k = 1
    end

    Logic.hero_lu_item( "rage","count", Logic.hero_lu_item( "rage","count" ) + math.ceil( tonumber( Attack.get_custom_param( "rage_gain" ) ) * mana_rage_gain_k ) )
  end

  return true

end

function death_rage_gain_highlight()

	local target = Attack.get_target()

	for i=0,Attack.cell_count()-1 do
	    local c = Attack.cell_get(i)
	    if Attack.cell_dist(c, target) <= 2 then
	        if Attack.act_enemy(c) and Attack.act_applicable(c) then
				Attack.cell_select(c,"avenemy")
	        else
				Attack.cell_select(c,"destination")
	        end
	    end
	end

	return true

end
