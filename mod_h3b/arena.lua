function correct_damage_minmax( caa, min_, max_ )
  if Attack.act_is_spell( caa, "spell_bless" ) then
    return max_, max_
  elseif Attack.act_is_spell( caa, "spell_weakness" ) then
    return min_, min_
  end

  return min_, max_
end

MISS        = 1e6
KRIT_MISS   = 2e6
CHARM       = 3e6

-- New common function for computing the attacker / receiver information / bonuses
function att_rec_stuff( attacker, receiver )
  local receiver_human = AU.is_human( receiver )
  local attacker_human = AU.is_human( attacker )
  local hero_attack = 0

  if attacker_human then
    hero_attack = tonum( Logic.hero_lu_item( "attack", "count" ) )
  else
    hero_attack = tonum( Attack.val_restore( attacker, "enemy_hero_attack" ) )
  end

  local krit_inc = tonum( Game.Config( "attack_config/krit_inc" ) )
  local krit_bonus = math.floor( hero_attack / 7 ) * krit_inc
  local res_inc = 0
  local hero_defense = 0

  if receiver_human then
    hero_defense = tonum( Logic.hero_lu_item( "defense", "count" ) )
  else
    hero_defense = tonum( Attack.val_restore( receiver, "enemy_hero_defense" ) )
  end

  local res_inc_config = tonum( Game.Config( "defense_config/res_inc" ) )
  res_inc = math.floor( hero_defense / 7 ) * res_inc_config

-- Здесь усиливает атака по нежити от скилла Святой Гнев
  --holy_rage
  local holy_rage_skill = tonum( skill_power2( "holy_rage", 1 ) )
  local holy_rage_bonus = 0

  if ( AU.race( receiver ) == "undead"
  or AU.feature( receiver, "undead" ) )
  and ( attacker_human
  and AU.race( attacker ) ~= "undead"
  and AU.race( attacker ) ~= "demon" ) then
    holy_rage_bonus = holy_rage_bonus + holy_rage_skill

    if holy_rage_bonus < 0 then holy_rage_bonus = 0 end
  end

  if ( AU.race( receiver ) == "demon"
  or AU.feature( receiver, "demon" ) )
  and ( attacker_human
  and AU.race( attacker ) ~= "demon"
  and AU.race( attacker ) ~= "undead" ) then
    holy_rage_bonus = holy_rage_bonus + holy_rage_skill

    if holy_rage_bonus < 0 then holy_rage_bonus = 0 end
  end

  -- усиливаем атаку по нежити от предметов:
  local attack_undead_bonus = 0

  if ( AU.race( receiver ) == "undead"
  or AU.feature( receiver, "undead" ) )
  and attacker_human then
    attack_undead_bonus = hero_item_count( "sp_attack_undead" )
  end

  -- усиливаем атаку по демонам от предметов:
  local attack_demon_bonus = 0

  if ( AU.race( receiver ) == "demon"
  or AU.feature( receiver, "demon" ) )
  and attacker_human then
    attack_demon_bonus = hero_item_count( "sp_attack_demon" )
  end

  -- усиливаем атаку по драконам от предметов:
  local attack_dragon_bonus = 0

  if AU.feature( receiver, "dragon" )
  and attacker_human then
    attack_dragon_bonus = hero_item_count( "sp_attack_dragon" )
  end

  local attacker_attack = AU.attack( attacker )
  local total_attack_bonus = 1 + attack_undead_bonus / 100 + attack_demon_bonus / 100 + attack_dragon_bonus / 100
  local receiver_defense = AU.defence( receiver )
  local k = ( attacker_attack * total_attack_bonus + holy_rage_bonus ) - receiver_defense
  local cap_inc = tonum( Game.Config( "attack_config/cap_inc" ) )
  local attack_kmax = math.floor( hero_attack / 7 ) * cap_inc / 100
  local kmax = 3 + attack_kmax
  local defense_kmin = math.floor( hero_defense / 7 )
  local kmin = 3 + defense_kmin

  local function sign( x )
    return x > 0 and 1 or x < 0 and -1 or 0
  end
  
  local kdmg = limit_value( ( 1 + math.abs( k ) / 30 )^( sign( k ) ), 1 / kmin, kmax )

  return kdmg, receiver_human, attacker_human, krit_bonus, res_inc
end


function apply_damage( attacker, receiver, dfactor, minmax, krit, kritProb ) --ftag:damage

  local beauty_k=30

  if dfactor < 0 then dfactor = 0 end

  dfactor = dfactor / 100
  local sdmg = 0
  local iskrit
  local kdmg, receiver_human, attacker_human, krit_bonus, res_inc = att_rec_stuff( attacker, receiver )

  if minmax ~= 0
  or krit == 0 then
    iskrit = false -- в подсказках критический урон никогда не учитываем (а также когда krit=0)
  elseif Attack.act_is_spell( attacker, "special_preparation" )
  or Attack.act_is_spell( receiver, "spell_crue_fate" )
  or Attack.act_is_spell( receiver, "effect_unconscious" )
  or Attack.act_is_spell( receiver, "effect_sleep" ) then
    iskrit = true
  else
    kritProb = kritProb + krit_bonus
  
    if Attack.act_is_spell( receiver, "effect_entangle" )
    or Attack.act_is_spell( receiver, "special_spider_web" )
    or Attack.act_is_spell( receiver, "effect_stun" )
    or Attack.act_is_spell( receiver, "spell_blind" ) then
      kritProb = 2 * kritProb
    end
  
    if Attack.act_is_spell( receiver, "spell_slow" ) then
      local kritslow = Attack.val_restore( receiver, "krit_slow" )
  
      if kritslow ~= nil then
        kritProb = kritProb + kritslow
      end
    end

    kritProb = limit_value( kritProb, 0, 100 )
    iskrit = ( Game.CurLocRand( 99 ) < kritProb )
  end

--  local k = AU.attack( attacker ) / AU.defence( receiver )

  local uc = math.max( 1, AU.unitcount( attacker ) ); -- max на случай, когда атакует мертвый юнит (count = 0)
  local dcnt = AU.rescount();
  local i
  local max_damage = 0

  for i = 0, dcnt - 1 do
    local min_ = uc * AU.minresdmg( attacker, i )
    local max_ = uc * AU.maxresdmg( attacker, i )

    if Attack.is_base_attack() then -- все изменения урона распространяются только на базовые атаки
      min_, max_ = correct_damage_minmax( attacker, min_, max_ )
    end

    local dmg

    if ( minmax == 1 ) then dmg = min_
    elseif ( minmax == 2 ) then dmg = max_
    elseif ( minmax == 3 ) then dmg = ( min_ + max_ ) / 2
    else dmg = Game.Random( min_ , max_ ) end

    -- ВНИМАНИЕ! Крит берется не из диапазона а по максимуму!
    if iskrit then dmg = max_ end

    local resi = AU.resistance( receiver, i ) + res_inc

    if resi > 95 then resi = 95 end

    local res_damage = dmg * ( 1 - resi / 100 )
    sdmg = sdmg + res_damage

    if res_damage > max_damage then
      max_damage = res_damage
      Attack.val_store( attacker, "damage_type_index", i )
    end
  end

  sdmg = sdmg * kdmg * dfactor

  -- calc rage for hero [begin] ====================================================================================

  local krage = 0.5
  -- in future it will be like    skill = Logic.cur_lu_counter_converted( "skill_rage" )

  if not ( receiver_human
  or attacker_human )  then
    -- наши вообще не пре делах
    krage = 0
  elseif receiver_human then
    -- наших бьют!
    krage = 1.0
  end

  krage = krage * Game.AddRageK()

  -- бонус от скилла и предметов
  local skill_bonus = 1 + skill_power2( "rage", 1 ) / 100 + hero_item_count( "sp_rage_battle_prc" ) / 100 + hero_item_count( "sp_rage_battle_inflow" ) / 100
  local EnemyRage
  local MaxRage = Logic.cur_lu_item( "rage", "limit" )
  local BaseEnemyLeadership, kLeadership = Game.FightParams()

  if kLeadership < 0.5 then kLeadership = 0.5 end

  if kLeadership > 3 then kLeadership = 3 end

  if kLeadership < 1 then
    EnemyRage = MaxRage * kLeadership
  else
    EnemyRage = MaxRage + ( MaxRage * kLeadership / 3 )
  end

  local killed = math.min( AU.unitcount( receiver ), sdmg / AU.health( receiver ))
  local DeadLeadership = AU.abslead( receiver ) * killed
  local add_hero_rage = DeadLeadership / BaseEnemyLeadership * EnemyRage * skill_bonus * krage

  -- Если удар от спирита или книги магии, то приход ярости занижен
  if Attack.get_caa( attacker ) == nil then add_hero_rage = add_hero_rage * 0.5 end

  -- Если игрок потерял хоть одного  юнита, то он получает +1 ярости
  if receiver_human and killed >= 1 then add_hero_rage = add_hero_rage + 1 end

  add_hero_rage = add_hero_rage * mana_rage_gain_k

  if add_hero_rage < 1
  and add_hero_rage > 0.2 then
    add_hero_rage = 1
  end

  -- calc rage for hero [end] ======================================================================================

  if iskrit then sdmg = -sdmg * krit end

  if minmax == 0 then -- только когда реально наносим урон
    -- выпили зелье уклонения и висит спелл
    if Attack.act_is_spell( receiver, "feat_potion_evasion" )
    and ( Attack.act_chesspiece( attacker )
    or Attack.act_pawn( attacker ) ) then
      local evasion = tonumber( Attack.act_spell_param( receiver, "feat_potion_evasion", "param" ) )
      local rnd = Game.Random( 99 )

      if rnd < evasion then
        return MISS, 0, "damage", ""
      end
    end

    -- особое свойство древнего вампира - превращать криты по нему в 0
    -- или в miss, тогда нужно делать damage не -0,1 а 0
    if iskrit then
      if Attack.act_name( receiver ) == "vampire2" then
        local rnd = Game.Random( 99 )
        local kritslow = Attack.val_restore( receiver, "krit_slow" )

        if kritslow ~= nil then
          rnd = rnd + kritslow
        end

        if rnd < 50 then
          return MISS, 0, "special", ""
        end
      elseif Attack.act_name( receiver ) == "orc"
      or Attack.act_name( receiver ) == "orc2" then
        Attack.val_store( receiver, "critical_hit", 1 )
      end
    end

    -- Здесь снижается урон по красавицам гуманоидами
    if ( AU.feature( receiver, "beauty" )
    and Attack.act_name( receiver ) ~= "ram"
    and AU.feature( attacker, "humanoid" ) ) then
      local rnd = Game.Random( 99 )

      if rnd < 30 then
        return MISS, 0, "avoid", ""
      end
    elseif ( AU.feature( receiver, "cute" )
    and Attack.act_name( receiver ) ~= "ram"
    and AU.feature( attacker, "humanoid" ) ) then
      local rnd = Game.Random( 99 )

      if rnd < 20 then
        return MISS, 0, "avoid", ""
      end
    end

    -- Умения Мародера
    if AU.is_human( attacker )
    and killed > 0
    and 1000 == 10 then
      local gold = 10 --
      local lead = Attack.act_leadership( receiver )
      local cost = math.ceil( killed * lead * gold / 100 )
      local cur_gold = hero_item_count( "money" )
      Logic.hero_lu_item( "money", "count", cur_gold + cost )

      Attack.log( .01, "looter_log", "special", cost )
    end

    if Attack.act_name( receiver ) == "glot" then
      local n = Attack.val_restore( receiver, "balls" )
      return sdmg, add_hero_rage, "damage" .. n, "death" .. n
    end
  end

  -- This is needed for the new cast sacrifice ability for thorns since I couldn't figure
  -- out how to do a custom hint
  Attack.val_store( attacker, "cast_sacrifice_receiver", receiver )
  -- This is for storing the damage caused by a spell effect in case it is needed later
  -- i.e. effect_burn, effect_poison
  Attack.val_store( receiver, "sdmg", sdmg )

  return sdmg, add_hero_rage, "", "" -- return damage and rage

end


function common_update_money( gold )

  -- Рассчитываем золото за бой и выдаем его
  local kCost = tonumber(Game.Config("arenacommon/kCost"))
  gold = kCost * gold * Game.HSP_moneyk()

  -- Золото красиво округляем
  if gold <1000 then gold = Game.Round(gold,10)
  elseif gold <2000 then gold = Game.Round(gold,50)
  elseif gold <10000 then gold = Game.Round(gold,100)
  else gold = Game.Round(gold,500)
  end

  return gold

end


function calc_bonus_simple() --ftag:bonus

  local ecnt = Bonus.info_enemy_dead_count()

  local addexp, gold = 0, 0
  local i
  for i=0, ecnt-1 do
    local dead, atom = Bonus.info_enemy_dead_get( i )
    if dead > 0 then
      addexp = addexp + (Bonus.info_unitexp( atom ) * dead)
      gold = gold + Attack.atom_getpar(atom, "cost") * dead
    end
  end

  Bonus.exp( addexp );
  Bonus.add( "money", common_update_money( gold ) )
  return false
end


function calc_bonus() --ftag:bonus
  local enemyHeroK = 1.5 + Game.Config( "enemy_hero_money_exp_bonus_k") * Logic.enemy_hero_level()
  if Logic.enemy_hero_level() == 0 then enemyHeroK = 1 end

  local necroK, necroKexp = skill_power2( "holy_knight", 1 ), skill_power2( "holy_knight", 2 )
  local addexp, gold = 0, 0

  for i = 0, Bonus.info_enemy_dead_count() - 1 do
    local dead, atom = Bonus.info_enemy_dead_get( i )
    local k, expK = 0, 1
    if dead > 0 then
      if necroK > 0 then
        local race = Attack.atom_getpar( atom, "race" )
        if race == "demon"
        or race == "undead" then k = necroK/100; expK = 1+necroKexp/100 end
      end

      addexp = addexp + ( Bonus.info_unitexp( atom ) * dead) * expK
      gold = gold + Attack.atom_getpar( atom, "cost" ) * dead * ( 1 + k )
    end
  end

  -- коэффициент силы армии
  local elead, leadk = Game.FightParams()
  -- gold = gold * math.min(2, math.max(.5, leadk))
  -- gold = gold * math.min(2, math.max(.5, leadk-(Game.MapLocDifficulty()*3/100)))
--  gold = gold * math.min(2.5, math.max(1, leadk-(Game.MapLocDifficulty()*1.5/100)))
  -- домножение получаемого золота на коэффициент предметов и навыка Трофеи
  gold = gold * ( 1 + skill_power2( "charm", 1 ) / 100 + hero_item_count( "sp_addgold_battle" ) / 100 )

  if boss_exp ~= nil then
    addexp = addexp + boss_exp
  end

  -- округление до 10 и домножение получаемого опыта на коэффициент предметов и навыка Обучение
  local ll = skill_power2( "learning", 1 )
  addexp = addexp
  addexp = Game.Round( addexp, 10 ) * (1 + skill_power2( "learning", 1 ) / 100 + hero_item_count( "sp_addexp_battle" ) / 100 )

  gold = gold / ( Game.MapLocDifficulty() * ( Game.Config( "diffmap_to_kmoneyarmy" ) - 1 ) / 100 + 1 )

  -- коэф-т враж. героя
  gold = gold * enemyHeroK
  addexp = addexp * enemyHeroK
  addexp = math.ceil( add_exp_postprocess( addexp ) )

  -- okruglyaem

  --addexp = Game.Round( add_exp_postprocess( addexp ), 10 )

  addexp = math.ceil( add_exp_postprocess( addexp ) )
  local curexp = Bonus.exp()
  local addlevel, clampedexp = calc_add_level( curexp, curexp + addexp )

  if clampedexp ~= nil then
    addexp = clampedexp
  end

  if addlevel > 1 then
    addlevel = 1
  end

  Bonus.exp( addexp, addlevel );

  if addlevel > 0 then
    Bonus.label( "vic_exp2" )
  else
    Bonus.label( "vic_exp1" )
  end

  local compensk = tonumber( text_dec( Game.Config( 'difficulty_k/deadmoney' ), Game.HSP_difficulty() + 1, '|' ) )
  for i = 0, Bonus.info_ally_dead_count() - 1 do
    local dead, atom = Bonus.info_ally_dead_get( i )
    if dead > 0 then
      gold = gold + Attack.atom_getpar( atom, "cost" ) * dead * compensk
    end
  end

  Bonus.add( "money", common_update_money( gold ) )
  mana_rage_gain_k = 1
--Bonus.add( "money", kCost * gold )
--  Bonus.add( "rage_stamp" )

  return false
end

--New! Function that computes the proper Morale Increase / Decrease Bonus / Penalty
function get_moral_modifier( moral_now, moral_prev )
  local att_def_table = { 70, 80, 90, 100, 110, 120, 130 }
  local krit_table = { 0, 50, 75, 100, 125, 150, 200 }
  moral_now = limit_value( moral_now, -3, 3 ) + 4
  moral_prev = limit_value( moral_prev, -3, 3 ) + 4
  local att_def_modifier = ( att_def_table[ moral_now ] / att_def_table[ moral_prev ] - 1 ) * 100
  local krit_modifier = ( krit_table[ moral_now ] / math.max( 45, krit_table[ moral_prev ] ) - 1 ) * 100

  return att_def_modifier, krit_modifier
end

--New! Function decreases moral of your units
function apply_long_combat_penalties( target, suffix, morale, init, speed, reload )
  local function apply_long_combat_penalties_common( target, suffix, morale, init, speed, reload )
    if morale
    and not Attack.act_pawn( target )
    and not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" )
    and not Attack.act_feature( target, "undead" )
    and not Attack.act_feature( target, "golem" )
    and Attack.act_ally( target )
    and not Attack.act_temporary( target ) then
      local current_value, base_value = Attack.act_get_par( target, "moral" )

      if current_value > -3 then
     	  Attack.act_del_modificator( target, "battle_", true)
     	  Attack.act_del_modificator( target, "battle_attack_", true)
     	  Attack.act_del_modificator( target, "battle_defense_", true)
     	  Attack.act_del_modificator( target, "battle_krit_", true)
        local penalty = tonum( Attack.val_restore( target, "moral_penalty" ) )
        local starting_moral

        if penalty == 0 then
          starting_moral = current_value
          Attack.val_store( target, "starting_moral", starting_moral )
        else
          starting_moral = tonum( Attack.val_restore( target, "starting_moral" ) )
        end

        penalty = penalty + 1
        Attack.val_store( target, "moral_penalty", penalty )
        Attack.act_attach_modificator( target, "moral", "battle_" .. suffix, base_value - penalty, 0, 0, -100, false )
        current_value, base_value = Attack.act_get_par( target, "moral" )
        local att_def_penalty, krit_penalty = get_moral_modifier( current_value, starting_moral )

        if att_def_penalty < 0 then
          Attack.act_attach_modificator( target, "attack", "battle_attack_" .. suffix, 0, 0, att_def_penalty, -100, false )
          Attack.act_attach_modificator( target, "defense", "battle_defense_" .. suffix, 0, 0, att_def_penalty, -100, false )
        end

        if krit_penalty < 0 then
          Attack.act_attach_modificator( target, "krit", "battle_krit_" .. suffix, 0, 0, krit_penalty, -100, false )
        end
      end
    end

    if init
    and not Attack.act_pawn( target )
    and not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "plant" )
    and Attack.act_ally( target ) then
      local current_value, base_value = Attack.act_get_par( target, "initiative" )

      if base_value > 1 then
        Attack.act_set_par( target, "initiative", base_value - 1 )
      end
    end

    if speed
    and not Attack.act_pawn( target )
    and not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" )
    and not Attack.act_feature( target, "golem" )
    and not Attack.act_feature( target, "plant" )
    and Attack.act_ally( target ) then
      local current_value, base_value = Attack.act_get_par( target, "speed" )

      if base_value > 1 then
        Attack.act_set_par( target, "speed", base_value - 1 )
      end
    end

    if reload
    and not Attack.act_feature( target, "pawn" )
    and not Attack.act_feature( target, "boss" )
    and Attack.act_ally( target ) then
      Attack.act_attach_modificator( target, "disreload", "disreload_lc_" .. suffix, 1, 0, 0, -100, false, 1000, false )
    end

    return true
  end

  if target == nil then
    for a = 1, Attack.act_count() - 1 do
      apply_long_combat_penalties_common( a, suffix, morale, init, speed, reload )
    end
  else
    apply_long_combat_penalties_common( target, suffix, morale, init, speed, reload )
  end

  return true
