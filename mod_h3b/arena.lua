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

  local hero_defense = 0

  if receiver_human then
    hero_defense = tonum( Logic.hero_lu_item( "defense", "count" ) )
  else
    hero_defense = tonum( Attack.val_restore( receiver, "enemy_hero_defense" ) )
  end
-- ����� ��������� ����� �� ������ �� ������ ������ ����
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

  -- ��������� ����� �� ������ �� ���������:
  local attack_undead_bonus = 0

  if ( AU.race( receiver ) == "undead"
  or AU.feature( receiver, "undead" ) )
  and attacker_human then
    attack_undead_bonus = hero_item_count( "sp_attack_undead" )
  end

  -- ��������� ����� �� ������� �� ���������:
  local attack_demon_bonus = 0

  if ( AU.race( receiver ) == "demon"
  or AU.feature( receiver, "demon" ) )
  and attacker_human then
    attack_demon_bonus = hero_item_count( "sp_attack_demon" )
  end

  -- ��������� ����� �� �������� �� ���������:
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

  return kdmg, receiver_human, attacker_human
end


function apply_damage( attacker, receiver, dfactor, minmax, krit, kritProb ) --ftag:damage

  local beauty_k=30

  if dfactor < 0 then dfactor = 0 end

  dfactor = dfactor / 100
  local sdmg = 0
  local iskrit
  local kdmg, receiver_human, attacker_human = att_rec_stuff( attacker, receiver )

  if minmax ~= 0
  or krit == 0 then
    iskrit = false -- � ���������� ����������� ���� ������� �� ��������� (� ����� ����� krit=0)
  elseif Attack.act_is_spell( attacker, "special_preparation" )
  or Attack.act_is_spell( receiver, "spell_crue_fate" )
  or Attack.act_is_spell( receiver, "effect_unconscious" )
  or Attack.act_is_spell( receiver, "effect_sleep" ) then
    iskrit = true
  else
    kritProb = kritProb
  
    if Attack.act_is_spell( receiver, "effect_entangle" )
    or Attack.act_is_spell( receiver, "special_spider_web" )
    or Attack.act_is_spell( receiver, "effect_stun" )
    or Attack.act_is_spell( receiver, "spell_blind" )
    or Attack.act_is_spell( receiver, "effect_blind" ) then
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

  local uc = math.max( 1, AU.unitcount( attacker ) ); -- max �� ������, ����� ������� ������� ���� (count = 0)
  local dcnt = AU.rescount();
  local i
  local max_damage = 0

  for i = 0, dcnt - 1 do
    local min_ = uc * AU.minresdmg( attacker, i )
    local max_ = uc * AU.maxresdmg( attacker, i )

    if Attack.is_base_attack() then -- ��� ��������� ����� ���������������� ������ �� ������� �����
      min_, max_ = correct_damage_minmax( attacker, min_, max_ )
    elseif Attack.get_caa( attacker ) ~= nil
    and Attack.act_chesspiece( attacker ) then
      local diff_k = Attack.val_restore( attacker, "diff_k" )
      local sign_diff_k = Attack.val_restore( attacker, "sign_diff_k" )
      local min_stat_inc = Attack.val_restore( attacker, "min_stat_inc" )
      local inc = 0

      if diff_k ~= nil
      and sign_diff_k ~= nil
      and min_stat_inc ~= nil then
        inc = math.max( round( math.abs( min_ * diff_k ) ), min_stat_inc ) * sign_diff_k
        min_ = min_ + inc
        inc = math.max( round( math.abs( max_ * diff_k ) ), min_stat_inc ) * sign_diff_k
        max_ = max_ + inc
      end
    end

    local dmg

    if ( minmax == 1 ) then dmg = min_
    elseif ( minmax == 2 ) then dmg = max_
    elseif ( minmax == 3 ) then dmg = ( min_ + max_ ) / 2
    else dmg = Game.Random( min_ , max_ ) end

    -- ��������! ���� ������� �� �� ��������� � �� ���������!
    if iskrit then dmg = max_ end

    local resi = AU.resistance( receiver, i )

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
    -- ���� ������ �� ��� �����
    krage = 0
  elseif receiver_human then
    -- ����� ����!
    krage = 1.0
  end

  krage = krage * Game.AddRageK()

  -- ����� �� ������ � ���������
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

  -- ���� ���� �� ������� ��� ����� �����, �� ������ ������ �������
  if Attack.get_caa( attacker ) == nil then add_hero_rage = add_hero_rage * 0.5 end

  -- ���� ����� ������� ���� ������  �����, �� �� �������� +1 ������
  if receiver_human and killed >= 1 then add_hero_rage = add_hero_rage + 1 end

  add_hero_rage = add_hero_rage * mana_rage_gain_k

  if add_hero_rage < 1
  and add_hero_rage > 0.2 then
    add_hero_rage = 1
  end

  -- calc rage for hero [end] ======================================================================================

  if iskrit then sdmg = -sdmg * krit end

  if minmax == 0 then -- ������ ����� ������� ������� ����
    -- ������ ����� ��������� � ����� �����
    if Attack.act_is_spell( attacker, "effect_blind" )
    and Attack.val_restore( attacker, "ignore_effect_blind" ) == nil then
      local rnd = Game.Random( 99 )
      
      if rnd < 89 then
        return MISS, 0, "happy", ""
      end
    end

    if Attack.act_is_spell( receiver, "feat_potion_evasion" )
    and ( Attack.act_chesspiece( attacker )
    or Attack.act_pawn( attacker ) ) then
      local evasion = tonumber( Attack.act_spell_param( receiver, "feat_potion_evasion", "param" ) )
      local rnd = Game.Random( 99 )

      if rnd < evasion then
        return MISS, 0, "damage", ""
      end
    end

    -- ������ �������� �������� ������� - ���������� ����� �� ���� � 0
    -- ��� � miss, ����� ����� ������ damage �� -0,1 � 0
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

    -- ����� ��������� ���� �� ���������� �����������
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

    -- ������ ��������
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

  -- ������������ ������ �� ��� � ������ ���
  local kCost = tonumber(Game.Config("arenacommon/kCost"))
  gold = kCost * gold * Game.HSP_moneyk()

  -- ������ ������� ���������
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
--  local enemyHeroK = 1.5 + Game.Config( "enemy_hero_money_exp_bonus_k") * Logic.enemy_hero_level()
--  if Logic.enemy_hero_level() == 0 then enemyHeroK = 1 end
  local ehero_level = 0

  if EHERO_LEVEL ~= nil then
    ehero_level = EHERO_LEVEL  -- this accounts for Gremlin Towers
    EHERO_LEVEL = nil  -- clear Global
  end

  local enemyHeroK = 1.5 + Game.Config( "enemy_hero_money_exp_bonus_k" ) * ehero_level

  if ehero_level == 0 then enemyHeroK = 1 end

  local necroK, necroKexp = skill_power2( "holy_knight", 1 ), skill_power2( "holy_knight", 2 )
  local addexp, gold = 0, 0
  local total_dragonflies = 0 --[[, total_griffins, total_snakes, total_spiders = 0, 0, 0, 0
  local total_skeletons, total_vampires, total_thorns, total_ents = 0, 0, 0, 0
  local total_bonedragons, total_greendragons, total_reddragons, total_blackdragons = 0, 0, 0, 0]]

  for i = 0, Bonus.info_enemy_dead_count() - 1 do
    local dead, atom = Bonus.info_enemy_dead_get( i )
    local k, expK = 0, 1

    if dead > 0 then
      if necroK > 0 then
        local race = Attack.atom_getpar( atom, "race" )

        if race == "demon"
        or race == "undead" then k = necroK / 100; expK = 1 + necroKexp / 100 end
      end

      -- This is to compute chance of awarding dragonfly wings as a bonus
      if atom == "dragonfly_fire"
      or atom == "dragonfly_lake" then
        total_dragonflies = total_dragonflies + dead
--[[      elseif atom == "griffin" then
        total_griffins = total_griffins + dead
      elseif atom == "snake"
      or atom == "snake_green"
      or atom == "snake_royal" then
        total_snakes = total_snakes + dead
      elseif atom == "spider"
      or atom == "spider_fire"
      or atom == "spider_undead"
      or atom == "spider_venom" then
        total_spiders = total_spiders + dead
      elseif atom == "archers"
      or atom == "skeletons" then
        total_skeletons = total_skeletons + dead
      elseif atom == "bat"
      or atom == "bat2"
      or atom == "vampire"
      or atom == "vampire2" then
        total_vampires = total_vampires + dead
      elseif atom == "thorn"
      or atom == "thorn_warrior" then
        total_thorns = total_thorns + dead
      elseif atom == "kingthorn" then
        total_thorns = total_thorns + dead * 61.5
      elseif atom == "ent" then
        total_ents = total_ents + dead
      elseif atom == "ent2" then
        total_ents = total_ents + dead * 4.5
      elseif atom == "bonedragon" then
        total_bonedragons = total_bonedragons + dead
      elseif atom == "blackdragon" then
        total_blackdragons = total_blackdragons + dead
      elseif atom == "greendragon" then
        total_greendragons = total_greendragons + dead
      elseif atom == "reddragon" then
        total_reddragons = total_reddragons + dead]]
      end

      addexp = addexp + ( Bonus.info_unitexp( atom ) * dead ) * expK
      gold = gold + Attack.atom_getpar( atom, "cost" ) * dead * ( 1 + k )
    end
  end

  -- ����������� ���� �����
  local elead, leadk = Game.FightParams()
  -- gold = gold * math.min(2, math.max(.5, leadk))
  -- gold = gold * math.min(2, math.max(.5, leadk-(Game.MapLocDifficulty()*3/100)))
--  gold = gold * math.min(2.5, math.max(1, leadk-(Game.MapLocDifficulty()*1.5/100)))
  -- ���������� ����������� ������ �� ����������� ��������� � ������ ������
  gold = gold * ( 1 + skill_power2( "charm", 1 ) / 100 + hero_item_count( "sp_addgold_battle" ) / 100 )

  if boss_exp ~= nil then
    addexp = addexp + boss_exp
  end

  -- ���������� �� 10 � ���������� ����������� ����� �� ����������� ��������� � ������ ��������
  local ll = skill_power2( "learning", 1 )
  addexp = addexp
  addexp = Game.Round( addexp, 10 ) * (1 + skill_power2( "learning", 1 ) / 100 + hero_item_count( "sp_addexp_battle" ) / 100 )

  gold = gold / ( Game.MapLocDifficulty() * ( Game.Config( "diffmap_to_kmoneyarmy" ) - 1 ) / 100 + 1 )

  -- ����-� ����. �����
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

  local total_bonus_add = 0  -- this counter is used to protect against calling Bonus.add more than 3 times (crashes game if it happens)

  if total_dragonflies > 0 then
    local dragonfly_wing_chance = math.sqrt( total_dragonflies )
    local number_wings = math.floor( math.sqrt( dragonfly_wing_chance ) )

    if number_wings > 0 then
      if Game.Random( 99 ) < dragonfly_wing_chance then
        Logic.hero_add_item( "wing_dragonfly", number_wings )

        if total_bonus_add < 3 then
          Bonus.add( "dfly_wng" )  -- I don't put the number of wings here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

--[[  if total_blackdragons > 0 then
    local container_chance = math.sqrt( total_blackdragons )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "blackdragon_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_blackdragon" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_reddragons > 0 then
    local container_chance = math.sqrt( total_reddragons )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "reddragon_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_reddragon" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_greendragons > 0 then
    local container_chance = math.sqrt( total_greendragons )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "greendragon_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_greendragon" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_bonedragons > 0 then
    local container_chance = math.sqrt( total_bonedragons )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "bonedragon_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_bonedragon" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_ents > 0 then
    local container_chance = math.sqrt( total_ents )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "ent_seed", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "seed_ent" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_griffins > 0 then
    local container_chance = math.sqrt( total_griffins )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "griffin_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_griffin" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_vampires > 0 then
    local container_chance = math.sqrt( total_vampires )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "vampire_grave", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "grave_vampire" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_snakes > 0 then
    local container_chance = math.sqrt( total_snakes )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "snake_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_snake" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_spiders > 0 then
    local container_chance = math.sqrt( total_spiders )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "spider_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_spider" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_skeletons > 0 then
    local container_chance = math.sqrt( total_skeletons )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "skeleton_grave", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "grave_skeleton" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_dragonflies > 0 then
    local container_chance = math.sqrt( total_dragonflies )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "dfly_egg", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "egg_dfly" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end

  if total_thorns > 0 then
    local container_chance = math.sqrt( total_thorns )
    local number_container = math.floor( math.sqrt( container_chance ) )

    if number_container > 0 then
      if Game.Random( 99 ) < container_chance then
        Logic.hero_add_item( "thorn_seed", number_continer )

        if total_bonus_add < 3 then
          Bonus.add( "seed_thorn" )  -- I don't put the number here because they interfere with the gold display (not sure how to fix)
          total_bonus_add = total_bonus_add + 1
        end
      end
    end
  end]]

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

--New! Function decreases stats of your units for long combats
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

  Attack.val_store( target, "diff_k", diff_k )
  Attack.val_store( target, "sign_diff_k", sign_diff_k )
  Attack.val_store( target, "min_stat_inc", min_stat_inc )
  
  local function apply_bonus( target, diff_k, sign_diff_k, parameter, min_stat_inc )
    local current_value, base_value = Attack.act_get_par( target, parameter )
    local value_inc = 0

    if parameter == "krit" then
      value_inc = math.max( round( math.abs( diff_k * 100 ) ), min_stat_inc ) * sign_diff_k
    else
      value_inc = math.max( round( math.abs( base_value * diff_k ) ), min_stat_inc ) * sign_diff_k
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
        local defenseup = math.max( round( ( base_value + value_inc ) / 5 ), min_stat_inc )
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
      local min_damage_inc = math.max( round( math.abs( min_damage_base * diff_k ) ), min_stat_inc ) * sign_diff_k
      local max_damage_inc = math.max( round( math.abs( max_damage_base * diff_k ) ), min_stat_inc ) * sign_diff_k
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
      local new_resist = round( math.abs( base_resist * diff_k ) * sign_diff_k )
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


