-- New! Common function for (permanently) increasing hero's stats
function apply_skill_bonus_to_hero( name, level, param, bonus_name, bonus_type, bonus_gain )
  local bonus = skill_power( name, param, level - 1 )

  if level > 1 then bonus = bonus - skill_power( name, param, level - 2 ) end

  if bonus_gain ~= nil then
    bonus = bonus * bonus_gain
  end

  local cur_bonus = Logic.hero_lu_item( bonus_name, bonus_type )
  Logic.hero_lu_item( bonus_name, bonus_type, cur_bonus + bonus )

  return true
end


-- New! Common function for applying a skill bonus to a value
function common_apply_skill_bonus( value, skill_name )
  local par = 1

  if skill_name == "holy_rage" then
    par = 3
  elseif skill_name == "necromancy" then
    par = 4
  end

  value = value * ( 1 + tonumber( skill_power2( skill_name, par ) ) / 100 )

  return value
end


function skill_caption()

    local name=""
--  (level, group, rune_might, rune_magic, rune_mind)
    local level, group, rune_might, rune_mind, rune_magic =Logic.hero_lu_skill()

  if level< 1 then
    name = "<label=skill_name_closed_font>"
  else
    name = "<label=skill_name_open_font>"
  end

    return name

end


function skill_name_hint()

    local name=""
--  (level, group, rune_might, rune_magic, rune_mind)
    local level, group, rune_might, rune_mind, rune_magic=Logic.hero_lu_skill()

  if group == 0 then
    name = "<label=skill_CapMight_font>"
  end
  if group == 1 then
    name = "<label=skill_CapMind_font>"
  end
  if group == 2 then
    name = "<label=skill_CapMagic_font>"
  end

    return Game.Config("txt_font_config/hint_cap")
    --name

end


function skill_level()

    local count="<label=skill_level>"
--  (level, group, rune_might, rune_magic, rune_mind)
    local level, group, rune_might, rune_mind, rune_magic=Logic.hero_lu_skill()
    local max_level=Logic.skill()
        count=count.." "..level.." / "..max_level

    if level == 0 then
        count=count.."<label=skill_hintDis_font>"
    else
        count=count.."<label=skill_hintDef_font>"
    end

    return count

end


function skill_text_hint()

    local current=""
    local level=Logic.hero_lu_skill()
    local max_level=Logic.skill()

    local s_name="skill_"..Logic.skill_name().."_text_"
--

    if level==0 then
        s_name=s_name.."1"
        --"skill_rage_text_l1" --"skill_"..Logic.skill_name().."text_l1"
        current="<label="..s_name..">"
    else
      if level==max_level then
          s_name=s_name..max_level
          current="<label="..s_name..">"
      else
          local n_name=s_name..(level+1)
          s_name=s_name..level
          current="<label="..s_name..">"
          local cur_head="<label=skill_next_level>"
          local cur_next="<label="..n_name..">"
          current=current.."<br><br><label=skill_hintLev_font>"..cur_head.."<br><label=skill_hintDis_font>"..cur_next
      end
    end
    --skill_rage_hint

    return current

end


function skill_learn()

    local itogo=""
    if Logic.hero_lu_skill_upg() then
        itogo = "<br><label=skill_hintYesUp_font><label=skill_Upgrade>"
    end

    return itogo

end


function skill_rune()

    local count=""
--  (level, group, rune_might, rune_magic, rune_mind)
    local level, group, rune_might, rune_mind, rune_magic=Logic.hero_lu_skill()

    if rune_might~=nil and  rune_mind~=nil and rune_magic~=nil then
        if (rune_might+rune_mind+rune_magic)>0 then
            if Logic.hero_lu_skill_upg() then
                count=count.."<label=skill_hint_TM_font><label=skill_rune_need> "
            else
                count=count.."<label=skill_hintNoUp_font><label=skill_rune_need> "
            end
        end

        if rune_might>0 then
            if Logic.hero_lu_item("rune_might","count")<rune_might then
                r="<image=Message_icon2_rune_red.png><label=skill_hintNoUp_font>"..rune_might
            else
                r="<image=Message_icon2_rune_red.png><label=skill_hint_TM_font>"..rune_might
            end
        else
            r=""
        end

        if rune_mind>0 then
            if Logic.hero_lu_item("rune_mind","count")<rune_mind then
                g="<image=Message_icon2_rune_green.png><label=skill_hintNoUp_font>"..rune_mind
            else
                g="<image=Message_icon2_rune_green.png><label=skill_hint_TM_font>"..rune_mind
            end
        else
            g=""
        end

        if rune_magic>0 then
            if Logic.hero_lu_item("rune_magic","count")<rune_magic then
                b="<image=Message_icon2_rune_blue.png><label=skill_hintNoUp_font>"..rune_magic
            else
                b="<image=Message_icon2_rune_blue.png><label=skill_hint_TM_font>"..rune_magic
            end
        else
            b=""
        end

        count=count..r..g..b
    end
    return count

