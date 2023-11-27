function scn_hero_magic ( param )
    if (param == nil) then
      Scenario.animate("magic","magic")
      Scenario.playcamtrack("bigfishship_free.track", 60)
    elseif (param == "magic") then
        return true
    end
    return false
end
function scn_hero_cast ( param )
    if (param == nil) then
      Scenario.stop( true )
      Scenario.animate("cast","cast")
    elseif (param == "cast") then
        return true
    end
    return false
end

function scn_hero_stop ( param )

    if (param == nil) then

        Scenario.stop()
        Scenario.delay( 1, "hero_000" )

    elseif (param == "hero_000") then
        return true
    end

    return false
end

function scn_hero_takebox ( param )

    Scenario.stop()
    return true
end

function scn_hero_entercastle ( param )

    Scenario.stop()
    return true
end

function scn_hero_enterboat ( param )

    Scenario.stop()
    return true

end

function scn_hero_teleport1 ( param )

    local teletarget = "dev_map_0.start"

    if (param == nil) then

      -- начнемс...
      Scenario.formsolo( "map" )         -- оставить только map интерфейс
      Scenario.delay( 0.1, "hero_001" )  -- подождать 0.1 сек

    elseif (param == "hero_001") then

      -- подождали. продолжаем....
      if not Atom.is_onboat() then
        Scenario.animate("telein","hero_002")  -- анимация ухода в иную реальность
      else
        Scenario.teleport( teletarget, "hero_003" ) -- реально перерубаем локацию
      end

    elseif (param == "hero_002") then
      -- анимация завершена
      Scenario.teleport( teletarget, "hero_003" ) -- реально перерубаем локацию

    elseif (param == "hero_003") then

      Scenario.animate("teleout","hero_004")  -- анимация выхода из телепорта

    elseif (param == "hero_004") then
        -- анимация завершена, больше делать нечего
        return true
    end

    return false
end

function hero_scenario ( scn, param ) --ftag:mascn

    local scenario_handlers = {
        stop = scn_hero_stop,
        hero_cast = scn_hero_cast,
        hero_magic = scn_hero_magic,
        takebox = scn_hero_takebox,
        entercastle = scn_hero_entercastle,
        enterboat = scn_hero_enterboat,
        teleport1 = scn_hero_teleport1
    }

    local f = scenario_handlers[ scn ]

    if (f ~= nil) then
        return f(param)
    end

end

function from_big_fish () --ftag:action

  Game.GVStr("afterswitch", "hero_magic")
  return false

end

function change_manarage () --ftag:action

  local rage = Logic.cur_lu_item( "rage", "count" )
  local diff=Game.HSP_difficulty()
  local par_mana=Game.Config("difficulty_k/manarage")
  local par_rage=Game.Config("difficulty_k/manarage")
  par_mana=string.gsub(par_mana, "|", ",")
  par_rage=string.gsub(par_rage, "|", ",")
  local k_mana_dif = tonumber(text_dec(par_mana,diff+1))
  local k_rage_dif = tonumber(text_dec(par_rage,diff+1))
  local max_rage = Logic.cur_lu_item( "rage", "limit" )
  local max_mana = Logic.cur_lu_item( "mana", "limit" )
  local mana = Logic.cur_lu_item( "mana", "count" )
  local mana_add=5   --сколько давать за период в % от максимума
  local rage_sub=5   --сколько отнимать за период в % от максимума
  -- бонус от навыка и предметов, в % на который домножим mana_add
  local wiz_bonus=skill_power("meditation",1)+ Logic.hero_lu_item("sp_mana_map_prc","count")
  --sp_mana_map_prc

  if rage > 0 then
    local tmp_rage = max_rage*(rage_sub/100)*(1-Logic.hero_lu_item("sp_rage_map","count")/100)/k_rage_dif
    if tmp_rage<1 then tmp_rage=1 end
    rage = rage - tmp_rage
    if rage<0 then rage = 0 end
    Logic.cur_lu_item( "rage", "count", rage )
    Game.ClearEffect( "rage" )
  end
  --if mana < max_mana then
    local tmp_mana = max_mana*(mana_add/100)*(1+wiz_bonus/100)*k_mana_dif
    if rage == 0 then tmp_mana = tmp_mana * Game.Config("mana_gain_k_when_no_rage") end
    if tmp_mana < 1 then tmp_mana = 1 end
    mana = mana + tmp_mana
    Logic.cur_lu_item( "mana", "count", mana )
    Game.ClearEffect( "mana" )
  --end

  return false

