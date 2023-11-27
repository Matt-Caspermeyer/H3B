function objuse_spawn_troop() --ftag:action
  local troop = Obj.get_param( "troop" )
  local troopcnt = Obj.get_param( "troopcount" )
  local trand = Obj.get_param( "random" )
  local factor = Obj.multiuse()
  local altfactor = Obj.get_param( "altfactor" )
  local troop_number = 0

  if altfactor ~= nil
  and altfactor ~= "" then
    if string.find( altfactor, "-" ) then
      altfactor = Game.Random( text_range_dec( altfactor ) )
    else
      altfactor = tonum( altfactor )
    end
  
    if factor >= altfactor then
      troop = Obj.get_param( "alttroop" )
      troopcnt = Obj.get_param( "alttroopcount" )
      trand = Obj.get_param( "altrandom" )
      factor = math.floor( factor / altfactor )
    end
  end

  if text_par_count( troop ) > 1 then
    local troop_table = {}
  
    for i = 1, text_par_count( trand ) do
      table.insert( troop_table, { troop = text_dec( troop, i ), troopcnt = text_dec( troopcnt, i ), prob = tonumber( text_dec( trand, i ) ) } )
    end
  
    local troop_select = random_choice( troop_table )
    
    troop = troop_select.troop
    troopcnt = troop_select.troopcnt
  end

  for i = 1, factor do
    local count = 0

    if text_range_count( troopcnt ) > 0 then
      count = Game.Random( text_range_dec( troopcnt ) )
    else
      count = troopcnt
    end

    troop_number = troop_number + count
  end

  troop_add_global = troop

  return not Obj.add_troop( troop, math.floor( troop_number ) )
end

function itm_give_item(par) --ftag:action
    --item_add=scroll
    --item_count=scroll
    --scroll=
    if par=="scroll" then
        local scroll="spell_"..Obj.get_param("scroll")
        local count=tonumber(Obj.get_param("item_count"))
        if count>0 then

        end
    end
    if par=="rune" then
    end

  return true

end

