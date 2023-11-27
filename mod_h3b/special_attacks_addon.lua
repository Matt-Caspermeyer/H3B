-- AP

-- ***********************************************
-- * Íåáåñíàÿ Ñòðàæà
-- ***********************************************

function special_sky_guard()
 	local ccnt = Attack.cell_count()
	 local count = 0
 	local summon_cell = {}
	
  for i = 0, ccnt - 1 do
		  local cell = Attack.cell_get( i )

 		 if empty_cell( cell )
			 and Attack.cell_dist( 0, cell ) < 3 then
 		 		table.insert( summon_cell, cell )
 		 end 
 	end 
	
  if table.getn( summon_cell ) == 0 then return true end -- ???

--  target = summon_cell[ Game.CurLocRand( 1,table.getn( summon_cell ) ) ]
  local target = summon_cell[ Game.Random( 1,table.getn( summon_cell ) ) ]
  Attack.aseq_rotate( 0, target, "special" )
  dmgts = Attack.aseq_time( 0, "x" )

  --íàõîäèì áëèæàéøåãî âðàãà
  local nearest_dist, nearest_enemy, ang_to_enemy = 10e10, nil, 0

  for i = 1, Attack.act_count() - 1 do
    if Attack.act_enemy( i ) then
      local d = Attack.cell_dist( target, i )

      if d < nearest_dist then nearest_dist = d; nearest_enemy = i; end
    end
  end

  local k_min, k_max = correct_damage_minmax( Attack.get_caa( 0 ), text_range_dec( Attack.get_custom_param( "k" ) ) )
  local k = apply_difficulty_level_talent_bonus( Game.Random( k_min, k_max ) )
  k = k * ( 1 + tonumber( skill_power2( "glory", 3 ) ) / 100 )
--  local k = Game.CurLocRand( text_range_dec( Attack.get_custom_param( "k" ) ) ) --êîýô.

  if nearest_enemy ~= nil then ang_to_enemy = Attack.angleto( target, nearest_enemy ) end

  local king_count = Attack.act_size( 0 )  -- ñêîëüêî ìàãîâ
  local summon_unit = "griffin_spirit"
  local king_name = Attack.act_name( 0 )
  --ëèäåðñòâî ìàãîâ è ltvjyjd
  local king_lead = Attack.atom_getpar( king_name, "leadership" )
  local summon_lead = Attack.atom_getpar( summon_unit, "leadership" )
  -- ñêîëüêî ìîæíî ïðèçâàòü ïî ëèäåðñòâó
  local summon_count = math.ceil( king_lead * king_count / summon_lead * k / 100 --[[* ( 1 + tonumber( skill_power2( "summonner", 1 ) / 100 ) ) ]] )
  -- ðåàëüíî
  Attack.act_spawn( target, 0, summon_unit, ang_to_enemy, summon_count )
  Attack.act_nodraw( target, true )
  Attack.act_nodraw( target, false, dmgts )--+dmgts1 )
  Attack.act_animate( target, "appear", dmgts )
  fix_hitback( target )
  apply_hero_attack_defense_bonuses( target )
  Attack.log_label( "add_blog_summon_0" ) -- ðàáîòàåò
  Attack.log_special( summon_count, "<label=cpsn_" .. summon_unit .. ">" ) -- ðàáîòàåò

  return true
end

-- ***********************************************
-- * Îáîäðåíèå
-- ***********************************************
function calccells_special_encouragement()
	 for i = 0, Attack.cell_count() - 1 do
  		local cell = Attack.cell_get( i )

  		if ( Attack.act_race( cell ) == "elf"
			 or Attack.act_race( cell ) == "human" )
			 and Attack.act_ally( cell ) then 
   			Attack.multiselect( 0 )

   			return true
  		end 
 	end 

 	return true
end 


function special_encouragement()
	 local power = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "power" ) )
	 local duration = apply_difficulty_level_talent_bonus( Attack.get_custom_param( "duration" ) )
	
  Attack.act_aseq( 0, "cast" )
  local dmgts = Attack.aseq_time( 0, "x" )
 	local ccnt = Attack.cell_count()
 	local count = 0
	
  for i = 0, ccnt - 1 do
    local cell = Attack.cell_get( i )
  	
   	if ( Attack.act_race( cell ) == "elf"
			 or Attack.act_race( cell ) == "human" )
			 and Attack.act_ally( cell ) then 
  	  	local a = Attack.atom_spawn( cell, dmgts, "effect_encouragement", Attack.angleto( cell ) )
  		  Attack.act_del_spell( cell, "special_encouragement" )
    		Attack.act_apply_spell_begin( cell, "special_encouragement", duration, false )
  		  Attack.act_apply_par_spell( "initiative", 0, power, 0, duration, false)
  		  Attack.act_apply_par_spell( "attack", 0, power, 0, duration, false)
  		  Attack.act_apply_spell_end()
  			count = count + 1			
    end
  end

  Attack.resort()

  --	if count==0 then return false end
  return true
end 

-- CW

