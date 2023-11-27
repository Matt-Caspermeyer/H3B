-- ***********************************************
-- * NEW! Applies Difficult Level Bonus to talents
-- ***********************************************
function apply_difficulty_level_talent_bonus( value, max )
  if value == "" then
    value = nil
  end

  if value ~= nil then
    value = tonumber( value )
    local diff_k = Attack.val_restore( 0, "diff_k" )
    local sign_diff_k = Attack.val_restore( 0, "sign_diff_k" )
    local min_stat_inc = Attack.val_restore( 0, "min_stat_inc" )
    local value_inc = 0
    
    if diff_k ~= nil
    and sign_diff_k ~= nil
    and min_stat_inc ~= nil then
      value_inc = math.max( round( math.abs( value * diff_k ) ), min_stat_inc ) * sign_diff_k
    end
  
    if max ~= nil then
      return math.min( max, value + value_inc )
    else
      return value + value_inc
    end
  else
    return value
  end
end


-- *********************************************************** --
-- New! For Black Dragons to layout their path - based on WotN --
-- *********************************************************** --
function special_blackdragon_firepower_calccells()
  if Attack.act_get_par( 0, "dismove" ) > 0 then
    return true
  end

  local cycle = Attack.get_cycle()
  local ccnt = Attack.cell_count()
  local ap = Attack.act_ap(0)

  if not Attack.is_computer_move() then 
		  Game.InfoHint( "bmsg_firepower_" .. ( math.min( 2, cycle + 1 ) ) )
  end 

  local function cellmark( cell, path, ap, ldist )
    local dir = path[ ldist ].dir

    for c = 0, 2 do
      local cell_c = Attack.cell_adjacent( cell, math.mod( dir + c + 5, 6 ) )

      if Attack.cell_present( cell_c ) then
        if ( ldist < ap - 1 ) then
          Attack.marktarget( cell )
        elseif ( ldist == ap - 1 ) and ( ( Attack.cell_is_empty( cell_c ) and Attack.cell_is_pass( cell_c ) ) or Attack.act_equal( 0, cell_c ) ) then
          Attack.marktarget( cell )
        end
      end
    end

    return true
  end

  local function cellmarkfirstcycle( cell, path, ap )
    local ldist = table.getn( path ) - 1

    if ( ldist < ap ) then
      cellmark( cell, path, ap, ldist )

      if Attack.cell_is_empty( cell )
      and Attack.cell_is_pass( cell ) then
        Attack.marktarget( cell )
      end
    elseif ( ldist == ap )
    and Attack.cell_is_empty( cell )
    and Attack.cell_is_pass( cell ) then
      Attack.marktarget( cell )
    end

    return true
  end

  local function cellmarkcycle( cell, dist, ldist, path )
    if ldist == dist
    and Attack.cell_is_empty( cell )
    and Attack.cell_is_pass( cell ) then
      Attack.marktarget( cell )
    end

    if Attack.act_equal( 0, cell )
    and ldist <= dist then
      Attack.marktarget( cell )
    end

    if ldist < dist
    and ldist ~=0 then
      cellmark( cell, path, dist, ldist )
      if Attack.cell_is_empty( cell )
      and Attack.cell_is_pass( cell ) then
        Attack.marktarget( cell )
      end
    end

    return true
  end

  for i = 0, ccnt - 1 do
    local cell = Attack.cell_get( i )

    if Attack.cell_is_pass( cell, 2 ) then
      if cycle == 0 then
        local path = Attack.calc_path( 0, cell )

        if path ~= nil then
          for a = 0, 2 do
            if table.getn( path ) >= 3 then
              local dir_l = path[ table.getn( path ) - 1 ].dir
              local dir_l1 = path[ table.getn( path ) - 2 ].dir

              if dir_l == math.mod( dir_l1 + a + 5, 6 ) then
                cellmarkfirstcycle( cell, path, ap )
              end
            else
              cellmarkfirstcycle( cell, path, ap )
            end
          end
        end
      else
        local cell_firepower = Attack.val_restore( 0, "firepower_" .. cycle )
        local path = Attack.calc_path( cell_firepower, cell )

        if path ~=nil then
          local dist = ap - Attack.val_restore( 0, "useddist" )
          local ldist = table.getn( path ) - 1
          local oldpath = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. cycle-1 ), cell_firepower )
          local olddir = oldpath[ table.getn( oldpath ) - 1 ].dir
          local dir_f = path[ 1 ].dir

          for a = 0, 2 do
            for b = 0, 2 do
              if table.getn( path ) >= 3 then
                local dir_l = path[ table.getn( path ) - 1 ].dir
                local dir_l1 = path[ table.getn( path ) - 2 ].dir

                if dir_l == math.mod( dir_l1 + a + 5, 6 )
                and dir_f == math.mod( olddir + b + 5, 6 ) then
                  cellmarkcycle( cell, dist, ldist, path )
                end
              else
                if dir_f == math.mod( olddir + b + 5, 6 ) then
                  cellmarkcycle( cell, dist, ldist, path )
                end
              end
            end
          end

          if ( Attack.cell_is_empty( cell_firepower )
          and Attack.cell_is_pass( cell_firepower ) )
          or Attack.act_equal( 0, cell_firepower ) then
            Attack.marktarget( cell_firepower )
          end
        end
      end
    end
  end

  return true
end

function special_blackdragon_firepower_highlight( target )
  local cycle = Attack.get_cycle()

  if cycle == 0 then
    local path = Attack.calc_path( 0, target )

    if path ~= nil then
      for i = 2, table.getn( path ) - 1 do
        local c = path[ i ].cell

        if ( Attack.act_enemy( c )
        or Attack.act_ally( c ) )
        and Attack.act_takesdmg( c )
        and not Attack.act_equal( 0, c ) then
          Attack.cell_select( c, "avenemy" )
        else
          Attack.cell_select( c, "path" )
        end
      end

      local c = path[ table.getn( path ) ].cell

      if ( Attack.act_enemy( c )
      or Attack.act_ally( c ) )
      and Attack.act_takesdmg( c )
      and not Attack.act_equal( 0, c ) then
        Attack.cell_select( c, "avenemy" )
      else
        Attack.cell_select( c, "destination" )
      end
    end
  else
    for a = 0, cycle - 1 do
      local path_past = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. a ), Attack.val_restore( 0, "firepower_" .. ( a + 1 ) ) )

      if path_past ~= nil then
        for i = 2,table.getn( path_past ) do
          local c = path_past[ i ].cell

          if ( Attack.act_enemy( c )
          or Attack.act_ally( c ) )
          and Attack.act_takesdmg( c )
          and not Attack.act_equal( 0, c ) then
            Attack.cell_select( c, "avenemy" )
          else
            Attack.cell_select( c, "path" )
          end
        end
      end
    end

    if target ~= nil then
      local path = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. cycle ), target )

      if path ~= nil then
        for i = 2, table.getn( path ) - 1 do
          local c = path[ i ].cell

          if ( Attack.act_enemy( c )
          or Attack.act_ally( c ) )
          and Attack.act_takesdmg( c )
          and not Attack.act_equal( 0, c ) then
            Attack.cell_select( c, "avenemy" )
          else
            Attack.cell_select( c, "path" )
          end
        end

        local c = path[ table.getn( path ) ].cell

        if ( Attack.act_enemy( c )
        or Attack.act_ally( c ) )
        and Attack.act_takesdmg( c )
        and not Attack.act_equal( 0, c ) then
          Attack.cell_select( c, "avenemy" )
        else
          Attack.cell_select( c, "destination" )
        end
      end
    end
  end

  return true
end

function special_blackdragon_firepower_attack()
  local cycle = Attack.get_cycle()
  local aps = Attack.act_ap( 0 )
  local useddist, dist, path_dist
  Attack.log_label( 'null' )

  if cycle == 0 then 
    if Attack.is_computer_move() then
      Attack.val_store( 0, "firepower_" .. cycle, Attack.get_cell( 0 ) )
      useddist = aps
      cycle = 1
      Attack.val_store( 0, "firepower_" .. ( cycle ), Attack.cell_id( tonumber( Attack.val_restore( "target" ) ) ) )
      Attack.val_store( 0, "firepower_" .. ( cycle + 1 ), Attack.get_target() )
    else
      Attack.val_store( 0, "firepower_" .. cycle, Attack.get_cell( 0 ) )
      Attack.val_store( 0, "firepower_" .. ( cycle + 1 ), Attack.get_target() )
      path_dist = Attack.calc_path( 0, Attack.get_target() )

      if path_dist ~= nil then
        dist = table.getn( path_dist ) - 1
        useddist = dist
        Attack.val_store( 0, "useddist", useddist )
      end
    end
  else
    path_dist = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. cycle ), Attack.get_target() )
    useddist = Attack.val_restore( 0, "useddist" )

    if path_dist ~= nil then
      dist = table.getn( path_dist ) - 1
      Attack.val_store( 0, "firepower_" .. ( cycle + 1 ), Attack.get_target() )
      useddist = useddist + dist
      Attack.val_store( 0,"useddist", useddist )
    else
      cycle = cycle - 1
      aps = useddist
    end
  end

  if useddist == aps then
    local path ={}
    local b = 1

    for t = 0, cycle do
      local pathw = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. t ), Attack.val_restore( 0, "firepower_" .. ( t + 1 ) ) )

      for k = b, ( b + table.getn( pathw )-2 ) do
        table.insert( path, table.getn( path ) + 1,pathw[ k - b + 1 ] )
      end

      b = b + table.getn( pathw ) - 1
      if t == cycle then 
        table.insert( path,table.getn( path ) + 1, pathw[ table.getn( pathw ) ] )
      end
    end

    if path == nil then 
      return false 
    end

    local typedmg = tostring( Attack.get_custom_param( "typedmg" ) )
    local dmg_min, dmg_max = text_range_dec( tostring( Attack.get_custom_param( "damage" ) ) )
    local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )
    burn = effect_chance( burn, "effect", "burn" )

    local multi = {}
    local apli = {}
    for i = 1, table.getn( path ) do
      if multi[ path[ i ].id ] == nil then
        multi[ path[ i ].id ] = 1
      else
        multi[ path[ i ].id ] = multi[ path[ i ].id ] + 1
      end

      apli[ i ] = 1
    end

    for i = 1, table.getn( path ) - 1 do
      for j = i + 1, table.getn( path ) do
        if path[ i ].id == path[ j ].id then
          apli[ i ]=0
        end
      end
    end

    Attack.act_no_cell_update( 0 )
    Attack.aseq_rotate( 0, path[ 2 ].cell )
    Attack.aseq_start( 0, "fire_takeoff", "fire_flight" )
    local i = 2
    local dir = path[ 1 ].dir

    local function common_burn_damage( cell, dmgts, burn )
      common_cell_apply_damage( cell, dmgts )
      local burn_rnd = Game.Random( 99 )
      local burn_res = Attack.act_get_res( cell, "fire" )
      local dmg = tonum( Attack.val_restore( 0, "last_dmg" ) )
      local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
      local burn_damage = dmg * burn_chance / 200

      if burn_rnd < burn_chance
      and not string.find( Attack.act_name( cell ), "cyclop" )
      and dmg > 0 then
        effect_burn_attack( cell, dmgts, 3, burn_damage, burn_damage )
      end
    end

    while i < table.getn( path ) do
      local ndir = path[ i ].dir

      if ndir == dir then
        if i + 2 < table.getn( path )
        and path[ i + 1 ].dir == dir
        and path[ i + 2 ].dir == dir then
          Attack.aseq_waft( 0, "fire_flight", "fire_waft" )

          if apli[ i ] == 1 then
            Attack.atk_set_damage( typedmg, dmg_min * multi[ path[ i ].id ], dmg_max * multi[ path[ i ].id ] )
            common_burn_damage( path[ i ].cell, Attack.aseq_time( 0, "v" ), burn )
          else
            Attack.act_animate( path[i].cell, "damage", Attack.aseq_time( 0, "v" ) )
          end

          Attack.atk_set_damage( typedmg, dmg_min, dmg_max )

          if apli[ i + 1 ] == 1 then
            Attack.atk_set_damage( typedmg, dmg_min * multi[ path[ i + 1 ].id ], dmg_max * multi[ path[ i + 1 ].id ] )
            common_burn_damage( path[ i + 1 ].cell, Attack.aseq_time( 0, "w" ), burn )
          else
            Attack.act_animate( path[ i + 1 ].cell, "damage", Attack.aseq_time( 0, "w" ) )
          end

          Attack.atk_set_damage( typedmg, dmg_min, dmg_max )
          i = i + 2
        else
          Attack.aseq_move( 0, "fire_flight" )
        end
      else
        if wrap( ndir - dir, -3, 3 ) == 1 then
          Attack.aseq_move( 0, "fire_flight", "fire_rdivert", 1 )
        else
          Attack.aseq_move( 0, "fire_flight", "fire_ldivert", -1 )
        end

        dir = ndir
      end

      if apli[i] == 1 then
        Attack.atk_set_damage( typedmg, dmg_min*multi[path[i].id], dmg_max*multi[path[i].id] )
        common_burn_damage( path[ i ].cell, Attack.aseq_time( 0, "x" ), burn )
      else
        Attack.act_animate( path[i].cell, "damage", Attack.aseq_time( 0, "x" ) )
      end
      i = i + 1
    end

    Attack.atk_set_damage( typedmg, dmg_min, dmg_max )
    Attack.act_aseq( 0, "fire_descent", false, true )
    Attack.atk_min_time( Attack.aseq_time( 0 ) + .5 )
    Attack.log_label( "" )

    return true
  else
    Attack.next( 0 )

    return true
  end
end


function is_target_appliciable( cell, ff )
  if ( cell ~= nil )
  and Attack.cell_present( cell ) then
    if not Attack.cell_is_empty( cell ) then
      if ( Attack.get_caa( cell ) ~= nil ) then
        if Attack.act_applicable( cell )
        and Attack.act_takesdmg( cell ) then
          if not ( ( ff == 0 )
          and Attack.act_ally( cell ) ) then
            return true
          end
        end
      end
    end
  end

  return false
end


