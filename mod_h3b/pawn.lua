-- BARIER PUSHER -- DELETE THIS STUFF

function barrier_set_attack() --ftag:chga -- selegd

  return Attack.change_attack(0)

end

function barrier_push()

  local t = Attack.get_target()
  local dir = Game.Ang2Dir(Attack.angleto(0,t))
  local c = Attack.cell_adjacent( t, dir )
  if Attack.cell_present(c) and Attack.cell_is_empty(c) then
    Attack.act_move( 0.52, 0.88, t, c )
  end
  return true
end

function features_pawn_heal(damage,addrage,attacker,receiver,minmax,userdata,hitbacking)

	if Attack.act_ally(attacker) or Attack.act_enemy(attacker) then 
	
	if Attack.act_need_cure(attacker) and Attack.atk_class()=="moveattack" then --Attack.cell_dist(attacker,receiver)==1 then
  	local cur_hp = Attack.act_hp(attacker)
  	local pawn_hp = Attack.act_hp(receiver)
  	--local name=Attack.act_name(attacker)
	  local max_hp = Attack.act_get_par(attacker,"health")
		local cure_hp=max_hp - cur_hp
		if cure_hp>pawn_hp then cure_hp=pawn_hp end 
		if minmax==0 then
			Attack.atom_spawn(attacker, 0, "effect_total_cure")
			Attack.act_cure(attacker, cure_hp)
		end 
	
		damage = cure_hp
	end 
  end
  --end
  return damage,addrage
end

function lightning_attack()

  local dist = tonumber(Attack.val_restore("dist"))

  local dist2table = {
    { d = 1.8, a = "hll_lightning18" },
    { d = 3.6, a = "hll_lightning36" },
    { d = 5.4, a = "hll_lightning54" }

    -- d   - distance
    -- a   - atom tag
  }

  --Attack.cam_shake(0, "quake_appear.envlp")

  Attack.log_label('null')
  local acnt = Attack.act_count()

  for i=1,acnt-1 do

    local d = Attack.cell_dist(0,i)
    if (d <= dist) and Attack.act_takesdmg(i) and (not Attack.act_pawn(i)) then

      --if Attack.act_busy(i) then
--        return false
  --    end

	  local min_dmg,max_dmg = text_range_dec(Attack.get_custom_param("damage"))
  	local dmg_type = Attack.get_custom_param("dmgtype")
		local  power = tonumber(Attack.val_restore("power"))
		Attack.atk_set_damage(dmg_type,min_dmg*power,max_dmg*power)
		
      Attack.act_aseq( 0, "attack" )
      Attack.act_damage(i)
      Attack.log_label('')

      -- seek best table item

      d = Attack.cell_mdist(0,i) -- dist in meters

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

        local a = Attack.atom_spawn(0,0,found_item.a,Attack.angleto(0,i))

        if (found_item.x == nil) then
          found_item.x = Attack.aseq_time(a, "x")
        end

        -- damage time
        Attack.dmg_timeshift(i,found_item.x)

        -- seqs of receiver time
        local hit_x = Attack.aseq_time( i, "x" )
        Attack.aseq_timeshift( i, found_item.x - hit_x )


        Attack.atom_spawn(i,found_item.x,"hll_lightning_after") -- may be need forestalling?

      end

    end

  end

  return true
end


function totem_update( i, name, totems )
  Attack.val_store( i, name, totems )

  if totems == "" then
    Attack.act_del_modificator( i, name, true )
    Attack.act_del_spell( i, "totem_" .. name )
  else
    local max = 0
    for m in string.gfind( totems, "<%d+,(%d+)>" ) do
      if tonumber( m ) > max then max = tonumber( m ) end
    end
    --Attack.act_attach_modificator(i, Attack.val_restore("param"), name, max/10)
    
    local param = Attack.val_restore( "param" )
    local count_par = text_par_count( param )

    for j = 1, count_par do 
    	 local p = text_dec( param, j )

    	 if p == "throw" then
			     local penalty = Attack.val_restore( "penalty" )

			     for r = 0, Logic.resistance() - 1 do
    			   Attack.act_attach_dmg_modificator_to_throw_attacks( i, Logic.resistance( r ), name .. j .. '_' .. r, 0, -penalty )
			     end
    	 else
  	    	local c1 = tonumber( text_dec( Attack.val_restore( "change" ), j ) )
	    	  local c2 = tonumber( text_dec( Attack.val_restore( "change_" ), j ) )
	    	  Attack.act_attach_modificator( i, p, name .. j, c1, c2 )
		    end
    end 

    Attack.act_apply_spell_begin( i, "totem_" .. name, -100, false )
    Attack.act_apply_spell_end()
  end
end


function totem_applicable( unit, self )
	 local val

	 if self == nil then
    val = Attack.val_restore
	 else
    val = function ( par ) return Attack.val_restore( self, par ) end
  end

 	local applicable = 0
 	local level = val( "level" )
 	local race = val( "race" )
	 local features = val( "features" )
	 local nfeatures = val( "nfeatures" )

 	-- если уровень юнита больше -- неприменимо
 	if level ~= nil
  and level ~= ""
  and Attack.act_level( unit ) > tonumber( level ) then
    return false
  end
	
 	-- если не все расы и не найдена раса юнита - неприменимо
	 if not ( race == nil
  or race == "all"
  or race == ""
  or string.find( race, Attack.act_race( unit ) ) ) then
    return false
  end

 	-- перебираем features из списка и ищем если не нашли ни одного - неприменимо
 	local feat_found=0

 	for i = 1, text_par_count( features ) do 
		  local ff = text_dec( features, i )
		  local f = Attack.act_feature( unit, ff )

		  if Attack.act_feature( unit, ff ) then feat_found = feat_found + 1 end 
	 end 

 	if feat_found == 0
  and features ~= "" then
    return false
  end

 	-- перебираем nfeatures из списка и если нашли хоть один - неприменимо
 	for i = 1, text_par_count( nfeatures ) do
		  local ff = text_dec( nfeatures, i )
		  local f = Attack.act_feature( unit, ff )

		  if Attack.act_feature( unit, ff )
    and nfeatures ~= "" then
      return false
    end 
 	end 
	
 	return true
