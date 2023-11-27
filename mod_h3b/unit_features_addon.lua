function griffin_clear_effect()
	 if Attack.act_spell_count( 0 ) > 0 then
				Attack.act_del_spell( 0 )
				Attack.act_aseq( 0, "clear" )	
				Attack.aseq_timeshift(0,1)
				Attack.log("add_blog_clear_bonus","name",blog_side_unit(0))		
 	end 

  return true
end


function features_panik( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
 	if minmax == 0
	 and not hitbacking then
		  local fear = apply_difficulty_level_talent_bonus( 30 )
  		local level = 4
  		local duration = apply_difficulty_level_talent_bonus( 2 )
  		local rnd = Game.CurLocRand( 1, 100 )
  		local race = { elf=true, dwarf=true, human=true, orc=true, neutral=true }

		  if rnd < fear
			 and race[ Attack.act_race( attacker ) ]
			 and Attack.act_level( attacker ) <= level
			 and not Attack.act_feature( attacker, "mind_immunitet" )
			 and not Attack.act_feature( attacker, "undead" )
			 and damage > 0
			 and not Attack.act_feature( attacker, "pawn" )
			 and not Attack.act_feature( attacker, "boss" ) then
      Attack.act_apply_spell_begin( attacker, "effect_fear", duration, false )
      Attack.act_apply_par_spell("autofight", 1, 0, 0, duration, false )
      Attack.act_apply_spell_end()
 					Attack.act_damage_addlog( attacker, "add_blog_fear_" )
					 Attack.atom_spawn( attacker, 0, "magic_scare", Attack.angleto( attacker ), true )
 					Attack.act_damage_addlog( attacker, "add_blog_fear_" )
  		end
 	end
	
  return damage, addrage
end


function features_execution( damage, addrage, attacker, receiver, minmax, userdata, hitbacking )
	 if minmax == 0
	 and Attack.atk_name() == "execution"
	 and damage >= Attack.act_totalhp( receiver )
	 and not Attack.act_pawn( receiver ) then
  		local fear = apply_difficulty_level_talent_bonus( 50 )
  		local level = 4
  		local duration = apply_difficulty_level_talent_bonus( 2 )
  		Attack.act_damage_addlog( receiver, "add_blog_exec_", true )

  		for i = 1, Attack.act_count() - 1 do
   			if Attack.act_enemy( i )
					 and Attack.act_applicable( i )
					 and Attack.act_hp( i ) > 0 then
    				Attack.act_apply_spell_begin( i, "effect_indecision", duration, false )
   					Attack.act_apply_par_spell( "initiative", -1, 0, 0, duration, false )
    				Attack.act_apply_spell_end()
    				Attack.atom_spawn( i, 0, "effect_execution", Attack.angleto(i), true )
								
   					if Game.CurLocRand( 1, 100 ) < fear
						 	and Attack.act_level( i ) <= level
						 	and not Attack.act_feature( i, "mind_immunitet" )
						 	and not Attack.act_feature( i, "undead" )
						 	and damage > 0
						 	and not Attack.act_feature( i, "pawn" )
						 	and not Attack.act_feature( i, "boss" ) then
    						Attack.act_apply_spell_begin( i, "effect_fear", duration, false )
   							Attack.act_apply_par_spell( "autofight", 1, 0, 0, duration, false )
    						Attack.act_apply_spell_end()
				  				Attack.act_damage_addlog( i,"add_blog_fear_" )
  								Attack.atom_spawn( i, 0, "magic_scare", Attack.angleto( i ), true )
   					end
			   end
 	 	end
	 end

  return damage, addrage
end


