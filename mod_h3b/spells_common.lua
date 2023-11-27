function dmg_round(dmg)
	local tmp=math.mod(dmg,10)
	if math.mod(dmg,100)<7 then return dmg-math.mod(dmg,100) end 
	if tmp == 5 or tmp == 10 then return dmg end 
	if tmp<3 then return dmg-tmp end 
	if tmp>7 then return dmg+(10-tmp) end
	if tmp>5 and tmp<8 then return dmg-(tmp-5) end
	if tmp>2 then return dmg+(5-tmp) end
	
	return dmg
end 

function empty_cell(c)

    return c~=nil and Attack.cell_present(c) and Attack.cell_is_pass(c) and Attack.cell_is_empty(c)

end

function calccells_all_enemy_actors_takes_damage()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i) or Attack.act_pawn(i)) and not Attack.act_ally(i) and Attack.act_takesdmg(i) then    -- enemy and takes damage
      if Attack.act_applicable(i) then                  -- can receive this attack
        Attack.marktarget(i)                    -- select it
      end
    end

  end
  return true

end


function calccells_pain_mirror()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i) and Attack.act_takesdmg(i)) then    -- enemy and takes damage
      if Attack.act_applicable(i) then -- can receive this attack
      	local dmg = Attack.val_restore(i, "last_dmg")
      	if dmg~=nil then
      	if tonumber(dmg) > 0 then 
        	Attack.marktarget(i)                    -- select it
        end 
        end 
      end
    end

  end
  return true

end


function calccells_all_actors_takes_damage()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if Attack.act_takesdmg(i) then          -- takes damage
      if Attack.act_applicable(i) then          -- and can receive this attack
        Attack.marktarget(i)                -- select it
      end
    end

  end
  return true

end


function calccells_all_need_resurrect_ally()
	 local level=Obj.spell_level()
 	-- если заклинание читаем из свитка (уровень = 0) то кастуем с силой 1

 	if level == 0 or level == nil then level = 1 end

 	local spell = Obj.name()
  local ccnt = Attack.cell_count()
  local lvl = tonumber( text_dec( Logic.obj_par( spell, "level" ), level ) )
  
  for i = 0, ccnt - 1 do
    local cell = Attack.cell_get( i )

    if ( Attack.cell_is_empty( cell ) ) then        -- is empty (has no live object)
      if ( Attack.cell_has_ally_corpse( cell ) ) then   -- contains ally corpse
        if ( Attack.cell_need_resurrect( cell ) )
        and ( Attack.act_level( Attack.cell_get_corpse( cell ) ) <= lvl ) then  -- needs resurrection
          if Attack.act_applicable( Attack.cell_get_corpse( cell ) ) then      -- can receive this attack
            Attack.marktarget( cell )           -- select it
          end
        end
      end
    elseif ( Attack.act_ally( cell ) ) then         -- contains ally
      if ( Attack.cell_need_resurrect( cell ) )
      and ( Attack.act_level( cell ) <= lvl ) then    -- ally needs resurrect
        if Attack.act_applicable( cell ) then     -- can receive this attack
          Attack.marktarget( cell )           -- select it
        end
      end
    end

  end

  return true
end

function calccells_all_need_resurrect_ally_simple()

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do

    local cell = Attack.cell_get(i)

    if (Attack.cell_is_empty(cell)) then        -- is empty (has no live object)
      if (Attack.cell_has_ally_corpse(cell)) then   -- contains ally corpse
        if (Attack.cell_need_resurrect(cell)) then  -- needs resurrection
           if Attack.act_applicable(Attack.cell_get_corpse(cell)) then      -- can receive this attack
              Attack.marktarget(cell)           -- select it
           end
        end
      end
    elseif (Attack.act_ally(cell)) then         -- contains ally
      if (Attack.cell_need_resurrect(cell)) then    -- ally needs resurrect
        if Attack.act_applicable(cell) then     -- can receive this attack
          Attack.marktarget(cell)           -- select it
        end
      end
    end

  end
  return true

end

-- New for Phoenix Sacrifice
function calccells_all_phoenix_sacrifice()
  local lvl = tonumber( Attack.get_custom_param( "level" ) )
  local ccnt = Attack.cell_count()

  for i = 0, ccnt - 1 do
    local cell = Attack.cell_get( i )

    if ( Attack.cell_is_empty( cell ) ) then        -- is empty (has no live object)
      if not Attack.act_equal( 0, Attack.cell_get_corpse( cell ) ) then
        if ( Attack.cell_has_ally_corpse( cell ) ) then   -- contains ally corpse
          if ( Attack.cell_need_resurrect( cell ) )       -- needs resurrection
          and ( Attack.act_level( Attack.cell_get_corpse( cell ) ) <= lvl ) then
            if Attack.act_applicable( Attack.cell_get_corpse( cell ) ) then      -- can receive this attack
              Attack.marktarget( cell )           -- select it
            end
          end
        end
      end
    elseif ( Attack.act_ally( cell ) ) then         -- contains ally
      if not Attack.act_equal( 0, cell ) then
        if ( Attack.cell_need_resurrect( cell ) )     -- ally needs resurrect
        and ( Attack.act_level( cell ) <= lvl ) then
          if Attack.act_applicable( cell ) then     -- can receive this attack
            Attack.marktarget( cell )           -- select it
          end
        end
      end
    end
  end

  return true
end