end


--New! Function ensures that the hitback parameter does not exceed 2 due to bonuses
function fix_hitback( target )
  local function fix_hitback_common( target )
    local current_value, base_value = Attack.act_get_par( target, "hitback" )
    if current_value > 2 then
      Attack.act_set_par( target, "hitback", base_value - ( current_value - 2 ) )
      return true
    end

    return false
  end

  if target == nil then
    for a = 1, Attack.act_count() - 1 do
      if not Attack.act_pawn( a )
      and not Attack.act_feature( a, "pawn" )
      and not Attack.act_feature( a, "boss" ) then
        fix_hitback_common( a )
      end
    end
  else
    fix_hitback_common( target )
  end

  return true
end


-- New! function that applies the difficulty level enemy unit statistic bonuses
function apply_difficulty_bonuses( target, diff_k, desc, resistances, min_stat_inc )
  if Attack.act_totalhp( target ) < 1 then
    return false
  end

  local sign_diff_k = 1
  
  if diff_k < 0 then
    sign_diff_k = -1
  end
  
  local function apply_bonus( target, diff_k, sign_diff_k, parameter, min_stat_inc )
    local current_value, base_value = Attack.act_get_par( target, parameter )
    local value_inc = 0

    if parameter == "krit" then
      value_inc = math.max( math.floor( math.abs( diff_k * 100 ) ), min_stat_inc ) * sign_diff_k
    else
      value_inc = math.max( math.floor( math.abs( base_value * diff_k ) ), min_stat_inc ) * sign_diff_k
    end

    if base_value + value_inc < 1
    or current_value + value_inc < 1 then
      value_inc = 0
    end

    if value_inc ~= 0 then
      if parameter == "speed" then
        Attack.act_ap( target, current_value + value_inc )
      elseif parameter == "health" then
        Attack.act_hp( target, base_value + value_inc )
      end
  
      Attack.act_set_par( target, parameter, base_value + value_inc )

      if parameter == "defense" then
        local defenseup = math.max( math.floor( ( base_value + value_inc ) / 5 ), min_stat_inc )
        Attack.act_set_par( target, "defenseup", defenseup )
        local new_current_value, new_base_value = Attack.act_get_par( target, parameter )
        Attack.val_store( target, "enemy_hero_defense", math.max( 0, new_current_value - new_base_value ) )
      elseif parameter == "attack" then
        local new_current_value, new_base_value = Attack.act_get_par( target, parameter )
        Attack.val_store( target, "enemy_hero_attack", math.max( 0, new_current_value - new_base_value ) )
      end
  
      return true   -- change made
    else
      return false  -- no change made
    end
  end

  apply_bonus( target, diff_k, sign_diff_k, "attack", min_stat_inc )
  apply_bonus( target, diff_k, sign_diff_k, "defense", min_stat_inc )
  apply_bonus( target, diff_k, sign_diff_k, "initiative", min_stat_inc )
  apply_bonus( target, diff_k, sign_diff_k, "speed", min_stat_inc )
  apply_bonus( target, diff_k, sign_diff_k, "health", min_stat_inc )
  apply_bonus( target, diff_k, sign_diff_k, "krit", min_stat_inc )

  Attack.act_apply_spell_begin( target, desc, -100, false )
  
  for i = 1, table.getn( resistances ) do
    local min_damage_current, min_damage_base = Attack.act_get_dmg_min( target, resistances[ i ] )
    if min_damage_base > 0 then
      local max_damage_current, max_damage_base = Attack.act_get_dmg_max( target, resistances[ i ] )
      local min_damage_inc = math.max( math.floor( math.abs( min_damage_base * diff_k ) ), min_stat_inc ) * sign_diff_k
      local max_damage_inc = math.max( math.floor( math.abs( max_damage_base * diff_k ) ), min_stat_inc ) * sign_diff_k
      local new_min_damage = min_damage_current + min_damage_inc
      local new_max_damage = max_damage_current + max_damage_inc
  
      if new_min_damage < 1 then
        new_min_damage = min_damage_current
      end

      if new_max_damage < 1 then
        new_max_damage = max_damage_current
      end

      if new_min_damage ~= min_damage_current then
        Attack.act_apply_dmgmin_spell( resistances[ i ], min_damage_inc, 0, 0, -100, false )
      end
  
      if new_max_damage ~= max_damage_current then
        Attack.act_apply_dmgmax_spell( resistances[ i ], max_damage_inc, 0, 0, -100, false )
      end
    end
  end

  Attack.act_apply_spell_end()
  
  for i = 1, table.getn( resistances ) do
    local resist, base_resist = Attack.act_get_res( target, resistances[ i ] )
    if base_resist ~= 0 then
      local new_resist = math.floor( math.abs( base_resist * diff_k ) * sign_diff_k )
      Attack.act_attach_modificator_res( target, resistances[ i ], desc .. resistances[ i ], new_resist, 0, 0, -100, false )
    end
  end

  return true
end


--New! Function that increases / decreases all the unit's stats based on difficulty level
function update_enemy_units_based_on_difficulty( target )
  local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/eunit' ), Game.HSP_difficulty() + 1, '|' ) ) - 1
  local maplocden = tonumber( text_dec( Game.Config( 'difficulty_k/maplocden' ), Game.HSP_difficulty() + 1, '|' ) )
  local maplocdiff = Game.MapLocDifficulty() + 1
  diff_k = diff_k + maplocdiff / maplocden / 100
  local min_stat_inc = tonumber( text_dec( Game.Config( 'difficulty_k/minstatinc' ), Game.HSP_difficulty() + 1, '|' ) )
  local difficulty_value = Game.HSP_difficulty()
  local desc = "difficulty_normal"

  if difficulty_value == 0 then
    desc = "special_difficulty_easy"
  elseif difficulty_value == 1 then
    desc = "special_difficulty_normal"
  elseif difficulty_value == 2 then
    desc = "special_difficulty_hard"
  elseif difficulty_value == 3 then
    desc = "special_difficulty_impossible"
  end

  local resistances = {}
  local str_resistances = Game.Config( 'resistances' )
  local number_resistances = text_par_count( str_resistances )

  if number_resistances > 1 then
    for j = 1, number_resistances do
      local sub_string = text_dec( str_resistances, j )
      table.insert( resistances, sub_string )
    end
  end

  if diff_k ~= 1 then
    if target == nil then
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_enemy( a )
        and not Attack.act_pawn( a )
        and not Attack.act_feature( a, "pawn" )
        and not Attack.act_feature( a, "boss" ) then
          apply_difficulty_bonuses( a, diff_k, desc, resistances, min_stat_inc )
        end
      end
    else
      apply_difficulty_bonuses( target, diff_k, desc, resistances, min_stat_inc )
    end
  end

  return true
end


--New! Function that regenerates enemy hero mana
function regen_enemy_hero_mana( ehero_mana_limit )
  local mana_regen_percent = tonumber( text_dec( Game.Config( 'difficulty_k/emanaregen' ), Game.HSP_difficulty() + 1, '|' ) )

  if ehero_mana_limit ~= nil
  and ehero_mana_limit > 0
  and mana_regen_percent > 0 then
    local mana_regen = math.ceil( ehero_mana_limit * mana_regen_percent / 100 * mana_rage_gain_k )

    if mana_regen > 0 then
  	   local current_mana = Logic.enemy_lu_item( "mana", "count" )

      if current_mana < ehero_mana_limit then
        Logic.enemy_lu_item( "mana", "count", current_mana + mana_regen )
  	     local mana_now = Logic.enemy_lu_item( "mana", "count" )
        Attack.log( "enemy_hero_mana_regen_log", "hero_name", enemy_hero_name, "special", mana_now - current_mana, "special2", mana_now )
      end
    end
  end

  return true
end


--New! Function that reloads enemy attacks
function recharge_enemy_attacks()
  local recharge = false

  for a = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( a )
    and Attack.act_need_charge_or_reload( a )
    and not Attack.act_is_spell( a, "spell_magic_bondage" )
    and not Attack.act_pawn( a )
    and not Attack.act_feature( a, "pawn" )
    and not Attack.act_feature( a, "boss" ) then
      Attack.act_charge( a, 0 )
      Attack.atom_spawn( a, 0, "magic_cornucopia", Attack.angleto( a ) )
      recharge = true
    end
  end

  if recharge then
    Attack.log( "recharge_enemy_attacks_log" )
  end

  return true
end


function on_round_start( round, tend )
  -- NEW! set cast charges depending on hero's level and mana limit
  local extra_book_times_level, extra_book_times_mana, enemy_hero_book_times = 0, 0, 0
  local ehero_level = get_enemy_hero_stuff()
  local ehero_mana = Logic.enemy_lu_item( "mana", "limit" )
  -- These parameters are in LOGIC.TXT
  local ehero_level_dbc = tonumber( text_dec( Game.Config( 'difficulty_k/ehlvldbc' ), Game.HSP_difficulty() + 1, '|' ) )
  local ehero_mana_dbc = tonumber( text_dec( Game.Config( 'difficulty_k/ehmanadbc' ), Game.HSP_difficulty() + 1, '|' ) )

  if ehero_level ~= nil
  and ehero_level >= ehero_level_dbc then
    extra_book_times_level = 1
  end
  
  if ehero_mana ~= nil
  and ehero_mana >= ehero_mana_dbc then
    extra_book_times_mana = 1
  end

  enemy_hero_book_times = 1 + extra_book_times_level + extra_book_times_mana
  Logic.enemy_lu_var( "book_times", enemy_hero_book_times )

  if round == 1 then -- начало боя
    -- NEW! Adds +rounds to the mana_rage_gain_k decrease when fighting enemy heroes, towers, and bosses (must be GLOBAL)
    ROUND_MANA_RAGE_GAIN = 0
    -- New! Used for generating spirit experience
    SECOND_SPIRIT_ATTACK = 0

    if ehero_level ~= nil
    and ehero_level > 0 then
      ROUND_MANA_RAGE_GAIN = tonumber( text_dec( Game.Config( 'difficulty_k/roundehero' ), Game.HSP_difficulty() + 1, '|' ) )
    end

    fix_hitback()  --New! Fixes the hitback of a unit so it does not exceed 2
    update_enemy_units_based_on_difficulty()  --New! Applies difficulty bonuses to starting units

    enemy_hero_name = ""       -- HACK, I couldn't figure out how to get the enemy hero's name here
    
    mana_rage_gain_k = 1

    boss_exp = 0
    local boss = Attack.get_boss()
    if boss ~= nil then
      boss_exp = tonumber( Attack.atom_getpar( Attack.act_name( boss ), "experience" ) )
      -- NEW! Fighting bosses adds +rounds to the mana_rage_gain_k decrease
      ROUND_MANA_RAGE_GAIN = math.max( ROUND_MANA_RAGE_GAIN, tonumber( text_dec( Game.Config( 'difficulty_k/roundboss' ), Game.HSP_difficulty() + 1, '|' ) ) )
    end

    -- Тактика
    if skill_power2( "tactics" ) > 0 then
        Attack.start_special_spell("spell_army_disposition")
        Attack.log("add_blog_tactics")
    else
        Attack.log("battle_start")
        Attack.arena_text("<label=round_big_text> 1")
    end

    -- Сапоги Паломника
    if hero_item_count( "sp_boots_speed" ) > 0 then
      Attack.log( "itm_boots_log" )
      local tormoz
      local speed, speed2 = 7, 0
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_ally( a ) then
          if Attack.act_get_par( a, "speed" ) <= speed then
            tormoz = a
            speed = Attack.act_get_par( a, "speed" )
          end
        end
      end

      if tormoz ~= nil then
        Attack.act_attach_modificator( tormoz, "speed", "palom", 1, 0, 0, -100, false, 0, false )
        Attack.act_ap( tormoz, speed + 1 )
        Attack.atom_spawn( tormoz, 0, "magic_reaction", Attack.angleto( tormoz ) )
      end
    end

    -- Осторожность
    local start_defense_p = skill_power2( "start_defense", 1 )
    if start_defense_p > 0 then
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_ally( a ) then
          Attack.act_attach_modificator_res( a, "physical", "sc", start_defense_p, 0, 0, -100, false, 0, true )
        end
      end

      Attack.log( tend + .01, "start_defense_log", "name", "<label=skill_start_defense_name>", "special", start_defense_p )
    end

    -- Натиск
    local rush_i = skill_power2( "rush", 1 )
    if rush_i > 0 then
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_ally( a ) then
          Attack.act_attach_modificator( a, "initiative", "rush_i", rush_i, 0, 0, 1 )
        end
      end

      Attack.log( tend + .01, "rush_i_log", "name", "<label=skill_rush_name>", "special", rush_i )
    end

    -- New! Rush also increases speed
    local rush_s = skill_power2( "rush", 2 )
    if rush_s > 0 then
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_ally( a ) then
          Attack.act_attach_modificator( a, "speed", "rush_s", rush_s, 0, 0, 1 )
        end
      end

      Attack.log( tend + .01, "rush_s_log", "name", "<label=skill_rush_name>", "special", rush_s )
    end

    -- Высшая магия (начало)
    local t = skill_power2( "hi_magic", 1 )
    Logic.hero_lu_var( "double_book_charges", t )

    if t > 0 then
      t = 2
      Attack.log( tend + .01, "hi_magic_log", "name", "<label=skill_hi_magic_name>", "special", t )
    else
      t = 1
    end

    Logic.hero_lu_var( "book_times", t + book_extra_times )

    -- Арены предметов
    for i = 1, Attack.act_count() - 1 do
      if string.find( Attack.act_name(i), "^arena_tower" ) then -- сражаемся на предметной арене - инициализация
        -- NEW! Fighting towers adds +rounds to the mana_rage_gain_k decrease
        ROUND_MANA_RAGE_GAIN = math.max( ROUND_MANA_RAGE_GAIN, tonumber( text_dec( Game.Config( 'difficulty_k/roundtower' ), Game.HSP_difficulty() + 1, '|' ) ) )
        local itlevel = Game.InsideItemLevel()

        if itlevel == nil then itlevel = 2 end

        local max_enemy_leadership = 0

        for i = 1, Attack.act_count() - 1 do -- считаем hp врагов
          if Attack.act_enemy( i )
          and not Attack.act_pawn( i ) then
            local enemy_leadership = Attack.act_leadership( i ) * Attack.act_initsize( i )
            max_enemy_leadership = math.max( enemy_leadership, max_enemy_leadership )
          end
        end

        enemy_unit_names = {} -- контейнер типов юнитов для призыва башнями
        ally_unit_names = {}

        for i = 1, Attack.act_count() - 1 do
          local actor_name = Attack.act_name( i )
          if string.find( actor_name, "^arena_tower" ) then
            local tower_base_hp = Attack.atom_getpar( actor_name, "hitpoint" )
            local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/eunit' ), Game.HSP_difficulty() + 1, '|' ) )
            local health = math.max( tower_base_hp, math.ceil( max_enemy_leadership * itlevel / 15 * diff_k ) ) -- здоровье башен
            local tower_level = math.max( health / tower_base_hp, 1 )
            local tower_int_bonus = tonum( Attack.val_restore( i, "intellect" ) ) * itlevel
            local tower_intellect = math.ceil( tower_level ) + tower_int_bonus
            local tower_spell_level = math.max( math.min( math.ceil( tower_level / 10 ), 3 ), 1 )
            local tower_def = math.floor( Attack.act_get_par( i, "defense" ) * itlevel + tower_level )
            local tower_init = math.floor( Attack.act_get_par( i, "initiative" ) + itlevel + health / 1000 )
            Attack.val_store( i, "intellect", tower_intellect )
            Attack.val_store( i, "tower_level", tower_level )
            Attack.val_store( i, "tower_spell_level", tower_spell_level )
            Attack.act_set_par( i, "defense", tower_def )
            Attack.act_set_par( i, "initiative", tower_init )
            Attack.act_hp( i, health )
            Attack.act_set_par( i, "health", health )
            local level = 1

            if itlevel >= 5 then
              level = 3
            elseif itlevel >= 3 then
              level = 2
            end

            Attack.act_level( i, level )
          elseif Attack.act_enemy( i ) then
            table.insert( enemy_unit_names, Attack.act_name( i ) )
          elseif Attack.act_ally( i ) then
            table.insert( ally_unit_names, Attack.act_name( i ) )
          end
        end

        break
      end
    end

    -- Инициализация паунов
    local lv = math.floor( Game.MapLocDifficulty() / 20 ) + 1

    for i=1, Attack.act_count()-1 do
      if string.find(Attack.act_name(i), "^altar") or string.find(Attack.act_name(i), "^barrier") then
        Attack.act_level(i, lv)
        Attack.val_store(i, "intellect", tonum(Attack.val_restore(i, "intellect"))*lv)
        Attack.act_set_par(i, "defense", Attack.act_get_par(i, "defense")*lv)
        Attack.act_set_par(i, "initiative", Attack.act_get_par(i, "initiative")+lv)
        local health = Attack.act_get_par(i, "health")*lv
        Attack.act_hp( i, health )
        Attack.act_set_par( i, "health", health )
      end
    end

    for i = 1, Attack.act_count() - 1 do
      if string.find( Attack.act_name( i ), "^darkcrystal") then
        enemy_unit_names = {}

        for j = 1, Attack.act_count() - 1 do
          if string.find( Attack.act_name( j ), "^darkcrystal") then
            local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/bosshp' ), Game.HSP_difficulty() + 1, '|' ) )
            local health = Attack.act_get_par( j, "health" ) * diff_k
            Attack.act_hp( j, health )
            Attack.act_set_par( j, "health", health )
          elseif Attack.act_enemy( j )
          and Attack.act_feature( j, "undead" ) then
            table.insert( enemy_unit_names, Attack.act_name( j ) )
          end
        end

        break
      end
    end

  else
    Attack.log( tend, "round_start", "round", round )
    Attack.arena_text( "<label=round_big_text> " .. round )

    -- Пожиратель Ярости
    if hero_item_count( "sp_rage_predator" ) > 0
    and hero_item_count( "rage" ) > 10
    and ( hero_item_count( "mana" ) < hero_item_limit( "mana" ) ) then
      local sub_rage_tmp = hero_item_count( "sp_rage_predator" )
      local rage_tmp = hero_item_count( "rage" )
      local mana_tmp = hero_item_count( "mana" )
      local add_mana_tmp = hero_item_limit( "mana" ) - hero_item_count( "mana" )

      if add_mana_tmp > sub_rage_tmp then add_mana_tmp = sub_rage_tmp end

      Logic.hero_lu_item( "rage", "count", rage_tmp-sub_rage_tmp )
      Logic.hero_lu_item( "mana", "count", add_mana_tmp+mana_tmp )
      Attack.log( .01, "itm_predator_log", "special", sub_rage_tmp, "special2", add_mana_tmp )
    end

    -- Дефицит маны/ярости
    -- NEW! The mana_rage_gain_k decrease rounds are specified in LOGIC.TXT for the difficulty level being played
    local roundmrgk1 = tonumber( text_dec( Game.Config( 'difficulty_k/roundmrgk1' ), Game.HSP_difficulty() + 1, '|' ) ) + ROUND_MANA_RAGE_GAIN
    local roundmrgk2 = tonumber( text_dec( Game.Config( 'difficulty_k/roundmrgk2' ), Game.HSP_difficulty() + 1, '|' ) ) + ROUND_MANA_RAGE_GAIN
    local roundmrgk3 = tonumber( text_dec( Game.Config( 'difficulty_k/roundmrgk3' ), Game.HSP_difficulty() + 1, '|' ) ) + ROUND_MANA_RAGE_GAIN
    local mrk_table = { { roundmrgk1, 1/2., "rage_mana_deficit_detected_1", "long", true, false, false, false },
                        { roundmrgk2, 1/4., "rage_mana_deficit_detected_2", "drawn", true, true, false, false },
                        { roundmrgk3, 0.  , "rage_mana_deficit_detected_3", "hard", true, true, true, false } }
    for k, v in ipairs( mrk_table ) do
      if round == v[ 1 ] then
        mana_rage_gain_k = v[ 2 ]
        Attack.log( tend + .001, v[ 3 ], "special", math.floor( v[ 2 ] * 100 + .5 ), "round", round )
        apply_long_combat_penalties( nil, v[ 4 ], v[ 5 ], v[ 6 ], v[ 7 ], v[ 8 ] )
        break
      elseif round > roundmrgk3
      and v[ 1 ] == roundmrgk3
      and modulo( round, roundmrgk3 - roundmrgk2 ) == 0 then
        Attack.log( tend + .001, "extremely_long_combat" )
        apply_long_combat_penalties( nil, "drudge", true, true, true, true )
        break
      end
    end

    local hclass = Game.HSP_class()
    local mana_class, rage_class = 0, 0

    if hclass == 0 then
      rage_class = 2
    elseif hclass == 1 then
      rage_class = 1
      mana_class = 1
    elseif hclass == 2 then
      mana_class = 2
    end

    local function kind_per_round( skill, param, item, class_bonus, kind, tend )
      local skill_bonus = skill_power2( skill, param )
      local item_bonus = hero_item_count( item )
      local bonus_per_round = math.ceil( ( skill_bonus + item_bonus + class_bonus ) * mana_rage_gain_k )

      if bonus_per_round > 0
      and Logic.hero_lu_item( kind, "count" ) < Logic.hero_lu_item( kind, "limit" ) then
        local prev = hero_item_count( kind )
        Logic.hero_lu_item( kind, "count", prev + bonus_per_round )
        Attack.log( tend + .01, skill .. "_log", "special", hero_item_count( kind ) - prev )
      end
    end

    kind_per_round( "concentration", 1, "sp_mana_battle", mana_class, "mana", tend )
    kind_per_round( "brutality", 2, "sp_rage_battle", rage_class, "rage", tend )

    -- Высшая магия (окончание)
    local dbc = Logic.hero_lu_var( "double_book_charges" )
    if dbc ~= nil then
      dbc = tonumber( dbc )

      if dbc > 0
      and tonumber( Logic.hero_lu_var( "book_times" ) ) < 1 then -- это означает, что книга была использована 2 раза
        dbc = dbc - 1
        Logic.hero_lu_var( "double_book_charges", dbc )
      end

      if dbc > 0 then
        Logic.hero_lu_var( "book_times", 2 )
        Attack.log( tend + .01, "hi_magic_log", "name", "<label=skill_hi_magic_name>", "special", 2 )
      else
        Logic.hero_lu_var( "book_times", 1 + book_extra_times )
      end
    end

    regen_enemy_hero_mana( ehero_mana )
    local round_recharge = tonumber( text_dec( Game.Config( 'difficulty_k/rndrecharge' ), Game.HSP_difficulty() + 1, '|' ) ) + ROUND_MANA_RAGE_GAIN
  
    if math.mod( round, round_recharge ) == 0 then
      recharge_enemy_attacks()
    end
  end

  if addon_on_round_start ~= nil then addon_on_round_start( round, tend ) end

  return true
