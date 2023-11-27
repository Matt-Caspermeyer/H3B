-- ***********************************************
-- * Boss layer logic function
-- ***********************************************

function cell_can_attack_boss (cell, layer) --ftag:cell_boss

  if (cell ~= nil) then

    if (layer == 1) then

      return true

    end

  end

  return false

end


-- ***********************************************
-- * Boss layer logic function
-- ***********************************************

function boss_can_attack_cell (cell, layer) --ftag:boss_cell

  -- boss should identify only important under attack cell (near head for example)

  if (cell ~= nil) then

    if (layer > 1) then

      return true

    end

  end

  return false

end


-- ***********************************************
-- * Turtle boss select attack
-- ***********************************************
function boss_turtle_selattack () --ftag:chga

    -- may be head?
    local acnt = Attack.act_count()
    for i=1,acnt-1 do
      local abl = Attack.bosscellid(i)
      local head = (abl==2) or (abl==5) or (abl==6)
      if head and Attack.act_human(i) and Attack.act_applicable(i) and not (string.find(Attack.act_name(Attack.cell_get_corpse(i)),"phoenix")) then
         Attack.val_store( "kandidad", i ) -- head attack kandidad
         return Attack.change_attack(0) -- use head
      end
    end

    local slowuse = Attack.val_restore("slowuse")

    if slowuse ~= nil then
      slowuse = slowuse - 1
    end

    if slowuse == nil or slowuse <= 0 then
      -- use slow attack
      Attack.val_store("slowuse",Game.Random(2,4))
      return Attack.change_attack(2) -- use slow
    end

    return Attack.change_attack(1) -- use quake
end

-- ***********************************************
-- * Turtle boss select hitback attack
-- ***********************************************
function boss_turtle_selhitback()

  local agressor = Attack.get_target()
  local abl = Attack.bosscellid(agressor)

  if (abl==2) then --or (abl==5) or (abl==6) then
    Attack.val_store( "kandidad", agressor ) -- head attack kandidad
    return Attack.change_attack(0) -- use head
  end

  if abl >2 then--==3 or abl==4 then
    return Attack.change_attack(3) -- use push
  end

  return Attack.change_attack(1) -- use quake (hm...)

end




-- ***********************************************
-- * Turtle Slow
-- ***********************************************
function boss_slow_attack()

  local duration = tonumber("0" .. Logic.obj_par("boss_slow","duration"))

    Attack.act_aseq( 0, "magic" )
    local spp = Attack.aseq_time( 0, "x" )

    local acnt = Attack.act_count()
    for i=1,acnt-1 do
      if Attack.act_human(i) and Attack.act_applicable(i) then
        local speedlow = tonumber("0" .. Logic.obj_par("boss_slow","penalty"))
        Attack.act_del_spell(i,"spell_slow")
        Attack.act_del_spell(i,"spell_haste")


        Attack.act_apply_spell_begin( i, "boss_slow", duration, false )
          Attack.act_apply_par_spell( "speed", -speedlow, 0, 0, duration, false)
--          Attack.act_ap( i, cur_ap)
        Attack.act_apply_spell_end()
                Attack.atom_spawn(i, spp, "magic_slow" )

      end
    end
  Attack.log("blog_boss_slow","name",blog_side_unit(0,1),"saname",blog_side_unit(0,3).."<label=boss_tattack_slow_name>")
  return true
end

-- ***********************************************
-- * Turtle Quake
-- ***********************************************
function boss_quake_attack()

  local min_dmg,max_dmg = text_range_dec(Logic.obj_par("boss_quake","damage"))
  local effect = tonumber(Logic.obj_par("boss_quake","effect"))
  local dmg_type = Logic.obj_par("boss_quake","typedmg")

  Attack.act_aseq( 0, "cast" )
  local boom_time = Attack.aseq_time( 0, "x" )


  local acnt = Attack.act_count()
  for i=1,acnt-1 do
    if Attack.act_human(i) and Attack.act_applicable(i) and Attack.act_takesdmg(i) then

      Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)

      Attack.act_damage(i)
      Attack.dmg_timeshift(i,boom_time)

      --Attack.atom_spawn(i,shake_time,"thespikes_quake")
      local hit_x = Attack.aseq_time( i, "x" )
      Attack.aseq_timeshift( i, boom_time - hit_x )
    end
  end

  return true
end