function calccells_all_need_cure_all()
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

		  if Attack.get_caa( 0 ) ~= nil then -- not magic
	     if ( Attack.act_ally( i )
      and Attack.act_need_cure( i ) ) then
  	     if Attack.act_applicable( i ) then  -- can receive this attack
          Attack.marktarget( i )            -- select it
    	   end
      end
    else
	     if ( Attack.act_ally( i )
      and Attack.act_need_cure( i ) )
      or ( ( Attack.act_enemy( i )
      or Attack.act_ally( i ) )
      and ( Attack.act_race( i, "undead" ) ) ) then
  	     if Attack.act_applicable( i ) then  -- can receive this attack
          Attack.marktarget( i )            -- select it
    	   end
      end
    end 
  end

  return true
end


function calccells_all_need_cure2_all()
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

		  if Attack.get_caa( 0 ) ~= nil then -- not magic
	     if ( Attack.act_ally( i )
      and Attack.act_need_cure( i ) )
      or ( ( Attack.act_enemy( i )
      or Attack.act_ally( i ) )
      and ( Attack.act_race( i, "undead" ) ) ) then
  	     if Attack.act_applicable( i ) then  -- can receive this attack
          Attack.marktarget( i )            -- select it
    	   end
      end
    end 
  end

  return true
end


function calccells_bless()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_ally(i) and not Attack.act_race(i,"undead")) or (Attack.act_enemy(i) and (Attack.act_race(i,"undead"))) then
      if Attack.act_applicable(i) then  -- can receive this attack
                Attack.marktarget(i)            -- select it
      end
        end
  end
  return true

end


function calccells_all_ally()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_ally(i)) then        -- contains ally
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end


--[[function calccells_mass_enemy()
  local n = 7
  Attack.multiselect(n)             -- turn on multiselect mode

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do             -- for all cells
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty(cell) then      -- cell is empty
      if Attack.cell_is_pass(cell) then   -- not unpassable
        Attack.marktarget(cell, false)      -- select it
      end
    elseif Attack.act_enemy(cell) then                      -- cell contains enemy
      if (Attack.act_takesdmg(cell) and Attack.act_applicable(cell)) then   -- takes damage and can receive this attack
        Attack.marktarget(cell, false)                      -- select it
      end
    end
  end

  return true
end]]


function calccells_mass_all()
  local n = 7
  Attack.multiselect(n)             -- turn on multiselect mode

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do             -- for all cells
    local cell = Attack.cell_get(i)
    if Attack.cell_is_pass(cell) then
        Attack.marktarget(cell, false)      -- select it
    end
    --elseif Attack.act_enemy(cell) or Attack.act_ally(cell) then
    --  if (Attack.act_takesdmg(cell) and Attack.act_applicable(cell)) then   -- takes damage and can receive this attack
    --    Attack.marktarget(cell, false)                      -- select it
    --  end
    --end
  end

  return true
end

function calccells_mass_all_19()
  local n = 19
  Attack.multiselect(n)             -- turn on multiselect mode

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do             -- for all cells
    local cell = Attack.cell_get(i)
    --if Attack.cell_is_empty(cell) then      -- cell is empty
      if Attack.cell_is_pass(cell) then   -- not unpassable
        Attack.marktarget(cell, false)      -- select it
      end
    --[[elseif Attack.act_enemy(cell) then
      if (Attack.act_takesdmg(cell) and Attack.act_applicable(cell)) then   -- takes damage and can receive this attack
        Attack.marktarget(cell, false)                      -- select it
      end
    end]]
  end

  return true
end

--[[function calccells_mass_enemy_19()
  local n = 19
  Attack.multiselect(n)             -- turn on multiselect mode

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do             -- for all cells
    local cell = Attack.cell_get(i)
    if Attack.cell_is_empty(cell) then      -- cell is empty
      if Attack.cell_is_pass(cell) then   -- not unpassable
        Attack.marktarget(cell, false)      -- select it
      end
    elseif Attack.act_enemy(cell) and Attack.act_ally(cell) then
      if (Attack.act_takesdmg(cell) and Attack.act_applicable(cell)) then   -- takes damage and can receive this attack
        Attack.marktarget(cell, false)                      -- select it
      end
    end
  end

  return true
end ]]

function calccells_teleport()

  local cycle = Attack.get_cycle()
  local spell = Obj.name()
  local level=Obj.spell_level()
  if level==0 then level=1 end

  if not Attack.is_computer_move() then 
		Game.InfoHint("bmsg_teleport_"..(cycle+1))
  end 
	
  if (cycle == 0) then -- кого телепортаем
     local all = tonumber(Logic.obj_par(spell,"all"))
      local acnt = Attack.act_count()
    for i=1,acnt-1 do                           -- for all actors
      if level<all and Attack.act_ally(i) then      -- только своих
--      if (Attack.act_enemy(i) or Attack.act_ally(i)) then       -- actor is enemy or ally
        if Attack.act_applicable(i) then                -- can receive this attack
          Attack.marktarget(i)                      -- select it
        end
      end
      if level>(all-1) and (Attack.act_ally(i) or Attack.act_enemy(i)) then     -- всех
--      if (Attack.act_enemy(i) or Attack.act_ally(i)) then       -- actor is enemy or ally
        if Attack.act_applicable(i) then                -- can receive this attack
          Attack.marktarget(i)                      -- select it
        end
      end
    end

  elseif (cycle == 1) then -- в куда телепортаем
        local dist = tonumber(text_dec(Logic.obj_par(spell,"dist"),level))

    local ccnt = Attack.cell_count()
    local source = Attack.val_restore("teleport_source")
    for i=0,ccnt-1 do               -- for all cells
      local cell = Attack.cell_get(i)       -- get cell
      local p_dist= Attack.cell_dist(source,cell)
      if Attack.cell_is_empty(cell) and p_dist<(dist+1) and Attack.cell_is_pass(cell) then --and Attack.cell_dist(source,i)<(dist+1) then    -- cell is empty
        Attack.marktarget(cell)         -- select it
      end
    end

  end

  return true
end

