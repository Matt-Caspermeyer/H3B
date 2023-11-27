function objuse_spawn_troop() --ftag:action
  local troop = Obj.get_param( "troop" )
  local troopcnt = Obj.get_param( "troopcount" )
  local trand = Obj.get_param( "random" )
  local rnd = Game.Mutate( 50, Obj.id() )
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
    local troop_num = diap( trand, 0, rnd )
    troop = text_dec( troop, troop_num )
    troopcnt = text_dec( troopcnt, troop_num )

    if text_range_count( troopcnt ) > 0 then
      troopcnt = text_range_ret( troopcnt, Obj.id() )
    end
  else
    if text_range_count( troopcnt ) > 0 then
      troopcnt = text_range_ret( troopcnt, Obj.id() )
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