end

function decrease_rage () --ftag:action

  local rage = Logic.cur_lu_item( "rage", "count" )
  if rage > 0 then
    rage = rage - 1
    Logic.cur_lu_item( "rage", "count", rage )
    Game.ClearEffect( "rage" )
  end

  return false

end

function increase_mana () --ftag:action

    local mana_add=1   --сколько давать за период
    local time_period=10  -- на сколько периодов делится минута

  local max_mana = Logic.cur_lu_item( "mana", "limit" )
  local mana = Logic.cur_lu_item( "mana", "count" )
  local wiz_bonus=skill_power("meditation",1)
  if wiz_bonus==nil then wiz_bonus=0 end

  if mana < max_mana then
    mana = mana + wiz_bonus/10 + mana_add
    Logic.cur_lu_item( "mana", "count", mana )
    Game.ClearEffect( "mana" )
  end

  return false

end

function restore_mana () --ftag:action


  local max_mana = Logic.hero_lu_item( "mana", "limit" )
  Logic.hero_lu_item( "mana", "count", max_mana  )

  return false

end

function set_hero_rank ( varname ) --ftag:vv

    local HR = "<label=hero_rank_"
    local c =  Logic.cur_lu_var( "hrank" )

    HR=HR..c..">"

    return HR

end

function gen_hero_class()

  local hclass = Game.HSP_class()
  if hclass == nil or hclass < 0 then
    hclass = 0
  end

  local hero = Game.Config("heroclasses/" .. tostring(hclass) )

  return "<label=hero_class_" .. hero .. ">"
end

function hero_rebirth( par ) --ftag:action
  local hclass = Game.HSP_class()

  if hclass == nil or hclass < 0 then
    hclass = 0
  end

  local hero = Game.Config( "heroclasses/" .. tostring( hclass ) )
  local hero_cfg = "hero_" .. hero
  local location = Game.LocName()

  if string.find( location, "training_centre" ) then
    local starting_army = Game.GVStr( "starting_army" )
    Logic.hero_lu_army( starting_army )
  else
    local current_leadership = Logic.hero_lu_item( "leadership", "count" )
    local max_leadership = tonumber( text_dec( Game.Config( 'difficulty_k/releadmax' ), Game.HSP_difficulty() + 1, '|' ) )
    local leadership = math.min( current_leadership, max_leadership )
    hero_random_army( hero_cfg, leadership, 5 )
  end

  return false
end

-- New! Randomly generates the hero's starting army
function hero_random_army( hero_cfg, leadership, total_slots )
  local unit_list = Game.Config( hero_cfg .. "/start/army" )
  local length_unit_list = text_par_count( unit_list )
  local unit_names = {}

  for i = 1, length_unit_list do
    local unit_name = text_dec( unit_list, i )

    if Logic.cp_leadship( unit_name ) < leadership then
      table.insert( unit_names, unit_name )
    end
  end
    
  local function remove_duplicate_table_entries( table_name )
    table.sort( table_name )

    local i = 1
    while i < table.getn( table_name ) do
      if table_name[ i ] == table_name[ i + 1 ] then
        table.remove( table_name, i + 1 )
      else
        i = i + 1
      end
    end

    return table_name
  end

  unit_names = remove_duplicate_table_entries( unit_names )
  local army = ""

  for i = 1, total_slots do
    local index = Game.Random( 1, table.getn( unit_names ) )
    local number = math.floor( leadership / Logic.cp_leadship( unit_names[ index ] ) )

    if i == 1 then
      army = army .. unit_names[ index ] .. "|" .. tostring( number )
    else
      army = army .. "|" .. unit_names[ index ] .. "|" .. tostring( number )
    end
    table.remove( unit_names, index )
  end

  Logic.hero_lu_army( army )

  if total_slots == 3 then
    Game.GVStr( "starting_army", army )
  end

  return true  