function common_cell_apply_kill(cell, dmgts)

  if (cell ~= nil) then                 -- not nil
    if (not Attack.cell_is_empty(cell)) then        -- not empty
        if (Attack.act_applicable(cell)) then       -- can receive this attack

          Attack.act_kill( cell )
          local hit_x = Attack.aseq_time( cell, "x" )
          Attack.aseq_timeshift( cell, dmgts - hit_x )
          Attack.dmg_timeshift( cell, dmgts )

          return true

        end
    end
  end

  return false

end

function common_cell_apply_damage( cell, dmgts, ignore_posthitmaster )
  if ( cell ~= nil ) then                 -- not nil
    if ( not Attack.cell_is_empty( cell ) ) then        -- not empty
      if ( Attack.act_takesdmg( cell ) )--[[ and Attack.cell_is_pass(cell)]] then       -- takes damage
        if ( Attack.act_applicable( cell ) ) then       -- can receive this attack
		        if ignore_posthitmaster ~= 0 then -- 0 означает, что act_damage вызывать не нужно
	           if ignore_posthitmaster == nil then ignore_posthitmaster = false end

	           Attack.act_damage( cell, ignore_posthitmaster )
		        end

          local hit_x = Attack.aseq_time( cell, "x" )
          Attack.aseq_timeshift( cell, dmgts - hit_x )
          Attack.dmg_timeshift( cell, dmgts )

          return true
        end
      end
    end
  end

  return false
end


function common_cell_attack(cell, atom_name)

  local dmgts = Attack.aseq_time(atom_name, "x")

  if (common_cell_apply_damage(cell, dmgts)) then   -- if damage applyed
    Attack.atom_spawn(cell, 0, atom_name )      -- summon atom
    return true                     -- success
  end

  return false                      -- failure

end


function calccells_all_enemy()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i)) then       -- contains enemy
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end

function calccells_all_enemy_no_magic_immunitet()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i)) and not Attack.act_feature(i, "magic_immunitet") then       -- contains enemy
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end


function calccells_all_one()
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if ( Attack.act_ally( i ) )
    or ( Attack.act_enemy( i ) ) then       -- contains ally and enemy
      if Attack.act_applicable( i ) then      -- can receive this attack
        Attack.marktarget( i )            -- select it
      end
    end
  end

  return true
end


function calccells_all_one_dispell()
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if ( Attack.act_ally( i )
    or Attack.act_enemy( i ) )
    and Attack.act_spell_count( i ) > 0 then       -- contains ally and enemy
      if Attack.act_spell_count( i ) == 1 then
		      local spell_name = Attack.act_spell_name( i, 0 )
        if not string.find( spell_name, "special_difficulty" ) then
          if Attack.act_applicable( i ) then      -- can receive this attack
            Attack.marktarget( i )            -- select it
          end
        end
      else
        if Attack.act_applicable( i ) then      -- can receive this attack
          Attack.marktarget( i )            -- select it
        end
      end
    end
  end

  return true
end


function calccells_sacrifice_old()

  local cycle = Attack.get_cycle()
  if not Attack.is_computer_move() then 
		Game.InfoHint("bmsg_sacrifice_"..(cycle+1))
  end 

  if (cycle == 0) then

    local acnt = Attack.act_count()
    for i=1,acnt-1 do                           -- for all actors
      if Attack.act_ally(i) then        -- actor is enemy or ally
        if Attack.act_applicable(i) then                -- can receive this attack
          Attack.marktarget(i)
        end
      end
    end

  elseif (cycle == 1) then

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do

    local cell = Attack.cell_get(i)

    if (Attack.cell_is_empty(cell)) then        -- is empty (has no live object)
      if (Attack.cell_has_ally_corpse(cell)) then   -- contains ally corpse
        if (Attack.cell_need_resurrect(cell)) then  -- needs resurrection
           if Attack.act_applicable(Attack.cell_get_corpse(cell)) then      -- can receive this attack
              Attack.marktarget(cell)           -- select it
           end
        end
      end
    elseif (Attack.act_ally(cell)) then         -- contains ally
      if (Attack.cell_need_resurrect(cell)) then    -- ally needs resurrect
        if Attack.act_applicable(cell) then     -- can receive this attack
          Attack.marktarget(cell)           -- select it
        end
      end
    end

  end

  end

  return true
end

function calccells_complex_ally()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))

    local level=Obj.spell_level()
    if level==0 then level=1 end

  local power = text_dec(Logic.obj_par(spell,"unit_count"),level)

    if power == "one" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
    for c=0,Attack.cell_count()-1 do

      local i = Attack.cell_get(c)
        if (Attack.act_ally(i)) then        -- contains ally
        if Attack.act_applicable(i) then        -- can receive this attack
          Attack.marktarget(i)          -- select it
          end
      end
      end
  else
    Attack.multiselect(0)
  end
  return true

end

function calccells_complex_enemy()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))
    local level=Obj.spell_level()
    if level==0 then level=1 end
    local power = text_dec(Logic.obj_par(spell,"unit_count"),level)

    if power == "one" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)
        if (Attack.act_enemy(i)) then        -- contains enemy
        if Attack.act_applicable(i) then        -- can receive this attack
          Attack.marktarget(i)          -- select it
          end
      end
      end
  else
    Attack.multiselect(0)
  end
  return true

end

function calccells_all_enemy_level_complex()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))
    local level=Obj.spell_level()
    if level==0 then level=1 end
    
    local lvl = tonumber(text_dec(Logic.obj_par(spell,"level"),level))
    local power = text_dec(Logic.obj_par(spell,"unit_count"),level)
		
    if power == "one" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)
        if (Attack.act_enemy(i)) and (Attack.act_level(i)<=lvl) then        -- contains enemy
        if Attack.act_applicable(i) then        -- can receive this attack
          Attack.marktarget(i)          -- select it
          end
      end
      end
  else
    Attack.multiselect(0)
  end
  return true