end


function totem_modificators()
  local uid = "<" .. Attack.act_uid( 0 ) .. "," .. Attack.val_restore( "power" ) .. ">"
  local name = Attack.act_name( 0 )
  local max_health = Attack.val_restore( "max_health" )

  if max_health ~= nil then
    Attack.act_set_par( 0, "health", tonumber( max_health ) * tonumber( Attack.val_restore( "power" ) ) )
  end

  local bel = Attack.val_restore( "belligerent" )
  --if bel==nil then bel = Attack.val_restore("ally") end
  local check

  if Attack.val_restore( "ally" ) == "1" then check = Attack.act_ally end 

  if Attack.val_restore( "ally" ) == "0" then check = Attack.act_enemy end 

  if Attack.val_restore( "ally" ) == "-1" then check = Attack.act_chesspiece end 
  
  local dist = tonumber( Attack.val_restore( "dist" ) )

  for i = 1, Attack.act_count() - 1 do
    --if check(i, bel) then --or bel=="-1" then
    local totems = Attack.val_restore( i, name )

    if totems == nil then totems = "" end

    local affect, new_affect = false, true

    if string.find( totems, uid ) then affect = true end

    if not check( i, bel )
    or Attack.cell_dist( 0, i ) > dist then -- вне радиуса действия - снимаем эффект с этого юнита
      new_affect = false
    end

    if new_affect ~= affect then
      if new_affect then
        totems = totems .. uid
      else
        totems = string.gsub( totems, uid, "" )
      end
			 
      if totem_applicable( i ) then totem_update( i, name, totems ) end
    end
    --end
  end

  return true
end


function totem_ondamage( wnm, ts, dead )
  if dead then
    local uid = "<" .. Attack.act_uid( 0 ) .. "," .. Attack.val_restore( "power" ) .. ">"
    local name = Attack.act_name( 0 )

    for i = 1, Attack.act_count() - 1 do
      local totems = Attack.val_restore( i, name )

      if totems == nil then totems = "" end

      if string.find( totems, uid ) then
        if totem_applicable( i ) then totem_update( i, name, string.gsub( totems, uid, "" ) ) end 
      end
    end
  end

  return true
end


function totem_time()
  local time = tonumber( Attack.val_restore( "time_last" ) ) - 1

  if time <= 0 then 
	  	local name = Attack.act_name( 0 )

	  	if name ~= "trap" then
	  		 totem_ondamage( 0, 0, true )
	  	end

	  	Attack.log( "add_blog_remove_totem", "spell", blog_side_unit( 0, 1 ) )
	  	Attack.act_kill()
  else
    Attack.val_store( 0, "time_last", time )
  end 

  return true
end


function totem_cure()
  local cure = tonumber( Attack.get_custom_param( "cure" ) )
  local dist = tonumber( Attack.val_restore( "dist" ) )
  local power = tonumber( Attack.val_restore( "power" ) )
  local bel = Attack.val_restore( "belligerent" )
 	local count_cure, dmgts, dmgts1 = 0, 0, 0
	 local animation, effect = Attack.get_custom_param( "animation" ), Attack.get_custom_param( "effect" )

	--считаем количество жертв
		for i = 1, Attack.act_count() - 1 do
		  if Attack.cell_dist( 0, i ) <= dist
    and not Attack.act_pawn( i )
    and Attack.act_ally( i, bel ) then
  		  if Attack.act_applicable( i )
      and totem_applicable( i )
      and Attack.act_need_cure( i ) then 
				    count_cure = count_cure + 1
			   end 
		  end
		end

  if animation ~= ""
  and animation ~= nil
  and count_cure > 0 then 
  		if text_dec( animation, 1 ) == "effect" then 
  			 local a = Attack.atom_spawn( 0, 0, text_dec( animation, 2 ) )
  			 dmgts = Attack.aseq_time( a, "x" )	
  		else
 			  Attack.act_aseq( 0, text_dec( animation, 2 ) )
			   dmgts = Attack.aseq_time( 0, "x" )
  		end

  	 Attack.log( "add_blog_totem_life", "name", blog_side_unit( 0, 1 ) )
  end 

 	for i = 1, Attack.act_count() - 1 do
	   if Attack.cell_dist( 0, i ) <= dist
    and not Attack.act_pawn( i )
    and Attack.act_ally( i, bel ) then
  	   if Attack.act_applicable( i )
      and totem_applicable( i ) then 
    	   if Attack.act_need_cure( i ) then
    		    local cure_hp = cure * power
          local cur_hp = Attack.act_hp( i )
          local max_hp = Attack.act_get_par( i, "health" )
          local need_hp = max_hp - cur_hp

          if cure_hp >= need_hp then cure_hp = need_hp end 
        
   	  	   if effect ~= ""
          and effect ~= nil then
	  			      local d = Attack.atom_spawn( i, dmgts + dmgts1, text_dec( effect, 1 ) )

  				      if text_dec( effect, 2 ) == "true"
            or text_dec( effect, 2 ) == "1" then 
  					       dmgts1 = Attack.aseq_time( d, "x" ) + dmgts1
  				      else
  					       dmgts1 = Attack.aseq_time( d, "x" )
  				      end 
  			     end

          Attack.act_cure( i, cure_hp, dmgts + dmgts1 )

          if Attack.act_size( i ) > 1 then 
         		 Attack.log( 0.001, "add_blog_cure_2", "target", blog_side_unit( i, 0, 1 ), "special", cure_hp )
          else 
         		 Attack.log( 0.001, "add_blog_cure_1", "target", blog_side_unit( i, 0, 1 ), "special", cure_hp )
          end 
     	  end 
    	 end 
    end
  end 

  return true 