--New! Function that applies Hero Attack / Defense bonuses
function apply_hero_attack_defense_bonuses( target )
  local function apply_bonus( unit )
    local unit_human = Attack.act_human( unit )
    local hero_attack = 0
  
    if unit_human then
      hero_attack = tonum( Logic.hero_lu_item( "attack", "count" ) )
    else
      hero_attack = Attack.val_restore( unit, "enemy_hero_attack" )

      if hero_attack == nil then
        local new_current_value, new_base_value = Attack.act_get_par( unit, "attack" )
        hero_attack = math.max( 0, new_current_value - new_base_value )

        if hero_attack > 0 then
          Attack.val_store( unit, "enemy_hero_attack", math.max( 0, hero_attack ) )
        end
      else
        hero_attack = tonumber( hero_attack )
      end
    end
  
    if hero_attack > 0 then
      local krit_inc = tonum( Game.Config( "attack_config/krit_inc" ) )
      local krit_bonus = math.floor( hero_attack / 7 ) * krit_inc
  
      if krit_bonus > 0 then
        Attack.act_attach_modificator( unit, "krit", "hero_attack_krit", krit_bonus, 0, 0, -100, false )
      end
    end

    local res_inc = 0
    local hero_defense = 0
  
    if unit_human then
      hero_defense = tonum( Logic.hero_lu_item( "defense", "count" ) )
    else
      hero_defense = Attack.val_restore( unit, "enemy_hero_defense" )

      if hero_defense == nil then
        local new_current_value, new_base_value = Attack.act_get_par( unit, "defense" )
        hero_defense = math.max( 0, new_current_value - new_base_value )

        if hero_defense > 0 then
          Attack.val_store( unit, "enemy_hero_defense", math.max( 0, hero_defense ) )
        end
      else
        hero_defense = tonumber( hero_defense )
      end
    end
  
    if hero_defense > 0 then
      local res_inc_config = tonum( Game.Config( "defense_config/res_inc" ) )
      res_inc = math.floor( hero_defense / 7 ) * res_inc_config
  
      if res_inc > 0 then
        local resistances = {}
        local str_resistances = Game.Config( 'resistances' )
        local number_resistances = text_par_count( str_resistances )
      
        if number_resistances > 1 then
          for j = 1, number_resistances do
            local sub_string = text_dec( str_resistances, j )
            table.insert( resistances, sub_string )
          end
        end
    
        for i, res in ipairs( resistances ) do
          Attack.act_attach_modificator_res( unit, res, "hero_defense_res_" .. res, res_inc, 0, 0, -100, false )
        end
      end
    end

    return true
  end

  if target == nil then
    for a = 1, Attack.act_count() - 1 do
      if not Attack.act_pawn( a )
      and not Attack.act_feature( a, "pawn" )
      and not Attack.act_feature( a, "boss" ) then
        apply_bonus( a )
      end
    end
  else
    apply_bonus( target )
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

  if round == 1 then -- ������ ���
--[[    local locName = Game.LocName()
    local locType = ''
  
    if Game.LocType( 'cemetery' ) then
      locType = 'cemetery'
    end
    if Game.LocType( 'lava' ) then
      if locType == '' then
        locType = 'lava'
      else
        locType = locType .. ',' .. 'lava'
      end
    end
    if Game.LocType( 'dungeon' ) then
      if locType == '' then
        locType = 'dungeon'
      else
        locType = locType .. ',' .. 'dungeon'
      end
    end
    if Game.LocType( 'forest' ) then
      if locType == '' then
        locType = 'forest'
      else
        locType = locType .. ',' .. 'forest'
      end
    end
    if Game.LocType( 'sea' ) then
      if locType == '' then
        locType = 'sea'
      else
        locType = locType .. ',' .. 'sea'
      end
    end
    if Game.LocType( 'winter' ) then
      if locType == '' then
        locType = 'winter'
      else
        locType = locType .. ',' .. 'winter'
      end
    end
    if locType == '' then
      locType = 'normal'
    end

    local timeOfDay

    if Game.DayTime() == 0 then
      timeOfDay = 'morning'
    elseif Game.DayTime() == 1 then
      timeOfDay = 'afternoon'
    elseif Game.DayTime() == 2 then
      timeOfDay = 'evening'
    elseif Game.DayTime() == 3 then
      timeOfDay = 'night'
    end

    Attack.log( "loc_name_type_log", "name", locName, "special", locType, "special2", timeOfDay )]]

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

    -- �������
    if skill_power2( "tactics" ) > 0 then
        Attack.start_special_spell("spell_army_disposition")
        Attack.log("add_blog_tactics")
    else
        Attack.log("battle_start")
        Attack.arena_text("<label=round_big_text> 1")
    end

    -- ������ ���������
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

    -- ������������
    local start_defense_p = skill_power2( "start_defense", 1 )
    if start_defense_p > 0 then
      for a = 1, Attack.act_count() - 1 do
        if Attack.act_ally( a ) then
          Attack.act_attach_modificator_res( a, "physical", "sc", start_defense_p, 0, 0, -100, false, 0, true )
        end
      end

      Attack.log( tend + .01, "start_defense_log", "name", "<label=skill_start_defense_name>", "special", start_defense_p )
    end

    -- ������
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

    -- ������ ����� (������)
    local t = skill_power2( "hi_magic", 1 )
    Logic.hero_lu_var( "double_book_charges", t )

    if t > 0 then
      t = 2
      Attack.log( tend + .01, "hi_magic_log", "name", "<label=skill_hi_magic_name>", "special", t )
    else
      t = 1
    end

    Logic.hero_lu_var( "book_times", t + book_extra_times )

    -- ����� ���������
    for i = 1, Attack.act_count() - 1 do
      if string.find( Attack.act_name(i), "^arena_tower" ) then -- ��������� �� ���������� ����� - �������������
        -- NEW! Fighting towers adds +rounds to the mana_rage_gain_k decrease
        ROUND_MANA_RAGE_GAIN = math.max( ROUND_MANA_RAGE_GAIN, tonumber( text_dec( Game.Config( 'difficulty_k/roundtower' ), Game.HSP_difficulty() + 1, '|' ) ) )
        local itlevel = Game.InsideItemLevel()

        if itlevel == nil then itlevel = 2 end

        local max_enemy_leadership = 0

        for i = 1, Attack.act_count() - 1 do -- ������� hp ������
          if Attack.act_enemy( i )
          and not Attack.act_pawn( i ) then
            local enemy_leadership = Attack.act_leadership( i ) * Attack.act_initsize( i )
            max_enemy_leadership = math.max( enemy_leadership, max_enemy_leadership )
          end
        end

        enemy_unit_names = {} -- ��������� ����� ������ ��� ������� �������
        ally_unit_names = {}

        for i = 1, Attack.act_count() - 1 do
          local actor_name = Attack.act_name( i )
          if string.find( actor_name, "^arena_tower" ) then
            local tower_base_hp = Attack.atom_getpar( actor_name, "hitpoint" )
            local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/eunit' ), Game.HSP_difficulty() + 1, '|' ) )
            local health = math.max( tower_base_hp, math.ceil( max_enemy_leadership * itlevel / 15 * diff_k ) ) -- �������� �����
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

    -- ������������� ������
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

    apply_hero_attack_defense_bonuses()

  else
    Attack.log( tend, "round_start", "round", round )
    Attack.arena_text( "<label=round_big_text> " .. round )

    -- ���������� ������
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

    -- ������� ����/������
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

    -- ������ ����� (���������)
    local dbc = Logic.hero_lu_var( "double_book_charges" )
    if dbc ~= nil then
      dbc = tonumber( dbc )

      if dbc > 0
      and tonumber( Logic.hero_lu_var( "book_times" ) ) < 1 then -- ��� ��������, ��� ����� ���� ������������ 2 ����
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


function on_knockout( koN, caa ) -- koN - ���-�� ������ �������
  -- �����������
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


--seed = 0

-- AI Front End
function ai_choose_target( mover--[[, attacks]], enemies, ecells ) --�������� ���� ��� ����� � ���������� �;
--[[
���������:
  mover - ����, ������� ���������� ����� � ���� ��� �������� ����� �������
  attacks - ������ a���, ������� ����� ������������ ����� ������
    .targets - ������ �������� �����, ������� ����� ��������� ������ ������
    .name - �������� ����� (��� ����� � ����� �����)
  enemies - ������ ���� ������
  �������� mover'a � enemies:
    .cell - id ������
    .name - ��� ����� �����
    .atks - ��������� ����� ����� � ���� �����. �������, ���� - ��� ����� (�� �������� ����� �����, ���� 'base' ��� ������� �����), ���������:
      .name - ��� �����
      .targets - ��������� ���� (�����)
      .cells - ��������� ������
      .dmgmin - ����������� ����
      .dmgmax - ������������ ����
      .dmgavg - ������� ����
      .class - ����� (throw, moveattack, scripted)
      .distance - ��������� �����
      .penalty - �������� ��� ���������� ���������
      .custom_params
      .applicable(actor) - true, ���� �� ����� ����� ���������
      .calc_damage(actor[, minmax]) - ������� ����, ������� ������ ������ ����� �� ����� actor (minmax: 1 - ���. ����, 2 - ����. ����, �� ��������� 3 - ������� ����)
        .damage - ����
        .dead - ������� ������ ����
        .hp - ������� ������ ��������� � ���������� ����� � �����
        .units - ������� ������ ��������� � �����
        .hitback - true, ���� ������ ���� ����� �������� �� ���� ����
      ����� move-����:
        friend_damage,_3in1,_6in1,superhitback,long2,nomove,_return
    .level - �������
    .leadship - ���������
    .initial_units - ���-�� ������ � ������ � ������ ���
    .units - ���-�� ������ � ������
    .totalhp - ���-�� ����� � ��� ������ � ������
    .hp - ����� � ���������� �����
    .ap - action points (������� ����)
    .thrower - true, ���� ���� ����� �������� (������, ����� ���� ����� ������� ����� ������ �� moveattack)
    .par("<���_���������>") - ����.: par("defense")
    .par_base("<���_���������>")
    .sdata - ��������� ���������� ���������� �����, ����� ������ � ������ ��������� ����� sdata.<���_���������> (����� ������� ������ val_store/val_restore)
    .spells - ����������, ������� �������� �� ����� (����� ���������� ����� spells[1],spells[2]...spells[spells.n], � ����� ����� spells.<���_����������>)
    �������� ����������:
      .name - ��������
      .duration - ����������������� ��������
      .<���_���������> - ������ � ���. ����������� ���������, ����� ������ � ������ (������ act_spell_param)
  ���. �������� mover:
    .can_pass - ����� ��������
  ���. �������� enemies:
    .distance - ���������� �� mover'a
    .attacks - ������ �������� ����, �������� ����� ��������� ������� �����
  ecells - ������ ������, � ������� ����� ��������
    .cell - id ������
    .distance - ���������� �� mover'a
]]

  --setfenv(1,aipar) --����� ���������� ��������� �������, ������ ������ aipar.enemies ����� ������������ ������ enemies / ����� ��� �� ������������, �.�. ����� ��������� ���� ����� ������ ������� �� ���������� ������� ���������, ����. math
  --local Game = {Random = function (x,y) seed = math.mod(seed,6584375897 * seed + 41864553113,1024*1024); return x+(y-x)*math.mod(seed,256)/256; end}

  if table.getn(enemies) == 0 then return {target = 0} end

  if Attack.act_ooc(mover) and Attack.act_human(mover) and Game.Random(99) < 90 then -- � 90% ������� �������� �� ��� �������� ����� ����� ���� ��� ����� �������
    if ecells.n == 0 then return {target = 0} end
    return {target = ecells[Game.Random(1,ecells.n)]}
  end

-- ���������� ����� � �����������
  local i = 1
  while i <= table.getn(enemies) do
    if ((mover.spells.spell_scare or mover.spells.effect_fear) and enemies[i].level > mover.level)
            or (enemies[i].spells.spell_invisibility and not Attack.act_feature(mover,"eyeless")) then
        table.remove(enemies, i)
        --[[enemies[i].skip = true
        if attacks.n > 0 then
            for j=1,attacks.n do -- ������� ����� ����� ��������
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

-- �������� � ����������� ������������� ������
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
        -- �������� ������ �������
            . . .
            exclude_attack(i) -- ��������� ��� �����, �.�. ������ ����-�� ������ ���
            break
        end
      end
]]
--      local targets = {}

--      for i=1,table.getn(enemies) do
--        if --[[enemies[i].skip ~= true and]] enemies[i].attacks.n > 0 then --�������� ������ ���, ���� ����� ��������� ������
    -- ���������� ����
--[[            if enemies[i].spells.spell_target then --���� �� ����� ����� ����� spell_target, �� ������ ������� ������ ���
                return {target = enemies[i], attack = Game.Random(1,enemies[i].attacks.n)} --�������� ��������� �����
            end

            table.insert(targets,enemies[i])
        end
      end]]

--    if Game.Random(1,100) < 50 then -- ����� ������� ����������� ���� (� �������� ����� ������������ ������ ����, ����� �� ������������������)
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

  -- ��� � ���������� �����
