--Game.SpiritRest("therock")

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
	
	 if par == "rage" then 
		  hint = Attack.get_custom_param( "rage" )
	 end 

 	if par == "rest" then 
		  hint = Attack.get_custom_param( "rest" )
  end 
	
 	return " "..hint
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
      value = "<br>" .. "<label=spirit_hint_defense>" .. " " .. "<color=255,243,179>" .. "+" .. value
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