end


function skill_head_hint()

    local level=Logic.hero_lu_skill()
    local max_level=Logic.skill()

    local s_name="skill_"..Logic.skill_name().."_text_"
--
        local current="<label=skill_"..Logic.skill_name().."_header><br>"
    if level==0 then
        s_name=s_name.."1"
        --"skill_rage_text_l1" --"skill_"..Logic.skill_name().."text_l1"
        current=current.."<label="..s_name..">"
    else
      if level==max_level then
          s_name=s_name..max_level
          current=current.."<label="..s_name..">"
      else
          local n_name=s_name..(level+1)
          s_name=s_name..level
          current=current.."<label="..s_name..">"
          local cur_head="<label=skill_next_level>"
          local cur_next="<label="..n_name..">"
          current=current.."<br><br><label=skill_hintLev_font>"..cur_head.."<br><label=skill_hintDis_font>"..cur_next
      end
    end
    --skill_rage_hint

    return current

end


function skill_need_for_learn()

    local itogo=""
    local learn, skill_need = Logic.hero_lu_skill_upg()

        if skill_need~="" then
            skill_need=string.gsub(skill_need, "/", ",")
            itogo = "<label=skill_hintNoUp_font>"

            local count = text_par_count(skill_need)/2
            for i=0,count-1 do
                local sk_need_name = text_dec(skill_need, i*2+1)
                sk_need_name = "<label=skill_"..sk_need_name.."_name>"
                local sk_need_level = text_dec(skill_need, i*2+2)
                itogo=itogo.."<br>'"..sk_need_name.."' "..sk_need_level.." <label=skill_level_need>"
            end
        end

    return itogo

end


function skill_name()

    return "<label=skill_"..Logic.skill_name().."_name>"
end

--skill [skillname [, level]] Инфа по скилу. Если без указания level'а, то возвратит количество левелов.
-- Если указать level, то для него вернет строку-параметр. Не указывать имя можно только в gen_text

function skill_param( param )
  local par = ""
  local level = tonumber( text_dec( param, 1 ) ) - 1

  if string.find( param, "duration" )
  or string.find( param, "bless" ) then
    return "+" .. tostring( math.max( 0, level - 1 ) )  -- +1 duration for skill level 3
  end

  local number_of_param = tonumber( text_dec( param, 2 ) )
  local max_level = Logic.skill()
  local skillname = Logic.skill_name()

  local max_level = Logic.skill()

  if level > max_level then return "level error" end

		if text_dec( param, 2 ) == "necro" then
			return "+" .. tostring( level + 1 ) .. "0%"
		end

  local par_string = Logic.skill( skillname, level )
  par_string = string.gsub( par_string, "/", "" )
  par = text_dec( par_string, number_of_param )

  return par
end


function skill_power( skillname, param, level )
  level = tonumber( level )

  if level == nil then level = Logic.hero_lu_skill( skillname ) - 1 end

  if level < 0 then return 0 end
  --local skillname=Logic.skill_name()

  local par_end = 0
  local par_string = Logic.skill( skillname, level )
  local par = ""

  if par_string ~= ""
  and par_string ~= nil then
    par_string = string.gsub( par_string, "/", "" )
    par = text_dec( par_string, param )
    if par ~= ""
    and par ~= nil then
      local par_e = string.gsub( par, "%D", "" )
      par_end = tonumber( par_e )
    end
  end

  return par_end
end