function hint_dmg_blackdragon_firepower()
  local res = ""
  local target = Attack.get_target()
  local added_target_ids = {}
  local tab_target = {}
  local tab_multi = {}
  local friendly_fire = tonumber( Attack.get_custom_param( "friendly_fire" ) )

  local function path2targets( path, tab_target, tab_multi, added_target_ids, ff )
    if path ~= nil then
      for i = 2, table.getn( path ) do
        local cell = path[i].cell

        if is_target_appliciable( cell, ff ) then
          if not Attack.act_equal( 0, cell ) then
            local id = Attack.cell_id( cell )

            if tab_multi[ id ] == nil then
              tab_multi[ id ] = 1
            else
              tab_multi[ id ] = tab_multi[ id ] + 1
            end

            table.insert( tab_target, { c = cell, id = id } )
          end
        end
      end
    end
  end

  local cycle = Attack.get_cycle()

  if cycle == 0 then
    local path = Attack.calc_path( 0, target )
    path2targets( path, tab_target, tab_multi, added_target_ids, friendly_fire )
  else
    for i = 0, cycle - 1 do
      local path = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. tostring( i ) ), Attack.val_restore( 0, "firepower_" .. tostring( i + 1 ) ) )
      path2targets( path, tab_target, tab_multi, added_target_ids, friendly_fire )
    end

    local path = Attack.calc_path( Attack.val_restore( 0, "firepower_" .. tostring( cycle ) ), target )
    path2targets( path, tab_target, tab_multi, added_target_ids, friendly_fire )
  end

  local count = table.getn( tab_target )

  for i = 1, count do
    local target = tab_target[ i ].c
    local id = tab_target[ i ].id
    local dmg_mod = tab_multi[ id ]
    res = add_target( target, res, added_target_ids, dmg_mod )
  end

  return res
end


-- ***********************************************
-- * NEW! Horseman Charge
-- ***********************************************

function charge_check_target( c )
	 return Attack.cell_present( c )
  and Attack.act_applicable( c )
  and Attack.act_enemy( c )
  and not Attack.act_ally( c )
end

function charge_calccells()
  for i = 0, 5 do
    local c = Attack.cell_adjacent( 0, i )
    if empty_cell( c ) then
      while true do
        Attack.marktarget( c )
        c = Attack.cell_adjacent( c, i )
        if not empty_cell( c ) then break end
      end
   			if c ~= nil
      and charge_check_target( c ) then
				    Attack.marktarget( c )
			   end
    end
  end

  Attack.val_store( 0, "cell_id", Attack.cell_id( Attack.get_cell( 0 ) ) )

  return true
end

function charge_highlight()
  local target, prev = Attack.get_target()
  local dir = Game.Ang2Dir( Attack.angleto( 0, target ) )
  target = Attack.cell_adjacent( 0, dir ) -- на тот случай, когда target отдалена более чем на 1 клетку

  if empty_cell( target ) then
    while true do
      Attack.cell_select( target, "path" )
      prev = target
      target = Attack.cell_adjacent( target, dir )
      if not empty_cell( target ) then break end
    end
  end

  if target ~= nil
  and charge_check_target( target ) then
    Attack.cell_select( target, "avenemy" )
  elseif prev ~= nil then
    Attack.cell_select( prev, "destination" )
  end

 	return true
end

function special_charge()
  local target = Attack.get_target()
  local dir = Game.Ang2Dir( Attack.angleto( 0, target ) )
  target = Attack.cell_adjacent( 0, dir )
  Attack.aseq_rotate( 0, target )
 	Attack.log_label( '' )
  --target = Attack.cell_adjacent(target, dir)
  if empty_cell( target ) then
    Attack.act_no_cell_update( 0 )
    Attack.aseq_start( 0, "start2", "move2" )
    while true do
			   if cell_trap( target ) then target = nil; break end

      target = Attack.cell_adjacent( target, dir )

      if not empty_cell( target ) then break end

      Attack.aseq_move( 0, "move2" )
    end

    if target ~= nil
    and charge_check_target( target ) then
      Attack.act_aseq( 0, Attack.get_custom_param( "rushanim" ), false, true )
      common_cell_apply_damage( target, Attack.aseq_time( 0, "x" ) )
    else
			   Attack.log_label( 'null' )
      Attack.act_aseq( 0, "stop", false, true )
    end
  end

  Attack.atk_min_time( Attack.aseq_time( 0 ) + .2 )

  return true
end

function charge_posthit( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if Attack.atk_name() == "charge" then
		  local dmg_k = tonumber( Attack.get_custom_param( "rush_dmg_inc" ) ) -- %увеличения урона за каждую клетку
    local bonus = tonumber( Logic.hero_lu_item( "sp_special_attacks_horseman_charge", "count" ) )
		  local c = Attack.cell_id( Attack.val_restore( attacker, "cell_id" ) ) -- восстановить клетку, где стоял шар, можно только так, т.к. положение шара на момент вызова постхита - уже после перемещения
  		local k = Attack.cell_dist( c, receiver ) - 1
  		return damage * ( 1 + k * ( dmg_k + bonus ) / 100 )
	 end

	 return damage
end


function cell_trap( c )
	 local id = Attack.cell_id( Attack.get_cell( c ) )
	 for i = 1, Attack.act_count() - 1 do
		  local name = Attack.act_name( i )
		  if ( name == "trap" or name == "zlogna" )
    and Attack.cell_id( Attack.get_cell( i ) ) == id then
			   return i
		  end
	 end
end


-- ***********************************************
-- * Ray
-- ***********************************************

function beholder_ray_attack()

  local dist2table = {
    { d = 3, a = "ray02m" },
    { d = 5, a = "ray05m" },
    { d = 10, a = "ray10m" }

    -- d   - distance
    -- a   - atom tag
  }

  local target = Attack.get_target()                            -- epicentre

  --local target = Attack.get_targets_count()

  Attack.aseq_rotate(0, target, "cast")
  Attack.act_rotate(0,0.1, 0, target)
  local atk_x = Attack.aseq_time(0, "x")                   -- x time of attacker

  local d = Attack.cell_mdist(0,target) -- dist in meters
  d = math.floor( d +1)

  --local found_item = nil
  --local ldist = 10000

  --for ii,ti in ipairs(dist2table) do
    --local dd = math.abs(ti.d - d)
    --if dd < ldist then
      --ldist = dd
      --found_item = ti
    --end
  --end
  local found_item = "ray02m"
  if d>2 and d<10 then found_item="ray0"..d.."m" end
  if d>9 then found_item="ray"..d.."m" end

  --if found_item ~= nil then

    Attack.act_damage(target)

    local a = Attack.atom_spawn(0,0,found_item,Attack.angleto(0,target))
    local acid_x = Attack.aseq_time(a, "x")
    local acid_y = Attack.aseq_time(a, "y")
    Attack.aseq_timeshift( 0, acid_x - atk_x )

    -- damage time
    Attack.dmg_timeshift( target, acid_y )

      -- seqs of receiver time
    local hit_x = Attack.aseq_time( target, "x" )
    Attack.aseq_timeshift( target, acid_y - hit_x )
    Attack.atom_spawn(target, acid_y - hit_x*2, "hll_beholder_post", 0, true)


    return true
  --end

  --return false
end

-- ***********************************************
-- * Lightning
-- ***********************************************

function archmage_lightning_attack()

  local dist2table = {
    { d = 2, a = "hll_attack_archmage_2lighting" },
    { d = 4, a = "hll_attack_archmage_4lighting" },
    { d = 6, a = "hll_attack_archmage_6lighting" },
    { d = 8, a = "hll_attack_archmage_8lighting" },
    { d = 10, a = "hll_attack_archmage_10lighting" },
    { d = 12, a = "hll_attack_archmage_12lighting" },
    { d = 15, a = "hll_attack_archmage_15lighting" }

    -- d   - distance
    -- a   - atom tag
  }

  local target = Attack.get_target()                            -- epicentre


  --local target = Attack.get_targets_count()

  Attack.aseq_rotate(0, target, "attack")
  local atk_x = Attack.aseq_time(0, "x")                   -- x time of attacker

  local d = Attack.cell_mdist(0,target) -- dist in meters

  local found_item = nil
  local ldist = 10000

  for ii,ti in ipairs(dist2table) do
    local dd = math.abs(ti.d - d)
    if dd < ldist then
      ldist = dd
      found_item = ti
    end
  end

  if found_item ~= nil then

    Attack.act_damage(target)

    local a = Attack.atom_spawn(0,0,found_item.a,Attack.angleto(0,target))
    local acid_x = Attack.aseq_time(a, "x")
    local acid_y = Attack.aseq_time(a, "y")
    Attack.aseq_timeshift( 0, acid_x - atk_x )

    -- damage time
    Attack.dmg_timeshift( target, acid_y )
    Attack.atom_spawn(target, acid_y, "hll_post_archmage_lighting",0,true)


      -- seqs of receiver time
    local hit_x = Attack.aseq_time( target, "x" )
    Attack.aseq_timeshift( target, acid_y - hit_x )


    return true
  end

  return false
end

function archmage_lightning_selcells()

  Attack.railgun(false)
  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do

    local cell = Attack.cell_get(i)

    if (not Attack.cell_is_empty(cell)) then        -- is empty (has no live object)
      if Attack.act_enemy(cell) then      -- can receive this attack
        if Attack.act_applicable(cell) then      -- can receive this attack
          local d = Attack.cell_dist(0,cell)
          if d < 4 then
            Attack.marktarget(cell)           -- select it
          end
        end
      end
    end
  end
  return true
end

-- ***********************************************
-- * Shaman badabum
-- ***********************************************

function special_shaman_spirit_dance_attack()
  local target = Attack.get_target()                            -- epicentre
  local text = ""
  Attack.aseq_remove( 0 )
  Attack.act_aseq( 0, "cast" )
  local dmgts1 = Attack.aseq_time( 0, "x" )                   -- x time of attacker
  local dmgts2 = Attack.aseq_time( "oldaxe", "x" )            -- x time of effect atom
  Attack.atom_spawn( target, dmgts1 - dmgts2, "oldaxe" )      -- summon atom at x time
  local dmgts3 = Attack.aseq_time( "oldaxe", "y" )
  local count = Attack.act_size( 0 )
  local dmg_min, dmg_max = text_range_dec( Attack.get_custom_param( "damage" ) )
  local power = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "power" ) )
  local damage = Game.Random( dmg_min, dmg_max )
  local typedmg = Attack.get_custom_param( "typedmg" )
  Attack.atk_set_damage( typedmg, damage, damage )
  local dmgt = dmgts1 - dmgts2 + dmgts3
  common_cell_apply_damage( target, dmgt )
  damage = math.min( Attack.act_totalhp( target ), ( Attack.act_damage_results( target ) ) )
  local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )
  local dissipate = tonumber( Attack.get_custom_param( "dissipate" ) ) * ( 2 - apply_difficulty_level_talent_bonus( 100 ) / 100 )
  Attack.val_store( 0, "dissipate", dissipate )
  damage = damage + titan_energy

  if not Attack.act_feature( target, "pawn" ) then --здоровье пьем только из живых
    if not Attack.act_feature( target, "undead" )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "plant" ) then
      local function check_cure( i )
    	   return Attack.act_ally( i )
        and Attack.act_need_cure( i )
        and not Attack.act_feature( i,"pawn" )
        and not Attack.act_temporary( i )
        and Attack.act_race( i ) ~= "orc"
      end
  
      local function check_res( i )
    	   return Attack.act_ally( i )
        and Attack.cell_need_resurrect( i )
        and not Attack.act_feature( i,"pawn,plant,undead,golem" )
        and not Attack.act_temporary( i )
        and Attack.act_race( i ) == "orc"
      end

      -- считаем сколько юнитов нужно лечить
      local acnt = Attack.act_count()
      local need_cure, need_res = 0, 0
  
      for i = 1, acnt - 1 do
        if check_res( i ) then
          need_res = need_res + 1
        end
      end

      if need_res > 0 then
        local res = math.ceil( damage / need_res * power / 100 )
        damage = 0
    
        for i = 1, acnt - 1 do
          if check_res( i ) then
            local initsize = Attack.act_initsize( i )
            local health = Attack.act_get_par( i, "health" )
            local inithp = initsize * health
            local totalhp = Attack.act_totalhp( i )
            local newhp = totalhp + res
            local excess_hp = newhp - inithp
            local oldsize = Attack.act_size( i )
        
            if excess_hp > 0 then
              damage = damage + excess_hp
            end
        
            local a = Attack.atom_spawn( i, dmgt, "hll_priest_resur_cast" )
            local dmgts = Attack.aseq_time( a, "x" )
            Attack.cell_resurrect( i, res, dmgt + dmgts )
            local newsize = Attack.act_size( i )
            local res_units = newsize - oldsize
        
            if res_units > 1 then
              Attack.log( dmgt + 0.1, "add_blog_res_2", "target", blog_side_unit( i, 0 ), "special", res_units )
            elseif res_units > 0 then
              Attack.log( dmgt + 0.1, "add_blog_res_1", "target", blog_side_unit( i, 0 ), "special", res_units )
            else
              if oldsize > 1 then
                Attack.log( dmgt + 0.1, "add_blog_cure_2", "target", blog_side_unit( i, 0 ), "special", res )
              else
                Attack.log( dmgt + 0.1, "add_blog_cure_1", "target", blog_side_unit( i, 0 ), "special", res )
              end
            end
          end
        end
      end
  
      if damage > 0 then
        for i = 1, acnt - 1 do
          if check_cure( i ) then need_cure = need_cure + 1 end
        end
    
        if need_cure > 0 then
          -- пересчитываем урон в лечилку
          local cure = math.ceil( damage / need_cure * power / 100 )
          damage = 0
      
          --лечим
          for i = 1, acnt - 1 do
            if check_cure( i ) then
              local max_hp = Attack.act_get_par( i, "health" )
              local cure_hp = cure
              local cur_hp = Attack.act_hp( i )
              local need_cure_hp = max_hp - cur_hp
      
              if cure_hp > need_cure_hp then
                damage = damage + ( cure_hp - need_cure_hp )
                cure_hp = max_hp - cur_hp
              end
      
              local a = Attack.atom_spawn( i, dmgt, "effect_total_cure" )
              local dmgts = Attack.aseq_time( a, "x" )
              Attack.act_cure( i, cure_hp, dmgt + dmgts )
      
              if Attack.act_size( i ) > 1 then
                Attack.log( dmgt + 0.2, "add_blog_cure_2", "target", blog_side_unit( i, 0 ), "special", cure_hp )
              else
                Attack.log( dmgt + 0.2, "add_blog_cure_1", "target", blog_side_unit( i, 0 ), "special", cure_hp )
              end
            end
          end
        end
      end
    end

    if damage > 0 then
      local stored_energy = math.floor( damage * power / 100 )
      Attack.val_store( 0, "titan_energy", stored_energy )
      local count = "1"

      if stored_energy > 1 then
        count = "2"
      end

      Attack.log( dmgt + 0.3, "add_blog_ste_" .. count, "name", blog_side_unit( 0, 1 ), "special", stored_energy )
    end
  end

  return true
