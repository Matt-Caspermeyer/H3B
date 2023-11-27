function gen_tab (par)

   return "    "

end
function gen_space (par)

   return " "

end

function gen_hero_item (par)

  local item = Logic.hero_lu_item( par, "count" )
  if item==nil or item<0 then item=0 end
  return tostring(item)

end

function race_gen(par1,par2)
  local desc=""
  local race=AU.race(par1)

  if par2=="0" then
      return "<label=inf_"..race.."_race_head>"
  else
      return "<label=inf_"..race.."_race_hint>"
  end
   -- return "no race /"..par1.." "..par2
end

function resource_gen(par)
    local res = Logic.hero_lu_item( par, "count" )
    return tostring(res)

end

function resource_gen_temp()
    local itm = Game.GVStr( "temp" )
    return "<br><imb=" .. Obj.image(itm) .. "><br><label=itm_".. itm .."_name>"
end

function map_hint_gen(par)
    local rs = Logic.cur_lu_var("object")
    return "itm_"..rs.."_"..par

end


function kilo_money()

    local money = Logic.hero_lu_item("money","count")
    if money == nil then return "" end
    if money >= 100000 then
        money = math.floor(money/1000)
        if money >= 10000 then
          money = math.floor(money/1000)
          return money.."M"
        end
        return money.."K"
    else
        return tostring(money)
    end

end

function gen_army_map(data,par)
local text=""
    if par=="header" then
        return "<label=cpsn_"..AU.name(data)..">"

    end
    if par=="end" then
        return "<label=map_unit_info_hint>"
    end

        local lead = AU.curlead(data)
        local max_count=Logic.hero_lu_item("leadership","count")
        local count_lead=math.floor(max_count/lead)

        local count=AU.unitcount(data)

        if count_lead<count then

            count="<label=hint_unit_nolead>"..count.."</color>"
            text="<label=hint_morale_bad><br>"
        end

        text = text.."<label=hint_morale_count> "..count.."/"..count_lead.."<br>"
        local hint = "<label=hint_morale_0>: "
    if AU.moral(data)<0 then --<label=hint_morale_low>
        hint=hint.."<label=hint_morale_l"..tostring(-1*AU.moral(data))..">"
    end
    if AU.moral(data)==0 then --<label=hint_morale_neit>
        hint=hint.."<label=hint_morale_n0>"
    end
    if AU.moral(data)>0 then --<label=hint_morale_hi>
        hint=hint.."<label=hint_morale_h"..tostring(AU.moral(data))..">"
    end


return text..hint
end

function gen_unit_damage(data)
local text=""

        local res_count=AU.rescount()
        for i=0,res_count-1 do
          local min_ = AU.minresdmg( data, i )
      local max_ = AU.maxresdmg( data, i )
      if min_+max_>0 then
        text="<br>урон типа "..i.."="..min_.."-"..max_
      end
    end

return text

end

--[[function gen_unit_res(data)
local text=""

        local res_count=AU.rescount()
        for i=0,res_count-2 do
          local res = AU.resistance( data, i )
          local t=""
          if res>95 then res=95 end
          if res> 0 then t="<label=cpi_defense_res_D>" end
          if res< 0 then t="<label=cpi_defense_res_U>" end
        text=text.."<br> -<label=cpi_defense_res_"..(i+1)..">: "..res.."% "..t

    end

return text
end]]

-- New! Function for showing Ice Ball Roll Damage increase
function gen_unit_roll( data )
  local text = ""

  if Game.LocIsArena() then
    text = tostring( Attack.val_restore( data, "k_dam" ) )
  else
    text = "100"
  end

  return text
end


-- New! Function for showing unit critical hit
function gen_unit_krit( data )
  local text = ""
  local is_human = AU.is_human( data )
  local hero_attack

  if not Game.LocIsArena()
  or is_human then
    hero_attack = Logic.hero_lu_item( "attack", "count" )
  else
    hero_attack = Attack.val_restore( data, "enemy_hero_attack" )
  end

  local current_krit, base_krit = Attack.act_get_par( data, "krit" )
  local current_color = "<color=252,249,220>"
  local base_color = "<color=79,172,211>"

  if hero_attack ~= nil
  and hero_attack > 0 then
    local krit_inc = Game.Config( "attack_config/krit_inc" )
    local krit_bonus = math.floor( hero_attack / 7 ) * krit_inc
    current_krit = current_krit + krit_bonus
  end

  if Attack.act_is_spell( data, "special_preparation" ) then
    current_krit = 100
  end

  current_krit = limit_value( current_krit, 0, 100 )

  if current_krit > base_krit then
    current_color = "<color=0,254,10>"
    text = current_color .. " +" .. tostring( current_krit ) .. "%</color>" .. base_color .. " (+" .. tostring( base_krit ) .. "%)</color>"
  elseif current_krit < base_krit then
    current_color = "<color=255,100,100>"
    text = current_color .. " +" .. tostring( current_krit ) .. "%</color>" .. base_color .. " (+" .. tostring( base_krit ) .. "%)</color>"
  else
    text = current_color .. " +" .. tostring( current_krit ) .. "%</color>"
  end

  return text