end


function totem_vampire()
  local min_dmg, max_dmg = text_range_dec( Attack.get_custom_param( "damage" ) )
  local dmg_type = Attack.get_custom_param( "dmgtype" )
  local dist = tonumber( Attack.val_restore( "dist" ) )
  local power = tonumber( Attack.val_restore( "power" ) )
  local max_health = tonumber( Attack.val_restore( "max_health" ) ) * power
  local bel = Attack.val_restore( "belligerent" )
	 local vamp, dmgts, dmgts1 = 0, 0, 0
	 local animation, effect = Attack.get_custom_param( "animation" ), Attack.get_custom_param( "effect" )
	 local count_target = 0
	
	 --считаем количество жертв
		for i = 1, Attack.act_count() - 1 do
		  if Attack.cell_dist( 0, i ) <= dist
    and not Attack.act_pawn( i ) then
  		  if Attack.act_applicable( i ) then 
				    count_target = count_target + 1
			   end 
		  end
		end

 	-- если есть анимация вампиризма и жертвы - запускаем
 	if animation ~= ""
  and animation ~= nil
  and count_target > 0 then 
  		if text_dec( animation, 1 ) == "effect" then 
  			 local a = Attack.atom_spawn( 0, 0, text_dec( animation, 2 ) )
  			 dmgts = Attack.aseq_time( a, "x" )
  		else
 			  Attack.act_aseq( 0, text_dec( animation, 2 ) )
			   dmgts = Attack.aseq_time( 0, "x" )
  		end
  end 

  -- теперь атакуем все жертвы...
 	for i = 1, Attack.act_count() - 1 do
		  if Attack.cell_dist( 0, i ) <= dist
    and not Attack.act_pawn( i ) then
  		  if Attack.act_applicable( i ) then 
  			   local damage = Game.Random( min_dmg * tonumber( power ), max_dmg * tonumber( power ) )
				    Attack.atk_set_damage( dmg_type, damage, damage )
			
			     --и кастим на них эффект вампиризма
	  	    if effect ~= ""
        and effect ~= nil then
  			     local d = Attack.atom_spawn( i, dmgts + dmgts1, text_dec( effect, 1 ) )

  			     if text_dec( effect, 2 ) == "true"
          or text_dec( effect, 2 ) == "1" then 
  				      dmgts1 = Attack.aseq_time( d, "x" ) + dmgts1
  			     else
  				      dmgts1 = Attack.aseq_time( d, "x" )
  			     end 
  		    end
      	
      	 common_cell_apply_damage( i, dmgts + dmgts1 )
      	 vamp = vamp + damage
  		  end 
  	 end
  end 

  -- клампим высосанное здоровье  
  local cur_hp = Attack.act_hp( 0 )

  if cur_hp + vamp >= max_health then
  	 vamp = max_health - cur_hp
	 end   

 	-- и восстанавливаем его вампиру
	 if cure_h ~= max_health
  and vamp ~= 0 then 
  	 Attack.act_cure( 0, vamp, dmgts + dmgts1 )
  	 --Attack.act_set_par( 0, "health", max_health )
    local a = Attack.atom_spawn( 0, dmgts + dmgts1, "effect_total_cure" )
  end 

  return true 
end