-- ***********************************************
-- * Turtle Push
-- ***********************************************
function boss_push_attack()

  local min_dmg,max_dmg = text_range_dec(Logic.obj_par("boss_push","damage"))
  local dmg_type = Logic.obj_par("boss_push","typedmg")

  local t = Attack.get_target()
  local t2 = nil

  local boss_cell_id = Attack.bosscellid(t)
  local animation
  if boss_cell_id==3 then
    t2 = boss_push_found(5)
    animation="push_left"
  elseif boss_cell_id==5 then
    t2 = boss_push_found(3)
    animation="push_left"
  elseif boss_cell_id==4 then
    t2 = boss_push_found(6)
    animation="push_right"
  elseif boss_cell_id==6 then
    t2 = boss_push_found(4)
    animation="push_right"
  else
    return true -- do nothing
  end

  local dir = Attack.cell_dir( t )
  local c = Attack.cell_adjacent( t, dir )
  local dir2 = nil
  local c2 = nil

  local push1 = Attack.cell_present(c) and Attack.cell_is_empty(c)
  local push2 = false

  if t2~=nil then
    dir2 = Attack.cell_dir( t2 )
    c2 = Attack.cell_adjacent( t2, dir2 )

    push2 = Attack.cell_present(c2) and Attack.cell_is_empty(c2)
  end

  Attack.act_aseq( 0, animation )
  local movtime0 = Attack.aseq_time( 0, "x" )

  if push1 or push2 then
    local movtime1 = Attack.aseq_time( 0, "y" )

    Attack.atk_set_damage(dmg_type,min_dmg,max_dmg) --

    if push1 then
      Attack.act_move( movtime0, movtime1, t, c )
      common_cell_apply_damage(t, (movtime0+movtime1)/2)
    end
    if push2 then
      Attack.act_move( movtime0, movtime1, t2, c2 )
      common_cell_apply_damage(t2, (movtime0+movtime1)/2)
    end
  end

  if (not push1) or (not push2) then
    Attack.atk_set_damage(dmg_type,min_dmg*2,max_dmg*2) --

    if not push1 then
      common_cell_apply_damage(t, movtime0)
    end

    if not push2 then
      common_cell_apply_damage(t2, movtime0)
    end

  end

  return true
end

-- ***********************************************
-- * Turtle Head Attack
-- ***********************************************
function boss_head_attack()

  local min_dmg,max_dmg = text_range_dec(Attack.get_custom_param("damage"))
  local dmg_type = Attack.get_custom_param("typedmg")

  local target = Attack.val_restore( "kandidad" )
  if target == nil then
    return true -- no target - no attack
  end

  if Attack.act_human(target) then
    local cid = Attack.bosscellid( target )
    if cid == 2 then
      Attack.act_aseq( 0, "attack" )
    elseif cid == 5 then
      Attack.act_aseq( 0, "attack_left" )
    elseif
      cid == 6 then
      Attack.act_aseq( 0, "attack_right" )
    end

    local dmgts = Attack.aseq_time( 0, "x" )
    Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)
    common_cell_apply_damage(target, dmgts)
  end

  return true
end

-- ***********************************************
-- * Turtle Found Push
-- ***********************************************
function boss_push_found(target)

    local acnt = Attack.act_count()
    for i=1,acnt-1 do
      local abl = Attack.bosscellid(i)
      if abl == target then
        return i
      end
    end

  return nil
end




-- ************************************************
-- ***************** Spider BOSS ******************
-- ************************************************


function sboss_arena_start()

  -- формируем информацию о возможных местах появления паука (делать это нужно каждый раз при запуске арены, т.к. указатели на ячейки могут меняться)
  spider_possible_place = {}
  spider_count_k = 1.
  local place = 1

  for i=0,Attack.cell_count()-1 do
	local cell = Attack.cell_get(i)
	if Attack.bosscellid(cell) == 2 then

	  local ii = cell
	  local iii, dir
	  for i=0,5 do
		local cell = Attack.cell_adjacent(ii, i)
		if Attack.bosscellid( cell ) == 0 then iii = cell; dir = i; break; end
	  end

	  spider_possible_place[place] = { cell = Attack.cell_adjacent(ii, math.mod(dir+3,6)), ang = Attack.angleto(ii,iii) }
	  if place == 3 then break end
	  place = place + 1

	end
  end

  -- сортируем места появления в порядке возрастания id клеток
  table.sort(spider_possible_place, function (i,j) return Attack.cell_id(i.cell)<Attack.cell_id(j.cell) end)

  spider_place = 1

  for i=1,3 do
	local atom = Attack.atom_spawn( spider_possible_place[i].cell, 0, "pitstone", spider_possible_place[i].ang )
  	spider_possible_place[i].stone = Attack.get_caa( atom ) -- atom - штука временная, поэтому преобразуем его к указателю на актера
  end

  -- отыгрываем появлениe
  Attack.act_aseq(spider_possible_place[1].stone, "appear") -- ...камней
  Attack.act_aseq(Attack.get_boss()             , "appear") -- ...паука

  Attack.val_store(Attack.get_boss(), "dislocate", 0)
  spider_first_move = true

  return true