end


function gen_unit_res( data )
  local text = ""
  local res_count = AU.rescount()

  for i = 0, res_count - 2 do
    local res = AU.resistance( data,  i )
    local is_human = AU.is_human( data )
    local hero_defense = 0

    if not Game.LocIsArena()
    or is_human then
      hero_defense = Logic.hero_lu_item( "defense", "count" )
      local value = Game.Config( "defense_config/res_inc" )
      res = res + math.floor( hero_defense / 7 ) * value
    else
      hero_defense = Attack.val_restore( data, "enemy_hero_defense" )
      
      if hero_defense ~= nil
      and hero_defense > 0 then
        local value = Game.Config( "defense_config/res_inc" )
        res = res + math.floor( hero_defense / 7 ) * value
      end
    end

    if res > 95 then res = 95 end

    local t = ""

    if res> 0 then t = "<label=cpi_defense_res_D>" end

    if res< 0 then t = "<label=cpi_defense_res_U>" end

    text = text .. "<br>-<label=cpi_defense_res_" .. ( i + 1 ) .. ">: " .. res .. "% " .. t
  end

  return text
end

-- New! For generating the attack / defense / Intellect parameters
function gen_adi_par( par )
  local text = ""

  if string.find( par, "att_den" ) then
    local value = Game.Config( "attack_config/den" )
    text = value

  elseif string.find( par, "att_krit_inc" ) then
    local value = Game.Config( "attack_config/krit_inc" )
    text = "+" .. value .. "%"

  elseif string.find( par, "att_cap_inc" ) then
    local value = Game.Config( "attack_config/cap_inc" )
    text = "+" .. value .. "%"

  elseif string.find( par, "def_den" ) then
    local value = Game.Config( "defense_config/den" )
    text = value

  elseif string.find( par, "def_res_inc" ) then
    local value = Game.Config( "defense_config/res_inc" )
    text = "+" .. value .. "%"

  elseif string.find( par, "att_inc" ) then
    local hero_attack = Logic.hero_lu_item( "attack", "count" )
    local value = Game.Config( "attack_config/cap_inc" )
    local attack_increase = math.floor( hero_attack / 7 ) * value
    text = "+" .. tostring( 300 + attack_increase ) .. "%"

  elseif string.find( par, "att_krit" ) then
    local hero_attack = Logic.hero_lu_item( "attack", "count" )
    local value = Game.Config( "attack_config/krit_inc" )
    local attack_increase = math.floor( hero_attack / 7 ) * value
    text = "+" .. tostring( attack_increase ) .. "%"

  elseif string.find( par, "def_res" ) then
    local hero_defense = Logic.hero_lu_item( "defense", "count" )
    local value = Game.Config( "defense_config/res_inc" )
    local defense_increase = math.floor( hero_defense / 7 ) * value
    text = "+" .. tostring( defense_increase ) .. "%"

  elseif string.find( par, "dam_dec" ) then
    local hero_defense = Logic.hero_lu_item( "defense", "count" )
    local defense_increase = math.floor( hero_defense / 7 )
    local den_string = tostring( math.floor( 1 / ( 3 + defense_increase ) * 100 ) ) .. "." .. tostring( round( ( ( 1 / ( 3 + defense_increase ) * 100 ) - math.floor( 1 / ( 3 + defense_increase ) * 100 ) ) * 10 ) )
    text = "1/" .. tostring( 3 + defense_increase ) .. " (" .. den_string .. "%)"

  elseif string.find( par, "int_den" ) then
    local mod = tonumber( Game.Config( "spell_power_config/mod" ) )
    local mod_limit = tonumber( Game.Config( "spell_power_config/mod_limit" ) )
    local den_scholar = tonumber( Game.Config( "spell_power_config/den_scholar" ) )
    local new_mod = math.max( mod_limit, mod - tonumber( Logic.hero_lu_item( "sp_power_mod", "count" ) ) / den_scholar )

    if new_mod ~= mod then
      text = tostring( new_mod ) .. " (" .. tostring( mod ) .. ")"
    else
      text = tostring( new_mod )
    end

  elseif string.find( par, "power_inc" ) then
    local inc = tonumber( Game.Config( "spell_power_config/inc" ) )
    local inc_limit = tonumber( Game.Config( "spell_power_config/inc_limit" ) )
    local den_scholar = tonumber( Game.Config( "spell_power_config/den_scholar" ) )
    local new_inc = math.max( inc_limit, inc + tonumber( Logic.hero_lu_item( "sp_power_inc", "count" ) ) / den_scholar )

    if new_inc ~= inc then
      text = "+" .. tostring( new_inc ) .. "% (" .. tostring( inc ) .. "%)"
    else
      text = "+" .. tostring( new_inc ) .. "%"
    end

  elseif string.find( par, "dur_den" ) then
    local den = tonumber( Game.Config( "spell_power_config/int_duration" ) )
    local new_den = math.max( 1, tonumber( den ) - tonumber( Logic.hero_lu_item( "sp_dur_mod", "count" ) ) )

    if new_den ~= den then
      text = tostring( new_den ) .. " (" .. tostring( den ) .. ")"
    else
      text = tostring( new_den )
    end

  elseif string.find( par, "dur_inc" ) then
    local dur_inc = tonumber( Game.Config( "spell_power_config/dur_inc" ) )
    text = "+" .. tostring( dur_inc )

  elseif string.find( par, "int_power" ) then
    local num = HInt()
    local mod = tonumber( Game.Config( "spell_power_config/mod" ) )
    local mod_limit = tonumber( Game.Config( "spell_power_config/mod_limit" ) )
    local den_scholar = tonumber( Game.Config( "spell_power_config/den_scholar" ) )
    local new_mod = math.max( mod_limit, mod - tonumber( Logic.hero_lu_item( "sp_power_mod", "count" ) ) / den_scholar )
    local inc = tonumber( Game.Config( "spell_power_config/inc" ) )
    local inc_limit = tonumber( Game.Config( "spell_power_config/inc_limit" ) )
    local new_inc = math.max( inc_limit, inc + tonumber( Logic.hero_lu_item( "sp_power_inc", "count" ) ) / den_scholar )
    inc = math.floor( num / new_mod ) * new_inc
    text = "+" .. tostring( inc ) .. "%"

  elseif string.find( par, "int_dur" ) then
    local hint = HInt()
    local mod = math.max( 1, tonumber( Game.Config( "spell_power_config/int_duration" ) ) - tonumber( Logic.hero_lu_item( "sp_dur_mod", "count" ) ) )
    local dur_inc = tonumber( Game.Config( "spell_power_config/dur_inc" ) )
    local dur_int_bonus = math.floor( hint / mod ) * dur_inc
    local dur = dur_int_bonus
    text = "+" .. tostring( dur )
  end

  return text