--[[  local dist, nearest = 1e10
  for i=1,table.getn(enemies) do
    if enemies[i].skip ~= true and enemies[i].distance < dist then
      dist = enemies[i].distance
      nearest = enemies[i]
    end
  end

  if nearest ~= nil then

    return {target = nearest}; -- attack=1 ����� �� ������, �.�. ��� ������ ������� ����� � ��� ������������ �� ���������

  elseif ecells.n > 0 then

  -- ���������� �����
  if mover.spells.spell_scare or mover.spells.effect_fear then
      if table.getn(targets) > 0 then --����� ����-���� ��������� (�� ����� ���� ������ ������ �� ��������� �����, �.�. ������� �� ������ �� ����������� ���� ����)

          return {new_enemies = targets};

      else -- ������� �� ������ ��� ����� ������

          local dist, farthest = 0, 0

          for i=1,ecells.n do -- ��� ������ ������ ������� ����� ���������� �� ������
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

          return {target = farthest} -- {target=0} �������� ������ � ������

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
                -- ���������, ����� �� ���� ���� ������� �� ����-���� �� ����� �������� ����� ������� ������
                for j=1,enemy_atks.base.targets.n do
                    local act = enemy_atks.base.targets[j]
                    if act.thrower and Attack.act_ally(act) then -- ����� - ��������
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
                        -- ���������, ����� �� ���� ���� ������� �� ����-���� �� ����� ����� ������� ������ (��� �������� ���������� ����� ������ ��� ��������, �.�. ��������� ������� ������ ����� ���������� �� �����)
                        for j=1,enemy_atks.base.targets.n do
                            if ally_check(enemy_atks.base.targets[j]) then -- ����� - ��������� ����
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
function ai_solver( mover, enemies, ecells, actors ) -- actors - ������ �������, �������� ��������� ���������� ������� ����
  --[[ ����� ������� �� (����������� ��� ��������������).
  ������ �������:
  ���� ����, ���� ��������� ����� ������, �� ������ ��������. (��� ����� �������� ��� ���� ��������, ���-� �������� � ������ ��� � �.�.)
  ���� ���, �� ���������, ����� ���-�� �� ��������� ���������� ����� ������� �� ������ �������, ���� ��, �� ��������.
  ����� ��������� ��������� ���� ��������� ���������� ������, ������� ����� ������� �� ������ ������ �����,
  � ����� ��������� ���� ���� ������ �����, ���� ��������� ������� ���������� �� ������� ������ 0.6, �� ������� - �����������, �����:
  ��������� ����������� ���������� ��� ������������� ������, � ���� �� ��������� ������ 0.6, �� ������� - ��������������, ����� �����������. ]]
  if mana_rage_gain_k == nil then
    mana_rage_gain_k = 1
  end

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
  --[[ �������� ��� ����������� �������:
    1. ������� ����� (���� ���������� �� ���������� ��������� ���� �� ��� ������, ���� ����� ��������� ������, ���� ���� ����� ���,
       �� ���� ��������� ������);
    2. ��� (���������� � ��� ������, ����� ��������� ���� �� ���� ���� ��������� ������ �� ����� �� ������, � ��� ����
       ����� �� ������� ����� ����� � �������� (�.�. �������� ������ ������ �������); ���� ���� ��� �������, �� �� ���� ����� �����
       ������� � ������ ������� 1 - ������� ���� �����������, � ������� ����� ������� ������ ���� ��������� ������ � ��. �������� ���);
    3. (�����������, � ������, ����� ������� ������ ������� ������ ������) ����� ����� (���������� � �����), ����. �����, ������ 20 �����. ]]

  --[[local function can_attack(act)
      for k,a in ipairs(enemies) do
          if Attack.act_equal(a,act) then return true end
      end
      return false
  end]]
  local can_attack = {}
  local total_can_attack = 0

  for k, act in ipairs( enemies ) do
    can_attack[ act.cell ] = true
    total_can_attack = total_can_attack + 1
  end

  local cant_attack_incapacitated_enemies = 1

  for k, act in ipairs( enemies ) do
    local max_duration = duration_effect( act, "spell_blind", 0 )
    max_duration = duration_effect( act, "effect_unconscious", max_duration )
    max_duration = duration_effect( act, "effect_sleep", max_duration )

    if max_duration > 1
    and total_can_attack > cant_attack_incapacitated_enemies then
      can_attack[ act.cell ] = false
      cant_attack_incapacitated_enemies = cant_attack_incapacitated_enemies + 1
    end
  end

  local function hazard( act, atk, cache ) -- ������������ ������� ��������� ����� �����, � ������ ��� ����������������� � �������� ����
    if cache ~= nil then
      if cache[ act.cell ] ~= nil then return unpack( cache[ act.cell ] ) end
    end

    local cd = atk.calc_damage( act )
    local dam = cd.damage
    local k = math.min( 1, act.totalhp / dam )^2 -- ����-� �� ��� ������, ����� � ����� �������� ����, � ���� ������� - ������ ����� ���� �������� � ��������� �������

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
      d = 1 + Attack.cell_dist( act, mover ) * .3 -- ����� ���������� ���� ��������� ����� �������
    end

    local v = math.min( act.totalhp, dam ) / d -- ��������� �������������� ��������� ������������ �����, �� ������ ����� �������� ����� ���� ������ �������� � ����, � ������� - � ������

    if act.thrower then v = 2 * v end

    if act.ap > 0 then v = v * 1.5 end -- ����, ������� �� ����� � ���� ������, ����� ������

    if cd.units == 0
    or not cd.hitback then v = v * 2 end -- ���� �� ����� ��������

    if Attack.act_belligerent( act ) ~= Attack.act_belligerent( act, nil ) then v = v / 100 end -- ����� �� �� ��� ����� �� ������ ��� ��������

    -- ������� ���-�� �����, ����� ������� ���� ���� ����� ��������� �����
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
    and act.par( 'dismove' ) ~= 0 then v = v * .3 end -- ���������� ����-� ��� ������ � �������

    if cache ~= nil then
      cache[ act.cell ] = { v, k }
    end

    return v, k
  end

  -- ���������� ��������� ������, ������� ����������� �����
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

  local bonus_cells = {}

  for i = 1, ecells.n do
    local cell = ecells[ i ]
    local ecellbonus = Attack.cell_bonus( cell )
  
    if ecellbonus ~= nil then
      table.insert( bonus_cells, cell )
    end
  end

  local closest, closest_target = 1e5, nil

  for i = 1, table.getn( bonus_cells ) do
    local cell = bonus_cells[ i ]

    if Attack.calc_path( cell, mover ) ~= nil then
      if cell.distance <= mover.ap
      and cell.distance < closest then
        closest = cell.distance
        closest_target = cell
      end
    end
  end
  
  if closest_target ~= nil then
    table.insert( actions, { target = { cell = closest_target.cell }, prob = mover.ap / closest * ( mintours2enemy + 0.5 ) * 10000 * ( mana_rage_gain_k + 0.01 ) } )
  end

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
    for i, en in ipairs( actors ) do -- ���������, ����� �� ���� ��������� ������� �����
      if Attack.act_enemy( en ) then
        local en_atks_base = en.atks.base

        if en_atks_base ~= nil then
          for i = 1, en_atks_base.targets.n do
            if en_atks_base.targets[i].cell == act.cell then -- �����
              return true
            end
          end
        end
      end
    end
  end

  local wait_or_not = 1

  if enemies_power / allies_power < 0.8 or Game.Random( 99 ) < 60 then wait_or_not = 0 end -- ���� ������ - �� ����

  if offence then
    if mover_atks.base ~= nil then
      local hazard_cache, possible_targets, cellfrom = {}, {}

      for i = 1, mover_atks.base.targets.n do -- ���� �������� ������� ����
        local act = mover_atks.base.targets[i]

        if ( can_attack[ act.cell] ) then
          if tostring( act.cell ) == mover.sdata.pref_target then target = act; break end

          -- ������ --
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

          if mover_atks.base.long2 then -- ���������� ������� � ������� ���� ����� �����
            for dir = 0,5 do
              local en = Attack.cell_adjacent( act, dir )

              if en ~= nil
              and Attack.cell_present( en )
              and Attack.act_enemy( en ) then
                local c = Attack.cell_adjacent( act, math.mod( dir + 3, 6 ) )

                if mego_check( c ) then -- ����� � ������ ������ ��������
                  local p = math.ceil( hazard( Attack.get_caa( en, true ), mover_atks.base, hazard_cache) * 10 )

                  if p > pr2 then -- ���� ����� �������
                    pr2 = p
                    from = c
                  end
                end
              end
            end

            if from == nil then -- ������ � ������ ��� - �������� ���� �� �����������, ����� �� ������� �� �����
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

            if from == nil then -- �� ����� �����������, ��� �� �� ���� ������ - ��������� ����������� ����� ������� �����
              pr = 0 --math.ceil(pr / 3)
            end
          end

        		if pr > 0 then
	           if from ~= nil then -- ������� ���� ���� ������ � �������� �������� �������, �.�. ������� �� ��������
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

      if target ~= nil then -- ���� ���� ��� ����� � ���� ���
        local cellatkfrom

        if not mover.thrower
        and mover.ap > 1
        and mover.par( 'speed' ) < 5
        and not mover_atks.longattack
        and -- ��������� ������ ���������� ������������ � ����� �� ��������� ��, �.�. �������� ������� � ������� ����� ��������� �����
          table.getn(possible_targets) == 1
        and target.units * target.leadship < mover_power then -- �������� ������� - ���� ���� (������ ������ ���������) � ������ mover'�.
          -- ���� � ���������� ����� (��� ����� ���� ��������� ������� ��������� ��� �� ��������� ������), ������� ����� ��������� �������� ]]
          local dist, nearest = 1000

          for i, en in ipairs( enemies ) do
            local atk = en.atks.base

            if atk ~= nil
            and en.distance < dist
            and en.cell ~= target.cell then
              for i = 1,atk.targets.n do
                if ( en.thrower or atk.targets[ i ].cell ~= mover.cell )
                and Attack.act_ally( atk.targets[ i ] ) then -- ���� ���� - ������, �� ������� �������� �� �����������
                  dist = en.distance
                  nearest = en
                  break
                end
              end
            end
          end

          if nearest ~= nil then -- ���� ���� ���������� - ������ �������, ����� ������ ������ ���������� ����� (target) ����� ����� � nearest
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
        and cellfrom.cell ~= mover.cell then -- ������ ����
          table.insert( actions, { target = cellfrom, next = { target = target, attack = "base" }, prob = 100 } )
        else
          table.insert( actions, { target = target, prob = 100, attack = "base" } )
        end
      else
        -- ��������� � ���� ��� ������ �� ����� - ���� ����� ��������, �� ������� ������� ���-�� ������, ������� ��� ����� �������� ����� ����� �����
        if mover.can_pass then
          local total_enemies, canmove_enemies = 0, 0

          for i, en in ipairs( actors ) do
            if Attack.act_enemy( en ) then
              if en.ap > 0
              and en.par( 'initiative' ) < mover.par( 'initiative' ) then canmove_enemies = canmove_enemies + 1 end -- �������� �� ���������� ����� �� ������, ����� ���� ���� ��� �������, ��� �� ������ ����� �� ����������� ��� ����� ����� ����

              total_enemies = total_enemies + 1
            end
          end

          if canmove_enemies > 0 then
            table.insert( actions, { target = 1, prob = wait_or_not * math.floor( 50 + 200 * canmove_enemies / total_enemies ) } )
          end
        end

        local max_hazard = -1
        local first_target

        for i, act in ipairs( enemies ) do -- ���� ���������� �����, �� ������, ����� �� ���� ����� ���� �����
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
          -- begin ����� ������
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

          if pawn_target ~= nil then -- ���������, ����� �� ������ ������� ����� (�.�. � ��� �� ����� ����)
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

        elseif first_target ~= nil then -- ����� �� �� ���� ������ - �������, ����� ������ ����������� ���� � ��� ����� ���������
          local mind, nearest_pawn = 1e10

          for i = 1, mover_atks.base.targets.n do -- ���� ����� ��������� ����� ������� ����� �����, ���������� � ������ ��������� ���� (first_target)
            local act = mover_atks.base.targets[ i ]

            if Attack.act_pawn(act) then
              local d = Attack.cell_dist( act, first_target )

              if d < mind then mind = d; nearest_pawn = act end
            end
          end

          if nearest_pawn ~= nil then
            table.insert(actions, {target=nearest_pawn, prob=20, attack="base"})
          else -- ����� ���, ��� � ������ ���� ��� ����� (����� ������ � ������ ����������� ������� ����� ��� ����������� ����, �� ���� ��������� ��� �� �� �����)
            table.insert(actions, {target=first_target, prob=50})
          end
        end

        if target ~= nil then
          -- ���������, �������� �� ���� ���� ���������, ���� ������� �� ������ ����� �� ��������� ���� �� ����� ��, ���� �� ������� ���-�� ��
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
      and target ~= nil then -- ���
        local prob = 0

        if mover.thrower
        and mover_atks.base ~= nil
        and Attack.cell_dist( mover, target ) > mover_atks.base.distance
        and mover_atks.base.penalty < 1
        and not act_under_attack( mover )
        and target.ap > 0
        and target.par( 'initiative' ) <= mover.par( 'initiative' ) then -- ��������� 2 �������� ����� ��������� ����������� ��������, ����� ���� �� ������ ����� ������ ����� ����� ��������
          local can_attack_ally = false

          for name, atk in pairs( target.atks ) do -- �������, ����� �� ��������� ���� ��������� ����-���� �� �����
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
        table.insert( actions, { target = 0, prob = 0 } ) -- ���� � prob=0 ����� �� ��� ������, ����� ������ �������� ���
      end
    end
  else
  --[[ ��� �������������� ������� �������� �������� - ������� ]]
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

  --[[ ���. ��������. ������ ��������� � ��������:
    1. ������������� ����. ������ (����������� (?) ��� �������� ������ �� ����� (�������, �����������) � ��������� �� ������
       ������ ������� ��� �������������� ������� � 0.5 ��� ��������������);
    2. ���������� ������;
    3. ���������� �� ����������;
    4. ������� ������ �������� �� ������ � �� ������. ]]

  for name, atk in pairs( mover_atks ) do
    if name ~= 'base' then -- ���������
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

      if name == "cure" then -- �������
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local profit = math.min( act.par( 'health' ) - act.hp, h ) / h

          if profit > maxprofit then maxprofit = profit; target = act; end
        end

        prob = math.floor( maxprofit^2 * 1000 )

      elseif name == "cure2" then -- �������
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]

          if Attack.act_race( act, "undead" ) then
            if Attack.act_enemy( act ) then
              local h2 = h * 2
              local power = math.min( act.totalhp, h2 ) / math.max( act.totalhp, h2 )
  
              if power > maxprofit then
                maxprofit = power
                target = act
              end
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

          if mover.ap - 1 >= need_ap then -- �� � ��� ����������, ��� ����� �� �����
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

      elseif name == "respawn" then -- �����������
        local h = atk.custom_params.heal * mover.units
        local maxprofit = 0

        for i = 1, atk.targets.n do
          local act = atk.targets[ i ]
          local profit = math.min( act.par( 'health' ) * act.initial_units - act.totalhp, h ) / h

          if profit > maxprofit then maxprofit = profit; target = act; end
        end

        prob = math.floor( maxprofit^2 * 1000 )

      elseif name == "resurrect" then -- ����������� ������� - ������ �����
        target = mover

      elseif name == "split" then -- ���������� ��������
        if mover.units > 1
        and mover.par( 'autofight' ) == 0 then
          for i, act in ipairs( enemies ) do
            if act.thrower
            and act.distance <= mover.par( 'speed' ) + 1 then -- ���������, ������� �� �� �������� (������� ������ ����� � ����)
              local path = Attack.calc_path( mover, act )

              if path ~= nil
              and table.getn( path ) - 1 <= mover.par( 'speed' ) + 1 then
                if Attack.cell_is_empty( path[ 2 ].cell )
                and Attack.cell_is_pass( path[ 2 ].cell )
                and path_len( path[ 2 ].cell, act ) <= mover.par( 'speed' ) then -- ���������, ������ �� ����� ����� ������� �� �����
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
      or name == "summondragonfly"
      or string.find( name, "summonplant" ) then  -- New! Summon Plant
        local pr = 70 + mover_power / allies_power * 30

        if name == "cast_demon" then -- ����� ������, ���� ����� ����
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

            if mover.ap - 1 >= need_ap then -- �� � ��� ����������, ��� ����� �� �����
              local pos = math.min( mover.ap, need_ap + 1 )
              if pos > 1 then
                prob = 100000
                table.insert( actions, { target = { cell = nearest[ pos ].id }, prob = prob } )
              end
            end
          end
        end

      elseif name == "attack_spell"
      or name == "gulp" then -- ����� ���
        set_random_target()

      elseif name == "gibe" then -- ��������
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

      elseif name == "dominator" then -- ��������� ����� ���������
        local leadship = 0

        for i = 1, atk.targets.n do -- ����� ��� �������� ������ ������� �����
          local act = atk.targets[ i ]
          local base_atk = act.atks.base
          if base_atk ~= nil
          and act.leadship*act.units > leadship then
            for i, en in ipairs( actors ) do -- ���������, ����� �� act ������� �� ����-���� �� ������
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

      elseif name == "beast_training" then -- �����������
        local leadship = 0

        for i = 1, atk.targets.n do -- ����� ��� �������� ������ ������� �����
          local act = atk.targets[ i ]
          if act.leadship * act.units > leadship then
            leadship = act.leadship * act.units
            target = act
          end
        end

      elseif name == "transform" then -- �������������
        if mover.par('autofight')==0 then
          local newSpeed = tonumber( Attack.atom_getpar( Attack.atom_getpar( mover.name, "transformto" ), "speed" ) )

          if newSpeed > mover.par_base( "speed" ) then -- ������ ���� � ��������� �����
            if mindist2enemy > mover.ap then -- ������� �� ����� �� ����� => ����������������
              target = mover
              prob = 75
            end

          else
            if mindist2enemy <= newSpeed - mover.par_base("speed") + mover.ap then -- ���� �������� � ��������� ����� � �� ����� ������ ������� �� �����, �� ����������������
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

        for i = 1,atk.targets.n do -- ������� ����, �� ���� ����� ���������
          local act, power, threshold = atk.targets[ i ], 0, 30

          if name == "bless"
          or name == "holy_rage" then
            local act_atks_base = act.atks.base

            if Attack.act_enemy( act ) then -- undead
              power = 1 -- ����� �����
              threshold = 40
            elseif not act.spells.spell_bless
            and not act.spells.special_holy_rage
            and act.leadship * act.units > allies_power / 4.
            and act_atks_base ~= nil then
              for i = 1,act_atks_base.targets.n do
                if Attack.act_enemy( act_atks_base.targets[ i ] ) then -- ���� ���� ����� ��������� ����� - ��� ����� ��������������
                  power = 2
                  break
                end
              end
            end

          elseif name == "magic_shield" then -- ����
            if act_under_attack( act ) then power = 2 end

          elseif name == "dispell" then
            local bonus_spells = takeoff_spells( act, "bonus", true )
            local penalty_spells = takeoff_spells( act, "penalty", true )
            if ( Attack.act_ally( act )
            and not bonus_spells
            and penalty_spells ) -- ������ ����� ��� �������� ������ (� �� ������) � ���� ������ (����� �����)
            or ( Attack.act_enemy( act )
            and bonus_spells
            and not penalty_spells ) then -- ��� ����� - ��������
              power = 2
            end

          elseif name == "amalgamation" then -- �����������
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
            for t in pairs( act.atks ) do -- ������ ������� ���-�� ����.����
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
              local d = math.ceil( ( path_len( c, act ) - 1 ) / mover.par( 'speed' ) ) -- 1 ������ mover.ap, �.�. ����� ���������� ����.������ ��������� ����� 1 ��
              if d < mintours then mintours = d; target = c end
            end
          end
        end

      elseif name == "quake" then -- giant
        local enemies, near_enemies, min_dist, nearest = 0, 0, 1e6

        if can_attack_enemy then near_enemies = -1 end -- �� ������� �����, ���. ����� ��������� ������. ����. ���� ����� 2 �����, �� ������ ����� ��������� ������� ������, quake �� �����, �� ���� ������ ����� ����, ����� ���� ��������� ����� �� ����, quake ����� ������

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

        if near_enemies / enemies > .6 then -- ����� 60% ������ ������ ����������� � �������
          if nearest ~= nil then
            local need_ap = table.getn( nearest ) - 2

            if mover.ap - 1 >= need_ap
            or mover_atks.run == nil then -- �� � ��� ����������, ��� ����� �� �����
              local pos = math.min( mover.ap, need_ap + 1 )

              if pos <= 1 then
                target = mover -- ����� ��� ����
              else
                table.insert( actions, { target = { cell = nearest[ pos ].id }, prob = prob } )
              end -- �������� � �����
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
            if enemies == 2 then -- ���� 2 ����� ��� ������ - ����!
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

      elseif name == "battle_mage" then -- �����
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

      elseif name == "reload" then -- � ����
        if not can_attack_enemy
        and Attack.act_need_charge_or_reload( mover ) then
          target = mover
        end

      elseif name == "rooted" then -- � ����
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
          or act.par( 'speed' ) <= 2 ) then -- ������ ������ ������ ������ �������� ���� ��������� ����������
            cell_ranks[ act.cell ] = tonum( cell_ranks[ act.cell ] ) + 3 -- �� ������, ����� ����������� ����� ����� ���������� ����� ��� ����

            for dir1 = 0, 5 do
              local c1 = Attack.cell_adjacent( act, dir1 )
              if c1 ~= nil
              and Attack.cell_present( c1 ) then
                local id = Attack.cell_id( c1 )
                cell_ranks[ id ] = tonum( cell_ranks[ id ] ) + 2 -- ���� ����������� ������ ����������� �� 2,..

                if name ~= "blood" then -- � ����������� ������ - 1
                  for dir2 = 0, 1 do
                    local c = Attack.cell_adjacent( c1, math.mod( dir1 + dir2, 6 ) )
                    if c ~= nil
                    and Attack.cell_present( c ) then
                      id = Attack.cell_id( c )
                      cell_ranks[ id ] = tonum( cell_ranks[ id ] ) + 1 -- ..� ���������� - �� 1
                    end
                  end
                end
              end
            end
          end
        end

        local max_rank = 3 -- ������� ����� ����� ������ � ������, ���� ������� ����� 3

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
          local unit_animate = necro_get_unit( actor_name( act ), Attack.act_initsize( act ), mover_power * ( text_range_dec( atk.custom_params.k ) ) / 100 ) -- �������� �� ���� ����� �� ������, �.�. �� ������� ������ ��������� ������
          local undead_lead = Attack.atom_getpar( unit_animate, "leadership" )
          -- ������� ����� ������� �� ���������
          local animate_count_lead = math.floor( mover_power / undead_lead * ( text_range_dec( atk.custom_params.k ) ) / 100 )
          -- �������
          local animate_real = math.min( animate_count_lead, Attack.act_initsize( act ) )
          if animate_real / animate_count_lead > .9 then -- ���������� ������ ���������� ���������� ����
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

          elseif Attack.act_ally( act ) then -- ������ ����� �������� �����
            if haseffect then
              enemy_rank = 0
              break
            end
          end
        end

        local pr = ( .5 - mover_power / ( mover_power + enemy_rank ) ) * 200

        if Game.Random( 99 ) < pr then target = mover end

      elseif name == "poison_cloud"  -- bone dragon
      or name == "zap"               -- blue dragon
      or name == "gain_mana" then    -- green dragon
        local enemies = 0

        for dir = 0, 5 do
          local c = Attack.cell_adjacent( mover, dir )

          if c ~= nil
          and Attack.cell_present( c ) then
            if name == "poison_cloud"
            or name == "zap"
            and Attack.act_ally( c ) then -- ����� �� ����!
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
        -- ������ ������ ������� ����� �����, ���� ����� ����� ������ ������ ������� �� �����
        for i = 1, atk.targets.n do
          local a = atk.targets[ i ]

          if not a.thrower
          and Attack.act_ally( a ) then -- �������� ������ ����
            local a_base = a.atks.base

            if a_base ~= nil
            and a_base.targets.n == 0 then -- ���� ������� �� ����� ������ ���������
              -- ���������, ����� ����� ������������, ���� ������ ����-���� �������
              for tt = 1, atk.targets.n do -- �������� ������
                local t_base = atk.targets[ tt ].atks.base

                if t_base ~= nil
                and Attack.act_enemy( atk.targets[ tt ] )
                and atk.targets[ tt ].thrower then -- ������������ ������ ����� �������
                  local tcell = atk.targets[ tt ].cell -- ������ � �������� ����� ���������� ����� a
                  
                  for ii, t in ipairs( actors ) do
                    if tcell ~= t.cell
                    and Attack.act_enemy( t )
                    and path_len( atk.targets[ tt ], t ) <= a.par( 'speed' ) then -- ��������� ������ ������������� �����
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

              if mego_check( c ) then -- ����� ������ � ��� ������
                dist = i
                cfrom = c
              end
            end

            if cfrom ~= nil then
              local sumh, sumk, ecount = 0, 0, 0

              for i = 0, Attack.trace( en, math.mod( dir + 3, 6 ) ) - 1 do
                local t = Attack.trace( i )

                if Attack.act_ally( t ) then -- ����� ���� - �����
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
              or ecount == table.getn( enemies ) then -- ����� ��� �� ������� �����, ����� ��� �� ����� (����. �� ��������� ������ ������ ��, ��� � ����� 1 ���� � 1 hp)
                -- �������, �� ������� ������ ����� �������� �� ������� ����� ����� ������ ������
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

            if Attack.act_ally( t ) then -- ����� ���� - �����
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
          or ecount == table.getn( enemies ) then -- ����� ��� �� ������� �����, ����� ��� �� ����� (����. �� ��������� ������ ������ ��, ��� � ����� 1 ���� � 1 hp)
            sumh = sumh * ( table.getn( path ) - 1 ) / mover.ap -- ��� ������� ����, ��� �����

            if sumh > best_h then
              best_h = sumh
              target = c
            end
          end
        end

        offencive_attack = true

      elseif name == "charge" then -- NEW! Horsemen Charge! (based on the ability "take" from Armored Princess)
        if not can_attack_enemy then
          set_random_target() -- ������ ����� ��������� ����
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

      elseif atk.dmgmax > 0 then -- ��� ����� - ������
        offencive_attack = true
        local max_hazard = -1

        for i = 1, atk.targets.n do
          local act = atk.targets[i]
          if can_attack[ act.cell ]
          and ( atk.class ~= "throw"
          or not ( atk.penalty < 1
          and Attack.cell_dist( mover,act ) > atk.distance ) ) then -- ������ ������� �����, ����� throw-��������� �� �������������� ����� ���� ������� ������
            local h, k = hazard( act, atk )
            
            if h > max_hazard then max_hazard = h; target = act; prob = math.floor( 1000 * k ) end
          end
        end

        if ( name == "longattack"
        or name == "capture" )
        and target == nil then -- ������� ������ �� ����� - �������, ����� ����� ����� �� ������, ������ ������ ������� �����
          local best_c, best_tar

          for i, act in ipairs( enemies ) do
            if atk.applicable( act )
            and ( name ~= "capture"
            or act.par( 'dismove' ) == 0 ) then
              local h, k = hazard( act, atk )

              if h > max_hazard
              and ( name ~= "capture"
              or k > .9 ) then -- ������ ��������, ����� ������ ��� �� ������ � ������, ���� ����� �� ����� ������
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
      or mover.par( 'autofight' ) > 0 ) ) then -- ������ �������� - ����� ������������ ����� ����� ������ ������ ����.�����, � �� ������ ������� � ����� ��� ������� �� ���� ����
        table.insert( actions, { target = target, prob = prob, attack = name } )
      end
    end
  end

  if mover.thrower then -- ������ �� ������
    local penalty_cells = {} -- id ������, � ������� ����� �� ������

    for i = 1, Attack.act_count() - 1 do
      if Attack.act_size( i ) > 0
      and Attack.val_restore( i, "bonus" ) == "0" then -- ��� ������ �����
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

      --[[ ��������������������� ���������:
          1: ���� ����� � �������, � ������� �����, ������ ���, ��: 0 - ������ ����� � ������, 1 - ����� ������ ��� (����� ��������� �� ������ � ������ ����� � ������), �����: 1 - ����� ������ ��� � ���������� �� ������ ������ mover.ap (������ ������� ����� ��� ������, � ������� 1 �� - ��� ���� ��� ����� ��������� ������� �� ������, ������� �� ������, � ����� ��� ������, � ������� ��� ������ �������� ���), � ��������� ������ - 0
          2: 0 - � ������, 1 - ���
          3: 0 - c.distance >= mover.ap (����� ����� �� ������ ����� ��������� ��� ��), 1 - �����
          4: target == nil => ������ 0, ����� = min(0, Attack.cell_dist(c, target) - optimal_dist), ��� optimal_dist - ����������� ��������� ��� ������� �������, - ��� ������� ����� ����� ������� �������� �������� �� ����
          5: target == nil => ������ 0, ����� = min(0, optimal_dist - Attack.cell_dist(c, target)) - � ���, ����� ��������� ����� �� ���������� ��� ��������
          6: ����� ���������� �� ���� ��������� ���������� ]]

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

      if c == nil then c = mover; c.distance = 0 end -- ��������� ����� ������, ��� �� ����� - ����� ���� ������ � �� ����� - � ����� ������

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
        or c.distance >= mover.ap then v[ 1 ] = 0 end -- ����� ������� �� �����, �� ����� ��� ��
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

      -- ������� ����� ���������� �� ���� ��������� ����������
      for k, act in ipairs( actors ) do
        if not act.thrower
        and Attack.act_enemy( act ) then
          v[ 6 ] = v[ 6 ] + Attack.cell_dist( c, act )
        end
      end

      if farthest == nil
      or multi_cmp( v, best_v ) > 0 then -- ������ ���� ������, ���� �� �������� �����, ��� ��, ��� ���� �������
        best_v = v
        farthest = c
      end
    end

    if farthest ~= nil
    and farthest.cell ~= mover.cell then -- ���� ��������� ������ - ��, ��� �� �����, �� ���� ������ �� �����
      table.insert( actions, { target = farthest, prob = 500, escape_action = true } )
    end
  end

  -- �������� �������� �������� �� ������������� ������ �������� ����� (�������� � ������� ���-��� ����� ����� ��������)
  local res = random_choice( actions )

  if res.escape_action
  and target ~= nil then -- ������������ �����, ����� ����� ��� ���������� �������, ����� ����� ����� ��������� ���� �� ��������� � ���, � ������� ��� ������, ���� ������� �������������� ����
    mover.sdata.pref_target = target.cell
  end

  -- �����
  if res.attack == nil
  and res.next == nil
  and type( res.target ) == "table"
  and mover_atks.base ~= nil
  and mover_power < allies_power / 5.
  and not mover.thrower then -- ���� ���� ������, ������� ������ �� �� ���� ������� ����
    local cc, boxes = mover_atks.base.cells, {}

    for i = 1, cc.n do
      if Attack.cell_is_box( cc[ i ] ) then table.insert( boxes, cc[ i ] ) end
    end

    if table.getn( boxes ) > 0 then -- some box detected!
      local path = Attack.calc_path( mover, res.target )

      if path == nil then -- ���� ������
        if Game.Random( 99 ) < 70 then
          return { target = boxes[ Game.Random( 1, table.getn( boxes ) ) ], attack = "base" }
        end
      else
        local refcell = path[ math.min( table.getn( path ), mover.ap + 1 ) ].cell -- ������, �� ������� ����� �����
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