end


function on_knockout( koN, caa ) -- koN - кол-во убитых отрядов
  -- Неистовство
  local attack_bonus = skill_power2( "brutality", 1 )

  if caa == nil then caa = 0 end

  if attack_bonus > 0
  and --[[koN == 1 and]] ( Attack.act_belligerent( 0, nil ) == 1
  or Attack.act_belligerent( 0, nil ) == 2 )
  and not Attack.act_pawn( caa ) then
    local total_ko = tonum( Attack.val_restore( 0,"total_ko" ) ) + 1
    Attack.val_store( 0, "total_ko", total_ko )
    Attack.act_attach_modificator( 0, "attack", "brutality_bonus", attack_bonus * total_ko )
    Attack.atom_spawn( 0, 1, "effect_rampage" )
    Attack.log( .01, "rage_log", "special", attack_bonus )
  end

  if features_again ~= nil then features_again() end

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

--seed = 0

-- AI Front End
function ai_choose_target( mover--[[, attacks]], enemies, ecells ) --выбирает цель для атаки и возвращает её;
--[[
Аргументы:
  mover - юнит, который производит атаку и цель для которого нужно выбрать
  attacks - массив aтак, которые можно использовать прямо сейчас
    .targets - массив индексов целей, которых можно атаковать данной атакой
    .name - название атаки (имя блока в атоме юнита)
  enemies - массив всех врагов
  атрибуты mover'a и enemies:
    .cell - id клетки
    .name - тэг атома юнита
    .atks - доступные атаки юнита в виде ассоц. массива, ключ - имя атаки (по названию блока атаки, либо 'base' для базовой атаки), параметры:
      .name - имя атаки
      .targets - возможные цели (юниты)
      .cells - возможные клетки
      .dmgmin - минимальный урон
      .dmgmax - максимальный урон
      .dmgavg - средний урон
      .class - класс (throw, moveattack, scripted)
      .distance - дальность атаки
      .penalty - пенальти при превышении дальности
      .custom_params
      .applicable(actor) - true, если по фичам атака применима
      .calc_damage(actor[, minmax]) - считает урон, который нанесёт данная атака по юниту actor (minmax: 1 - мин. урон, 2 - макс. урон, по умолчанию 3 - средний урон)
        .damage - урон
        .dead - сколько юнитов умрёт
        .hp - сколько жизней останется у последнего юнита в стеке
        .units - сколько юнитов останется в стеке
        .hitback - true, если данный юнит может ответить на этот удар
      опции move-атак:
        friend_damage,_3in1,_6in1,superhitback,long2,nomove,_return
    .level - уровень
    .leadship - лидерство
    .initial_units - кол-во юнитов в отряде в начале боя
    .units - кол-во юнитов в отряде
    .totalhp - кол-во хитов у все юнитов в отряде
    .hp - хитов у последнего юнита
    .ap - action points (действа очки)
    .thrower - true, если юнит может стрелять (точнее, когда юнит имеет базовую атаку класса не moveattack)
    .par("<имя_параметра>") - напр.: par("defense")
    .par_base("<имя_параметра>")
    .sdata - контейнер скриптовых параметров юнита, можно читать и писать параметры через sdata.<имя_параметра> (более удобный аналог val_store/val_restore)
    .spells - заклинания, которые навешаны на юните (можно обращаться через spells[1],spells[2]...spells[spells.n], а также через spells.<имя_заклинания>)
    атрибуты заклинаний:
      .name - название
      .duration - продолжительность действия
      .<имя_параметра> - доступ к доп. скриптовому параметру, можно читать и писать (аналог act_spell_param)
  доп. атрибуты mover:
    .can_pass - может пасовать
  доп. атрибуты enemies:
    .distance - расстояние от mover'a
    .attacks - массив индексов атак, которыми можно атаковать данного врага
  ecells - пустые клетки, в которые можно походить
    .cell - id клетки
    .distance - расстояние от mover'a
]]

  --setfenv(1,aipar) --задаём переменные окружения функции, теперь вместо aipar.enemies можно использовать просто enemies / лучше это не использовать, т.к. тогда перестают быть видны другие объекты из глобальной области видимости, напр. math
  --local Game = {Random = function (x,y) seed = math.mod(seed,6584375897 * seed + 41864553113,1024*1024); return x+(y-x)*math.mod(seed,256)/256; end}

  if table.getn(enemies) == 0 then return {target = 0} end

  if Attack.act_ooc(mover) and Attack.act_human(mover) and Game.Random(99) < 90 then -- в 90% случаев вышедшие из под контроля юниты ведут себя как стадо баранов
    if ecells.n == 0 then return {target = 0} end
    return {target = ecells[Game.Random(1,ecells.n)]}
  end

-- заклинание СТРАХ и НЕВИДИМОСТЬ
  local i = 1
  while i <= table.getn(enemies) do
    if ((mover.spells.spell_scare or mover.spells.effect_fear) and enemies[i].level > mover.level)
            or (enemies[i].spells.spell_invisibility and not Attack.act_feature(mover,"eyeless")) then
        table.remove(enemies, i)
        --[[enemies[i].skip = true
        if attacks.n > 0 then
            for j=1,attacks.n do -- удаляем этого врага отовсюду
                local t = attacks[j].targets
                for j=t.n,1,-1 do
                    if t[j] == i then table.remove(t,j) end
                end
            end
        end]]
    else
        i = i + 1
    end
  end

-- НАСМЕШКА и способность Доминирование разума
  local gibe_target = mover.sdata.gibe_target
  if gibe_target ~= "" then
     for i=1,table.getn(enemies) do
        if --[[enemies[i].skip ~= true and]] enemies[i].cell == tonumber(gibe_target) then
            mover.sdata.gibe_target = ""
            local atks, atk = enemies[i].attacks, 0
            --if atks.n > 0 then atk = atks[ Game.Random(1, atks.n) ] end
            return {target = enemies[i], attack = atk}
        end
     end
     mover.sdata.gibe_target = ""
  end

--[[
  local function exclude_attack(atki)

      for i=1,table.getn(enemies) do
        local a = enemies[i].attacks
        for j=a.n,1,-1 do
            if a[j] == atki then table.remove(a,j) end
        end
      end

  end

  if attacks.n > 0 then
      for i=1,attacks.n do
        if attacks[i].name == "change" then
        -- ПОМЕНЯТЬ ЮНИТОВ МЕСТАМИ
            . . .
            exclude_attack(i) -- исключаем эту атаку, т.к. менять кого-то смысла нет
            break
        end
      end
]]
      local targets = {}

--      for i=1,table.getn(enemies) do
--        if --[[enemies[i].skip ~= true and]] enemies[i].attacks.n > 0 then --выбираем только тех, кого можно атаковать сейчас
    -- заклинание ЦЕЛЬ
--[[            if enemies[i].spells.spell_target then --если на юните висит магия spell_target, то всегда атакуем именно его
                return {target = enemies[i], attack = Game.Random(1,enemies[i].attacks.n)} --выбираем рандомную атаку
            end

            table.insert(targets,enemies[i])
        end
      end]]

--    if Game.Random(1,100) < 50 then -- выбор способа определения цели (в принципе можно использовать только один, любой из нижепредставленных)
  --        if (table.getn(targets) > 0) then
  --          local r = {target = targets[Game.Random(1,table.getn(targets))]}
  --          r.attack = r.target.attacks[Game.Random(1,r.target.attacks.n)]
  --          return r;
  --        end
--[[      else
          local aind
          if attacks.n > 1 and Game.Random(1,100) < 40 then -- use spec.attack
            aind = Game.Random(2,attacks.n)
          else -- use base attack
            aind = 1
          end
          local atar = attacks[aind].targets
          return {target = enemies[ atar[Game.Random(1,atar.n)] ], attack = aind}
      end]]
--  end

  -- идём к ближайшему врагу
--[[  local dist, nearest = 1e10
  for i=1,table.getn(enemies) do
    if enemies[i].skip ~= true and enemies[i].distance < dist then
      dist = enemies[i].distance
      nearest = enemies[i]
    end
  end

  if nearest ~= nil then

    return {target = nearest}; -- attack=1 можно не писать, т.к. это всегда базовая атака и она используется по умолчанию

  elseif ecells.n > 0 then

  -- заклинание ИСПУГ
  if mover.spells.spell_scare or mover.spells.effect_fear then
      if table.getn(targets) > 0 then --можем кого-нить атаковать (но выбор надо делать только из доступных целей, т.е. которые по уровню не превосходят этот юнит)

          return {new_enemies = targets};

      else -- убегаем от врагов как можно дальше

          local dist, farthest = 0, 0

          for i=1,ecells.n do -- для каждой клетки находим сумму расстояний от врагов
              local d = 0
              local c = ecells[i]

              for i=1,table.getn(enemies) do
                d = d + Attack.cell_dist(c, enemies[i])
              end

              if d > dist then
                dist = d
                farthest = ecells[i]
              end
          end

          return {target = farthest} -- {target=0} означает встать в защиту

      end
  end]]

--    return {target = ecells[Game.Random(1,ecells.n)]};
--  end
  return {new_enemies = enemies};

end


-- Unit specific AI

function ram_choose_target( mover, enemies, ecells )

  if ecells.n == 0 then return {target = 0} end
  return {target = ecells[Game.Random(1,ecells.n)]};

end


function path_len(a, b)
    local path = Attack.calc_path(a, b)
    if path ~= nil then return table.getn(path) - 1 end
    return 1000
end

function random_choice(actions)

    local total_prob = 0
    for k,v in ipairs(actions) do
        total_prob = total_prob + v.prob
    end

    local rnd = Game.Random( total_prob - 1 )
    for k,v in ipairs(actions) do
        if rnd < v.prob then return v end
        rnd = rnd - v.prob
    end

    return actions[1] -- ???

end

function is_tactics_offencive(enemies, actors)

    local offence

    if Attack.get_boss() ~= nil then offence = true end

    if offence == nil then
        for i,enemy in ipairs(actors) do
            local enemy_atks = enemy.atks
            if not enemy.thrower and Attack.act_enemy(enemy) and enemy_atks.base ~= nil then
                -- Проверяем, может ли этот враг достать до кого-нить из наших лучников своей базовой атакой
                for j=1,enemy_atks.base.targets.n do
                    local act = enemy_atks.base.targets[j]
                    if act.thrower and Attack.act_ally(act) then -- может - нападаем
                        offence = true
                        break
                    end
                end
                if offence then break end
            end
        end
    end

    if offence == nil then

        local function compute_rel_strength(enemy_check, ally_check)

            local throwingEnemiesSummaryStrength, enemiesSummaryStrength = 0, 0

            for i,enemy in ipairs(actors) do
                local enemy_atks = enemy.atks
                if enemy_check(enemy) and enemy_atks.base ~= nil then
                    if enemy.thrower then
                        -- Проверяем, может ли этот враг достать до кого-нить из наших своей базовой атакой (эта проверка фактически нужна только для алхимика, т.к. остальные лучники всегда могут выстрелить во врага)
                        for j=1,enemy_atks.base.targets.n do
                            if ally_check(enemy_atks.base.targets[j]) then -- может - добавляем силу
                                throwingEnemiesSummaryStrength = throwingEnemiesSummaryStrength + enemy.units*enemy.leadship;--enemy_atks.base.dmgavg;
                                break
                            end
                        end
                    end
                    enemiesSummaryStrength = enemiesSummaryStrength + enemy.units*enemy.leadship;--enemy_atks.base.dmgavg;
                end
            end

            return throwingEnemiesSummaryStrength / enemiesSummaryStrength

        end

        if compute_rel_strength(Attack.act_enemy, Attack.act_ally) > 0.3 then
            offence = true
        elseif compute_rel_strength(Attack.act_ally, Attack.act_enemy) > 0.6 then
            offence = false
        else
            offence = true
        end
    end

    return offence

end


function duration_effect( act, effect, max_duration )
  local duration_effect = Attack.act_spell_duration( act, effect )

  if duration_effect ~= nil then
    if duration_effect > max_duration then
      max_duration = duration_effect
    end
  end

  return max_duration
end