end


function applicable(i)
  return Attack.act_human(i) and Attack.act_applicable(i) and not (string.find(Attack.act_name(Attack.cell_get_corpse(i)),"phoenix"))
end


function get_spider_boss_front_cells()

  local boss, dir = Attack.get_boss()
  for i=0,5 do -- сначала ищем клетку спереди от босса
	local cell = Attack.cell_adjacent(boss, i)
	if Attack.bosscellid( cell ) == 2 then boss = cell; dir = i; break; end
  end

  local left = Attack.cell_adjacent(boss, math.mod(dir+5,6))
  local right = Attack.cell_adjacent(boss, math.mod(dir+1,6))
  return { Attack.cell_adjacent(left, math.mod(dir+4,6)), left, boss, right, Attack.cell_adjacent(right, math.mod(dir+2,6)) }

end


function cell_can_attack_spider_boss (cell, layer)

  return (cell ~= nil) and (layer == 1) and Attack.cell_dist( Attack.get_boss(), cell ) <= 2

end


function spider_boss_selattack ()

  Attack.val_store("hitback", 0)

  local cells = get_spider_boss_front_cells()

  if Attack.val_restore("dislocate")>0 then return Attack.change_attack(6) end
  local hpC = Attack.act_hp(0)/Attack.act_get_par(0, "health")
  local new_spider_place
      if hpC<.4 then new_spider_place=1
  elseif hpC<.6 then new_spider_place=3
  elseif hpC<.8 then new_spider_place=2
  else               new_spider_place=1 end
  if new_spider_place~=spider_place then Attack.val_store("dislocate", new_spider_place) end

  -- с вероятностью 60% рождаем паучка
  if Game.Random( 99 ) < 60 or spider_first_move then return Attack.change_attack(5) end

  -- если можно кусать головой, то всегда кусаем
  if applicable(cells[3]) then return Attack.change_attack(0) end

  -- смотрим, под какой ногой народа больше, той и атакуем
  local left, right = 0, 0
  if applicable(cells[1]) then left = left + 1 end
  if applicable(cells[2]) then left = left + 1 end
  if applicable(cells[4]) then right = right + 1 end
  if applicable(cells[5]) then right = right + 1 end
  if left > 0 or right > 0 then
	if left > right then return Attack.change_attack(1) end
	if right > left then return Attack.change_attack(2) end
	if Game.Random( 1, 100 ) > 50 then return Attack.change_attack(1) end
	return Attack.change_attack(2)
  end

  -- ближнебойные атаки недоступны - зовем паучка
  return Attack.change_attack(5)

end


function spider_boss_selhitback()

  Attack.val_store("hitback", 1)
  local bcid = Attack.bosscellid( Attack.get_target() )
  if bcid <= 1 then return false end
  return Attack.change_attack( ({ nil, 0, 1, 2, 1, 2 })[bcid] )

end


function attack_targets(anim_name, ...)

  local dmgts

  for k,target in ipairs(arg) do
  
	  if applicable(target) then

		if dmgts == nil then
		    Attack.act_aseq( 0, anim_name )
		    dmgts = Attack.aseq_time( 0, "x" )
		end

	    local min_dmg,max_dmg = text_range_dec(Attack.get_custom_param("damage"))
	    local dmg_type = Attack.get_custom_param("typedmg")

	    Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)
	    common_cell_apply_damage(target, dmgts)

	  end

  end

  spider_prepare_dislocation_check()

end


function spider_boss_head_attack()

  attack_targets( "attack", get_spider_boss_front_cells()[3] )
  return true

end


function spider_boss_foot_left_attack()

  local cells = get_spider_boss_front_cells()
  attack_targets( "attack_left", cells[1], cells[2] )
  return true