function skill_power2( skillname, param, level )
	 if Attack.act_belligerent() ~= 1 then return 0 end

	 return skill_power( skillname, param, level )
end


function hero_item_count( name )
  local count = Logic.hero_lu_item( name, "count" )

  if count == nil then return 0 end

  return count
end


function hero_item_count2( name )
	 if Attack.act_belligerent() ~= 1 then return 0 end

  local count = Logic.hero_lu_item( name, "count" )

  if count == nil then return 0 end

  return count
end


function hero_item_limit( name )
  local limit = Logic.hero_lu_item( name, "limit" )

  if limit == nil then return 0 end

  return limit
end


-- коэффеициент домножения для получения цены
function skill_trader()
  return skill_power( "trader", 1 ) / 100
end


-- прибавочные скиллы
-- +Контроль Ярости (Ярость), +Слава (Лидерство), +Рунный Камень (Руны), +Мудрость (мана и свитки)
function skill_glory( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "leadership", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_alchemist", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_archdemon", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_archer", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_archmage", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_barbarians", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_vampire", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_vampire2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_bears", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_bear_white", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_beholder", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_beholder2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_blackdragon", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_blackknight", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_bonedragon", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_bowman", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_cannoner", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_catapult", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_cerberus", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_cyclop", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_demon", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_demoness", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_devilfish", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_dragonflies", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_druid", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_dryad", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_dwarf", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_elf", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_elf2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_ent", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_ent2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_footman", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_footman2", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_ghosts", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_giant", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_goblin", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_goblin2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_greendragon", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_griffin", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_horseman", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_hyena", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_imps", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_kingthorn", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_knight", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_miner", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_necromant", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_ogre", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_orc", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_orc2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_peasant", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_pirate", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_pirate2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_priest", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_priest2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_reddragon", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_robber", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_robber2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_shaman", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_skeleton", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_snakes", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_snake_royal", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_spider", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_spider_fire", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_spider_undead", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_spider_venom", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_sprites", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_thorn", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_thorn_warrior", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_unicorns", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_werewolf", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_graywolf", "count" )
--  apply_skill_bonus_to_hero( name, level, 2, "sp_lead_unit_zombies", "count" )

  return true
end


function skill_rage( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "rage", "limit" )

  return true
end


-- "traning" is misspelled in SKILLS.TXT
function skill_traning( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "attack", "count" )

  return true
end


function skill_start_defense( name, level )
  apply_skill_bonus_to_hero( name, level, 2, "defense", "count" )

  return true
end


function skill_explorer( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "intellect", "count" )

  return true
end


function skill_holy_rage( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "rage", "limit" )
  apply_skill_bonus_to_hero( name, level, 1, "mana", "limit" )

  return true
end


--booksize
function skill_wizdom( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "mana", "limit" )
  apply_skill_bonus_to_hero( name, level, 2, "booksize", "count" )

  return true
end


function skill_rune_stone( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "rune_might", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "rune_magic", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "defense", "count" )

  return true
end


----
function skill_archer( name, level )
-- For the individual bonuses to work, sp_lead_archer must not have any units
-- otherwise the individual bonuses are ignored. Each individual bonus is
-- therefore adjusted rather than the group sp_lead_archer. See SPECIAL_PARAMS.TXT
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_alchemist", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_archer", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_bowman", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_cannoner", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_catapult", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_cyclop", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_elf", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_elf2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_goblin", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_kingthorn", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_thorn", "count" )

  return true
end


function skill_inquisition( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_priest", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_priest2", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "rage", "limit" )
  apply_skill_bonus_to_hero( name, level, 2, "mana", "limit" )
  apply_skill_bonus_to_hero( name, level, 3, "intellect", "count" )

  return true
end


function skill_archmage( name, level )
-- For the individual bonuses to work, sp_lead_archmage must not have any units
-- otherwise the individual bonuses are ignored. Each individual bonus is
-- therefore adjusted rather than the group sp_lead_archmage. See SPECIAL_PARAMS.TXT
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_archmage", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_beholder", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_beholder2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_druid", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_necromant", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_priest", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_priest2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_shaman", "count" )
  apply_skill_bonus_to_hero( name, level, 2, "intellect", "count" )

  return true
end