end

function calccells_all_enemy_level()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))
    local level=Obj.spell_level()
    if level==0 then level=1 end
--  local power = tonumber(text_dec(Logic.obj_par(spell,"unit_count"),level))
  local lvl = tonumber(text_dec(Logic.obj_par(spell,"level"),level))

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i)) and  (Attack.act_level(i)<=lvl) then       -- contains enemy and level
     if not (spell=="spell_ram" and Attack.act_name(i)=="ram") then
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
     end 
    end

  end
  return true

end

function calccells_hypnosis()
  local spell = Obj.name()
  local level = Obj.spell_level()

  if level == 0 then level = 1 end

  local ehero_level

  if Attack.act_belligerent() ~= 1 then
    ehero_level, level = get_enemy_hero_stuff( level )
  end

	 local lvl, power = pwr_hypnosis( level, ehero_level )

  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if ( Attack.act_enemy( i ) )
    and ( Attack.act_level( i ) <= lvl ) then       -- contains enemy and level
  	   local lead = tonumber( Attack.act_leadership( i ) ) * Attack.act_size( i )

      if Attack.act_applicable( i )
      and ( lead <= power ) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
	     end 
    end
  end

  return true
end

function calccells_all_ally_level()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))
    local level=Obj.spell_level()
    if level==0 then level=1 end
--  local power = tonumber(text_dec(Logic.obj_par(spell,"unit_count"),level))
  local lvl = tonumber(text_dec(Logic.obj_par(spell,"level"),level))

  local acnt = Attack.act_count()
  for i=1,acnt-1 do

    if (Attack.act_ally(i)) and  (Attack.act_level(i)<=lvl) then       -- contains ally and level
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
        local c=1
      end
    end

  end
  return true

end

function calccells_all_ally_lasthero()

    local spell = Obj.name()
    --local level=math.floor(Game.Random(1,4))
    local level=Obj.spell_level()
    if level==0 then level=1 end
--  local power = tonumber(text_dec(Logic.obj_par(spell,"unit_count"),level))
  local lvl = tonumber(text_dec(Logic.obj_par(spell,"level"),level))

  local acnt = Attack.act_count()
  for i=1,acnt-1 do

    if (Attack.act_ally(i)) and (Attack.act_level(i)<=lvl) --[[and Attack.act_size(i)>=2]] then
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
        local c=1
      end
    end

  end
  return true

end

function calccells_all_enemy_around()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if (Attack.act_enemy(i)) and Attack.cell_dist(0,i)==1 and Attack.act_level(i)<5 then      -- contains enemy and level
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end

function calccells_all_enemy_around2()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for i=0,5 do
    local trg=Attack.cell_adjacent(0,i)
    if Attack.act_enemy(trg) and Attack.act_level(trg)<5 then 
          if Attack.act_applicable(trg) then      -- can receive this attack
            Attack.marktarget(trg)            -- select it
          end
    else 
      if Attack.cell_present(trg) and Attack.cell_is_empty(trg) and Attack.cell_is_pass(trg) then      
        trg1=Attack.cell_adjacent(trg,i)
        if Attack.act_enemy(trg1) and Attack.act_level(trg1)<5 then 
          if Attack.act_applicable(trg1) then      -- can receive this attack
            Attack.marktarget(trg1)            -- select it
          end
        end
	    end 
    end

  end

  return true

end

function calccells_all_empty_around()

  for i=0,5 do
    local trg=Attack.cell_adjacent(0,i)
    if Attack.cell_present(trg) and Attack.cell_is_empty(trg) and Attack.cell_is_pass(trg) then      -- contains enemy and level
        Attack.marktarget(trg)            -- select it
    end

  end
  return true

end

function calccells_all_ally_around()

  for i=0,5 do
  	local trg=Attack.cell_adjacent(0,i)
    if (Attack.act_ally(trg)) and Attack.cell_dist(0,trg)==1 and Attack.act_level(trg)<5 then
    if Attack.act_applicable(trg) then      -- can receive this attack
        Attack.marktarget(trg)            -- select it
    end
  end 
  end
  return true

end

function calccells_one_intellect()
  local spell = Obj.name()
  --local level=math.floor(Game.Random(1,4))
  local level = Obj.spell_level()

  if level == 0 then level = 1 end

  local target = text_dec( Logic.obj_par( spell, "target" ), level )

  if target == "ally" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
    for c = 0, Attack.cell_count() - 1 do
      local i = Attack.cell_get( c )

      if ( Attack.act_ally( i ) ) then        -- contains ally
        if Attack.act_applicable( i ) then        -- can receive this attack
          if string.find( spell, "dispell" )
          and Attack.act_spell_count( i ) > 0 then
            if Attack.act_spell_count( i ) == 1 then
      		      local spell_name = Attack.act_spell_name( i, 0 )
              if not string.find( spell_name, "special_difficulty" ) then
                Attack.marktarget(i)          -- select it
              end
            else
              Attack.marktarget(i)          -- select it
            end
          end 

          if not string.find( spell, "dispell" ) then 
            Attack.marktarget(i)          -- select it
          end
        end
      end
    end
  end

  if target == "enemy" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
    for c = 0, Attack.cell_count() - 1 do
      local i = Attack.cell_get( c )
      if ( Attack.act_enemy( i ) ) then        -- contains enemy
        if Attack.act_applicable( i ) then        -- can receive this attack
          if string.find( spell, "dispell" )
          and Attack.act_spell_count( i ) > 0 then
            if Attack.act_spell_count( i ) == 1 then
      		      local spell_name = Attack.act_spell_name( i, 0 )
              if not string.find( spell_name, "special_difficulty" ) then
                Attack.marktarget(i)          -- select it
              end
            else
              Attack.marktarget(i)          -- select it
            end
          end 

          if not string.find( spell, "dispell" ) then 
            Attack.marktarget(i)          -- select it
          end
        end
      end
    end
  end

  if target == "all" then