end

-- ***********************************************
-- * Shaman totems
-- ***********************************************

function special_shaman_totem()
  local target, name, health = Attack.get_target(), Attack.get_custom_param( "atomname" ), apply_difficulty_level_talent_bonus( Attack.get_custom_param( "health" ) )

  local totem = Attack.atom_spawn( target, 0, name )
  Attack.act_aseq( totem, "appear" )

  local titan_energy = tonum( Attack.val_restore( 0, "titan_energy" ) )
  local power = 80
  local stored_energy = math.floor( titan_energy * power / 100 )
  local count2 = "1"

  if stored_energy > 0 then
    Attack.val_store( 0, "titan_energy", stored_energy )
    count2 = "2"
  end

  if titan_energy > 0
  and stored_energy > 0 then
    Attack.log( 0, "add_blog_ate_" .. count2, "name", blog_side_unit( 0, 1 ), "target", blog_side_unit( totem, 0 ), "special2", titan_energy, "special", stored_energy )
  elseif titan_energy > 0 then
    Attack.log( 0, "add_blog_ate_d", "name", blog_side_unit( 0, 1 ), "target", blog_side_unit( totem, 0 ), "special2", titan_energy )
  end

  local count = Attack.act_size( 0 )
  local total_hp = Attack.act_totalhp( 0 )
  local hp = math.ceil( health / 100 * total_hp + titan_energy )
  Attack.act_hp( totem, hp )
  Attack.act_set_par( totem, "health", hp )
  local init, init_base = Attack.act_get_par( 0, "initiative" )
  local init_den = tonumber( Attack.get_custom_param( "init_den" ) )
  local totem_init = init_base + math.floor( hp / init_den )
  Attack.act_set_par( totem, "initiative", totem_init )

  local edg = 1

  if Attack.act_belligerent(0) == 1 then
    edg = 0
  end

  Attack.act_edge( totem, edg )
  Attack.val_store( totem, "power", count )
  Attack.val_store( totem, "belligerent", Attack.act_belligerent( 0 ) )
  Attack.log_label( "add_blog_place_" ) -- работает

  return true
end

function special_demoness_pentagramm()
  local target, name = Attack.get_target(), Attack.get_custom_param( "atomname" )
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )
  duration = apply_hero_duration_bonus( target, duration, "sp_duration_blood", true )
  Attack.aseq_rotate( 0, target, "cast" )
  local pentagramm = Attack.atom_spawn( target, Attack.aseq_time(0, "x"), name, 0 )
  Attack.val_store( pentagramm, "belligerent", Attack.act_belligerent(0) )
  Attack.val_store( pentagramm, "time_last", duration )
  Attack.log_label( "add_blog_place_" ) -- работает

  return true
end


-- ***********************************************
-- * alchemist acid cannon
-- ***********************************************

function alchemist_acidcannon_attack()

  local dist2table = {
    { d = 1.8, a = "hll_acidcannon1" },
    { d = 3.6, a = "hll_acidcannon2" },
    { d = 5.4, a = "hll_acidcannon3" }

    -- d   - distance
    -- a   - atom tag
  }

  local target = Attack.get_target()                            -- epicentre


  --local target = Attack.get_targets_count()

  Attack.aseq_rotate(0, target, "attack")
  local atk_x = Attack.aseq_time(0, "x")                   -- x time of attacker

  local d = Attack.cell_mdist(0,target) -- dist in meters

  local found_item = nil
  local ldist = 10000

  for ii,ti in ipairs(dist2table) do
    local dd = math.abs(ti.d - d)
    if dd < ldist then
      ldist = dd
      found_item = ti
    end
  end

  if found_item ~= nil then

    --Attack.act_damage(target)

    local a = Attack.atom_spawn(0,0,found_item.a,Attack.angleto(0,target))
    local acid_x = Attack.aseq_time(a, "x")
    local acid_y = Attack.aseq_time(a, "y")
    Attack.aseq_timeshift( 0, acid_x - atk_x )

    -- damage time
--[[    Attack.dmg_timeshift( target, acid_y )

      -- seqs of receiver time
    local hit_x = Attack.aseq_time( target, "x" )
    Attack.aseq_timeshift( target, acid_y - hit_x )]]

  local targets = {}
  alchemist_acidcannon_enum_targets(target, function (c) table.insert(targets, c) end)

  for i,target in ipairs(targets) do
      common_cell_apply_damage(target, acid_y)       -- apply damage
  end


    return true
  end

  return false
end

function alchemist_acidcannon_filter( cell, present )
  if present then
    return true
  end
  return Attack.act_enemy(cell) and Attack.act_applicable(cell)
end

function alchemist_acidcannon_selcells()

  --Attack.railgun(true)
  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do

    local cell = Attack.cell_get(i)

    if (not Attack.cell_is_empty(cell)) then        -- is empty (has no live object)
      if Attack.act_enemy(cell) or Attack.act_pawn(cell) then      -- can receive this attack
        if Attack.act_applicable(cell) then      -- can receive this attack
          local d = Attack.cell_dist(0,cell)
          if d < 4 then
            Attack.marktarget(cell)           -- select it
          end
        end
      end
    end
  end
  return true
end


function alchemist_acidcannon_enum_targets(target, func)

  local ang = Attack.angleto(0, target)
  local dir = Game.Ang2Dir(ang)
  local ang2 = Game.Dir2Ang(dir)

  function select(c)
    --local id = Attack.cell_id(c)
    if Attack.cell_present(c) and (Attack.act_enemy(c) or Attack.act_ally(c) or Attack.act_pawn(c)) then
        func(c)
    end
  end

  if (math.abs(ang - ang2) < .001) then -- стрельба по прямой
    local c = 0
    while true do
      c = Attack.cell_adjacent(c, dir)
      if c == nil then break end
      select(c)
      if Attack.cell_id(c) == Attack.cell_id(target) then break end
    end
  elseif Attack.cell_dist(0, target) == 2 then
    select(target)
  else
    c = Attack.cell_adjacent(0, dir)
    if c == nil then return true end
    select(c)
    if wrap(ang - ang2, -math.pi, math.pi) > 0 then
      c = Attack.cell_adjacent(c, wrap(dir+1, 6))
    else
      c = Attack.cell_adjacent(c, wrap(dir-1, 6))
    end
    if c == nil then return true end
    select(c)
    c = Attack.cell_adjacent(c, dir)
    if c == nil then return true end
    select(c)
  end

end

function alchemist_acidcannon_highlight(target)

  alchemist_acidcannon_enum_targets(target, function (c) Attack.cell_select(c, "avenemy") end)

  return true

end


-- ***********************************************
-- * Ogre Rage
-- ***********************************************