end


function spider_boss_foot_right_attack()

  local cells = get_spider_boss_front_cells()
  attack_targets( "attack_right", cells[4], cells[5] )
  return true

end


function spider_idle() -- для маленьких паучков
--  if Attack.get_boss() == nil or Atom.getparam() == "spawned" then
    Atom.animate( "idle" )
  --[[else
	Atom.setparam("spawned")
    Atom.animate( "descend" )
  end]]
end

function spider_boss_spawnspider_attack()

  local avcells = {}

  for i=0, Attack.cell_count()-1 do
	local cell = Attack.cell_get(i)
	if Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then table.insert(avcells,cell) end
  end

  local n = 2
  if Game.Random( 99 ) < 50 then n = 3 end
  if spider_first_move then n = 4 end
  if table.getn(avcells) >= n then

  	  local tot_count, target = 0

	  for i=1,n do

		  local r = Game.Random(1, table.getn(avcells))
		  target = avcells[r]

		  --находим ближайшего врага
		  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0
		  for i=1,Attack.act_count()-1 do
		  	if applicable(i) then
		  		local d = Attack.cell_dist(target,i)
		  		if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
		  	end
		  end
		  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto(target, nearest_enemy) end
		  local count = math.floor(Game.Random(text_range_dec(Attack.get_custom_param("count"))) * spider_count_k)
		  Attack.act_spawn(target, 0, "spider_venom", ang_to_enemy, count)
	      Attack.act_nodraw(target, true)
	      local t = (i-1)*.25
		  Attack.act_animate(target, "descend", t)
	      Attack.act_nodraw(target, false, t+.1)

		  tot_count = tot_count + count
		  table.remove(avcells, r);

	  end

	  Attack.act_aseq( 0, "cast" )
	  Attack.log("add_blog_summon_1","name",blog_side_unit(0,1),"targeta",blog_side_unit(target,0),"special",tot_count)

      spider_count_k = spider_count_k * 1.1 -- увечиливаем коэф-т на 10%

  end
  spider_first_move = false

  spider_prepare_dislocation_check()

  return true

end


function spider_prepare_dislocation_check()

  if Attack.val_restore("dislocate")>0 and Attack.val_restore("hitback")~=1 then

    Attack.act_aseq(spider_possible_place[spider_place].stone, "prepare")
    Attack.aseq_timeshift(spider_possible_place[spider_place].stone, Attack.aseq_time(0))
	Attack.act_aseq(0, "prepare")

  end

end

function spider_boss_dislocation()

  Attack.act_aseq(0, "disappear")
  Attack.act_aseq(spider_possible_place[spider_place].stone, "disappear")

    spider_place = Attack.val_restore("dislocate");

  local time = Attack.aseq_time(0)
  Attack.act_teleport(0, spider_possible_place[spider_place].cell, time, spider_possible_place[spider_place].ang)
  Game.SetCam("aboss_spider_camera" .. spider_place .. ".strg", time)
  Attack.act_aseq(0, "appear")
  Attack.act_aseq(spider_possible_place[spider_place].stone, "appear")
  Attack.aseq_timeshift(spider_possible_place[spider_place].stone, time)

  Attack.val_store("dislocate", 0);
	Attack.log("blog_boss_escape","name",blog_side_unit(0,1))
  return true

end



-- ************************************************
-- ***************** Kraken BOSS ******************
-- ************************************************


function kraken_boss_arena_start()

    local hpK = text_dec(Game.Config('difficulty_k/bosshp'), Game.HSP_difficulty()+1, '|')
    local atkK = text_dec(Game.Config('difficulty_k/bossatk'), Game.HSP_difficulty()+1, '|')

	kraken_fish_count_k = 1.
	tentacles_left = 3
	-- заполняем глобальный массив со щупальцами для более удобного доступа
	tentacle = {}
	for i=1,Attack.act_count()-1 do
		local bid = Attack.bosscellid(i)
		if bid >= 2 and not Attack.act_human(i) then
			tentacle[bid] = Attack.get_cell(i)
		    local health = Attack.act_get_par(i, "health") * hpK
		    Attack.act_hp(i, health)
		    Attack.act_set_par(i, "health", health)
            Attack.act_set_par(i, "attack", Attack.act_get_par(i, "attack")*atkK)
		end
	end

	local boss = Attack.get_boss()
	tentacle_damage = {}
	for i,dmg in ipairs({0,"center","side","side","vside","vside"}) do
	    if dmg ~= 0 then
			tentacle_damage[i] = { text_range_dec(Attack.val_restore(boss, "damage_"..dmg)) }
		end
	end

	Attack.act_aseq(boss, "appear")
	Attack.act_animate(boss, "appear")
	Attack.act_aseq(tentacle[2], "appear")
	Attack.act_aseq(tentacle[3], "appear")
	Attack.act_aseq(tentacle[4], "appear2")
	Attack.act_aseq(tentacle[5], "appear")
	Attack.act_aseq(tentacle[6], "appear2")
	--Attack.atk_min_time(Attack.aseq_time(boss))

	return true