-- New! Function that computes actor, ally, and enemy data for AI functions
function compute_actor_ally_enemy( resistances )
  local actors, allies, enemies = {}, {}, {}
  local under_attack_units, can_attack_units = {}, {}


  local function augment_act( a, act )
    act.power = act.units * act.leadship
    act.att = Attack.act_get_par( a, "attack" )
    act.def = Attack.act_get_par( a, "defense" )
    act.init = Attack.act_get_par( a, "initiative" )
    act.krit = Attack.act_get_par( a, "krit" )
    act.baseatk = {}
    act.res = {}
    local total_avg_dmg = 0
    local total_res = 0

    for i = 1, table.getn( resistances ) do
      local min_dmg = Attack.act_get_dmg_min( a, resistances[ i ] )
      local max_dmg = Attack.act_get_dmg_max( a, resistances[ i ] )
      local avg_dmg = ( min_dmg + max_dmg ) / 2
      total_avg_dmg = total_avg_dmg + avg_dmg
      act.baseatk[ resistances[ i ] ] = { min_dmg = min_dmg, max_dmg = max_dmg, avg_dmg = avg_dmg }
      local res = Attack.act_get_res( a, resistances[ i ] )
      act.res[ resistances[ i ] ] = res
      total_res = total_res + res
    end

    act.total_avg_dmg = total_avg_dmg
    act.dangerous = act.units * act.att * act.total_avg_dmg * ( 1 + act.krit )
    act.avg_res = total_res / table.getn( resistances )
    act.res_factor = ( act.avg_res + 100 ) / 100
    act.toughness = act.def * act.res_factor
    act.resilience = act.totalhp * act.toughness

    return true
  end


  for i = 1, Attack.act_count() - 1 do
    local ally = Attack.act_ally( i )

    if ally
    or Attack.act_enemy( i ) then
      local act = Attack.get_caa( i, true )
      augment_act( i, act )
      table.insert( actors, act )
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


  local function atk_common_score( act )
    local atk_power = 0
    local total_targets = 0


    local function use_mass_ability( unit, no_spell, check_func )
      local targets = 0
  
      for i, act in ipairs( actors ) do
        if not act.spells[ no_spell ]
        and check_func( act, unit ) then
          targets = targets + 1
        end
      end

      return targets  
    end


    for name, atk in pairs( act.atks ) do
      if name ~= nil then
        if atk.dmgavg ~= 0 then
          atk_power = atk_power + act.units * atk.dmgavg * act.level * atk.targets.n
          total_targets = total_targets + atk.targets.n
        else
          if name == "cry" then
            local targets = use_mass_ability( act, 'effect_fear', function( act, unit ) return Attack.act_enemy( act, Attack.act_belligerent( unit ) ) and ( Attack.act_race( act ) == "human" or Attack.act_race( act ) == "elf" or Attack.act_race( act ) == "dwarf" or ( string.find( Attack.act_name( act ), "pirat" ) ) ) and Attack.act_level( act ) <= tonumber( Logic.obj_par( "special_wolf_cry", "level" ) ) and not Attack.act_feature( act, "mind_immunitet" ) end )
            atk_power = atk_power + act.units * act.level * act.level * targets * targets
            total_targets = total_targets + targets
          elseif name == "cast_sleep" then
            local targets = use_mass_ability( act, 'effect_sleep', function( act, unit ) return Attack.act_enemy( act, Attack.act_belligerent( unit ) ) and Attack.act_level( act ) <= tonumber( atk.custom_params.level ) and not Attack.act_feature( act, atk.custom_params.nfeatures ) end )
            atk_power = atk_power + act.units * act.level * act.level * targets * targets
            total_targets = total_targets + targets
          elseif name == "elf_song" then
            local targets = use_mass_ability( act, 'special_elf_song', function( act, unit ) return Attack.act_ally( act, Attack.act_belligerent( unit ) ) and Attack.act_race( act ) == "elf" end )
            atk_power = atk_power + act.units * act.level * act.level * targets * targets
            total_targets = total_targets + targets
          else
            atk_power = atk_power + act.units * act.level * act.level * atk.targets.n * atk.targets.n
            total_targets = total_targets + atk.targets.n
          end
        end
      end
    end

    total_targets = math.max( total_targets, ( act.init + act.ap ) / 2 )

    return atk_power, total_targets
  end


  local function unit_score( act )
    local lead_power = act.leadship * act.units
    local hp_power = act.totalhp
    local power = lead_power + hp_power + act.atk_power

    return power 
  end


  local totals = { dangerous = { total = 0, ally = 0, enemy = 0 },
                   toughness = { total = 0, ally = 0, enemy = 0 },
                   resilience = { total = 0, ally = 0, enemy = 0 },
                   power = { total = 0, ally = 0, enemy = 0 },
                   level = { total = 0, ally = 0, enemy = 0 },
                   init = { total = 0, ally = 0, enemy = 0 },
                   ap = { total = 0, ally = 0, enemy = 0 },
                   att = { total = 0, ally = 0, enemy = 0 },
                   def = { total = 0, ally = 0, enemy = 0 },
                   krit = { total = 0, ally = 0, enemy = 0 },
                   res = { total = {}, ally = {}, enemy = {} },
                   total_avg_dmg = { total = 0, ally = 0, enemy = 0 },
                   atk_power = { total = 0, ally = 0, enemy = 0 },
                   unit_score = { total = 0, ally = 0, enemy = 0 },
                   threat = { total = 0, ally = 0, enemy = 0 } }

  local maxes = { dangerous = { total = 0, ally = 0, enemy = 0 },
                  toughness = { total = 0, ally = 0, enemy = 0 },
                  resilience = { total = 0, ally = 0, enemy = 0 },
                  power = { total = 0, ally = 0, enemy = 0 },
                  level = { total = 0, ally = 0, enemy = 0 },
                  init = { total = 0, ally = 0, enemy = 0 },
                  ap = { total = 0, ally = 0, enemy = 0 },
                  att = { total = 0, ally = 0, enemy = 0 },
                  def = { total = 0, ally = 0, enemy = 0 },
                  krit = { total = 0, ally = 0, enemy = 0 },
                  res = { total = {}, ally = {}, enemy = {} },
                  total_avg_dmg = { total = 0, ally = 0, enemy = 0 },
                  atk_power = { total = 0, ally = 0, enemy = 0 },
                  unit_score = { total = 0, ally = 0, enemy = 0 },
                  threat = { total = 0, ally = 0, enemy = 0 } }


  local mins = { dangerous = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 toughness = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 resilience = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 power = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 level = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 init = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 ap = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 att = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 def = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 krit = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 res = { total = {}, ally = {}, enemy = {} },
                 total_avg_dmg = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 atk_power = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 unit_score = { total = 1e10, ally = 1e10, enemy = 1e10 },
                 threat = { total = 1e10, ally = 1e10, enemy = 1e10 } }


  for i = 1, table.getn( resistances ) do
    for kind, v in pairs( totals.res ) do
      totals.res[ kind ][ resistances[ i ] ] = 0
    end

    for kind, v in pairs( maxes.res ) do
      maxes.res[ kind ][ resistances[ i ] ] = -1e10
    end

    for kind, v in pairs( mins.res ) do
      mins.res[ kind ][ resistances[ i ] ] = 1e10
    end
  end


  local function get_totals( kind, act )
    for name, v in pairs( totals ) do
      if name == "res" then
        for res, value in pairs( act.res ) do
          totals[ name ][ kind ][ res ] = totals[ name ][ kind ][ res ] + value + 100

          if value > maxes[ name ][ kind ][ res ] then
            maxes[ name ][ kind ][ res ] = value
          end

          if value < mins[ name ][ kind ][ res ] then
            mins[ name ][ kind ][ res ] = value
          end
        end
      else
        totals[ name ][ kind ] = totals[ name ][ kind ] + act[ name ]

        if act[ name ] > maxes[ name ][ kind ] then
          maxes[ name ][ kind ] = act[ name ]
        end

        if act[ name ] < mins[ name ][ kind ] then
          mins[ name ][ kind ] = act[ name ]
        end
      end
    end
  end


  local res_danger = { total = {}, ally = {}, enemy = {} }

  for i = 1, table.getn( resistances ) do
    res_danger.total[ resistances[ i ] ] = 0
    res_danger.ally[ resistances[ i ] ] = 0
    res_danger.enemy[ resistances[ i ] ] = 0
  end

  for i, act in ipairs( actors ) do
    for res, dmg in pairs( act.baseatk ) do
      res_danger.total[ res ] = res_danger.total[ res ] + act.units * act.att * act.baseatk[ res ].avg_dmg * ( 1 + act.krit )

      if Attack.act_ally( act ) then
        res_danger.ally[ res ] = res_danger.ally[ res ] + act.units * act.att * act.baseatk[ res ].avg_dmg * ( 1 + act.krit )
      else
        res_danger.enemy[ res ] = res_danger.enemy[ res ] + act.units * act.att * act.baseatk[ res ].avg_dmg * ( 1 + act.krit )
      end
    end

    actors[ i ].atk_power, actors[ i ].threat = atk_common_score( act )
    actors[ i ].unit_score = unit_score( act )
    get_totals( "total", act )