end


function add_hero_spell( path, spellname, spellparam )
  if spellparam ~= nil then
    local level = tonumber( spellparam )

    if level == 0 then
      local hclass = Logic.hero_lu_var( "class" )

      if hclass == nil then
        hclass = Game.HSP_class()
      end

      local hero = Game.Config( "heroclasses/" .. tostring( hclass ) )
      local hero_cfg = "hero_" .. hero
      local spell_chance = tonumber( Game.Config( hero_cfg .. "/start/spell_chance" ) )
      local scroll_chance = tonumber( Game.Config( hero_cfg .. "/start/scroll_chance" ) )

      if Game.Random( 100 ) < spell_chance then
        if Game.Random( 100 ) < scroll_chance then
          Logic.hero_add_spell( spellname, 0, Game.Random( 1, 3 ) )
        else
          Logic.hero_add_spell( spellname, 1 )
        end
      end

    elseif level < 0 then
      Logic.hero_add_spell( spellname, 0, -level )
    else
      Logic.hero_add_spell( spellname, level )
    end
  end

  return true
end

function add_hero_item(path, itemname, countpar)
  if countpar ~= nil then
    local count = tonumber( countpar )
    Logic.hero_add_item( itemname, count )
  end
  return true
end

function generation_hero( par ) --ftag:action
  local hclass = Game.HSP_class()

  if hclass == nil
  or hclass < 0 then
    hclass = 0
  end

  local hero = Game.Config( "heroclasses/" .. tostring( hclass ) )

  if par == nil or par == "" then hero = par end

  local hero_cfg = "hero_" .. hero
  Logic.hero_lu_var( "class", hclass )
  Logic.hi_slots( hero_cfg .. "/slots" )
  local leadership = tonumber( Game.Config( hero_cfg .. "/start/leadership" ) )
  local attack = tonumber( Game.Config( hero_cfg .. "/start/attack" ) )
  local defense = tonumber( Game.Config( hero_cfg .. "/start/defense" ) )
  local intellect = tonumber( Game.Config( hero_cfg .. "/start/intellect" ) )
  local mana = tonumber( Game.Config( hero_cfg .. "/start/mana" ) )
  local rage = tonumber( Game.Config( hero_cfg .. "/start/rage" ) )
  local gold = tonumber( Game.Config( hero_cfg .. "/start/gold" ) )
  local crystals = tonumber( Game.Config( hero_cfg .. "/start/crystals" ) )
  local rune_might = tonumber( Game.Config( hero_cfg .. "/start/rune_might" ) )
  local rune_mind = tonumber( Game.Config( hero_cfg .. "/start/rune_mind" ) )
  local rune_magic = tonumber( Game.Config( hero_cfg .. "/start/rune_magic" ) )
  local book = tonumber( Game.Config( hero_cfg .. "/start/book" ) )
  local rindex = Game.Mutate( 6 ) + 1 -- индекс начала выдачи рун
  local rside = Game.Mutate( 2 )      -- направление отсчета
  Logic.hero_lu_var( "rindex",rindex )
  Logic.hero_lu_var( "rside",rside )
  local diff = Game.HSP_difficulty()

  if diff == 0 then -- легкий уровень
      gold = gold * 5
      crystals = crystals * 5
      mana = math.ceil( mana * 1.5 )
      rage = math.ceil( rage * 1.5 )
      rune_might = rune_might + 8
      rune_mind = rune_mind + 8
      rune_magic = rune_magic + 8
      book = math.ceil( book * 2 )
  end

  if diff == 1 then -- нормальный уровень
      gold = gold * 2
      crystals = crystals * 2
      mana = math.ceil( mana * 1.25 )
      rage = math.ceil( rage * 1.25 )
      rune_might = rune_might + 2
      rune_mind = rune_mind + 2
      rune_magic = rune_magic + 2
      book = math.ceil( book * 1.3 )
  end

  Logic.hero_lu_item( "money", "count", gold )
  Logic.hero_lu_item( "leadership", "count", leadership )
  Logic.hero_lu_item( "attack", "count", attack )
  Logic.hero_lu_item( "defense", "count", defense )
  Logic.hero_lu_item( "intellect", "count", intellect )
  Logic.hero_lu_item( "mana", "limit", mana )
  Logic.hero_lu_item( "mana", "count", mana )
  Logic.hero_lu_item( "rage", "limit", rage )
  Logic.hero_lu_item( "rage", "count", 0 )
  Logic.hero_lu_item( "crystals", "count", crystals )
  Logic.hero_lu_item( "rune_mind", "count", rune_mind )
  Logic.hero_lu_item( "rune_might", "count", rune_might )
  Logic.hero_lu_item( "rune_magic", "count", rune_magic )
  Logic.hero_lu_item( "booksize", "count", book )
  Game.ConfigEnum( hero_cfg .. "/start/spells", "add_hero_spell" )
  Game.ConfigEnum( hero_cfg .. "/start/items", "add_hero_item" )

  -- apply skill after! params
  local skill_off = Game.Config( hero_cfg .. "/start/skills_off" )
  local skill_off_count = text_par_count( skill_off )

  for i = 1, skill_off_count do
    Logic.hero_lu_skill( text_dec( skill_off, i ), -1 )
  end

  local skill_on = Game.Config( hero_cfg .. "/start/skills_open" )
  local skill_on_count = text_par_count( skill_on )
  for i = 1, skill_on_count do
    Logic.hero_lu_skill( text_dec( skill_on, i ), 1 )
  end

  hero_random_army( hero_cfg, Logic.hero_lu_item( "leadership", "count" ), 3 )

  return false
