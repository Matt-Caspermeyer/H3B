--Game.SpiritRest("therock")
-- New! Experience calculation based on code from CW
function calc_spirit_exp( expirience )
 	local ClassK = tonumber( Game.Config( "hero_" .. Game.Config( "heroclasses/" .. tostring( math.max( 0, Game.HSP_class() ) ) ) .. '/k_spirit_up' ) )
 	local EnemyStrengthK = math.max( 0.5, math.min( 2, Game.FightParams() / ( Logic.hero_lu_item( "leadership", "count" ) * 5 ) ) )
 	local HeroSpiritLevelK = math.min( 3, tonumber( Logic.hero_lu_var( "level" ) ) / tonumber( Attack.get_custom_param( "LV" ) ) )

 	if ClassK == nil then ClassK = 1 end

 	if EnemyStrengthK == nil then EnemyStrengthK = 1 end

 	if HeroSpiritLevelK == nil then HeroSpiritLevelK = 1 end

 	return expirience * ClassK * EnemyStrengthK * HeroSpiritLevelK
end


-- New! Experience gain based on code from CW
function calc_K()
 	local K
 
 	if SECOND_SPIRIT_ATTACK == 0 then
  		K = 1
 	else 
  		local CurEnemyLeadership, CurAllyLeadership = 0, 0

  		for c = 0, Attack.cell_count() - 1 do
  			 local i = Attack.cell_get( c )

  			 if Attack.act_enemy( i ) then
   			 	CurEnemyLeadership = CurEnemyLeadership + tonumber( Attack.act_leadership( i ) ) * Attack.act_size( i )
  			 elseif Attack.act_ally( i ) then
   			 	CurAllyLeadership = CurAllyLeadership + tonumber( Attack.act_leadership( i ) ) * Attack.act_size( i )
  			 end
  		end

  		K = math.min( CurEnemyLeadership / CurAllyLeadership, 1 )
 	end

 	return K
end


function exp_round( exp )
 	if math.mod( exp * 10, 10 ) >= 5 then return math.ceil( exp ) end
	 if math.mod( exp * 10, 10 ) < 5 then return math.floor( exp ) end
end

-- New! Experience Hints based on code from CW
function gen_spirit_exp_hint( data )
 	local hint = ""
 	local RewardSkill = 1 + tonum( Logic.hero_lu_item( "sp_addexp_spirit", "count" ) ) / 100
 	local base_exp = tonumber( Attack.get_custom_param( "exp" ) ) * RewardSkill
 	local LV = tonumber( Attack.get_custom_param( "LV" ) )
 	local Max_LV = tonumber( text_par_count( Game.Config( 'arenacommon/exptable' ) ) ) + 1

 	if Game.LocIsArena()
  and LV < Max_LV then --В бою или нет, и может ли получать опыт
 		 local K = calc_K()
   	local spirittable = Game.Config( 'arenacommon/exptable' )
   	local killedunitexp = tonumber( Attack.get_custom_param( "killedunitexp" ) )
  		local LimitKilledUnitExp = 0

    if killedunitexp == 1 then
    		if LV > 1 then
    			LimitKilledUnitExp = ( tonumber( text_dec( spirittable, LV ) ) - tonumber( text_dec( spirittable, LV - 1 ) ) ) * text_dec( Game.Config( 'difficulty_k/spexp' ), Game.HSP_difficulty() + 1, '|' ) / ( LV / 5 + 2 )
    		else
    			LimitKilledUnitExp = tonumber( text_dec( spirittable, LV ) ) * text_dec( Game.Config( 'difficulty_k / spexp' ), Game.HSP_difficulty() + 1, '|' ) / ( LV / 5 + 2 )
    		end
  		end

  		local RawExp = exp_round( base_exp ) * K
  		local Total_Exp = exp_round( calc_spirit_exp( RawExp ) )
  		local temp_exp_max_1 = calc_spirit_exp( RawExp + LimitKilledUnitExp )

    if LimitKilledUnitExp == 0 then
      temp_exp_max_1 = temp_exp_max_1 + 1
    end

  		local temp_exp_max_2 = base_exp * 3
  		local Total_Exp_max = exp_round( math.min( temp_exp_max_1, temp_exp_max_2 ) )

    if Total_Exp == Total_Exp_max then
      hint = hint .. "<br><color=222,194,94><label=spirit_hint_combatexp> </color>" .. tostring( Total_Exp )
  		elseif Total_Exp > 0
    or killedunitexp == 1 then
      hint = hint .. "<br><color=222,194,94><label=spirit_hint_combatexp> </color>" .. tostring( Total_Exp ) .. "-" .. tostring( Total_Exp_max )
    else
   			hint = hint .. "<br><color=222,194,94><label=spirit_hint_combatexp> </color>" .. "<label=spirit_hint_noexp>"
    end
 	else
    local ClassK = tonumber( Game.Config( "hero_" .. Game.Config( "heroclasses/" .. tostring( math.max( 0, Game.HSP_class() ) ) ) .. '/k_spirit_up' ) )
    local HeroSpiritLevelK = math.min( 3, tonumber( Logic.hero_lu_var( "level" ) ) / tonumber( Attack.get_custom_param( "LV" ) ) )
    local overall = ClassK * HeroSpiritLevelK
    hint = hint .. "<br><color=222,194,94><label=spirit_hint_baseexp> </color>" .. tostring( exp_round( base_exp * overall ) )
  end
 
 	return hint
