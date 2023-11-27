function change_load_tips( count )
--  local hint_num = tostring( Game.Random( 1, tonumber( count ) ) )
  -- The count doesn't seem to work, so manually set it to the max hints in EN(G)_WINDOWS.LNG
  local hint_num = tostring( Game.Random( 1, 167 ) )

  return "<label=load_screen_tips_" .. hint_num .. ">"

end


function calc_add_level( oldexp, newexp )

  local addlevel = 0
  local expclamped = newexp - oldexp

  local tsize = Logic.exptable()-1

  for i=0, tsize do
    local ti = Logic.exptable(i)
    if oldexp < ti and newexp >= ti then

      -- -- comment out below code if exp should be clamped -- --

      --if addlevel == 1 then
      --   expclamped = ti - 1 - oldexp
      --end

      addlevel = addlevel + 1
    end
  end

  return addlevel, expclamped

end

function add_exp_postprocess( addexp )

  -- ####not used####
  -- local expbouns = Logic.cur_lu_spbonus( "addexp" )
  -- if expbouns ~= 0 then
  --   return addexp + math.floor(addexp * tonumber(expbouns) / 100);
  -- end
  return addexp

end

function add_exp_handler( valname, oldvalue, newvalue ) --ftag:itmw



  if Logic.cur_is_hero() and valname == "count" then

    local addlevel, clamped = calc_add_level(oldvalue,newvalue)

    if addlevel > 0 then

      --Logic.cur_lu_var( "level", addlevel + Logic.cur_lu_var( "level" ) )
      Logic.levelup( addlevel )

    end


  end

  return false

end



function add_lead_handler( valname, oldvalue, newvalue ) --ftag:itmw


  if valname == "count" then

    Game.RefreshArmySlots()

  end

  return false

end

function crystals_handler( valname, oldvalue, newvalue ) --ftag:itmw

  if valname == "count" and oldvalue < newvalue then
    Game.GVNumInc("res_crystals_received", newvalue-oldvalue)
  end
  return false

end

function rune_might_handler( valname, oldvalue, newvalue ) --ftag:itmw

  if valname == "count" and oldvalue < newvalue then
    Game.GVNumInc("runes_might_received", newvalue-oldvalue)
  end
  return false

end

function rune_magic_handler( valname, oldvalue, newvalue ) --ftag:itmw

  if valname == "count" and oldvalue < newvalue then
    Game.GVNumInc("runes_magic_received", newvalue-oldvalue)
  end
  return false

end

function rune_mind_handler( valname, oldvalue, newvalue ) --ftag:itmw

  if valname == "count" and oldvalue < newvalue then
    Game.GVNumInc("runes_mind_received", newvalue-oldvalue)
  end
  return false

end

function is_day() --ftag:if
  return Game.DayTime() == 1
end

function is_night() --ftag:if
  return Game.DayTime() == 3
end