function totem_attack()
-- скрипт наносит урон 1 цели или нескольким, по врагу или по всем, с анимацией/эффектом и постэффектом. постэффект синхронный или последовательный
-- может использоваться в атаке или как ответ на удар
--attack=15-30,physical,20
--  local freeze_im=0.75 --25%
  --local freeze = tonumber(text_dec(attack,3))
  Attack.log_label('null')
  local min_dmg, max_dmg = text_range_dec( Attack.get_custom_param( "damage" ) )
  local dmg_type = Attack.get_custom_param( "dmgtype" )
  local target = Attack.get_custom_param( "target" )
  local animation, effect = Attack.get_custom_param( "animation" ), Attack.get_custom_param( "effect" )
  local dist = tonumber( Attack.val_restore( "dist" ) )
  local power = tonumber( Attack.val_restore( "power" ) )
  local ally = Attack.val_restore( "ally" )
  local bel = Attack.val_restore( "belligerent" )

  if bel == nil then bel = 1000 end
  
  --local  attack = Attack.val_restore("attack")
  Attack.atk_set_damage( dmg_type, min_dmg * tonumber( power ), max_dmg * tonumber( power ) )      
  local dmgts, dmgts1 = 0, 0
  local trg = Attack.get_target()
  
  if target == "attacker"
  and trg ~= nil then 
  -- цель нам подходит по применимости атаки и стороне врага  
    if Attack.act_applicable( trg )
    and ( ( Attack.act_enemy( trg, bel )
    and ally == "0" )
    or ally == "-1" ) then
   	  if animation ~= ""
      and animation ~= nil then
  		    if text_dec( animation, 1 ) == "effect" then 
  			     local a = Attack.atom_spawn( 0, 0, text_dec( animation, 2 ) )
  			     dmgts = Attack.aseq_time( a, "x" )	
  		    else
 			      Attack.act_aseq( 0, text_dec( animation, 2 ) )
			       dmgts = Attack.aseq_time( 0, "x" )
  		    end
  	   end 

   	  if effect ~= ""
      and effect ~= nil then
  			   local b = Attack.atom_spawn( trg, dmgts, text_dec( effect, 1 ) )
  			   dmgts1 = Attack.aseq_time( b, "x" )
  	   end

  	   common_cell_apply_damage(trg,dmgts+dmgts1)
    end 
  end 

  if target == "all" then 
    local count_target = 0

    -- считаем количесвто целей
    for i = 1, Attack.act_count() - 1 do
      if Attack.cell_dist( 0, i ) <= dist
      and not Attack.act_pawn( i )
      and Attack.act_applicable( i ) then
			     if ( Attack.act_enemy( i, bel )
        and ally == "0" )
        or ally == "-1" then
				      count_target = count_target + 1
			     end 
    		end 
    end 

    -- если есть хоть одна - запускаем эффект атаки
	  	if animation ~= ""
    and animation ~= nil
    and count_target > 0 then
  		  if text_dec( animation, 1 ) == "effect" then 
  			   local a = Attack.atom_spawn( 0, 0, text_dec( animation, 2 ) )
  			   dmgts = Attack.aseq_time( a, "x" )	
  		  else
 			    Attack.act_aseq( 0, text_dec( animation, 2 ) )
			     dmgts = Attack.aseq_time( 0, "x" )
  		  end
  	 end 

    for i = 1, Attack.act_count() - 1 do
      if Attack.cell_dist( 0, i ) <= dist
      and not Attack.act_pawn( i )
      and Attack.act_applicable( i ) then
		      if ( Attack.act_enemy( i, bel )
        and ally == "0" )
        or ally == "-1" then
	  	      if effect ~= ""
          and effect ~= nil then
  			       local d = Attack.atom_spawn( i, dmgts + dmgts1, text_dec( effect, 1 ) )

  			       if text_dec( effect, 2 ) == "true"
            or text_dec( effect, 2 ) == "1" then 
          				dmgts1 = Attack.aseq_time( d, "x" ) + dmgts1
         			else
  				        dmgts1 = Attack.aseq_time( d, "x" )
  			       end 
  		      end

          common_cell_apply_damage(i, dmgts+dmgts1)
          Attack.log_label('')
		      end
      end
    end
  end 

  -- если цель 1
  if target == "one" then 
    local possible_target = {}
    local count_target = 0

    -- перебираем все юниты и запоминаем доступные для атаки
	   for i = 1, Attack.act_count() - 1 do
    	 if Attack.cell_dist( 0, i ) <= dist
      and not Attack.act_pawn( i )
      and Attack.act_applicable( i ) then
				    if ( Attack.act_enemy( i, bel )
        and ally == "0" )
        or ally == "-1" then
					     table.insert( possible_target, i )
					     count_target = count_target + 1
				    end 
			   end
		  end 

  		if count_target > 0 then
		    -- запускаем эффект атаки
	 	   if animation ~= ""
      and animation ~= nil
      and count_target > 0 then
   		   if text_dec( animation, 1 ) == "effect" then 
   			    local a = Attack.atom_spawn( 0, 0, text_dec( animation, 2 ) )
  	 		    dmgts = Attack.aseq_time( a, "x" )	
  		    else
 			      Attack.act_aseq( 0, text_dec( animation, 2 ) )
			       dmgts = Attack.aseq_time( 0, "x" )
  		    end
   	  end 

    		-- выбираем и атакуем случайную цель из списка доступных
		 	  trg = possible_target[ Game.Random( 1, count_target ) ]

	   	 if effect ~= ""
      and effect ~= nil then
   			  local d = Attack.atom_spawn( trg, dmgts, text_dec( effect, 1 ) )
 	 			  dmgts1 = Attack.aseq_time( d, "x" )
  	 	 end

      common_cell_apply_damage(trg, dmgts+dmgts1)
      Attack.log_label('')
    end
  end

  return true 
end


-- не используется! но позырыить полезно
function shaman_totem_turn()
  local bel, script = Attack.val_restore( "belligerent" ), Attack.val_restore( "script" )
  local power, check = Attack.val_restore( "power" )

  if Attack.val_restore( "ally" ) == "1" then check = Attack.act_ally else check = Attack.act_enemy end
  
  local dist = tonumber( Attack.val_restore( "dist" ) )
  local attack = Attack.val_restore( "attack" )

  for i = 1, Attack.act_count() - 1 do
    if check( i, bel )
    and Attack.cell_dist( 0, i ) <= dist then
      _G[ script ]( i, power, attack )
    end
  end

  return true
end


function explode_attack()
	local target=Attack.get_target()
  --if Attack.act_hp(0)==1 then
--  if dead then
--  	Attack.change_attack(0)
	  local min_dmg,max_dmg = text_range_dec(Attack.val_restore(target,"damage"))
  	local dmg_type = Attack.val_restore(target,"dmgtype")
  	local  dist = tonumber(Attack.val_restore(target,"dist"))
  	local  power = tonumber(Attack.val_restore(target,"power"))
		local bel = 1
	  local check
  	if Attack.val_restore("ally")=="1" then check = Attack.act_ally end 
  	if Attack.val_restore("ally")=="0" then check = Attack.act_enemy end 
  	if Attack.val_restore("ally")=="-1" then check = Attack.act_chesspiece end 

    local a = Attack.atom_spawn(target, 0, Attack.val_restore(target,"effect"))
    local dmgts = Attack.aseq_time(a, "x")
		Attack.atk_set_damage(dmg_type,min_dmg*tonumber(power),max_dmg*tonumber(power))      
		
		for i=1,Attack.act_count()-1 do
    	if Attack.cell_dist(target,i) <= dist and totem_applicable(i) and check(i, bel) then
	   	  common_cell_apply_damage(i, dmgts)
    	end 
		end 