function special_ogre_rage_attack()
--  local target = Attack.get_target()
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_ogre_rage", true )
  local power = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "power" ) )
  local attack = Attack.act_get_par( 0, "attack" )
  Attack.act_del_spell( 0, "spell_weakness" )
  Attack.act_del_spell( 0, "special_ogre_rage" )
		Attack.act_ap( 0, Attack.act_ap( 0 ) + apply_difficulty_level_talent_bonus( Attack.get_custom_param( "ap" ) ) )
  Attack.act_apply_spell_begin( 0, "special_ogre_rage", duration, false )
  Attack.act_apply_par_spell( "attack", attack * power / 100, 0, 0, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_aseq( 0, "cast" )

  return true
end

-- ***********************************************
-- * Magic shield
-- ***********************************************
function special_magic_shield_attack()

  local target = Attack.get_target()

  if (target ~= nil) then
    local duration = Logic.obj_par( "special_magic_shield", "duration" )

    duration = apply_hero_duration_bonus( target, duration, "sp_duration_special_magic_shield", true )

    local dfactor = Logic.obj_par( "special_magic_shield", "power" )

    Attack.act_del_spell(target,"special_magic_shield")

    Attack.act_apply_spell_begin( target, "special_magic_shield", duration, false )
    --Attack.act_apply_par_spell( "dfactor", dfactor/100, 0, 0, duration, false)
      Attack.act_posthitslave(target, "post_magic_shield", duration)
    Attack.act_apply_spell_end()

    Attack.aseq_rotate(0, target, "cast")
--    Attack.act_aseq( 0, "cast" )
    dmgts = Attack.aseq_time(0, "x")

    Attack.atom_spawn(target, dmgts , "shield" )
  end

  return true
end

-- ***********************************************
-- * Berserk
-- ***********************************************

function special_berserk_attack()
  local duration = Logic.obj_par( "special_berserk", "duration" )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_berserk", true )
  local power = Logic.obj_par( "special_berserk", "power" )
  local penalty = Logic.obj_par( "special_berserk", "penalty" )
  local attack = Attack.act_get_par( 0, "attack" )
  local initiative = Attack.act_get_par( 0, "initiative" )
  local defense = Attack.act_get_par( 0, "defense" )
  local krit = Attack.act_get_par( 0, "krit" )
  Attack.act_apply_spell_begin( 0, "special_berserk", duration, false )
  Attack.act_apply_par_spell( "attack", 0, power, 0, duration, false )
  Attack.act_apply_par_spell("autofight", 1, 0, 0, duration, false )
  Attack.act_apply_par_spell( "initiative", 0, power, 0, duration, false )
  Attack.act_apply_par_spell( "defense", 0, -penalty, 0, duration, false )
  Attack.act_apply_par_spell( "krit", krit * power / 100, 0, 0, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_aseq( 0, "cast" )

  return true
end

-- ***********************************************
-- * Haste
-- ***********************************************

function special_haste_attack()
  local duration = Logic.obj_par( "special_haste", "duration" )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_special_haste", true )
  local power = Logic.obj_par( "special_haste", "power" )
  local speed = Attack.act_get_par( 0, "speed" )
  Attack.act_aseq( 0, "speed" )
		Attack.act_ap( 0, Attack.act_ap( 0 ) + Attack.act_ap( 0 ) )
  Attack.atom_spawn( 0, 0, "magic_haste", Attack.angleto( 0 ) )

  return true
end

-- ***********************************************
-- * Spider Web
-- ***********************************************
function special_spider_web_attack()
  local target = Attack.get_target()

  if (target ~= nil) then
    local duration = Logic.obj_par( "special_spider_web", "duration" )
    duration = apply_hero_duration_bonus( target, duration, "sp_duration_special_spider_web", false )
    Attack.act_del_spell( target, "special_spider_web" )
    Attack.act_apply_spell_begin( target, "special_spider_web", duration, false )
    Attack.act_apply_par_spell( "dismove", 1, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.aseq_rotate( 0, target )
    local start = Attack.aseq_time( 0 )
   	Attack.atom_spawn( target, start, "spiderweb_effect", Attack.angleto( 0, target ) )
    Attack.act_attach_atom( target, "spiderweb", start )
    Attack.act_aseq( 0, "cast" )
  end

  return true
end

function spider_web_onremove(caa,duration_end)
    Attack.act_deattach_atom( caa, "spiderweb", 0 )
    return true
end

-- ***********************************************
-- * Bless
-- ***********************************************

function special_bless_attack()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target, "cure" )
  dmgts = Attack.aseq_time( 0, "x" )

  if target~=nil  then
    if Attack.act_race( target ) ~= "undead" then
      local duration = tonumber( Logic.obj_par( "special_holy_rage", "duration" ) )

      if Attack.get_custom_param( "rage" ) == "0" then
        duration = apply_hero_duration_bonus( target, duration, "sp_duration_bless", true )
      else
        duration = apply_hero_duration_bonus( target, duration, "sp_duration_holy_rage", true )
      end

      effect_bless_weakness_attack( target, "spell_bless", duration, dmgts, "magic_bless", false )
  
      if Attack.get_custom_param( "rage" ) == "0" then
        Attack.atom_spawn( target, dmgts, "magic_bless", Attack.angleto( target ) )
      else
        local damage = Logic.obj_par( "special_holy_rage", "damage" )

        if not Attack.act_feature( target, "plant" )
        and not Attack.act_feature( target, "golem" ) then 
          Attack.act_apply_spell_begin( target, "special_holy_rage", duration, false )
          Attack.act_posthitmaster( target, "features_holy_attack" ,duration )
          Attack.act_apply_spell_end()
          Attack.atom_spawn( target, dmgts + 0.3, "effect_hard_bless", 0, true )
        end 
  
        if Attack.act_human(0) then
          local rage = Game.Random( text_range_dec( Logic.obj_par( "special_holy_rage", "rage" ) ) )
          rage = get_add_gain_bonus( rage, "rage_holy_rage" )
          local skill_bonus = 1 + skill_power2( "rage", 1 ) / 100
          rage = math.ceil( rage * skill_bonus * mana_rage_gain_k )

          if rage ~= 0 then
            local cur_rage = Logic.hero_lu_item( "rage", "count" )
            Logic.hero_lu_item( "rage", "count", cur_rage + rage )
          end
        end
  		
    		  Attack.atom_spawn( target, dmgts, "magic_bless", Attack.angleto( target ) )
      end
    else
      if not Attack.act_feature( target, "plant" )
      and not Attack.act_feature( target, "golem" ) then
        local duration = Logic.obj_par( "effect_holy", "duration" ) + tonumber( Logic.hero_lu_item( "sp_duration_effect_holy", "count" ) )
        Attack.act_del_spell( target, "effect_holy" )
        effect_holy_attack( target, dmgts, duration )
      end 
    end
  end

  return true
end

-- ***********************************************
-- * Stupid
-- ***********************************************
function special_stupid_attack()
  local target = Attack.get_target()

  if (target ~= nil) then
    local duration = Logic.obj_par( "special_stupid", "duration" )
    duration = apply_hero_duration_bonus( target, duration, "sp_duration_special_stupid", false )
    Attack.act_del_spell( target, "special_stupid" )
    Attack.act_del_spell( target, "spell_magic_bondage" )
    Attack.act_apply_spell_begin( target, "special_stupid", duration, false )
    Attack.act_apply_par_spell( "disreload", 10, 0, 0, duration, false )
    Attack.act_apply_par_spell( "disspec", 10, 0, 0, duration, false )
    Attack.act_apply_spell_end()
    Attack.act_aseq( 0, "cast" )
    dmgts = Attack.aseq_time( 0, "x" )
    Attack.atom_spawn( target, dmgts, "magic_bondage", Attack.angleto( target ) )
  end

  return true
end

-- ***********************************************
-- * Wolf cry
-- ***********************************************

function check_wolf_cry( i )
  local level = tonumber( Logic.obj_par( "special_wolf_cry", "level" ) )

  return Attack.act_enemy( i )
    and ( Attack.act_race( i ) == "human"
    or Attack.act_race( i ) == "elf"
    or Attack.act_race( i ) == "dwarf"
    or ( string.find( Attack.act_name( i ), "pirat" )
    --[[or string.find( Attack.act_name( i ), "barbarian" )]] ) )
    and Attack.act_level( i ) <= level
    and not Attack.act_feature( i, "mind_immunitet" )
end

function special_wolf_cry_attack()

  local duration = tonumber( Logic.obj_par( "special_wolf_cry", "duration" ) )
  local power = tonumber( Logic.obj_par( "special_wolf_cry", "power" ) )
  Attack.act_aseq( 0, "rare" )
  dmgts = Attack.aseq_time( 0, "x" )
  local acnt = Attack.act_count()

  for i = 1, acnt - 1 do
    if check_wolf_cry( i ) then
      local rnd = Game.Random( 99 )
      duration = apply_hero_duration_bonus( i, duration, "sp_duration_special_wolf_cry", false )
      Attack.act_apply_spell_begin( i, "effect_fear", duration, false )
      Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )

      if rnd < power then Attack.act_skipmove( i, 1 ) end

      Attack.act_apply_spell_end()
      Attack.atom_spawn( i, dmgts, "magic_scare", Attack.angleto( i ) )

      if Attack.act_size( i ) > 1 then
        Attack.log( 0.001, "add_blog_fear_2", "targets", "   "..blog_side_unit( i, 0 ) )
      else
        Attack.log( 0.001, "add_blog_fear_1", "target", "   "..blog_side_unit( i, 0 ) )
      end
    end
  end

  return true
end


-- ***********************************************
-- * Werewolf
-- ***********************************************

function special_transform()
  Attack.act_aseq( 0, "transform" )

  --HACK - if this unit has a difficulty modifier, then setup parameters so that bonuses can reapplied below
  for i = 0, Attack.act_spell_count( 0 ) - 1 do
    local spell_name = Attack.act_spell_name( 0, i )
    if string.find( spell_name, "special_difficulty" ) then
      TRANSFORM_SPECIAL_DIFFICULTY = true
      -- Sometimes a transforming unit will have to wait before it continues its turn, so we need the cell ID
      -- to properly identify the unit for bonus reapplication - I wish I knew a better way to do this...
      TRANSFORM_CELL_ID = Attack.get_cell( 0 )
      break
    end
  end

  Attack.act_del_spell( 0 )  -- Because of this, the above is needed
  Attack.act_transform( 0, Attack.aseq_time( 0 ) )
  local name = Attack.act_name( 0 )

  if string.find( name, "bat" )
  or name == "wolf" then
    Attack.log_label( "add_blog_tr_" ) -- работает
  end

  if string.find( name, "vampire" ) then
    Attack.log_label( "add_blog_trbat_" ) -- работает
  end

  if name == "werewolf" then
    Attack.log_label( "add_blog_trwolf_" ) -- работает
  end

  return true
end


-- New function for resetting the enemy unit bonuses between turns
function transform_modificators()
  if TRANSFORM_SPECIAL_DIFFICULTY == true then
    TRANSFORM_SPECIAL_DIFFICULTY = nil  -- reset for next transformer
    -- Using the cell ID is needed because the current unit, might not be the same that just transformed
    update_enemy_units_based_on_difficulty( Attack.get_caa( Attack.get_cell( TRANSFORM_CELL_ID ) ) )
    TRANSFORM_CELL_ID = nil  -- clean up
  end

end

-- ***********************************************
-- * Resurrect (phoenix)
-- ***********************************************

function special_resurrect()
  for i = 1, 10 do
 	  local name = Attack.act_name( Attack.cell_get_corpse( 0 ) )
   	if string.find( name, "phoenix" ) then
     	Attack.act_resurrect( 0 )
      Attack.act_charge( 0 )
      local ehero_level = tonumber( Attack.val_restore( 0, "ehero_level" ) )

      if ehero_level == 0 then
        summon_bonus( 0, "spell_phoenix" )
      else
        summon_bonus( 0, "spell_phoenix", nil, ehero_level )
      end

     	Attack.val_store( 0, "lifes", Attack.val_restore( 0,"lifes" ) - 1 );
     	return true
    else
    	 Attack.cell_remove_last_corpse( 0 )
    end 
  end 
end

function special_change_place()

  local cycle = Attack.get_cycle()
  local target
  local sname=""

  if Attack.is_computer_move() then
    if cycle ~= 0 then Game.MessageBox('Этого не может быть потому что этого не может быть') end
      Attack.val_store("change_place", Attack.get_target())
  --[[        local targets = {}
      calccells_change_place( function (i) table.insert(targets,i) end )
      if table.getn(targets) == 0 then return true end
    target = targets[ Game.Random(1,table.getn(targets)) ] ]]
    target = Attack.cell_id(tonumber(Attack.val_restore("target")))
    cycle = 1
  end

  if (cycle == 0) then
    Attack.val_store("change_place", Attack.get_target())
   Attack.next(0)
  elseif (cycle == 1) then
    local source = Attack.val_restore("change_place")

    if target == nil then
      target = Attack.get_target()
    end

    if ((source ~= nil) and (target ~= nil)) then
      local tx,ty = Attack.act_get_center(target)
      local sx,sy = Attack.act_get_center(source)

          Attack.act_aseq(source, "telein")
          Attack.act_aseq(target, "telein")
          Attack.atom_spawn(source, 0, "hll_telein" )
          Attack.atom_spawn(target, 0, "hll_telein" )

          local t = Attack.aseq_time(source)

          Attack.act_aseq(source, "teleout" )
          Attack.act_aseq(target, "teleout" )
          Attack.atom_spawn(source, t, "hll_teleout" )
          Attack.atom_spawn(target, t, "hll_teleout" )

          Attack.act_teleport(source, target, t)
      --Attack.act_teleport(target, source, 0)

         Attack.log("change_place","name",blog_side_unit(0),"target",blog_side_unit(source,-1),"targeta",blog_side_unit(target,-1))
      end
    end
--      if Attack.act_size(target)>1 then
--        sname="<label=cpsn_"..Attack.act_name(target)..">"
--      else
--        sname="<label=cpn_"..Attack.act_name(target)..">"
--
--      Attack.log_special(sname) -- работает

--  end

      --Attack.log_label("add_blog_change_") -- работает
      Attack.act_aseq( 0, "castmagic" )

  return true

end

-- ***********************************************
-- * Summon Thorn
-- ***********************************************

function special_cast_thorn()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  local dmgts = Attack.aseq_time( 0 )

  if string.find( Attack.act_name( 0 ), "thorn" ) then
    Attack.act_aseq( 0, "special" )
  else
    Attack.act_aseq( 0, "cast" )
  end

  dmgts = dmgts + Attack.aseq_time( 0, "x") * 2
  --находим ближайшего врага
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0
  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )
      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto(target, nearest_enemy) end

  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ), 100 )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
  local summoner_count = Attack.act_size( 0 )
  local summoner_name = Attack.act_name( 0 )
  local summoner_lead = Attack.atom_getpar( summoner_name, "leadership" )
  local type_thorn = Game.Random( 99 )
  local count_summon = 0
  local unit_summon = ""

  if type_thorn < 50 then
    unit_summon = "thorn"
  else
    unit_summon = "thorn_warrior"
  end

  local chance = Game.Random( 99 )
  local chance_kingthorn = math.min( apply_difficulty_level_talent_bonus( 20 ), math.floor( summoner_lead * summoner_count / Attack.atom_getpar( "kingthorn", "leadership" ) ) )

  if chance < chance_kingthorn then
    unit_summon = "kingthorn"
  end

  local summon_lead = Attack.atom_getpar( unit_summon, "leadership" )
  count_summon = math.ceil( summoner_lead * summoner_count / summon_lead * k / 100 )
  Attack.act_spawn( target, 0, unit_summon, ang_to_enemy, count_summon )
  Attack.act_nodraw( target, true )
  local t = Attack.aseq_time( 0 ) - .3
  Attack.act_animate( target, "grow", t )
  Attack.act_nodraw( target, false, t )
  fix_hitback( target )
  Attack.log_label( "add_blog_summon_" ) -- работает
  Attack.log_special( count_summon ) -- работает

  if Attack.act_name( 0 ) == "thorn"
  or Attack.act_name( 0 ) == "thorn_warrior" then
    local t = 2.
    if Attack.cell_remove_last_corpse( Attack.get_target(), t + .01 ) then
      Attack.act_fadeout( Attack.cell_get_corpse( Attack.get_target() ), 0, t )
      Attack.act_enable_attack( 0, "cast_sacrifice" )
    end
  end
  --Attack.act_aseq(target, "grow")

  --Attack.act_aseq( 0, "cast" )

  return true
end


-- ***********************************************
-- * New! Thorn Gift of Life
-- ***********************************************
function special_cast_thorn_sacrifice()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  Attack.atom_spawn( target, 0, "hll_priest_resur_cast" )
  Attack.act_aseq( 0, "x" )
  Attack.atom_spawn( 0, 0, "magic_dagger", Attack.angleto( 0 ) )
  Attack.act_aseq( 0, "x" )
  local heal = round( get_add_gain_bonus( common_apply_skill_bonus( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_cast_sacrifice" ) )
  local giver_size = Attack.act_size( 0 )
  local giver_totalhp = Attack.act_totalhp( 0 )
  local giver_heal = round( giver_totalhp * heal / 100 )
  local receiver_totalhp = Attack.act_totalhp( target )
  local receiver_initsize = Attack.act_initsize( target )
  local receiver_health = Attack.act_get_par( target, "health" )
  local receiver_inithp = receiver_initsize * receiver_health
  local receiver_newhp = receiver_totalhp + giver_heal
  local excess_hp = receiver_newhp - receiver_inithp
  local receiver_size = Attack.act_size( target )
  local over_count = 0
  
  if excess_hp > 0 then
    over_count = math.ceil( excess_hp / receiver_health )
    Attack.act_initsize( target, receiver_initsize + over_count )
  else
    over_count = math.floor( excess_hp / receiver_health )
  end

  local new_count = receiver_initsize + over_count
  local add_count = new_count - receiver_size
  Attack.cell_resurrect( target, giver_heal )
	 takeoff_spells( target, "penalty" )
  Attack.act_charge( target )

  local M
  if giver_size > 1 then
    M = '2'
  else
    M = '1'
  end

  local N
  if receiver_size > 1 then
    N = '2'
  else
    N = '1'
  end

  Attack.act_kill( 0, false, false )
  Attack.act_remove( 0, 4 )
  Attack.log_label( "null" )

  if add_count > 0 then
    Attack.log( "thorn_gift_res_" .. M .. N, "name", blog_side_unit( 0, 1, nil, giver_size ), "saname", blog_side_unit( 0, 3 ) .. "<label=special_thorn3_name></color>", "targets", blog_side_unit( target, 1, nil, receiver_size ), "special", giver_heal, "special2", add_count, "name", blog_side_unit( 0, -1 ) )
  else
    Attack.log( "thorn_gift_cure_" .. M .. N, "name", blog_side_unit( 0, 1, nil, giver_size ), "saname", blog_side_unit( 0, 3 ) .. "<label=special_thorn3_name></color>", "targets", blog_side_unit( target, 1, nil, receiver_size ), "special", giver_heal, "name", blog_side_unit( 0, -1, nil, giver_size ) )
  end

  effect_temp_ooc( target )

  return true
end


-- ***********************************************
-- * Preparation
-- ***********************************************

function special_preparation_attack()
  local duration = Logic.obj_par( "special_preparation", "duration" )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_special_preparation", true )
  local speed = Logic.obj_par( "special_preparation", "power" )
  Attack.act_del_spell( 0, "special_preparation" )
  Attack.act_apply_spell_begin( 0, "special_preparation", duration, false )
  Attack.act_apply_spell_end()
  Attack.act_aseq( 0, "special" )

  return true
end

-- ***********************************************
-- * Suicide
-- ***********************************************

function special_suicide()
  Attack.act_aseq( 0, "death" )
  dmgts = Attack.aseq_time( 0, "x" )
  Attack.atom_spawn( 0, dmgts, "catapultfireball" )
  local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )

  local acnt = Attack.act_count()
  for i = 1, acnt - 1 do
    if ( Attack.act_enemy( i ) or Attack.act_ally( i ) )
    and Attack.cell_dist( 0, i ) == 1 then      -- contains enemy and level
      if Attack.act_applicable(i) then      -- can receive this attack
        local rnd = Game.Random( 99 )
        common_cell_apply_damage( i, dmgts )
        local burn_res = Attack.act_get_res( i, "fire" )
        local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
        if rnd < burn_chance
        and not string.find( Attack.act_name( i ), "cyclop" ) then
          effect_burn_attack( i, dmgts, 3 )
        end
      end
    end
  end
  Attack.act_kill( 0, true )

  return true
end

-- ***********************************************
-- * Summon Bear
-- ***********************************************

function special_cast_bear()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )

  --находим ближайшего врага
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0
  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )
      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto( target, nearest_enemy ) end

  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ) )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
  local summoner_count = Attack.act_size( 0 )
  local summoner_name = Attack.act_name( 0 )
  local summoner_lead = Attack.atom_getpar( summoner_name, "leadership" )
  local type_bear = Game.Random( 99 )
  local count_summon = 0
  local unit_summon = ""

  if type_bear < 50 then
    unit_summon = "bear2"
  else
    unit_summon = "bear"
  end

  local chance = Game.Random( 99 )
  local chance_bear_white = math.min( apply_difficulty_level_talent_bonus( 20 ), math.floor( summoner_lead * summoner_count / Attack.atom_getpar( "bear_white", "leadership" ) ) )

  if chance < chance_bear_white then
    unit_summon = "bear_white"
  end

  local summon_lead = Attack.atom_getpar( unit_summon, "leadership" )
  count_summon = math.ceil( summoner_lead * summoner_count / summon_lead * k / 100 )
  Attack.act_spawn( target, 0, unit_summon, ang_to_enemy, count_summon )
  Attack.act_nodraw( target, true )
  local t = Attack.aseq_time( 0 ) - dmgts
  Attack.act_animate( target, "castbear", dmgts )
  Attack.act_nodraw( target, false, dmgts )
  fix_hitback( target )
  Attack.log_label( "add_blog_summon_" ) -- работает
  Attack.log_special( count_summon ) -- работает

  return true