-- DS
-- ***********************************************
-- ������
-- ***********************************************
function special_sacrifice_calccells( enumerator )
  local cycle = Attack.get_cycle()

  if enumerator ~= nil then
    cycle = 1
  end

  if not Attack.is_computer_move() then
    Game.InfoHint( "bmsg_vamp_" .. ( cycle + 1 ) )
  end

  local acnt = Attack.act_count()

  if ( cycle == 0 ) then
    local appl = {}

    for i = 1, acnt - 1 do
      if not Attack.act_equal( 0, i )
					 and Attack.act_enemy( i ) then
        if Attack.act_applicable( i ) then
		     			if Attack.act_is_spell( i, "feat_bleeding" )
            table.insert( appl, i )
									 end
        end
      end
    end

    if table.getn( appl ) > 1 then
      for i, act in ipairs( appl ) do
        Attack.marktarget( act )
      end
    end

  elseif ( cycle == 1 ) then
    if enumerator == nil then
      enumerator = Attack.marktarget
    end

    local source = Attack.val_restore( "blood_sacrifice" )
    local hero_lead = Logic.hero_lu_item( "leadership", "count" )
    local k_min, k_max = correct_damage_minmax( Attack.get_caa( 0 ), text_range_dec( Attack.get_custom_param( "k" ) ) )  --����.
    local k = apply_difficulty_level_talent_bonus( Game.Random( k_min, k_max ) )  --����.
    local damage = k * Attack.act_size( 0 )

    if Attack.act_is_spell( source, "special_magic_shield" ) then
      damage = damage / 2
    end

    for j = 1, acnt-1 do
      if not Attack.act_equal( 0, j )
					 and Attack.act_enemy( j )
					 and not Attack.act_equal( j, source ) then
        if Attack.act_applicable( j ) then
       		 local size = Attack.act_size( j );
      		  Attack.act_size( j, size + 1 );
      		  
									 if ( Attack.act_size( j ) > size ) then
          --if (Attack.act_size(j)+1)*Attack.act_leadership(j) <= hero_lead then
         			if damage >= Attack.act_get_par( j, "health" ) then
              enumerator( j )
            end
			         
											 Attack.act_size( j, size );
          end
        end
      end
    end
  end

  return true
end

function special_sacrifice_attack()
  local cycle = Attack.get_cycle()
  local target
  local sname = ""

  if Attack.is_computer_move() then
    --if cycle ~= 0 then
    --  Game.MessageBox('����� �� ����� ���� ������ ��� ����� �� ����� ����')
    --end
    Attack.val_store( "blood_sacrifice", Attack.get_target() )
    target = Attack.cell_id( tonumber( Attack.val_restore( "target" ) ) )
    cycle = 1
  end

  if (cycle == 0) then
    Attack.val_store( "blood_sacrifice", Attack.get_target() )
    Attack.next( 0 )
  elseif (cycle == 1) then
    local source = Attack.val_restore( "blood_sacrifice" )
    
			 if target == nil then
      target = Attack.get_target()
    end
    
			 if ( ( source ~= nil )
			 and ( target ~= nil ) ) then
      Attack.aseq_rotate( 0, target, "power" )
      local dmgts = Attack.aseq_time( 0, "x" )
      local k_min, k_max = correct_damage_minmax( Attack.get_caa( 0 ), text_range_dec( Attack.get_custom_param( "k" ) ) )  --����.
      local k = apply_difficulty_level_talent_bonus( Game.Random( k_min, k_max ) )  --����.
      local damage = k * Attack.act_size( 0 )

      if Attack.act_is_spell( source, "special_magic_shield" ) then
        damage = damage / 2
      end

      local dmg_type = Attack.get_custom_param( "typedmg" )
      local resist, resistbase = Attack.act_get_res( source, dmg_type )

      if resist > 95 then
        resist = 95
      end

      damage = damage / ( 1 - resist / 100 )
      local count = math.floor( damage / Attack.act_get_par( target, "health" ) )
      local a = Attack.atom_spawn( source, dmgts, "magic_dagger", Attack.angleto( source ) )
      local dmgts2 = Attack.aseq_time(a, "x")
      Attack.atk_set_damage( dmg_type, damage / Attack.act_size( 0 ) );
      common_cell_apply_damage( source, dmgts + dmgts2 )
      local b = Attack.atom_spawn( target, dmgts + dmgts2, "hll_priest_resur_cast" )
      Attack.act_size( target, Attack.act_size( target ) + count )
      local damage, dead = Attack.act_damage_results( source )

      if dead == 0 then
        Attack.log( "sacrifice_1", "name", blog_side_unit( 0, 1 ), "spell", blog_side_unit( 0, 3 ) .. "<label=special_sacrifice_name>", "target", blog_side_unit( source, 0 ), "special", damage, "targeta", blog_side_unit( target, 0 ), "special2", count )
      else
        Attack.log( "sacrifice_2", "name", blog_side_unit( 0, 1 ), "spell", blog_side_unit( 0, 3 ) .. "<label=special_sacrifice_name>", "target", blog_side_unit( source, 0 ), "special", damage, "targeta", blog_side_unit( target, 0 ), "special2", count )
      end
    end
  end

  return true
end