end

function kraken_boss_selattack()  -- bosses code: 3-5-2-6-4

	kraken_attack = {}

	if Game.Random( 99 ) < 60 then return true end -- с вероятностью 60% спауним рыбокк

    local bossidcell_rating = {0,0,0,0,0,0} -- таблица рейтингов для каждого типа клетки

	for i=1,Attack.act_count()-1 do
		local bid = Attack.bosscellid(i)
		if bid >= 2 and applicable(i) and not Attack.cell_is_empty(tentacle[bid]) then
			bossidcell_rating[bid] = bossidcell_rating[bid] + tentacle_damage[bid][1] --рейтинг считаем по минимальному урону
		end
	end

	-- рандомизируем рейтинги, чтобы кракен не бил постоянно только одной тройкой щупалец
	for i in ipairs(bossidcell_rating) do
		bossidcell_rating[i] = bossidcell_rating[i] * Game.Random()
	end

	-- считаем оставшиеся щупальца
 	local n = 0
--[[ 	for i=2,4 do
 	    if not Attack.cell_is_empty(tentacle[i]) then n = n + 1 end
 	end]]
 	n = tentacles_left

 	if n == 0 then return true end -- все щупальцы умерли

	for i=1,n do -- находим n максимальных рейтингов и атакуем соответствующими щупальцами (n - число оставшихся щупалец)
		local m = math.max(unpack(bossidcell_rating)) -- максимальный рейтинг

		if m == 0 then return true end

		for i=2,6 do
			if bossidcell_rating[i] == m then
		    	table.insert(kraken_attack, i)
		    	bossidcell_rating[i] = 0
		    	break
		    end
		end
	end

	return true

end

function kraken_boss_selhitback()

	local bid = Attack.bosscellid( Attack.get_target() )
	if bid >= 2 and not Attack.cell_is_empty(tentacle[bid]) then
		kraken_attack = {bid}
		return true
	end

	kraken_attack = {}
	return true

end

function kraken_boss_attack() -- в данной функции нельзя использовать никакие параметры атаки, т.к. она универсальная - используется для всех хитбэков и атак босса, а поскольку босс и щупальца это абсолютно разные атомы, никак друг с другом не связанные, то использовать параметры тек. атаки нельзя

	if table.getn(kraken_attack) == 0 then return kraken_boss_drop_devilfish() end

	local boss = Attack.get_boss()
    local dmg_type = Attack.val_restore(boss, "typedmg")
	Attack.log_label("")

	for k,kattack in ipairs(kraken_attack) do

		local attacker = tentacle[kattack];
	    local min_dmg,max_dmg = unpack(tentacle_damage[kattack]);
		local dmgts

		for i=1,Attack.act_count()-1 do
		  if Attack.bosscellid(i) == kattack and applicable(i) then

			if dmgts == nil then
			    Attack.act_aseq( attacker, "attack" )
			    local tshift = math.random()*1.5 - 2
			    Attack.aseq_timeshift( attacker, tshift )
			    dmgts = Attack.aseq_time( attacker, "x" ) + tshift
			end

		    Attack.atk_set_damage(dmg_type,min_dmg,max_dmg)
		    common_cell_apply_damage(i, dmgts)

		  end
		end

	end

	return true

end

function tentacle_ondmg(wnm,tshift,dead)

	-- считаем оставшиеся щупальца
	if dead then tentacles_left = tentacles_left - 1 end

	local boss = Attack.get_boss()

	Attack.aseq_remove(boss)
 	if tentacles_left == 0 then
 		Attack.act_aseq(boss, "death", true)
 		for i=5,6 do
	 		Attack.act_aseq(tentacle[i], "death", true)
			Attack.aseq_timeshift(tentacle[i], tshift-Attack.aseq_time(tentacle[i], "x"))
		end
	else Attack.act_aseq(boss, "damage") end

	Attack.aseq_timeshift(boss, tshift-Attack.aseq_time(boss, "x"))
	--Attack.atk_min_time( wnm+Attack.aseq_time(boss, "death", "")+.01 )