--    local nomag_immune = not Attack.act_feature( act, "magic_immunitet" )

    if Attack.act_ally( act ) then
      table.insert( allies, act )
      get_totals( "ally", act )

--      if nomag_immune then nomag_immune_allies = nomag_immune_allies + 1 end
    else
      table.insert( enemies, act )
      get_totals( "enemy", act )

--      if nomag_immune then nomag_immune_enemies = nomag_immune_enemies + 1 end
    end
  end

  local averages = { dangerous = { total = 0, ally = 0, enemy = 0 },
                     toughness = { total = 0, ally = 0, enemy = 0 },
                     resilience = { total = 0, ally = 0, enemy = 0 },
                     power = { total = 0, ally = 0, enemy = 0 },
                     level = { total = 0, ally = 0, enemy = 0 },
                     init = { total = 0, ally = 0, enemy = 0 },
                     ap = { total = 0, ally = 0, enemy = 0 },
                     att = { total = 0, ally = 0, enemy = 0 },
                     def = { total = 0, ally = 0, enemy = 0 },
                     krit = { total = 0, ally = 0, enemy = 0 },
                     res = { total = {}, ally = {}, enemy = {} },
                     total_avg_dmg = { total = 0, ally = 0, enemy = 0 },
                     atk_power = { total = 0, ally = 0, enemy = 0 },
                     unit_score = { total = 0, ally = 0, enemy = 0 },
                     threat = { total = 0, ally = 0, enemy = 0 } }


  local total_numbers = { total = table.getn( actors ),
                          ally = table.getn( allies ),
                          enemy = table.getn( enemies ) }

  for name, v in pairs( totals ) do
    for kind, w in pairs( v ) do
      if name == "res" then
        for res, value in pairs( w ) do
          averages[ name ][ kind ][ res ] = ( value - total_numbers[ kind ] * 100 ) / total_numbers[ kind ]
        end
      else
        averages[ name ][ kind ] = w / total_numbers[ kind ]
      end
    end
  end

  local pct_danger = { total = {}, ally = {}, enemy = {} }

  for kind, danger in pairs( res_danger ) do
    for res, v in pairs( danger ) do
      pct_danger[ kind ][ res ] = v / totals.dangerous[ kind ]
    end
  end

  local ranks = { actors = {}, allies = {}, enemies = {} }


  local function update_ranks( ranks )
    local allies_counter, enemies_counter = 0, 0

    for i, act in ipairs( actors ) do
      ranks.actors[ i ] = {}
      local total = 0

      for name, v in pairs( totals ) do
        if name == "res" then
          ranks.actors[ i ][ name ] = {}

          for res, value in pairs( act.res ) do
            local res_value = ( 100 + act[ name ][ res ] ) / totals[ name ][ "total" ][ res ]
            ranks.actors[ i ][ name ][ res ] = res_value
            total = total + res_value
          end
        else
          local name_value = act[ name ] / totals[ name ][ "total" ]
          ranks.actors[ i ][ name ] = name_value
          total = total + name_value
        end
      end

      ranks.actors[ i ].total = total
      local total_allies, total_enemies = 0, 0
  
      if Attack.act_ally( act ) then
        allies_counter = allies_counter + 1
        ranks.allies[ allies_counter ] = {}

        for name, v in pairs( totals ) do
          if name == "res" then
            ranks.allies[ allies_counter ][ name ] = {}

            for res, value in pairs( act.res ) do
              local res_value = ( 100 + act[ name ][ res ] ) / totals[ name ][ "ally" ][ res ]
              ranks.allies[ allies_counter ][ name ][ res ] = res_value
              total_allies = total_allies + res_value
            end
          else
            local name_value = act[ name ] / totals[ name ][ "ally" ]
            ranks.allies[ allies_counter ][ name ] = name_value
            total_allies = total_allies + name_value
          end
        end

        ranks.allies[ allies_counter ].total = total_allies
      else
        enemies_counter = enemies_counter + 1
        ranks.enemies[ enemies_counter ] = {}

        for name, v in pairs( totals ) do
          if name == "res" then
            ranks.enemies[ enemies_counter ][ name ] = {}

            for res, value in pairs( act.res ) do
              local res_value = ( 100 + act[ name ][ res ] ) / totals[ name ][ "enemy" ][ res ]
              ranks.enemies[ enemies_counter ][ name ][ res ] = res_value
              total_enemies = total_enemies + res_value
            end
          else
            local name_value = act[ name ] / totals[ name ][ "enemy" ]
            ranks.enemies[ enemies_counter ][ name ] = name_value
            total_enemies = total_enemies + name_value
          end
        end

        ranks.enemies[ enemies_counter ].total = total_enemies
      end
    end
  end

  update_ranks( ranks )

  return actors, allies, enemies, totals, maxes, mins, averages, res_danger, pct_danger, ranks, under_attack_units, can_attack_units