--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
    for c = 0, Attack.cell_count() - 1 do
      local i = Attack.cell_get( c )
      if ( Attack.act_ally( i )
      or Attack.act_enemy( i ) ) then        -- contains ally or enemy
        if Attack.act_applicable( i ) then        -- can receive this attack
          if string.find( spell, "dispell" )
          and Attack.act_spell_count( i ) > 0 then
            if Attack.act_spell_count( i ) == 1 then
      		      local spell_name = Attack.act_spell_name( i, 0 )
              if not string.find( spell_name, "special_difficulty" ) then
                Attack.marktarget(i)          -- select it
              end
            else
              Attack.marktarget(i)          -- select it
            end
          end 

          if not string.find( spell, "dispell" ) then 
            Attack.marktarget(i)          -- select it
          end
        end
      end
    end
  end

  return true
end

function calccells_all_empty()

    local ccnt = Attack.cell_count()
    for i=0,ccnt-1 do               -- for all cells
      local cell = Attack.cell_get(i)       -- get cell
      if Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then  -- cell is empty
        Attack.marktarget(cell)         -- select it
      end
    end

  return true
end


function calccells_all()

    local ccnt = Attack.cell_count()
    for i=0,ccnt-1 do               -- for all cells
        Attack.marktarget(Attack.cell_get(i))     -- select
    end

  return true
end

function calccells_ally_empty_around()

--  local acnt = Attack.act_count()
--  for j=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local j = Attack.cell_get(c)
    if Attack.act_ally(j) then -- ищет всех союзников
    for i=0,5 do
      local trg=Attack.cell_adjacent(j,i)
      if Attack.cell_present(trg) and Attack.cell_is_empty(trg) and Attack.cell_is_pass(trg) then      -- ищет все пустые клетки рядом
        Attack.marktarget(trg)            -- select it
      end
    end
    end
  end
  return true

end

function calccells_blood()

--  local acnt = Attack.act_count()
--  for j=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local j = Attack.cell_get(c)
    if Attack.act_ally(j) then -- ищет всех союзников
    Attack.marktarget(j)            -- select it
    for i=0,5 do
      local trg=Attack.cell_adjacent(j,i)
      if Attack.cell_present(trg) and Attack.cell_is_empty(trg) and Attack.cell_is_pass(trg) then      -- ищет все пустые клетки рядом
        Attack.marktarget(trg)            -- select it
      end
    end
    end
  end
  return true

end

function calccells_time_return()
  local acnt = Attack.act_count()
  local level=tonumber(Attack.get_custom_param("level"))
  for i=1,acnt-1 do
    if (Attack.act_ally(i) or Attack.act_enemy(i)) and not Attack.act_feature(i,"pawn") and not Attack.act_pawn(i) then       -- contains ally and enemy
      if Attack.act_applicable(i) and (Attack.act_level(i)<=level) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true
end

function calccells_sacrifice()
  local cycle = Attack.get_cycle()

  if not Attack.is_computer_move() then 
		  Game.InfoHint( "bmsg_sacrifice_" .. ( cycle + 1 ) )
  end 

  local function check_target( j, hp, source )
  	 return Attack.act_ally( j )
    and not Attack.act_equal( j, source )
    and Attack.act_applicable( j )
    and not Attack.act_temporary( j )
	  	and math.floor( hp / Attack.act_get_par( j,"health" ) ) >= 1
  end

  if ( cycle == 0 ) then
	   local level = Obj.spell_level()

	   if level == 0 then level = 1 end
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

	   local damage, power = pwr_sacrifice( level, ehero_level )
    local acnt = Attack.act_count()

    for i = 1, acnt - 1 do                           -- for all actors
      if Attack.act_ally( i )
      and Attack.act_applicable( i )
      and not Attack.act_temporary( i )
      and Attack.act_get_armour( i ) == nil
      and not Attack.act_feature( i, "undead" ) then
        -- проверяем, для данного source, есть ли хоть один target
        local hp = math.min( damage, Attack.act_totalhp( i ) ) * power / 100

		      for j = 1, acnt - 1 do                           -- for all actors
		        if check_target( j, hp, i ) then
          		Attack.marktarget( i )
          		break
          end
        end
      end
    end

  elseif ( cycle == 1 ) then
    local source = Attack.val_restore( "sacrifice_source" )
    local dcnt = Attack.act_count()
    local hp = Attack.val_restore( "sacrifice_hp" )

    for j = 1, dcnt - 1 do                           -- for all actors
      if check_target( j, hp, source ) then
        Attack.marktarget( j )
      end
    end
  end

  return true
end

function calccells_change_place(enumerator)

  local cycle = Attack.get_cycle()
  if enumerator ~= nil then cycle = 1 end
  if not Attack.is_computer_move() then 
		Game.InfoHint("bmsg_change_"..(cycle+1))
  end 

  if (cycle == 0) then
-- Game.InfoHint("bowman_moveattack_infohint");
    local acnt, appl = Attack.act_count(), {}
    for i=1,acnt-1 do                           -- for all actors
      if not Attack.act_equal(0,i) and (Attack.act_ally(i) or Attack.act_enemy(i)) and Attack.act_name(i)~="archdemon"  then        -- actor is enemy or ally
        if Attack.act_applicable(i) then                -- can receive this attack
			table.insert(appl, i)
        end
      end
    end

	if table.getn(appl) > 1 then
		for i,act in ipairs(appl) do
		    Attack.marktarget(act)
		end
	end

  elseif (cycle == 1) then  