end

-- ***********************************************
-- * Faery
-- ***********************************************

function special_heal()
  local target = Attack.get_target()
  local count = Attack.act_size( 0 )
  local heal = round( get_add_gain_bonus( common_apply_skill_bonus( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_cure" ) ) * count
  Attack.act_aseq( 0, "cure" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local a = Attack.atom_spawn( target, dmgts, "hll_priest_heal_post" )
  local dmgts1 = Attack.aseq_time( a, "x" )
  local max_hp = Attack.act_get_par( target, "health" )
  local cur_hp = Attack.act_hp( target )

  if heal > max_hp - cur_hp then heal = max_hp - cur_hp end

  Attack.act_cure( target, heal, dmgts )
  Attack.log_label( "cure_" ) -- работает
  Attack.log_special( heal )

  return true
end


function special_heal2()
  local target = Attack.get_target()
  Attack.act_del_spell( target, "effect_poison" )
		Attack.act_del_spell( target, "spell_weakness" )
		Attack.act_del_spell( target, "spell_infection" )
		Attack.act_del_spell( target, "effect_weakness" )
		Attack.act_del_spell( target, "special_plague" )
		Attack.act_del_spell( target, "spell_plague" )
		Attack.act_del_spell( target, "special_disease" )
		Attack.act_del_spell( target, "effect_infection" )
  local heal = get_add_gain_bonus( common_apply_skill_bonus( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_cure" )
  local dmg_type = Attack.get_custom_param( "typedmg" )
		Attack.log_label( "null" )
  local min_dmg, max_dmg = heal, heal
  Attack.atk_set_damage( dmg_type, min_dmg, max_dmg )

  if ( Attack.act_race( target, "undead" ) ) then
    common_cell_attack( target, "hll_priest_heal_post" )
    Attack.log_label( "" )
  elseif ( Attack.act_need_cure( target ) ) then
    local count = Attack.act_size( 0 )
    local cure_hp = round( Game.Random( min_dmg, max_dmg + 0.45 ) * count )
    local max_hp = Attack.act_get_par( target, "health" )
    local cur_hp = Attack.act_hp( target )

    if cure_hp > max_hp - cur_hp then
      cure_hp = max_hp - cur_hp
--      Attack.act_charge( 0, 1, "cure2" )
    end

    local a = Attack.atom_spawn( target, 0, "hll_priest_heal_post" )
    local dmgts = Attack.aseq_time( a, "x" )
    Attack.act_cure( target, cure_hp, dmgts )
    Attack.log_label( "cure_" ) -- работает
    Attack.log_special( cure_hp )

  end

  return true
end


function special_presurrect()
  local target = Attack.get_target()
  local count = Attack.act_size( 0 )
  local count_1 = Attack.act_size( target )
  local hp_1 = Attack.act_hp( target )

  local heal = round( get_add_gain_bonus( common_apply_skill_bonus( apply_difficulty_level_talent_bonus( Attack.get_custom_param( "heal" ) ), "healer" ), "heal_respawn" ) ) * count
  Attack.act_aseq( 0, "cure" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local a = Attack.atom_spawn( target, dmgts, "hll_priest_resur_cast" )
  local dmgts1 = Attack.aseq_time( a, "x" )
  Attack.cell_resurrect( target, heal, dmgts + dmgts1 )
  Attack.log_label( "respawn_" ) -- работает
  local count_2 = Attack.act_size( target )
  local hp_2 = Attack.act_hp( target )

  if count_1 < count_2 then
    Attack.act_damage_addlog( target, "res_" )
    Attack.log_special( count_2 - count_1 )
  elseif count_1 > count_2
  or ( hp_1 == 0
  and count_1 == count_2 ) then
    Attack.act_damage_addlog( target, "res_" )
    Attack.log_special( count_2 )
  elseif hp_1 < hp_2
  and hp_1 ~= 0 then --
    Attack.act_damage_addlog( target, "cur_" )
    Attack.log_special( hp_2 - hp_1 )
  end

  return true
end


function special_phoenix_sacrifice()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  Attack.atom_spawn( target, 0, "hll_priest_resur_cast" )
  Attack.act_aseq( 0, "x" )
  Attack.atom_spawn( 0, 0, "magic_dagger", Attack.angleto( 0 ) )
  Attack.act_aseq( 0, "x" )
  local heal = Attack.act_hp( 0 )
  local count_before

  if Attack.get_caa( target ) == nil then
    count_before = 0
  else
    count_before = Attack.act_size( target )
  end

  Attack.cell_resurrect( target, heal )
  local count_after = Attack.act_size( target )
	 takeoff_spells( target, "penalty" )
  Attack.act_charge( target )
  Attack.act_reload( target )

  local N
  if count_before > 1 then
    N = '2'
  else
    N = '1'
  end

  Attack.act_kill( 0, false, false )
  phoenix_ondamage( 0, 0, true )
  Attack.log_label( "null" )

  if count_after > count_before then
    Attack.log( "phoenix_sacrifice_res_" .. N, "name", blog_side_unit( 0, 1, nil, 1 ), "saname", blog_side_unit( 0, 3 ) .. "<label=special_phoenix_sacrifice_name></color>", "targets", blog_side_unit( target, 1, nil, count_before ), "special", heal, "special2", count_after - count_before, "name", blog_side_unit( 0, -1 ) )
  else
    Attack.log( "phoenix_sacrifice_cure_" .. N, "name", blog_side_unit( 0, 1, nil, 1 ), "saname", blog_side_unit( 0, 3 ) .. "<label=special_phoenix_sacrifice_name></color>", "targets", blog_side_unit( target, 1, nil, count_before ), "special", heal, "name", blog_side_unit( 0, -1, nil, 1 ) )
  end

  return true
end


-- ***********************************************
-- * Dispell
-- ***********************************************

function special_dispell()
  local target = Attack.get_target()
  Attack.act_aseq( 0, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )
  takeoff_spells( target, "penalty" )
  takeoff_spells( target, "bonus" )
--  Attack.act_del_spell( target )
  Attack.atom_spawn( target, dmgts, "magic_dispel" )
  return true
end

-- ***********************************************
-- * Battle Mage
-- ***********************************************

function special_battle_mage_attack()
  local duration = Logic.obj_par( "special_battle_mage", "duration" )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_battle_mage", true )
  local power = round( get_add_gain_bonus( tonumber( Logic.obj_par( "special_battle_mage", "power" ) ), "power_battle_mage" ) )
  local penalty = round( get_add_gain_bonus( tonumber( Logic.obj_par( "special_battle_mage", "penalty" ) ), "penalty_battle_mage", false ) )
  local shock = round( get_add_gain_bonus( Logic.obj_par( "special_battle_mage", "shock" ), "shock_battle_mage" ) )
  local bon_krit = round( get_add_gain_bonus( Logic.obj_par( "special_battle_mage", "krit" ), "krit_battle_mage" ) )
  local krit = Attack.act_get_par( 0, "krit" )
  Attack.act_apply_spell_begin( 0, "special_battle_mage", duration, false )
  Attack.act_apply_dmgmin_spell( "magic", 0, power, 0, duration, false )
  Attack.act_apply_dmgmax_spell( "magic", 0, power, 0, duration, false )
  Attack.act_apply_par_spell( "defense", 0, -penalty, 0, duration, false )
  Attack.act_apply_par_spell( "krit", (bon_krit-krit), 0, 0, duration, false )
  Attack.act_apply_par_spell( "disspec", 10, 0, 0, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_spell_param( 0, "special_battle_mage", "shock", shock )
  Attack.act_aseq( 0, "special" )
  return true
end

-- ***********************************************
-- * Telekines
-- ***********************************************

function special_telekines()
  local cycle = Attack.get_cycle()
  local target

  if (cycle == 0) then
    Attack.val_store("telekines", Attack.get_target())
    if Attack.is_computer_move() then
        local targets = {}
        calccells_telekines( function (i) table.insert(targets,i) end )
        if table.getn(targets) == 0 then return true end
    target = targets[ Game.Random(1,table.getn(targets)) ]
    cycle = 1
    else
      Attack.next(0)
  end
  end

  if (cycle == 1) then
    local source = Attack.val_restore("telekines")
    if target == nil then target = Attack.get_target() end

    Attack.aseq_rotate(0,source)
    Attack.act_aseq(0,"cast")
    local dmgts = Attack.aseq_time(0, "x")

    local angle = Attack.angleto(target,source)
    Attack.atom_spawn(target, dmgts, "effect_telekines",angle)
    if ((source ~= nil) and (target ~= nil)) then
      Attack.act_move( 1, 3, source, target )
      --common_cell_apply_damage(t2, (movtime0+movtime1)/2)
    end
  end

  return true

end

-- ***********************************************
-- * Прицеливание
-- ***********************************************
function special_aiming_attack()
  local duration = tonumber( Logic.obj_par( "special_aiming", "duration" ) )
  duration = apply_hero_duration_bonus( nil, duration, "sp_duration_special_aiming", true )
  local power = tonumber( Logic.obj_par( "special_aiming", "power" ) )
  Attack.act_apply_spell_begin( 0, "special_aiming", duration, false )
  Attack.act_apply_par_spell( "attack", 0, power, 0, duration, false )
  Attack.act_apply_dmg_spell( "physical", 0, power, 0, duration, false )
  Attack.act_apply_spell_end()
  Attack.act_aseq( 0, "rare" )
--    end
  return true
end

-- ***********************************************
-- * Эльфийская песня
-- ***********************************************
function special_elf_song_attack()
  local duration = tonumber( Logic.obj_par( "special_elf_song", "duration" ) )
  local power = tonumber( Logic.obj_par( "special_elf_song", "power" ) )
  Attack.act_aseq( 0, "song" )
  local dmgts = Attack.aseq_time( 0, "x" )                   -- x time of attacker

  acnt = Attack.act_count()
  for i = 1, acnt - 1 do
    if ( Attack.act_ally( i ) )
    and ( Attack.act_race( i ) == "elf"
    or Attack.act_feature( i, "plant" ) ) then        -- contains ally
      duration = apply_hero_duration_bonus( i, duration, "sp_duration_special_elf_song", true )
      local a = Attack.atom_spawn( i, dmgts, "effect_elvensong" )
      Attack.act_del_spell( i, "special_elf_song" )
      Attack.act_apply_spell_begin( i, "special_elf_song", duration, false )
      Attack.act_apply_par_spell( "initiative", power, 0, 0, duration, false )
      Attack.act_apply_spell_end()
     end
  end

  return true
end

-- ***********************************************
-- * Усыпление фейское
-- ***********************************************

function check_cast_sleep(i, level, nfeatures)

    return Attack.act_enemy(i) and Attack.act_level(i)<=level and not Attack.act_feature(i, nfeatures)

end

function special_cast_sleep()
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )
  local level = tonumber( Attack.get_custom_param( "level" ) )
  local nfeatures = Attack.get_custom_param( "nfeatures" )
  Attack.act_aseq( 0, "sleep" )
  local dmgts = Attack.aseq_time(0, "x")                   -- x time of attacker

  local acnt = Attack.act_count()
  for i = 1, acnt - 1 do
    if check_cast_sleep( i, level, nfeatures ) then
      effect_sleep_attack( i, dmgts, duration )
      if Attack.act_size( i ) > 1 then
        Attack.log( 0.001, "add_blog_sleep_2", "targets", "   "..blog_side_unit( i, 0 ) )
      else
        Attack.log( 0.001, "add_blog_sleep_1", "target", "   "..blog_side_unit( i, 0 ) )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Giant Quake
-- ***********************************************

function special_giant_quake()
  Attack.act_aseq( 0, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local dmg_min,dmg_max = text_range_dec( Attack.get_custom_param( "damage" ) )
  local k = tonumber( Attack.get_custom_param( "k" ) )
  local typedmg = Attack.get_custom_param( "typedmg" )
  local acnt = Attack.act_count()
  Attack.val_store( 0, "ignore_effect_blind", 1 )

  for i = 1, acnt - 1 do
    if Attack.act_enemy( i )
    and Attack.act_mt( i ) == 0
    and Attack.act_applicable( i )
    and Attack.act_name( i ) ~= "archdemon"
    and Attack.act_name( i ) ~= "demoness" then
      local dist = Attack.cell_dist( 0, i ) - 1

      if Attack.act_feature( i, "barrier" ) then
        Attack.atk_set_damage( typedmg, 2 * dmg_min * ( 1 - k * dist / 100 ), 2 * dmg_max * ( 1 - k * dist / 100 ) )
      else
        Attack.atk_set_damage( typedmg, dmg_min * ( 1 - k * dist / 100 ), dmg_max * ( 1 - k * dist / 100 ) )
      end

      common_cell_apply_damage( i, dmgts )
    end

    if Attack.act_enemy( i )
    and Attack.act_mt( i ) == 2
    and Attack.act_applicable( i ) then
      Attack.act_aseq( i, "takeoff" )
      Attack.act_aseq( i, "descent" )
    end

    if Attack.act_enemy( i )
    and Attack.act_name( i ) == "demoness"
    and Attack.act_applicable( i ) then
      Attack.act_aseq( i, "avoid" )
    end

    if Attack.act_enemy( i )
    and Attack.act_name( i ) == "archdemon"
    and Attack.act_applicable( i ) then
      Attack.act_aseq( i, "special" )
    end
  end

  Attack.val_store( 0, "ignore_effect_blind", nil )
  --      if target == nil then

  return true
end

-- ***********************************************
-- * Poison Cloud
-- ***********************************************

function special_poison_cloud()
  Attack.act_aseq( 0, "special" )
  dmgts = Attack.aseq_time( 0, "x" )
  --Attack.atom_spawn(0, dmgts, "hll_shaman_post")
  local poison = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "poison" ) )
  poison = effect_chance( poison, "effect", "poison" )

  local acnt = Attack.act_count()
  for i = 1, acnt - 1 do
    if ( Attack.act_enemy( i ) or Attack.act_ally( i ) )
    and Attack.cell_dist( 0, i ) == 1 then      -- contains enemy and level
      if Attack.act_applicable( i ) then      -- can receive this attack
        local rnd = Game.Random( 99 )
        common_cell_apply_damage( i, dmgts )
        local dmg = tonum( Attack.val_restore( 0, "last_dmg" ) )
        local poison_res = Attack.act_get_res( i, "poison" )
        local poison_chance = math.min( 100, poison * ( 1 - poison_res / 100 ) )
        local poison_damage = dmg * poison_chance / 200
        if rnd < poison_chance
        and not Attack.act_feature( i, "golem" ) then
          effect_poison_attack( i, dmgts, 3, poison_damage, poison_damage )
        end
      end
    end
  end

  return true
end


function spell_spawn_atom()

  Attack.atom_spawn(atom_spawn_target, 0, atom_spawn_name)
  return true

end

-- ***********************************************
-- * Дрессировка
-- ***********************************************

function special_beast_training()
  local level = tonumber( Attack.get_custom_param( "level" ) )
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )
  local target = Attack.get_target()
  Attack.aseq_rotate( 0,target )
  Attack.act_aseq( 0, "cast" )
  dmgts = Attack.aseq_time( 0, "x" )
  effect_charm_attack( target, dmgts , duration, "effect_beast_training" )

  return true
end

-- ***********************************************
-- * Summon Undead
-- ***********************************************

function special_animate_dead()
  local target = Attack.get_target()
  local cell = Attack.cell_get_corpse( target )

  if cell == nil then
    cell = target
  end

  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ) ) --коэф.
  k = k * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 )
  local necro_count = Attack.act_size( 0 )  -- сколько магов
  local necro_name = Attack.act_name( 0 )
  --лидерство магов и трупов
  local necro_lead = Attack.atom_getpar( necro_name, "leadership" )

  if ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 )
  and ( Attack.act_feature( target, "undead" )
  or Attack.act_feature( cell, "undead" ) )
  and ( Attack.cell_has_ally_corpse( cell )
  or Attack.act_ally( target ) )
  and not Attack.act_temporary( cell ) then
    local percent = Game.Random( skill_power_range_dec( "necromancy", 1 ) )
    heal = necro_count * necro_lead * k / 100 * percent / 100

    Attack.act_aseq( 0, "cure" )
    local dmgts = Attack.aseq_time( 0, "x" )
    local a = Attack.atom_spawn( target, dmgts, "hll_priest_resur_cast" )
    local dmgts1 = Attack.aseq_time( a, "x" )
    Attack.cell_resurrect( target, heal, dmgts + dmgts1 )
    Attack.log_label( "respawn_" ) -- работает
    local count_2 = Attack.act_size( target )
    local hp_2 = Attack.act_hp( target )
  
    if count_1 < count_2 then
      Attack.act_damage_addlog( target, "res_" )
      Attack.log_special( count_2 - count_1 )
    elseif count_1 > count_2
    or ( hp_1 == 0
    and count_1 == count_2 ) then
      Attack.act_damage_addlog( target, "res_" )
      Attack.log_special( count_2 )
    elseif hp_1 < hp_2
    and hp_1 ~= 0 then
      Attack.act_damage_addlog( target, "cur_" )
      Attack.log_special( hp_2 - hp_1 )
    end

    return true
  else
    Attack.aseq_rotate( 0, cell )
    Attack.act_aseq( 0, "cast" )
    local dmgts = Attack.aseq_time( 0, "x" )
    local name = actor_name( cell )
    local bel = 0
  
    local animate_count_base = Attack.act_initsize( cell )  --сколько юнитов в трупе
    local unit_animate = necro_get_unit( name, animate_count_base, necro_lead * necro_count * k / 100 )
    local undead_lead = Attack.atom_getpar( unit_animate, "leadership" )
    -- сколько можно поднять по лидерству
    local animate_count_lead = math.floor( necro_lead * necro_count / undead_lead * k / 100 )
    -- реально
    local animate_real = math.min( animate_count_lead, animate_count_base )
  
    if animate_real < 1 then
      unit_animate = "skeleton"
      undead_lead = Attack.atom_getpar( unit_animate, "leadership" )
      animate_count_lead = math.floor( necro_lead * necro_count / undead_lead * k / 100 )
      animate_real = math.min( animate_count_lead, animate_count_base )
    end
  
    animate_dead( target, cell, Attack.aseq_time( 0, "x" ), bel, unit_animate, animate_real )
  
    if animate_real > 1 then
      Attack.log( "add_blog_necro_2", "name", blog_side_unit( 0, 1 ), "target", blog_side_unit( cell, 0 ), "targeta", blog_side_unit( Attack.get_target(), 0 ), "special", animate_real )
    else
      Attack.log( "add_blog_necro_1", "name", blog_side_unit( 0, 1 ), "target", blog_side_unit( cell, 0 ), "targeta", blog_side_unit( Attack.get_target(), 0 ), "special", animate_real )
    end
  
    if mana_rage_gain_k > 0 then
      Attack.act_charge( 0, 1, "animate_dead" )
    end

    return true
  end
end


--special_demoness_charm
-- ***********************************************
-- * Соблазнение
-- ***********************************************

function special_demoness_charm()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  Attack.act_aseq( 0, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local k = apply_difficulty_level_talent_bonus( text_range_dec( Attack.get_custom_param( "k" ) ) )  --коэф.
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )  --коэф.
  local demon_count = Attack.act_size( 0 )  -- сколько магов
  local demon_name = Attack.act_name( 0 )
  --лидерство магов и цели
  local demon_lead = Attack.atom_getpar( demon_name, "leadership" )
  local target_lead = Attack.act_leadership( target )
  local target_count = Attack.act_size( target )

  -- сколько можно соблазнить по лидерству
  if demon_lead * demon_count * k / 100 > target_lead * target_count
  and Attack.act_level( target ) < 5
  and effect_charm_attack( target, dmgts, duration ) then
    Attack.log_label( "charm_" )
  else
    if Attack.cell_dist( 0, target ) == 1 then
      Attack.act_aseq( 0, "attack" )
    else
      Attack.act_aseq( 0, "longattack" )
    end

    local dmgts1 = Attack.aseq_time( 0, "x" )

    --local dmg_min,dmg_max = text_range_dec(Attack.get_custom_param("damage"))
    --local typedmg=Attack.get_custom_param("typedmg")
    --Attack.atk_set_damage(typedmg,dmg_min,dmg_max)
    common_cell_apply_damage( target, dmgts1 )
    Attack.log_label( "" )
  end

  return true
end

-- ***********************************************
-- * Summon Demon
-- ***********************************************

function special_summon_demon()
  local target = Attack.get_target()
  Attack.aseq_rotate(0,target)
  Attack.act_aseq( 0, "cast" )
  dmgts = Attack.aseq_time(0, "x")
  --находим ближайшего врага
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0
  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )

      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  local mas = { "imp", "imp2", "cerberus", "demoness", "demon" }
  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ) ) --коэф.
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto( target, nearest_enemy ) end

  local demon_count = Attack.act_size( 0 )  -- сколько магов
  local summon_unit = mas[ Game.Random( 1, 5 ) ]
  local demon_name = Attack.act_name( 0 )
  --лидерство магов и ltvjyjd
  local demon_lead = Attack.atom_getpar( demon_name, "leadership" )
  local summon_lead = Attack.atom_getpar( summon_unit, "leadership" )
  -- сколько можно призвать по лидерству
  local summon_count = math.ceil( demon_lead * demon_count / summon_lead * k / 100 )
  -- реально
  local a = Attack.atom_spawn( target, dmgts, "effect_demonsummon", Attack.angleto( target ) )
  local dmgts1 = Attack.aseq_time( a, "x" )