--New High Magic
function skill_hi_magic( name, level )
  apply_skill_bonus_to_hero( name, level, 3, "intellect", "count" )
  apply_skill_bonus_to_hero( name, level, 4, "mana", "limit" )

  return true
end


function skill_necromancy( name, level )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_archer", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_vampire", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_vampire2", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_blackknight", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_bonedragon", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_ghosts", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_necromant", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_skeleton", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_spider_undead", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "sp_lead_unit_zombies", "count" )

  return true
end


function skill_spirit( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "sp_addexp_spirit", "count" )

  return true
end


--sp_lead_warrior
function skill_warrior( name, level )
-- For the individual bonuses to work, sp_lead_warrior must not have any units
-- otherwise the individual bonuses are ignored. Each individual bonus is
-- therefore adjusted rather than the group sp_lead_warrior. See SPECIAL_PARAMS.TXT
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_footman", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_footman2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_horseman", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_knight", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_barbarians", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_blackknight", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_demon", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_dwarf", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_goblin2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_orc", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_orc2", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_skeleton", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_werewolf", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_lead_unit_zombies", "count" )
  apply_skill_bonus_to_hero( name, level, 3, "attack", "count" )
  apply_skill_bonus_to_hero( name, level, 4, "rage", "limit" )

  return true
end


-- учитывается другим способом. скрипт не использован!
function skill_exp( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "sp_addexp_battle", "count" )
  apply_skill_bonus_to_hero( name, level, 1, "sp_addexp_quest", "count" )

  return true
end


-- учитывается другим способом. скрипт не использован!
function skill_gold_quest( name, level )
  apply_skill_bonus_to_hero( name, level, 1, "sp_addgold_quest", "count" )

  return true
end

--sp_addgold_quest {}


function army_text_to_table(army,max)

    local tbl = {}
    for i=1,max do
        local atom, count = Logic.army_get(army, i)
        if count > 0 then
            if tbl[atom] == nil then tbl[atom] = count
            else tbl[atom] = tbl[atom] + count end
        end
    end
    return tbl

end


function diplomacy_check()

    local perc = skill_power("diplomacy", 1)
    if perc > 0 then

        local enemy = army_text_to_table(Logic.cur_lu_army(),10)
        local hero  = army_text_to_table(Logic.hero_lu_army(),5) -- учитываем только основную армию, без резерва
        local hero_ld = Logic.hero_lu_item("leadership","count")

        local join_max = {} -- отряды, которые могут присоединиться по максимуму
        local join_maxs = 0
        local join_other = {} -- отряды, которые могут присоединиться, но не по максимуму
        local join_others = 0

        for atom, count in pairs(hero) do
            if enemy[atom] ~= nil then -- у врага есть такой же отряд как и у героя
                local can_join = math.floor(hero_ld / Logic.cp_leadship(atom)) - count -- сколько можно взять по лидерству
                local can_capture_from_enemy = math.floor(enemy[atom]*perc/100.) -- сколько может отдать враг
                if can_join > 0 and can_capture_from_enemy > 0 then
                    if can_join >= can_capture_from_enemy then
                        join_max[atom] = can_capture_from_enemy
                        join_maxs = join_maxs + 1
                        join_max[join_maxs] = atom
                    else -- потенциал скила использован не полностью - не хватает лидерства, поэтому этих юнитов присоединяем в последнюю очередь
                        join_other[atom] = can_join
                        join_others = join_others + 1
                        join_other[join_others] = atom
                    end
                end
            end
        end

        joining_cp = nil
        if join_maxs > 0 then
            joining_cp = join_max[Game.Random(1, join_maxs)]
            joining_count = join_max[joining_cp]
        elseif join_others > 0 then
            joining_cp = join_other[Game.Random(1, join_others)]
            joining_count = join_other[joining_cp]
        end

        if joining_cp ~= nil then
            local text = "<label=diplomacy_mes><imu="..joining_cp..".png><br><label=cpsn_"..joining_cp..">: "..joining_count
            Logic.cur_lu_var("diplomacy", text)
            return true
        end

    end
    return false

end


function do_diplomacy()

    Logic.hero_lu_army_change(joining_cp, joining_count)
    Logic.cur_lu_army_change(joining_cp, -joining_count)
    return false -- no break execution

end