-- Game.InfoHint("bowman_throw1_infohint");
  local source = Attack.val_restore("change_place")
    local dcnt = Attack.act_count()
    
    if enumerator == nil then enumerator = Attack.marktarget end
    
    for j=1,dcnt-1 do                           -- for all actors
      if not Attack.act_equal(0,j) and (Attack.act_ally(j) or Attack.act_enemy(j)) and not Attack.act_equal(j,source) and Attack.act_name(j)~="archdemon" then        -- actor is enemy or ally
        if Attack.act_applicable(j) then                -- can receive this attack
          enumerator(j)
        end
      end
    end

  end

  return true
end


function calccells_ice_serpent()

  local ccnt = Attack.cell_count()
  for i=0,ccnt-1 do
    local cell = Attack.cell_get(i)
    if (not Attack.cell_is_empty(cell)) and Attack.act_enemy(cell) and Attack.act_takesdmg(cell) and Attack.act_applicable(cell) then
        Attack.marktarget(cell)
    end
  end
  return true
end

function calccells_corpse_around()

  for i=0,5 do
    local cell=Attack.cell_adjacent(0,i)
    if Attack.cell_is_empty(cell) and Attack.cell_present(cell) and (Attack.cell_has_ally_corpse(cell) or Attack.cell_has_enemy_corpse(cell)) and Attack.cell_dist(0,cell)==1 then      -- contains enemy and level
        Attack.marktarget(cell)            -- select it
    end
  end
    
  return true
end


function calccells_plant_around()
  for i = 0, 5 do
    local cell = Attack.cell_adjacent( 0, i )
    if Attack.act_ally( cell )
    and Attack.act_feature( cell, "plant" )
    and Attack.cell_dist( 0, cell ) == 1 then
      if Attack.act_applicable( cell ) then  -- can receive this attack
        Attack.marktarget( cell )            -- select it
      end
    end
  end
    
  return true
end


function calccells_phantom()
  local cycle = Attack.get_cycle()
  local spell = Obj.name()
  local level = Obj.spell_level()

  if level == 0 then level = 1 end
  
  if not Attack.is_computer_move() then 
		  Game.InfoHint( "bmsg_phantom_" .. ( cycle + 1 ) )
  end 

  if ( cycle == 0 ) then -- кого клонируем
    local ehero_level

    if Attack.act_belligerent() ~= 1 then
      ehero_level, level = get_enemy_hero_stuff( level )
    end

    local acnt = Attack.act_count()

    for i = 1, acnt - 1 do
      if Attack.act_ally( i )
      and Attack.act_applicable( i )
      and not Attack.act_is_spell( i, spell ) then
        local count = math.floor( Attack.act_totalhp( i ) * ( pwr_phantom( level, ehero_level ) / 100 ) / (Attack.act_get_par( i, "health" ) ) )

        if count > 0 then
      	   for dir = 0, 5 do
      		    local c = Attack.cell_adjacent( i, dir )

      		    if empty_cell( c ) then -- есть хоть одна пустая клетка вокруг
        		    Attack.marktarget( i )
        		    break
        	   end
          end
        end
      end
    end

  elseif ( cycle == 1 ) then -- куда
    local source = Attack.val_restore( "source_unit" )
    local ccnt = Attack.cell_count()

    for i = 0, ccnt - 1 do
      local cell = Attack.cell_get( i )

      if Attack.cell_is_empty( cell )
      and Attack.cell_is_pass( cell )
      and Attack.cell_dist( source, cell ) == 1 then
        Attack.marktarget( cell )
      end
    end
  end

  return true
end


function calccells_telekines(enumerator)

  local cycle
  if enumerator == nil then cycle = Attack.get_cycle() else cycle = 1 end
  
  if not Attack.is_computer_move() then 
		Game.InfoHint("bmsg_telekines_"..(cycle+1))
  end 


  if (cycle == 0) then

    local acnt = Attack.act_count()
    for i=1,acnt-1 do                           -- for all actors
      if Attack.act_ally(i) or Attack.act_enemy(i)  then        -- actor is enemy or ally
        if Attack.act_applicable(i) and Attack.act_get_par(i, "dismove") == 0 then                -- can receive this attack
          Attack.marktarget(i)
        end
      end
    end

  elseif (cycle == 1) then
  
  local target = Attack.val_restore("telekines")
  
    if enumerator == nil then enumerator = Attack.marktarget; end
    
    for i=0,5 do
      local trg=Attack.cell_adjacent(target,i)
      if Attack.cell_present(trg) and Attack.cell_is_empty(trg) and Attack.cell_is_pass(trg) then      -- ищет все пустые клетки рядом
            enumerator(trg)            -- select it
      end
  end
  
  end

  return true
end

function calccells_ally_undead()

--  local acnt = Attack.act_count()
--  for i=1,acnt-1 do
  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if Attack.act_ally(i) or (Attack.act_enemy(i) and Attack.act_race(i)=="undead")  then        -- contains ally
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end

-- New for Archdemon Amalgamation
function calccells_enemy_special_amalgamation()
  local level = tonumber( Attack.get_custom_param( "level" ) )
	
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )
		
    if Attack.act_enemy( i )
    and Attack.act_level( i ) <= level
    and ( ( not Attack.act_is_spell( i, "spell_ram" )
    and not Attack.act_feature( i, "plant" )
    and not Attack.act_feature( i, "golem" )
    and not Attack.act_feature( i, "undead" ) )
    or ( not Attack.act_is_spell( i, "spell_blind" )
    and not Attack.act_feature( i, "eyeless" ) )
    or not Attack.act_is_spell( i, "spell_pygmy" ) ) then
      if Attack.act_applicable( i ) then      -- can receive this attack
      	 Attack.marktarget( i )                -- select it
      end
    end
  end

  return true
