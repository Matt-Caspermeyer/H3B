function unit_moral_desc( unit )
  local desc = AU.mlabels( unit )
  local hint="" --"<label=hint_morale_current> "..AU.moral(unit)
  local count = text_par_count(desc)
 	local hint_base="hint_morale_"
	  
 	if string.find( desc, "bad" ) then hint = hint .. "<label=hint_morale_bad><br>" end 

  if desc ~= ""
  and desc ~= "bad" then
  	 for i = 1, count do
  	   local temp = text_dec( desc, i )

  	   if temp ~= "bad" then
  	  	  if string.find( temp, "[$]" ) then -- если не предмет и не заклинание
  	  		   if string.find( temp, "spell" )
          or string.find( temp, "special" )
          or string.find( temp, "effect" ) then -- если заклинание
  	  			    temp = string.gsub( temp, "[.]", ",", 1 )
  	  			    temp = string.gsub( temp, "[$]", "", 1 )
  	  			    local mr = tonumber( text_dec( temp, 1 ) )

  	  			    if mr > 0 then mr = "+" .. mr end

  	  			    hint = hint .. "" .. mr .. ": <label=hint_morale_spell> '<label=" .. text_dec( temp, 2 ) .. "_name>'" .. "<br>"
    	  		 elseif string.find( temp, "battle_" ) then
  	  			    temp = string.gsub( temp, "[.]", ",", 1 )
  	  			    temp = string.gsub( temp, "[$]", "", 1 )
  	  			    local mr = tonumber( text_dec( temp, 1 ) )

  	  			    if mr > 0 then mr = "+" .. mr end

  	  			    hint = hint .. "" .. mr .. ": <label=" .. text_dec( temp, 2 ) .. "><br>"
    	  		 else
            if string.find( temp, "arena" )
            or string.find( temp, "time" ) then
    	  						 temp = string.gsub( temp, "[.]", ",", 1 )
    	  						 temp = string.gsub( temp, "[$]", hint_base, 1 )
    	  						 local mr = tonumber( text_dec( temp, 1 ) )
  
    	  						 if mr > 0 then mr = "+" .. mr end
  
     	  						hint = hint .. "" .. mr .. ": <label=" .. text_dec( temp, 2 ) .. "><br>"
    	  				 else  
    	  					  temp = string.gsub( temp, "[.]", ",", 1 )
    	  					  temp = string.gsub( temp, "[$]", "itm_", 1 )
    	  					  local mr = tonumber( text_dec( temp, 1 ) )
  
    	  					  if mr > 0 then mr = "+" .. mr end
  
    	  					  if string.find( temp, "totem" ) then
    	  						   hint = hint .. "" .. mr .. ": <label=hint_totem_item> '<label=" .. text_dec( temp, 2 ) .. "_name>'" .. "<br>"
    	  					  elseif string.find( temp, "wife" ) then
    	  						   hint = hint .. "" .. mr .. ": <label=hint_wife_item> '<label=" .. text_dec( temp, 2 ) .. "_name>'" .. "<br>"
    	  					  elseif string.find( temp, "set" ) then
    	  						   hint = hint .. "" .. mr .. ": <label=hint_morale_set> '<label=" .. text_dec( temp, 2 ) .. "_name>'" .. "<br>"
    	  					  else
    	  						   hint = hint .. "" .. mr .. ": <label=hint_morale_item> '<label=" .. text_dec( temp, 2 ) .. "_name>'" .. "<br>"
    	  					  end 
    	  				 end 
    	  		 end 
    	  	else 
    	  		 temp = string.gsub( temp, "[.]", ",", 1 )
    	  		 local mr = tonumber( text_dec( temp, 1 ) )
  
    	  		 if mr > 0 then mr = "+" .. mr end 
  
    	  		 hint = hint .. "" .. mr .. ": <label=" .. text_dec( temp, 2 ) .. ">" .. "<br>"
    	  	end 
    	 end 
    end
  
    if AU.moral( unit ) < 0 then --<label=hint_morale_low>
    		hint = hint .. "<label=hint_morale_itogo>: <label=hint_morale_l" .. tostring(-1 * AU.moral( unit ) ) .. ">"
    end 
  
    if AU.moral( unit ) == 0 then --<label=hint_morale_neit>
    		hint = hint .. "<label=hint_morale_itogo>: <label=hint_morale_n0>"
    end 
  
    if AU.moral( unit ) > 0 then --<label=hint_morale_hi>
    		hint = hint .. "<label=hint_morale_itogo>: <label=hint_morale_h" .. tostring( AU.moral( unit ) ) .. ">"
    end 
  end 
  
  if ( desc == "bad" )
  or ( desc == "" ) then hint = hint .. "<label=hint_morale_n1>" end 
  
  return hint --.."  "..desc
  --return desc..tostring(AU.moral(unit))
end


function unit_moral_head(unit)
	
	local desc = AU.mlabels(unit)
	local hint=""
	if string.find(desc, "bad") then
		return "<label=hint_morale_lead>"
	else
	 	if AU.moral(unit)<0 then --<label=hint_morale_low>
  		hint=hint.."<label=hint_morale_itogo>: <label=hint_morale_l"..tostring(-1*AU.moral(unit))..">"
  	end 
  	if AU.moral(unit)==0 then --<label=hint_morale_neit>
  		hint=hint.."<label=hint_morale_itogo>: <label=hint_morale_n0>"
  	end 
  	if AU.moral(unit)>0 then --<label=hint_morale_hi>
  		hint=hint.."<label=hint_morale_itogo>: <label=hint_morale_h"..tostring(AU.moral(unit))..">"
  	end 
  	return hint
  end 
  
end

function unit_moral_cur(unit)
	
	return AU.moral(unit).." "
   
end

function unit_moral_bonus(unit,par)
	
	local desc = AU.mlabels(unit)
	local text = ""
	local moral = AU.moral(unit)
	
	local mas_par={"-30%","-20%","-10%","100%","+10%","+20%","+30%"}
	local mas_krit={"0%","50%","75%","100%","125%","150%","200%"}
	local mas_moral={-3,-2,-1,0,1,2,3}
	
	if (par=="end") and (desc=="bad" or desc=="") then 
		text = text.."<label=hint_morale_n2>" 
	end 
	if par=="end" and desc~="bad" and desc~="" then 
		text = text.."<label=hint_morale_bonus>" 
	end 

	if par=="attack" or par=="defense" then 
	  for i=1,7 do
	  	if mas_moral[i]==moral then
	  		text=mas_par[i]
	  	end 
	  end 
	end 
	if par=="krit" then 
	  for i=1,7 do
	  	if mas_moral[i]==moral then
	  		text=mas_krit[i]
	  	end 
	  end 
	end 

	return text
  
end

--***************************************************************************************

function demon_morale( unit ) --ftag:morale

  --Logic.*
  --AU.*

  return 3, true, true -- moral, is_absolute, do_other

  -- is_absolute - if true, then return moral is final moral value, else it is addition
  -- do_other    - proceed other modificators?

end

function knight_morale( unit ) --ftag:morale

  --Logic.*
  --AU.*

  return 1, false, true -- moral, is_absolute, do_other

  -- is_absolute - if true, then return moral is final moral value, else it is addition
  -- do_other    - proceed other modificators?

end