end

function kraken_boss_drop_devilfish()

  local boss = Attack.get_boss()
  local avcells = {}
  local fishesCount = 0

  for i=0, Attack.cell_count()-1 do
	local cell = Attack.cell_get(i)
	if Attack.cell_is_empty(cell) and Attack.cell_is_pass(cell) then table.insert(avcells,cell)
	elseif Attack.act_name(cell) == "devilfish" then fishesCount = fishesCount + 1 end
  end

  if table.getn(avcells) >= 2 and fishesCount < 6 then

    Attack.act_aseq( boss, "cast" )
    local ids = {15, 5}
    local anims = {"castleft", "castright"}

	for i=1,2 do

		local r = Game.Random(1, table.getn(avcells))
		local target = avcells[r]

	    local spawn = Attack.cell_id( ids[i] )
	    local count=math.floor(Game.Random(text_range_dec(Attack.val_restore(boss,"fishescount"))) * kraken_fish_count_k)
  	    Attack.act_spawn(spawn, 0, "devilfish", Game.Dir2Ang(4), count)
	    Attack.act_aseq( spawn, anims[i] )
	    Attack.act_animate( spawn, anims[i] )

	    local t = Attack.aseq_time( spawn )
	    Attack.act_teleport( spawn, target, t, Game.Dir2Ang(Game.Random(6)) )
	    Attack.act_aseq( spawn, "appear" )
		
		table.remove(avcells, r);
		Attack.log_label("null")
		Attack.log("add_blog_summon_1","name",blog_side_unit(0,1),"targeta",blog_side_unit(spawn,0),"special",count)
    end

    kraken_fish_count_k = kraken_fish_count_k * 1.1 -- увечиливаем коэф-т на 10%

  end

  return true

end


-- ***********************************************
-- * Spider Poison
-- ***********************************************
function effect_spider_poison_attack(target,pause, duration)

  if pause==nil then
    pause=1
  end
	
	if target~=nil and (Attack.act_ally(target) or Attack.act_enemy(target)) then
    local poisonresist = Attack.act_get_res(target,"poison")
    if poisonresist<80 then

      if duration==nil then
        duration = tonumber(Logic.obj_par("boss_poison","duration"))
      end
      
    	local dmg_min,dmg_max = text_range_dec(Logic.obj_par("boss_poison","damage"))

      local power = tonumber(Logic.obj_par("boss_poison","power"))
      local attack = Attack.act_get_par(target, "attack")

      Attack.act_del_spell(target,"boss_poison")

      Attack.act_apply_spell_begin( target, "boss_poison", duration, false )
      Attack.act_apply_par_spell( "attack", -attack/100*power , 0, 0, duration, false)
      Attack.act_apply_spell_end()
   	  Attack.act_spell_param(target, "boss_poison", "dmg_min", dmg_min,"dmg_max", dmg_max)

      Attack.atom_spawn(target, pause, "effect_poison",0,true)
    end
  else if target==nil then
  		  target = Attack.get_target()
				local typedmg=Logic.obj_par("boss_poison","typedmg")
  			local dmg_min=Attack.act_spell_param(target, "boss_poison", "dmg_min")
  			local dmg_max=Attack.act_spell_param(target, "boss_poison", "dmg_max")
  
  			Attack.atk_set_damage(typedmg,dmg_min,dmg_max)
  			Attack.atom_spawn(target, 0, "effect_poison",0,true)
  			common_cell_apply_damage(target, 1)
  	end
  end

  return true
end

function features_boss_poison( damage,addrage,attacker,receiver,minmax )

    if (minmax==0) then

    --local receiver=Attack.get_target(1)  -- кого?
    local poison=tonumber(Attack.get_custom_param("poison"))
    local rnd=Game.Random( 99 )
    
    if rnd<=poison then -- and (not Attack.act_feature(receiver,"poison_immunitet") or Attack.act_race("undead")) then 
        effect_spider_poison_attack(receiver,1,3)
    end

    end 

    return damage,addrage
end