end


function gen_lead_count(data,par)
local text=""
    local lead= Logic.hero_lu_item("leadership","count")
    if par=="hero" then
        return tostring(lead)
    end

    if par=="unit" then
        count=AU.unitcount(data)
        lead=AU.abslead(data)
        return tostring(lead*count)
    end

        local max_ = AU.curlead(data)
        local count_lead=math.floor(lead/max_)

        return tostring(count_lead)


end

function gen_army_align(data,par)
    local align=Logic.cur_lu_var("align")
    local fur=Logic.cur_lu_var("furious")
    if align=="enemy" or fur=="1" then return "<label=enemy_01_hint>" end
    if align=="friend" then return "<label=enemy_03_hint>" end
    if align=="neutral" then return "<label=enemy_02_hint>" end

    return "<label=enemy_01_hint>"

end


function gen_day_time()
    return "<label=int_time_"..Game.DayTime()..">"
end

function gen_pawn_health()
    local hp = Attack.act_hp(0)
    local health = Attack.act_get_par(0,"health")
    return hp.."/"..health
end

function gen_max_hp()
    if Game.LocIsArena() then
        return "<br><label=cpi_health_hall> "..Attack.act_totalhp(0)
    end
    return ""
end

function time_gen()
	local time = Game.Time()
	local h = math.floor(time)
	local mt = (time*10 - math.floor(time)*10)/10
	local mnt = math.floor(mt*60)
	if mnt<10 then mnt="0"..tostring(mnt) end 

	return h..":"..mnt
end 
