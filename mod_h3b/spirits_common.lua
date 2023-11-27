function spirit_after_hit()
  -- spend rage
  local hero_rage = Logic.cur_lu_item( "rage", "count" )
  local rage_used = tonumber( "0" .. Attack.get_custom_param( "rage" ) )
  local new_hero_rage = math.max( 0, hero_rage - rage_used )
  Logic.cur_lu_item( "rage", "count", new_hero_rage )

  -- add exp
  SECOND_SPIRIT_ATTACK = 1
  local exp_add = tonumber( "0" .. Attack.get_custom_param( "exp" ) )
  local exp_bonus = tonumber( "0" .. Logic.hero_lu_item( "sp_addexp_spirit", "count" ) )
  local status = Attack.add_exp( exp_add * ( 1 + exp_bonus / 100) )

  return status
end