end

-- Повышение уровня героя
function calc_levelup()
  local hclass = Game.HSP_class()

  if hclass == nil or hclass < 0 then
    hclass = 0
  end

  local hero = Game.Config( "heroclasses/" .. tostring( hclass ) )
  local hero_cfg = "hero_"..hero
  local level = tonumber( Logic.hero_lu_var( "level" ) )
  local leadership1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/leadership" ), 1 ) )
  local leadership2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/leadership" ), 2 ) )
  --tonumber(text_dec(Game.Config(hero_cfg.."/level_up/leadership"),2))
  -- New! Modifiers to stats and limits based on level and probability such that Leadership isn't such an obvious choice
  local attack_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/attack" ), 3 ) )
  local defense_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/defense" ), 3 ) )
  local intellect_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/intellect" ), 3 ) )
  local mana_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/mana" ), 3 ) )
  local rage_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/rage" ), 3 ) )
  -- stat_den and limit_den values are in CONFIG.TXT
  local stat_den = tonumber( Game.Config( "hero_level_up_den/stat_den" ) )
  local limit_den = tonumber( Game.Config( "hero_level_up_den/limit_den" ) )
  local attack_den = math.max( 1, ( 100 - attack_rnd ) / ( 100 / stat_den ) )
  local defense_den = math.max( 1, ( 100 - defense_rnd ) / ( 100 / stat_den ) )
  local intellect_den = math.max( 1, ( 100 - intellect_rnd ) / ( 100 / stat_den ) )
  local mana_den = math.max( 1, ( 100 - mana_rnd ) / ( 100 / limit_den ) )
  local rage_den = math.max( 1, ( 100 - rage_rnd ) / ( 100 / limit_den ) )
  local attack_mod1 = math.floor( level / stat_den )
  local defense_mod1 = math.floor( level / stat_den )
  local intellect_mod1 = math.floor( level / stat_den )
  local attack_mod2 = math.floor( level / attack_den )
  local defense_mod2 = math.floor( level / defense_den )
  local intellect_mod2 = math.floor( level / intellect_den )
  local mana_mod1 = math.floor( level / limit_den )
  local rage_mod1 = math.floor( level / limit_den )
  local mana_mod2 = math.floor( level / mana_den )
  local rage_mod2 = math.floor( level / rage_den )
  local attack1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/attack" ), 1 ) ) + attack_mod1
  local attack2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/attack" ), 2 ) ) + attack_mod2
  local defense1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/defense" ), 1 ) ) + defense_mod1
  local defense2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/defense" ), 2 ) ) + defense_mod2
  local intellect1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/intellect" ), 1 ) ) + intellect_mod1
  local intellect2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/intellect" ), 2 ) ) + intellect_mod2
  local mana1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/mana" ), 1 ) ) + mana_mod1
  local mana2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/mana" ), 2 ) ) + mana_mod2
  local rage1 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/rage" ), 1 ) ) + rage_mod1
  local rage2 = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/rage" ), 2 ) ) + rage_mod2

  if Game.HSP_difficulty() == 0 then
    mana1, rage1 = mana1 + 2, rage1 + 2
    mana2, rage2 = mana2 + 2, rage2 + 2
  end

  if Game.HSP_difficulty() == 1 then
    mana1, rage1 = mana1 + 1, rage1 + 1
    mana2, rage2 = mana2 + 1, rage2 + 1
  end

  local book = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/book" ), 1 ) )
  local book_rnd = tonumber( text_dec( Game.Config( hero_cfg.."/level_up/book" ), 2 ) )

  if math.mod( level + 1,book_rnd ) == 0 then Levelup.add( 0, "booksize", book ) end