--		Attack.act_kill(0)
--totem_applicable(i)
--  end

  return true
end

function features_explode(damage,addrage,attacker,receiver,minmax )

	if minmax==0 then 
		local hp=Attack.act_hp(receiver)
		if damage>hp then 
			Game.ExecSpell("feat_explode")
		end 
	end 	
	return damage, addrage

end

function totem_spell_cast(x,y, kill)

 local target=Attack.get_target() 
 if x~=nil and y~=nil and target==nil then
   for i=1,Attack.act_count()-1 do
   	 local x1,y1=Attack.act_get_center(i)
     if x1==x and y1==y and not Attack.act_pawn(i) then -- вне радиуса действия - снимаем эффект с этого юнита
				target = i
     end
	end 
 end 

  local  trg = Attack.get_custom_param("target")
  local  spell = Attack.get_custom_param("spell")
  local  type_param = Attack.get_custom_param("type_param")    
  local  param = Attack.get_custom_param("param")     
  local  change_ = Attack.get_custom_param("change_")       
  local  change = Attack.get_custom_param("change")         
  local  level = tonumber(Attack.get_custom_param("level"))
  local  duration = tonumber(Attack.get_custom_param("duration"))+1
  local dmgts,dmgts1=0,0
  
  local  animation,effect = Attack.get_custom_param("animation"),Attack.get_custom_param("effect")
  local  dist = tonumber(Attack.val_restore("dist"))
  local  power = tonumber(Attack.val_restore("power"))
  local ally = Attack.val_restore("ally")
  local  bel = Attack.val_restore("belligerent")
  if bel==nil then bel=1000 end

-- цель найдена и это атакующий юнит, дистанция тогда не нужна
  if trg == "attacker" and target~=nil then 

  -- цель нам подходит по применимости атаки, стороне и уровню врага  
  if Attack.act_applicable(target) and ((Attack.act_enemy(target,bel) and ally=="0") or ally=="-1") and Attack.act_level(target)<=level then
  -- кастуем эффекты и анимацию если они есть
   	if animation~="" and animation~=nil then
  		if text_dec(animation,1)=="effect" then 
  			local a = Attack.atom_spawn(0, 0, text_dec(animation,2))
  			dmgts = Attack.aseq_time(a, "x")	
  		else
 			  Attack.act_aseq( 0, text_dec(animation,2))
			  dmgts = Attack.aseq_time(0, "x")
  		end
  	end 
   	if effect~="" and effect~=nil then
  			local b = Attack.atom_spawn(target, dmgts, text_dec(effect,1))
  			dmgts1 = Attack.aseq_time(b, "x") 	
  	end
  -- накладываем спелл	и все параметры и скрипты
  	Attack.act_del_spell(target,spell)
    Attack.act_apply_spell_begin( target, spell, duration, false )
	    local count_par = text_par_count(type_param)
  	  for j=1,count_par do 
	    	local c1 = tonumber(text_dec(change,j))
	    	local c2 = tonumber(text_dec(change_,j))
	    	local par = text_dec(param,j)
    		if text_dec(type_param,j) == "param"	then    
        	Attack.act_apply_par_spell( par, c1, c2, 0, duration, false)
      	end 
    		if text_dec(type_param,j) == "damage"	then   
    			if c2~=0 then 		
    		    local mindfire = Attack.act_get_dmg_min(target, "fire")
		    		local mindpoison = Attack.act_get_dmg_min(target, "poison")
    				local mindmagic = Attack.act_get_dmg_min(target, "magic")
    				local mindphysical = Attack.act_get_dmg_min(target, "physical")
    				local maxdfire = Attack.act_get_dmg_max(target, "fire")
    				local maxdpoison = Attack.act_get_dmg_max(target, "poison")
    				local maxdmagic = Attack.act_get_dmg_max(target, "magic")
    				local maxdphysical = Attack.act_get_dmg_max(target, "physical")

    				local max_dmg = (maxdfire + maxdpoison + maxdmagic + maxdphysical)*c2/100
    				local min_dmg = (mindfire + mindpoison + mindmagic + mindphysical)*c2/100
    				
    				Attack.act_apply_dmgmax_spell( par, max_dmg, 0, 0, duration, false)
    				Attack.act_apply_dmgmin_spell( par, min_dmg, 0, 0, duration, false)
 					else
 					 	Attack.act_apply_dmg_spell( par, c1, 0, 0, duration, false)
 					end 
      	end 
    		if text_dec(type_param,j) == "resist"	then    
        	Attack.act_apply_res_spell( par, c1, c2, 0, duration, false)
      	end 
    		if text_dec(type_param,j) == "script"	then    
    			if c1==0 then 
    				Attack.act_posthitmaster(target, par ,duration)
    			else
    				Attack.act_posthitslave(target, par ,duration)
    			end
    			Attack.act_spell_param(target, spell, "param" , c2*power)
      	end 
      	
      end 
    Attack.act_apply_spell_end()

	end 
  end 
 --if kill==true then 
 	--Attack.act_kill() 
 --end 
 return true 
 
end 