--    local far=0
  Attack.act_spawn( target, 0, summon_unit, ang_to_enemy, summon_count )
  Attack.act_nodraw( target, true )
--    Attack.act_animate(target, "descent", t)
  Attack.act_nodraw( target, false, dmgts + dmgts1 )
  fix_hitback( target )
  Attack.log_label( "add_blog_summon_" ) -- работает
  Attack.log_special( summon_count ) -- работает
  --Attack.act_aseq(target, "respawn")

  return true
end


-- ******************************************************* --
-- * Дистанционный удар (у демонессы, разбойника и змей) * --
-- ******************************************************* --

function special_long_hit()

  local target = Attack.get_target()
  Attack.aseq_rotate(0, target)
  Attack.act_aseq(0, "longattack")

  common_cell_apply_damage(target, Attack.aseq_time(0, "x"))
  return true

end

-- ******************************************************* --
-- * Закопаться * --
-- ******************************************************* --

function special_rooted()
  --Attack.aseq_rotate(0, target)
  Attack.act_aseq( 0, "rare" )
  local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )  --коэф.
  local resist = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "resist" ) )  --коэф.
  local bhealth = Attack.act_get_par( 0, "health" )
  local hpbonus = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "HP" ) )
  local hbonus = bhealth * hpbonus / 100
  takeoff_spells( 0, "penalty" )

	 if Attack.act_need_cure( 0 ) then
	   local cur_hp = Attack.act_hp( 0 )
				Attack.atom_spawn( 0, 0, "effect_total_cure" )
				Attack.act_cure( 0, bhealth - cur_hp, 0 )
  end 

  Attack.act_apply_spell_begin( 0, "special_rooted", duration, false )
  Attack.act_apply_par_spell( "dismove", 1, 0, 0, duration, false )
  Attack.act_apply_par_spell( "health", hbonus, 0, 0, duration, false )
  Attack.act_apply_res_spell( "fire", resist, 0, 0, duration, false)
  Attack.act_apply_res_spell( "physical", resist, 0, 0, duration, false)
  Attack.act_apply_res_spell( "magic", resist, 0, 0, duration, false)
  Attack.act_apply_res_spell( "poison", resist, 0, 0, duration, false)
  Attack.act_apply_spell_end()
  Attack.atom_spawn( 0, 0, "magic_slow" )
  Attack.act_enable_attack( 0, "rooted", false )

  return true
end

-- ***********************************************
-- * Summon Plant (based off of cast demon)
-- ***********************************************

function special_summonplant()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target )
  Attack.act_aseq( 0, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )

      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  local plant_name = Attack.act_name( 0 )
  local summon_unit = ""
  local plant_count = Attack.act_size( 0 )

  if plant_name == "ent" then
    if plant_count == 1 then
      local mas = { "thorn", "thorn_warrior" }
      summon_unit = mas[ Game.Random( 1, 2 ) ]
    else
      local mas = { "thorn", "thorn_warrior", "kingthorn", "ent" }
      summon_unit = mas[ Game.Random( 1, 4 ) ]
    end

  elseif plant_name == "ent2" then
    if plant_count == 1 then
      local mas = { "kingthorn", "ent" }
      summon_unit = mas[ Game.Random( 1, 2 ) ]
    else
      local mas = { "kingthorn", "ent", "ent2" }
      summon_unit = mas[ Game.Random( 1, 3 ) ]
    end

  else
    local mas = { "thorn", "thorn_warrior", "kingthorn", "ent", "ent2" }
    summon_unit = mas[ Game.Random( 1, 5 ) ]
  end

  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ) )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto( target, nearest_enemy ) end

  local plant_lead = Attack.atom_getpar( plant_name, "leadership" )
  local summon_lead = Attack.atom_getpar( summon_unit, "leadership" )
  local summon_count = math.max( 1, math.floor( plant_lead * plant_count / summon_lead * k / 100 ) )
  Attack.act_spawn( target, 0, summon_unit, ang_to_enemy, summon_count )
  Attack.act_nodraw( target, true )
  local t = Attack.aseq_time( 0 ) - dmgts

  if string.find( summon_unit, "thorn" ) then
    Attack.act_animate( target, "grow", t )
  else
    local a = Attack.aseq_time( target )
    Attack.act_aseq( target, "teleout" )
    Attack.atom_spawn( target, a, "hll_teleout", Attack.angleto( target ) )
	   t = t + a
  end

  Attack.act_nodraw( target, false, t )
  fix_hitback( target )
  Attack.log_label( "add_blog_summon_" )
  Attack.log_special( summon_count )

  return true
end

-- *********************************************************** --
-- * Summon Dragonfly (based off of cast demon & summon plant) --
-- *********************************************************** --

function special_summondragonfly()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0,target )
  Attack.act_aseq( 0, "summon" )
  dmgts = Attack.aseq_time( 0, "x" )
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )

      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  local mas = { "dragonfly_fire", "dragonfly_lake" }
  local k = apply_difficulty_level_talent_bonus( Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) ) ) --коэф.
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto( target, nearest_enemy ) end

  local dragonfly_count = Attack.act_size( 0 )
  local summon_unit = mas[ Game.Random( 1, 2 ) ]
  local dragonfly_lead = Attack.atom_getpar( Attack.act_name( 0 ), "leadership" )
  local summon_lead = Attack.atom_getpar( summon_unit, "leadership" )
  local summon_count = math.ceil( dragonfly_lead * dragonfly_count / summon_lead * k / 100 )
  Attack.act_spawn( target, 0, summon_unit, ang_to_enemy, summon_count )
  Attack.act_nodraw( target, true )
  local t = Attack.aseq_time( 0 ) - dmgts
  local a = Attack.aseq_time( target )
  Attack.act_aseq( target, "teleout" )
  Attack.atom_spawn( target, a, "hll_teleout", Attack.angleto( target ) )
	 t = t + a
  Attack.act_nodraw( target, false, t )
  fix_hitback( target )
  Attack.log_label( "add_blog_summon_" )
  Attack.log_special( summon_count )

  return true