-- новый способ выдаи рун
  local max_var = 6
--  local rune_war = { "4,1,2", "4,2,1", "5,2,0", "4,3,1", "4,2,2", "5,1,2" } -- 7, 7, 7, 8, 8, 8: 26, 11, 8 (58%, 24%, 18%)
  local rune_war = { "4,2,1", "4,3,0", "3,3,1", "3,3,2", "4,4,0", "4,3,1" } -- 7, 7, 7, 8, 8, 8: 22, 18, 5 (49%, 40%, 11%)
--  local rune_pal = { "1,4,2", "2,4,2", "2,4,2", "3,4,0", "0,4,3", "2,5,1" } -- 7, 8, 8, 7, 7, 8: 10, 25, 10 (22%, 56%, 22%)
  local rune_pal = { "2,3,2", "1,4,2", "2,4,1", "3,4,1", "3,3,2", "2,4,2" } -- 7, 7, 7, 8, 8, 8: 13, 22, 9 (30%, 50%, 20%)
  local rune_mag = { "1,2,4", "2,1,4", "0,1,6", "1,3,4", "3,1,4", "2,1,5" } -- 7, 7, 7, 8, 8, 8: 9, 9, 27 (20%, 20%, 60%)
  local rindex = Logic.hero_lu_var( "rindex" )

  if rindex == nil or rindex == "" then
    rindex = Game.Mutate( 6 ) + 1
  else
    rindex = tonumber( rindex )
  end

  local rside = Logic.hero_lu_var( "rside" ) -- 0 <- назад, 1 -> вперед
  if rside == nil or rside == "" then
    rside = Game.Mutate( 2 )
    Logic.hero_lu_var( "rside", rside )
  else
    rside = tonumber( rside )
  end

  local might, mind, magic = 0, 0, 0
  local tmp_mas

  if hclass == 0 then
    tmp_mas = rune_war
    if Game.HSP_difficulty() == 0 then
      might = might + 1
    end
  end

  if hclass == 1 then
    tmp_mas = rune_pal
    if Game.HSP_difficulty() == 0 then
      mind = mind + 1
    end
  end

  if hclass == 2 then
    tmp_mas = rune_mag
    if Game.HSP_difficulty() == 0 then
      magic = magic + 1
    end
  end

  might = might + tonumber( text_dec( tmp_mas[ rindex ], 1 ) )
  mind = mind + tonumber (text_dec( tmp_mas[ rindex ], 2 ) )
  magic = magic + tonumber (text_dec( tmp_mas[ rindex ], 3 ) )

  if rside == 0 then
    rindex = rindex - 1
  else
    rindex = rindex + 1
  end

  if rindex == 0 then
    rindex = max_var
  end
  if rindex == ( max_var + 1 ) then
    rindex = 1
  end

  Logic.hero_lu_var( "rindex", rindex )

