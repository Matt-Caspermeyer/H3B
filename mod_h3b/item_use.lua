function objuse_spawn_troop() --ftag:action
  local troop = Obj.get_param( "troop" )
  local troopcnt = Obj.get_param( "troopcount" )
  local trand = Obj.get_param( "random" )
  local factor = Obj.multiuse()
  local altfactor = Obj.get_param( "altfactor" )

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
      factor = factor / altfactor
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

    if text_range_count( troopcnt ) > 0 then
      troopcnt = Game.Random( text_range_dec( troopcnt ) )
    end
  else
    if text_range_count( troopcnt ) > 0 then
      troopcnt = Game.Random( text_range_dec( troopcnt ) )
    end
  end

  troop_add_global = troop
  local troop_number = math.floor( tonumber( troopcnt ) * factor )

  return not Obj.add_troop( troop, troop_number )
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