end

function calccells_enemy_beast()
  local level = tonumber( Attack.get_custom_param( "level" ) )
	 local k = Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
  local caster_count = Attack.act_size( 0 )	-- сколько магов
	 local caster_name = Attack.act_name( 0 )
 	local caster_lead = Attack.act_leadership( 0 )
 	local target_lead, target_count = 0, 0
	
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )
		
  		if Attack.act_enemy( i ) then 
			   target_lead = Attack.act_leadership( i )
			   target_count = Attack.act_size( i )
		  end 
	 
    if Attack.act_enemy( i )
    and Attack.act_feature( i, "beast" )
    and Attack.act_level( i ) <= level then        -- contains ally
    	 if caster_lead * caster_count * k / 100 >= target_lead * target_count then
      	 if Attack.act_applicable( i ) then      -- can receive this attack
        	 Attack.marktarget( i )            -- select it
      	 end
      end 
    end
  end

  return true
end

function calccells_all_corpse()
  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if Attack.cell_is_empty( i )
    and Attack.cell_present( i )
    and Attack.cell_get_corpse( i ) ~= nil
    and Attack.cell_is_pass( i ) then
      if Attack.act_applicable( Attack.cell_get_corpse( i ) ) --[[and (Attack.act_size(Attack.cell_get_corpse(i))>0 or Attack.act_size(Attack.cell_get_corpse(i))~=nil)]] then      -- can receive this attack
        Attack.marktarget( i )            -- select it
      end
    end
  end

  return true
end


function calccells_all_corpse2()
  local lvl

		if Attack.get_caa( 0 ) == nil then -- magic
    local level
  	 level = Obj.spell_level()
 	  -- если заклинание читаем из свитка (уровень = 0) то кастуем с силой 1

   	if level == 0 or level == nil then level = 1 end

   	local spell = Obj.name()
    lvl = tonumber( text_dec( Logic.obj_par( spell, "level" ), level ) )
  else
    lvl = tonumber( Attack.get_custom_param( "level" ) )
  end

  for c = 0, Attack.cell_count() - 1 do
    local i = Attack.cell_get( c )

    if Attack.cell_is_empty( i )
    and Attack.cell_present( i )
    and Attack.cell_get_corpse( i ) ~= nil
    and Attack.cell_is_pass( i ) then
      if Attack.act_applicable( Attack.cell_get_corpse( i ) ) --[[and (Attack.act_size(Attack.cell_get_corpse(i))>0 or Attack.act_size(Attack.cell_get_corpse(i))~=nil)]] then      -- can receive this attack
        Attack.marktarget( i )            -- select it
      end
    elseif ( Attack.act_ally( i ) ) then         -- contains ally
      if ( Attack.cell_need_resurrect( i ) )
      and ( Attack.act_level( i ) <= lvl )
      and ( tonumber( skill_power2( "necromancy", 4 ) ) > 0 )
      and Attack.act_feature( i, "undead" ) then    -- ally needs resurrect
        if Attack.act_applicable( i ) then     -- can receive this attack
          Attack.marktarget( i )           -- select it
        end
      end
    end
  end

  return true
end


function calccells_enemy_longhit()

  for c=0,5 do
    local i = Attack.cell_adjacent(0, c)

	if Attack.cell_is_empty(i) and Attack.cell_is_pass(i) then
	
		local ii = Attack.cell_adjacent(i, c)
	    if (Attack.act_enemy(ii) or Attack.act_pawn(ii)) and Attack.act_takesdmg(ii) and Attack.act_applicable(ii) then
	       Attack.marktarget(ii)            -- select it
        end
	    
	end

  end
  return true

end

function calccells_capture()

  for c=0,5 do
    local i = Attack.cell_adjacent(0, c)

	if Attack.cell_is_empty(i) and Attack.cell_is_pass(i) then

		local ii = Attack.cell_adjacent(i, c)
	    if Attack.act_enemy(ii) and Attack.act_applicable(ii) and Attack.act_get_par(ii, "dismove") == 0 then
	       Attack.marktarget(ii)            -- select it
        end

	end

  end
  return true

end

function calccells_corpse()

--[[    local i = Attack.cell_get(0)

    if Attack.cell_is_empty(i) and Attack.cell_present(i) and (Attack.cell_has_ally_corpse(i) or Attack.cell_has_enemy_corpse(i)) then
      return true
    else 
     	return false
    end ]]
    if Attack.cell_get_corpse(0) ~= nil then
        Attack.multiselect(0)
    end
    return true

end


function calccells_griffin_split()

  if Attack.act_size(0) < 2 then return true end

  for c=0,5 do
    local i = Attack.cell_adjacent(0, c)

	if Attack.cell_is_empty(i) and Attack.cell_is_pass(i) then
		Attack.marktarget(i)            -- select it
	end
  end
  return true

end


function calccells_greediness()

  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)
	if Attack.cell_is_box(i) then -- помечаем все клетки вокруг сундука
	  for d=0,5 do
	    local j = Attack.cell_adjacent(i, d)
	    if Attack.cell_present(j) and Attack.cell_is_empty(j) and Attack.cell_is_pass(j) then Attack.marktarget(j) end
	  end
	end

  end
  return true

end


function calccells_gibe()

  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if Attack.act_enemy(i) and Attack.act_level(i)<=4 and Attack.act_ap(i)>0 then       -- contains enemy
      if Attack.act_applicable(i) then      -- can receive this attack
        Attack.marktarget(i)            -- select it
      end
    end

  end
  return true