function potion_take()
	
	barrier_set_attack()
  for i=1,Attack.act_count()-1 do
     if Attack.cell_dist(0,i)==0 and not Attack.act_pawn(i) then -- вне радиуса действия - снимаем эффект с этого юнита
				local x,y=Attack.act_get_center(i)
				totem_spell_cast(x,y,true)
				--Attack.act_remove(0)
				Attack.act_kill() 
     end
	end 
	
  return true
end

function fake_attack()
	return true
end

-- New! Add additional tower spells based on army makeup
function add_tower_spell( spells, spell_level, tower_name )
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

  local function get_unit_races( unit_names )
    local races = {}
    local race
    local features = {}
    local feature
    local avg_level = 0
    local level
    for i = 1, table.getn( unit_names ) do
      race = Attack.atom_getpar( unit_names[ i ], "race" )
      table.insert( races, race )
      feature = Attack.atom_getpar( unit_names[ i ], "features" )
      if feature ~= nil
      and feature ~= "" then
        local number_features = text_par_count( feature )
  
        if number_features > 1 then
          for j = 1, number_features do
            local sub_string = text_dec( feature, j )
            table.insert( features, sub_string )
          end
        else
          table.insert( features, feature )
        end
      end

      level = tonumber( Attack.atom_getpar( unit_names[ i ], "level" ) )

      avg_level = avg_level + level
    end

    avg_level = round( avg_level / table.getn( unit_names ) )

    races = remove_duplicate_table_entries( races )
    features = remove_duplicate_table_entries( features )

    return races, features, avg_level
  end

  local function get_random_spell_choice( spells, spell_list )
    local length = 0

    for i, j in pairs( spell_list ) do
      length = length + 1
    end

    if length > 0 then
      local index = Game.Random( 1, length )
  
      length = 0
      for i, j in pairs( spell_list ) do
        length = length + 1
        if index == length then
          spells[ i ] = j
          return spells, i
        end
      end
    else
      return spells
    end
  end

  local enemy_races, enemy_features, enemy_avg_level

  if table.getn( enemy_unit_names ) > 0 then
    enemy_races, enemy_features, enemy_avg_level = get_unit_races( enemy_unit_names )
  end

  if table.getn( enemy_races ) > 0 then
    for i = 1, table.getn( enemy_races ) do
      local spells_enemy_race = build_spell_list( "spells_enemy_" .. enemy_races[ i ], spell_level )
      spells = get_random_spell_choice( spells, spells_enemy_race )
    end
  end

  if table.getn( enemy_features ) > 0 then
    for i = 1, table.getn( enemy_features ) do
      local spells_enemy_feature = build_spell_list( "spells_enemy_feature_" .. enemy_features[ i ], spell_level )
      spells = get_random_spell_choice( spells, spells_enemy_feature )
    end
  end

  if tower_name == "arena_tower" then
    local spells_good = build_spell_list( "spells_good", spell_level )
  
    for i = 1, enemy_avg_level do
      local key
      spells, key = get_random_spell_choice( spells, spells_good )
      spells_good[ key ] = nil
    end
  end

  local ally_races, ally_features, ally_avg_level
  if table.getn( ally_unit_names ) > 0 then
    ally_races, ally_features, ally_avg_level = get_unit_races( ally_unit_names )
  end

  if table.getn( ally_races ) > 0 then
    for i = 1, table.getn( ally_races ) do
      local spells_ally_race = build_spell_list( "spells_ally_" .. ally_races[ i ], spell_level )
      spells = get_random_spell_choice( spells, spells_ally_race )
    end
  end

  if table.getn( ally_features ) > 0 then
    for i = 1, table.getn( ally_features ) do
      local spells_ally_feature = build_spell_list( "spells_ally_feature_" .. ally_features[ i ], spell_level )
      spells = get_random_spell_choice( spells, spells_ally_feature )
    end
  end

  if tower_name == "arena_tower_1" then
    local spells_evil = build_spell_list( "spells_evil", spell_level )
  
    for i = 1, ally_avg_level do
      local key
      spells, key = get_random_spell_choice( spells, spells_evil )
      spells_evil[ key ] = nil
    end
  end

  return spells
end


-- New! Function for building a list of spells to cast
function build_spell_list( par_spell, spell_level )
 	local spells = {}
 	local str_spells = Attack.atom_getpar( Attack.act_name( 0 ), par_spell )
  if str_spells ~= nil then
   	for k, v in string.gfind( str_spells, "([%w_]+)=(%w+)" ) do
      if v == 'L' then
        spells[k] = tonumber( spell_level )
      else
        spells[k] = tonumber( v )
      end
    end
 	end

  return spells
end 


-- Башни на аренах предметов