end

-- ***********************************************
-- * Archdemon Sheep
-- ***********************************************

function special_amalgamation()
  local target = Attack.get_target()
  local tmp_spells = {}
  
  if not Attack.act_is_spell( target, "spell_blind" )
  and not Attack.act_feature( target, "eyeless" ) then
    table.insert( tmp_spells, spell_blind_attack )
  end
  
  if not Attack.act_is_spell( target, "spell_pygmy" ) then
    table.insert( tmp_spells, spell_pygmy_attack )
  end
  
  if not Attack.act_is_spell( target, "spell_ram" )
  and not Attack.act_feature( target, "plant" )
  and not Attack.act_feature( target, "golem" )
  and not Attack.act_feature( target, "undead" ) then
    table.insert( tmp_spells, spell_ram_attack )
  end

  if table.getn( tmp_spells ) > 0 then
    Attack.act_aseq( 0, "cast" )
    local dmgts = Attack.aseq_time( 0, "x" )
    local cast = Game.Random( 1, table.getn( tmp_spells ) )
    local spell_level = 3
    tmp_spells[ cast ]( spell_level, dmgts, target, true )
    Attack.log( dmgts + 0.2, "add_blog_amal_attack", "name", blog_side_unit( 0, 1 ), "target", blog_side_unit( target, 0 ) )
  end

  return true
end

-- ******************************************************* --
-- * Выкопаться * --
-- ******************************************************* --

function special_digout()
  --Attack.aseq_rotate(0, target)
  Attack.act_del_spell(0,"special_rooted")
  local cur_hp = Attack.act_hp( 0 )
  local name = Attack.act_name( 0 )
  local base_hp = Attack.atom_getpar( name, "hitpoint" )
  local change_hp = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "HP" ) )

  if cur_hp > base_hp then Attack.act_hp( 0, cur_hp - base_hp ) end

  Attack.act_charge( 0, 1 )

  return true
end


-- ******************************************************* --
-- * Жадность
-- ******************************************************* --

function special_greediness()

  local target = Attack.get_target()

      Attack.act_aseq(0, "telein")
      Attack.atom_spawn(0, 0, "hll_telein" )

      local t = Attack.aseq_time(0)

      Attack.act_aseq(0, "teleout" )
      Attack.atom_spawn(target, t, "hll_teleout" )

    local box
    for d=0,5 do
      box = Attack.cell_adjacent(target, d)
      if Attack.cell_is_box( box ) then break end --нашли ящЕг
    end

      Attack.act_teleport(0, target, t, Attack.angleto(target,box))
      Attack.act_ap(0, 1);

  return true

end

-- ******************************************************* --
-- * Мародерство* --
-- ******************************************************* --

function special_looter()

  local target = Attack.cell_get_corpse(0)
  --Attack.aseq_rotate(0, target)

  if target~=nil then
    Attack.act_aseq(0,"special")
    local dmgts = Attack.aseq_time(0, "x")                   -- x time of attacker


    Attack.loot_it(dmgts)
    Attack.act_fadeout(target,0,dmgts)
    Attack.cell_remove_last_corpse(target,dmgts+.01)

    return true
  else

--      Game.InvokeMsgBox("warning","<label=warning_loot>")
    return false
  end

end

-- ******************************************************* --
-- * Вопль привидения * --
-- ******************************************************* --

function check_ghost_cry(i, dist)

  return not Attack.act_equal(0,i) and (Attack.cell_dist(0,i)<=dist) and Attack.act_level(i)<4

end

function special_ghost_cry()
  --local target=Attack.get_target()
  --Attack.atom_spawn(0, 0, "hll_post_archmage_lighting")
  local dmg_min, dmg_max = text_range_dec( Attack.get_custom_param( "damage" ) )
  dmg_min = dmg_min * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 )
  dmg_max = dmg_max * ( 1 + tonumber( skill_power2( "necromancy", 4 ) ) / 100 )
  local typedmg = Attack.get_custom_param( "typedmg" )
  local dist = tonumber( Attack.get_custom_param( "dist" ) )
  Attack.act_aseq( 0, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )                   -- x time of attacker
  local busy_cells = {}

  for i = 1, Attack.act_count() - 1 do
    if check_ghost_cry( i, dist )
    and ( Attack.act_enemy( i )
    or Attack.act_ally( i ) )
    and Attack.act_applicable( i ) then      -- берем цель
      -- ищем для цели максимально удаленную от привидения клетку
      local max_dist = Attack.cell_dist( 0, i ) -- задаем расстояние минимум
      local cell = nil

      for j = 0, 5 do -- перебираем все направления для цели
        local trg = Attack.cell_adjacent( i, j )
        local dist = Attack.cell_dist( 0, trg ) -- определяем расстояние до привидения из клетки в этом направлении

        if dist > max_dist
        and Attack.cell_present( trg )
        and Attack.cell_is_empty( trg )
        and Attack.cell_is_pass( trg )
        and not busy_cells[ Attack.cell_id( trg ) ] then -- если оно дальше предыдущего найденного, при этом клетка есть, свободна и проходима, то имеем ее в виду
          --Attack.atom_spawn(trg, 4, "magic_slow")
          max_dist = dist
          cell = trg
          busy_cells[ Attack.cell_id( trg ) ] = true
        end
      end

      local time1, time2 = 1, 2
      -- если была найдена удаленная свободная, то юнит сдвигаем:
      if cell ~= nil
      and Attack.act_get_par( i, "dismove" ) == 0 then
        Attack.act_move( 1, 2, i, cell )
        time1, time2 = 2, 3
      end

      local d = Attack.cell_dist( 0, i )

      if not Attack.act_feature( i, "mind_immunitet,undead" )
      and Attack.act_enemy( i ) then
        Attack.atk_set_damage( typedmg, dmg_min / d, dmg_max / d ) --*Attack.act_size(0
        common_cell_apply_damage( i, time1 --[[+ time2]] )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Green Dragon Rail
-- ***********************************************

function special_dragon_rail()
  --  local count=Attack.act_size(0)      -- количество драконов
  --local dmg_min,dmg_max = text_range_dec(Attack.get_custom_param("damage"))
  --local typedmg=Attack.get_custom_param("typedmg")
  --Attack.atk_set_damage(typedmg,dmg_min,dmg_max)
  local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )
  burn = effect_chance( burn, "effect", "burn" )
  local target = Attack.get_target()
  local angle = Attack.angleto( 0, target )
  local dir = Game.Ang2Dir( angle )
  target = Attack.cell_adjacent( 0, dir )
  Attack.aseq_rotate( 0, target )
  Attack.act_aseq( 0, "cast" )
  local cell_count = Attack.trace ( target, dir )
  local c1 = Attack.cell_adjacent( 0,dir )
  local c2 = Attack.cell_adjacent( c1,dir )
  local c3 = Attack.cell_adjacent( c2,dir )
  local c4 = Attack.cell_adjacent( c3,dir )
  local d = math.floor( cell_count * 0.7 )

  if d > 3 then
    Attack.atom_spawn( c4, Attack.aseq_time( 0, "z" ), string.format( "flame%02ihx", d ), angle )
  end

  local dmgts, dt = Attack.aseq_time( 0, "x" ), Attack.aseq_time( "reddragon", "cast", "y" )
  for i = 0, cell_count - 1 do
    local cell_found = Attack.trace(i)
    if Attack.cell_present( cell_found ) then
      if --[[(Attack.act_enemy(cell_found) or Attack.act_ally(cell_found))]]Attack.get_caa( cell_found ) ~= nil and Attack.act_applicable( cell_found ) then
        local burn_rnd = Game.Random( 99 )
        common_cell_apply_damage( cell_found, dmgts )
        local burn_res = Attack.act_get_res( cell_found, "fire" )
        local dmg = tonum( Attack.val_restore( 0, "last_dmg" ) )
        local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
        local burn_damage = dmg * burn_chance / 200
        if burn_rnd < burn_chance
        and not string.find( Attack.act_name( cell_found ), "cyclop" )
        and dmg > 0 then
          effect_burn_attack( cell_found, dmgts, 3, burn_damage, burn_damage )
        end
      end
    end
    dmgts = dmgts + dt
  end

  return true
end

function special_reddragon_rail_highlight()

    local target = Attack.get_target()
    local dir = Game.Ang2Dir(Attack.angleto(0,target))
    target = Attack.cell_adjacent(0, dir)

    local cell_count=Attack.trace(target, dir)
    for i=0,cell_count-1 do
        local cell_found=Attack.trace(i)
        if Attack.cell_present(cell_found) then
            if (Attack.act_enemy(cell_found) or Attack.act_ally(cell_found)) and Attack.act_applicable(cell_found) then
                Attack.cell_select(cell_found, "avenemy")
            else
                Attack.cell_select(cell_found, "destination")
            end
        end
    end

    return true

end

function special_reddragon_rail_calccells()

    for dir=0,5 do
        local c = Attack.cell_adjacent(0, dir)
        local cell_count=Attack.trace(c, dir)
        for i=0,cell_count-1 do
            local cell_found=Attack.trace(i)
            if Attack.cell_present(cell_found) then
                Attack.marktarget(cell_found)
            end
        end
    end

    return true

end


-- ******************************************************* --
-- * Источник маны
-- ******************************************************* --

function calccells_gain_mana()
    for j=0,5 do
        local t=Attack.cell_adjacent(0,j)
        if t~=nil and Attack.cell_present(t) and Attack.act_enemy(t) and Attack.act_applicable(t) then
	        Attack.multiselect(0)
	        break
		end
    end
    return true
end


-- New! Blue Dragon's Zap ability
function calccells_zap()
  for j = 0, 5 do
    local t = Attack.cell_adjacent( 0, j )

    if t ~= nil
    and Attack.cell_present( t )
    and Attack.act_applicable( t ) then
	     Attack.multiselect( 0 )
 	    break
    end
  end

  return true
end

function cur_hero_item_count( name, val )
	 local func

 	if Attack.act_belligerent() == 1 then
    func = Logic.hero_lu_item
    func1 = Logic.enemy_lu_item
 	else
    func = Logic.enemy_lu_item
    func1 = Logic.hero_lu_item
  end

  if val == nil then return func( name, "count" ), func1( name, "count" )
  else return func( name, "count", val ) end

end

-- New!!! This function performs the mana burn
function cur_enemy_hero_item_count( name, val )
	 local func

 	if Attack.act_belligerent() ~= 1 then func = Logic.hero_lu_item
 	else func = Logic.enemy_lu_item end

  if val == nil then return func( name, "count" )
  else return func( name, "count", val ) end

end

function special_gain_mana()
  Attack.act_aseq( 0, "mana" )
  local count = Attack.act_size( 0 )      -- количество драконов
  local mana_k = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "mana_k" ) )
  local mana, damages = 0, 0

  for j = 0, 5 do
    local t = Attack.cell_adjacent( 0, j )

    if t ~= nil
    and Attack.cell_present( t )
    and Attack.act_enemy( t )
    and Attack.act_applicable( t ) then
      common_cell_apply_damage( t, Attack.aseq_time( 0, "x" ) )
	     local damage = Attack.act_damage_results( t )
	     mana = mana + math.min( Attack.act_totalhp( t ), damage )
	     damages = damages + 1
	   end
	 end

  if mana_rage_gain_k == nil then
    mana_rage_gain_k = 1
  end

 	mana = math.ceil( mana / mana_k * mana_rage_gain_k )

  if mana > 0 then
    Attack.log_label( "" )
    local curmana, enemycurmana = cur_hero_item_count( "mana" )
    
    if curmana ~= nil then
      cur_hero_item_count( "mana", curmana + mana )

  	   if damages > 1 then
  	    	Attack.log_label( "add_blog_mana_" ) -- работает
      else
  	    	Attack.log_label( "add_blog_mana1_" ) -- работает
  		  end
    -- Mana burn target
    elseif enemycurmana ~= nil then
      cur_enemy_hero_item_count( "mana", enemycurmana - mana )

  	   if damages > 1 then
  	    	Attack.log_label( "add_blog_manaburn_" ) -- работает
      else
  	    	Attack.log_label( "add_blog_manaburn1_" ) -- работает
  		  end
    end

    Attack.log_special( mana ) -- работает
	 end

  return true
end


-- New Blue Dragon's Zap ability
function special_zap()
  Attack.act_aseq( 0, "spare" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local shock = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "shock" ) )
  shock = effect_chance( shock, "effect", "shock" )

  local acnt = Attack.act_count()

  for i = 1, acnt - 1 do
    if ( Attack.act_enemy( i )
    or Attack.act_ally( i ) )
    and Attack.cell_dist( 0, i ) == 1 then      -- contains enemy and level
      if Attack.act_applicable( i ) then        -- can receive this attack
        local rnd = Game.Random( 99 )
        common_cell_apply_damage( i, dmgts )

        if Attack.act_is_spell( i, "effect_freeze" ) then
          shock = shock * 2
        end
  
        local shock_res = Attack.act_get_res( i, "astral" )
        local shock_chance = math.min( 100, shock * ( 1 - shock_res / 100 ) )

        if rnd < shock_chance
        and not Attack.act_feature( i, "golem" ) then
          local duration = apply_difficulty_level_talent_bonus( Logic.obj_par( "effect_shock", "duration" ) )
          effect_shock_attack( i, dmgts, duration )
        end
      end
    end
  end

  return true
end


-- ******************************************************* --
-- * Кровожадность
-- ******************************************************* --