-- старый способ выдачи рун весь блок закомментирован
    --[[local   rune_min,rune_max=text_range_dec(Game.Config(hero_cfg.."/level_up/runes")) -- сколько рун
    -- сюда div от уровня героя на коэффициент rune_level
    local rune_level=Game.Config("rune_level")

    local rune_max=rune_max+math.floor(level/rune_level)
    local diff=Game.HSP_difficulty()
    local one_rune=0
    if diff==0 then one_rune=1 end

    -- runes=Game.Mutate(8-8+1,level)+8+0-4 = 0 + 8 - 4 = 4
    local runes=Game.Mutate(rune_max-rune_min+1,level)+rune_min+one_rune-4 --4 мы гарантированно получаем чуть ниже

    local   rune_might=tonumber(Game.Config(hero_cfg.."/level_up/rune_might"))
    local   rune_mind=tonumber(Game.Config(hero_cfg.."/level_up/rune_mind"))
    local   rune_magic=tonumber(Game.Config(hero_cfg.."/level_up/rune_magic"))

    local   might=1
    local   mind=1
    local   magic=1

    if hclass==0 then might=might+1 end
    if hclass==1 then mind=mind+1 end
    if hclass==2 then magic=magic+1 end

    local par1,par2=0,0
    local rnd=1
  for i=1,runes do
    rnd=Game.Mutate(100,level,i,rnd)+1
    if rnd<rune_might then
        might=might+1
    else
        if rnd>rune_might+rune_mind then
            magic=magic+1
        else
            mind=mind+1
        end
    end
  end ]]--
  Levelup.add( 0, "rune_might", might )
  Levelup.add( 0, "rune_mind", mind )
  Levelup.add( 0, "rune_magic", magic )
   -- add items to left button
  local par_len = attack_rnd..","..defense_rnd..","..intellect_rnd..","..mana_rnd..","..rage_rnd
  local res1, res2 = diap( par_len, 1, level )
  local give_lead = true
  local last = Game.GVStrAr( "herolups", 0 )

  if last ~= nil and last == "leadership" then
    give_lead = false
  end

  local min1 = ""
  local min2 = ""
  local farr = { ["attack"] = 0, ["defense"] = 0, ["intellect"] = 0, ["mana"] = 0, ["rage"] = 0 }
  local i
  for i = 0, Game.GVStrAr( "herolups" ) - 1 do
    local sel = Game.GVStrAr( "herolups", i )
    local ov = farr[ sel ]
    if ov == nil then
      farr[ sel ] = 1
    else
      farr[ sel ] = ov + 1
    end
  end

  local w, n, ma
  ma = 10000
  for w, n in farr do
    if n < ma and w ~= last and w ~= "leadership" then
      min1 = w
      ma = n
    end
  end
  ma = 10000
  for w, n in farr do
    if n < ma and w ~= last and w ~= "leadership" and w ~= min1 then
      min2 = w
      ma = n
    end
  end

  local usemin = Game.IsEvery( level, 5 )

  if give_lead then
    Levelup.add( 1, "leadership", Game.Random( leadership1, leadership2 ) * ( level ) )
  else
    res1 = fixgiv( res1, min2, last, usemin )
    if res1 == 1 then Levelup.add( 1, "attack", Game.Random( attack1, attack2 ) )
    elseif res1 == 2 then Levelup.add( 1, "defense", Game.Random( defense1, defense2 ) )
    elseif res1 == 3 then Levelup.add( 1, "intellect", Game.Random( intellect1, intellect2 ) )
    elseif res1 == 4 then
      local mana = Game.Random( mana1, mana2 )
      Levelup.add( 1, "mana", mana, mana )
    elseif res1 == 5 then
      local rage = Game.Random( rage1, rage2 )
      Levelup.add( 1, "rage", rage, rage )
    end
  end

  res2 = fixgiv( res2, min1, last, usemin )

  if (not give_lead) and (res1 == res2) then
    -- this is hack. res1 should never be equal to res2. bug somewhere above...
    local n2i = { ["attack"] = 1, ["defense"] = 2, ["intellect"] = 3, ["mana"] = 4, ["rage"] = 5, [""] = r }
    if res1 ~= min2 then
      res2 = n2i[ min2 ]
    elseif res1 ~= min1 then
      res2 = n2i[ min1 ]
    else
      res2 = res1 + 1
      if res2 > 5 then
        res2 = 1
      end
    end
  end

  if res2==1 then Levelup.add( 2, "attack", Game.Random( attack1, attack2 ) )
  elseif res2==2 then Levelup.add( 2, "defense", Game.Random( defense1, defense2 ) )
  elseif res2==3 then Levelup.add( 2, "intellect", Game.Random( intellect1, intellect2 ) )
  elseif res2==4 then
    local mana = Game.Random( mana1, mana2 )
    Levelup.add( 2, "mana", mana, mana )
  elseif res2==5 then
    local rage = Game.Random( rage1, rage2 )
    Levelup.add( 2, "rage", rage, rage )
  end

  return false