-- AI Back End
function ai_solver( mover, enemies, ecells, actors ) -- actors - массив актеров, значение остальных аргументов описано выше
  --[[ Выбор тактики ИИ (наступающая или оборонительная).
  Логика простая:
  Если есть, кого атаковать прямо сейчас, то всегда нападаем. (это будет работать для всех лучников, исп-е спецатак в начале боя и т.д.)
  Если нет, то проверяем, вдруг кто-то из вражеских пехотинцев может достать до нашего лучника, если да, то нападаем.
  Иначе считается суммарная сила вражеских стреляющих юнитов, которые могут достать до любого нашего юнита,
  а также суммарная сила всех юнитов врага, если отношение первого показателя ко второму больше 0.6, то тактика - наступающая, иначе:
  считаются аналогичные показатели для дружественных юнитов, и если их отношение больше 0.6, то тактика - оборонительная, иначе наступающая. ]]

  local targets, offence = {}

  for i = 1, table.getn( enemies ) do
    if enemies[i].attacks.n > 0 then
      offence = true
      --table.insert(targets, enemies[i])
      break
    end
  end

  if mover.name == "barbarian2"
  or mover.spells.special_berserk
  or mover.spells.spell_berserker then offence = true end

  if offence == nil then
    offence = is_tactics_offencive( enemies, actors )
  end

  local actions = {}

  --[[ Действия при наступающей тактике:
    1. базовая атака (цель выбирается по наибольшей опасности либо из тех врагов, кого можно атаковать сейчас, либо если таких нет,
       из всех доступных врагов);
    2. пас (выбирается в том случае, когда выбранный враг на своём ходе атаковать никого из наших не сможет, и при этом
       атака по данному юниту будет с пенальти (т.е. пасовать смогут только лучники); если юнит уже пасовал, то на этом месте стоит
       оборона с очками равными 1 - тактика ведь наступающая, и оборона может выпасть только если атаковать некого и др. действий нет);
    3. (опционально, в случае, когда базовой атакой достать никого нельзя) атака пауна (ближайшего к врагу), напр. стены, всегда 20 очков. ]]

  --[[local function can_attack(act)
      for k,a in ipairs(enemies) do
          if Attack.act_equal(a,act) then return true end
      end
      return false
  end]]
  local can_attack = {}

  for k, act in ipairs( enemies ) do
    local max_duration = duration_effect( act, "spell_blind", 0 )
    max_duration = duration_effect( act, "effect_unconscious", max_duration )
    max_duration = duration_effect( act, "effect_sleep", max_duration )

    if max_duration > 1 then
      can_attack[ act.cell ] = false
    else
      can_attack[ act.cell ] = true
    end
  end

  local function hazard( act, atk, cache ) -- рассчитывает степень опасности этого врага, а точнее его привлекательность в качестве цели
    if cache ~= nil then
      if cache[ act.cell ] ~= nil then return unpack( cache[ act.cell ] ) end
    end

    local cd = atk.calc_damage( act )
    local dam = cd.damage
    local k = math.min( 1, act.totalhp / dam )^2 -- коэф-т на тот случай, когда у юнита здоровья мало, а урон большой - такого юнита надо выбирать в последнюю очередь

    if atk.name == "krugom" then
      local hit_count = 0
      local path = Attack.calc_path( mover, act )
      local cc = path[ table.getn( path ) - 1 ].cell

      for dir = 0, 5 do
        local c = Attack.cell_adjacent( cc, dir )

        if c ~= nil
        and Attack.cell_present( c )
        and Attack.cell_id( c ) ~= act.cell
        and Attack.act_enemy( c ) then
          hit_count = hit_count + 1
        end
      end

      k = k * ( hit_count * .5 )
    end

    local d = 1

    if mover.name ~= "orb"
    and not mover.thrower then
      d = 1 + Attack.cell_dist( act, mover ) * .3 -- более отдаленный враг считается менее опасным
    end

    local v = math.min( act.totalhp, dam ) / d -- результат пропорционален реальному причиняемому урону, на случай чтобы огненные атаки били юнитов уязвимых к огню, а ледяные - к холоду

    if act.thrower then v = 2 * v end

    if act.ap > 0 then v = v * 1.5 end -- юнит, который не ходил в этом раунде, более опасен

    if cd.units == 0
    or not cd.hitback then v = v * 2 end -- юнит не может ответить

    if Attack.act_belligerent( act ) ~= Attack.act_belligerent( act, nil ) then v = v / 100 end -- чтобы ИИ не бил своих же юнитов под гипнозом

    -- считаем кол-во туров, через которые этот юнит может атаковать наших
    local dists, distsK = {}, 0

    for i, ally in ipairs( actors ) do
      if Attack.act_ally( ally ) then
        local tours = 100

        if act.thrower then
          if act.ap > 0 then tours = 0 else tours = 1 end
        else
          tours = math.ceil( ( path_len( act, ally ) - act.ap ) / act.par( 'speed' ) )
          if tours < 0 then tours = 0 end
        end

        table.insert( dists, tours )
      end
    end

    table.sort( dists )

    for k,n in ipairs(dists) do
      distsK = distsK + ( 1 + 1. / ( 1 + n ) ) / k
    end

    v = v * distsK

    if not act.thrower
    and act.par( 'dismove' ) ~= 0 then v = v * .3 end -- понижающий коэф-т для пехоты в паутине

    if cache ~= nil then
      cache[ act.cell ] = { v, k }
    end

    return v, k
  end

  -- Подготовка различных данных, которые понадобятся позже
  local mindist2enemy = 1000

  for i, act in ipairs( enemies ) do
    mindist2enemy = math.min( mindist2enemy, path_len( mover, act ) )
  end

  local mintours2enemy = math.ceil( ( mindist2enemy - mover.ap ) / mover.par( 'speed' ) )

  local allies_power, enemies_power = 0, 0

  for i, act in ipairs( actors ) do
    if Attack.act_ally( act ) then
      allies_power = allies_power + act.leadship * act.units
    elseif Attack.act_enemy( act ) then
      enemies_power = enemies_power + act.leadship * act.units
    end
  end

  local can_attack_enemy = false
  local mover_atks, target = mover.atks
  local mover_power = mover.leadship * mover.units

  -- I didn't know any other way to do this, since the Throw Axe ability doesn't show when the Furious Goblin
  -- is adjacent to an enemy. So by disabling their Run ability (and then re-enabling later) I can then see (by
  -- inference) if their Throw Axe ability is available. If so, then set the thrower flag true so that the
  -- "thrower" logic can move the Goblin away to use its Throw Axe ability.
  if mover.name == "goblin2" then
    if not Attack.act_is_spell( mover, "effect_stun" )
    and mover.ap > 0 then
      if Attack.act_need_charge_or_reload( mover ) then
        Attack.act_enable_attack( mover, "run", false )
  
        if not Attack.act_need_charge_or_reload( mover ) then
          mover.thrower = true
        end
  
        Attack.act_enable_attack( mover, "run", true )
      else  -- if here then Throw Axe is available so set true to use "thrower" logic
        mover.thrower = true
      end
    end
  end

  local function mego_check( c )
    return c ~= nil
    and Attack.cell_present( c )
    and Attack.cell_is_pass( c )
    and ( Attack.cell_id( c ) == mover.cell
    or (Attack.cell_is_empty( c )
    and path_len( mover, c ) < mover.ap ) )
  end

  local function act_under_attack( act )
    for i, en in ipairs( actors ) do -- проверяем, может ли враг атаковать данного юнита
      if Attack.act_enemy( en ) then
        local en_atks_base = en.atks.base

        if en_atks_base ~= nil then
          for i = 1, en_atks_base.targets.n do
            if en_atks_base.targets[i].cell == act.cell then -- может
              return true
            end
          end
        end
      end
    end
  end

  local wait_or_not = 1

  if enemies_power / allies_power < 0.8 or Game.Random( 99 ) < 60 then wait_or_not = 0 end -- враг слабее - не ждем

  if offence then
    if mover_atks.base ~= nil then
      local hazard_cache, possible_targets, cellfrom = {}, {}

      for i = 1, mover_atks.base.targets.n do -- ищем наиболее опасную цель
        local act = mover_atks.base.targets[i]

        if ( can_attack[ act.cell] ) then
          if tostring( act.cell ) == mover.sdata.pref_target then target = act; break end

          -- Мишень --
          if act.spells.spell_target then
            for i = 1,act.spells.n do
              if act.spells[ i ].name == "spell_target" then
                if mover.level <= tonumber( act.spells[ i ].lvl ) then return { target=act, attack="base" } end
                break
              end
            end
          end
          ------------
          local pr, pr2, from = math.ceil( hazard( act, mover_atks.base, hazard_cache ) * 10 ), 0

          if mover_atks.base.long2 then -- определяем сторону с которой бить лучше всего
            for dir = 0,5 do
              local en = Attack.cell_adjacent( act, dir )

              if en ~= nil
              and Attack.cell_present( en )
              and Attack.act_enemy( en ) then
                local c = Attack.cell_adjacent( act, math.mod( dir + 3, 6 ) )

                if mego_check( c ) then -- атака с данной клетки возможна
                  local p = math.ceil( hazard( Attack.get_caa( en, true ), mover_atks.base, hazard_cache) * 10 )

                  if p > pr2 then -- враг более опасный
                    pr2 = p
                    from = c
                  end
                end
              end
            end

            if from == nil then -- врагов в округе нет - выбираем хотя бы направление, чтобы не попасть по своим
              local path = Attack.calc_path( mover, act )
              local basedir = path[ table.getn( path ) - 1 ].dir

              for dir = 0, 2 do
                for sign = -1, 1, 2 do
                  local d = math.mod( basedir + dir * sign + 6, 6 )
                  local c = Attack.cell_adjacent( act, d )

                  if not ( c ~= nil and Attack.cell_present( c ) )
                  or not Attack.act_ally( c ) then
                    c = Attack.cell_adjacent( act, math.mod( d + 3, 6 ) )
                    if mego_check( c ) then
                      from = c
                      pr = math.ceil( pr / 2 )
                      break
                    end
                  end
                end

                if from ~= nil then break end
              end
            end

            if from == nil then -- не нашли направления, что бы не бить своего - уменьшаем вероятность атаки данного врага
              pr = 0 --math.ceil(pr / 3)
            end
          end

        		if pr > 0 then
	           if from ~= nil then -- драконы бьют цель всегда с наиболее выгодной стороны, т.е. сторона не рандомна
	             table.insert( possible_targets, { target = act, cellfrom = { cell = Attack.cell_id( from ) }, prob = 2 * pr + pr2 } )
	           else
	             table.insert( possible_targets, { target = act, prob = pr } )
	           end
	           
	           can_attack_enemy = true
	         end
        end
      end

      if target == nil
      and table.getn( possible_targets ) > 0 then
        local ch = random_choice( possible_targets )
        target = ch.target
        cellfrom = ch.cellfrom
      end

      if target ~= nil then -- есть цель для атаки в этот ход
        local cellatkfrom

        if not mover.thrower
        and mover.ap > 1
        and mover.par( 'speed' ) < 5
        and not mover_atks.longattack
        and -- пехотинцы должны потихоньку продвигаться к своим на доступные ОД, т.е. выбираем сторону с которой будем атаковать врага
          table.getn(possible_targets) == 1
        and target.units * target.leadship < mover_power then -- проверка простая - враг один (больше некого атаковать) и слабее mover'а.
          -- Идем к ближайшему врагу (это может быть настигший лучника пехотинец или же вражеский лучник), который может атаковать союзника ]]
          local dist, nearest = 1000

          for i, en in ipairs( enemies ) do
            local atk = en.atks.base

            if atk ~= nil
            and en.distance < dist
            and en.cell ~= target.cell then
              for i = 1,atk.targets.n do
                if ( en.thrower or atk.targets[ i ].cell ~= mover.cell )
                and Attack.act_ally( atk.targets[ i ] ) then -- если враг - лучник, то наличие союзника не обязательно
                  dist = en.distance
                  nearest = en
                  break
                end
              end
            end
          end

          if nearest ~= nil then -- есть куда стремиться - теперь смотрим, какая клетка вокруг выбранного врага (target) ближе всего к nearest
            dist = 1000

            for dir = 0, 5 do
              local c = Attack.cell_adjacent( target, dir )

              if mego_check( c ) then
                local len_to_nearest = path_len( c, nearest )

                if len_to_nearest < dist then
                  if Attack.cell_id( c ) ~= mover.cell then cellatkfrom = c else cellatkfrom = nil end
                  dist = len_to_nearest
                end
              end
            end
          end
        end

        if cellatkfrom ~= nil then
          table.insert( actions, { target = { cell = Attack.cell_id( cellatkfrom ) }, prob=2000 } ) -- let's go!
        elseif cellfrom ~= nil
        and cellfrom.cell ~= mover.cell then -- откуда бить
          table.insert( actions, { target = cellfrom, next = { target = target, attack = "base" }, prob = 100 } )
        else
          table.insert( actions, { target = target, prob = 100, attack = "base" } )
        end
      else
        -- атаковать в этот ход никого не можем - есть смысл пасовать, но вначале считаем кол-во врагов, которые ещё могут походить перед нашим ходом
        if mover.can_pass then
          local total_enemies, canmove_enemies = 0, 0

          for i, en in ipairs( actors ) do
            if Attack.act_enemy( en ) then
              if en.ap > 0
              and en.par( 'initiative' ) < mover.par( 'initiative' ) then canmove_enemies = canmove_enemies + 1 end -- проверка на инициативу нужна на случай, когда этот враг уже пасанул, что бы нашему юниту не передавался ход сразу после паса

              total_enemies = total_enemies + 1
            end
          end

          if canmove_enemies > 0 then
            table.insert( actions, { target = 1, prob = wait_or_not * math.floor( 50 + 200 * canmove_enemies / total_enemies ) } )
          end
        end

        local max_hazard = -1
        local first_target

        for i, act in ipairs( enemies ) do -- ищем ближайшего врага, но такого, чтобы до него можно было дойти
          local h = hazard( act, mover_atks.base, hazard_cache )
          local accessible = Attack.calc_path( mover, act ) ~= nil

          if target ~= nil then
            if accessible and h > max_hazard then max_hazard = h; target = act end
          elseif accessible then
            max_hazard = h; target = act
          else -- target == nil and not accessible
            if h > max_hazard then max_hazard = h; first_target = act end
          end
        end

        if target ~= nil then
          -- begin Рушим стенки
          local min_dist, pawn_target = path_len( mover, target )

          for i = 0, Attack.cell_count() - 1 do
            local c = Attack.cell_get( i )
            local cell = { cell = Attack.cell_id( c ) }

            if Attack.act_pawn( c )
            and Attack.act_takesdmg( c ) then
              local d = path_len( mover, c )
                        + math.ceil( Attack.act_totalhp( c ) / mover_atks.base.calc_damage( cell ).damage ) * mover.par( 'speed' )
                        + path_len( c, target )
              if d < min_dist then
                pawn_target = cell
                min_dist = d
              end
            end
          end

          if pawn_target ~= nil then target = pawn_target end
          -- end
          local action = { target = target, prob = 50 }

          if pawn_target ~= nil then -- проверяем, можно ли стенку ударить сразу (т.е. к ней не нужно идти)
            for i = 1,mover_atks.base.targets.n do
              if mover_atks.base.targets[ i ].cell == target.cell then
                action.attack = "base"
                break
              end
            end
          end

          if mover_atks.run ~= nil
          and mover.ap < 8
          and action.attack == nil
          and mover.par( 'dismove' ) == 0 then
            local path = Attack.calc_path( mover, target )

            if path ~= nil
            and path[ mover.ap + 1 ] ~= nil then
              action.attack = "run"
              action.next = { target = { cell = path[ mover.ap + 1 ].id } }
            end
          end

          table.insert( actions, action )

        elseif first_target ~= nil then -- дойти ни до кого нельзя - смотрим, вдруг дорогу преграждает паун и его можно атаковать
          local mind, nearest_pawn = 1e10

          for i = 1, mover_atks.base.targets.n do -- ищем среди возможных целей базовой атаки пауна, ближайшего к первой найденной цели (first_target)
            local act = mover_atks.base.targets[ i ]

            if Attack.act_pawn(act) then
              local d = Attack.cell_dist( act, first_target )

              if d < mind then mind = d; nearest_pawn = act end
            end
          end

          if nearest_pawn ~= nil then
            table.insert(actions, {target=nearest_pawn, prob=20, attack="base"})
          else -- пауна нет, идём к первой цели как можем (вдруг дорогу к врагам преграждают союзные юниты или преграждает паун, но пока атаковать его мы не можем)
            table.insert(actions, {target=first_target, prob=50})
          end
        end

        if target ~= nil then
          -- проверяем, возможно на пути есть енергетик, взяв который мы сможем дойти до выбранной цели за такое же, либо за меньшее кол-во ОД
          local max_profit, min_mover_b_len, best_bonus = -1, 1e10

          for i = 0, Attack.cell_count() - 1 do
            local cell = Attack.cell_get( i )
            local b = Attack.cell_bonus( cell )

            if b ~= nil
            and Attack.cell_is_empty( cell )
            and Attack.cell_is_pass( cell ) then
              local ap = Attack.val_restore( b, "ap" )
              local mover_b_len = path_len( mover, b )
              local profit = path_len( mover, target ) - ( mover_b_len - ap + path_len( b, target ) )

              if profit >= 0
              and ( mover_b_len < min_mover_b_len
              or ( mover_b_len == min_mover_b_len
              and profit > max_profit ) ) then
                max_profit = profit
                min_mover_b_len = mover_b_len
                best_bonus = cell
              end
            end
          end

          if best_bonus ~= nil then
            table.insert( actions, { target = { cell = Attack.cell_id( best_bonus ) }, prob = 250 * ( max_profit + 1 ) } )
          end
        end
      end

      if mover.can_pass
      and target ~= nil then -- пас
        local prob = 0

        if mover.thrower
        and mover_atks.base ~= nil
        and Attack.cell_dist( mover, target ) > mover_atks.base.distance
        and mover_atks.base.penalty < 1
        and not act_under_attack( mover )
        and target.ap > 0
        and target.par( 'initiative' ) <= mover.par( 'initiative' ) then -- последние 2 проверки чтобы исключить бестолковые пропуски, когда этот же лучник будет ходить сразу после пропуска
          local can_attack_ally = false

          for name, atk in pairs( target.atks ) do -- смотрим, может ли выбранная цель атаковать кого-либо из наших
            for i = 1, atk.targets.n do
              if Attack.act_ally( atk.targets[ i ] ) then can_attack_ally = true; break end
            end

            if can_attack_ally then break end
          end

          if not can_attack_ally then
            prob = 1000
          end
        end

        table.insert( actions, { target = 1, prob = wait_or_not * prob } )
      else
        table.insert( actions, { target = 0, prob = 0 } ) -- экшн с prob=0 нужен на тот случай, когда больше действий нет
      end
    end
  else
  --[[ При оборонительной тактике основное действие - оборона ]]
    table.insert( actions, { target = 0, prob = 100 } )
  end

  mover.sdata.pref_target = ""

  local function use_mass_ability( no_spell, check_func )
    local power = 0

    for i, act in ipairs( actors ) do
      if not act.spells[ no_spell ]
      and check_func( act ) then
        power = power + act.leadship * act.units
      end
    end

    local pr = ( .5 - mover_power / ( mover_power + power ) ) * 200

    if Game.Random( 99 ) < pr then return mover end
  end

  --[[ Доп. действия. Всегда добавляем к основным:
    1. использование спец. абилок (коэффициент (?) для бонусных абилок на своих (лечение, воскрешение) и статусных на врагов
       берётся двойной при оборонительной тактике и 0.5 при наступательной);
    2. подбирание ящиков;
    3. наступание на энергетики;
    4. лучники должны отходить от врагов и из пелены. ]]

  for name, atk in pairs( mover_atks ) do
    if name ~= 'base' then -- спецатаки
      local offencive_attack, prob, target = false, 1000

      -- This function is from Armored Princess
      local function set_random_target()
        local possible_targets = {}

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          if can_attack[ act.cell ] then table.insert( possible_targets, act ) end
        end

        if table.getn( possible_targets ) >= 1 then
          target = possible_targets[ Game.CurLocRand( 1, table.getn( possible_targets ) ) ]
        end
      end

      if name == "cure" then -- лечение
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local profit = math.min( act.par( 'health' ) - act.hp, h ) / h

          if profit > maxprofit then maxprofit = profit; target = act; end
        end

        prob = math.floor( maxprofit^2 * 1000 )

      elseif name == "cure2" then -- лечение
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]

          if Attack.act_race( act, "undead" )
          and Attack.act_enemy( act ) then
            local h2 = h * 2
            local power = math.min( act.totalhp, h2 ) / math.max( act.totalhp, h2 )

            if power > maxprofit then
              maxprofit = power
              target = act
            end
          else
            local profit = math.min( act.par( 'health' ) - act.hp, h ) / h

            if profit > maxprofit then maxprofit = profit; target = act; end
          end
        end

        prob = math.floor( maxprofit^2 * 1000 )

      elseif name == "cast_sacrifice" then
        local min_dist, nearest, nearest_act = 1000

        for i, act in ipairs( actors ) do
          if Attack.act_ally( act )
          and Attack.act_feature( act, "plant" )
          and ( act.level > 3
          or ( act.level < 4
          and not Attack.act_temporary( act ) ) ) then
            local dist = Attack.cell_dist( mover, act )

            if dist < min_dist then
              local path = Attack.calc_path( mover, act )

              if path ~= nil then
                min_dist = dist
                nearest = path
                nearest_act = act
              end
            end
          end
        end

        if nearest ~= nil then
          local need_ap = table.getn( nearest ) - 2
          prob = 100000

          if mover.ap - 1 >= need_ap then -- ОД и так достаточно, бег можно не юзать
            local pos = math.min( mover.ap, need_ap + 1 )
            if pos <= 1 then
              target = nearest_act
            else
              table.insert( actions, { target = { cell = nearest[ pos ].id }, prob = prob } )
            end

          else
            table.insert( actions, { target = { cell = nearest[ mover.ap + 1 ].id }, prob = prob } )
          end
        end

      elseif name == "respawn" then -- воскрешение
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local profit = math.min( act.par( 'health' ) * act.initial_units - act.totalhp, h ) / h

          if profit > maxprofit then maxprofit = profit; target = act; end
        end

        prob = math.floor( maxprofit^2 * 1000 )

      elseif name == "resurrect" then -- возрождение феникса - всегда юзаем
        target = mover

      elseif name == "split" then -- разделение грифонов
        if mover.units > 1
        and mover.par( 'autofight' ) == 0 then
          for i, act in ipairs( enemies ) do
            if act.thrower
            and act.distance <= mover.par( 'speed' ) + 1 then -- проверяем, достаем ли до лучников (делимся только рядом с ними)
              local path = Attack.calc_path( mover, act )

              if path ~= nil
              and table.getn( path ) - 1 <= mover.par( 'speed' ) + 1 then
                if Attack.cell_is_empty( path[ 2 ].cell )
                and Attack.cell_is_pass( path[ 2 ].cell )
                and path_len( path[ 2 ].cell, act ) <= mover.par( 'speed' ) then -- проверяем, сможет ли новый отряд достать до врага
                  target = { cell = path[ 2 ].id }
                  break
                else
                  for i = 0, 5 do
                    local c = Attack.cell_adjacent( mover, i )

                    if  c ~= nil
                    and Attack.cell_present( c )
                    and Attack.cell_is_empty( c )
                    and Attack.cell_is_pass( c )
                    and path_len( c, act ) <= mover.par('speed') then
                      target = { cell = Attack.cell_id( c ) }
                      break
                    end
                  end
                end
              end
            end
          end
        end

      elseif name == "web" then
        local possible_targets = {}
        local mover_speed = math.max( 1, mover.par( 'speed' ) )

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local act_speed = act.par( 'speed' )
          local act_power = act.leadship * act.units
          local chance = Game.Random( 99 )

          if not act.spells.special_spider_web
          and not act.spells.spell_blind
          and not act.spells.special_rooted
          and not act.spells.effect_entangle
          and not act.spells.effect_sleep
          and not act.spells.effect_unconscious
          and chance < ( act_speed / mover_speed * 50 )
          and chance < ( act_power / mover_power * 50 ) then
            local pr = ( act_speed / mover_speed + act_power / mover_power ) * 1000
            table.insert( possible_targets, { target = act, prob = pr } )
          end
        end

        if table.getn( possible_targets ) > 0 then
          local choice = random_choice( possible_targets )
          target = choice.target
          prob = choice.prob
        end

      elseif name == "haste" then
        if mintours2enemy > 1 then target = mover end

      elseif name == "entangle" then
        local possible_targets = {}

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]

          for j, act2 in ipairs( actors ) do
            if Attack.act_ally( act2 ) then
              local distance2closestenemy = path_len( act2, act )
              local shortestdistance2enemy = act.par( 'speed' )
    
              if distance2closestenemy < shortestdistance2enemy then
                local max_duration = duration_effect( act, "spell_blind", 0 )
                max_duration = duration_effect( act, "special_rooted", max_duration )
                max_duration = duration_effect( act, "effect_entangle", max_duration )
                max_duration = duration_effect( act, "effect_unconscious", max_duration )
                max_duration = duration_effect( act, "effect_sleep", max_duration )
                max_duration = duration_effect( act, "effect_spider_web", max_duration )

                if max_duration <= 1 then
                  local pr = ( act.leadship * act.units ) / mover_power * 1000 / shortestdistance2enemy
                  table.insert( possible_targets, { target = act, prob = pr } )
                end
              end
            end
          end
        end

        if table.getn( possible_targets ) > 0 then
          local choice = random_choice( possible_targets )
          target = choice.target
          prob = choice.prob
        end


      elseif name == "cast_thorn"
      or name == "cast_bear"
      or name == "cast_demon"
      or string.find( name, "summonplant" ) then  -- New! Summon Plant
        local pr = 70 + mover_power / allies_power * 30

        if name == "cast_demon" then -- юзаем только, если рядом враг
          pr = 0
          for dir = 0, 5 do
            local c = Attack.cell_adjacent( mover, dir )
            if c ~= nil
            and Attack.cell_present( c )
            and Attack.act_enemy( c ) then
              pr = 30 + mover_power / allies_power * 70
              break
            end
          end
        end

        if string.find( mover.name, "ent" )
        or string.find( mover.name, "thorn" ) then
          pr = 100
        end

        if atk.cells.n >= 1 then
          if Game.Random( 99 ) < pr then
            if string.find( mover.name, "ent" )
            or string.find( mover.name, "thorn" ) then
              prob = 100000
            end

            target = atk.cells[ Game.Random( 1, atk.cells.n ) ]
          end

        else
          local min_dist, nearest, nearest_cell = 1000

          for i = 0, Attack.cell_count() - 1 do
            local cell = Attack.cell_get( i )
            if Attack.cell_is_empty( cell ) then
              if Attack.cell_has_ally_corpse( cell )
              or Attack.cell_has_enemy_corpse( cell ) then
                local dist = Attack.cell_dist( mover, cell )
                if dist < min_dist then
                  local path = Attack.calc_path( mover, cell )
                  if path ~= nil then
                    min_dist = dist
                    nearest = path
                    nearest_cell = cell
                  end
                end
              end
            end
          end

          if nearest ~= nil then
            local need_ap = table.getn( nearest ) - 2

            if mover.ap - 1 >= need_ap then -- ОД и так достаточно, бег можно не юзать
              local pos = math.min( mover.ap, need_ap + 1 )
              if pos > 1 then
                prob = 100000
                table.insert( actions, { target = { cell = nearest[ pos ].id }, prob = prob } )
              end
            end
          end
        end

      elseif name == "attack_spell"
      or name == "gulp" then -- книга зла
        set_random_target()

      elseif name == "gibe" then -- насмешка
        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local base_atk = act.atks.base

          if base_atk ~= nil then
            local can_atk = false
            for i = 1, base_atk.targets.n do
              if base_atk.targets[ i ].cell == mover.cell then
                can_atk = true
                break
              end
            end

            if not can_atk then
              target = act
              prob = 300
              break
            end
          end
        end

      elseif name == "dominator" then -- доминатор глаза недоброго
        local leadship = 0

        for i = 1, atk.targets.n do -- берем под контроль самого крутого врага
          local act = atk.targets[ i ]
          local base_atk = act.atks.base
          if base_atk ~= nil
          and act.leadship*act.units > leadship then
            for i, en in ipairs( actors ) do -- проверяем, может ли act достать до кого-нить из врагов
              if Attack.act_enemy( en )
              and en.cell ~= act.cell
              and ( ( act.thrower and Attack.cell_dist( act, en ) <= base_atk.distance )
              or ( not act.thrower and path_len( act, en ) <= act.ap ) ) then
                leadship = act.leadship*act.units
                target = act
                break
              end
            end
          end
        end

      elseif name == "beast_training" then -- дрессировка
        local leadship = 0

        for i = 1, atk.targets.n do -- берем под контроль самого крутого врага
          local act = atk.targets[ i ]
          if act.leadship * act.units > leadship then
            leadship = act.leadship * act.units
            target = act
          end
        end

      elseif name == "transform" then -- трансформация
        if mover.par('autofight')==0 then
          local newSpeed = tonumber( Attack.atom_getpar( Attack.atom_getpar( mover.name, "transformto" ), "speed" ) )

          if newSpeed > mover.par_base( "speed" ) then -- сейчас юнит в медленной форме
            if mindist2enemy > mover.ap then -- достать до врага не можем => трансформируемся
              target = mover
              prob = 75
            end

          else
            if mindist2enemy <= newSpeed - mover.par_base("speed") + mover.ap then -- если перейдем в медленную форму и всё равно сможем достать до врага, то трансформируемся
              target = mover
              prob = 150
            end
          end
        end

      elseif name == "bless"
      or name == "holy_rage"
      or name == "magic_shield"
      or name == "dispell"
      or name == "amalgamation"
      or name == "stupid" then -- 5 in 1 !!!!
        local possible_targets = {}

        for i = 1,atk.targets.n do -- смотрим всех, на кого можем накастать
          local act, power, threshold = atk.targets[ i ], 0, 30

          if name == "bless"
          or name == "holy_rage" then
            local act_atks_base = act.atks.base

            if Attack.act_enemy( act ) then -- undead
              power = 1 -- юзаем редко
              threshold = 40
            elseif not act.spells.spell_bless
            and not act.spells.special_holy_rage
            and act.leadship * act.units > allies_power / 4.
            and act_atks_base ~= nil then
              for i = 1,act_atks_base.targets.n do
                if Attack.act_enemy( act_atks_base.targets[ i ] ) then -- этот юнит может атаковать врага - ему нужно благославление
                  power = 2
                  break
                end
              end
            end

          elseif name == "magic_shield" then -- шилд
            if act_under_attack( act ) then power = 2 end

          elseif name == "dispell" then
            local bonus_spells = takeoff_spells( act, "bonus", true )
            local penalty_spells = takeoff_spells( act, "penalty", true )
            if ( Attack.act_ally( act )
            and not bonus_spells
            and penalty_spells ) -- только когда нет бонусных спелов (а то снимем) и есть плохие (чтобы снять)
            or ( Attack.act_enemy( act )
            and bonus_spells
            and not penalty_spells ) then -- для врага - наоборот
              power = 2
            end

          elseif name == "amalgamation" then -- дрессировка
            if Attack.act_enemy( act )
            and act.level <= tonumber( atk.custom_params.level )
            and not Attack.act_feature( act, "golem" ) then
              power = power + act.leadship * act.units / 1e3
              threshold = 0

              if Attack.act_is_spell( act, "spell_ram" ) then
                power = power / 3
                threshold = threshold + 10
              end

              if Attack.act_is_spell( act, "spell_blind" ) then
                power = power / 3
                threshold = threshold + 10
              end

              if Attack.act_is_spell( act, "spell_pygmy" ) then
                threshold = threshold + 10

                if Attack.act_feature( act, "eyeless" ) then
                  power = 0
                  threshold = 100
                else
                  power = power / 3
                end
              end

              if Attack.act_is_spell( act, "spell_blind" )
              and Attack.act_is_spell( act, "spell_pygmy" ) then
                if Attack.act_feature( act, "plant" )
                or Attack.act_feature( act, "undead" ) then
                  power = 0
                  threshold = 100
                end
              end
            end

          elseif name == "stupid" then
            for t in pairs( act.atks ) do -- просто считаем кол-во спец.атак
              if t ~= "base" then power = power + 1 end
            end

            threshold = 20
          end

          local pr = math.floor( ( .5 - mover_power / ( mover_power + power * act.leadship * act.units ) ) * 200 )

          if pr >= threshold then
            table.insert( possible_targets, { target = act, prob = pr } )
          end
        end

        if table.getn( possible_targets ) > 0 then
          local choice = random_choice( possible_targets )
          target = choice.target
          prob = 5 * choice.prob
        end

      elseif name == "greediness" then -- teleport to box
        if not can_attack_enemy then
          local mintours = mintours2enemy

          for i, c in ipairs( atk.cells ) do
            for i, act in ipairs( enemies ) do
              local d = math.ceil( ( path_len( c, act ) - 1 ) / mover.par( 'speed' ) ) -- 1 вместо mover.ap, т.к. после применения спец.абилки останется всего 1 ОД
              if d < mintours then mintours = d; target = c end
            end
          end
        end

      elseif name == "quake" then -- giant
        local enemies, near_enemies, min_dist, nearest = 0, 0, 1e6

        if can_attack_enemy then near_enemies = -1 end -- не считаем врага, кот. можем атаковать сейчас. напр. если рядом 2 врага, но одного можно атаковать обычной атакой, quake не юзаем, но если врагов будет трое, пусть даже атаковать можно их всех, quake будет вызван

        for i, act in ipairs( actors ) do
          if Attack.act_enemy( act )
          and Attack.act_mt( act ) == 0 then
            enemies = enemies + 1
            local dist = Attack.cell_dist( mover, act )
            --if dist <= 10 then
            near_enemies = near_enemies + 1
            --end
            if dist < min_dist then
              local path = Attack.calc_path( mover, act )

              if path ~= nil then
                min_dist = dist
                nearest = path
              end
            end
          end
        end

        prob = 100000

        if near_enemies / enemies > .6 then -- более 60% врагов близко расположены к гиганту
          if nearest ~= nil then
            local need_ap = table.getn( nearest ) - 2

            if mover.ap - 1 >= need_ap
            or mover_atks.run == nil then -- ОД и так достаточно, бег можно не юзать
              local pos = math.min( mover.ap, need_ap + 1 )

              if pos <= 1 then
                target = mover -- стоим где надо
              else
                table.insert( actions, { target = { cell = nearest[ pos ].id }, prob = prob } )
              end -- подходим к врагу
            else
              table.insert( actions, { target = mover, prob = prob, attack = "run" } )
            end
          end
        end

        offencive_attack = true

      elseif name == "gcry" then -- ghost
        local enemies = 0

        for i,act in ipairs( actors ) do
          if check_ghost_cry( act, tonumber( atk.custom_params.dist ) )
          and not Attack.act_feature( act,"mind_immunitet,undead" )
          and Attack.act_enemy( act ) then
            enemies = enemies + 1
            if enemies == 2 then -- есть 2 врага под ударом - воем!
              target = mover
              break
            end
          end
        end

        offencive_attack = true

      elseif name == "cry" then -- wolf
        target = use_mass_ability( 'effect_fear', check_wolf_cry )

      elseif name == "cast_sleep" then -- dryad
        target = use_mass_ability( 'effect_sleep', function( act ) return check_cast_sleep( act, tonumber( atk.custom_params.level ), atk.custom_params.nfeatures ) end )

      elseif name == "elf_song" then -- dryad
        target = use_mass_ability( 'special_elf_song', function( act ) return Attack.act_ally( act ) and Attack.act_race( act ) == "elf" end )

      elseif name == "battle_mage" then -- транс
        if can_attack_enemy
        and Game.Random( 99 ) < 70 then
          target = mover
        end

      elseif name == "berserk"
      or name == "ogre_rage"
      or name == "preparation" then
        if can_attack_enemy then
          target = mover
        end

      elseif name == "reload" then -- у ента
        if not can_attack_enemy
        and Attack.act_need_charge_or_reload( mover ) then
          target = mover
        end

      elseif name == "rooted" then -- у ента
        if Attack.act_need_cure( mover )
        or Attack.cell_need_resurrect( mover ) then
          target = mover
          prob = 1000 * allies_power / enemies_power

          if Attack.act_is_spell( mover, "effect_burn" ) then
            prob = prob * 5
          end
        end


      elseif name == "protective_totem"
      or name == "ice_totem"
      or name == "blood" then -- shaman/demoness
        local cell_ranks = {}
        local belcheck

        if name == "ice_totem" then belcheck = Attack.act_enemy else belcheck = Attack.act_ally end

        for i,act in ipairs(actors) do
          if belcheck( act )
          and act.level < 5
          and ( name ~= "blood"
          or Attack.act_race( act ) == "demon" )
          and not Attack.act_pawn( act )
          and ( act.cell == mover.cell
          or act.thrower
          or act.par( 'speed' ) <= 2 ) then -- тотемы ставим только вокруг лучников либо медленных пехотинцев
            cell_ranks[ act.cell ] = tonum( cell_ranks[ act.cell ] ) + 3 -- на случай, когда пентаграмму можно будет установить прямо под юнит

            for dir1 = 0, 5 do
              local c1 = Attack.cell_adjacent( act, dir1 )
              if c1 ~= nil
              and Attack.cell_present( c1 ) then
                local id = Attack.cell_id( c1 )
                cell_ranks[ id ] = tonum( cell_ranks[ id ] ) + 2 -- ранг близлежащих клеток увеличиваем на 2,..

                if name ~= "blood" then -- у пентаграммы радиус - 1
                  for dir2 = 0, 1 do
                    local c = Attack.cell_adjacent( c1, math.mod( dir1 + dir2, 6 ) )
                    if c ~= nil
                    and Attack.cell_present( c ) then
                      id = Attack.cell_id( c )
                      cell_ranks[ id ] = tonum( cell_ranks[ id ] ) + 1 -- ..а отдаленных - на 1
                    end
                  end
                end
              end
            end
          end
        end

        local max_rank = 3 -- ставить тотем будем только в клетку, ранг которой более 3

        for i = 1, atk.cells.n do
          local rank = cell_ranks[ atk.cells[ i ].cell ]

          if tonum( rank ) > max_rank then
            max_rank = rank
            target = atk.cells[ i ]
          end
        end

      elseif name == "animate_dead" then
        for i = 1, atk.cells.n do
          local act = Attack.cell_get_corpse( atk.cells[ i ] )
          local unit_animate = necro_get_unit( actor_name( act ), Attack.act_initsize( act ), mover_power * ( text_range_dec( atk.custom_params.k ) ) / 100 ) -- проверок на фичи можно не делать, т.к. мы смотрим только доступные клетки
          local undead_lead = Attack.atom_getpar( unit_animate, "leadership" )
          -- сколько можно поднять по лидерству
          local animate_count_lead = math.floor( mover_power / undead_lead * ( text_range_dec( atk.custom_params.k ) ) / 100 )
          -- реально
          local animate_real = math.min( animate_count_lead, Attack.act_initsize( act ) )
          if animate_real / animate_count_lead > .9 then -- воскрешаем первый попавшийся подходящий труп
            target = atk.cells[ i ]
            break
          end
        end

      elseif name == "plague" then --
        local enemy_rank = 0

        for i, act in ipairs( actors ) do
          local haseffect = not Attack.act_feature( act, atk.custom_params.nfeatures )
                            and not act.spells.spell_plague

          if Attack.act_enemy( act ) then
            if haseffect then enemy_rank = enemy_rank + act.leadship * act.units end

          elseif Attack.act_ally( act ) then -- нельзя своих заражать чумой
            if haseffect then
              enemy_rank = 0
              break
            end
          end
        end

        local pr = ( .5 - mover_power / ( mover_power + enemy_rank ) ) * 200

        if Game.Random( 99 ) < pr then target = mover end

      elseif name == "poison_cloud"
      or name == "gain_mana" then -- bone/green dragon
        local enemies = 0

        for dir = 0, 5 do
          local c = Attack.cell_adjacent( mover, dir )

          if c ~= nil
          and Attack.cell_present( c ) then
            if name == "poison_cloud"
            and Attack.act_ally( c ) then -- своих не бьём!
              enemies = 0
              break
            end

            if Attack.act_enemy( c ) then
              enemies = enemies + 1
            end
          end
        end

        if enemies >= 2
        and atk.targets.n > 0 then
          target = mover
        end

        offencive_attack = true

      elseif name == "fire_shot" then -- imps
        local max_targets = -1

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]

          if can_attack[ act.cell ] then
            local targets = 0

            for dir = 0, 5 do
              local c = Attack.cell_adjacent( act, dir )

              if c ~= nil
              and Attack.cell_present( c )
              and Attack.get_caa( c ) ~= nil then
                targets = targets + 1
              end
            end

            if targets > max_targets then max_targets = targets; target = act end
          end
        end

        prob = 10000
        offencive_attack = true

      elseif name == "change" then -- archdemon
        -- менять юнитов местами имеет смысл, если после этого пехота сможет достать до врага
        for i = 1, atk.targets.n do
          local a = atk.targets[ i ]

          if not a.thrower
          and Attack.act_ally( a ) then -- выбираем первую цель
            local a_base = a.atks.base

            if a_base ~= nil
            and a_base.targets.n == 0 then -- этот союзник не может никого атаковать
              -- проверяем, вдруг после перестановки, юнит сможет кого-нить достать
              for tt = 1, atk.targets.n do -- выбираем вторую
                local t_base = atk.targets[ tt ].atks.base

                if t_base ~= nil
                and Attack.act_enemy( atk.targets[ tt ] )
                and atk.targets[ tt ].thrower then -- переставляем только врага лучника
                  local tcell = atk.targets[ tt ].cell -- клетка с возможно новым положением юнита a
                  
                  for ii, t in ipairs( actors ) do
                    if tcell ~= t.cell
                    and Attack.act_enemy( t )
                    and path_len( atk.targets[ tt ], t ) <= a.par( 'speed' ) then -- исключаем самого перемещаемого врага
                      mover.sdata.target = tcell
                      target = a
                      break
                    end
                  end

                  if target ~= nil then break end
                end
              end

              if target ~= nil then break end
            end
          end
        end

      elseif name == "rail" then -- red dragon
        local best_h, hhache, from, tar = 0

        for i, en in ipairs( enemies ) do
          for dir = 0, 5 do
            local c = Attack.cell_adjacent( en, dir )
            local dist, cfrom = 0

            for i = 0, Attack.trace( c, dir ) - 1 do
              local c = Attack.trace( i )

              if c ~= nil
              and Attack.cell_present( c )
              and Attack.act_ally( c )
              and Attack.cell_id( c ) ~= mover.cell then break end

              if mego_check( c ) then -- можем встать в эту клетку
                dist = i
                cfrom = c
              end
            end

            if cfrom ~= nil then
              local sumh, sumk, ecount = 0, 0, 0

              for i = 0, Attack.trace( en, math.mod( dir + 3, 6 ) ) - 1 do
                local t = Attack.trace( i )

                if Attack.act_ally( t ) then -- своих бить - плохо
                  sumk = sumk - 3
                elseif Attack.act_enemy( t ) then
                  local caa = Attack.get_caa( t, true )
                  if caa ~= nil then
                    local h, k = hazard( caa, atk, hhache )
                    sumh = sumh + h
                    sumk = sumk + k
                    ecount = ecount + 1
                  end
                end
              end

              if ( ecount > 1
              and sumk > .9 )
              or ecount == table.getn( enemies ) then -- чтобы зря не тратить атаку, когда это не нужно (напр. из доступных врагов только те, где в стеке 1 юнит с 1 hp)
                -- Считаем, на сколько клеток можно отлететь от первого врага вдоль данной прямой
                sumh = sumh * ( 1 + dist *.1 )

                if sumh > best_h then
                  best_h = sumh
                  from = cfrom
                  tar = en
                end
              end
            end
          end
        end

        if tar ~= nil then
          if from ~= nil
          and Attack.cell_id( from ) ~= mover.cell then
            table.insert( actions, { target = { cell = Attack.cell_id( from ) }, next = { target = tar, attack = name }, prob = prob } )
          else
            target = tar
          end
        end

        offencive_attack = true

      elseif name == "firepower" then -- black dragon
        local best_h, hhache = 0

        for i, c in ipairs( atk.cells ) do
          local sumh, sumk, ecount = 0, 0, 0
          local path = Attack.calc_path( mover, c )

          for i = 2, table.getn( path ) - 1 do
            local t = path[ i ].cell

            if Attack.act_ally( t ) then -- своих бить - плохо
              sumk = sumk - 3
            elseif Attack.act_enemy( t ) then
              local caa = Attack.get_caa( t, true )

              if caa ~= nil then
                local h, k = hazard( caa, atk, hhache )
                sumh = sumh + h
                sumk = sumk + k
                ecount = ecount + 1
              end
            end
          end

          if ( ecount > 1
          and sumk > .9 )
          or ecount == table.getn( enemies ) then -- чтобы зря не тратить атаку, когда это не нужно (напр. из доступных врагов только те, где в стеке 1 юнит с 1 hp)
            sumh = sumh * ( table.getn( path ) - 1 ) / mover.ap -- чем длиннее путь, тем лучше

            if sumh > best_h then
              best_h = sumh
              target = c
            end
          end
        end

        offencive_attack = true

      elseif name == "charge" then -- NEW! Horsemen Charge! (based on the ability "take" from Armored Princess)
        if not can_attack_enemy then
          set_random_target() -- просто берем случайную цель
        end

        offencive_attack = true

      elseif name == "throw_axe" then
        local possible_targets = {}

        for i, act in ipairs( enemies ) do
          if atk.applicable( act ) then
            local dist = Attack.cell_dist( mover, act )

            if dist <= atk.distance then
              local act_power = act.leadship * act.units
              local pr = act_power / mover_power * 1000
              table.insert( possible_targets, { target = act, prob = pr } )
            end
          end
        end

        if table.getn( possible_targets ) > 0 then
          local choice = random_choice( possible_targets )
          target = choice.target
          prob = choice.prob
          offencive_attack = true
        else
          local possible_cells = {}

          for i, act in ipairs( enemies ) do
            if atk.applicable( act ) then
              local dist = Attack.cell_dist( mover, act )
        
              if dist - mover.ap < atk.distance then
                local path = Attack.calc_path( mover, act )

                if path ~= nil then
                  local cell = path[ atk.distance - ( dist - mover.ap ) ].cell

                  if cell ~= nil then
                    local act_power = act.leadship * act.units
                    local pr = act_power / mover_power * 1000
                    table.insert( possible_cells, { target = cell, prob = pr, act = act } )
                  end
                end
              end
            end
          end
          
          if table.getn( possible_cells ) > 0 then
            local choice = random_choice( possible_cells )
            local cell = choice.target
            local pr = choice.prob
            local act = choice.act
            table.insert( actions, { target = { cell = Attack.cell_id( cell ) }, next = { target = act, attack = name }, prob = pr } )
          else
            for i, act in ipairs( enemies ) do
              if atk.applicable( act ) then
                local act_power = act.leadship * act.units
                local pr = act_power / mover_power * 500
                table.insert( possible_targets, { target = act, prob = pr } )
              end
            end

            if table.getn( possible_targets ) > 0 then
              local choice = random_choice( possible_targets )
              target = choice.target
              prob = choice.prob
              offencive_attack = true
            end
          end
        end

      elseif atk.dmgmax > 0 then -- эта атака - боевая
        offencive_attack = true
        local max_hazard = -1

        for i = 1, atk.targets.n do
          local act = atk.targets[i]
          if can_attack[ act.cell ]
          and ( atk.class ~= "throw"
          or not ( atk.penalty < 1
          and Attack.cell_dist( mover,act ) > atk.distance ) ) then -- второе условие нужно, чтобы throw-спецатаки не использовались когда цель слишком далеко
            local h, k = hazard( act, atk )
            
            if h > max_hazard then max_hazard = h; target = act; prob = math.floor( 1000 * k ) end
          end
        end

        if ( name == "longattack"
        or name == "capture" )
        and target == nil then -- достать никого не можем - смотрим, вдруг можно дойти до клетки, откуда сможем заюзать атаку
          local best_c, best_tar

          for i, act in ipairs( enemies ) do
            if atk.applicable( act )
            and ( name ~= "capture"
            or act.par( 'dismove' ) == 0 ) then
              local h, k = hazard( act, atk )

              if h > max_hazard
              and ( name ~= "capture"
              or k > .9 ) then -- вторая проверка, чтобы просто так не лететь в клетку, если атака не имеет смысла
                for dir = 0, 5 do
                  local c = Attack.cell_adjacent( act, dir )
  
                  if c ~= nil
                  and Attack.cell_present( c )
                  and ( Attack.cell_is_empty( c )
                  or Attack.cell_id( c ) == mover.cell )
                  and Attack.cell_is_pass( c ) then
                    c = Attack.cell_adjacent( c, dir )
  
                    if mego_check( c ) then
                      best_c = c
                      best_tar = act
                      max_hazard = h
                      break
                    end
                  end
                end
              end
            end
          end

          if best_c ~= nil then
            table.insert( actions, { target = { cell = Attack.cell_id( best_c ) }, next = { target = best_tar, attack = name }, prob = 1000 } )
          end
        end
      end

      if target ~= nil then
        if mover.name == "archmage"
        and ( mover_power > allies_power / 5.
        or mover_power > enemies_power / 5.) then
          if name == "magic_shield" then
            target = nil
          elseif name == "battle_mage" then
            prob = 30
          end

        elseif string.find( mover.name, "priest" )
        and ( mover_power > allies_power / 4.
        or mover_power > enemies_power / 4.) then
          if name == "holy_rage"
          or name == "bless" then
            target = nil
          end
        end
      end

      if target ~= nil
      and ( offencive_attack
      or not ( mover.spells.effect_charm
      or mover.par( 'autofight' ) > 0 ) ) then -- вторая проверка - чтобы зачарованные юниты юзали только боевые спец.атаки, а то начнут входить в транс или кастать на себя бафы
        table.insert( actions, { target = target, prob = prob, attack = name } )
      end
    end
  end

  if mover.thrower then -- уходим от врагов
    local penalty_cells = {} -- id клеток, в которых лучше не стоять

    for i = 1, Attack.act_count() - 1 do
      if Attack.act_size( i ) > 0
      and Attack.val_restore( i, "bonus" ) == "0" then -- это плохой тотем
        local ally = Attack.val_restore( i, "ally" )
        local bel = Attack.val_restore( i, "belligerent" )
        local param = Attack.val_restore( i, "param" )

        if ( ally == nil
        or ally == ""
        or ally == "-1"
        or ( ally == "1"
        and Attack.act_ally( mover, bel ) )
        or ( ally == "0"
        and Attack.act_enemy( mover, bel ) ) )
        and ( param ~= "throw"
        or Attack.act_has_throw_attacks( mover ) )
        and ( param ~= "speed"
        or mover.par_base( "speed" ) > 1 )
        and totem_applicable( mover, i ) then
          local function mark_neighbours( i, d )
            penalty_cells[ Attack.cell_id( i ) ] = true

            if d > 0 then
              for dir = 0, 5 do
                local c = Attack.cell_adjacent( i, dir )

                if c ~= nil
                and Attack.cell_present( c ) then
                  mark_neighbours( c, d - 1 )
                end
              end
            end
          end

          mark_neighbours( Attack.get_cell( i ), tonumber( Attack.val_restore( i, "dist" ) ) )
        end
      end
    end

      --[[ мультипараметрическое сравнение:
          1: если рядом с клеткой, в которой стоим, врагов нет, то: 0 - клетка рядом с врагом, 1 - рядом врагов нет (чтобы ненароком не встать в клетку рядом с врагом), иначе: 1 - рядом врагов нет и расстояние до клетки меньше mover.ap (второе условие нужно для юнитов, у которых 1 ОД - без него они будут постоянно убегать от пехоты, никогда не атакуя, а также для юнитов, у которых нет штрафа ближнего боя), в противном случае - 0
          2: 0 - в пелене, 1 - нет
          3: 0 - c.distance >= mover.ap (чтобы дойти до клетки нужно потратить все ОД), 1 - иначе
          4: target == nil => всегда 0, иначе = min(0, Attack.cell_dist(c, target) - optimal_dist), где optimal_dist - оптимальная дистанция для данного лучника, - это условие нужно чтобы лучники отходили подальше от цели
          5: target == nil => всегда 0, иначе = min(0, optimal_dist - Attack.cell_dist(c, target)) - а это, чтобы подходили ближе на расстояние без пенальти
          6: сумма расстояний до всех вражеских пехотинцев ]]

    local function multi_cmp( a, b )
      for i = 1, table.getn( a ) do
        if a[ i ] ~= b[ i ] then return a[ i ] - b[ i ] end
      end

      return 0
    end

    local optimal_dist = mover_atks.base.distance
    local best_v, farthest, enemy_near_mover

    for i = 0, ecells.n do
      local c = ecells[ i ]

      if c == nil then c = mover; c.distance = 0 end -- проверяем также клетку, где мы стоим - вдруг идти никуда и не нужно - и здесь хорошо

      local v, enemy_near = { 1, 1, 1, 0, 0, 0 }

      for dir = 0, 5 do
        local a = Attack.cell_adjacent( c, dir )
        if a ~= nil
        and Attack.cell_present( a )
        and Attack.act_enemy( a ) then
          if i == 0 then enemy_near_mover = true end

          enemy_near = true
          break
        end
      end

      if enemy_near_mover then
        if enemy_near
        or c.distance >= mover.ap then v[ 1 ] = 0 end -- чтобы уходить от врага, не тратя все ОД
      else
        if enemy_near then v[ 1 ] = 0 end
      end

      if penalty_cells[ c.cell ] then v[ 2 ] = 0 end

      if c.distance >= mover.ap then v[ 3 ] = 0 end

      if target ~= nil
      and optimal_dist > 1 then
        local c_to_target = Attack.cell_dist( c, target )
        v[ 4 ] = math.min( 0, c_to_target - optimal_dist )
        v[ 5 ] = math.min( 0, optimal_dist - c_to_target )
      end

      -- находим сумму расстояний до всех вражеских пехотинцев
      for k, act in ipairs( actors ) do
        if not act.thrower
        and Attack.act_enemy( act ) then
          v[ 6 ] = v[ 6 ] + Attack.cell_dist( c, act )
        end
      end

      if farthest == nil
      or multi_cmp( v, best_v ) > 0 then -- клетка либо первая, либо по условиям лучше, чем та, что была выбрана
        best_v = v
        farthest = c
      end
    end

    if farthest ~= nil
    and farthest.cell ~= mover.cell then -- если выбранная клетка - та, где мы стоим, то идти никуда не нужно
      table.insert( actions, { target = farthest, prob = 500, escape_action = true } )
    end
  end

  -- Рандомно выбираем действие из составленного списка согласно очкам (действие с большим кол-вом очков более вероятно)
  local res = random_choice( actions )

  if res.escape_action
  and target ~= nil then -- сомнительная штука, нужна чтобы при подбегании лучника, когда вдруг вновь выбранная цель не совпадает с той, к которой шёл лучник, была выбрана первоначальная цель
    mover.sdata.pref_target = target.cell
  end

  -- Ящики
  if res.attack == nil
  and res.next == nil
  and type( res.target ) == "table"
  and mover_atks.base ~= nil
  and mover_power < allies_power / 5.
  and not mover.thrower then -- если идем пешком, смотрим нельзя ли по пути собрать ящик
    local cc, boxes = mover_atks.base.cells, {}

    for i = 1, cc.n do
      if Attack.cell_is_box( cc[ i ] ) then table.insert( boxes, cc[ i ] ) end
    end

    if table.getn( boxes ) > 0 then -- some box detected!
      local path = Attack.calc_path( mover, res.target )

      if path == nil then -- идти некуда
        if Game.Random( 99 ) < 70 then
          return { target = boxes[ Game.Random( 1, table.getn( boxes ) ) ], attack = "base" }
        end
      else
        local refcell = path[ math.min( table.getn( path ), mover.ap + 1 ) ].cell -- клетка, до которой можем дойти
        local mindist, nearest_b = 1000

        for i, b in ipairs( boxes ) do
          local dist = Attack.cell_dist( refcell, b )
          if dist < mindist then
            mindist = dist
            nearest_b = b
          end
        end

        if nearest_b ~= nil
        and Game.Random( 99 ) < ( 100 - mindist * 20 ) then
          return { target = nearest_b, attack = "base" }
        end
      end
    end
  end

  return res