function special_blood()

  local target = Attack.get_target()

  Attack.aseq_rotate(0,target)
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time(0, "x")

  if target~=nil  then
    local a = Attack.atom_spawn(target,dmgts,"blood_rune",0)
    Attack.act_aseq(a, "appear" )
    Attack.aseq_timeshift(a,dmgts)
  end
  return true
end

-- ***********************************************
-- * Stun
-- ***********************************************

function special_cyclop_push()

  local target = Attack.get_target()

  -- разворачиваем лицом

  Attack.aseq_rotate( 0,target)

  -- толкаем
  Attack.act_aseq( 0, "push" )
  local dmgts = Attack.aseq_time(0, "x") --+ Attack.aseq_time(0,"","x")atomtag, animation, key

  local dir=Game.Ang2Dir(Attack.angleto(0,target))
  local cell=Attack.cell_adjacent(target,dir)

  if Attack.cell_present(cell) and Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) and Attack.act_get_par(target, "dismove") == 0 then
    Attack.act_move(dmgts, dmgts+1, target, cell)
  end

  common_cell_apply_damage(target,dmgts)

  return true
end

-- ***********************************************
-- * Захват цели
-- ***********************************************

function special_capture_target()

  local target = Attack.get_target()

  -- разворачиваем лицом

  --Attack.aseq_rotate(target,0)
  Attack.aseq_rotate(0,target)

  local dmgtsR = Attack.aseq_time(0)

  -- толкаем
  Attack.act_aseq( 0, "special" )
  local dmgts1 = Attack.aseq_time(0, "x") --+ Attack.aseq_time(0,"","x")atomtag, animation, key
  local dmgts2 = Attack.aseq_time(0, "y") --+ Attack.aseq_time(0,"","x")atomtag, animation, key
  local dmgtsD = Attack.aseq_time(0, "z") --+ Attack.aseq_time(0,"","x")atomtag, animation, key

  local dir=Game.Ang2Dir(Attack.angleto(target,0))
  local cell=Attack.cell_adjacent(target,dir)
  --local pp=0

  --if Attack.cell_present(cell) and Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then
    Attack.act_move(dmgts1,dmgts2,target,cell)
  --  pp=dmgts+0.4
  --end

  common_cell_apply_damage(target,dmgtsD)

  return true
end

-- ***********************************************
-- * plague
-- ***********************************************
function special_plague()
  local level = tonumber( Attack.get_custom_param( "level" ) )
  local var = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "plague" ) )
  --calccells_all_enemy_around()
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )

  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if Attack.act_applicable( i )
    and ( Attack.act_enemy( i )
    or Attack.act_ally( i ) ) then                  -- can receive this attack
      local rnd = Game.Random( 99 )

      if rnd < var
      and not Attack.act_feature( i, "golem" ) then
        spell_plague_attack( i, level, dmgts )
      end
    end
  end

  return true
end

-- ***********************************************
-- * Griffin split
-- ***********************************************
function special_griffin_split()
  local target = Attack.get_target()
  local halfSize = Attack.act_size( 0 ) / 2.
  Attack.act_size( 0, math.ceil( halfSize ) )
  local newTroopSize = math.floor( halfSize )
  Attack.act_initsize( 0, Attack.act_initsize( 0 ) - newTroopSize )
  Attack.aseq_rotate( 0, target )
  Attack.act_aseq( 0, "special" )
  Attack.act_spawn( target, 0, "griffin", Attack.angleto( 0, target ), newTroopSize, Attack.act_slot( 0 ) )
  -- запрещаем деление этого и клонированного отряда
  Attack.val_store( 0, "clone", 1 )
  Attack.act_enable_attack( 0, "split", false )
  Attack.val_store( target, "clone", 1 )
  Attack.act_enable_attack( target, "split", false )
  Attack.act_nodraw( target, true )
  local t = Attack.aseq_time( 0 ) - .3
  Attack.act_animate( target, "descent", t )
  Attack.act_nodraw( target, false, t )
  fix_hitback( target )
  Attack.log_label( "add_blog_split_" )
  Attack.resort( target ) -- даем походить новому отряду в этом раунде

  return true
end

function griffin_check_split()
  if Attack.val_restore( 0, "clone" ) ~= 1 then -- это не клон
    if Attack.act_size( 0 ) > 1
    and Attack.act_belligerent( 0 ) == Attack.act_belligerent( 0, nil ) then
      Attack.act_enable_attack( 0, "split", true )
    else
      Attack.act_enable_attack( 0, "split", false )
    end
  end

  return true
end

-- ***********************************************
-- * Ent Reload
-- ***********************************************
function special_reload()
  local count = tonumber( Attack.get_custom_param( "count" ) )
  Attack.act_aseq( 0, "special" )
  Attack.act_charge( 0, count, "throw1" )

  return true
end

-- ***********************************************
-- * Gibe
-- ***********************************************
function special_gibe()

  local target = Attack.get_target()
  Attack.aseq_rotate(0, target)
  Attack.act_aseq(0, "special")
  local dmgts = Attack.aseq_time(0, "x")                   -- x time of attacker

  Attack.val_store(target,"gibe_target",Attack.cell_id(Attack.get_cell(0)))
  Attack.act_attach_modificator(target,"initiative","temp_i",100,0,0,1,true,100)
  Attack.act_attach_modificator(target,"autofight","temp_a",1,0,0,1,true,100)
    Attack.atom_spawn(target, dmgts, "effect_bullhead",0,true)
      Attack.log_label("add_blog_gibe_") -- работает
  Attack.act_again(target, true)
  Attack.resort()
  return true

end

-- ***********************************************
-- * Fire Power
-- ***********************************************
function special_blackdragon_firepower()
  local path = Attack.calc_path( 0, Attack.get_target() )
  local burn = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "burn" ) )
  burn = effect_chance( burn, "effect", "burn" )

  if path == nil then return false end

  Attack.act_no_cell_update( 0 )
  Attack.aseq_rotate( 0, path[2].cell )
  Attack.aseq_start( 0, "fire_takeoff", "fire_flight" )
  local i, dir = 2, path[1].dir

  while i < table.getn( path ) do
    local ndir = path[i].dir
    if ndir == dir then
      if i + 2 < table.getn( path ) and path[i+1].dir == dir and path[i+2].dir == dir then
        Attack.aseq_waft( 0, "fire_flight", "fire_waft" )
        common_cell_apply_damage( path[i].cell, Attack.aseq_time( 0, "v" ) )
        common_cell_apply_damage( path[i+1].cell, Attack.aseq_time( 0, "w" ) )
        i = i + 2
      else
        Attack.aseq_move( 0, "fire_flight" )
      end
    else
      if wrap( ndir - dir, -3, 3 ) == 1 then
        Attack.aseq_move( 0, "fire_flight", "fire_rdivert", 1 )
      else
        Attack.aseq_move( 0, "fire_flight", "fire_ldivert", -1 )
      end

      dir = ndir
    end

    common_cell_apply_damage( path[i].cell, Attack.aseq_time( 0, "x" ) )
    local burn_rnd = Game.Random( 99 )
    local burn_res = Attack.act_get_res( path[i].cell, "fire" )
    local dmg = tonum( Attack.val_restore( 0, "last_dmg" ) )
    local burn_chance = math.min( 100, burn * ( 1 - burn_res / 100 ) )
    local burn_damage = dmg * burn_chance / 200
    if burn_rnd < burn_chance
    and not string.find( Attack.act_name( path[i].cell ), "cyclop" )
    and dmg > 0 then
      effect_burn_attack( path[i].cell, Attack.aseq_time( 0, "x" ), 3, burn_damage, burn_damage )
    end
    i = i + 1
  end

  Attack.act_aseq( 0, "fire_descent", false, true )
  Attack.atk_min_time( Attack.aseq_time(0) + .5 )

  return true
end

--[[function special_blackdragon_firepower_highlight(target)

  local path = Attack.calc_path(0, target)
  if path ~= nil then
    for i=2,table.getn(path)-1 do
      local c = path[i].cell
      if (Attack.act_enemy(c) or Attack.act_ally(c)) and Attack.act_takesdmg(c) then
        Attack.cell_select(c, "avenemy")
      else
        Attack.cell_select(c, "path")
      end
    end
    Attack.cell_select(path[table.getn(path)].cell, "destination")
  end
  return true

end]]


function special_spell()
-- итого умеем:
-- атакующие: +огненная стрела, +молния, +масляный туман, +магический топор, +ядовитый череп, +призрачный меч
-- баффы: +замедление, +злой рок, +слабость, +беззащитность,
-- под вопросом: +гипноз, +испуг, +карлик, +овца, +ослепление
-- не из книги: +сон, 
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )
  local target = Attack.get_target()
  local num=string.gsub( Attack.act_name( 0 ), "evilbook", "" )
  local level = tonumber( num )
  local spells1 = { spell_magic_axe_attack, spell_fire_arrow_attack,  spell_smile_skull_attack }
  local spells2 = { spell_lightning_attack, spell_oil_fog_attack, spell_magic_axe_attack, spell_smile_skull_attack, spell_ghost_sword_attack }
  local spells3 = { spell_lightning_attack, spell_lightning_attack, spell_magic_axe_attack, spell_ghost_sword_attack, spell_smile_skull_attack, }
  local tmp_spells = {}

  -- исключаем неатакующие заклинания из списка для боссов и паунов
  if not Attack.act_feature( target, "pawn" )
  and not Attack.act_feature( target, "boss" ) then
    if not Attack.act_feature( target, "plant" )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "undead" ) then
      if level > 1 then table.insert( tmp_spells, spell_weakness_attack ) end
      --if level>1 then table.insert(tmp_spells, effect_curse_attack) end
    end

    if not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" )  then
      if level < 3 then table.insert( tmp_spells, spell_slow_attack ) end
      --if level>1 then table.insert(tmp_spells, effect_curse_attack) end
    end

    if Attack.act_level( target ) > 2
    and Attack.act_get_par( target, "defense" ) > 5 then
      table.insert( tmp_spells, spell_defenseless_attack )
    end

    if Attack.act_level( target ) <= ( level + 1 ) then
      if level > 2 then table.insert( tmp_spells, spell_ram_attack ) end

      if level > 1 then table.insert( tmp_spells, spell_pygmy_attack ) end

      if level > 1 then table.insert( tmp_spells, spell_crue_fate_attack ) end

      if not Attack.act_feature( target, "mind_immunitet" )
      and not Attack.act_feature( target, "undead" ) then
        if level > 2 then table.insert( tmp_spells, spell_hypnosis_attack ) end

        if level > 1 and level <= Attack.act_level( 0 ) then table.insert( tmp_spells, spell_scare_attack ) end

        if level > 2 then table.insert( tmp_spells, effect_sleep_attack ) end
      end

      if not Attack.act_feature( target, "eyeless" ) then
        if level > 2 then table.insert( tmp_spells, spell_blind_attack ) end
      end
    end
  end

  if level == 1 then
    for i = 1, table.getn( spells1 ) do
      table.insert( tmp_spells, spells1[i] )
    end
  end

  if level == 2 then
    for i = 1, table.getn( spells2 ) do
      table.insert( tmp_spells, spells2[i] )
    end
  end

  if level == 3 then
    for i = 1, table.getn( spells3 ) do
      table.insert( tmp_spells, spells3[i] )
    end
  end

  local cast = Game.Random( 1, table.getn( tmp_spells ) )

  if tmp_spells[ cast ] ~= effect_curse_attack
  and tmp_spells[ cast ] ~= effect_sleep_attack then
    tmp_spells[ cast ]( level, dmgts )
  else
    tmp_spells[ cast ]( target, dmgts, level )
  end

  local charges = tonum( Attack.val_restore( 0, "charges" ) )

  if charges == 1 then
    Attack.act_enable_attack( 0, "gulp" )
  end

  if charges > 0 then 
    Attack.val_store( 0, "charges", charges - 1 )
  end

  Attack.log_label( '' )

  return true

end

-- ***********************************************
-- * Dominator
-- ***********************************************
function special_dominator()

  local cycle = Attack.get_cycle()

  if cycle == 0 and not Attack.is_computer_move() then
    Attack.val_store("dominator_control", Attack.get_target())
    Attack.next(0)
    return true
  end

  local source
  if Attack.is_computer_move() then
    source = Attack.get_target()
  else
    source = Attack.val_restore("dominator_control")
    local target = Attack.get_target()
    Attack.val_store(source,"gibe_target",Attack.cell_id(Attack.get_cell(target)))
  end

    Attack.aseq_rotate(0, source)
    Attack.act_aseq(0, "special")
    local dmgts = Attack.aseq_time(0, "x")                   -- x time of attacker
    Attack.act_del_spell(source,"effect_charm")
    Attack.act_del_spell(source,"effect_sleep")

    if Attack.act_enemy(source) then
        effect_charm_attack(source,dmgts,1,"magic_hypnosis")
    else
        Attack.atom_spawn(source, dmgts, "magic_hypnosis",Attack.angleto(source))
    end

    --Attack.act_again(source)
    Attack.act_attach_modificator(source,"initiative","temp_i",100,0,0,1,true,100)
    Attack.act_attach_modificator(source,"autofight","temp_a",1,0,0,1,true,100)
    Attack.act_again(source, true)
    Attack.resort()
		Attack.log_label("null")
    --      Attack.log_label("add_blog_gibe_") -- работает

  return true
end

function special_gulp()
  local target = Attack.get_target()
  Attack.aseq_rotate( 0, target, "special" )
  local dmgts = Attack.aseq_time( 0, "x" )                   -- x time of attacke
  Attack.act_nodraw( target, true, dmgts ); -- скрываем юнит, когда книга его проглотила
  --Attack.act_kill(target)
  local level = tonumber( Attack.act_level( 0 ) )
  Attack.act_charge( 0, level, "attack_spell" )
  Attack.val_store( 0, "charges", level )
  Attack.act_enable_attack( 0, "gulp", false )
  Attack.act_remove( target, dmgts )

  return true
end

-- ***********************************************
-- * Run
-- ***********************************************
function special_run()
  Attack.act_ap( 0, Attack.act_ap( 0 ) + apply_difficulty_level_talent_bonus( Attack.get_custom_param( "ap" ) ) )
  Attack.atom_spawn( 0, 0, "effect_run", 0 )

  return true
end