end

function fixgiv( r, s, last, usemin )

  local i2n = { "attack", "defense", "intellect", "mana", "rage" }
  local n2i = { ["attack"] = 1, ["defense"] = 2, ["intellect"] = 3, ["mana"] = 4, ["rage"] = 5, [""] = r }
  if i2n[r] == last or usemin then
    return n2i[ s ]
  end
  return r
end


function diap(str,instr,par)

  local number=text_par_count(str)
  local sum=0
  local result1=0
  local result2=0
  for i=1,number do
    sum=sum+tonumber(text_dec(str,i))
  end
  local level=tonumber(Logic.hero_lu_var("level"))
    local rnd=0
    if par==nil then
        rnd=math.floor(Game.Random(1,sum+0.45))
    end
    if par=="box" then
    rnd=Game.Mutate(sum,par)+1
  end
  if par~=nil and par~="box" then
    rnd=Game.Mutate(sum,par)+1
  end

  local tmp=0

  for i=1,number do
    if rnd > tmp and rnd <=(tmp+tonumber(text_dec(str,i))) then
        result1 = i
        break
    else
        tmp=tmp+tonumber(text_dec(str,i))
    end
  end

  if instr==nil or instr==0 then
    return result1
  else
--      local dec=text_dec(str,result1)
    str=text_replace(str,result1,0)
        local number=text_par_count(str)

      local sum=0
      for i=1,number do
        sum=sum+tonumber(text_dec(str,i))
    end

    local rnd=Game.Mutate(sum,par,sum)+1
    local tmp=0

    for i=1,number do
        if rnd > tmp and rnd <=(tmp+tonumber(text_dec(str,i))) and number~=0 then
            result2 = i
            break
        else
            tmp=tmp+tonumber(text_dec(str,i))
        end
    end

    return result1,result2
  end

  return sum
end

function gen_diap()
    local res1,res2 = diap("10,25,20,20,43,50,45,10",1)
    --local rnd=Game.Random(5,10)--math.floor(Game.Random(5,10))

    return res1.."-"..res2

end

function text_replace(str,num,repl)
    local number=text_par_count(str)
    local result=""
    if text_instr(str) then result=result..text_dec(str,0).."=" end
    for i=1,number do
        if i==num then
            result=result..repl
        else
            result=result..text_dec(str,i)
        end
        if i~=number then result=result.."," end
    end

    return result
end