end


function spell_auto_cast( spells, spellattacks )
--[[
���������:
    spells - ������������� ������ ��������� (�� ������� ������� ����) ������ � ����� ���_�����=�������
    spellattacks - ������ ���� ������
        .avcells([first_target]) - ���������� ������ ��������� ������ ��� ������� �����, ���� ����� first_target, �� ���� ��������� ������������, � first_target ������ ������ ����
        .applicable(actor) - true, ���� ���� ����� ��������� �� ������ ����
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
  end  -- ������ ������ ����

  local resistances = {}
  local str_resistances = Game.Config( 'resistances' )
  local number_resistances = text_par_count( str_resistances )
  
  if number_resistances > 1 then
    for j = 1, number_resistances do
      local sub_string = text_dec( str_resistances, j )
      table.insert( resistances, sub_string )
    end
  end

  -- ��������� ������ ������ � ����� � ������� �����
  local actors, allies, enemies, totals, maxes, mins, averages, res_danger, pct_danger, ranks, under_attack_units, can_attack_units = compute_actor_ally_enemy( resistances )
--  local actors, allies, enemies = {}, {}, {}
--  local nomag_immune_allies, nomag_immune_enemies = 0, 0
  local allies_power, enemies_power = 0, 0
  local avg_ally_init, avg_enemy_init = 0, 0
  local a2e = limit_value( totals.power.ally / totals.power.enemy, 0.1, 10 )
  local e2a = limit_value( totals.power.enemy / totals.power.ally, 0.1, 10 )


  local function common_score( act )
    local lead_power = act.leadship * act.units
    local power = 0
    
    if act.unit_score ~= nil then
      power = ( act.unit_score / 3 ) / math.max( 1, lead_power )
    end

    return power 
  end


--  local min_score = math.ceil( math.max( totals.power.ally, totals.power.enemy ) / 100 )
  local min_score = 0

  -- �������� �������� 7 ������ ��� �������������
  local spellsToUse = {}

  for name, level in pairs( spells ) do -- ������� �������� ��� ����� � ������
    table.insert( spellsToUse, name )
  end

  local ehero_max_spells = tonumber( Game.Config( 'ehero_max_spells' ) )

  while table.getn( spellsToUse ) > ehero_max_spells do -- ������� �� ������ ����� �� ��� ���, ���� �� ����� �� ������ 7-�
    spells[ table.remove( spellsToUse, Game.Random( 1, table.getn( spellsToUse ) ) ) ] = nil
  end
  -- spellsToUse = {}

  -- ��������� ����� ��� ������, ���� ��� �� ������
  if spellattacks == nil then
    spellattacks = {}
    for name, level in pairs( spells ) do
      spellattacks[ name ] = Attack.build_spell_attack( name, level )
    end
  end

  local cast = {}


  local function find_ally_or_enemy_pos( act, actor_table )
    for i, act_tab in ipairs( actor_table ) do
      if act_tab.cell == act.cell then
        return i
      end
    end
  end


  local function find_act( act )
    if act == nil then
      return nil, nil, nil
    end

    local actor_pos = 0

    for i, act_tab in ipairs( actors ) do
      if act_tab.cell == act.cell then
        act = act_tab
        actor_pos = i
        break
      end
    end

    local ally_or_enemy_pos = 0

    if Attack.act_ally( act ) then
      ally_or_enemy_pos = find_ally_or_enemy_pos( act, allies )
    else
      ally_or_enemy_pos = find_ally_or_enemy_pos( act, enemies )
    end

    return act, actor_pos, ally_or_enemy_pos
  end


  local function get_damage_score( cell, res_type, avg_dmg, chance, duration, spell_name, ignore_res, prc, cold_fear )
    local res = {}

    for i = 1, table.getn( res_type ) do
      res[ i ] = ( 100 - Attack.act_get_res( cell, res_type[ i ] ) * ( 1 - ignore_res / 100 ) ) / 100
    end

    local k = 0

    if Attack.act_ally( cell ) then
      k = -1
      prc = prc / 100
    else
      k = 1
      prc = 1
    end

    local act, act_pos = find_act( Attack.get_caa( cell, true ) )

    if act ~= nil
    and act_pos ~= 0 then
      if cold_fear == nil then
        cold_fear = { false }
      end
  
      local cold_res = {}
      local cold_chance = {}

      for i = 1, table.getn( cold_fear ) do
        cold_res[ i ] = 1
        cold_chance[ i ] = 0

        if cold_fear[ i ] then
          if Attack.act_feature( act, "freeze_immunitet" ) then
            chance[ i ] = 0
          elseif Attack.act_feature( act, "fire_immunitet" )
          or Attack.act_race( act, "demon" ) then
            cold_chance[ i ] = Attack.act_get_res( act, "fire" ) + 30
            chance[ i ] = chance[ i ] + cold_chance[ i ]
          end

          cold_res[ i ] = 0
        end
      end

      for i = 1, table.getn( duration ) do
        duration[ i ] = res_dur( nil, act, spell_name, duration[ i ], res_type[ i ], true, cold_fear[ i ] )
      end

      local score, effect_score = 0, 0
      
      for i = 1, table.getn( res ) do
        score = score + math.min( act.totalhp, avg_dmg * res[ i ] * prc ) * ranks.actors[ act_pos ].total

        if cold_chance[ i ] > 50 then
          effect_score = effect_score + duration[ i ]
        else
          effect_score = effect_score + ( 1 + math.max( 0, ( chance[ i ] - ( 100 - res[ i ] * cold_res[ i ] * 100 ) ) / 100 * duration[ i ] ) )
        end
      end

      score = score / table.getn( res )
      effect_score = k * effect_score
      score = score * effect_score * ( 1 + averages.power.enemy / averages.power.ally )
  
      if Attack.act_feature( act, "pawn" ) then
        score = score / 10;
      end
  
      return score, res
    else
      return 0
    end
  end


  local function common_spell_7_in_1( applicable, spell_name, spell_level, ehero_level, res_type )
    local cells_rating = {}

    for i = 0, Attack.cell_count() - 1 do
      local cell = Attack.cell_get( i )
      local min_dmg, max_dmg, chance, duration

      if spell_name == "spell_fire_rain" then
        min_dmg, max_dmg, chance, duration = pwr_fire_rain( spell_level, ehero_level )
      elseif spell_name == "spell_fire_ball" then
        min_dmg, max_dmg, chance, duration = pwr_fire_ball( "epicentre", spell_level, ehero_level )
      elseif spell_name == "spell_ice_serpent" then
        min_dmg, max_dmg, chance, duration = pwr_ice_serpent( "epicentre", spell_level, ehero_level )
      end

      local id = Attack.cell_id( cell )
      local avg_dmg = ( min_dmg + max_dmg ) / 2

      if cell ~= nil
      and applicable( cell ) then
        local score = 0

        if spell_name == "spell_ice_serpent" then
          local dmg = common_freeze_im_vul( cell, avg_dmg, avg_dmg )
          score = get_damage_score( cell, { res_type }, dmg, { chance }, { duration }, spell_name, 0, 100, { true } )
        else
          score = get_damage_score( cell, { res_type }, avg_dmg, { chance }, { duration }, spell_name, 0, 100 )
        end

        cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
      end

      if spell_name == "spell_fire_ball" then
        min_dmg, max_dmg, chance, duration = pwr_fire_ball( "periphery", spell_level, ehero_level )
      elseif spell_name == "spell_ice_serpent" then
        min_dmg, max_dmg, chance, duration = pwr_ice_serpent( "periphery", spell_level, ehero_level )
      end

      avg_dmg = ( min_dmg + max_dmg ) / 2

      for dir = 0, 5 do
        local c = Attack.cell_adjacent( cell, dir )

        if c ~= nil
        and applicable( c ) then
          local score = 0

          if spell_name == "spell_ice_serpent" then
            local dmg = common_freeze_im_vul( c, avg_dmg, avg_dmg )
            score = get_damage_score( c, { res_type }, dmg, { chance }, { duration }, spell_name, 0, 100, { true } )
          else
            score = get_damage_score( c, { res_type }, avg_dmg, { chance }, { duration }, spell_name, 0, 100 )
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


  -- �������� ���������� ������ (���.��� � ���.�����)
  if spells.spell_fire_rain then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_fire_rain.applicable, "spell_fire_rain", spells.spell_fire_rain, ehero_level, "fire" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_fire_rain", spells.spell_fire_rain, ignore_mana, max_rating )
--      Attack.log( "spell_prob_log", "name", "spell_fire_rain", "special", max_rating )
      table.insert( cast, { spell = "spell_fire_rain", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_fire_ball then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_fire_ball.applicable, "spell_fire_ball", spells.spell_fire_ball, ehero_level, "fire" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_fire_ball", spells.spell_fire_ball, ignore_mana, max_rating )
--      Attack.log( "spell_prob_log", "name", "spell_fire_ball", "special", max_rating )
      table.insert( cast, { spell = "spell_fire_ball", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_ice_serpent then
    local tid, max_rating = common_spell_7_in_1( spellattacks.spell_ice_serpent.applicable, "spell_ice_serpent", spells.spell_ice_serpent, ehero_level, "physical" )

    if tid ~= nil
    and max_rating > min_score then
      max_rating = common_spell_mana( "spell_ice_serpent", spells.spell_ice_serpent, ignore_mana, max_rating )
--      Attack.log( "spell_prob_log", "name", "spell_ice_serpent", "special", max_rating )
      table.insert( cast, { spell = "spell_ice_serpent", target = { cell = tid }, prob = max_rating } )
    end
  end


  local function ck_canatk_thrower( act )
    return can_attack_units[ act.cell ]
    and Attack.act_is_thrower( act )
    and Attack.act_enemy( act )
    and Attack.act_name( act ) ~= "ram"
  end


  local function rank_score( act, act_pos )
    local score = act.unit_score * ranks.actors[ act_pos ].total

    return score
  end


  local function get_act_damage_score( act, act_pos, good )
    local kind = "ally"
    local score = 0

    if good then
      kind = "enemy"
    end

    local total_avg_eff_dmg = 0

    for res, dmg in pairs( act.baseatk ) do
      total_avg_eff_dmg = total_avg_eff_dmg + dmg.avg_dmg * ( 1 - pct_danger[ kind ][ res ] )
    end

    score = total_avg_eff_dmg * act.units * act.att / averages.def[ kind ] * ranks.actors[ act_pos ].total

    return score
  end


  local function common_spell_score( act, act_pos, spell_level, spell_name, ehero_level, function_name, good )
    local score = get_act_damage_score( act, act_pos, good )
    local spell_power = function_name( spell_level, ehero_level )
    local duration = int_dur( spell_name, spell_level, nil, nil, ehero_level )
    spell_power = spell_power / 100 * duration
    score = score * spell_power

    return score
  end


  if spells.spell_shroud then
    local cells_rating = {}

    for i = 0, Attack.cell_count() - 1 do
      local cell = Attack.cell_get( i )
      local id = Attack.cell_id( cell )

      if cell ~= nil
      and spellattacks.spell_shroud.applicable( cell ) then
        local act, act_pos = find_act( Attack.get_caa( cell, true ) )

        if act ~= nil
        and act_pos ~= 0 then
          if ck_canatk_thrower( act )
          and not Attack.act_is_spell( act, "totem_shroud" ) then
            local score = common_spell_score( act, act_pos, spells.spell_shroud, "spell_shroud", ehero_level, pwr_shroud, false )
            cells_rating[ id ] = tonum( cells_rating[ id ] ) + score
          end
        end
      end

      for dir = 0, 5 do
        local c = Attack.cell_adjacent( cell, dir )

        if c ~= nil
        and spellattacks.spell_shroud.applicable( c ) then
          local act, act_pos = find_act( Attack.get_caa( c, true ) )

          if act ~= nil
          and act_pos ~= 0 then
            if ck_canatk_thrower( act )
            and not Attack.act_is_spell( act, "totem_shroud" ) then
              local score = common_spell_score( act, act_pos, spells.spell_shroud, "spell_shroud", ehero_level, pwr_shroud, false )
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
--      Attack.log( "spell_prob_log", "name", "spell_shroud", "special", max_rating )
      table.insert( cast, { spell = "spell_shroud", target = { cell = tid }, prob = max_rating } )
    end
  end

  if spells.spell_pain_mirror then
    local applicable = spellattacks.spell_pain_mirror.applicable
    local max_score, tid = min_score

    for i, act in ipairs( enemies ) do
      local pos = find_ally_or_enemy_pos( act, enemies )

      if applicable( act ) then
        local last_dmg = tonum( Attack.val_restore( act, "last_dmg" ) ) * pwr_pain_mirror( spells.spell_pain_mirror, ehero_level ) / 100

        if last_dmg > 0 then
          local dt_index = Attack.val_restore( act, "damage_type_index" )

          if dt_index ~= nil then
            local str_resistances = Game.Config( 'resistances' )
            local sub_string = text_dec( str_resistances, dt_index + 1 )
            local res = ( 100 - Attack.act_get_res( act, sub_string ) ) / 100
            local score = math.min( act.totalhp, last_dmg * res ) * ranks.enemies[ pos ].total
  
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
--      Attack.log( "spell_prob_log", "name", "spell_pain_mirror", "special", max_score )
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
        local avg_dmg = ( min_dmg + max_dmg ) / 2
        local score = get_damage_score( Attack.get_cell( act ), { "magic" }, avg_dmg, { shock }, { duration }, "spell_lightning", 0, 100 )
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
              score = score + get_damage_score( Attack.get_cell( act ), { "magic" }, avg_dmg, { shock }, { duration }, "spell_lightning", 0, 100 )
              local unit = Attack.get_caa( Attack.get_cell( act ), true )
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
--      Attack.log( "spell_prob_log", "name", "spell_lightning", "special", max_score )
      table.insert( cast, { spell = "spell_lightning", target = { cell = tid }, prob = max_score } )
    end
  end

  -- ��������� ������������� ������ (������ � �������)
  local function ck_none() return true end

  local function ck_underatk( act ) -- ������� ����� ����� ���������
    return under_attack_units[ act.cell ]
  end

  local function ck_underatk_not_temporary( act ) -- ������� ����� ����� ���������
    return under_attack_units[ act.cell ]
    and not Attack.act_temporary( act )
  end

  local function ck_canatk( act ) -- ������ ���� ����� ���������
    return can_attack_units[ act.cell ]
    and Attack.act_name( act ) ~= "ram"
  end

  local function ck_cantatk( act ) -- ������ ���� �� ����� ���������
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
        return ( ( Attack.act_get_par( a, "initiative" ) < averages.init.ally
        or Attack.act_get_par( a, "initiative" ) < averages.init.enemy )
        or ( Attack.act_ap( a ) < averages.ap.ally
        or Attack.act_ap( a ) < averages.ap.enemy )
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
        and Attack.act_leadership(a) * Attack.act_size(a) > totals.power.ally / 4.
        and not Attack.act_is_spell( a, "spell_bless" )
      end,
    spell_adrenalin =
      function( a )
        if Attack.act_ap( a ) > 0 then return false end -- �� ������� �� ���, ��� ��� �� �����

        if Attack.act_is_thrower( a ) then return true end

        local bel = Attack.act_belligerent( a )

        for dir = 0, 5 do -- ������� �� ���, ��� ������ ��������� ����� �� 1 ��
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
          and penalty_spells ) -- ������ ����� ��� �������� ������ (� �� ������) � ���� ������ (����� �����)
          or ( Attack.act_enemy( act )
          and bonus_spells
          and not penalty_spells ) -- ��� ����� - ��������
        else
          return ( Attack.act_ally( act )
          and penalty_spells )
          or ( Attack.act_enemy( act )
          and bonus_spells )
        end
      end,
    -- spell_reaction now increases morale - AI does not use morale
    spell_reaction = function( a ) return false end,
--    spell_reaction = function( a ) return Attack.act_get_par( a, "initiative" ) < averages.init.enemy end,
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
        return ( ( Attack.act_get_par( a, "initiative" ) > averages.init.enemy
        or Attack.act_get_par( a, "initiative" ) > averages.init.ally )
        or ( Attack.act_ap( a ) > averages.ap.enemy
        or Attack.act_ap( a ) > averages.ap.ally )
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
        and Attack.act_leadership( a ) * Attack.act_size( a ) > totals.power.enemy / 4.
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
        and Attack.act_level( a ) < maxes.level.ally
        and not Attack.act_is_spell( a, "effect_fear" )
      end,
    spell_plague =
      function( a )
        return Attack.act_race( a ) ~= "undead"
        and ( ck_canatk( a )
        or ck_underatk( a ) )
        and not Attack.act_is_spell( a, "spell_plague" )
      end, -- �.�. ���� ������� � ����� � ������
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
        and ( Attack.act_get_par( a, "defense" ) > averages.def.enemy
        or Attack.act_get_par( a, "defense" ) > averages.att.ally )
        and not Attack.act_is_spell( a, "spell_defenseless" )
      end
  }

  local function pwr_spell( name, unit, level, ehero_level )
    local func_name = string.gsub( name, "^spell_", "pwr_" )
    local baseatk = unit.atks.base
    local k, gain = 0, 20

    if name == "spell_haste" then
      local power = _G[ func_name ]( level, ehero_level )

      if unit.thrower then
        if under_attack_units[ unit.cell ] then
          k = ( power + unit.ap ) / averages.ap.enemy * gain
        end
      else
        k = power * unit.threat / averages.threat.ally * averages.ap.ally / unit.ap * gain
      end

    elseif name == "spell_slow" then
      local power = _G[ func_name ]( level, ehero_level )

      if unit.thrower then
        if under_attack_units[ unit.cell ] == nil then
          k = math.max( 1, unit.ap - power ) / averages.ap.ally * gain
        end
      else
        k = power * unit.threat / averages.threat.enemy * unit.ap / averages.ap.enemy * gain
      end

    elseif name == "spell_dragon_arrow" then
      local power = _G[ func_name ]( level, ehero_level )
      k = power * gain

    elseif name == "spell_pacifism" then
      local power, penalty = _G[ func_name ]( level, ehero_level )
      k = power - penalty / 2

    elseif name == "spell_berserker" then
      local unit_level, power = _G[ func_name ]( level, ehero_level )
      k = power

    elseif name == "spell_last_hero" then
      for i, spell in ipairs( unit.spells ) do
        if spell.name == "effect_poison"
        or spell.name == "effect_burn" then
          gain = gain * spell.duration
        end
      end

      local initialhp = Attack.act_get_par( unit, "health" ) * unit.initial_units
      local profit = math.min( 100, initialhp / unit.totalhp )
      k = gain * profit * 5

    elseif name == "spell_bless"
    or name == "spell_weakness" then
      local total_min_dmg, total_max_dmg = 0, 0

      for i = 1, table.getn( resistances ) do
        total_min_dmg = total_min_dmg + unit.baseatk[ resistances[ i ] ][ "min_dmg" ]
        total_max_dmg = total_max_dmg + unit.baseatk[ resistances[ i ] ][ "max_dmg" ]
      end

      k = total_max_dmg / total_min_dmg * gain

      if baseatk._3in1 then
        k = k * 3
      elseif baseatk.superhitback then
        k = k * unit.threat
      elseif baseatk._6in1 then
        k = k * 6
      end

    elseif name == "spell_reaction" then
      k = gain

    elseif name == "spell_adrenalin" then
      local power = _G[ func_name ]( level, ehero_level )

      if unit.ap == 0 then
        k = power * gain
      else
        k = ( unit.threat + power ) / averages.threat.enemy * gain
      end

        k = power 

        if level == 3 then
          k = k + unit.threat * gain
        end

    elseif name == "spell_gifts" then
      k = averages.threat.ally / unit.threat * gain

    elseif name == "spell_blind"
    or name == "spell_magic_bondage"
    or name == "spell_hypnosis"
    or name == "spell_crue_fate"
    or name == "spell_ram" then
      k = unit.threat / averages.threat.enemy * ( 1 + averages.power.enemy / averages.power.ally ) * gain * 10

    elseif name == "spell_scare" then
      k = unit.threat / averages.threat.enemy * ( averages.level.ally / unit.level )^2 * gain

    elseif name == "spell_oil_fog" then
      local min_dmg, max_dmg, duration, power = _G[ func_name ]( level, ehero_level )
      local resist, resistbase = Attack.act_get_res( unit, "fire" )
      k = power + resist

    else
      local power = _G[ func_name ]( level, ehero_level )

      if name == "spell_divine_armor" then
        local res_power = 0

        for i = 1, table.getn( resistances ) do
          if resistances[ i ] ~= "astral" then
            res_power = res_power + math.min( 95 - unit.res[ resistances[ i ] ], power ) * pct_danger.enemy[ resistances[ i ] ]
          end
        end

        power = res_power
      elseif name == "spell_pygmy"
      or name == "spell_plague" then
        power = power * unit.resilience / averages.resilience.enemy * ( 1 + averages.power.enemy / averages.power.ally ) * 10
      elseif name == "spell_fire_breath" then
        power = power * ( 1 - math.min( 95, averages.res.enemy.fire ) / 100 )
      elseif name == "spell_stone_skin" then
        power = math.min( 95 - unit.res.physical, power ) * pct_danger.enemy.physical
      elseif name == "spell_defenseless" then
        power = power * unit.def / averages.def.enemy * unit.def / averages.att.ally * unit.resilience / averages.resilience.enemy
      end

      k = power
    end

    k = k / 100

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
    spell_oil_fog = pwr_spell,
    spell_defenseless = pwr_spell
  }

  local function power_spell_dispell( c )
    local power = 10
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

    power = 1 + power / 100

    return power
  end


  local function get_good_bad_score( cell, spell_name, duration, level, ehero_level, good )
    if not good
    and Attack.act_is_spell( cell, "spell_ram" )
    and spell_name ~= "spell_ram" then
      return 0
    end

    local act, act_pos = find_act( Attack.get_caa( cell, true ) )

    if act ~= nil
    and act_pos ~= 0 then
      duration = res_dur( nil, act, spell_name, duration, nil, true )
      local score = get_act_damage_score( act, act_pos, good )
      local spell_power = 0
      
      if spell_name == "spell_dispell" then
        spell_power = power_spell_dispell( act )
      elseif powerSpells[ spell_name ] then
        spell_power = powerSpells[ spell_name ]( spell_name, act, level, ehero_level ) * duration
      end

      score = score * spell_power
  
      return score
    else
      return 0
    end
  end


  for name, level in pairs( spells ) do
    if goodSpells[ name ] or badSpells[ name ] then
      local check = goodSpells[ name ] -- ������� ��������
      local good = true

      if check == nil then
        check = badSpells[ name ]
        good = false
      end

      local avcells = spellattacks[ name ].avcells()

      if avcells.n > 0 then -- ���� �� ���� ��� �����
        local max_power, unit_power, target = 0, 0

        for i, c in ipairs( avcells ) do -- ���� ������ �������� �����,..
          if not Attack.act_is_spell( c, name )
          and check( c ) then -- ..�� ������� ��� ����� �����
            local power = get_good_bad_score( c, name, int_dur( name, level, nil, nil, ehero_level ), level, ehero_level, good )

            if power > max_power then
              max_power = power
              target = c
            end
          end
        end

        if target ~= nil then
          local prob = max_power

          if prob > min_score then
            prob = common_spell_mana( name, level, ignore_mana, prob )
--            Attack.log( "spell_prob_log", "name", name, "special", prob )
            table.insert( cast, { spell = name, target = target, prob = prob } )
          end
        end
      elseif text_dec( Logic.obj_par( name, "unit_count" ), level ) == "all" then -- ������ ���� ��������� �� ����
        local applicable = spellattacks[ name ].applicable
        local k = 0
        local array = enemies
        local good = false

        if goodSpells[ name ] then
          array = allies
          good = true
        end

        for i, act in ipairs( array ) do -- ������� ��������� ���� ������,..
          if not act.spells[ name ]
          and not Attack.act_is_spell( act, name )
          and applicable( act )
          and check( act ) then -- ..�� ������� ��� ����� ����� � �� ������� ����� �������� ���� �����
            local power = get_good_bad_score( Attack.get_cell( act ), name, int_dur( name, level, nil, nil, ehero_level ), level, ehero_level, good )
            k = k + power
          end
        end

        local prob = k

        if prob > min_score then
          prob = common_spell_mana( name, level, ignore_mana, prob )
--          Attack.log( "spell_prob_log", "name", name, "special", prob )
          table.insert( cast, { spell = name, prob = prob } )
        end
      end
    end
  end

  -- ������ ����� �� ���� ����
  local function score_def( c, name, level, ehero_level )
    local func_name = string.gsub( name, "^spell_", "pwr_" )
    local score, res, avg_dmg, chance, duration, ignore_res = 0, 0, 0, -100, 0, 0
    local min_dmg, max_dmg = 0, 0

    if name == "spell_magic_axe" then
      min_dmg, max_dmg = _G[ func_name ]( level, ehero_level )

    elseif name == "spell_ghost_sword" then
      min_dmg, max_dmg, ignore_res = _G[ func_name ]( level, ehero_level )

    elseif name == "spell_oil_fog" then
      min_dmg, max_dmg, duration, chance = _G[ func_name ]( level, ehero_level )
      chance = -chance * 100  -- this effectively negates the duration function so that it can be applied below...

    else
      min_dmg, max_dmg, chance, duration = _G[ func_name ]( level, ehero_level )
    end

    avg_dmg = ( min_dmg + max_dmg ) / 2
    score, res = get_damage_score( c, { Logic.obj_par( name, "typedmg" ) }, avg_dmg, { chance }, { duration }, name, ignore_res, 100 )

    if name == "spell_oil_fog" then
      chance = -chance / 100  -- restore to proper value, technically chance is spell power here
      res[ 1 ] = res[ 1 ] + 100

      -- this is from SPELLS.LUA for the spell_oil_fog_attack function and corresponding power check
      if ( res[ 1 ] <= -1 * chance ) or ( res[ 1 ] >= 80 ) then
        chance = 0
      end

      if chance > 0 then
        score = score + get_good_bad_score( c, name, duration, level, ehero_level, false )
      end
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
          local prob = battleSpells[ name ]( c, name, level, ehero_level )

          if prob > max_prob then
            max_prob = prob
            tid = c
          end
        end
      end

      if tid ~= nil then
        max_prob = common_spell_mana( name, level, ignore_mana, max_prob )
--        Attack.log( "spell_prob_log", "name", name, "special", max_prob )
        table.insert( cast, { spell = name, target = tid, prob = max_prob } )
      end
    end
  end

  -- ������ ���������
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
      if allyEnemyMidpoint == nil then -- ������� �����, ��� ����� ��������� �������� - ��� ������ ���� ����� ������ � �������
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
          prob = lead * ( 1 + averages.power.enemy / averages.power.ally )

        else
          local damage_bonus, hitpoint_bonus, defense_bonus, attack_bonus, res_bonus, text = summon_bonus( nil, name, true )
          local hp
          local danger = 1

          -- This is kind of lame, but I don't know how to get their hp from the ATOM
          if name == "spell_phoenix" then
            hp = 200 * level

            if level == 3 then
              hp = hp + 200
            end

          elseif name == "spell_evilbook" then
            hp = 200 * level
            danger = ( 1 - pct_danger.enemy.fire )
            local total_books = 1

            for i, act in ipairs( allies ) do
              if string.find( act.name, "evilbook" ) then
                total_books = total_books + 1
              end
            end

            hp = hp / total_books
          end

          hp = hp * ( 1 + hitpoint_bonus / 100 )
          local bonus = damage_bonus + defense_bonus + attack_bonus + res_bonus

          prob = math.ceil( hp * level * ( 1 + bonus / 100 ) ) * ( 1 + averages.power.enemy / averages.power.ally ) * danger
        end

        if prob > min_score then
          prob = common_spell_mana( name, level, ignore_mana, prob )
--          Attack.log( "spell_prob_log", "name", name, "special", prob )
          table.insert( cast, { spell = name, target = nearest, prob = prob } )
        end
      end
    end
  end

  -- ������
  if spells.spell_healing then -- �������
    local h = pwr_healing( spells.spell_healing, ehero_level )
    local maxprofit, target = 0

    for i, act in ipairs( spellattacks.spell_healing.avcells() ) do
      local a, a_pos = find_act( Attack.get_caa( act, true ) )

      if a ~= nil
      and a_pos ~= 0 then
        local currenthp = a.hp - ( a.totalhp - Attack.act_get_par( act, "health" ) * a.units )
        local profit = math.min( currenthp, h ) / h
        profit = math.min( 10, profit * a.hp / currenthp )
  
        if profit > maxprofit then maxprofit = profit; target = act; end
      end
    end

    local prob = maxprofit * h * ( 1 + averages.power.enemy / averages.power.ally )
    prob = common_spell_mana( "spell_healing", spells.spell_healing, ignore_mana, prob )

    if prob > min_score then
--      Attack.log( "spell_prob_log", "name", "spell_healing", "special", prob )
      table.insert( cast, { spell = "spell_healing", target = target, prob = prob } )
    end
  end

  if spells.spell_resurrection then -- �����������
    local h = pwr_resurrection( spells.spell_resurrection, ehero_level )
    local maxprofit = 0

    for i, act in ipairs( spellattacks.spell_resurrection.avcells() ) do
      local a, a_pos = find_act( Attack.get_caa( act, true ) )

      if a ~= nil
      and a_pos ~= 0 then
        local initialhp = Attack.act_get_par( act, "health" ) * a.initial_units
        local profit = math.min( initialhp - a.totalhp, h ) / h
        profit = math.min( 10, profit * initialhp / a.totalhp )
  
        if profit > maxprofit then maxprofit = profit; target = act; end
      end
    end

    local prob = maxprofit * h * ( 1 + averages.power.enemy / averages.power.ally )
    prob = common_spell_mana( "spell_resurrection", spells.spell_resurrection, ignore_mana, prob )

    if prob > min_score then
--      Attack.log( "spell_prob_log", "name", "spell_resurrection", "special", prob )
      table.insert( cast, { spell = "spell_resurrection", target = target, prob = prob } )
    end
  end

  if spells.spell_armageddon then
    local applicable = spellattacks.spell_armageddon.applicable
   	local min_dmg, max_dmg, burn, duration, prc = pwr_armageddon( spells.spell_armageddon, ehero_level )
    local avg_dmg = ( min_dmg + max_dmg ) / 2
    local score = 0

    for i, act in ipairs( actors ) do
      if applicable( act )
      and not Attack.act_feature( act, "magic_immunitet" ) then
        score = score + get_damage_score( Attack.get_cell( act ), { "fire" }, avg_dmg, { burn }, { duration }, "spell_armageddon", 0, prc )
      end
    end

    local prob = score

    if prob > min_score then
      prob = common_spell_mana( "spell_armageddon", spells.spell_armageddon, ignore_mana, prob )
--      Attack.log( "spell_prob_log", "name", "spell_armageddon", "special", prob )
      table.insert( cast, { spell = 'spell_armageddon', prob = prob } )
    end
  end

  if spells.spell_geyser then
    local applicable = spellattacks.spell_geyser.applicable
   	local min_dmg, max_dmg, count, freeze, stun, duration = pwr_geyser( spells.spell_geyser, ehero_level )
    local avg_dmg = ( min_dmg + max_dmg ) / 2
    local hits = count
    local score = 0

    for i, act in ipairs( enemies ) do
      if applicable( act )
      and not Attack.act_feature( act, "magic_immunitet" ) then
        score = score + get_damage_score( Attack.get_cell( act ), { "physical", "physical" }, avg_dmg, { freeze, stun }, { duration, duration }, "spell_geyser", 0, 100, { true, false } )

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
--      Attack.log( "spell_prob_log", "name", "spell_geyser", "special", prob )
      table.insert( cast, { spell = 'spell_geyser', prob = prob } )
    end
  end

  if spells.spell_phantom then
    local max_power, unit_power, target = 0, 0

    for i, c in ipairs( spellattacks.spell_phantom.avcells() ) do -- ��������� ������ �������� �����
      local act, act_pos = find_act( Attack.get_caa( c, true ) )
      local power = common_spell_score( act, act_pos, spells.spell_phantom, "spell_phantom", ehero_level, pwr_phantom, true )

      if power > max_power then
        max_power = power
        target = c
      end
    end

    if target ~= nil then
      local prob = max_power

      if prob > min_score then
        local av = spellattacks.spell_phantom.avcells( target ) -- ����� ��������� - ��������
        prob = common_spell_mana( "spell_phantom", spells.spell_phantom, ignore_mana, prob )
--        Attack.log( "spell_prob_log", "name", "spell_phantom", "special", prob )
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
      -- ������� ����� ������� �� ��������
      local animate_count = math.floor( power / undead_HP )
      -- �������
      local animate_real = math.min( animate_count, Attack.act_initsize( act ) )
      local benefit = animate_real / animate_count

      if benefit > .9 then -- ���������� ������ ���������� ���������� ����
        prob = power * ( 1 + averages.power.enemy / averages.power.ally )
--        prob = math.ceil( math.min( 2000, benefit * 1000 ) * e2a )
        prob = common_spell_mana( "spell_necromancy", spells.spell_necromancy, ignore_mana, prob )
--        Attack.log( "spell_prob_log", "name", "spell_necromancy", "special", prob )
        table.insert( cast, { spell = 'spell_necromancy', target = c, prob = prob } )
        break
      end
    end
  end

  if spells.spell_teleport then
    local max_power, target, thrower = 0

    for i, act in ipairs( allies ) do
      if act.thrower
      and act.units * act.leadship / totals.power.ally > .5
      and under_attack_units[ act.cell ] then -- ��� ������, ������� ���������� ����� �������� ����� �����
        thrower = act

        for i, c in ipairs( spellattacks.spell_teleport.avcells() ) do
          local power = Attack.act_leadership( c ) * Attack.act_size( c )

          if power > max_power
          and not Attack.act_is_thrower( c )
          and Attack.act_enemy( c )
          and Attack.act_get_par( c, "speed" ) <= 4 then
            local a = Attack.get_caa( c, true )
            local base = a.atks.base

            if base ~= nil then -- �������, ����� �� ���� ���� ��������� ������ �������
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

    if target ~= nil then -- ������������� ���������� ����� ��� ����� ������ �� �������
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
    elseif is_tactics_offencive( enemies, actors ) then -- ������� ��������������� ���� ����� � ��������� ��������
      local max_power = 0
      for i, act in ipairs( enemies ) do -- ���� ������ �������� ���������� �������
        local power = act.units * act.leadship
        if power > max_power
        and act.thrower then
          max_power = power
          target = act
        end
      end

      if target ~= nil then -- ����� ������� - ������ ���� ������ �������� ������ �����, ������� ������ �� ����� ���������
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

        if unit ~= nil then -- ������������� ����� ����� ��� ����� ����� � �������
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

    --[[if attacks.glot then -- �������� ������ �������� ������ �������
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
        for i=0,Attack.cell_count()-1 do -- ���� ��������� ������ � midp
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
                    if enemy then table.insert(targets, id) end -- �� ������ ����������� ��������� � 2 ���� ������
                end
            end
        end

        if table.getn(targets) > 0 then
            table.insert(use, {attack=attacks.gizmo, target=targets[Game.Random(1,table.getn(targets))], prob=1000})
        end

    end

    if table.getn(use) > 0 then return random_choice(use) end

end