function item_tower_attack()
 	-- Преобразуем строку в массив спелов
  local tower_spell_level = Attack.val_restore( 0, "tower_spell_level" )
  local spells = build_spell_list( "spells", tower_spell_level )
  spells = add_tower_spell( spells, tower_spell_level, Attack.act_name( 0 ) )
 	Attack.log_label( 'null' )
 	Attack.log_image( '' )
 	local freecell

 	for dir = 0, 5 do
 	  local c = Attack.cell_adjacent( 0, dir )
 	  if empty_cell( c ) then freecell = c end
 	end

 	if not spells.spell_summon then freecell = nil end
 
 	local start = 1.
 	local r = spell_auto_cast( spells )

 	if r ~= nil
  and ( freecell == nil
  or Game.Random( 100 ) < 70 ) then
 		 Attack.atom_spawn( 0, 0, "effect_unit_turn", 0 )
 	  -- Кастим магию
 	  Attack.cast_spell( r.spell, spells[ r.spell ], 4, r.target, r.target2, start + Attack.aseq_time( 0, "cast", "x" ) - 0.5 )
 		 Attack.act_animate( 0, "cast", start )
 	elseif freecell ~= nil
  and table.getn( enemy_unit_names ) > 0 then
 		 Attack.atom_spawn( 0, 0, "effect_unit_turn", 0 )
 		 Attack.act_animate( 0, "cast", start )
 		 -- Призываем союзника
  		local name = enemy_unit_names[ Game.Random( 1, table.getn( enemy_unit_names ) ) ]
    local k = Game.Random( text_range_dec( Attack.get_custom_param( "k" ) ) )
 		 local count = math.ceil( Attack.act_get_par( 0, "health" ) * tower_spell_level / tonumber( Attack.atom_getpar( name, "hitpoint" ) ) * k / 100 )
 		 Attack.act_spawn( freecell, 0, name, tonum( ang_to_nearest_enemy( freecell, Attack.act_enemy ) ), count )
 		 local delay = start + 1
 		 Attack.act_fadeout( freecell, 0, delay, 0.01, 0 )
 		 Attack.act_fadeout( freecell, delay, delay + 2, 1 )
 		 Attack.atom_spawn( freecell, delay, "hll_teleout" )

    if count > 1 then name = 'cpsn_' .. name else name = 'cpn_' .. name end

 		 Attack.log_special( '<label=' .. name .. '>', count )
 		 Attack.log_label( 'add_blog_summon2_' )
 		 Attack.log_image( 'blog_enemy_spell_img' )
 	else
 		 local a = Attack.atom_spawn( 0, 0, "effect_unit_defense", 0 )
 		 local x, y, z = Attack.act_get_center( 0 )
 		 Attack.act_move( 0, .01, a, x, y, z + 1.1 )
 	end
 
 	return true
end

function item_tower_hitback()
  --item_tower_cast("spell_lightning", 1, Attack.get_target())
 	Attack.act_aseq( 0, "cast" )
	 local dmgts = Attack.aseq_time( 0, "x" )
	 local target = Attack.get_target()
	 local a = Attack.atom_spawn( target, dmgts, "magic_lightning" )
	 local dmgts1 = Attack.aseq_time( a, "x" )
	 local interval = Attack.aseq_time( "magic_lightning", "z" )
  local tower_spell_level = Attack.val_restore( 0, "tower_spell_level" )
  local tower_level = tonumber( Attack.val_restore( 0, "tower_level" ) )
	 Attack.atk_set_damage( Logic.obj_par( "spell_lightning", "typedmg" ), pwr_lightning( tower_spell_level, tower_level ) )
	 common_cell_apply_damage( target, dmgts1 + dmgts )

 	return true
end

function item_tower_push()

	local source, target = Attack.get_target()
	local max_dist = Attack.cell_mdist(0,source)
	for dir=0,5 do
		local c = Attack.cell_adjacent(source,dir)
		local dist = Attack.cell_mdist(0,c)
		if empty_cell(c) and dist > max_dist then
			max_dist = dist
			target = c
		end
	end

	if target ~= nil then
		Attack.act_aseq(0, "cast")
	    local dmgts = Attack.aseq_time(0, "y")
	    local angle = Attack.angleto(target, source)
	    Attack.atom_spawn(target, dmgts-.8, "effect_telekines", angle)
		if Attack.act_get_par(source, "dismove") == 0 then
			Attack.act_move( dmgts, dmgts+10/25, source, target )
		end
	end

	return true

end

function arena_tower_selattack()
    return Attack.change_attack(0)
end

function arena_tower_selhitback()
    return Attack.change_attack(1)
end


-- Кристалл Карадора

function darkcrystal_attack()
	 local corpses = {}
  local diff_k = tonumber( text_dec( Game.Config( 'difficulty_k/alead' ), Game.HSP_difficulty() + 1, '|' ) )

	 for i = 0, Attack.cell_count() - 1 do
		  local c = Attack.cell_get( i )
		  local act = Attack.cell_get_corpse( c )

		  if act ~= nil
    and not Attack.act_feature( act, "nonecro,golem,plant,demon,magic_immunitet")
    and Attack.cell_is_empty( c ) then
			   table.insert( corpses, { c, act } )
		  end
	 end

	 if table.getn( corpses ) > 0 then
		  local c, act = unpack( corpses[ Game.Random( 1, table.getn( corpses ) ) ] )
		  local unit_animate = necro_get_unit( actor_name( act ) )
		  local count = math.ceil( Attack.act_initsize( act ) * Attack.act_hp( 0 ) / Attack.act_get_par( 0, "health" ) * diff_k )
		  Attack.act_aseq( 0, "attack" )
		  animate_dead( c, act, Attack.aseq_time( 0, "x" ), 0, unit_animate, count )
 			Attack.log( "add_blog_necro_1", "name",blog_side_unit( 0, 1 ), "target", blog_side_unit( act, 0 ), "targeta", blog_side_unit( c, 0 ), "special", count )
 	end

 	return true
end

function darkcrystal_hitback()
	 Attack.act_aseq( 0, "attack" )
	 local target = Attack.get_target()

 	if target ~= nil then 
		  Attack.act_del_spell( target, "spell_weakness" )
  		Attack.act_del_spell( target, "spell_bless" )
		  Attack.act_apply_spell_begin( target, "spell_weakness", tonumber( Attack.get_custom_param( "duration" ) ), false )
		  Attack.act_apply_spell_end()
		  Attack.atom_spawn( target, 0, "magic_sword", Attack.angleto( target ) )
	 end 

	return true
end


-- Пауны

--[[function barrel_ondamage(wnm,ts,dead)

	if dead then
	end

	return true

end]]