end

function gen_spirit_rest( data, par )
	 local hint = "<label=spirit_rest_last> "
	 local name = ""

	 if par == "rage" then 
		  hint = Attack.get_custom_param( "rage" )
	 end 

 	if par == "rest" then 
		  hint = Attack.get_custom_param( "rest" )
	 end 
	
	 return " " .. hint
end


function gen_lina_hint( data, par )
	 local hint = Attack.get_custom_param( par )

	 if hint == 1 or hint == "1" then 
		  return "<label=lina_yes>"
	 else
		  return "<label=lina_no>"
 	end 
		
end


function gen_spirit_hint( data, par )
	 local hint = ""

 	if par == "abilitylevel" then 
    local level = tonum( Attack.get_custom_param( "level" ) )
    local ragelevel = tonum( Attack.get_custom_param( "ragelevel" ) )
    local restlevel = tonum( Attack.get_custom_param( "restlevel" ) )
    local ttllevel = tonum( Attack.get_custom_param( "ttllevel" ) )
    local squarelevel = tonum( Attack.get_custom_param( "squarelevel" ) )
    local timelevel = tonum( Attack.get_custom_param( "timelevel" ) )
    local ppwr = tonum( Attack.get_custom_param( "ppwr" ) )
    local attack = tonum( Attack.get_custom_param( "attack" ) )
    local defense = tonum( Attack.get_custom_param( "defense" ) )
    local healing = tonum( Attack.get_custom_param( "healing" ) )
    local total_level = level + ragelevel + restlevel + ttllevel + squarelevel + timelevel + ppwr + attack + defense + healing
		  hint = total_level
  end 
	
	 if par == "rage"
  or par == "rest" then
		  hint = Attack.get_custom_param( par )
	 end 

  if par == "exp" then 
		  hint = gen_spirit_exp_hint( data )
	 end 

 	return " " .. hint
end


function gen_spirit_level()
	 local level=""
	
	 return level
end


function gen_spirit_damage()
	 local min, max = 0, 0

	 for i = 0, Logic.resistance() - 1 do
	   local r = Logic.resistance( i )
	   local m = Attack.get_custom_param( "damage." .. r .. ".0" )
	   if m ~= "" then
	     min = min + m
	     max = max + Attack.get_custom_param( "damage." .. r .. ".1" )
	   end
	end

	if min == 0 then
		 min = Attack.get_custom_param( "dmg.0" )
 		max = Attack.get_custom_param( "dmg.1" )
	end 
	
	if min == max then 
		 return min 
	else
		 return min .. '-' .. max
	end

end


function gen_spirit_energo( data, par )
	 local min, max, text = 0, 0

  if mana_rage_gain_k == nil then
    mana_rage_gain_k = 1
  end

 	if par == "mana" then
		  min = math.ceil( tonumber( Attack.get_custom_param( "manabonus.0" ) ) * mana_rage_gain_k )
		  max = math.ceil( tonumber( Attack.get_custom_param( "manabonus.1" ) ) * mana_rage_gain_k )
 	else
		  min = math.ceil( tonumber( Attack.get_custom_param( "ragebonus.0" ) ) * mana_rage_gain_k )
  		max = math.ceil( tonumber( Attack.get_custom_param( "ragebonus.1" ) ) * mana_rage_gain_k )
    par = "rage"
  end 	

 	if min == max then
    if min == 0 then
      return "<color=255,66,0>" .. "NO " .. string.upper( par ) .. " GAIN!" .. "</color>"
    else
  		  return tostring( min )
    end
 	else
  		return tostring( min ) .. '-' .. tostring( max )
	 end

end


function gen_spirit_param( data, par )
  local value = Attack.get_custom_param( par )

  if value ~= "" then
    if par == "atk" then
      value = "<br>" .. "<label=spirit_hint_attack>" .. " " .. "<color=255,243,179>" .. "+" .. value
    elseif par == "def" then
      value = "<br>" .. "<label=spirit_hint_orbdefense>" .. " " .. "<color=255,243,179>" .. "+" .. value
    elseif par == "init" then
      value = "<br>" .. "<label=spirit_hint_initiative>" .. " " .. "<color=255,243,179>" .. "+" .. value
    elseif par == "rage_gain" then
      if mana_rage_gain_k == nil then
        mana_rage_gain_k = 1
      end

      value = math.ceil( tonumber( value ) * mana_rage_gain_k )

      if value == 0 then
        value = "<color=255,66,0>" .. "NO RAGE GAIN!" .. "</color>"
      else
        value = tostring( value )
      end
    end
  end

		return value
end


function gen_spirit_sleep( par )
	 local name = ""

	 if par == "1" then 
		  name = "therock"
 	end 

	 if par == "2" then 
		  name = "slime"
 	end 

 	if par == "3" then 
	  	name = "lina"
 	end 

	 if par == "4" then 
		  name = "death"
 	end 

 	return tostring( Game.SpiritRest( name ) )
end 