end


function ally_enemy_midpoint()
  local cx, cy, actcnt = 0, 0, 0

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i )
    or Attack.act_ally( i ) then
      local x, y = Attack.act_get_center( i )
      cx = cx + x
      cy = cy + y
      actcnt = actcnt + 1
    end
  end

  if actcnt > 0 then
    return Attack.find_nearest_cell( cx / actcnt, cy / actcnt )
  else
    return Attack.cell_id( 0 )
  end
end


function spell_auto_cast( spells, spellattacks )
--[[
Аргументы:
    spells - ассоциативный список доступных (на которые хватает маны) спелов в форме имя_спела=уровень
    spellattacks - массив атак спелов
        .avcells([first_target]) - возвращает массив доступных клеток для данного спела, если задан first_target, то спел считается двустепенным, а first_target задает первую цель
        .applicable(actor) - true, если спел можно применить на данную цель
]]
  local ehero_level, spell_level = get_enemy_hero_stuff()
  local ehero_max_mana = Logic.enemy_lu_item( "mana", "limit" )
  local ehero_mana = Logic.enemy_lu_item( "mana", "count" )
  local ignore_mana = true

  if ehero_max_mana ~= nil
  and ehero_mana ~= nil then
    if ehero_mana / ehero_max_mana < 0.33 then
      ignore_mana = false
    end
  end

  if ehero_level > 0 then
    if enemy_hero_name == "" then
      enemy_hero_name = Attack.hero_name()

      if enemy_hero_name == nil
      or enemy_hero_name == "" then
        enemy_hero_name = "Your enemy"
      end

      local enemy_hero_book_times = tonum( Logic.enemy_lu_var( "book_times" ) )
      
      if enemy_hero_book_times ~= nil
      and enemy_hero_book_times > 1 then
        local adjective = ""
      
        if enemy_hero_book_times == 2 then
          adjective = "extremely"
        elseif enemy_hero_book_times > 2 then
          adjective = "sensationally"
        end
      
        Attack.log( "enemy_hero_book_times_log", "hero_name", enemy_hero_name, "special2", adjective, "special", enemy_hero_book_times )
      end
    end
  end

  for name, level in pairs( spells ) do
    if spell_level ~= nil then
      if spells[ name ] < spell_level then
        spells[ name ] = spell_level
      end
    else
      spell_level = level
      break
    end
  end

  if next( spells ) == nil then
    return
  end  -- список спелов пуст

  -- Формируем списки врагов и своих в удобной форме
  local actors, allies, enemies = {}, {}, {}
  local nomag_immune_allies, nomag_immune_enemies = 0, 0
  local allies_power, enemies_power = 0, 0
  local under_attack_units, can_attack_units = {}, {}
  local avg_ally_init, avg_enemy_init = 0, 0

  for i = 1, Attack.act_count() - 1 do
    local ally = Attack.act_ally( i )

    if ally
    or Attack.act_enemy( i ) then
      local act = Attack.get_caa( i, true )
      table.insert( actors, act )
      local nomag_immune = not Attack.act_feature( act, "magic_immunitet" )
      local init = Attack.act_get_par( i, "initiative" )

      if ally then
        table.insert( allies, act )
        if nomag_immune then nomag_immune_allies = nomag_immune_allies + 1 end
        allies_power = allies_power + act.leadship * act.units
        avg_ally_init = avg_ally_init + init

      else
        table.insert( enemies, act )
        if nomag_immune then nomag_immune_enemies = nomag_immune_enemies + 1 end
        enemies_power = enemies_power + act.leadship * act.units
        avg_enemy_init = avg_enemy_init + init
      end

      local base = act.atks.base

      if base ~= nil then
        if base.targets.n > 0 then
          local max_duration = duration_effect( act, "spell_blind", 0 )
          max_duration = duration_effect( act, "effect_unconscious", max_duration )
          max_duration = duration_effect( act, "effect_sleep", max_duration )
       
          if max_duration > 1 then
            can_attack_units[ act.cell ] = false
          else
            can_attack_units[ act.cell ] = true
          end
        end

        for i = 1, base.targets.n do
          under_attack_units[ base.targets[ i ].cell ] = true
        end
      end
    end
  end

  avg_ally_init = avg_ally_init / table.getn( allies )
  avg_enemy_init = avg_enemy_init / table.getn( enemies )
  local a2e = limit_value( allies_power / enemies_power, 0.1, 10 )
  local e2a = limit_value( enemies_power / allies_power, 0.1, 10 )