function barrel_attack()

	Attack.log_label('null')
	if Attack.act_hp(0) <= 0 then
		local start = 0--ts
		local a = Attack.atom_spawn(0, start, "effect_bomb")
		local dmgts = start + Attack.aseq_time(a, "x")

		local min_dmg, max_dmg = text_range_dec(Attack.val_restore("damage"))
		local power = Attack.act_level(0)^2
		Attack.atk_set_damage(Attack.val_restore("dmgtype"),min_dmg*power,max_dmg*power)

		for dir=0,5 do
		    local c = Attack.cell_adjacent(0, dir)
		    if c ~= nil and Attack.cell_present(c) and Attack.act_takesdmg(c) and Attack.act_applicable(c) then
		    	common_cell_apply_damage(c, dmgts)
				Attack.log_label('')
		    end
		end
	    --Attack.act_kill(0,true,false)
	    Attack.act_aseq(0,"realdeath")
	    Attack.act_remove(0,Attack.aseq_time(0))
	    return true
	end
	return false -- чтобы не тормозило

end

function barrel_set_attack()

  return Attack.change_attack(0)

end

function pawn_get_targets()

	local targets = {}
	local feat = Attack.val_restore("nfeatures")
	local dist = tonumber(Attack.val_restore("dist"))
	for i=1, Attack.act_count()-1 do
		if not Attack.act_feature(i,feat) and Attack.act_takesdmg(i) and Attack.cell_dist(0,i) <= dist then
			table.insert(targets, i)
		end
	end
	return targets

end

function hollow_attack_target(start, target)

	local a = Attack.atom_spawn(0, start, "ent_wasps")
	local endt = start + 2
	local h,x,y,z = 1.2,Attack.act_get_center(0)
	Attack.act_move(start, start+.01, a, x, y, z+h)
	local tx,ty,tz = Attack.act_get_center(target)
	Attack.act_move(start+.1, endt, a, tx, ty, tz+h)

	local min_dmg, max_dmg = text_range_dec(Attack.val_restore("damage"))
	local power = Attack.act_level(0)^2
	Attack.atk_set_damage(Attack.val_restore("dmgtype"),min_dmg*power,max_dmg*power)
   	common_cell_apply_damage(target, endt)

end

function hollow_attack()

	Attack.log_label('null')
	local targets = pawn_get_targets()
	if table.getn(targets) > 0 then
		local target = targets[Game.Random(1,table.getn(targets))]
		Attack.act_aseq(0, "attack")
		local start = Attack.aseq_time(0, "x")
		hollow_attack_target(start, target)
		Attack.log_label('')
	end

	return true

end

--[[function hollow_ondamage(wnm,ts,dead)

	Attack.log_label('null')
	if dead then
	    for i,target in ipairs(pawn_get_targets()) do
	    	hollow_attack_target(ts+.5, target)
			Attack.log_label('')
	    end
	end

	return true

end]]

function grave_ondamage(wnm,ts,dead,bl)

	if dead then
		Attack.act_spawn(0, bl, "skeleton", 0, 20*Attack.act_level(0))
		local caa = Attack.get_caa(Attack.get_cell(0))
		local delay = wnm
		local endt = delay + 1
		Attack.act_fadeout(caa, 0, delay, 0.01, 0)
		Attack.act_fadeout(caa, delay, endt, 1)
        Attack.act_teleport(caa, caa, endt) -- иначе склет окажется не прописан в клетке
	end

    return true

end

function get_pawn_level()
	if Attack.act_level(0) <= 2 then return 1
	elseif Attack.act_level(0) <= 4 then return 2 end
	return 3
end

function pawn_caster_attack()

	local targets = pawn_get_targets()
	if table.getn(targets) > 0 then

		-- Считаем уровень заклинаний
		local spell_lv = get_pawn_level()

		-- Обходим все спелы и собираем возможные касты в массив
		local cast = {}
		local str_spells = Attack.val_restore("spells")
		for name,lv in string.gfind(str_spells, "([%w_]+)=(%w+)") do
		    local level = math.min(spell_lv, tonumber(lv)) -- ограничиваем уровень
		    local applicable = Attack.build_spell_attack(name, level).applicable
			for i,t in ipairs(targets) do
			    if applicable(t) and (name ~= "spell_healing" or Attack.act_get_par(t,"health")-Attack.act_hp(t) >= 10) then
			        table.insert(cast, {spell=name, level=level, target=t, prob=1})
			    end
			end
		end

		if table.getn(cast) > 0 then
		    local ch = random_choice(cast)
		    -- Кастим магию
			Attack.atom_spawn(0, 0, "effect_unit_turn", 0)
		    local start = 1.
		    Attack.cast_spell(ch.spell, ch.level, 16, ch.target, nil, start+Attack.aseq_time(0,"cast","x")-0.5)
			Attack.act_animate(0,"cast",start)
		end

	end

	return true

end

function altar_ice_attack()

	Attack.log_label('null')
	local targets = pawn_get_targets()
	if table.getn(targets) > 0 then
		local target = targets[Game.Random(1,table.getn(targets))]

		Attack.act_aseq(0, "cast")
		local start = Attack.aseq_time(0, "x")
		local spell_lv = get_pawn_level()

		if Attack.act_race(target) == "dwarf" then
			if Game.Random(100) < 50 then spell_haste_attack(spell_lv,start,target)
			else                          spell_bless_attack(spell_lv,start,target) end
		else
			if Game.Random(100) < 50 then spell_ice_serpent_attack(spell_lv,start,target)
			else                          spell_geyser_attack(spell_lv,start,target) end
			Attack.log_label('')
		end
	end

	return true

end