end


function calccells_blackdragon_firepower()

	if Attack.act_get_par(0, "dismove") > 0 then return true end

	local ccnt = Attack.cell_count()
	for i=0,ccnt-1 do               -- for all cells
	  local cell = Attack.cell_get(i)       -- get cell
	  if Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then  -- cell is empty
		local ap = Attack.act_ap(0)
		if Attack.cell_dist(0, cell) <= ap then
		    local path = Attack.calc_path(0, cell)
		    if path ~= nil and table.getn(path) <= ap+1 then
		    	Attack.marktarget(cell)         -- select it
			end
		end
	  end
	end

	return true

end


function calccells_all_pass()

    local ccnt = Attack.cell_count()
    for i=0,ccnt-1 do               -- for all cells
      local cell = Attack.cell_get(i)       -- get cell
      if Attack.cell_is_pass(cell) and not Attack.cell_is_box(cell) then  -- cell is empty
        Attack.marktarget(cell)         -- select it
      end
    end

  return true

end

function calccells_evilbook()
	
    local ccnt = Attack.cell_count()
    local dist=Attack.act_ap(0)
    for i=0,ccnt-1 do               -- for all cells
      local cell = Attack.cell_get(i)       -- get cell
      
      if Attack.cell_is_pass(cell) and not Attack.cell_is_box(cell) and Attack.cell_dist(0,cell)<=dist then  -- cell is empty
        Attack.marktarget(cell)         -- select it
      end
      if Attack.act_ally(cell) or Attack.act_enemy(cell)  and Attack.cell_dist(0,cell)<=dist then
      	Attack.marktarget(cell)         -- select it
      end 
    end

  return true
	
end

function calccells_dominator()
  local cycle = Attack.get_cycle()
  local level = tonumber( Attack.get_custom_param( "level" ) )
	 local k = Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
  local caster_count = Attack.act_size( 0 )	-- сколько магов
 	local caster_name = Attack.act_name( 0 )
	 local caster_lead = tonumber( Attack.act_leadership( 0 ) )
 	local target_lead, target_count = 0, 0
  
  if not Attack.is_computer_move() then 
		  Game.InfoHint( "bmsg_dominator_" .. ( cycle + 1 ) )
  end 
  
  if ( cycle == 0 ) then -- кого телепортаем
    local acnt = Attack.act_count()

    for i = 1, acnt - 1 do                           -- for all actors
      if Attack.act_level( i ) <= level
      and ( Attack.act_enemy( i )
      or Attack.act_ally( i ) )
      and not Attack.act_feature( i, "mind_immunitet" )
      and not Attack.act_feature( i, "undead" ) then      
					   target_lead = tonumber( Attack.act_leadership( i ) )
					   target_count = Attack.act_size( i )

				    if ( caster_lead * caster_count * k / 100 >= target_lead * target_count ) then
          if Attack.act_applicable( i )
          and Attack.act_ap( i ) > 0
          and not Attack.act_feature( i, "mind_immunitet" ) then                -- can receive this attack
            Attack.marktarget(i)                      -- select it
          end
        end
      end
    end

  elseif ( cycle == 1 ) then -- в куда телепортаем
    local acnt = Attack.act_count()

    for i = 1, acnt - 1 do                           -- for all actors
      if Attack.act_enemy( i )
      and not Attack.act_equal( Attack.val_restore( "dominator_control" ), i ) then      -- только своих
        if Attack.act_applicable( i ) then                -- can receive this attack
          Attack.marktarget( i )                      -- select it
        end
      end
    end
  end

  return true
end

function calccells_ally_gulp()

	local HP=tonumber(Attack.get_custom_param("health"))*Attack.act_size(0)
  for i=0,5 do
  	local trg=Attack.cell_adjacent(0,i)
  	if trg ~= nil and Attack.cell_present(trg) then
	  	local cur_hp=Attack.act_totalhp(trg)
	  	local name=Attack.act_name(trg)
	    if (Attack.act_ally(trg) and not Attack.act_pawn(trg)) and Attack.act_level(trg)<5 then
	    if Attack.act_applicable(trg) and cur_hp<=HP then      -- can receive this attack
	        Attack.marktarget(trg)            -- select it
	    end
	end
  end 
  end
  return true

end


function calccells_army_disposition()

	local dist = skill_power("tactics")

	if Attack.get_cycle() == 0 then

	    for i=1, Attack.act_count()-1 do
			if Attack.act_ally(i) then
				Attack.marktarget(i)
			end
		end

	else

		local t = Attack.get_board_layer(0)
		if t ~= nil then
			for i=0, Attack.cell_count()-1 do

				local c = Attack.cell_get(i)
				if Attack.act_ally(c) then
					if not Attack.act_equal(Attack.val_restore("source"), c) then
						Attack.marktarget(c)
					end
				elseif empty_cell(c) then
					for i,id in ipairs(t) do
						if (Attack.cell_dist(Attack.cell_id(id), c) <= dist) then
							Attack.marktarget(c)
							break
						end
					end
				end

			end
		end

	end

	return true

end

function calccells_totem()

  local d = tonumber(Attack.val_restore("dist"))
  local ally = Attack.val_restore("ally")
  local bel = Attack.val_restore("belligerent")

  for c=0,Attack.cell_count()-1 do

    local i = Attack.cell_get(c)

    if Attack.cell_dist(0,i)<=d and (Attack.cell_is_empty(i) or (ally==nil or ally=="" or ally=="-1" or (ally=="1" and Attack.act_ally(i, bel)) or (ally=="0" and Attack.act_enemy(i, bel)))
			and totem_applicable(i)) then
        Attack.marktarget(i)                    -- select it
    end

  end

  return true

end
