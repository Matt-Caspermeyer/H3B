--cam_lina_rare_devatron_closeup


function lina_appear_idle()

  Attack.act_aseq( 0, "appear" )

  Attack.act_aseq( 0, "rare" )

end

--------------
--Enegretics--
--------------

function lina_enboxes()
  local r = Game.Random()
  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2cast" )
    Attack.act_fadeout( 0, 0, 1. / 25., 0., 0. )
    Attack.cam_track_duration( 7.6 )
    if Game.ArenaShape() == 4 then
      if r < 0.7 then
			     Attack.cam_track( 0, 0, "spirit_cam_short_ships.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
		    end
    else
      if r <= 0.44 then
        Attack.cam_track( 0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.88 then
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track( 0, 0, "spirit_cam_short_2right.track" )
      end
    end
  else
    if Game.ArenaShape() == 4 then --  ships
    	 Attack.cam_track_duration( 14.8 )
        if r < 0.7 then
			       Attack.cam_track( 0, 0, "spirit_cam_ships.track" )
		      else
          Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		      end
    elseif Game.ArenaShape() == 1 then --  castle
      if r <= 0.35 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r_castle.track" )
      elseif r <= 0.7 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l_castle.track" )
      elseif r <= 0.9 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_r_castle.track" )
      else
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup_castle.track" )
      end
    elseif Game.ArenaShape() == 5 then --  water
      if r <= 0.5 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r_castle.track" )
      else
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l_castle.track" )
      end
    else
      if r <= 0.2 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r.track" )
      elseif r <= 0.4 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l.track" )
      elseif r <= 0.6 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_r.track" )
      else
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup.track" )
      end
    end
    lina_appear_idle()
    Attack.act_aseq( 0, "cast" )
  end

  local start = Attack.aseq_time( 0, "x" )
  local count = tonumber( Attack.get_custom_param( "count" ) )
  local mana_count = { Attack.get_custom_param( "manabonus.0" ), Attack.get_custom_param( "manabonus.1" ) }
  local rage_count = { Attack.get_custom_param( "ragebonus.0" ), Attack.get_custom_param( "ragebonus.1" ) }
  local cells = {}
  for i = 0, Attack.cell_count() - 1 do
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty( cell )
    and Attack.cell_is_pass( cell )
    and Attack.cell_bonus( cell ) == nil then
      table.insert( cells, cell )
    end
  end

  for i = 1, math.min( table.getn( cells ), count ) do
    local n = Game.Random( 1, table.getn( cells ) )
    local c = cells[ n ]
    table.remove( cells, n )
    local name, val

    if math.mod( i, 2 ) == 0 then
      name = "mana"
      val = Game.Random( unpack( mana_count ) )
    else
      name = "rage"
      val = Game.Random( unpack( rage_count ) )
    end

    local t = start + ( i - 1 ) * .3
    local a = Attack.atom_spawn( c, t, "energo_" .. name )
    Attack.act_aseq( a, "appear" )
    Attack.aseq_timeshift( a, t )

    if mana_rage_gain_k == nil then
      mana_rage_gain_k = 1
    end

    Attack.val_store( a, "val", tostring( math.ceil( val * mana_rage_gain_k ) ) )
    Attack.val_store( a, "name", name )
    Attack.cell_bonus( c, a )
  end

  spirit_after_hit()
  Attack.log( "lina_enbox", "name", "<label=cpn_lina>" )

  return true
end


function enbox_bonus( t, cl )
  local name = Attack.val_restore( "name" )

  if name == "" then return 0 end

  Attack.val_store( "name", "" ) -- чтобы дважды не давать этот бонус

  if Attack.act_belligerent( cl ) ~= 1 then
    if name == "rage"
    or name == "mana" then
  	   local count = Logic.enemy_lu_item( name, "count" )

	     if count ~= nil then
        Logic.enemy_lu_item( name, "count", count + tonumber( Attack.val_restore( "val" ) ) )
  		  else
        Logic.hero_lu_item( name, "count", Logic.hero_lu_item( name, "count" ) - tonumber( Attack.val_restore( "val" ) ) )
      end
    end
  else
    Logic.hero_lu_item( name, "count", Logic.hero_lu_item( name, "count" ) + tonumber( Attack.val_restore( "val" ) ) )
  end

-- This code doesn't work properly - the above should be okay...
--[[  if Attack.act_human( cl ) then
    Logic.hero_lu_item( name, "count", Logic.hero_lu_item( name, "count" ) + tonumber( Attack.val_restore( "val" ) ) )
	 elseif Attack.act_belligerent( cl ) == 4
  and name == "mana" then
	   local count = Logic.enemy_lu_item( name,"count" )

	   if count ~= nil then
      Logic.enemy_lu_item( name, "count", count + tonumber( Attack.val_restore( "val" ) ) )
		  end
  end]]

  Attack.act_aseq( 0, "disappear", true )
  Attack.aseq_timeshift( 0, t )

  return tonumber( Attack.val_restore( "ap" ) )
end


function enbox_modificators()
  local caa = Attack.get_caa( Attack.get_cell( 0 ) )

  if caa ~= nil then
    local ap = enbox_bonus( 0, caa )
    Attack.act_ap( caa, Attack.act_ap( caa ) + ap )
  end
  
  return true
end


--------------
-----Orb------
--------------

function lina_orb()
  local r = Game.Random()
  local target, start = Attack.get_target(), 0

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2orbcast" )
    Attack.act_fadeout( 0, 0, 1./25., 0., 0. )
    Attack.act_rotate( 0, .1, 0, target )
    Attack.cam_track_duration( 7.6 )
    if Game.ArenaShape() == 4 then
      if r < 0.7 then
     			Attack.cam_track( 0, 0, "spirit_cam_short_ships.track" )
    		else
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
		    end
    else
      if r <= 0.44 then
        Attack.cam_track( 0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.88 then
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track( 0, 0, "spirit_cam_short_2right.track" )
      end
    end
  else
    lina_appear_idle()

    if Game.ArenaShape() == 4 then --  ships
    	 Attack.cam_track_duration( 14.8 )
      if r < 0.7 then
     			Attack.cam_track( 0, 0, "spirit_cam_ships.track" )
    		else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
    elseif Game.ArenaShape() == 1 then --  castle
      Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup_castle.track" )
    elseif Game.ArenaShape() == 5 then --  water
      if r < 0.4 then
			     Attack.cam_track( 0, 0, "spirit_cam_centre.track" )
		    elseif r < 0.7 then
        Attack.cam_track( 0, 0, "spirit_cam_2right.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
    else
      if r <= 0.45 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r.track" )
      elseif r <= 0.75 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l.track" )
      elseif r <= 0.9 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_r.track" )
      elseif r <= 1.0 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup.track" )
      end
    end

    Attack.act_rotate( Attack.aseq_time( 0, "x" ), Attack.aseq_time( 0, "y" ), 0, target )
    start = Attack.aseq_time( 0 );
    Attack.act_aseq( 0, "orbcast" )
  end

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_name( i ) == "orb" then
	     Attack.act_aseq( i, "death", true )
    end
  end

  local c = Attack.get_cell( 0 )
  Attack.act_spawn( c, 0, "orb", Attack.angleto( 0, target ) )
  Game.GVSNumInc( "units_kupleno", "orb", 1 )
  Attack.act_nodraw( c, true )
  Attack.act_animate( c, "appear", start )
  Attack.act_nodraw( c, false, start )
  local ts_x = Attack.aseq_time( "orb", "appear", "x" )
  local ts_y = Attack.aseq_time( "orb", "appear", "y" )
  Attack.act_move( ts_x + start, ts_y + start, c, target )
  local health = tonumber( Attack.get_custom_param( "health" ) )
  local atk = tonumber( Attack.get_custom_param( "atk" ) )
  local def = tonumber( Attack.get_custom_param( "def" ) )
  local init = tonumber( Attack.get_custom_param( "init" ) )
  local k_dam = tonumber( Attack.get_custom_param( "k_dam" ) )
  Attack.val_store( c, "k_dam", k_dam )
  Attack.act_hp( c, health )
  Attack.act_set_par( c, "health", health )

  if atk ~= nil then
    local current_atk, base_atk = Attack.act_get_par( c, "attack" )
    Attack.act_set_par( c, "attack", atk + base_atk )
  end

  if def ~= nil then
    local current_def, base_def = Attack.act_get_par( c, "defense" )
    Attack.act_set_par( c, "defense", def + base_def )
    local current_defup = Attack.act_get_par( c, "defenseup" )
    Attack.act_set_par( c, "defenseup", math.ceil( current_defup + def / 5 ) )
    Attack.act_attach_modificator_res( c, "fire", "orb_res1", def, 0, 0, -100, false, 0, false )
    Attack.act_attach_modificator_res( c, "physical", "orb_res2", def, 0, 0, -100, false, 0, false )
  end

  local start_defense_p = skill_power2( "start_defense", 1 )

  if start_defense_p > 0 then
    Attack.act_attach_modificator_res( c, "physical", "sc", start_defense_p, 0, 0, -100, false, 0, true )
  end

  if init ~= nil then
    local current_init, base_init = Attack.act_get_par( c, "initiative" )
    Attack.act_set_par( c, "initiative", init + base_init )
  end

  local dmg_min, dmg_max = text_range_dec( Attack.get_custom_param( "damage.physical.0" ) .. '-' .. Attack.get_custom_param( "damage.physical.1" ) )
  local typedmg = "physical"
  Attack.atk_set_damage( typedmg, dmg_min, dmg_max )
  -- Impact damage is 2x roll damage
  dmg_min = 2 * dmg_min
  dmg_max = 2 * dmg_max
--  dmg_min = dmg_min + health
--  dmg_max = dmg_max + health
  local k_dec = tonumber( Attack.get_custom_param( "k_dec" ) )
  local acnt = Attack.act_count()

  for i = 1, acnt - 1 do
    if Attack.act_enemy( i )
    and Attack.act_mt( i ) == 0
    and Attack.act_applicable( i )
    and Attack.act_takesdmg( i )
    and Attack.act_hp( i ) > 0
    and Attack.act_name( i ) ~= "archdemon"
    and Attack.act_name( i ) ~= "demoness" then
      local dist = Attack.cell_dist( target, i ) - 1
      local k = ( 1 - k_dec * dist / 100 )

      if k > 0 then
        if Attack.act_feature( i, "barrier" ) then
          Attack.atk_set_damage( typedmg, 2 * dmg_min * k, 2 * dmg_max * k )
        else
          Attack.atk_set_damage( typedmg, dmg_min * k, dmg_max * k )
        end

        common_cell_apply_damage( i, start + ts_y )
      end
    end

    if Attack.act_enemy( i )
    and Attack.act_mt( i ) == 2
    and Attack.act_applicable( i ) then
      local dragon_ts = start + ( ts_x + ts_y ) / 2
      Attack.act_aseq( i, "takeoff" )
      Attack.aseq_timeshift( i, dragon_ts )
      Attack.act_aseq( i, "descent" )
    end

    if Attack.act_enemy( i )
    and Attack.act_name( i ) == "demoness"
    and Attack.act_applicable( i ) then
      Attack.act_animate( i, "avoid", start + ts_y )
    end

    if Attack.act_enemy( i )
    and Attack.act_name( i ) == "archdemon"
    and Attack.act_applicable( i ) then
      Attack.act_animate( i, "special", start + ts_y )
    end
  end

  Attack.resort( c )
  Attack.log("slime_fog", "name", "<label=cpn_lina>", "target", "<label=cpn_orb>")
  spirit_after_hit()

  return true

end

function orb_check_target(c)
	return Attack.act_takesdmg(c) and not Attack.act_ally(c)
end

function orb_calccells()

    for i=0,5 do
        local c = Attack.cell_adjacent(0, i)

        if empty_cell(c) then
            while true do
                Attack.marktarget(c)
                c = Attack.cell_adjacent(c, i)
                if not empty_cell(c) then break end
            end
        end

        if c~=nil and orb_check_target(c) then
            Attack.marktarget(c)
        end
        --[[if c~=nil and Attack.cell_present(c) and ((Attack.cell_is_pass(c) and Attack.cell_is_empty(c)) or Attack.act_takesdmg(c)) then
            Attack.marktarget(c)
        end]]
    end

    Attack.val_store(0, "cell_id", Attack.cell_id(Attack.get_cell(0)))
    --Attack.atk_set_damage("physical", text_range_dec(Attack.val_restore("damage")))

    return true

end

function orb_posthit( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
		local dmg_k = tonumber( Attack.val_restore( attacker, "k_dam" ) ) -- %увеличения урона за каждую клетку которую прокатился орб
  local c = Attack.cell_id( Attack.val_restore( attacker, "cell_id" ) ) -- восстановить клетку, где стоял шар, можно только так, т.к. положение шара на момент вызова постхита - уже после перемещения
  local k = Attack.cell_dist( c, receiver ) - 1
  local dir = Game.Ang2Dir( Attack.angleto( attacker, receiver ) )
  local cell = Attack.cell_adjacent( receiver, dir )

	 if ( minmax == 0 )
  and damage > 0 then
	   if not Attack.act_feature( receiver, "boss, pawn" )
    and Attack.cell_present( cell )
    and Attack.cell_is_empty( cell )
    and Attack.cell_is_pass( cell )
    and Attack.act_get_par( receiver, "dismove" ) == 0 then
      local dmgts = ( k * 0.5 ) + 0.5
      Attack.act_move( dmgts, dmgts + 0.5, receiver, cell )
    end
  end

  return damage * ( 1 + k * dmg_k / 100 ), addrage * ( 1 + k * dmg_k / 100 )
end

function orb_highlight()

    local target, prev = Attack.get_target()
    local dir = Game.Ang2Dir(Attack.angleto(0,target))
    target = Attack.cell_adjacent(0, dir) -- на тот случай, когда target отдалена более чем на 1 клетку от шара

    if empty_cell(target) then
        while true do
            Attack.cell_select(target, "path")

            prev = target
            target = Attack.cell_adjacent(target, dir)

            if not empty_cell(target) then break end
        end
    end

    if target~=nil and orb_check_target(target) then
        Attack.cell_select(target, "avenemy")
    elseif prev ~= nil then
        Attack.cell_select(prev, "destination")
    end

    --[[
    if empty_cell(target) then

        Attack.cell_select(target,"pathstart")
        while true do
            target = Attack.cell_adjacent(target, dir)
            if not empty_cell(target) then break end
            Attack.cell_select(target,"pathline")
        end
        Attack.cell_select(target,"pathend")

    end

    if target~=nil and Attack.act_takesdmg(target) then
        Attack.cell_select(target,"avenemy")
    end
]]
    return true

end

function orb_rollattack()

    local target = Attack.get_target()
    local dir = Game.Ang2Dir(Attack.angleto(0,target))
    target = Attack.cell_adjacent(0, dir)

    Attack.aseq_rotate(0, target)

	Attack.log_label('')
    --target = Attack.cell_adjacent(target, dir)
    if empty_cell(target) then

        Attack.act_no_cell_update(0)
        Attack.aseq_start(0, "start", "move")

        while true do
            target = Attack.cell_adjacent(target, dir)
            if not empty_cell(target) then break end
            Attack.aseq_move(0, "move")
        end

        if target~=nil and orb_check_target(target) then
            Attack.act_aseq(0, "rush", false, true)
            common_cell_apply_damage(target, Attack.aseq_time(0, "x"))
        else
			Attack.log_label('null')
            Attack.act_aseq(0, "stop", false, true)
        end

    elseif orb_check_target(target) then
        Attack.act_aseq(0, "attack")
        common_cell_apply_damage(target, Attack.aseq_time(0, "x"))
    end

    Attack.atk_min_time(Attack.aseq_time(0)+.2)

    return true

end

--------------
----Gizmo-----
--------------

function get_gizmo_ids()
    local gizmo_ids = {} -- запоминаем клетки, где стоят гизмо, чтобы два не встали на одну клетку
    for i=1, Attack.act_count()-1 do
        if Attack.act_name(i) == "gizmo" then
            gizmo_ids[Attack.cell_id(Attack.get_cell(i))] = true
        end
    end
    return gizmo_ids
end

function gizmo_calccells()

    local gizmo_ids = get_gizmo_ids()

    local ccnt = Attack.cell_count()
    for i=0,ccnt-1 do               -- for all cells
        if gizmo_ids[Attack.cell_id(Attack.cell_get(i))] ~= true then
            Attack.marktarget(Attack.cell_get(i))     -- select
        end
    end

    return true

end

function lina_gizmo()

  local target = Attack.get_target()
  local r = Game.Random()

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq(0, "2cast")
    Attack.act_fadeout(0, 0, 1./25., 0., 0.)
    Attack.act_rotate( 0, .1, 0, target )
    Attack.cam_track_duration(7.6)

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
    lina_appear_idle()
    --******************************** camera control
    if Game.ArenaShape() == 4 then --  ships
    	 Attack.cam_track_duration(14.8)

      if r <0.7 then
			     Attack.cam_track(0, 0, "spirit_cam_ships.track" )
		    else
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
		    end
    elseif Game.ArenaShape() == 1 then --  castle
      if r <= 0.35 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_still2r_castle.track" )
      elseif r <= 0.7 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_still2l_castle.track" )
      elseif r <= 0.9 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_r_castle.track" )
      elseif r <= 1.0 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_closeup_castle.track" )
       end
    elseif Game.ArenaShape() == 5 then --  water
    	 Attack.cam_track_duration(14.8)

      if r <= 0.4 then
        Attack.cam_track(0, 0, "spirit_cam_centre.track" )
      elseif r <= 0.7 then
        Attack.cam_track(0, 0, "spirit_cam_2right.track" )
      else
        Attack.cam_track(0, 0, "spirit_cam_2left.track" )
      end
    else
      if r <= 0.45 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_still2r.track" )
      elseif r <= 0.75 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_still2l.track" )
      elseif r <= 0.9 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_r.track" )
      elseif r <= 1.0 then
        Attack.cam_track(0, 0, "cam_lina_rare_devatron_closeup.track" )
      end
    end
    --********************************* End of camera control
    Attack.act_rotate( Attack.aseq_time(0, "x"), Attack.aseq_time(0, "y"), 0, target )
    Attack.act_aseq(0, "cast")
  end

  local start = Attack.aseq_time( 0, "y" );

  local atom = Attack.atom_spawn( target, start, "gizmo", 0 )
  Attack.act_animate( atom, "appear", start )
  Attack.val_store( atom, "belligerent", Attack.act_belligerent() )
--    Attack.val_store(atom, "charges", 3)
  Attack.val_store( atom, "charges", Attack.get_custom_param( "charges" ) )
  Attack.val_store( atom, "ap", Attack.get_custom_param( "ap" ) )
  Attack.val_store( atom, "damage", Attack.get_custom_param( "dmg.0" ) .. '-' .. Attack.get_custom_param( "dmg.1" ) )
  Attack.val_store( atom, "dammin", Attack.get_custom_param( "dmg.0" ) )
  Attack.val_store( atom, "dammax", Attack.get_custom_param( "dmg.1" ) )
  Attack.val_store( atom, "heal", Attack.get_custom_param( "heal" ) )
  Attack.val_store( atom, "apally", Attack.get_custom_param( "apally" ) )
  Attack.val_store( atom, "apenemy", Attack.get_custom_param( "apenemy" ) )
  Attack.val_store( atom, "dispellbad", Attack.get_custom_param( "dispellbad" ) )
  Attack.val_store( atom, "dispellgood", Attack.get_custom_param( "dispellgood" ) )

  -- New! Gizmo's Initiative can now change based on LINA.ATOM
  local init = Attack.get_custom_param( "init" )
  if init ~= nil then
    local current_init, base_init = Attack.act_get_par( atom, "initiative" )
    Attack.act_set_par( atom, "initiative", init + base_init )
  end

  Attack.resort( atom )
  spirit_after_hit()
  local charges = Attack.val_restore( "charges" )
  if charges == 1 then
    Attack.log( "lina_gizmo_1", "name", "<label=cpn_lina>", "target", "<label=cpn_gizmo>", "target", "<label=cpn_gizmo>" )
  else
    Attack.log( "lina_gizmo_2", "name", "<label=cpn_lina>", "target", "<label=cpn_gizmo>", "target", "<label=cpn_gizmo>", "charges", charges )
  end

  return true

end

function gizmo_attack()
	 Attack.log_label( "null" )
  local bel = Attack.val_restore( "belligerent" )
  local charges = Attack.val_restore( "charges" )
  local ap = Attack.val_restore( "ap" )
  local apally = Attack.val_restore( "apally" ) > 0
  local apenemy = Attack.val_restore( "apenemy" ) > 0
  local dispellbad = Attack.val_restore( "dispellbad" ) > 0
  local dispellgood = Attack.val_restore( "dispellgood" ) > 0
  local cure_hp = tonumber( Attack.val_restore( "heal" ) )
  local dammin = tonumber( Attack.val_restore( "dammin" ) )
  local dammax = tonumber( Attack.val_restore( "dammax" ) )
  local damavg = ( dammin + dammax ) / 2
  local under, target = Attack.get_caa( Attack.get_cell( 0 ) )
  local priority, max_priority = 0, 0
  local ally_power, enemy_power = 0, 0

  local function check_charmed( i, ally )
	   for s = 0, Attack.act_spell_count( i ) - 1 do
		    local spell_name = Attack.act_spell_name( i, s )

      if spell_name == "effect_charm"
      or spell_name == "spell_hypnosis" then
        if ally
        and dispelbad
        and Attack.act_enemy( i, bel ) then
          return true
        end

        if Attack.act_ally( i, bel ) then
          return false
        end

      end
    end

    return ( ally and Attack.act_ally( i, bel ) ) or ( not ally and Attack.act_enemy( i, bel ) )
  end

  local function ally_check( i )
    if check_charmed( i, true ) then
      if Attack.act_pawn( i )
      or Attack.act_temporary( i ) then
        priority = 0
        return false
      end

      local level = Attack.act_level( i )
      local health = Attack.act_get_par( i, "health" )
      local total_initial_hp =  health * Attack.act_initsize( i )
      local unit_priority = 0

      priority = tonumber( unit_priority ) / 2
      if Attack.cell_need_resurrect( i ) then
        local res_eff = ( total_initial_hp - Attack.act_totalhp( i ) ) / cure_hp
        priority = priority + res_eff * level * level
      end

      if Attack.act_need_cure( i ) then
        local hp = Attack.act_hp( i )
        local health_eff = ( 1 - hp / health ) * hp / cure_hp
        priority = priority + ( health_eff * level * level )
      end

      if dispellbad then
      	 for ii = 0, Attack.act_spell_count( i ) - 1 do
      		  local spell_name = Attack.act_spell_name( i, ii )
      		  local spell_type = Logic.obj_par( spell_name,"type" )

      		  if spell_type == "penalty" and string.find( spell_name, "^totem_" ) == nil then
            local duration = tonumber( Attack.act_spell_duration( i, spell_name ) )

            if duration == nil then
              duration = 1
            elseif duration < 0 then
              duration = 0
            end

            local gain

            if spell_name == "spell_pygmy"
            or spell_name == "spell_blind"
            or spell_name == "spell_plague"
            or spell_name == "spell_magic_bondage"
            or spell_name == "spell_crue_fate"
            or spell_name == "spell_ram"
            or spell_name == "spell_hypnosis"
            or spell_name == "effect_shock"
            or spell_name == "effect_poison"
            or spell_name == "effect_burn"
            or spell_name == "effect_sleep"
            or spell_name == "effect_stun"
            or spell_name == "effect_freeze"
            or spell_name == "effect_charm"
            or spell_name == "feat_rabid"
            or spell_name == "effect_fear" then
              gain = 9
              priority = priority + ( duration * gain * enemy_power / ally_power )

            elseif spell_name == "spell_scare"
            or spell_name == "spell_weakness"
            or spell_name == "effect_weakness"
            or spell_name == "effect_curse"
            or spell_name == "effect_holy"
            or spell_name == "feat_bleeding" then
              gain = 4
              priority = priority + ( duration * gain * enemy_power / ally_power )

            else
              gain = 1
              priority = priority + ( duration * gain * enemy_power / ally_power )
            end
          end
      	 end
      end

      if apally then
        local best_eff = math.sqrt( ( tonumber( Attack.act_leadership( i ) * Attack.act_size( i ) ) ) / cure_hp )
        local ap_eff = math.max( 1, 5 - Attack.act_ap( i ) )
        priority = priority + ( best_eff * ap_eff * enemy_power / ally_power )
      end

      if Attack.act_feature( i, "magic_immunitet" )
      or ( Attack.act_feature( i, "undead" )
      and not Logic.hero_lu_skill( "necromancy" ) > 0 )
      or Attack.act_feature( i, "plant" )
      or Attack.act_feature( i, "golem" ) then
        priority = priority * 2
      end

      return true
    else
      priority = 0
      return false
    end
  end

  local function enemy_check( i )
    if check_charmed( i, false ) then
      local att_eff = Attack.act_totalhp( i ) / damavg
      local level = Attack.act_level( i )
      local unit_priority = 0

      priority = ( tonumber( unit_priority ) / 2 ) + att_eff * level

      if dispellgood then
      	 for ii = 0, Attack.act_spell_count( i ) - 1 do
      		  local spell_name = Attack.act_spell_name( i, ii )
      		  local spell_type = Logic.obj_par( spell_name,"type" )

      		  if spell_type == "bonus" and string.find( spell_name, "^totem_" ) == nil then
            local duration = tonumber( Attack.act_spell_duration( i, spell_name ) )

            if duration == nil then
              duration = 1
            elseif duration < 0 then
              duration = 0
            end

            local gain

            if spell_name == "spell_dragon_slayer"
            or spell_name == "spell_demon_slayer"
            or spell_name == "spell_divine_armor"
            or spell_name == "spell_haste"
            or spell_name == "spell_berserker"
            or spell_name == "spell_invisibility"
            or spell_name == "spell_phantom" then
              gain = 9
              priority = priority + ( duration * gain * enemy_power / ally_power )

            elseif spell_name == "spell_stone_skin"
            or spell_name == "spell_bless"
            or spell_name == "spell_reaction"
            or spell_name == "spell_magic_source" then
              gain = 4
              priority = priority + ( duration * gain * enemy_power / ally_power )

            else
              gain = 1
              priority = priority + ( duration * gain * enemy_power / ally_power )
            end
          end
      	 end
      end

      if ( apenemy and Attack.act_ap( i ) > 0 ) then
        local best_eff = math.sqrt( ( tonumber( Attack.act_leadership( i ) * Attack.act_size( i ) ) ) / damavg )
        local ap_eff = Attack.act_ap( i )
        priority = priority + ( best_eff * ap_eff * enemy_power / ally_power )
      end

      return true
    else
      priority = 0
      return false
    end
  end

  local gizmo_ids = {} -- запоминаем клетки, где стоят гизмо, чтобы два не встали на одну клетку

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_name(i) == "gizmo" then
      gizmo_ids[ Attack.cell_id( Attack.get_cell( i ) ) ] = true
    end
  end

  for a = 1, Attack.act_count() - 1 do
    local i = Attack.get_cell( a )
    if Attack.act_ally( i, bel ) then
      ally_power = ally_power + tonumber( Attack.act_leadership( i ) * Attack.act_size( i ) )
    elseif Attack.act_enemy( i, bel ) then
      enemy_power = enemy_power + tonumber( Attack.act_leadership( i ) * Attack.act_size( i ) )
    end
  end

  local chance_attack_enemy = Game.Random( 1, 100 )
  local enemy2ally_power = math.ceil( enemy_power / ( enemy_power + ally_power ) * 100 )
  local repeat_counter = 0

 	repeat

    for a = 1, Attack.act_count() - 1 do
      local i = Attack.get_cell( a )
  
      if ( under == nil
      or not Attack.act_equal( under, i ) ) then
        if chance_attack_enemy <= enemy2ally_power then
          enemy_check( i )
        else
          ally_check( i )
        end
        
        if priority ~= 0 then
          local d = Attack.cell_mdist( 0, i )
          priority = priority * math.min( 1, ap / ( d / 1.8 ) )
  
          if gizmo_ids[ Attack.cell_id( Attack.get_cell( i ) ) ] ~= true then -- вторая проверка нужна, чтобы гизмо 
            if priority >= max_priority then
              max_priority = priority
              target = i
            end
          end
        end
      end
    end

    if target == nil then
      chance_attack_enemy = 0
      enemy2ally_power = 1
      repeat_counter = repeat_counter + 1
    end

  until target ~= nil or repeat_counter > 1

  if under ~= nil then
    if ( enemy_check( under )
    or ally_check( under ) )
    and ( priority ~= 0 ) then
      if priority >= max_priority then
        target = under
      end
    end
  end

  if target ~= nil then
    local d = Attack.cell_mdist( 0, target ) / 1.8

    if d > ap + 1 then -- запас +1 нужен, чтобы не было так, что гизмо встал на клетку с врагом и при этом ничего не сделал
      for i = ap, 1, -1 do
        local dist = 1.8 * i
        local x, y = Attack.act_get_center( 0 )
        local dx, dy = Attack.act_get_center( target  )
        dx = dx - x; dy = dy - y
        local len = math.sqrt( dx * dx + dy * dy )
        dx = dx * dist / len; dy = dy * dist / len
        local dest = Attack.find_nearest_cell( x + dx, y + dy )

        if gizmo_ids[ Attack.cell_id( dest ) ] ~= true then
          Attack.act_move( 0, i, 0, dest )
          break
        end
      end

    else
      Attack.act_move( 0, d, 0, target )

      if check_charmed( target, true ) then
        local cast_value = gizmo_animation_from_charges( charges )
		      Attack.act_aseq( 0, "cast" .. cast_value )
       	local count_1, count, max_hp = Attack.act_size( target ), 0, Attack.act_get_par( target, "health" )

	       if Attack.get_caa( target ) == nil then count_1 = 0 end

      		local cur_hp = Attack.act_hp( target )
        Attack.cell_resurrect( target, cure_hp, Attack.aseq_time( d + 1, "x" ) )
        local count_2 = Attack.act_size( target )

        if count_2 > count_1 then count = count_2 - count_1 end

        if count_2 < count_1 then count = count_2 end

   	    local N

        if count > 1 then N = '2' else N = '1' end

      		if cure_hp > max_hp - cur_hp then cure_hp = max_hp - cur_hp end

     		 if apally then
   		     local new_ap
          local message

      		  if ( Attack.act_again( target ) ) then
            local speed = Attack.act_get_par( target, "speed" )
            new_ap = math.max( 1, math.ceil( speed / 2 ) )
            message = "apally_gizmo_1"
          else
            new_ap = Attack.act_ap( target ) + math.max( 1, math.ceil( Attack.act_ap( target ) / 2 ) )
            message = "apally_gizmo_2"
          end

      		  Attack.act_ap( target, new_ap )
        		Attack.log( message, "name", "<label=cpn_gizmo></color>","saname","<label=blog_ally_color><label=sp_gizmo_apally>", "targets", blog_side_unit( target, 0 ) )
          Attack.atom_spawn( target, d , "magic_horn" )
     		 end

     		 if dispellbad then
    		    if ( Attack.act_is_spell( target, "spell_hypnosis" )
          or Attack.act_is_spell( target, "effect_charm" ) ) then
    			     Attack.act_del_spell( target, "spell_hypnosis" )
    			     Attack.act_del_spell( target, "effect_charm" )
          end

          takeoff_spells( target, "penalty" )
        		Attack.log( "dispelbad_gizmo_" .. N, "name", "<label=cpn_gizmo></color>","saname","<label=blog_ally_color><label=sp_gizmo_dispel>", "targets", blog_side_unit( target, 0 ) )
          d = d + 0.1
      	   Attack.atom_spawn( target, d, "magic_dispel" )
        end

        if count_1 == count_2 then
          if cure_hp > 0 then
        		  Attack.log( "cure_" .. N, "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_heal>", "targets", blog_side_unit( target, 0 ), "special", cure_hp )
            d = d + 0.1
            Attack.atom_spawn( target, d, "hll_priest_heal_post" )
          end

     		 else
        		Attack.log( "res_gizmo_" .. N, "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_res>", "targets", blog_side_unit( target, 0 ), "special", count )
          d = d + 0.1
          Attack.atom_spawn( target, d, "hll_priest_resur_cast" )
	         -- If Gizmo Resurrects, then use a charge
          if charges == 1 then
	           Attack.act_aseq( 0, "disappear" )
	           Attack.act_remove( 0, d + Attack.aseq_time( 0 ) )
            Attack.log( "charges_gizmo_0", "name", "<label=cpn_gizmo></color>" )

    	     else
            d = d + 0.1
	           Attack.val_store( 0, "charges", charges - 1, d )
            if charges == 2 then
              Attack.log( "charges_gizmo_1", "name", "<label=cpn_gizmo></color>" )
            else
              Attack.log( "charges_gizmo_2", "name", "<label=cpn_gizmo></color>", "charges", ( charges - 1 ) )
            end
	         end
        end
      else
        local attack_value = gizmo_animation_from_charges( charges )
        Attack.act_aseq( 0, "attack" .. attack_value )
        local target_size = Attack.act_size( target )
        Attack.atk_set_damage( "astral", text_range_dec( Attack.val_restore( "damage" ) ) )
        common_cell_apply_damage( target, d + Attack.aseq_time( 0, "x" ) )
        local damage, dead = Attack.act_damage_results( target )
        Attack.atom_spawn( target, d, "hll_lightning_after" )

   	    local N
        if target_size > 1 then
          N = 2
        else
          N = 1
        end

        if dead > 0 then
          if target_size == dead then
            Attack.log( "atk_gizmo_" .. N .. "_troopdef", "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_attack>", "targets", blog_side_unit( target, 0 ), "damage", damage, "troopdef", "<label=troop_defeated>" )
          else
            if dead > 1 then
              Attack.log( "atk_gizmo_" .. N .. "_2dead", "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_attack>", "targets", blog_side_unit( target, 0 ), "damage", damage, "dead", dead )
            else
              Attack.log( "atk_gizmo_" .. N .. "_1dead", "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_attack>", "targets", blog_side_unit( target, 0 ), "damage", damage, "dead", dead )
            end
          end
        else
          Attack.log( "atk_gizmo_" .. N, "name", "<label=cpn_gizmo></color>", "saname", "<label=blog_ally_color><label=sp_gizmo_attack>", "targets", blog_side_unit( target, 0 ), "damage", damage )
        end

    	   if apenemy then
		        local cur_ap = Attack.act_ap( target )
          local effect_entangle = false

        	 for s = 0, Attack.act_spell_count( target ) - 1 do
        		  local spell_name = Attack.act_spell_name( target, s )

            if spell_name == "effect_entangle" then
              effect_entangle = true
              break
            end
          end

    		    if cur_ap > 1
          and not effect_entangle then
            Attack.act_ap( target, math.floor( cur_ap / 2 ) )
        		  Attack.log( "apenemy_gizmo_" .. N, "name", "<label=cpn_gizmo></color>","saname","<label=blog_ally_color><label=sp_gizmo_apenemy>", "targets", blog_side_unit( target, 0 ) )
            d = d + 0.1
            Attack.atom_spawn( target, d, "magic_slow" )
          end
      		end

    		  if dispellgood then
          takeoff_spells( target, "bonus" )
        		Attack.log( "dispelgood_gizmo_" .. N, "name", "<label=cpn_gizmo></color>","saname","<label=blog_ally_color><label=sp_gizmo_dispel>", "targets", blog_side_unit( target, 0 ) )
          d = d + 0.1
      	   Attack.atom_spawn( target, d, "magic_dispel" )
        end

	       if charges == 1 then
	         Attack.act_aseq(0, "disappear")
	         Attack.act_remove( 0, d + Attack.aseq_time( 0 ) )
          Attack.log( "charges_gizmo_0", "name", "<label=cpn_gizmo></color>" )
  	     else
          d = d + 0.1
	         Attack.val_store( 0, "charges", charges - 1, d )
          if charges == 2 then
            Attack.log( "charges_gizmo_1", "name", "<label=cpn_gizmo></color>" )
          else
            Attack.log( "charges_gizmo_2", "name", "<label=cpn_gizmo></color>", "charges", ( charges - 1 ) )
          end
	       end
      end
      Attack.aseq_timeshift( 0, d )
    end
  end

  return true
end


function gizmo_idle()
  local idle_value = gizmo_animation_from_charges( Attack.val_restore( "charges" ) )
  Atom.animate( "idle" .. idle_value )
end


-- New! Function for determining the correct animation based on charges
-- Cycles through the 3 different animations based on charges in multiples of 3
function gizmo_animation_from_charges( charges )
  return modulo( charges - 1, 3 ) + 1
end


-----------------
----Devatron-----
-----------------

function devatron_calccells()
  Attack.multiselect( 3 )

  for i = 0, Attack.cell_count() - 1 do
    local cell = Attack.cell_get( i )
    Attack.marktarget( cell )
  end

  return true
end

function get_devatron_cells()
  local ids = {}

  -- запоминаем всех соседей для 3-х выбранных клеток
  for tar = 0, 2 do
    local t = Attack.get_target( tar )

    if t ~= nil then
      for i = 0, 5 do
        local c = Attack.cell_adjacent( t, i )

        if c ~= nil
        and Attack.cell_present( c ) then
          ids[ Attack.cell_id( c ) ] = true
        end
      end
    end
  end

  -- исключаем сами выбранные клетки
  for tar = 0, 2 do
    local t = Attack.get_target( tar )

    if t ~= nil then
      ids[ Attack.cell_id( t ) ] = nil
    end
  end

  local cells = {}

  for id in pairs( ids ) do
    local c = Attack.cell_id( id )

    if c ~= nil
    and ( ( Attack.act_enemy( c )
    or Attack.act_takesdmg( c )
    and not Attack.act_name( c ) == "devatron" )
    or ( Attack.cell_is_empty( c )
    and Attack.cell_is_pass( c ) ) ) then
      table.insert( cells, c )
    end
  end

  return cells
end

function devatron_highlight()
  for i, c in ipairs( get_devatron_cells() ) do
    if Attack.act_enemy( c )
    and Attack.act_takesdmg( c ) then
      Attack.cell_select( c, "avenemy" )
    else
      Attack.cell_select( c, "destination" )
    end
  end

  return true
end

function lina_devatron()
  local r = Game.Random()
  local target = Attack.get_target()

  if Attack.is_short_spirit_seq() then
    Attack.act_aseq( 0, "2cast" )
    Attack.act_fadeout( 0, 0, 1./25., 0., 0. )
    Attack.act_rotate( 0, .1, 0, target )
    Attack.cam_track_duration( 7.6 )

    if Game.ArenaShape() == 4 then
      if r <0.7 then
			     Attack.cam_track( 0, 0, "spirit_cam_short_ships.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
		    end
    else
      if r <= 0.44 then
        Attack.cam_track( 0, 0, "spirit_cam_short_centre.track" )
      elseif r <= 0.88 then
        Attack.cam_track( 0, 0, "spirit_cam_short_2left.track" )
      else
        Attack.cam_track( 0, 0, "spirit_cam_short_2right.track" )
      end
    end
  else
    lina_appear_idle()

    --******************************** camera control
    if Game.ArenaShape() == 4 then --  ships
     	Attack.cam_track_duration( 14.8 )

      if r <0.7 then
			     Attack.cam_track( 0, 0, "spirit_cam_ships.track" )
		    else
        Attack.cam_track( 0, 0, "spirit_cam_2left.track" )
		    end
    elseif Game.ArenaShape() == 1 then --  castle
      if r <= 0.35 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r_castle.track" )
      elseif r <= 0.7 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l_castle.track" )
      elseif r <= 0.9 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_r_castle.track" )
      elseif r <= 1.0 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup_castle.track" )
      end
    elseif Game.ArenaShape() == 5 then --  water
      if r <= 0.5 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r_castle.track" )
      else
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l_castle.track" )
      end
    else
      if r <= 0.2 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2r.track" )
      elseif r <= 0.4 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_still2l.track" )
      elseif r <= 0.6 then
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_r.track" )
      else
        Attack.cam_track( 0, 0, "cam_lina_rare_devatron_closeup.track" )
      end
    end
    --********************************* End of camera control

    Attack.act_rotate( Attack.aseq_time( 0, "x" ), Attack.aseq_time( 0, "y" ), 0, target )
    Attack.act_aseq( 0, "cast" )
  end

  local start = Attack.aseq_time( 0, "z" );
  local duration = tonumber( Attack.get_custom_param( "duration" ) )
  local freeze = tonumber( Attack.get_custom_param( "freeze" ) )
  local thorns = tonumber( Attack.get_custom_param( "thorns" ) )
  local min_dmg = tonumber( Attack.get_custom_param( "damage.physical.0" ) )
  local max_dmg = tonumber( Attack.get_custom_param( "damage.physical.1" ) )

  for i, c in ipairs( get_devatron_cells() ) do
    local deviation = Game.Random( 000,600 )/1000.
    local t = start + deviation

    if Attack.cell_is_empty( c )
    and Attack.cell_is_pass( c ) then
      local atom = Attack.atom_spawn( c, t, "devatron" )
      Attack.act_animate( atom, "appear", t )
      local random_dur = Game.Random( 1, duration )
      Attack.val_store( atom, "duration", random_dur )
      Attack.val_store( atom, "min_dmg", min_dmg * thorns / 100 )
      Attack.val_store( atom, "max_dmg", max_dmg * thorns / 100 )
      Attack.val_store( atom, "dmg_type", "physical" )
    elseif Attack.act_enemy( c )
    and Attack.act_takesdmg( c ) then
      local a = Attack.atom_spawn( c, start + deviation / 10, "devatron_throw" )
      Attack.act_aseq( a, "idle" )
      local hit_time = Attack.aseq_time( a, "x" ) + start + deviation / 10
      local dmg_min, dmg_max = common_freeze_im_vul( c, min_dmg, max_dmg )
      Attack.atk_set_damage( "physical", dmg_min, dmg_max )
      local returnval, dead = common_cell_apply_damage( c, hit_time )
--[[      local hit_x = Attack.aseq_time( c, "x" )
      Attack.aseq_timeshift( c, hit_time )
      Attack.dmg_timeshift( c, hit_time )
      local dead = Attack.act_damage( c )]]

      if not dead then
        common_freeze_attack( c, "devatron", freeze, hit_time + 2, duration )
      end
    end
  end

  spirit_after_hit()
  Attack.log( "slime_fog", "name", "<label=cpn_lina>", "target", "<label=cpsn_devatron>" )

  return true
end

function devatron_attack()
  local duration = Attack.val_restore( 0, "duration" )
  duration = duration - 1

  if duration == 0 then
		  local dmgts = Attack.aseq_time( 0, "x" )
    local min_dmg = Attack.val_restore( 0, "min_dmg" )
    local max_dmg = Attack.val_restore( 0, "max_dmg" )
    local dmg_type = Attack.val_restore( 0, "dmg_type" )

  		for dir = 0, 5 do
		    local c = Attack.cell_adjacent( 0, dir )

		    if c ~= nil
      and Attack.cell_present( c )
      and Attack.act_takesdmg( c )
      and not ( Attack.act_name( c ) == "devatron" ) then
        local dmg_min, dmg_max = common_freeze_im_vul( c, min_dmg, max_dmg )
        Attack.atk_set_damage( dmg_type, dmg_min, dmg_max )
		    	 common_cell_apply_damage( c, dmgts + Game.Random() )
    				Attack.log_label( '' )
		    end
		  end

    Attack.act_kill()
  else
    Attack.val_store( 0, "duration", duration )
  end

  return true
end

function devatron_thorns( wnm, ts, dead )
 	if dead then
    local min_dmg = Attack.val_restore( 0, "min_dmg" )
    local max_dmg = Attack.val_restore( 0, "max_dmg" )
    local dmg_type = Attack.val_restore( 0, "dmg_type" )
	   local target = Attack.val_restore( 0, "target" )

    if target ~= nil then
      local dmg_min, dmg_max = common_freeze_im_vul( target, min_dmg, max_dmg )
      Attack.atk_set_damage( dmg_type, dmg_min, dmg_max )
      common_cell_apply_damage( target, ts + 0.5 )
  				Attack.log_label( '' )
    end
  end

	 return true
end

function devatron_posthitslave( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if ( minmax == 0 )
  and damage > 0 then
    local dist = Attack.cell_dist( receiver, attacker )

    if dist <= 1
    and Attack.act_takesdmg( attacker )
    and not Attack.act_pawn( attacker )
    and not Attack.act_feature( attacker, "pawn" )
    and not Attack.act_feature( attacker, "boss" ) then
      Attack.val_store( receiver, "target", attacker )
    end
  end

	 return damage, addrage
end

function gen_devatron_par()
  local min_dmg = Attack.val_restore( 0, "min_dmg" )
  local max_dmg = Attack.val_restore( 0, "max_dmg" )

  return tostring( min_dmg ) .. "-" .. tostring( max_dmg )
end