--  local min_score = math.ceil( math.max( allies_power, enemies_power ) / 100 )
  local min_score = 0

  -- Рандомно выбираем 7 спелов для использования
  local spellsToUse = {}

  for name, level in pairs( spells ) do -- вначале собираем все спелы в массив
    table.insert( spellsToUse, name )
  end

  local ehero_max_spells = tonumber( Game.Config( 'ehero_max_spells' ) )

  while table.getn( spellsToUse ) > ehero_max_spells do -- удаляем по одному спелу до тех пор, пока их будет не больше 7-х
    spells[ table.remove( spellsToUse, Game.Random( 1, table.getn( spellsToUse ) ) ) ] = nil
  end
  -- spellsToUse = {}

  -- Формируем атаки для спелов, если они не заданы
  if spellattacks == nil then
    spellattacks = {}
    for name, level in pairs( spells ) do
      spellattacks[ name ] = Attack.build_spell_attack( name, level )
    end
  end

  local cast = {}

  local function common_damage_score( value, res, act, factor )
    if value == 0 then
      return 0
    end

    local eff = math.min( 1, act.totalhp / ( value * res ) )
    local kill = value * res / ( act.totalhp / act.units )
    local score = eff * value * res * factor * kill * act.level / 5

    return score
  end

  local function atk_common_score( act )
    local atk_power = 0

    for name, atk in pairs( act.atks ) do
      if name ~= nil then
        if atk.dmgavg ~= 0 then
          atk_power = atk_power + act.units * atk.dmgavg * act.level * atk.targets.n
        else
          atk_power = atk_power + act.units * act.level * atk.targets.n
        end
      end
    end

    return atk_power
  end

  local function common_score( act, factor )
    local lead_power = act.leadship * act.units
    local hp_power = act.totalhp
    local atk_power = atk_common_score( act )
    local power = 0

    if atk_power > 0 then
      power = ( lead_power + hp_power + atk_power ) / 3
    else
      power = ( lead_power + hp_power ) / 2
    end

    power = power / lead_power * 500 * factor

    return power 
  end

  local function unit_score( act )
    local lead_power = act.leadship * act.units
    local hp_power = act.totalhp
    local atk_power = atk_common_score( act )
    local power = lead_power + hp_power + atk_power

    return power 
  end

  local function common_spell_7_in_1( applicable, spell_name, spell_level, ehero_level, res_type )
    local cells_rating = {}

    for i = 0, Attack.cell_count() - 1 do
      local cell = Attack.cell_get( i )
      local k, k2 = 0, 0
      local res
      local min_dmg, max_dmg, chance, duration, chance2
      if spell_name == "spell_fire_rain" then
        min_dmg, max_dmg, chance, duration = pwr_fire_rain( spell_level, ehero_level )
        chance2 = chance
      elseif spell_name == "spell_fire_ball" then
        min_dmg, max_dmg, chance, duration = pwr_fire_ball( "epicentre", spell_level, ehero_level )
        chance2 = chance
      elseif spell_name == "spell_ice_serpent" then
        min_dmg, max_dmg, chance, duration = pwr_ice_serpent( "epicentre", spell_level, ehero_level )
        chance2 = 0
      end

      local id = Attack.cell_id( cell )

      if cell ~= nil
      and applicable( cell ) then
        res = ( 100 - Attack.act_get_res( cell, res_type ) ) / 100

        if Attack.act_ally( cell ) then
          k = -( min_dmg + max_dmg ) / 2 * ( 1 + chance2 / 100 * duration )
          k2 = -1
        else
          k = ( min_dmg + max_dmg ) / 2 * ( 1 + chance2 / 100 * duration )
          k2 = 1
        end

        local act = Attack.get_caa( cell, true )
        local score = common_damage_score( k, res, act, e2a )
        local effect_score = k2 * common_score( act, e2a ) * ( chance - ( 100 - res * 100 ) ) / 100 * duration
        score = score + effect_score

        if Attack.act_feature( act, "pawn" ) then
          score = score / 10;
        end

        cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
      end

      for dir = 0, 5 do
        local c = Attack.cell_adjacent( cell, dir )

        if c ~= nil
        and applicable( c ) then
          res = ( 100 - Attack.act_get_res( c, res_type ) ) / 100

          if spell_name == "spell_fire_ball" then
            min_dmg, max_dmg, chance, duration = pwr_fire_ball( "periphery", spell_level, ehero_level )
            chance2 = chance
          elseif spell_name == "spell_ice_serpent" then
            min_dmg, max_dmg, chance, duration = pwr_ice_serpent( "periphery", spell_level, ehero_level )
            chance2 = 0
          end

          if Attack.act_ally( c ) then
            k = -( min_dmg + max_dmg ) / 2 * ( 1 + chance2 / 100 * duration )
            k2 = -1
          else
            k = ( min_dmg + max_dmg ) / 2 * ( 1 + chance2 / 100 * duration )
            k2 = 1
          end

          local act = Attack.get_caa( c, true )
          local score = common_damage_score( k, res, act, e2a )
          local effect_score = k2 * common_score( act, e2a ) * ( chance - ( 100 - res * 100 ) ) / 100 * duration
          score = score + effect_score

          if Attack.act_feature( act, "pawn" ) then
            score = score / 10;
          end

          cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
        end
      end
    end

    local max_rating, tid = 0

    for id, rating in pairs( cells_rating ) do
      if rating > max_rating then tid = id; max_rating = rating end
    end

    return tid, max_rating
  end

  local function common_spell_mana( spell_name, spell_level, ignore_mana, value )
    if ignore_mana then
      value = math.ceil( value )
    else
     	local mana = tonumber( text_dec( Logic.obj_par( spell_name, "mana_cost" ), spell_level ) )
      value = math.ceil( value / mana )
    end

    return value
  end

  -- Проверка однотипных спелов (огн.шар и огн.дождь)
  if spells.spell_fire_rain then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_fire_rain.applicable, "spell_fire_rain", spells.spell_fire_rain, ehero_level, "fire" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_fire_rain", spells.spell_fire_rain, ignore_mana, max_rating )
      table.insert( cast, { spell = "spell_fire_rain", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_fire_ball then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_fire_ball.applicable, "spell_fire_ball", spells.spell_fire_ball, ehero_level, "fire" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_fire_ball", spells.spell_fire_ball, ignore_mana, max_rating )
      table.insert( cast, { spell = "spell_fire_ball", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_ice_serpent then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_ice_serpent.applicable, "spell_ice_serpent", spells.spell_ice_serpent, ehero_level, "physical" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_ice_serpent", spells.spell_ice_serpent, ignore_mana, max_rating )
      table.insert( cast, { spell = "spell_ice_serpent", target = { cell = tid }, prob = max_rating } )
    end
  end

  local function ck_canatk_thrower( act )
    return can_attack_units[ act.cell ]
    and Attack.act_is_thrower( act )
    and Attack.act_enemy( act )
    and Attack.act_name( act ) ~= "ram"
  end

  if spells.spell_shroud then
    local cells_rating = {}

    for i = 0, Attack.cell_count() - 1 do
      local cell = Attack.cell_get( i )
      local id = Attack.cell_id( cell )

      if cell ~= nil
      and spellattacks.spell_shroud.applicable( cell ) then
        local act = Attack.get_caa( cell, true )

        if act ~= nil then
          if ck_canatk_thrower( act )
          and not Attack.act_is_spell( act, "totem_shroud" ) then
            local unit_power = common_score( act, e2a )
            local spell_power = pwr_shroud( spells.spell_shroud, ehero_level )
            local duration = int_dur( "spell_shroud", spells.spell_shroud )
            local score = unit_power * ( spell_power + 100 ) / 100 * duration
            cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
          end
        end
      end

      for dir = 0, 5 do
        local c = Attack.cell_adjacent( cell, dir )

        if c ~= nil
        and spellattacks.spell_shroud.applicable( c ) then
          local act = Attack.get_caa( c, true )

          if act ~= nil then
            if ck_canatk_thrower( act )
            and not Attack.act_is_spell( act, "totem_shroud" ) then
              local unit_power = common_score( act, e2a )
              local spell_power = pwr_shroud( spells.spell_shroud, ehero_level )
              local duration = int_dur( "spell_shroud", spells.spell_shroud )
              local score = unit_power * ( spell_power + 100 ) / 100 * duration
              cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
            end
          end
        end
        
      end
    end

    local max_rating, tid = 0

    for id, rating in pairs( cells_rating ) do
      if rating > max_rating then tid = id; max_rating = rating end
    end

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_shroud", spells.spell_shroud, ignore_mana, max_rating )
      table.insert( cast, { spell = "spell_shroud", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_pain_mirror then
    local applicable = spellattacks.spell_pain_mirror.applicable
    local max_score, tid = min_score

    for i, act in ipairs( actors ) do
      if applicable( act )
      and Attack.act_enemy( act ) then
        local last_dmg = tonum( Attack.val_restore( act, "last_dmg" ) ) * pwr_pain_mirror( spells.spell_pain_mirror, ehero_level ) / 100

        if last_dmg > 0 then
          local dt_index = Attack.val_restore( act, "damage_type_index" )

          if dt_index ~= nil then
            local str_resistances = Game.Config( 'resistances' )
            local sub_string = text_dec( str_resistances, dt_index + 1 )
            local res = ( 100 - Attack.act_get_res( act, sub_string ) ) / 100
            local score = common_damage_score( last_dmg, res, act, e2a )
  
            if score > max_score then
              max_score = score
              tid = act.cell
            end
          end
        end
      end
    end

    if max_score > min_score
    and tid ~= nil then
      max_score = common_spell_mana( "spell_pain_mirror", spells.spell_pain_mirror, ignore_mana, max_score )
      table.insert( cast, { spell = "spell_pain_mirror", target = { cell = tid }, prob = max_score } )
    end
  end

  if spells.spell_lightning then
    local applicable = spellattacks.spell_lightning.applicable
 	  local min_dmg, max_dmg, shock, hits, duration = pwr_lightning( spells.spell_lightning, ehero_level )
    local max_score = min_score
    local tid

    for i, act in ipairs( enemies ) do
      if applicable( act ) then
        local res = ( 100 - Attack.act_get_res( act, "magic" ) ) / 100
        local avg_dmg = ( min_dmg + max_dmg ) / 2
        local spell_power = common_damage_score( avg_dmg, res, act, e2a )
        local effect_score = common_score( act, e2a ) * ( shock - ( 100 - res * 100 ) ) / 100 * duration
        local score = spell_power + effect_score

        if Attack.act_feature( act, "pawn" ) then
          score = score / 10;
        end

        local count = hits
      	 local attacked_ids = {}
       	attacked_ids[ act.cell ] = true
      	 local front = { act }
      
       	repeat
      
         	if count == 0 then break end
      
         	count = count - 1
        		avg_dmg = avg_dmg * 0.5
      
        		local new_front = {}
        		-- Hit the front of the current units
        		for k, target in ipairs( front ) do
         			local mind, atkd = 1e10, {}
        	 		for j = 1, Attack.act_count() - 1 do
        		  		local d = Attack.cell_mdist( target, j )

        				  if d <= ( 4. * 1.8 + .1 )
              and applicable( j )
              and Attack.act_takesdmg( j )
        						and attacked_ids[ Attack.cell_id( Attack.get_cell( j ) ) ] == nil then
        					   if math.abs( mind - d ) < .1 then
                  table.insert( atkd, j )

        					   elseif d < mind then
                  mind = d
                  atkd = { j }
                end
        				  end
        		  end

        		  for j, act in ipairs( atkd ) do -- We attack those who have chosen
              res = ( 100 - Attack.act_get_res( act, "magic" ) ) / 100
              local unit = Attack.get_caa( Attack.get_cell( act ), true )

              if Attack.act_enemy( act ) then
                spell_power = common_damage_score( avg_dmg, res, unit, e2a )
              else
                spell_power = -common_damage_score( avg_dmg, res, unit, e2a )
              end

              effect_score = common_score( unit, e2a ) * ( shock - ( 100 - res * 100 ) ) / 100 * duration

              if Attack.act_feature( unit, "pawn" ) then
                effect_score = effect_score / 10;
                spell_power = spell_power / 10;
              end

              score = score + spell_power + effect_score
          				attacked_ids[ unit.cell ] = true
        		  		-- Form the next front
          				table.insert( new_front, unit )
        		 	end
        		end

        		front = new_front
      
       	until table.getn( front ) == 0

        if score > max_score then
          max_score = score
          tid = act.cell
        end
      end
    end

    max_score = common_spell_mana( "spell_lightning", spells.spell_lightning, ignore_mana, max_score )

    if tid ~= nil then
      table.insert( cast, { spell = "spell_lightning", target = { cell = tid }, prob = max_score } )
    end
  end

  -- Обработка накладываемых спелов (плохих и хороших)
  local function ck_none() return true end

  local function ck_underatk( act ) -- данного юнита могут атаковать
    return under_attack_units[ act.cell ]
  end

  local function ck_underatk_not_temporary( act ) -- данного юнита могут атаковать
    return under_attack_units[ act.cell ]
    and not Attack.act_temporary( act )
  end

  local function ck_canatk( act ) -- данный юнит может атаковать
    return can_attack_units[ act.cell ]
    and Attack.act_name( act ) ~= "ram"
  end

  local function ck_cantatk( act ) -- данный юнит не может атаковать
    return not can_attack_units[ act.cell ]
    and Attack.act_name(act) ~= "ram"
  end

  local function spell_feature_slayer( feature )
    for i, act in ipairs( actors ) do
      if Attack.act_enemy( act )
      and Attack.act_feature( act, feature ) then
        return true
      end
    end

    return false
  end

  local goodSpells = { 
    -- Haste now increases initiative and chance to krit
    spell_haste =
      function( a )
        return ( Attack.act_get_par( a, "initiative" ) < avg_enemy_init
        or ck_cantatk( a )
        or ( Game.Random( 99 ) < 20 ) )
        and not Attack.act_is_spell( a, "spell_haste" )
      end, 
    spell_divine_armor =
      function( a )
        return ck_underatk( a )
        and not Attack.act_is_spell( a, "spell_divine_armor" )
      end, 
    spell_stone_skin =
      function( a )
        return ck_underatk( a )
        and not Attack.act_is_spell( a, "spell_stone_skin" )
      end, 
    spell_pacifism =
      function( a )
        return ck_underatk( a )
        and not Attack.act_is_spell( a, "spell_pacifism" )
      end, 
    spell_berserker =
      function( a )
        return ck_canatk( a )
        and not Attack.act_is_spell( a, "spell_berserker" )
      end, 
    spell_fire_breath =
      function( a )
        return ck_canatk( a )
        and not Attack.act_is_spell( a, "spell_fire_breath" )
      end, 
    spell_magic_source =
      function( a )
        return ck_underatk( a )
        and not Attack.act_is_spell( a, "spell_magic_source" )
      end,
    spell_last_hero =
      function( a )
        return ck_underatk_not_temporary( a )
        and not Attack.act_is_spell( a, "spell_last_hero" )
      end,
    spell_bless =
      function( a )
        return ck_canatk( a )
        and Attack.act_leadership(a) * Attack.act_size(a) > allies_power / 4.
        and not Attack.act_is_spell( a, "spell_bless" )
      end,
    spell_adrenalin =
      function( a )
        if Attack.act_ap( a ) > 0 then return false end -- не кастаем на тех, кто еще не ходил

        if Attack.act_is_thrower( a ) then return true end

        local bel = Attack.act_belligerent( a )

        for dir = 0, 5 do -- кастаем на тех, кто сможет атаковать врага на 1 ОД
          local c = Attack.cell_adjacent( a, dir )
          if c ~= nil
          and Attack.cell_present( c )
          and Attack.act_enemy( c, bel ) then return true end
        end
        return false;
      end,
    spell_dispell =
      function( act )
        local bonus_spells = takeoff_spells( act, "bonus", true )
        local penalty_spells = takeoff_spells( act, "penalty", true )

        if text_dec( Logic.obj_par( "spell_dispell", "spell" ), spells.spell_dispell ) == "all" then
          return ( Attack.act_ally( act )
          and not bonus_spells
          and penalty_spells ) -- только когда нет бонусных спелов (а то снимем) и есть плохие (чтобы снять)
          or ( Attack.act_enemy( act )
          and bonus_spells
          and not penalty_spells ) -- для врага - наоборот
        else
          return ( Attack.act_ally( act )
          and penalty_spells )
          or ( Attack.act_enemy( act )
          and bonus_spells )
        end
      end,
    -- spell_reaction now increases morale - AI does not use morale
    spell_reaction = function( a ) return false end,
--    spell_reaction = function( a ) return Attack.act_get_par( a, "initiative" ) < avg_enemy_init end,
    spell_dragon_arrow =
      function ( a )
        return ck_canatk( a )
        and Attack.act_is_thrower( a )
        and Attack.act_feature( a, "archer" )
        and not Attack.act_is_spell( a, "spell_dragon_arrow" )
      end,
    spell_accuracy =
      function ( a )
        return ck_canatk( a )
        and Attack.act_is_thrower( a )
        and not Attack.act_is_spell( a, "spell_accuracy" )
      end,
    spell_gifts =
      function ( a )
        return Attack.act_need_charge_or_reload( a )
      end,
    spell_demon_slayer =
      function ( a )
        return spell_feature_slayer( "demon" )
        and not Attack.act_is_spell( a, "spell_demon_slayer" )
      end,
    spell_dragon_slayer =
      function ( a )
        return spell_feature_slayer( "dragon" )
        and not Attack.act_is_spell( a, "spell_dragon_slayer" )
      end
  }

  local badSpells  = {
    -- Slow now decreases initiative and susceptibility to krit
    spell_slow =
      function( a )
        return ( Attack.act_get_par( a, "initiative" ) > avg_enemy_init
        or ck_canatk( a )
        or ( Game.Random( 99 ) < 20 ) )
        and not Attack.act_is_spell( a, "spell_slow" )
      end,
    spell_pygmy =
      function( a )
        return ck_canatk( a )
        and not Attack.act_is_spell( a, "spell_pygmy" )
      end,
    spell_hypnosis =
      function( a )
        return ck_none
        and not Attack.act_is_spell( a, "spell_hypnosis" )
      end,
    spell_crue_fate =
      function( a )
        return ck_underatk( a )
        and not Attack.act_is_spell( a, "spell_crue_fate" )
      end,
		  spell_weakness =
      function( a )
     			return ck_canatk( a )
        and Attack.act_leadership( a ) * Attack.act_size( a ) > enemies_power / 4.
        and not Attack.act_is_spell( a, "spell_weakness" )
    		end,
  		spell_blind =
      function( a )
        return ck_canatk( a )
        and not Attack.act_is_spell( a, "spell_blind" )
      end,
    spell_ram =
      function( a )
        return ck_canatk( a )
        and not Attack.act_is_spell( a, "spell_ram" )
      end,
    spell_scare =
      function( a )
        return ck_canatk( a )
        and Attack.act_level( a ) < 3
        and not Attack.act_is_spell( a, "effect_fear" )
      end,
    spell_plague =
      function( a )
        return Attack.act_race( a ) ~= "undead"
        and ( ck_canatk( a )
        or ck_underatk( a ) )
        and not Attack.act_is_spell( a, "spell_plague" )
      end, -- т.к. чума снижает и атаку и защиту
    spell_magic_bondage =
      function( a )
        if a.atks == nil then a = Attack.get_caa( a, true ) end

        for name in pairs( a.atks ) do
          if name ~= "base"
          and not Attack.act_is_spell( a, "spell_magic_bondage" ) then return true end
        end

        return false
      end,
    spell_defenseless =
      function( a )
        return ck_underatk( a )
        and Attack.act_get_par( a, "defense" ) >= 5
        and not Attack.act_is_spell( a, "spell_defenseless" )
      end
  }

  local function pwr_spell( name, unit, level, ehero_level )
    local func_name = string.gsub( name, "^spell_", "pwr_" )
    local baseatk = unit.atks.base
    local k, gain = 0, 50

    if name == "spell_haste"
    or name == "spell_slow"
    or name == "spell_dragon_arrow" then
      local power = _G[ func_name ]( level, ehero_level )
      k = power * gain

    elseif name == "spell_pacifism" then
      local power, penalty = _G[ func_name ]( level, ehero_level )
      k = power - penalty / 2

    elseif name == "spell_berserker" then
      local unit_level, power = _G[ func_name ]( level, ehero_level )
      k = power

    elseif name == "spell_last_hero" then
      k = unit.level * gain

    elseif name == "spell_bless"
    or name == "spell_weakness" then
      if baseatk ~= nil then
        if name == "spell_bless" then
          k = baseatk.dmgmax / baseatk.dmgavg * gain
        else
          k = baseatk.dmgavg / baseatk.dmgmin * gain
        end

        if baseatk._3in1 then
          k = k * 3
        elseif baseatk.superhitback then
          k = k * 2
        elseif baseatk._6in1 then
          k = k * 6
        end
      end

    elseif name == "spell_reaction" then
      k = gain / 5 * avg_enemy_init / avg_ally_init

    elseif name == "spell_adrenalin" then
      if baseatk ~= nil then
        k = unit.level * baseatk.dmgavg

        if level == 3 then
          k = k + unit.level * gain
        end
      end

    elseif name == "spell_gifts"
    or name == "spell_blind"
    or name == "spell_magic_bondage"
    or name == "spell_hypnosis"
    or name == "spell_crue_fate"
    or name == "spell_ram" then
      k = unit.level * gain

    elseif name == "spell_scare" then
      k = ( 5 - unit.level ) * gain

    else
      local power = _G[ func_name ]( level, ehero_level )

      if name == "spell_divine_armor"
      or name == "spell_pygmy"
      or name == "spell_plague" then
        power = power * 4
      end

      k = power
    end

    return k
  end

  local powerSpells = { 
    spell_haste = pwr_spell, 
    spell_divine_armor = pwr_spell, 
    spell_stone_skin = pwr_spell, 
    spell_pacifism = pwr_spell, 
    spell_berserker = pwr_spell, 
    spell_fire_breath = pwr_spell, 
    spell_magic_source = pwr_spell,
    spell_last_hero = pwr_spell,
    spell_bless = pwr_spell,
    spell_adrenalin = pwr_spell,
    spell_reaction = pwr_spell,
    spell_dragon_arrow = pwr_spell,
    spell_accuracy = pwr_spell,
    spell_gifts = pwr_spell,
    spell_demon_slayer = pwr_spell,
    spell_dragon_slayer = pwr_spell,
    spell_slow = pwr_spell,
    spell_shroud = pwr_spell,
    spell_pygmy = pwr_spell,
    spell_hypnosis = pwr_spell,
    spell_crue_fate = pwr_spell,
		  spell_weakness = pwr_spell,
  		spell_blind = pwr_spell,
    spell_ram = pwr_spell,
    spell_scare = pwr_spell,
    spell_plague = pwr_spell,
    spell_magic_bondage = pwr_spell,
    spell_defenseless = pwr_spell
  }

  local function power_spell_dispell( c, power )
    local good_k, bad_k = 0, 0
    local good_spells, good_spells_list = takeoff_spells( c, "bonus", true )

    if good_spells then
      for k, v in ipairs( good_spells_list ) do
        if v == "spell_dragon_slayer"
        or v == "spell_demon_slayer"
        or v == "spell_divine_armor"
        or v == "spell_haste"
        or v == "spell_berserker"
        or v == "spell_invisibility"
        or v == "spell_phantom" then
          good_k = good_k + 3
    
        elseif v == "spell_stone_skin"
        or v == "spell_bless"
        or v == "spell_reaction"
        or v == "spell_magic_source" then
          good_k = good_k + 2
    
        else
          good_k = good_k + 1
        end
      end
    end

    local bad_spells, bad_spells_list = takeoff_spells( c, "penalty", true )

    if bad_spells then
      for k, v in ipairs( bad_spells_list ) do
        if v == "spell_pygmy"
        or v == "spell_blind"
        or v == "spell_plague"
        or v == "spell_magic_bondage"
        or v == "spell_crue_fate"
        or v == "spell_ram"
        or v == "spell_hypnosis"
        or v == "effect_shock"
        or v == "effect_poison"
        or v == "effect_burn"
        or v == "effect_sleep"
        or v == "effect_stun"
        or v == "effect_freeze"
        or v == "effect_charm"
        or v == "feat_rabid"
        or v == "effect_fear" then
          bad_k = bad_k + 3
    
        elseif v == "spell_scare"
        or v == "spell_weakness"
        or v == "effect_weakness"
        or v == "effect_curse"
        or v == "effect_holy"
        or v == "feat_bleeding" then
          bad_k = bad_k + 2
    
        else
          bad_k = bad_k + 1
        end
      end
    end

    if text_dec( Logic.obj_par( "spell_dispell", "spell" ), spells.spell_dispell ) == "all" then
      if Attack.act_ally( c ) then
        power = power * ( bad_k - good_k )
      else
        power = power * ( good_k - bad_k )
      end

    else
      if Attack.act_ally( c ) then
        power = power * bad_k
      else
        power = power * good_k
      end
    end

    return power
  end

  for name, level in pairs( spells ) do
    if goodSpells[ name ] or badSpells[ name ] then
      local check = goodSpells[ name ] -- функция проверки
      local good = true

      if check == nil then
        check = badSpells[ name ]
        good = false
      end

      local avcells = spellattacks[ name ].avcells()
      local no_power_value = 100

      if avcells.n > 0 then -- есть ли цели для каста
        local max_power, unit_power, target = 0, 0

        for i, c in ipairs( avcells ) do -- ищем самого сильного юнита,..
          if not Attack.act_is_spell( c, name )
          and check( c ) then -- ..на котором нет этого спела
            local unit = Attack.get_caa( c, true )
            local power = unit_score( unit )

            if name == "spell_dispell" then
              power = power_spell_dispell( c, power )
            end

            if power > max_power then
              max_power = power
              target = c

              if good then
                unit_power = common_score( unit, a2e )
              else
                unit_power = common_score( unit, e2a )
              end
            end
          end
        end

        if target ~= nil then
          local spell_power = no_power_value

          if powerSpells[ name ] then
            spell_power = powerSpells[ name ]( name, Attack.get_caa( target, true ), level, ehero_level )
          end

          local duration = int_dur( name, level )

          if duration == 0 then
            duration = 1
          end

          local prob = unit_power * ( spell_power + 100 ) / 100 * duration

          if prob > min_score then
            prob = common_spell_mana( name, level, ignore_mana, prob )
            table.insert( cast, { spell = name, target = target, prob = prob } )
          end
        end
      elseif text_dec( Logic.obj_par( name, "unit_count" ), level ) == "all" then -- значит спел действует на всех
        local applicable = spellattacks[ name ].applicable
        local k = 0
        local array = enemies
        local good = false

        if goodSpells[ name ] then
          array = allies
          good = true
        end

        for i, act in ipairs( array ) do -- считаем лидерство всех юнитов,..
          if not act.spells[ name ]
          and not Attack.act_is_spell( act, name )
          and applicable( act )
          and check( act ) then -- ..на которых нет этого спела и на которых можно наложить этот спелл
            local power = 0
            
            if good then
              power = common_score( act, a2e )
            else
              power = common_score( act, e2a )
            end

            local spell_power = no_power_value

            if powerSpells[ name ] then
              spell_power = powerSpells[ name ]( name, act, level, ehero_level )
            end

            k = k + power * ( spell_power + 100 ) / 100
          end
        end

        local duration = int_dur( name, level )
        local prob = k * duration

        if prob > min_score then
          prob = common_spell_mana( name, level, ignore_mana, prob )
          table.insert( cast, { spell = name, prob = prob } )
        end
      end
    end
  end

  -- Боевые спелы на одну цель
  local function score_def( c, name, level, ehero_level, e2a )
    local func_name = string.gsub( name, "^spell_", "pwr_" )
    local spell_power, effect_score, score, avg_dmg = 0, 0, 0, 0
    local act = Attack.get_caa( c, true )
    local res = ( 100 - Attack.act_get_res( c, Logic.obj_par( name, "typedmg" ) ) ) / 100

    if name == "spell_magic_axe" then
      local min_dmg, max_dmg = _G[ func_name ]( level, ehero_level )
      avg_dmg = ( min_dmg + max_dmg ) / 2
      spell_power = common_damage_score( avg_dmg, res, act, e2a )

    elseif name == "spell_ghost_sword" then
      local min_dmg, max_dmg, ignore_res = _G[ func_name ]( level, ehero_level )
      avg_dmg = ( min_dmg + max_dmg ) / 2
      res = ( 100 - Attack.act_get_res( c, Logic.obj_par( name, "typedmg" ) ) * ( 1 - ignore_res / 100 ) ) / 100
      spell_power = common_damage_score( avg_dmg, res, act, e2a )

    elseif name == "spell_oil_fog" then
      local min_dmg, max_dmg, duration, chance = _G[ func_name ]( level, ehero_level )
      avg_dmg = ( min_dmg + max_dmg ) / 2
      spell_power = common_damage_score( avg_dmg, res, act, e2a )
      effect_score = common_score( act, e2a ) * chance / 100 * duration

    else
      local min_dmg, max_dmg, chance, duration = _G[ func_name ]( level, ehero_level )
      avg_dmg = ( min_dmg + max_dmg ) / 2 * ( 1 + chance / 100 * duration )
      spell_power = common_damage_score( avg_dmg, res, act, e2a )
      effect_score = common_score( act, e2a ) * ( chance - ( 100 - res * 100 ) ) / 100 * duration
    end

    score = spell_power + effect_score

    if Attack.act_feature( act, "pawn" ) then
      score = score / 10;
    end

    return score
  end

  local battleSpells = {
    spell_magic_axe = score_def,
    spell_oil_fog = score_def,
    spell_ghost_sword = score_def,
    spell_fire_arrow = score_def,
    spell_smile_skull = score_def
  }

  for name, level in pairs( spells ) do
    if battleSpells[ name ] then
      local max_prob, tid = min_score
      local targets = {}
      for i, c in ipairs( spellattacks[ name ].avcells() ) do
        if Attack.act_enemy( c ) then
          local prob = battleSpells[ name ]( c, name, level, ehero_level, e2a )

          if prob > max_prob then
            max_prob = prob
            tid = c
          end
        end
      end

      if tid ~= nil then
        max_prob = common_spell_mana( name, level, ignore_mana, max_prob )
        table.insert( cast, { spell = name, target = tid, prob = max_prob } )
      end
    end
  end

  -- Призыв союзников
  local summonSpells = {
    spell_demonologist = ck_none,
    spell_evilbook = ck_none,
    spell_phoenix =
      function()
        for i = 1, Attack.act_count() - 1 do
          if string.sub( actor_name( i ), 1, 7 ) == "phoenix"
          and Attack.act_belligerent( i ) == Attack.act_belligerent() then return false end
        end
        return true
      end
  }

  local allyEnemyMidpoint

  for name, level in pairs( spells ) do
    if summonSpells[ name ]
    and summonSpells[ name ]() then
      if allyEnemyMidpoint == nil then -- рассчет точки, где будут рождаться союзники - она должна быть между нашими и врагами
        allyEnemyMidpoint = ally_enemy_midpoint()
      end

      local mindist, nearest = 1000
      for i, c in ipairs( spellattacks[ name ].avcells() ) do
        local dist = Attack.cell_dist( c, allyEnemyMidpoint )
        if dist < mindist then
          mindist = dist
          nearest = c
        end
      end

      if nearest ~= nil then
        local prob = 0

        if name == "spell_demonologist" then
          local lead = pwr_demonologist( level, ehero_level )
          prob = lead

        else
          local damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus, text = summon_bonus( nil, name, true )
          local hp

          -- This is kind of lame, but I don't know how to get their hp from the ATOM
          if name == "spell_phoenix" then
            hp = 200 * level

            if level == 3 then
              hp = hp + 200
            end
          elseif name == "spell_evilbook" then
            hp = 200 * level
          end

          prob = math.ceil( hp * ( level + 2 ) * ( 1 + hitpoint_bonus / 100 ) )
        end

        prob = prob * e2a

        if prob > min_score then
          prob = common_spell_mana( name, level, ignore_mana, prob )
          table.insert( cast, { spell = name, target = nearest, prob = prob } )
        end
      end
    end
  end

  -- Разное
  if spells.spell_healing then -- лечение
    local h = pwr_healing( spells.spell_healing, ehero_level )
    local maxprofit, target = 0

    for i, act in ipairs( spellattacks.spell_healing.avcells() ) do
      local profit = math.min( Attack.act_get_par( act, "health" ) - Attack.act_hp( act ), h ) / h

      if profit > maxprofit then maxprofit = profit; target = act; end
    end

    local prob = math.ceil( maxprofit^2 * 500 * a2e )
    prob = common_spell_mana( "spell_healing", spells.spell_healing, ignore_mana, prob )

    if maxprofit > .90 then table.insert( cast, { spell = "spell_healing", target = target, prob = prob } ) end
  end

  if spells.spell_resurrection then -- воскрешение
    local h = pwr_resurrection( spells.spell_resurrection, ehero_level )
    local maxprofit = 0

    for i, act in ipairs( spellattacks.spell_resurrection.avcells() ) do
      local profit = math.min( Attack.act_get_par( act, "health" ) * Attack.act_initsize( act ) - Attack.act_totalhp( act ), h ) / h

      if profit > maxprofit then maxprofit = profit; target = act; end
    end

    local prob = math.ceil( maxprofit^2 * 1000 * a2e )
    prob = common_spell_mana( "spell_resurrection", spells.spell_resurrection, ignore_mana, prob )

    if maxprofit > .90 then table.insert( cast, { spell = "spell_resurrection", target = target, prob = prob } ) end
  end

  if spells.spell_armageddon then
    local applicable = spellattacks.spell_armageddon.applicable
   	local min_dmg, max_dmg, burn, duration, prc = pwr_armageddon( spells.spell_armageddon, ehero_level )
    local avg_dmg = ( min_dmg + max_dmg ) / 2
    local score = 0

    for i, act in ipairs( actors ) do
      if applicable( act )
      and not Attack.act_feature( act, "magic_immunitet" ) then
        local res = ( 100 - Attack.act_get_res( act, "astral" ) ) / 100
        local spell_power = avg_dmg * ( 1 + burn / 100 * duration )
        local effect_score = common_score( act, e2a ) * ( burn - ( 100 - res * 100 ) ) / 100 * duration
        local act_score = 0

        if Attack.act_enemy( act ) then
          act_score = common_damage_score( spell_power, res, act, e2a ) + effect_score
        else
          act_score = -( common_damage_score( spell_power * prc / 100, res, act, e2a ) + effect_score )
        end

        if Attack.act_feature( act, "pawn" ) then
          act_score = act_score / 10;
        end

        score = score + act_score
      end
    end

    local prob = score

    if prob > min_score then
      prob = common_spell_mana( "spell_armageddon", spells.spell_armageddon, ignore_mana, prob )
      table.insert( cast, { spell = 'spell_armageddon', prob = prob } )
    end
  end

  if spells.spell_geyser then
    local applicable = spellattacks.spell_geyser.applicable
   	local min_dmg, max_dmg, count, stun, duration = pwr_geyser( spells.spell_geyser, ehero_level )
    local avg_dmg = ( min_dmg + max_dmg ) / 2
    local hits = count
    local score = 0

    for i, act in ipairs( enemies ) do
      if applicable( act )
      and not Attack.act_feature( act, "magic_immunitet" ) then
        local res = ( 100 - Attack.act_get_res( act, "physical" ) ) / 100
        local spell_power = common_damage_score( avg_dmg, res, act, e2a )
        local effect_score = common_score( act, e2a ) * ( stun - ( 100 - res * 100 ) ) / 100 * duration

        if Attack.act_feature( act, "pawn" ) then
          effect_score = effect_score / 10;
          spell_power = spell_power / 10;
        end

        score = score + spell_power + effect_score

        if hits == 0 then
          break
        else
          hits = hits - 1
        end
      end
    end

    local prob = score

    if prob > min_score then
      prob = common_spell_mana( "spell_geyser", spells.spell_geyser, ignore_mana, prob )
      table.insert( cast, { spell = 'spell_geyser', prob = prob } )
    end
  end

  if spells.spell_phantom then
    local max_power, unit_power, target = 0, 0

    for i, c in ipairs( spellattacks.spell_phantom.avcells() ) do -- клонируем самого сильного юнита
      local power = unit_score( Attack.get_caa( c, true ) )

      if power > max_power then
        max_power = power
        target = c
        unit_power = common_score( Attack.get_caa( c, true ), a2e )
      end
    end

    if target ~= nil then
      local av = spellattacks.spell_phantom.avcells( target ) -- место появления - рандомно
      local power = pwr_phantom( spells.spell_phantom, ehero_level )
      local duration = int_dur( "spell_phantom", spells.spell_phantom )
      local prob = unit_power * power / 100 * duration

      if prob > min_score then
        prob = common_spell_mana( "spell_phantom", spells.spell_phantom, ignore_mana, prob )
        table.insert( cast, { spell = 'spell_phantom', target = target, target2 = av[ Game.Random( 1, av.n ) ], prob = prob } )
      end
    end
  end

  if spells.spell_necromancy then
    for i, c in ipairs( spellattacks.spell_necromancy.avcells() ) do
      local act = Attack.cell_get_corpse( c )
      local power = pwr_necromancy( spells.spell_necromancy, ehero_level )
      local unit_animate = necro_get_unit( actor_name( act ), Attack.act_initsize( act ), power )
      local undead_HP = Attack.atom_getpar( unit_animate, "hitpoint" )
      -- сколько можно поднять по здоровью
      local animate_count = math.floor( power / undead_HP )
      -- реально
      local animate_real = math.min( animate_count, Attack.act_initsize( act ) )
      local benefit = animate_real / animate_count

      if benefit > .9 then -- воскрешаем первый попавшийся подходящий труп
        prob = math.ceil( math.min( 2000, benefit * 1000 ) * e2a )
        prob = common_spell_mana( "spell_necromancy", spells.spell_necromancy, ignore_mana, prob )
        table.insert( cast, { spell = 'spell_necromancy', target = c, prob = prob } )
        break
      end
    end
  end

  if spells.spell_teleport then
    local max_power, target, thrower = 0

    for i, act in ipairs( allies ) do
      if act.thrower
      and act.units * act.leadship / allies_power > .5
      and under_attack_units[ act.cell ] then -- это лучник, который составляет более половины нашей армии
        thrower = act

        for i, c in ipairs( spellattacks.spell_teleport.avcells() ) do
          local power = Attack.act_leadership( c ) * Attack.act_size( c )

          if power > max_power
          and not Attack.act_is_thrower( c )
          and Attack.act_enemy( c )
          and Attack.act_get_par( c, "speed" ) <= 4 then
            local a = Attack.get_caa( c, true )
            local base = a.atks.base

            if base ~= nil then -- смотрим, может ли этот враг атаковать нашего лучника
              for i = 1, base.targets.n do
                if base.targets[ i ].cell == thrower.cell then
                  max_power = power
                  target = c
                  break
                end
              end
            end
          end
        end

        break
      end
    end

    if target ~= nil then -- телепортируем выбранного врага как можно дальше от лучника
      local max_dist, farthest = 0

      for i, c in ipairs( spellattacks.spell_teleport.avcells( target ) ) do
        local dist = Attack.cell_dist( thrower, c )
        if dist > max_dist then
          max_dist = dist
          farthest = c
        end
      end

      if farthest ~= nil then
        table.insert( cast, { spell = 'spell_teleport', target = target, target2 = farthest, prob = 1500 } )
      end
    elseif is_tactics_offencive( enemies, actors ) then -- пробуем телепортировать свой отряд к вражеским лучникам
      local max_power = 0
      for i, act in ipairs( enemies ) do -- ищем самого сильного вражеского лучника
        local power = act.units * act.leadship
        if power > max_power
        and act.thrower then
          max_power = power
          target = act
        end
      end

      if target ~= nil then -- нашли лучника - теперь ищем самого сильного нашего юнита, который никого не может атаковать
        max_power = 0
        local unit

        for i, c in ipairs( spellattacks.spell_teleport.avcells() ) do
          local power = Attack.act_leadership( c ) * Attack.act_size( c )
          if power > max_power
          and not can_attack_units[ c.cell ]
          and Attack.act_ally( c ) then
            max_power = power
            unit = c
          end
        end

        if unit ~= nil then -- телепортируем этого юнита как можно ближе к лучнику
          local min_dist, nearest = 1000

          for i, c in ipairs( spellattacks.spell_teleport.avcells( unit ) ) do
            local dist = Attack.cell_dist( target, c )
            if dist < min_dist then
              min_dist = dist
              nearest = c
            end
          end

          if nearest ~= nil then
            table.insert( cast, { spell = 'spell_teleport', target = unit, target2 = nearest, prob = 800 } )
          end
        end
      end
    end
  end

  if table.getn( cast ) > 0 then return random_choice( cast ) end
    --return {spell="spell_invisibility", target=spellattacks.spell_invisibility.avcells()[1]}

end

book_extra_times = 00  -- dont forget to delete 100x book times in two places

function demonbox_controller(attacks)

    local use = {}

    if attacks.lump or attacks.spittle or attacks.reaping then

        local enemies_power, max_power, target = 0, 0
        for i=1,Attack.act_count()-1 do
            if Attack.act_enemy(i) then
                local power = Attack.act_leadership(i)*Attack.act_size(i)
                enemies_power = enemies_power + power
                if power > max_power then
                    max_power = power
                    target = i
                end
            end
        end

        if target ~= nil then
            local cellid = Attack.cell_id(Attack.get_cell(target))
            if attacks.lump then
                table.insert(use, {attack=attacks.lump, target=cellid, prob=700})
            end
            if attacks.spittle then
                table.insert(use, {attack=attacks.spittle, target=cellid, prob=700})
            end
            if attacks.reaping and max_power/enemies_power > .3 and not Attack.act_feature(target, "pawn,undead,golem,plant") then
                table.insert(use, {attack=attacks.reaping, target=cellid, prob=2000})
            end
        end

    end

    local justRandomAttacks = {quake=800, black_hole=1000, enboxes=1000}
    for name,prob in pairs(justRandomAttacks) do
        if attacks[name] then
            table.insert(use, {attack=attacks[name], prob=prob})
        end
    end

    --[[if attacks.glot then -- защищаем самого сильного нашего лучника
        local max_power, target = 0
        for i=1,Attack.act_count()-1 do
            if Attack.act_ally(i) and Attack.act_is_thrower(i) and Attack.act_get_armour(i) == nil then
                local power = Attack.act_leadership(i)*Attack.act_size(i)
                if power > max_power then
                    max_power = power
                    target = i
                end
            end
        end
        if target ~= nil then
            table.insert(use, {attack=attacks.glot, target=Attack.cell_id(Attack.get_cell(target)), prob=1500})
        end
    end]]

    if attacks.orb then

        local midp = ally_enemy_midpoint()

        local mindist, nearest = 1000
        for i=0,Attack.cell_count()-1 do -- ищем ближайшую клетку к midp
            local c = Attack.cell_get(i)
            if empty_cell(c) then
                local dist = Attack.cell_dist(c, midp)
                if dist < mindist then
                    mindist = dist
                    nearest = c
                end
            end
        end

        if nearest ~= nil then
            table.insert(use, {attack=attacks.orb, target=Attack.cell_id(nearest), prob=1000})
        end

    end

    if attacks.gizmo then

        local gizmo_ids = get_gizmo_ids()
        local targets = {}

        for i=1,Attack.act_count()-1 do
            local enemy = Attack.act_enemy(i)
            if Attack.act_ally(i) or enemy then
                local id = Attack.cell_id(Attack.get_cell(i))
                if not gizmo_ids[id] then
                    table.insert(targets, id)
                    if enemy then table.insert(targets, id) end -- на врагах вероятность появления в 2 раза больше
                end
            end
        end

        if table.getn(targets) > 0 then
            table.insert(use, {attack=attacks.gizmo, target=targets[Game.Random(1,table.getn(targets))], prob=1000})
        end

    end

    if table.getn(use) > 0 then return random_choice(use) end

end
