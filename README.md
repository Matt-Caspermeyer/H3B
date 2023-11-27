# H3B

Heroes of Might and Magic 3 Babies (HOMM3 Babies) Mod / Micro / Mini Expansion Pack for King's Bounty: The Legend
-----------------------------------------------------------------------------------------------------------------

Created by: Matt Caspermeyer (matt.caspermeyer@cox.net)
-------------------------------------------------------

You are free to use any part of my work in your projects so long as you give me credit.


Installation:
-------------

1. This mod is not compatible with any other mods since I've most likely modified a file that another mod uses.
    1. You will need to remove all mods from your King's Bounty: The Legend "mods" folder before installation of this mod.
    1. Ensure that the "mods" folder exists, it is typically located here: C:\Program Files (x86)\1C Company\King's Bounty\data\mods
    1. If the "mods" folder does not exist then create it below the "data" folder using the path above as a guide.
2. Extract mod_h3b.kfs included in this archive to the King's Bounty: The Legend mods folder.
    1. This folder is typically here: C:\Program Files (x86)\1C Company\King's Bounty\data\mods
    1. If the "mods" folder does not exist, then see note 1bi above.
3. Run the game
    1. Start a new game to play!
    1. It is not recommended to continue your current game, please restart.
    1. For your first play through:
        1. Please do not use any cheats (i.e. Save Game Scanner, etc.)
        1. Please do not use with any other mods (probably won't work anyway)
        1. You'll be able to experience the mod as I intended it to be played.


Uninstallation:
---------------

1. Simply delete mod_h3b.kfs from your "mods" folder.
2. Done!


Notes:
------

1. This mod was developed using the Gamer's Gate V1.7 (Build 35,396) version of King's Bounty: The Legend.
<ol type="a">
  <li> If you have a different version of the game, then it is possible that not all features of the mod will work.</li>
  <li> For example, I also have the GoG version of the game and it is V1.7 (Build 35,234) and:</li>
    i. There is a bug with the Game.LocType LUA Library function that causes LUA execution stop due to some internal error. All features that use LUA scripts to implement location logic has been commented out to prevent the game from crashing / having problems.
    ii. It does not support the damage hint displays for the Spirit abilities that I added in Beta 2013-12-25 and later versions of this mod.
    iii. Please email the company you got Build 35,234 from and request they update to Build 35,396.
</ol>
2. I have not tried it with other versions.
3. This mod uses the English localizations using both the "eng_" and "en_" prefixes for the localization files.
  a.  As mentioned above, only one of those files is needed to play the game.
  b.  Other versions may have other prefixes and so you may be able to get this mod to work with your localization version by changing the prefixes of the *.LNG localization files.
    i. The *.LNG files are located inside mod_homm3_babies_en_lng.kfs or mod_homm3_babies_eng_lng.kfs both file sets are identical so either may be used as a baseline.
    ii. Simply rename *.kfs to *.zip and extract files if you wish to attempt this.
    iii. Currently, you're on your own if you want to get it to work with a different localization, but if you'd like to help with localizations in your country then please let me know.


Issues / Bugs:
--------------

Since this is a beta release of this mod, it is quite possible that your game will crash or you'll find bugs in this mod. Please provide me feedback on any issues that you are having with my mod so that I can make improvements and make your playing experience more enjoyable.

If you have any problems during play, here are some pointers:

1. If it is a game crash, note which action caused the crash.
2. If the game appears to lock up, ALT-TAB back to Windows to see if there is a pop-up.
  a.  If there is a pop-up window, note the message and then click OK to proceed.
  b.  After you click OK, the game will most likely crash exit to Windows.
  c.  If the game does not crash after you click OK, it is highly recommended to quit your game rather than continue since behavior may be strange.
3. Save your game often just in case!
4. If the game locks up when you cursor over a child or item, there is a misspelling in one of the templates:
  a.  Note which child it is when this happens
  b.  Contact me and let me know which child it is and I'll correct the error
  c.  I hope we've found all these errors!
5. Try to load from a save game and see if it still crashes in the same spot. If it crashes in the same spot, the only hope I have of resolving the issue is for:
  a.  You to provide me a savegame.
  b.  Provide me the exact steps to repeat the crash.
  c.  Without these, my chance of resolving this issue is probably very slim.

Crash List
----------

1. I've had crashes with a failure to allocate more memory a couple of times.
  a.  The solution is to reload your most recent save game and simply continue.
  b.  Let me know if you see this problem, but currently I have no idea how to resolve it (I probably would need 1CC or Katauri Interactive's help with this one).
  c.  This problem seems to exhibit itself after you've been playing a long gaming session (it seems like I run into this after playing for several hours).

Bug List:
---------

1. Damage causing effects (i.e. burning and poison):
  a.  If an AI unit is killed by a damage causing effect and if the next unit to move is another AI unit, then their damage causing effect is skipped if they have one.
  b.  I worked and worked trying to fix this bug, but to no avail.
    i. I'm pretty sure that it is a bug with the game itself as I don't think they intended for damaging effects to kill units.
    ii. As such, I don't know how to fix this bug, but if you have any ideas then please let me know!

If you notice any other problems or issues, then please let me know!

It is my intent to make this mod as bug free and enjoyable as possible!


Updates:
--------

1. As this version of the mod is in a beta state, there are still changes that are being done; however:
  a.  The mod is stable enough to play the game completely through - enjoy!
  b.  Every change has been checked at least once, but I'm in the quality assurance phase rechecking the code.
  c.  I'm currently play testing the game with a Paladin.
2. At this stage, changes should not require you to restart your game - simply install the new files and continue playing.
  a.  Changes will be focused on editing data files (i.e. *.ATOM, *.TXT) to improve game balance and user enjoyability.
  b.  New features can still be added, but only if they are really good ideas!
3. Updates will most likely occur on a monthly basis depending on severity and other factors.
4. Once the quality assurance phase is completed and sufficient feedback is garnered, the project will transition to the release phase.
5. The release phase will have all features properly implemented and all controllable bugs fixed.


Modders:
--------

1. I've made many changes under the hood that only modders or code aficionados would notice.
2. I've added comments where warranted to the areas in the game that I've changed, but not everywhere.
  a.  Feel free to look at these comments and provide me feedback if you know of a better way to implement something.
  b.  Certain comments have the word "HACK" where I did not know how to do it a better way - once again if you know a better way to implement this feature then please let me know!
3. I've unified many *.LUA functions (i.e. like SPELLS_POWER.LUA) so that they all use the same bonus system, etc.
4. I've made common functions for dealing with redundant code.
  a.  The original *.LUA files had lots and lots of redundant code.
  b.  I've replaced most of the redundant code in the *.LUA functions I've edited to reduce error and provide code consistency.
5. I've beautified the sections of the *.LUA files I've changed to make reading the code much, much easier.
6. The changes I've made really form the basis of a new code base from which you can create new mods.


Copyright Issues:
-----------------

1. This work contains images from the Heroes of Might and Magic 3 game and those images are copyrighted.
2. The picture for Orcelyn Ordy I found via the web, but I have not been able to find out who created that source image.
  a.  If you have any information about who created this picture please let me know and I'll give credit to the author.
3. I created all the new ability icons.
4. All of my effort is being freely distributed to the public domain.
  a.  Please give me credit if you use any portion of my work in your projects - thanks! :-)
  b.  Feel free to use this code base as a starting point for your own mod!


THANK YOU!!!
------------

1. Thanks to all the people posting in the King's Bounty forums, especially those with modding tips!
2. Thanks for trying out my mod and providing feedback!


/C\/C\ Matt Caspermeyer


Change List
-----------

This list is provided for historical purposes as well as for people to learn about the changes made.

Windows 8 Comments
* I've had crashes when trying to transfer save games from Windows 7 to Windows 8. I'm not sure what is going on here for certain, but it appears to be related to file credentials.
* I was able to copy a save game from my Windows 7 install to my Windows 8 install by:
  * Copying it to the root folder of my Windows 8 install (i.e. C:\)
  * Then copying it to my user folder
* I was able to play for the most part, except that when I try to go to the Western Islands, the game crashes.
* I also tried a new game with Windows 8 and did not have the same issues and I was also able to make it to the Western Islands without it crashing
* I have been unable to copy a save game from my Windows 8 install to my Windows 7
  * The file simply doesn't appear in the save game list when I'm trying to load a save game from Windows 7
  * I'm not sure what the problem is here.
* So it seems best to just stick with playing your games in the Windows you started them with and to just start a new game if you want to switch O/S's.
* I've noticed that I get more diagnostic error messages when running the game in -dev mode with Windows 8 than with Windows 7
* Because of this, I've found quite a few more bugs than I noticed than when I was developing on Windows 7.
* So this release is mostly bug fixes, but there are some new features as well.

Version 1.0 2021-MM-DD
-------------------------
*.ATOM - altered the movement points of a lot of units and added the run ability to quite a few more atoms and the action points are now variable
  * Most biped units move just 1 or 2 movement points, but have the run ability to make up for it and it is also reloadable
  * Snakes have either 1 or 2 movement points (but can run)
  * Spiders have 2 movement points (but can run)
  * Most 4-legged units move 3 movement points (and can run)
  * Most flyers move 5 or more movement points
  * Most other units that could run before now have variable AP
  * Ogre's rage ability now has variable AP (and they can run now)
  * Increased dwarf unit resistance since they all move just 1 movement point now (they can run, though) and gave them Magic Resistance
  * Implemented the Cold Resistance Type in LOGIC.TXT and have updated units that have a Cold Resistance value to their *.ATOM
  * Snakes now have Night Sight and receive a defense bonus in forests, but have reduced health in winter arenas.
  * ARCHMAGE.ATOM - fixed issues with shock no longer working for Archmages - thanks @SlickDragon! (when I added Blue Dragons, I broke Archmage's shock):
    *  Removed the level= custom parameter from their moveattack section (now they can't shock with melee any more)
    *  Added level=5 custom parameter to their lightning section (now they can shock with their ranged attack again)
  * WOLF.ATOM: Werewolf Elves in Wolf form now have their own Werewolf Cry which affects level 3 units
  * Changed Phoenix damage (all 3) to be 25% astral / 75% fire (instead of 50 / 50 before)
  * Increased Physical Resistance and Fire Resistance for Footmen, Horsemen, and Knights
  * Increased Physical Resistance of Black Knights
  * The following units are now furious (always retaliating to attacks):
    * All Barbarians, Bears, and Cerberi
  * Thorns (Thorn Hunters, Thorn Warriors, and Royal Thorns) now rejuvenate 10% of their lost stack hp each turn
  * Cyclops recover 25% of their lost hp each turn
*.CHAT - I currently don't have these put in as players can just run away from the dragon if it's too tough
  * These two deal with the changes to the increase in difficulty on impossible allowing the starting Dragon to be defeated (with the default 10 Knight's and Horsemen it was possible that the Dragon was unbeatable).
    * 1405621286.chat - increased Iron Richard's +Leadership to allow for 15 Knights and Horsemen
    * 1329609773.chat - Iron Richard now removes the same leadership added as above
*.DAT
  * ITEXTURES.DAT - added new TEX340.DAT to include list
  * TEX340.DAT - new DDS icon data file for the item bonus icons
*.DDS
  * TEX340.DDS - new picture file that contains the item bonus icons (i.e. attack, defense, etc.)
*.LNG - added all of the LNG's from my English Grammar mod
    * EN(G)_BATTLE.LNG
      * Added new features to the combat log
    * EN(G)_CHAT_0814853819_0185019267.LNG (Lady Beaulla) - fixed misspelling: honer -> honor
    * EN(G)_CHAT_1920750196_1155319803.LNG (Furious Paladin) - "but no I don't remember... so what's" -> "but no, I don't remember... so, what's" (thanks to Dohi64)
    * EN(G)_ITEMS.LNG - grammar fixes (some of these are from my grammar patch that forked and others provided by Dohi64)
      * "strike it couple of" -> "strike it a couple of" (thanks to Dohi64)
      * "image of the skull and the crossbones" -> "image of a skull and crossbones"
      * "The ordinary golden" -> "An ordinary golden" (thanks to Dohi64)
      * "with a straw" -> "with straw" & "even of teeth" -> "even teeth"
      * "trident more" -> "trident is more" x3
      * "This is item" -> "This item"
      * "are still sometimes still used" -> "are sometimes still"
    * EN(G)_CREDITS.LNG - updated the credits for beta testers! Pretty much if you provided comments in the forum then I included you in the credits:
      * @bacchus1974
      * @Gza
      * @Helios
      * @jorko80
      * @Kiras
      * @Nevar
      * @ShuiMienLung
      * @SirLancelot
      * @Sir Whiskers
      * @SlickDragon
      * @Zepdog
    * EN(G)_HERO.LNG - added bonuses to descriptions for the following on the hero screen:
      * Gold
      * Rage
      * Mana
    * EN(G)_ITEMS_BONUS.LNG - new file that contains all the labels for the auto-generated item bonuses
    * EN(G)_SKILLS.LNG
      * Added Summon Dragonfly to the list of talents affected by the Glory skill
      * Clarified Frenzy description a little bit
      * Skill Healer:
        * (Level 3) now lists the bonus for Bless as two possibilities, whichever is greater (see SPELL_EFFECTS.LUA)
	* Added Recovery and Rejuvenation to the list of abilities increased by it
      * Skill Necromancy (Level 3) now lists the bonus for Weakness as two possibilities, whichever is greater (see SPELL_EFFECTS.LUA)
    * EN(G)_SPELLS.LNG
      * Bless now maximizes the target's damage for all attacks and allows use of talents at maximum capability
      * Weakness now minimizes the target's damage for all attacks and allows use of talents at minimum capability
      * Added updates to spell descriptions where the number of targets could change as a function of level
    * EN(G)_UNITS.LNG
      * Leadership reduction bonus is now shown on the unit card
      * Added new multi-unit descriptions for combined units:
        * cpsn_sprites - all sprites (Sprites & Lake Fairies)
	* cpsn_unicorns - all unicorns (Unicorns & Black Unicorns)
	* cpsn_zombies - all zombies (Zombies & Decaying Zombies)
	* cpsn_ghosts - all ghosts (Ghosts & Cursed Ghosts)
	* cpsn_imps - all imps (Imps and Scoffer Imps)
	* cpsn_barbarians - all barbarians (Barbarians & Berserkers)
	* cpsn_dragonflies - all dragonflies (Fire & Lake Dragonflies)
	* cpsn_snakes - all level 2 snakes (Snakes & Swamp Snakes)
	* cpsn_bears - all level 3 bears (Bears & Ancient Bears)
    * EN(G)_UNIT_FEATURES.LNG
      * Updated descriptions to include changes to snakes
      * Added new features:
        * Recovery for Cyclops
	* Rejuvenation for all Thorns
    * EN(G)_UNIT_SPECIALS.LNG
      * Updated description of Bless to include changes (see EN(G)_SPELLS.LNG)
    * EN(G)_WINDOWS.LNG
      * Updated hints on the loading screen for the new features
      * Changed version ID
    * TEMPLATES.LNG
      * Added new macros to "left_t" template for displaying the additional information identified in EN(G)_HERO.LNG
      * Added weakness macro to "skills_tPar" template to display the bonus to the weakness spell in the Necromancy skill description (see EN(G)_SKILLS.LNG)
      * Added new sp_lead_unit macro to def_hint_t1 template for showing the leadership reduction bonus on the unit card
      * Added new bonuses macro to items_tM to auto generate all item bonuses
*.LUA
  * ARENA.LUA
    * ***BUG*** Fixed issue that only affected Paladins: the Holy Rage Attack bonus would cause the Evil Book to apply 2x damage to Undead and Demons when casting damage causing spells on these targets
    * ***NEW*** Function correct_damage_minmax now is used to apply Bless / Weakness bonuses to talents and abilities (see EN(G)_SPELLS.LNG)
    * ***FIX*** I think I was double dipping on the Morale and Attack / Defense / Critical Hit penalties during long combats and so I've commented out the code that was changing the 3 latter parameters and now am relying solely on the Morale penalty to affect the other 3
    * New! Added logic for the new Werewolf Cry
    * Beautiful units now only have a 50% and Cute units a 25% chance of being struck by humanoid troops
    * New! Haas's influence now spreads far and wide and there is a chance of a unit's map difficulty bonus being doubled at the start of combat & the unit always retaliating
      * As an example of this, if you're fighting in Marshan Swamp Impossible, the difficulty bonus is 0.5 and the map bonus is 0.0625 for a total of 0.5625. The 0.0625 could now double to 0.135 for a total of 0.635.
      * The chance of this happening is diff_k * maplocK in LOGIC.TXT (0.5625 * 1e4 = 5625) out of maplocPct in LOGIC.TXT (25000) or about 1/5 of the units could be affected in Marshan Swamp. Chance for the number of units affected goes up by map location difficulty.
  * ITEMS_HINT.LUA
    * Due to the change in CONFIG.TXT to include ITEMS.TXT (and hence its includes) now the function brute_force_get_params can use Game.Config to get egg parameters when the Object library is not available
    * New function: gen_item_bonus_fight_hint that autogenerates the item "fight" bonuses
    * New function: gen_item_bonus_mod_hint that autogenerates the item "mod" bonuses
  * LOGIC.LUA - total hints is now 185
  * LOGIC_HERO.LUA - implemented new levelup parameter, sp_counter, functions:
    * Function hero_sp_counter: implemented the logic to parse through the sp_counter list
    * Function levelup_counter: generic function that adds a value to a counter or limit
    * The spell's level (i.e. profit) is now used to divide into the chance of getting that spell at start (so for example if spell_chance = 15 and profit = 5, then there is only a 15 / 5 = 3% chance of getting that spell at the start of that game)
  * SKILLS.LUA
    * ***FIX*** Added Blue Dragons to leadership reduction list for Glory Skill (note that this change either requires a restart or for you to have remaining points in your Glory skill since this code only runs when selecting a skill (note that you'll be missing part of the bonus if you already have a point or two in this skill))
    * Updated function skill_param to output changes to Healer and Necromancy (see EN(G)_SKILLS.LNG)
  * SPECIAL_ATTACKS.LUA
    * ***BUG*** AI Black Dragons were still landing on your troops with the WotN code, and so I added logic for all the functions to default to the TL logic if they are controlled by the computer
    * Summon functions now use the new common function in SPELLS.LUA to apply your hero's leadership reduction bonuses to summon talents:
      * special_cast_thorn
      * special_cast_bear
      * special_cast_demon
      * special_summon_plant
      * special_summon_dragonfly
    * Updated talent functions so that they implement the changes to Bless / Weakness (see EN(G)_SPELLS.LNG)
    * ***BUG*** I screwed up on the implementation of a change to the special_bless_attack thereby breaking Priest's Bless and Inquisitor's Holy Rage - now it's fixed!
    * New! Added new Werewolf Cry functions
    * ***BUG*** There was an issue with transforming units where it was possible that their special difficulty bonus was not reapplied after transforming and I think I now have this fixed!
  * SPECIAL_HINT.LUA
    * Updated function gen_special_hint to include changes to Bless / Weakness (see EN(G)_SPELLS.LNG)
    * Due to the issues with sp_lvl_inc, I needed to change the bonus name to sp_lev_inc
  * SPELL_EFFECTS.LUA
    * ***FIX*** Function effect_bless_weakness_attack: added belligerent input so that the bonus to either Bless or Weakness is only carried out if the caster is human
    * ***NEW*** Function apply_bless_weakness_bonus: now either adds  bonus or  bonus*10%, whichever is greater
  * SPELLS.LUA
    * New function, common_get_leadership_bonus, for applying hero leadership reduction bonuses (sp_lead_unit_<atom>) to summoning spells / abilities
    * sp_lead_unit_<demon_atom> bonus now applies to Demon Portal
    * ***FIX*** Spell functions spell_weakness_attack and spell_bless_attack now pass the belligerent into their common function so that the bonus is only applied if the caster is human (see SPELL_EFFECTS.LUA)
    * Function common_freeze_attack: cold_fear has been replaced with the unit's actual cold resistance
    * ***FIX*** Commented out the Critical Hit increase for spell_reaction_attack since the Morale bonus should account for the Critical Hit increase
    * The following spells can be cast on 1, 3, or all targets based on spell level:
      * Stone Skin, Bless, Helplessness, Dragon & Demon Slayer, Battle Cry, Precision, Haste, Slow, Magic Shackles, Weakness, and Doom
    * The Following spells can be cast on 1, 1, or 3 targets based on spell level:
      * Divine Armor, Blind, and Fear
    * Updated Life Light so that it can now be cast on 3, 7, and 19 targets depending on its level
    * Trap can now be cast on 1, 3 (triangular), and 3 (line) squares depending on its level
  * SPELLS_COMMON.LUA
    * Updated selection functions to handle number of targets changes
  * SPELLS_POWER.LUA
    * ***NEW*** function get_ehero_spell_bonus - this function allows the addition of a new spell parameter in SPELLS.TXT, ehero_bonus, that effectively implements a spell power modifier (which the enemy hero files don't have)
    * ***FIX*** Glory was supposed to increase the leadership value for the Demonologist and Hypnosis spells, but it wasn't doing this and now I've added the proper Glory Leadership bonus to these spells for your hero
    * ***NEW*** Function int_dur:
      * Now has updated description for the Bless / Weakness bonuses to include changes in SPELL_EFFECTS.LUA
      * Added new description for item bonuses (this had been omitted before)
    * Due to the issues with sp_lvl_inc, I needed to change the bonus name to sp_lev_inc
  * TEXT_GEN.LUA
    * Implemented addition of the changes to EN(G)_HERO.LNG Hero Screen to display Gold, Rage, and Mana bonuses with the description when pointing at them with the mouse
    * Implemented changes to gen_lead_count to also compute and show the leadership reduction bonus on the unit card
  * UNIT_FEATURES.LUA	
    * Function special_bowman:
      * Updated the special_bowman function to take into account the arrows=1 custom parameter for all their ranged attacks to properly show / do damage
      * Removed bonus applicators for burn, freeze, and arrows since they are meant to be identifiers
      * Organized the function to properly show / perform damage based on which attack the Bowman is using
    * Function special_archer:
      * Did similar to special_bowman to ensure that modifiers aren't used for parameters that are set to specific values
      * Added "special_difficulty" to the list of bonuses not dispelled by the Archer Dispel skill
*.TXT
  * BABY TXT's - numbered all fight filters (where appropriate) so that their bonuses may be auto generated, affects:
    * DIANA_BABIES.TXT
    * FEANORA_BABIES.TXT
      * ***BUG*** made an error in the sp_rage_battle bonus that affected 9 babies - it has now been corrected
      * ***BUG*** made an error in the intellect bonus that affected 10 babies - it has now been corrected
      * kid_bron and kid_arlach - added Werewolf Elves and Werewolves to their bonuses
    * GERDA_BABIES.TXT
      * ***BUG*** made an error in the sp_rage_battle bonus that affected 12 babies - it has now been corrected
    * MIRABELLA_BABIES.TXT
      * ***BUG*** made an error in the sp_rage_battle bonus that affected 11 babies - it has now been corrected
    * NEOKA_BABIES.TXT
    * ORCELYN_BABIES.TXT
    * RINA_BABIES.TXT
      * ***BUG*** made an error in the sp_rage_battle bonus that affected 11 babies - it has now been corrected
      * ***BUG*** made an error in the intellect bonus that affected 7 babies - it has now been corrected
    * XEONA_BABIES.TXT
  * CONFIG.TXT
    * Now includes ITEMS.TXT which in turn includes a lot of files - there appears to be no change in performance (so far as I can tell from including all of ITEMS.TXT and its includes in the Game.Config data structure)
    * The above allows leverage of the Game.Config to enumerate any list included and so this opens up the possibility of being able to autogenerate item descriptions amongst other things
  * HERO.TXT
    * New levelup parameter, sp_counter:
      * Extensible list of the form: sp_counter=sp_counter1_group1,pct,value1-value2,type|sp_counter2_group1,pct,value1-value2,type;sp_counter1_group2,pct,value1-value2,type;sp_counter1_group3,pct,value1-value2,type|sp_counter2_group3,pct,value1-value2,type|sp_counter3_group3,pct,value1-value2,type;...
      * Note that pct is normalized to the sum of all pct's (i.e. it does not need to add to 100)
      * Note that with value1-value2, value2 may be omitted if the value doesn't have variance
      * Type is either "count" or "limit"
    * Implements sp_counter such that now during levelup, a hero will get a +1 in either rage decrease on the map (sp_rage_map) or mana increase on the map (sp_mana_map_prc)
      * Warriors are:
        * 67% chance of +1 to sp_rage_map (average at level 30 is +20 or 20% slower rage drain)
        * 33% chance of +1 to sp_mana_map_prc (average at level 30 is +10 or 10% faster mana recovery)
      * Paladins are:
        * 50% chance of +1 to sp_rage_map (average at level 30 is +15 or 15% slower rage drain)
        * 50% chance of +1 to sp_mana_map_prc (average at level 30 is +15 or 15% faster mana recovery)
      * Mages are:
        * 33% chance of +1 to sp_rage_map (average at level 30 is +10 or 10% slower rage drain)
        * 67% chance of +1 to sp_mana_map_prc (average at level 30 is +20 or 20% faster mana recovery)
      * Note that these are in addition to any item or skill bonuses to these counters
  * ITEMS.TXT
    * ***FIX*** rahha_shield (Rahha's Shield) - added Blue Dragons to the list of dragons that the shield can produce
    * ***FIX*** demetrios1,2,3 (all levels - Demetrius, Class 1, 2, & 3) now applies the leadership reduction to Fire Spiders (since they are Demon troops and I had overlooked this in the past)
    * ***NEW*** in order to auto generate item descriptions, each fight item (for multiple bonuses) must be numbered
    * Items that increase rage inflow now use the bonus sp_rage_battle_inflow to delineate them from sp_rage_battle_prc, which is now only used for items that convert mana into rage (for example, this affect the item rage_spear)
  * LOGIC.TXT - these changes either make easy difficulty level easier or hard and impossible difficulty levels harder:
    * Easy:
      * Enemy units have 75% (was 100%) of nominal statistics
      * Enemy hero spell power is 75% (was 100%) of nominal
      * Round at which mana gain is 1/2: 35 (was 30); 1/4: 50 (was 40)
      * Boss attack and hitpoints are 75% (was 100%) of nominal
      * When dying, the hero now gets 125% (was 100%) of money
    * Hard:
      * Hero experience gain is 50% (was 70%)
      * Enemy power is 150% (was 130%)
      * Spirit experience gain is 75% (was 85%)
      * Money gain is 75% (was 77%)
      * Rage gain during combat is 75% (was 85%)
      * Rage decreases 25% (was 20%) faster on the map
      * Mana recharges 25% (was 20%) slower on the map
      * Enemy units have 125% (was 110%) of nominal statistics
      * Enemy hero spell power is 125% (was 110%) of nominal
      * Boss attack and hitpoints are 150% (were 140%) of nominal
    * Impossible:
      * Hero experience gain is 25% (was 30%)
      * Enemy power is 200% (was 170%)
      * Spirit experience gain is 50% (was 70%)
      * Money gain is 50% (was 60%)
      * Rage gain during combat is 50% (was 70%)
      * Enemy units have 150% (was 125%) of nominal statistics
      * Enemy hero spell power is 150% (was 125%) of nominal
    * Added 2 new parameters for the Haas Map Location Difficulty Bonus
      * maplocK - this is the gain applied to the chance that this will happen
      * maplocPct - this is the chance that the Haas bonus can be applied and goes with maplocK above
    * Implemented actual Cold Resistance, note that cold damage does not display correctly, so right now it is pretty much just another resistance type
  * MORALE.TXT
    * ***FIX*** Added Blue Dragons to +1 Morale unit list for Diplomacy Level 2
  * SKILLS.TXT
    * ***FIX*** Added Blue Dragons to Dark Commander skill bonuses
    * ***BUG*** I did not implement the level 3 Tolerance +6 Resist All bonus properly (now it's fixed!) - thanks @SlickDragon!
  * SPECIALS.TXT
    * New! Added Werewolf Cry special ability (which is a more powerful version of the Wolf Cry)
  * SPECIAL_PARAMS.TXT
    * (Technically not used, but) sp_lev_inc_resurrection -> sp_lvl_inc_resurrection (all the other bonuses like this are this way)
    * Okay, I tried the above and it would cause new games to crash! So now all sp_lvl_inc bonuses are sp_lev_inc bonuses since naming all the bonuses those names does not cause new games to crash and makes all the names consistent. Now I just have to fix where these are used in the LUA files...
    * New! Added new sp_... for the Werewolf Cry
  * SPELLS.TXT
    * Demon Portal (spell_demonologist) - power is now 5, 10, 20 (was 10, 20, 40) this still gives over 100% of Leadership for really high-power mages
    * Evil Book (spell_evilbook) - mana is now 15 (was 10) for level 1 (levels 2 and 3 via formula)
    * ***NEW*** parameter, ehero_bonus:
      * That is of the form: actor_number:bonus (multiple enemy heroes are separated by commas, i.e. actor1_number:bonus,actor2_number:bonus)
      * The actor numbers are in EN(G)_ACTORS.LNG
      * Implements spell power mod functionality for enemy heroes since they technically didn't have this capability in their .HERO file
      * Note that it is now possible to give enemy hero spell power bonuses, for example, all enemy Demon(ess) heroes have a bonus to Demon Portal that restores the power to 10, 20, 40 only for them
      * Current Enemy Hero Spell Bonuses:
        * Resurrection: Zelum:27, Puppeteer:16
       	* Berserker: Igdym Urkurshak:18, Bagud:29
       	* Hypnosis: Aha:25, Heo:15
	       * Fire Ball: Baal:27, Raab Sotten: 25
	       * Evil Book: Book of Evil:23
	       * Demonologist: Isshara, Deira Oman, Xeona, Baal, and Raab Sotten: all 100
	       * Fire Rain: Isshara:25, Deira Oman:24, Xeona:23
	       * Necromancy: Ambrosius:27, Zelberra:23, Ehno Partes:23, Ruin Guy:14, Necromancer Neirum:20, Duke Helm:10, Katana:26, General Karador:50, Egirra:7, Sir Amber:26, Kemilho:30, Tiberius:12
    * Updated spells for multiple targets based on level (see above in SPELLS.LUA for those spells affected)
    * Updated Price, Mana, and Crystals for the above changes
  * WIFES.TXT
    * Numbered all fight filters (where appropriate) so that their bonuses may be auto generated
    * Rina - added peasants, pirates, and sea dogs to her bonuses
    * Feanora - added Werewolf Elves and Werewolves to her bonuses
    * For wives with attack / defense bonuses, the bonuses are now:
      * Level 2: +4
      * Level 3: +9
      * Level 4: +16
      * Level 5: +25
  * Various baby TXT's - added cold damage resistance for those babies where applicable:
    * DIANA_BABIES.TXT - Fafner
    * FEANORA_BABIES.TXT - Bron
    * GERDA_BABIES.TXT - Ajit, Clancy, Thorgrim, Ufretin
    * ORCELYN_BABIES.TXT - Krellion, Saurug
    * RINA_BABIES.TXT - Straker
    * XEONA_BABIES.TXT - Ignatius

Version Beta 2014-06-01
-------------------------
*.ATOM
  * BEHOLDER.ATOM - +15% Magic Resistance (since classed as a mage)
  * BEHOLDER2.ATOM - +20% Magic Resistance (since classed as a mage)
  * BLACKKNIGHT.ATOM - +25% Fire Resistance (similar to horseman and knight)
  * DRUID.ATOM - +25% Poison Resistance (familiar with poisons common in nature)
  * PRIEST.ATOM
    * Poison Resistance: +15 was 0 (being holy, they have personal fortitude to resist damage common with the Undead)
    * Magic Resistance: +20 was 10
  * PRIEST2.ATOM
    * Poison Resistance: +20 was 0 (similar to Priest)
    * Magic Resistance: +25 was 10
  * SHAMAN.ATOM
    * Poison Resistance: +25 was 10 (similar to Druid poison knowledge)
    * Magic Resistance: +20 was 0
  * Undead ATOM's - receive -50% magic resistance for level 1, half that for level 2, and so on (rounding to the nearest 5% where applicable) (except ghosts, which are -100% and Necromancers who are not affected):
    * -50%
      * ARCHER.ATOM
      * SKELETON.ATOM
      * SPIDER_UNDEAD.ATOM
    * -25%
      * ZOMBIE.ATOM
      * ZOMBIE2.ATOM
    * -10%
      * BAT.ATOM
      * VAMPIRE.ATOM
    * -5%
      * BAT2.ATOM
      * BLACKKNIGHT.ATOM
      * VAMPIRE2.ATOM
*.CHAT
  * 1183480135.CHAT (Archmage Rezo)
    * Now increases your mana limit based on the number of potions you give him (note that if you have an item that increases your mana limit it may appear that you get a larger increase, but this is actually due to the bonus):
      * +1 for 1 mana potion
      * +2 for 2 mana potions
      * +7 for 5 mana potions
      * +15 for 10 mana potions
  * 1195220771.CHAT (Chief Engineer Debat)
    * Added capability to exchange runes of different types for the other
    * Exhanges rates are very favorable:
      * 2 for 1
      * 3 for 2
      * 4 for 3
  * 1594798170.CHAT (Maria) - updated snaps to add more trading options if you want to exchange 1, 2, 5, or 10 Dragonfly Wings for Magic Crystals
  * 1986778263.CHAT (Shaman Karrakh) (if you don't kill him)
    * Now increases your rage limit based on the number of potions you give him (note that if you have an item that increases your rage limit it may appear that you get a larger increase, but this is actually due to the bonus):
      * +1 for 1 rage potion
      * +2 for 2 rage potions
      * +7 for 5 rage potions
      * +15 for 10 rage potions
*.LNG
  * CHAT's - added additional dialog for changes to *.CHAT indicated above
    * EN(G)_CHAT_0013319904_1594798170.LNG (Maria)
    * EN(G)_CHAT_1067500631_1183480135.LNG (Archmage Rezo)
    * EN(G)_CHAT_1957388512_1195220771.LNG (Chief Engineer Debat)
    * EN(G)_CHAT_2079420493_1986778263.LNG (Shaman Karrakh)
  * EN(G)_SPELLS.LNG - updated Life Light description to match changes in SPELLS.LUA & SPELLS.TXT
  * EN(G)_UNITS.LNG
    * Updated race Undead description to include changes to Undead ATOM's
    * Updated race Orc to add a description about additional resistances (which they've had for a long time)
    * Updated race Dwarf to add a description about additional resistances (which they've had for a long time)
  * EN(G)_UNITS_FEATURES.LNG - updated to include ATOM changes above
*.LUA
  * ARENA.LUA
    * Added changes to int_dur function calls to include new enemy hero bonus
    * Added damage time shift parameter (technically nil) due to res_dur function input list changes (see SPELLS_POWER.LUA)
    * ***BUG FIX*** Due to issues with how I had implemented the Critical Hit / Res All bonuses from your (enemy) Hero's Attack / Defense, I've now implemented these bonuses by modificators so that the standard LUA library functions will have the correct values (before these functions would return the unmodified parameter (like res_dur, for example), which was incorrect):
      * Critical Hit from your (enemy) Hero's Attack is applied as a modificator in the arena
      * Resistance from your (enemy) Hero's Defense is applied as a modificator in the arena
    * Commented out Attack.log messages for arena location type, time of day, and spell cast AI
  * COMBAT_LOG.LUA
    * Holy Rain hint updated to include changes in SPELLS.LUA and hint fixed to be formatted properly
  * LOGIC.LUA - total hints is now 167
  * SPECIAL_ATTACKS.LUA
    * ***BUG FIX*** the Black Dragon AI did not work with the WotN Dragon Power ability so now if it it controlled by a human I use the WotN code, otherwise I use the original code for the AI
    * The way I was doing the Shaman totem initiative resulted in too high of initiative bonuses for their totems, now it is the 1/5 power of their health (before the health was divided by 2000 specified in their ATOM)
    * Updated summoning functions to apply Hero Attack / Defense bonuses changed in ARENA.LUA & TEXT_GEN.LUA
    * ***BUG FIX*** When the Griffin uses its split ability, the split troop now receives the difficulty level bonus if the parent troop had this bonus applied previously
    * New function, tal_dur, that is the talent resistance duration check function similar to res_dur. The target's resistance can now affect the talent or effect duration
    * Added tal_dur check to many unit talents (usually self cast talents are not affected by target's own resistance) to increase / decrease talent duration based on target's resistance
    * ***FIX*** function special_battle_mage_attack now properly applies the critical hit bonus (note that error is in the original game code so I inherited this bug)
  * SPECIAL_HINT.LUA
    * Updated Shaman totem hint per changes above in SPECIAL_ATTACKS.LUA
  * SPELLS.LUA
    * Added changes to int_dur function calls to include new enemy hero bonus
    * Updated all res_dur function calls to include damage time shift parameter
    * Holy Rain
      * Now resurrects targets
      * Targets include golems (Cyclops) and magic immune creatures (Black / Blue Dragons) (per the description)
      * Targets exclude special_summon_bonus (i.e. Phoenix and Evil Book) (and Demons still)
      * Heal and Undead Damage changed (see SPELLS.TXT changes)
    * Updated summoning spell functions to apply (enemY) Hero Attack / Defense bonuses changed in ARENA.LUA & TEXT_GEN.LUA
  * SPELL_EFFECTS.LUA
    * Updated all res_dur function calls to include damage time shift parameter
  * SPELLS_POWER.LUA
    * Enemy hero spell power is now increased by the difficulty level and map location bonus
    * Enemy hero infliction chance is now increased by the difficulty level and map location bonus
    * Enemy hero spell duration is now increased by the difficulty level and map location bonus
    * Function res_dur now accepts a damage time shift input to display the log text in the right sequence
  * SPIRIT_SLIME.LUA - added tal_dur to abilities whose duration is affected by the target's resistance
  * SPIRIT_THEROCK.LUA - added tal_dur to abilities whose duration is affected by the target's resistance
  * TEXT_GEN.LUA - with the changes to the (enemy) Hero Attack / Defense bonuses, these changes deal with display of the unit card
    * Function gen_unit_krit now only manually applies this bonus outside of combat
    * Function gen_unit_res now only manually applies this bonus outside of combat
  * UNIT_FEATURES.LUA
    * Added tal_dur check to many unit features, where applicable
    * Bowman cold arrow now uses common_freeze_attack for duration and common_freeze_im_vul for damage / rage gain
*.TXT
  * LOGIC.TXT - new "espell" parameter that SPELLS_POWER.LUA uses to scale enemy hero spell parameters based on difficulty level (set to same as eunit, but parameter is independent)
  * SPELLS.TXT
    * Spell power / mana / crystals rebalancing (due to the number of changes that have occured since these changes were originally made) - note that cost and level increases are changed per formula
    * Mana for level 1 has been determined by sorting the spells versus their mana cost and seeing if I'd be willing to spend more / less mana for spells higher / lower on the list
    * Dispel (spell_dispell) - mana for all levels is essentially the average of the spells it can dispell at the level
    * Helplessness (spell_defenseless) - power is now 5,10,10 (was 10,20,20) (this is to prevent maxing out power, except for only the highlest level spell casters with awesome power bonuses)
    * Stone Skin (spell_stone_skin)
      * Power is now 5,10,10 (was 10,20,20) (this is to prevent maxing out power, except for only the highlest level spell casters with awesome power bonuses)
      * Mana is now 5,8,40 was 4,7,35 (levels 2 and 3 via formula)
    * Enchanted Hero (spell_last_hero) - mana costs updated since it is the average of all the spells it can cast
    * Dragon Arrows (spell_dragon_arrow) - mana reduced from 10 to 7 for level 1 (other levels via formula)
    * Bless (spell_bless) - mana for level 1 reduced from 3 to 2 (other levels via formula)
    * Phoenix (spell_phoenix) - mana is now 20,40,80 was 15,30,60 (Phoenix has dramatically improved so these values are more representative of its power now)
    * Gift (spell_gift) - mana for level 1 is now 11 was 14 (other levels via formula)
    * Divine Armor (spell_divine_armor)
      * Power is now 3,6,9 was 5,10,15 (this is to prevent maxing out resist all, except for only the highlest level spell casters with awesome power bonuses)
      * Mana for level 1 is now 12 was 15 (other levels via formula)
    * Life Light (spell_holy_rain) - I've been wanting to add a resurrection ability to Life Light for a long time. It is, in essence, very similar to the Paladin Prayer ability in the newer KB games.
      * rephits is now 50 was 75
      * prc_damage is now 750 was 300 (matched with rephits decrease and mana increase so damage per mana is slightly higher than before)
      * Now that spell resurrects, mana for level 1 is now 15 was 10 (other levels via formula)
    * Precision (spell_accuracy) - mana for mass is now 2.5 times level 2 instead of 5 (so it assumes that only half of your troops out of 5 (the normal mass multiplier) are eligible)
    * Battle Cry (spell_reaction) - mana for level 1 reduced from 4 to 3 (other levels via formula)
    * Mana Spring (spell_mana_source) - mana for level 1 increased from 5 to 6 (other levels via formula)
    * Phantom (spell_phantom) - mana for level 1 changed from 15 to 14 (other levels via formula)
    * Pygmy (spell_pygmy)
      * Power is now 5,10,15 was 5,10,20 (this is to prevent maxing out power, except for only the highlest level spell casters with awesome power bonuses)
      * Mana for level 1 is now 15 was 10 (other levels via formula)
    * Blind (spell_blind) - mana for level 1 is now 13 was 15 (other levels via formula)
    * Hypnosis (spell_blind) - mana for level 2 and 3 has been updated to their proper values
    * Fear (spell_scare) - mana for level 1 is now 11 was 9 (other levels via formula)
    * Plague (spell_plague)
      * Power is now 5,10,15 was 5,10,20 (this is to prevent maxing out power, except for only the highlest level spell casters with awesome power bonuses)
      * Mana for level 1 is now 17 was 11 (other levels via formula)
    * Hell Breath (spell_fire_breath) - mana for level 1 is now 5 was 4 (other levels via formula)
    * Magic Shackles (spell_magic_bondage) - mana for level 1 is now 7 was 6 (other levels via formula)
    * Weakness (spell_weakness) - mana for level 1 reduced from 3 to 2 (other levels via formula)
    * Doom (spell_crue_fate) - mana for level 1 is now 9 was 8 (other levels via formula)
    * Sheep (spell_ram) - mana for level 1 reduced from 22 to 19 (other levels via formula)
    * Demon Portal (spell_demonologist) - mana for level 1 changed from 15 to 13 (other levels via formula)
    * Armageddon (spell_armageddon)
      * prc_damage is now 5,10,15 was 5,10,20 (this is to prevent maxing out damage reduction, except for only the highlest level spell casters with awesome power bonuses)
      * Mana for level 1 is now 25 was 20 (other levels via formula)


Version Beta 2014-05-11
-------------------------
*.ATOM
  * BLACKRAGON.ATOM
    * Added WotN functions to allow selection of the path of the Dragon's Power of Fire talent just like the AI uses
*.LUA
  * ITEMS_HINT.LUA
    * There's a situation when after talking to an NPC in a castle that they add a container (such as an egg, seed, etc.) and the Obj.get_param library function is unable to acquire the container parameters for displaying the container variant text. So I added code to brute force set the Obj.get_params if they are returning empty strings by setting the values to what they should be in ITEMS_MONSTER.TXT. The unfortunate part of this is that if I change something in ITEMS_MONSTER.TXT, then I have to change it here as well, but at least I've gotten around this problem now.
  * SPECIAL_ATTACKS.LUA
    * New WotN function special_blackdragon_firepower_attack for implementing the damage caused by Power of Fire (I integrated my changes of the function special_blackdragon_firepower (which is the original script attack) into the WotN function).
    * New WotN function special_blackdragon_firepower_calccells that is the new script_calccells for the Power of Fire talent (I added a text description to aid you in what to do)
    * New WotN function special_blackdragon_firepower_highlight that highlights the cells as you click your Power of Fire path (note that the original function has the same name so it has been commented out).
    * New WotN fucntion hint_dmg_blackdragon_firepower that shows the damage to targets as you layout your path of destruction when using Power of Fire
  * SPIRITS_HINT.LUA ***BUG*** - fixed error with experience computation when your spirits are level 1 for the experience hint during combat.
*.CHAT
  * 1422394811.CHAT (Carl Leonard) - Now includes extra snaps and logic for selling griffin eggs to get crystals!
  * 1348067287.CHAT (Dragon Attah) - Now includes extra snaps and logic for selling bone dragon eggs to get crystals!
  * 686733070.CHAT (Gelena Attahskaya) - Now includes extra snaps and logic for selling dragon eggs to get crystals!
  * 920168865.CHAT (Priest Owein) - Now includes extra snaps and logic for selling skeleton coffins to get crystals!
  * 1155319803.CHAT (Furious Paladin) - Now includes extra snaps and logic for selling vampire coffins to get crystals!
*.LNG
  * EN(G)_BATTLE
    * Added bmsg_firepower_1 and 2 for aiding you in selecting the Black Dragon's Talent, Power of Fire, path.
  * EN(G)_CHAT_0002578364_1422394811.LNG (Carl Leonard) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_0353666255_1348067287.LNG (Dragon Attah) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_0389231472_0686733070.LNG (Gelena Attahskaya) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_0997083665_0920168865.LNG (Priest Owein) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1920750196_1155319803.LNG (Furious Paladin) - added additional dialog for changes to *.CHAT indicated above
  * These changes are just to give you a reminder of how many of the container you need in case you forgot and you don't have enough
    * EN(G)_CHAT_0814853819_0185019267.LNG (Lady Beaulla) - added reminders for the exchange rate to dialog options when you don't have enough to trade
    * EN(G)_CHAT_1000228560_0460900476.LNG (Frogus Bogis) - added reminders for the exchange rate to dialog options when you don't have enough to trade
    * EN(G)_CHAT_1056215454_1378754138.LNG (Old Chvakah) - added reminders for the exchange rate to dialog options when you don't have enough to trade
    * EN(G)_CHAT_1107629933_0248920890.LNG (Milk Woman, Wilma) - added reminders for the exchange rate to dialog options when you don't have enough to trade
    * EN(G)_CHAT_1237766457_0111145785.LNG (Witch Helga) - added reminders for the exchange rate to dialog options when you don't have enough to trade


Version Beta 2014-05-08
-------------------------
*.ATOM
  * ARCHMAGE.ATOM - added level=4 custom param since features_shock has been updated to work with blue dragons
  * Bear ATOM's
    * Increase in hitpoints, critical hit and some resistances
    * Have a new ability: Maul that has a chance to stun and / or cause bleeding in the target
    * BEAR.ATOM
      * Health: 60 -> 80
      * Resistance:
        * Physical: 0 -> 5
	* Poison: 0 -> 5
      * Critical Hit: 20 -> 30
    * BEAR2.ATOM
      * Health: 70 -> 95
      * Resistance:
	* Poison: 0 -> 5
      * Critical Hit: 30 -> 40
    * BEAR_WHITE.ATOM
      * Health: 120 -> 190
      * Resistance:
	* Poison: 0 -> 5
      * Critical Hit: 30 -> 40
  * ARMY_BLUEDRAGON.ATOM - implents the blue dragon army map atom, based on the red dragon and Drahha army map atoms.
  * BLUEDRAGON.ATOM New Unit! Thanks to Sir Whiskers for providing brain storming ideas
    * Blue Dragons have the following abilities:
      * Move attack
        * Does half fire and half astral lightning damage that is the long2 attack like Black and Red Dragons
	* Has a 50% chance to burn and a 50% chance to shock targets
	* Damage is 60 - 70 fire and astral (total is 120 - 140)
	* Effects all creatures regardless of level
      * Can summon Dragonflies, 25 to 40% of their leadership (this idea was provided by Sir Whiskers)
      * Has a "Zap" attack that is similar to the Bone Dragon Poison cloud attack.
      * Gives morale bonus to Dragonflies
      * Discharge - 25% chance to discharge "Zap" attack when being struck
      * Aversion - other dragons dislike them, reducing the morale of those dragons.
      * For other info, see the ATOM file
  * BLUE_DRAGON_EGG01.ATOM - based on the sapfir (sapphire or blue egg that Welbewooll has you get in Ultrax) egg
    * Implements the blue dragon egg as an item that can be added to the map.
    * There may be more work to do here, but since technically it doesn't exist in the game it is probably okay.
  * BONEDRAGON.ATOM - base attack is now 50% poison and 50% physical and they have a 25% chance to cause poison when attacking / counterattacking
  * CYLCOP.ATOM - stone throw attack now does 200% damage to obstacles, barriers, and gremlin towers
  * DRYAD.ATOM - sleep now is a charge of 1 (i.e. no longer reloadable)
  * ATOM's with the Dragon Arrow ability (ARCHER, BOWMAN, ELF, ELF2) - damage is now x2 of their normal throw ability
  * Plant Summoning ATOM's - these changes will give the enemy roughly the same summoning percent on impossible and max map difficulty (so they really mostly affect your summoning)
    * DRYAD.ATOM - reduced summoning from 30-55% to 20-40%
    * ENT.ATOM - reduced summoning from 30-50% to 20-35%
    * ENT2.ATOM - reduced summoning from 35-55% to 25-40%
    * KINGTHORN.ATOM - reduced summoning from 75-95% to 50-60%
    * THORN.ATOM - reduced summoning from 80-90% to 55-65%
    * THORN_WARRIOR.ATOM - reduced summoning from 80-90% to 55-65%
  * Undead ATOM's - receive -25% health in daylight (excludes cemeteries, dungeons, and lava):
    * ARCHER.ATOM
    * BAT.ATOM
    * BAT2.ATOM
    * BLACKKNIGHT.ATOM
    * BONEDRAGON.ATOM
    * GHOST.ATOM - receive -50% health in daylight
    * GHOST2.ATOM - receive -50% health in daylight
    * NECROMANT.ATOM
    * SKELETON.ATOM
    * SPIDER_UNDEAD.ATOM
    * VAMPIRE.ATOM
    * VAMPIRE2.ATOM
    * ZOMBIE.ATOM
    * ZOMBIE2.ATOM
    * Note: even though I've listed the above atoms, the capability was done with a subturn function due to limitations of the ATOM's arena bonus section
  * Unicorn ATOM's:
    * Horn of Light now has a chance to blind enemy troops when attacking or counter-attacking (chance is doubled for beholders, demons, and the undead and duration +1 and doubled again if combat takes place in the evening or at night or undergound and another +1 duration as well)
    * Have a magic aura that either adds magic resistance to all allies (Unicorns) or subtracts magic resistance from all enemies (Black Unicorn)
    * UNICORN.ATOM
      * Blind chance is 15% (x2 vs beholders, cyclopses, demons, & undead and then x2 again for evening / night combat)
      * Magic aura is +20 magic resistance to all allies (except Unicorns and Black Unicorns)
    * UNICORN2.ATOM
      * Blind chance is 20% (x2 vs beholders, cyclopses, demons, & undead and then x2 again for evening / night combat)
      * Magic curse is -30 magic resistance to all enemies (except Unicorns and Black Unicorns)
  * This batch of changes deal with the fact that since I changed some unit abilities to be reloadable, the Gift spell is far less important. Now I've changed some reloadable skills back to charged skills so that Gift is now more desirable for long combats:
    * ALCHEMIST.ATOM (note that reload time is still enforced)
      * throw1 - moves=2
      * throw2 - moves=2
      * throw3 - moves=2
    * DRUID.ATOM (note that reload time is still enforced) - cast bear moves=2
    * ENT.ATOM (note that reload time is still enforced) - summonplant1 moves=2
*.CHAT
  * 185019267.CHAT (Lady Beaulla) - Now includes extra snaps and logic for selling ent seeds to get crystals!
  * 248920890.CHAT (Milk Woman, Wilma) - Now includes extra snaps and logic for selling thorn seeds to get crystals!
  * 460900476.CHAT (Frogus Bogis) - Now includes extra snaps and logic for selling dragonfly eggs to get crystals!
  * 1378754138.CHAT (Old Chvakha) - Now includes extra snaps and logic for selling spider eggs to get crystals!
  * 111145785.CHAT (Witch Helga) - Now includes extra snaps and logic for selling snake eggs to get crystals!
  * 1567022839.CHAT (Dragon Drahha) - Now includes extra snaps and logic for selling dragon eggs to get runes!
*.LOC:
  * Arena LOC's - most of these changes have to do with stricter enforcement of the logbits (terrain) for applying bonuses / penalties more correctly, especially with the Undead health penalty during daylight
    * ACASTLE_KARADOR.ARENA.LOC - logbits 1 (cemetery) -> 5 (cemetery & dungeon)
    * ADARION4_MAGICTOWER.ARENA.LOC - logbits 0 -> 4 (dungeon), even though this is above ground it is still considered dungeon because it is dark inside
    * ADARION_1_COAST_1.ARENA.LOC - logbits 16 (sea) -> 24 (sea & forest)
    * ADARION_1_FOREST_4.ARENA.LOC - logbits 0 -> 8 (forest)
    * ADARION_1_LAKE_1.ARENA.LOC - logbits 0 -> 8 (forest)
    * ADARION_1_LAKE_2.ARENA.LOC - logbits 0 -> 8 (forest)
    * ADARION_1_LAKE_3.ARENA.LOC - logbits 0 -> 8 (forest)
    * ADARION_2_KINGTOMB.ARENA.LOC - logbits 0 -> 5 (cemetery & dungeon), this is part of the old King's Castle in Verlon Forest and so parts of the castle apply both of these bonuses to the Undead making them very tough
    * ADARION_2_ROAD_2.ARENA.LOC - logbits 0 -> 8 (forest)
    * ADARION_3_DEADLAND_1.ARENA.LOC - logbits 1 (cemetery) -> 9 (cemetery & forest)
    * AELLINIA_BOOK.ARENA.LOC - logbits 1 (cemetery) -> 9 (cemetery & forest)
    * AELLINIA_1_COAST_1.ARENA.LOC - logbits 16 (sea) -> 24 (sea & forest)
    * AELLINIA_1_FOREST_3.ARENA.LOC - logbits 0 -> 8 (forest)
    * AELLINIA_1_FOREST_4.ARENA.LOC - logbits 0 -> 8 (forest)
    * AISLAND_1_BRIDGE_1.ARENA.LOC - logbits 16 (sea) -> 24 (sea & forest)
    * AKORDAR_DEMONROAD.ARENA.LOC - logbits 0 -> 4 (dungeon), this is the underground sea area
    * AITEM_DEMON01.ARENA.LOC - logbits 0 -> 2 (lava)
    * AITEM_DEMON02.ARENA.LOC - logbits 0 -> 2 (lava)
    * AITEM_DWARF_01.ARENA.LOC - logbits 0 -> 32 (winter)
    * AITEM_DWARF_02.ARENA.LOC - logbits 0 -> 32 (winter)
    * AITEM_ELF_01.ARENA.LOC - logbits 0 -> 8 (forest)
    * AITEM_ELF_02.ARENA.LOC - logbits 0 -> 8 (forest)
    * AITEM_UNDEAD_01.ARENA.LOC - logbits 0 -> 5 (cemetery & dungeon)
    * AITEM_UNDEAD_02.ARENA.LOC - logbits 0 -> 5 (cemetery & dungeon)
    * AUNDEAD_BLACKMOUNTAINS.ARENA.LOC - logbits 0 -> 1 (cemetery)
    * AUNDEAD_BOOK.ARENA.LOC - logbits 0 -> 9 (cemetery & forest)
    * AUNDEAD_COAST.ARENA.LOC - logbits 16 (sea) -> 25 (sea, forest, & cemetery)
    * AUNDEAD_DRAGONDUNGEON1.ARENA.LOC - logbits 4 (dungeon) -> 5 (cemetery & dungeon)
    * AUNDEAD_DRAGONDUNGEON2.ARENA.LOC - logbits 4 (dungeon) -> 5 (cemetery & dungeon)
    * AUNDEAD_ISLAND.ARENA.LOC - logbits 16 (sea) -> 17 (sea & cemetery)
    * AUNDEAD_REDMOUNTAINS.ARENA.LOC - logbits 0 -> 1 (cemetery)
    * DEADLAND_02_ARENA.ARENA.LOC - logbits 1 (cemetery) -> 9 (cemetery & forest)
  * DEMON_1_EMBRYOS.LOC (Demonis)
    * building_demon04 (Welbewooll's shop)
      * Now always sells 1 to 5 Blue Dragon Eggs
      * Now always sells 1 to 5 Blue Dragons
      * Has an additional chance to sell 5 to 10 Blue Dragons
    * army_demon (embyro_1) - now has a chance to spawn Blue Dragons in the army
    * Baal's Army - now has a chance to spawn Blue Dragons with the second variant
    * army_demon (embyro_2) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_23) - now has a chance to spawn Blue Dragons in the army
    * Xeona's Army - now has a chance to spawn Blue Dragons with the second variant
    * army_demon (embyro_42) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_46) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_51) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_52) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_63) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_64) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_67) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_74) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_75) - now has a chance to spawn Blue Dragons in the army
    * army_demon (embyro_76) - now has a chance to spawn Blue Dragons in the army
  * DEMON_ULTRAX.EMBRYOS.LOC (only affects new games)
    * army_blackdragon (embyro_1) - now has a chance to spawn Blue Dragons in the army
    * army_reddragon (embyro_12) - now has a chance to spawn Blue Dragons in the army
    * army_blackdragon (embyro_13) - now has a chance to spawn Blue Dragons in the army
  * ELLINIA_1_LABIRINT_1.EMBRYOS.LOC (only affects new games)
    * Dragon Shop:
      * Now has a 25% chance to sell Blue Dragon Eggs (2:10)
      * Now always sells 10 to 20 Blue Dragons
  * ELLINIA_1_LABIRINT_2.EMBRYOS.LOC (only affects new games)
    * (only affects new games) - ***CRASH*** fixed mispelling of "cereberus" - should be spelled cerberus (thanks to Sir_Whiskers for pointing this out!).
    * Skaar's Shop:
      * Now has a 50% chance to sell Blue Dragon Eggs (1:5)
      * Now always sells an additional either 10 to 20 Black, Blue, or Red Dragons (even chance)
    * Giant Shop:
      * Now has a 50% chance to sell Blue Dragon Eggs (2:5)
      * Chance to sell either Black or Red Dragons is now those two or Blue Dragons (same number)
    * Dragon Averr (army_greendragon (embryo_21)) now has a chance to spawn Blue Dragons in the army
    * Dragon Wirz (army_greendragon (embryo_22)) now has a chance to spawn Blue Dragons in the army
  * ELLINIA_1_LABIRINT_3.EMBRYOS.LOC
    * Dragon Shop:
      * Now has a 25% chance to sell Blue Dragon Eggs (1:5)
      * Chance to sell either Black or Red Dragons is now either Black or Blue Dragons
      * Additional chance to sell either 10 to 20 Blue or Red Dragons
      * Alternate chance is now 5 to 10 Blue Dragons (was nothing before) (the other alternate is still the same: Black, Bone, or Red Dragons)
    * Dragon Reige (army_reddragon (embryo_39)) now has a chance to spawn Blue Dragons in the army
    * Dragon Ferr (army_reddragon (embryo_5)) now has a chance to spawn Blue Dragons in the army
  * GREMLIN_CASTLE.EMBRYOS.LOC (only affects new games) - now you get one of each type of dragon (instead of 1 Bone and 2 Black)
    * Changed bonedragon_egg01 (Bone Dragon egg) -> dragon_egg01 (Green Dragon egg)
    * Changed (first) blackdragon_egg01 (Black Dragon egg) -> red_dragon_egg01 (Red Dragon egg)
    * army_blackdragon (embyro_13) - now has a chance to spawn Blue Dragons in the army
    * army_blackdragon (embyro_19) - now has a chance to spawn Blue Dragons in the army
    * army_necromant (embyro_24) - now has a chance to spawn Blue Dragons in the army
    * army_necromant (embyro_25) - now has a chance to spawn Blue Dragons in the army
    * army_goblin2 (embyro_33) - now has a chance to spawn Blue Dragons in one of the army choices
    * army_goblin2 (embyro_53) - now has a chance to spawn Blue Dragons in one of the army choices
  * KORDAR_2.EMBRYOS.LOC (only affects new games) - Raab Sotten's army now has a chance (33%) to spawn Blue Dragons in the Dragon Army choice
  * TURTLE_HEAD.EMBRYOS.LOC (only affects new games)
    * Cruel Haas's army: 100% chance of Bone Dragons is now either Blue or Bone Dragons
    * Cruel Haas's army: 100% chance of either Fire Dragonflies, Black, Bone, Green, or Red Dragons now adds Blue Dragons to the list
*.LNG
  * EN(G)_BATTLE
    * add_blog_snarl_1, 2 -> snarled changed to ensnarled
    * added add_blog_blind_ and add_block_purblind_ macros for (Black) Unicorns new ability
    * added for when the (Black) Unicorns blind and fear targets:
      * add_blog_blind_fear_ normal message
      * add_blog_purblind_fear_ +1 blind duration
      * add_blog_blind_frightened_ +1 scare duration
      * add_blog_purblind_frightened_ +1 blind and scare duration
    * added for when the Bears stun and bleed targets:
      * add_blog_stunned_bleeding_ normal message
      * add_blog_dazed_bleeding_ +1 stun duration
      * add_blog_stunned_hemoraging_ +1 bleeding duration
      * add_blog_dazed_hemoraging_ +1 stune and bleeding duration
    * added add_blog_manaburn_ for when Green Dragons mana burn your hero
  * EN(G)_CHAT_0814853819_0185019267.LNG (Lady Beaulla) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1000228560_0460900476.LNG (Frogus Bogis) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1056215454_1378754138.LNG (Old Chvakah) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1107629933_0248920890.LNG (Milk Woman, Wilma) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1237766457_0111145785.LNG (Witch Helga) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1253377691_1567022839.LNG (Dragon Drahha) - added additional dialog for changes to *.CHAT indicated above
  * EN(G)_CHAT_1315394584_0068736578.LNG (Diana) - fixed spelling errors coarse -> course
  * EN(G)_ITEMS.LNG
    * Added Blue Dragon Egg labels
  * EN(G)_SKILLS.LNG
    * Updated Tolerance skill for changes (see MORALE.TXT)
    * Updated Mega Mage skill for changes (see SKILLS.TXT)
  * EN(G)_SPELLS.LNG
    * Highlighted in red the mana_rage_gain_k effect on Magic Spring
    * Altered Ice Snake and Geyser descriptions to include changes for Fire Immune and Demon targets as noted below
    * Updated Dragon Arrow description to include changes above (see Dragon Arrow ATOM's).
  * EN(G)_SPIRITS.LNG
    * Added hint for possibility of rage or mana burn if an enemy picks up your Lina Charger
    * Highlighted in red the mana_rage_gain_k effect on Lina's Chargers and Reaper's Rage Gain
    * Added Fire Immune and Demon target description to Ice Thorns
  * EN(G)_UNITS.LNG 
    * Added Blue Dragon labels
    * Changed Black Dragons's Dragon Power description to match the changes made in UNIT_FEATURES.LUA.
  * EN(G)_UNITS_SPECIALS.LNG
    * Green Dragon Mana Source now mana burns the target troop's hero if they do not have a hero controlling them and mention that it is affected by combat duration (due to mana_rage_gain_k)
  * EN(G)_UNITS_FEATURES.LNG
    * Changed (Black) Unicorn's Horn of Light description to include blind and fear chance
    * Added new (Black) Unicorn's Magical Aura / Curse feature
    * Change Cyclop's stone_thrower to include changes made above
  * EN(G)_WIVES.LNG
    * Changed the children postambles so that the line break is leading rather than trailing
    * Added itm_kid_fire_spells, _attack_, and _defense_ spell labels to delineate spell lists better
  * EN(G)_WINDOWS.LNG
    * Added more tips
    * Fixed errors in previous tips (for example, Shamans pointed out by Sir_Whiskers)
  * TEMPLATES.LNG
    * <br> next line codes are now controlled in the childs macro instead of ITEMS_HINT.LUA (<br> are now leading instead of trailing - improves children bonus display by eliminating blank lines at the end of the bonus description)
    * Added some new color macros so that I could show the mana_rage_gain_k effect language in red, for example
    * Fixed attack and defense spell templates (i.e. Deemer)
*.LUA
  * ARENA.LUA
    * ***BUG*** Fixed issue with casting Stone Skin multiple times in a row (was due to Pentagram casts and the fact that it somehow does not register as a pawn even though it is classified as one)
    * ***BUG*** Fixed issue with enemy Priests casting Healing on their own Undead troops thereby damaging them
    * Enemy unit talents that cause damage are now effected by the difficulty level / map bonus
    * Added logic to ai_solver for enemy units to consider picking up chargers if they can so they can rage or mana burn you
    * Major revision to Spell Casting AI:
      * Fixed bugs - Geyser was not computing probability correctly (Jorko80 pointed this out a long time ago, but didn't realize it was a bug until now)
      * A lot more data is collected on the ally and enemy units to aid in spell probability computation
      * Probability computation for a spell is more pertinent to the situation for which the spell is being used
    * I had made a change previously where if an enemy (your) unit was incapcitated (i.e. sleep, unconscious, blind) that the AI would leave them alone until as long as the duration of the spell was greater than 1 turn. Sounded reasonable, however, if there was no one else to attack, the AI would keeping moving the troop back and forth until it ran out of movement even if attacking the incapacitated troop was their only option. So I've made a change where this doesn't happen any more.
    * Gremlin Towers now amplify exp / gold based on their level
    * Added chance to get more dragonfly wings if you actually fight dragonflies:
      * Chance to get wings is the sqrt( number killed )
      * Number of wings is sqrt( chance )
    * Added Blue Dragon's summondragonfly to summon logic and zap to poison_cloud and gain_mana logic
  * COMBAT_LOG.LUA
    * Implemented changes to Ice Snake (see SPELLS.LUA changes)
  * ITEMS_HINT.LUA
    * Removed the <br> "next line" codes since they are now controlled in TEMPLATES.LNG
    * Added fire_, attack_, and defense_ as variants to spell bonus templates to identify spell groups better
  * LOGIC.LUA - total hints is now 164
  * SPECIAL_ATTACKS.LUA
    * Implemented changes to talent functions to implement difficulty level bonus to enemy units when using talents
    * Green Dragon's special_gain_mana now mana burns enemy hero's if they don't have one (otherwise works same as before)
  * SPECIAL_HINT.LUA - all enemy unit talents are effected by the difficulty level bonus / map bonus, including:
    * Damage
    * Action points when running
    * Curative powers
    * Duration of effects
    * Infliction chances (i.e. burning, poison, etc.)
    * Health of summoned totems
    * Percent of summons
    * Effect power, bonuses, etc.
    * Penalties are reduced (i.e. the new Undead Health penalty is reduced by this)
    * More...
  * SPELLS.LUA
    * The (Ancient) Ent's Tree of Life ability can no longer be dispelled.
    * Freeze immune units can no longer be frozen
    * Ice Snake now ignores half of the target's physical reistance and amplifies damage based on half of the target's fire resistance if they are either Fire Immune or Demons (otherwise it is same as before)
    * Mana Spring function spell_magic_source_attack now has a new boolean input to let it know if it is being called by Enchanted Hero or not. The way I implemented Enchanted Hero is that it casts spells at the power of the time of the Enchanted Hero cast. So this meant if you cast Enchanted Hero on your troop on turn 9 and then on turn mana / rage increase dropped to 50%, it would cast Mana Spring on your troop at full power. However, if you cast Mana Spring on your troop on turn 10, then that would be at the current mana / rage gain increase. This boolean now discerns between the two situations and allows Mana Spring to be cast appropriately.
  * SPELLS_POWER.LUA
    * Made changes to function res_dur so that it can work with the Spell Casting AI in ARENA.LUA
    * ***BUG*** Fixed limits on Armageddon spell 0 to 95 is now 5 to 100 (they were set backwards - thanks to Kiras for pointing this out!)
  * SPIRIT_LINA.LUA
    * Chargers - now rage or mana burn your hero if they are picked up by enemy troops not controlled by an enemy hero. So don't let them pick up your Chargers!
    * Similar to Ice Snake, Ice Thorns now amplify damage to Fire Immune and Demons in the same way
  * TEXTGEN.LUA - fixed double dipping on the display of your Hero Resistance bonus due to their Defense during combat (i.e. if your bonus was +2% it would show as +4% in combat even though it was still just +2%)
  * UNIT_FEATURES.LUA
    * ***BUG*** Bear's Hibernation now checks to ensure that the bear is not unconscious
    * ***BUG*** Fixed broken features_stun path for Snakes / Cyclops
    * ***BUG*** Archers' Black Arrow can no longer dispel summons' "special_summon_bonus" (thanks to Kiras for pointing this out!)
    * Implemented changes to talent functions to implement difficulty level bonus to enemy units when using talents
    * Implemented features_undead_penalty function to apply Undead health penalty bonuses
    * Implemented changes to Horn of Light
    * Added magic aura / curse Unicorn functions
    * Added check on a lot of the functions to ensure that the stack is not killed when applying a feature
    * Soul draining and Vampirism are only 50% effective during daylight (morning and afternoon, and are not affected if combat is in a cemetery, lava, or underground)
    * Implemented Undead health penalty function for daylight (and not cemetery, lava, or dungeon)
    * Added boolean to the call for spell_magic_source_attack per changes above to correctly cast Mana Spring from Enchanted Hero.
    * Black Dragon's now is -2 initiative to level 1 and 2 troops (and remains -1 initiative to level 3 and 4 troops)
*.TXT
  * BABY TXT's - Ugg! All these errors deal with a typo copied from place to place nerco -> necro! Doh! Thanks Windows 8.1!
    * DIANA_BABIES.TXT
      * ***BUG*** 3 errors! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * FEANORA_BABIES.TXT
      * ***BUG*** 7 errors! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * GERDA_BABIES.TXT
      * ***BUG*** 1 error! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * MIRABELLA_BABIES.TXT
      * ***BUG*** 10 errors! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * NEOKA_BABIES.TXT
      * ***BUG*** 18 errors! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * ORCELYN_BABIES.TXT
      * ***BUG*** 7 errors! Fixed typo nerco -> necro (for necromant ATOM reference)
      * Added bonuses for blue dragons where applicable
    * RINA_BABIES.TXT
      * ***BUG*** 15 errors!
        * Fixed typo nerco -> necro (for necromant ATOM reference)
        * Fixed typo sp_lead_unit_nercomant -> sp_lead_unit_necromant (which means previously that Necromancer Leadership Reduction was not working!)
      * Added bonuses for blue dragons where applicable
    * XEONA_BABIES.TXT
      * ***BUG*** 9 errors! Fixed typo sp_lead_unit_nercomant -> sp_lead_unit_necromant (which means previously that Necromancer Leadership Reduction was not working!)
      * ***BUG*** Changed Deemer's Rage Increase from +40% -> +20%
      * Changed Deemer's Attack / Spell bonus from +10% -> +5%
      * Added bonuses for blue dragons where applicable
  * ITEMS.TXT
    * Added bluedragons to items that would affect them
  * ITEMS_MONSTER.TXT
    * Added new container - Blue Dragon Eggs!
    * Made unit range consistent with leadership for all variants:
      * snake: 1-3 -> 2-4, snake_green: 1-3 -> 2-4
      * vampire: 1-3 -> 2-4
  * MORALE.TXT
    * -2 Morale (was -1) from Robber's negated by Tolerance level 2
    * -2 Morale from Giants to Green Dragons negated by Tolerance level 3
    * +1 Morale from Green Dragons to Giants negated by Tolerance level 3 (I guess they are no longer as happy since they can't eat 'em)
    * Blue Dragons:
      * -2 Morale to Green & Red Dragons negated by Tolerance level 3
      * -1 Morale to Black Dragons negated by Tolerance level 2
      * +2 Morale to Fire / Lake Dragonflies
  * PARAMS.TXT
    * In order to get the dragonfly wings to show up in the combat screen I added a dummy parameter, dfly_wng, so that you'd at least see its picture when you were awarded dragonfly wings. I tried to show the number that you get, but it somehow doesn't format on the screen properly. So I just show the wings picture and you'll have to check your inventory to see how many you got for now...
  * SKILLS.TXT
    * Evil Book now gets Mega Mage bonuses
    * Tolerance now removes penalties for other units (i.e. Robbers, Green Dragons / Giants, etc.)

Version Beta 2014-01-28
-------------------------
*.LNG
  * EN(G)_WINDOWS.LNG
    * Corrected a few errors in the original tips
    * Removed duplicate hint #44
*.LUA
  * Fixed issues with not converting act_spell_param outputs to numbers:
    * BOSS.LUA - dmg_min and dmg_max for effect_spider_poison_attack may have been strings instead of numbers, although since this was in the original game it may not have been a problem
    * SPELLS.LUA - level for post_spell_plague may have been a string, although not sure if this was a problem
    * UNIT_FEATURES.LUA - this one was a problem and was causing Mana Spring cast from Enchanted Hero to give your hero mana instead of the enemy hero - belligerent check from spell parameter needed to be converted to a number
  * LOGIC.LUA - the new mod hints I added were not being used because it seems like the hint counting did not work so I manually set it to the maximum number of hints that are in EN(G)_WINDOWS.LNG so that it would show my new hints


Version Beta 2014-01-01
-------------------------
*.ATOM
  * CANNONER.ATOM
    * Triple shot: Added Fatt_Shade's idea for damage to surrounding troops, although I added friendly damage.
    * Normal shot: now does 50% damage to surrounding troops (friendly fire)
    * All shots have no range limit and no penalty
    * Added camera shake to both attacks! :-)
  * Spirit ATOMS: (DEATH, LINA, SLIME, THEROCK) - simplified upgrade criteria
    * DEATH.ATOM - removed 1 rest reduction level from time back and black hole and replaced with 1 rage reduction level
    * LINA.ATOM
      * Removed 1 rest reduction level from gizmo and replaced with 1 rage reduction level
      * Orb:
        * Now causes damage when cast upon landing via a quake similar to the Giant ability and the damage reduction per hex away from the landing point decreases with increasing attack level
	* Attack and Defense upgrades now only increase attack and defense capability (before there was a slight increase to the opposite statistic)
	* Roll damage per hex now increases with increasing attack level
	* Knocks the target back 1 cell if possible
      * Added always hint flag for orb and devatron to show the damage hint
    * SLIME.ATOM
      * Dramatically improved Poison Cloud:
        * Does immediate damage to the targets plus the damage by the cloud later
	* Has the specified chance to poison the targets (note that higher levels can "super" poison the targets due to its high and repetitive damage)
      * Evil Shoal:
        * Now has a chance to cause fear in the target (normal fear immunities apply)
	* Now shows the damage hint!
      * Swamp Poison now has the duration specified
    * THEROCK.ATOM - lump, rockfall, and quake now all have their duration specified
  * DEVATRON_THROW.ATOM - improved the damage animation
  * DRUID.ATOM - new ability: Revive Beast (2 charges) - resurrects beasts (i.e. bears, wolves, etc.)
  * ENT & ENT2.ATOM - added movetype custom parameter to moveattack to include movement type = -2 (Ghosts and Cursed Ghosts)
  * GIANT.ATOM - quake now does 200% damage to structures (obstacles, barriers, and towers)
  * KINGTHORN.ATOM - included movement type = -2 (Ghosts and Cursed Ghosts) in the movetype entangle custom parameter
  * ORB.ATOM - added ground shake particles for shaking the ground when the Ice Ball lands per the changes to Ice Ball above
  * SLIMEFOG.ATOM - the fog damage is no longer affected by the attack of the cloud / defense of the target
*.LNG
  * EN(G)_BATTLE.LNG
    * Added new log for showing the recharge enemy attacks message.
    * Added "fightened" log for when Evil Shoal causes fear and the unit already has it, it will add +1 to the duration of current
  * EN(G)_ITEMS.LNG - fixed Carl Leonar -> Carl Leonard
  * EN(G)_SPIRITS.LNG
    * Added changes to descriptions and level ups based on all the atom and other features added
  * EN(G)_UNITS_SPECIALS.LNG 
    * Updated Cannoneer Salvo to include half damage to surrounding troops, friend or foe.
    * Update Giant Quake to include 200% damage to structures
    * Added new druid Beast Revive name, header, and hint
    * Added warning_revive for new Druid ability
  * EN(G)_UNITS_FEATURES.LNG
    * Added separate Siege Gun header / hint for Cannoners per their update
    * Added Knockback header / hint
  * EN(G)_WINDOWS.LNG
    * Updated version number
    * Added many new screen tips to show new features of the mod
  * TEMPLATES.LNG
    * Updated spirit templates to accommodate changes in ATOMs
    * Fixed Feanora template Werewolves -> Graywolves
*.LUA
  * ARENA.LUA
    * Fixed issue with improperly using the wrong spell level if the enemy hero's spells happened to be higher than I thought
    * Set min_score to 0 so that all spells have a chance to cast. I originally put this in to prevent spells with very low probabilities from being cast, but it seems like there could be quite a few lower level enemy heroes with really low scores and so they'd end up skipping turns not casting spells.
    * Critical Hit difficulty level bonus is now additive since a lot of unit's Critical Hit is really low. So now enemies will "krit" a lot more often on harder difficulty levels...
  * COMBAT_LOG.LUA
    * Added damage hint for Rage Skills:
      * Poison Cloud
      * Ice Ball (see above)
      * Evil Shoal
      * Ice Thorns
  * ITEMS_HINT.LUA - fixed issue with text description for wives having their first child
  * SPECIAL_ATTACKS - added change to Giant's Quake damage to structures as identified above
  * SPELL_COMMON.LUA
    * Calccells for Royal Thorn's Entangle now checks for a comma-delimited list of movement types (this is to include Ghosts / Cursed Ghosts) - Thanks to jorko80 for pointing this out!
    * Function common_cell_apply_damage can now return the dead from act_damage
  * SPIRIT_LINA.LUA
    * Ice Thorns now:
      * Uses common_freeze_attack to be consistent with Geyser and Ice Serpent - Thanks to jork80 for pointing this out!
      * Uses its duration (was using a constant of 3, but had created variable duration in the past)
      * Affects the Undead (not sure why I had it this way before)
      * Improved the damage animation
    * Ice Ball now:
      * Damages enemies like the Giant's quake upon casting
      * Has variable roll damage increase
      * Knocks targets back 1 cell if possible
  * SPIRIT_SLIME.LUA
    * Implemented changes as specified in the ATOM changes above
    * Implemented changes to show the damage of Evil Shoal
  * SPIRIT_THEROCK.LUA - implemented changes as specified in the ATOM changes above
  * TEXTGEN.LUA - added new function for generating the Ice Ball's roll damage for its feature hint
  * UNIT_FEATURES.LUA
    * features_entangle (Entangle) now also checks for a comma-delimited list of movement types (this is to include Ghosts / Cursed Ghosts) - Thanks to jorko80 for pointing this out!
    * Re-ordered features_entangle boolean logic checks to optimize logic for speed / efficiency
    * Fixed error with special_priest where the holy effect was being shown when moving the cursor over enemies
*.TXT
  * LOGIC.TXT - added new parameter, rndrecharge, for determining when enemy attacks are automatically recharged based on difficulty level.
  * SPELLS.TXT - Ice Snake is now an Order spell

Version: Beta 2013-06-02
-------------------------
*.TXT
  * ITEMS_MONSTER.TXT - forgot to fix the Bone Dragon 1 unit per 2 egg issue - now this is fixed!


Version: Beta 2013-05-26
-------------------------
*.CHAT
  * 79826769.chat - fixed Orcelyn's chat dialogue for when she initiates conversation to have a child (thanks to Nevar for pointing this out!)
  * 68736578.chat - fixed Diana's chat dialogue for when she initiates conversation to have a child (thanks to Nevar for pointing this out!)
*.LNG
  * EN(G)_CHAT_1379826769_0079826769.LNG - updated Orcelyn's dialogue such that the proper question and answer appear when she initiates the conversation to have a child as well as fixed duplicate answer on your response that was causing her to have a child in only 5 turns (thanks to Nevar for pointing this out!)
  * EN(G)_CHAT_1315394584_0068736578.LNG - updated Diana's dialogue such that the proper question and answer appear when she initiates the conversation to have a child as well as fixed duplicate answer on your response that was causing her to have a child in only 5 turns (thanks to Nevar for pointing this out!)
*.LUA
  * ITEMS_HINT_LUA - fixed wife baby macro so that it only shows the victories until next baby when sex == "1". When your wife initiates the conversation and you say "no", sex is set to "2" and I was checking before for it ~= "0", which is what it is if you don't ask for a child (thanks to Nevar for pointing out the problem above as it helped me fix this, too!)


Version: Beta 2013-05-18
-------------------------
*.ATOM
  * SLIME.ATOM
    * Lowered the level requirements for Poisonous Spit levels 5-7 to be 8, 11, and 14 was (9, 15, and 19)
    * Increased the level requirements for Poisonous Spit Poison levels 1-2 to be 9 and 16 (was 6 and 12)
    * Increased the level requirements for EVil Shoal levels 4-7 to be 9, 12, 15, and 20 (were 7, 10, 14, and 19)
    * Lowered the level requirements for Poison Cloud levels 3-5 to be 8, 14, and 22 (were 11, 16, and 24)
  * THE_ROCK.ATOM
    * Added level requirements for Wall levels 4-5 to be 10 and 16 (no level requirements before)
*.LNG
  ENG_ITEMS.LNG - updated description for Griffin and Dragon Eggs so that they are now just like the other containers (and have a range)
*.LUA
  * ARENA.LUA
    * Fixed error with Shroud spell that was causing a crash when cast by heroes such as Martin Vodash and Dirty Butory (thanks to Jorko80 and Sir Whiskers for pointing this out!)
    * Added AI spell function for Shroud so that it selects the optimal location to cast (was using the generic bonus spell code before, which is where the above error was as well)
    * Changed score for AI damage spells to include number of kills so that the AI focuses more on killing your units
  * ITEM_USE.LUA
    * Updated objuse_spawn_troop so that it loops through the troop ranges for each container used (this provides better variability for containers)
*.TXT
  * ITEMS_MONSTER.TXT
    * Fixed Griffin and Dragon Eggs so that it is no longer 2 eggs per unit (thanks to Sir Whiskers for pointing this out!)
    * Griffin and Dragon Eggs now just have a range of 1-2 and due to the change in objuse_spawn_troop above, it will give an average of 1.5 units per egg.
    

Version: Beta 2013-03-18
-------------------------
*.ATOM
  * ORC.ATOM - Ill-tempered now works only 50% of the time
  * ORC2.ATOM - Ill-tempered now works only 50% of the time
*.LNG
  * EN(G)_UNITS_FEATURES.LNG - changed Ill-tempered description to indicate that it works 50% of the time
*.LUA
  * ARENA.LUA
    * Added check for spell when they are being mass cast to reduce the AI spamming the same mass spells repeatedly
  * LOGIC_HERO.LUA - slight tweak to Paladin rune level-ups: now 12, 21, 12 (26.7%, 46.6%, 26.7%) for Might, Mind, and Magic runs (was 11, 23, 11)
  * SPELLS.LUA
    * Dispel still wasn't working properly if the unit had Enchanted Hero cast on it - now I think I've fixed it for good
    * For Summon Spells (i.e. Phoenix and Evil Book, Resistance increase is Percent Base instead of Absolute). This lowers their overall resistance since they are now getting significant bonuses from Defense and possibly the Tolerance Skill and for Phoenix especially it was too easy to get 95% resist all across the board with items to help.
  * UNIT_FEATURES.LUA
    * Fixed features_giant_attack such that it ensures the receiving unit did not get killed before it implements its effect
    * Fixed features_ogre_attack such that it ensures the receiving unit did not get killed before it implements its effect
    * Fixed features_bonedragon_attack such that it ensures the receiving unit did not get killed before it implements its effect
    * Fixed features_archdemon_attack such that it ensures the receiving unit did not get killed before it implements its effect
    * Fixed features_entangle such that it ensures the receiving unit did not get killed before it implements its effect
    * Changed Enchanted Hero Dispel call so that hopefully it now works properly...
    * Orc Ill-tempered now works only 50% of the time
    * Fixed orc_posthitslave to check for angry ~= nil (thanks Windows 8!)
    * Fixed features_ogre_attack to check for receiver_level ~= nil
    * Fixed features_archdemon_attack to check for receiver_level ~= nil
    * Fixed features_bonedragon_attack to check for receiver_level ~= nil
    * Fixed features_dissipate_energy to check for titan_energy ~= nil


Version: Beta 2013-03-03
-------------------------
*.ATOM
  * DEATH.ATOM
    * Fixed errors in rest level increases that prevented it from being selected during levelup
  * LINA.ATOM
    * Fixed errors in rest level increases that prevented it from being selected during levelup
  * SLIME.ATOM
    * Fixed errors in rest level increases that prevented it from being selected during levelup
    * Fixed errors in Cloud of Poison time level increases that prevented it from being selected during levelup
  * THEROCK.ATOM
    * Fixed errors in rest level increases that prevented it from being selected during levelup
    * Fixed errors in Stone Wall time level increases that prevented it from being selected during levelup
*.LNG
  * EN(G)_SPELLS.LNG
    * Mention that Holy Rain, Plague, and Armageddon can affect Magic Immune creatures.
*.LUA
  * SPELLS.LUA
    * When I had added check for belligerent when Dispel was being auto cast by Enchanted Hero, I introduced a bug where normal Dispel was no longer working properly (i.e. level 3 Dispell was removing Penalty spells from enemies, not Bonus spells). I've now (hopefully) fixed the problem where both normal Dispel cast and Enchanted Hero auto cast Dispel work properly
  * UNIT_FEATURES.LUA
    * Added flag to receiver of Enchanted Hero Dispel auto cast such that spell_dispell_attack still works with Enchanted Hero
*.TXT
  * ARENA.TXT - had one too many spirit levels, now highest level is 51 @1,000,000 spirit experience


Version: Beta 2013-02-24
-------------------------
*.ATOM
  * DEATH.ATOM
    * Doubled experience for using Time Back since it does not get any damage bonus for experience gain
    * Improved rest pacing for Soul Draining and added new rest level
    * Improved rest pacing for Rage Draining and added new rest level
    * Improved rest pacing for Time Back and added new rest level
    * Improved rest pacing for Black Hole and added new rest level
  * DEVATRON.ATOM - these changes most likely don't really change anything, but I feel are proper for the thorns
    * Now are Fire, Poison, and Freeze Immnune
    * Resistances:
      * Physical: 100% (95)
      * Poison: 100% (95)
      * Magic: 0% (no change)
      * Fire: -100%
  * LINA.ATOM
    * Doubled experience for using Chargers, Ice Orb, and Gizmo since they do not get any damage bonus for experience gain
    * Improved rest pacing for Chargers
    * Improved rest pacing for Ice Orb and added new rest level
    * Improved rest pacing for Ice Thorns and added new rest level
    * Improved rest pacing for Gizmo and added two new rest levels
  * SLIME.ATOM
    * Doubled experience for using Cloud of Poison and Glot's Armor since they do not get any damage bonus for experience gain
    * Improved rest pacing for Evil Shoal and added new rest level
    * Improved rest pacing for Cloud of Posion and added new rest level
    * Improved rest pacing for Glot's Armor and added two new rest levels
  * THEROCK.ATOM
    * Doubled experience for using Stone Wall since it does not get any damage bonus for experience gain
    * Improved rest pacing of Stone Wall and added new rest level
    * Improved rest pacing of Rockfall and added new rest level
    * Improved rest pacing of Underground Blades and added two new rest levels
*.LNG
  * EN(G)_SPIRITS.LNG - added new spirit ability rest levels
*.LUA
  * ARENA.LUA
    * Fixed error with computing of enemy hero attack / defense could be less than 0
    * Fixed error with Arena Spells check for Demon / Dragon Slayer (thanks Windows 8!)
*.TXT
  * ARENA.TXT - spirit levels now go to level 51 (only 50 is attainable, since level 51 requires 1,000,000 experience)


Version: Beta 2013-02-10.1 - I forgot to include DEVATRON.ATOM in 2013-02-10
-------------------------

Version: Beta 2013-02-10 - CRITICAL UPDATE
-------------------------
*.ATOM
  * DEVATRON.ATOM - reverted to previous version until I figure out how to make it prevent ranged troops from attacking when adjacent to it
  * DRYAD.ATOM
    * Fixed issue with not properly implementing the Arena bonuses / penalties (i.e. +50% Attack in Forest Environments / -1 Morale in Dungeons)
  * EVILBOOK1.ATOM - Physical Resistance changed from 5 -> 2
  * EVILBOOK2.ATOM - Physical Resistance changed from 10 -> 5
  * EVILBOOK3.ATOM - Physical Resistance changed from 15 -> 10
  * PHOENIX_YOUNG.ATOM
    * Physical Resistance changed from 10 -> 5
    * Poison Resistance changed from 5 -> 2
  * PHOENIX.ATOM
    * Physical Resistance changed from 15 -> 10
    * Poison Resistance changed from 10 -> 5
  * PHOENIX_OLD.ATOM
    * Physical Resistance changed from 20 -> 15
    * Poison Resistance changed from 15 -> 10
  * Spirit ATOM's:
    * Added killedunitexp flag to help with showing combat experience during battles
*.LNG
  * EN(G)_CHAT_0170292983_0979371428.LNG - fixed minor grammar error
  * EN(G)_SPIRITS.LNG
    * Added exp macro to end of spirit ability descriptions to show experience
    * Showing experience is very experimental as it doesn't quite seem to follow the formula in the fan manual
  * EN(G)_WIVES.LNG - added baby macro to end of wives for showing victories to next birth
  * TEMPLATES.LNG
    * Added new baby template for wives to show number of victories until next birth
    * Added new exp template for spirit ability experience
*.LOC
  * ELLINIA_2_EMBRYOS.LOC (Great Forest)
    * ***CRASH*** Neoka's Castle: Fixed bug with "druids" in item list after marrying Neoka
    * If you started a new game with 2013-01-27 you'll need to use the fix identified below
      * If you are playing a game and it crashes after marrying Neoka, you have to make a copy of DRUID.ATOM and call it DRUIDS.ATOM and place it in your mods folder.
      * Don't buy the "DRUIDS.ATOM" units (their picture will be blank), it is just to allow you to continue your game if you want to marry Neoka
*.LUA
  * ARENA.LUA
    * Fixed error of your unit Critical Hit not being affected by Morale changed during long combats (thanks to Gza for pointing this out!)
    * Added global flag to aid in showing of spirit experience
    * Added additional criteria for Spells to ensure that they are not repeatedly cast on the same unit(s)
  * ITEM_HINT.LUA
    * Added capability to display number of wins before your wife's next baby
  * ITEM_USE.LUA
    * Updated "objuse_spawn_troop" to use different code than the built-in code to randomize the units per the percentages listed
  * SPELLS.LUA
    * Fixed error where Battle Cry was not affecting your unit's Critical Hit positively
    * Fixed weird error with Plague trying to infect disappearing pawns (I think it was related to fire killing a unit, with fire being the pawn) (thanks Windows 8!)
    * Fixed possible nil value for tgt in spell_holy_rain_attack (thanks Windows 8!)
    * Fixed possibility of nil value for target in spell_accuracy_attack (thanks Windows 8!)
    * Added check for belligerent when checking ally for spell_dispell_attack so that it works with Enchanted Hero
  * SPIRITS_COMMON.LUA
    * Added global flag to aid in showing of spirit experience
  * SPIRITS_HINT.LUA
    * Added functions based on CW's EXP_PET_HINT.LUA to aid in showing the spirit experience hint
  * SPIRIT_THEROCK.LUA
    * ***BUG*** Fixed sequence of damage timeshift (thanks Windows 8!)
  * TEXT_GEN.LUA
    * Fixed error with display of your unit's Critical Hit using hero's Defense instead of Attack for bonus
  * UNIT_FEATURES.LUA
    * Fixed error with Bone Dragon's Dread not dropping your unit's Critical Hit due to the Morale decrease
    * Fixed error with Regenerates Mana where it sometimes gave mana to your hero when damaging enemy mages (i.e. with spirit abilities)
    * Fixed error with string belligerent for special_bonus_spell for Enchanted Hero
    * Fixed error with misspelled "spell_dispell_attack" function name for special_bonus_spell for Enchanted Hero
*.TXT
  * GERDA_BABIES.TXT - fixed missing count on sp_duration_stone_skin for Labetha (thanks Windows 8!)
  * NEOKA_BABIES.TXT - fixed missing count on sp_duration_ice_serpent for Alagar (thanks Windows 8!)
  * RINA_BABIES.TXT - fixed missing count on sp_duration_stone_skin for Xsi (thanks Windows 8!)


Version: Beta 2013-01-27 - CRITICAL UPDATE
*.LOC
  * ISLAND_1_EMBRYOS.LOC (Western Islands) - ***CRASH TO DESKTOP*** fixed error of Griffin Eggs improperly implemented (thanks to Sir Whiskers for pointing this out!)
  * KORDAR_2.EMRYOS.LOC (Kordar)
    * Now has a 50% chance to sell Skeleton Graves (30:60)
    * Now has a 25% chance to sell Vampire Coffins (10:25)
*.LUA
  * SPECIAL_ATTACKS.LUA
    * ***BUG*** Fixed duration being string in special_bless_attack (thanks Windows 8!)


Version: Beta 2013-01-26
-------------------------
*.ATOM
  * ALCHEMIST.ATOM
    * Holy Water charges changed to a reload of 3
    * Fire Potion Charges changed to a reload of 4
    * Poison Potion Charges changed to a reload of 5
  * DEATH.ATOM - Rage Gain set to display a damage hint
  * Demon ATOM's: ARCHDEMON, CERBERUS, DEMON, DEMONESS, IMP, IMP2, SPIDER_FIRE
    * Now generate twice as much rage when attacking / defending
  * DEVATRON.ATOM - set the isenemy flag to true such that ranged units cannot use their ranged ability when adjacent to an Ice Thorn
  * EVILBOOK ATOM's: EVILBOOK1 - 3
    * Now are Mages (and subject to Zerock's Attacks)
    * Have the feature other mages have (denoted below) to convert damage to mana
  * ENT.ATOM
    * Added "special" animation for Summon Plant
    * Added sound for "special" animation
    * Added particle for "special" animation
  * GOBLIN2.ATOM - Throw Axe now reloads every 3 rounds
  * Mage ATOM's: ARCHMAGE, BEHOLDER, BEHOLDER2, NECROMANT, PRIEST, PRIEST2, SHAMAN
    * Now have a feature that has a chance of converting damage into mana for their hero
    * The chance is related to the total leadership of the stack
  * Orc ATOM's: CATAPULT, GOBLIN, GOBLIN2, OGRE, ORC, ORC2, SHAMAN
    * Now generate 1.5 times as much rage when attacking / defending
  * ROBBER.ATOM - removed from mod and returned to default (the only change here was them having 8 charges on their longattack)
  * ROBBER2.ATOM - removed from mod and returned to default (the only change here was them having 8 charges on their longattack)
  * SLIME.ATOM
    * rage1 now has a level 4 requirement (was 3) and a spirit level requirement of 9 (didn't have one before)
    * rage2 now has a level 6 requirement (was 5) and a spirit level requirement of 14 (didn't have one before)
  * SPIDER_FIRE.ATOM - Added the missing demon feature
  * THEROCK.ATOM - Added level requirements to Wall TTL upgrades since it was possible to be offered it without even having the ability
*.CHAT
  * 1594798170.CHAT - Maria now exchanges 1 dragonfly wing for 3 crystals
*.DAT
  * ITEXTURES.DAT - added include for tex338.dat
  * TEX338.DAT - new DDS data file for the new Tolerance Skill pictures
* TEX338.DDS - new pictures for the Tolerance Skill (Level 0 and 1, Levels 2 and 3 are the same)
*.LNG
  * EN(G)_ACTORS.LNG - Changed Carl Leonar to Leonard
  * EN(G)_BATTLE.LNG - added Totem Dispel log label
  * EN(G)_CHAT_0013319904_1594798170.LNG - Maria now exchanges 1 dragonfly wing for 3 crystals
  * EN(G)_ITEMS.LNG - added [egg] macro for generating container unit possibilities for certain containers (i.e. eggs, seeds, etc.)
  * EN(G)_ITEMS_BASE - added new labels for the egg macro for container hints
  * EN(G)_SKILLS.LNG - added Tolerance Level 3
  * EN(G)_SPELLS.LNG
    * Clarified Entangle Critical Hit verbiage
    * Added description to Freeze about Shock chance doubling
    * Added description to stun and blind about double chance of being struck critically
  * EN(G)_UNITS.LNG
    * Death Totem now also randomly removes 1 bonus spell from each target
    * Life Totem now also randomly removes 1 penalty spell from each target
    * Updated Orcs and Demons to include Rage bonuses.
    * Added Critical Hit labels and macro
    * Added Level to the end of the Evil Book unit names
    * Added new Elf / Dwarf Tolerance label
  * EN(G)_UNITS_FEATURES.LNG
    * Updated Soul Drain description to include units not affected by it
    * Added new regenerates_mana header and hint
    * Changed description of Team Spirit to include changes listed below
    * Updated holy_attack_header to include changes listed below
  * EN(G)_UNITS_SPECIALS.LNG
    * Web now also doubles the chance of the target being struck critically
    * Death Totem now also randomly removes 1 bonus spell from each target
    * Life Totem now also randomly removes 1 penalty spell from each target
  * TEMPLATES.LNG
    * Added "egg" macro to generate the unit possibility hints
    * Changed "allmages1" macro to include Beholders, Evil Beholders, and Evil Books since they are Mages (Beholders were given the mage feature a while back)
    * Fixed group macros to use the proper bonuses since they were wrong
    * Added Critical Hit macro definition
    * Added dragonfly_wings macro to show number of Dragon Fly Wings when selling them to Maria
*.LUA
  * ARENA.LUA
    * Targets with blind, unconscious, or sleep have their can_attack flag set to false if the duration left is greater than 1
    * Web:
      * The criteria for the AI deciding to web a unit is now:
        * Cannot be webbed, entangled, sleeping, unconscious, blinded, or rooted
	* The ratio of the target's speed to the webber's speed
	* The ratio of the target's power to the webber's power
    * Entangle - AI now considers targets viable if they can attack an ally, not just the caster
    * Rooted:
      * AI now just considers whether the caster needs healing or resurrection as entry criteria
      * Probability is now 5 times higher if the caster is burning
    * Units that have been webbed now have twice the chance of being struck critically
    * Units that have been blinded now have twice the chance of being struck critically
    * Units that have been stunned now have twice the chance of being struck critically
    * Furious Goblin's Throw Axe ability AI improved
    * Spell AI
      * If a pawn is a valid target then its score is 1/10 (Gremlin Towers liked to target Ice Thorns with Fire Ball / Rain)
      * Targets with blind, unconscious, or sleep have their can_attack_units flag set to false if the duration left is greater than 1
    * ***BUG*** Fixed error with Frenzy giving too much of an Attack bonus after killing enemy troop
    * ***BUG*** Fixed error with Towers and "book_times" (thanks Windows 8!)
  * COMBAT_LOG.LUA
    * If you have a split stack, Gift of Life now correctly displays the correct hint for whether or not your stack will cause you to go over your Hero's Leadership
    * Rage Gain now shows the damage tooltip
  * ITEMS_HINT.LUA
    * Added new "gen_egg_param" function to list the probability and variants of units coming out of certain containers
    * Fixed unit bonus generators to properly compute the unit group bonus macros
    * Scholar is now sp_power_inc / den_scholar
  * ITEM_USE.LUA
    * Updated "objuse_spawn_troop" to handle an alternate set of units to produce from the object (see ITEMS_MONSTER.TXT)
  * LOGIC_HERO.LUA
    * Removed Leadership Reduction Limit code since you can't clamp leadership limit bonuses
    * Tweak to Paladin's Rune Level-ups: Now 24.4, 51.2, and 24.4% Might, Mind, and Magic Rune split
    * Tweak to Mage's Rune Level-ups: Now 13.3, 26.7, and 60% Might, Mind, and Magic Rune split
  * PAWN.LUA
    * Death Totem now removes 1 random bonus spell from each enemy target in the radius
    * Life Totem now removes 1 random penalty spell from each ally target in the radius
  * SKILLS.LUA
    * Explorer now also increases the Hero's Search Radius
    * Added check to skill_power to set param to 1 if the input value is nil
  * SPECIAL_ATTACKS.LUA
    * Improved Ent Summon Plant animation for when Ents are summoned
  * SPELLS.LUA
    * Mass spells now have a random time shift for the mass effect
    * If a unit is frozen, then their chance of shock doubles
    * The intellegence spell power bonuses (int_pwr and sp_power_int) are now multiplicative of total intelligence bonus not simply intelligence (i.e. instead of ( 1 + int * bonuses ) it is ( 1 + int / 100 ) * bonuses. This is so that if you have, for example, 28 intellect then you get +40% intellect power or ( 1 + int / 100  ) * 1.4 rather than a 40% increase in intellect ( 1 + int * 1.4 / 100 ) like how I had it implemented before in which the 40% bonus did not equate to +40% power bonus like the intellect description states.
    * ***BUG*** Fixed bug with spells that were determining if the caster was human or computer (thanks Windows 8!)
  * SPELLS_COMMON.LUA
    * ***BUG*** Added check for corpse_cell not nil to calccells_all_phoenix_sacrifice (thanks Windows 8!)
    * ***BUG*** Fixed error with Towers and the Necromancy Spell using calccells_all_corpse2 (thanks Windows 8!)
  * SPELLS_EFFECTS.LUA
    * Bless / Weakness now have a random time shift
    * ***BUG*** Added check for nil target in apply_hero_duration_bonus (thanks Windows 8!)
    * ***BUG*** Fixed error with " defense" in effect_holy_attack (thanks Windows 8!)
  * SPELLS_POWER.LUA
    * Fixed "holy" bonus to be "sp_holy" to prevent conflict with "holy" affliction chance
    * The sp_power_inc bonus is now divided by den_scholar
    * ***BUG*** Added check to ensure targets are not nil in res_dur (thanks Windows 8!)
    * See the change to intelligence spell power bonuses in SPELLS.LUA
  * SPIRIT_LINA.LUA
    * Updated Gizmo AI to be a merging of H3B and H3T logic
    * Improved Ice Thorns animation sequence of displaying damage numbers
  * TEXTGEN.LUA
    * Fixed "int_power" calculation to accurately calculate the bonus with item bonuses
    * The total Scholar spell power increase is now sp_power_inc / den_scholar
    * Added new gen_unit_krit function to generate the unit's Critical Hit chance
  * UNIT_FEATURES.LUA
    * The Ghost / Cursed Ghost Soul Drain ability no longer works on Holy units
    * If a unit is frozen, then their chance of shock doubles
    * Fixed Orc's Ill-Tempered from executing when the Orc troop is killed
    * ***BUG*** Added check for sleep not nil to features_giant_attack (thanks Windows 8!)
    * ***BUG*** Added check for stun not nil to features_ogre_attack (thanks Windows 8!)
    * ***BUG*** Added check for chance not nil to features_bonedragon_attack (thanks Windows 8!)
    * ***BUG*** Added check for entangle not nil to features_entangle (thanks Windows 8!)
    * ***BUG*** Fixed issues with post_spell_last_hero not returning damage and addrage properly (thanks Windows 8!)
    * ***BUG*** Fixed issues with possibility of nil parameters when getting custom parameters (thanks Windows 8!)
    * Priests and Inquisitors now have a chance to affect the Undead with Holy Power, decreasing their combat ability
    * Peasant's Team Spirit bonus is now a function of the square root of the number of troops and no longer has a restriction on how high the bonus may go.
    * ***BUG*** Fixed error in features_bleeding (target -> receiver) (thanks Windows 8!)
*.TXT
  * CONFIG.TXT
    * Leadership Reduction Limit is no longer used since you can't (apparently) clamp the leadership reduction bonus counters
  * DIANA_BABIES.TXT
    * Added Beholders and Evil Book Level 1 (Level 3), Evil Beholders and Evil Book Level 2 (Level 4), and Evil Book Level 3 (Level 5) to Dracon's Mage bonuses
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Aine (thanks Windows 8!)
  * GERDA_BABIES.TXT
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Grindan, Mutare, and Thunar (thanks Windows 8!)
  * HERO.TXT - removed wolf from the starting army lists, since I guess you can't technically buy any in that state throughout the game
  * ITEMS_MONSTER.TXT
    * For all the changes below, you need to collect (or buy) another container for these changes to take affect
    * "snake_egg" now has a chance to generate all snakes
    * "spider_egg" now has a chance to generate all spiders
    * "dfly_egg" now has a chance to generate all dragonflies (equal probability)
    * "skeleton_grave" now has a chance to generate all skeletons (almost equal probability)
    * "vampire_grave" now has a chance to generate all vampires
    * "thorn_seed"
      * Now has a chance to also generate Thorn Warriors (equal probability between Thorns and Thorn Warrios)
      * If the number of seeds exceed a certain random range (47-76 seeds) also will produce (always) Royal Thorns for each 47-76 seeds
    * "ent_seed" now always produces Ancient Ents if 4-5 seeds or more are used (1 for each 4-5 seeds)
    * There is now a slight chance of a griffin egg producing twins (but only when used individually)!
    * There is now a slight chance of all dragon eggs producing twins (but only when used individually)!
  * MIRABELLA_BABIES.TXT
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Cuthbert, Caitlin, and Haart (thanks Windows 8!)
  * MORALE.TXT
    * Fixed issue with giving Humans, Dwarves, and Elves +1 Morale for each level of Diplomacy (should be just +1 Morale @Level 1)
    * Fixed issue with giving Neutrals and Orcs +1 Morale for level 2 and 3 Diplomacy (should be just +1 Morale @Level 2)
    * Now Tolerance Level 1 removes the Elf / Dwarf Morale penalty
    * Undead Morale penalty now is removed @ Tolerance Level 2 (was 1)
    * Demon Morale penalty now is removed @ Tolerance Level 3 (was 2)
  * NEOKA_BABIES.TXT
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Jenova, Gelare, and Kendal (thanks Windows 8!)
  * ORCELYN_BABIES.TXT
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Erdamon (thanks Windows 8!)
  * RINA_BABIES.TXT
    * Removed sp_lead_unit_bat and sp_lead_unit_bat2 from Isra, Sandro, Xsi, Finneas, Clavius, Vidomina, and Death Haart (these counters don't exist)
    * Changed sp_lead_unit_vampire3 to sp_lead_unit_vampire2 for Sandro, Xsi, Finneas, and Clavius (how'd that get there???)
    * Removed duplicate sp_lead_unit_bonedragon from Vidomina (thanks to Fatt_Shade for pointing this one out!)
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Nagash and Clavius (thanks Windows 8!)
  * SKILLS.TXT
    * Explorer now increases the Hero's Search Radius by +1 for each level
    * Tolerance:
      * Now has 3 levels:
        * Elves & Dwarves @ Level 1
	* Undead @ Level 2
	* Demons @ Level 3
      * Resist All is now +2, 4, and 6% (was +2 and +5%)
  * SPELLS.TXT
    * Had not realized that I had doubled up on the "holy" parameter using it for both the holy affliction chance and the sp_spell_holy bonus. Spells affected by sp_spell_holy now have an sp_holy parameter (instead of just holy), reserving holy for the chance of inflicting Holy Power on the Undead.
    * Had not realized that I had weakened Stone Skin when I made it mass - set the values to allow twice as much power as Divine Armor
  * WIFES.TXT
    * Removed sp_lead_unit_bat, sp_lead_unit_bat2, from Zombie Rina since these counters don't exist (sp_lead_unit_vampire, sp_lead_unit_vampire2 are the valid ones)
  * XEONA_BABIES.TXT
    * Fixed sp_addgold_chestt misspelling (sp_addgold_chest) for Octavia and Mutare Drake (thanks Windows 8!)
*.LOC - ***CHANGES TO LOC FILES ONLY AFFECT NEW GAMES***
  * Increased chance of:
    * Getting rare units
    * Unit generators (i.e. seeds, eggs, etc.)
    * Unit variability here and there.
  * If not specified then the ranges were not changed.
  * DARION_1_EMBRYOS.LOC (Greenwort)
    * Ghost Ship:
      * Now has a 25% chance to sell Skeleton Graves (3:10)
      * Now has a 10% chance to sell Vampire Coffins (1:3)
    * Pet Shop:
      * Now has a 50% chance to sell Dragon Fly Eggs (10:25)
      * Now has a 25% chance to sell Spider Eggs (3:10)
      * Now has a 10% chance to sell Snake Eggs (1:3)
      * Now has a 10% chance to sell Griffin Eggs (1:3)
      * Has the same probabilities of the above generators after finishing quest
    * Royal Thorn Shop:
      * Now has a chance to sell more (sometimes fewer) Thorn Seeds (100 -> 70:5:140)
      * Now has a 10% chance to sell Royal Thorns (1:2)
    * Milk Woman Shop now has a 10% chance to sell Royal Thorns (1)
    * Forester Shop:
      * Now has a 10% chance to sell Thorn Seeds (10:25)
      * Now has a 10% chance to sell Spider Eggs (5:15)
      * Now has a 10% chance to sell Druids (5:15)
      * Now has a 20% chance to sell Thorn Seeds (20:5:50) after finishing quest
      * Now has a 20% chance to sell Spider Eggs (10:30) after finishing quest
      * Now has a 20% chance to sell Druids (10:30) after finishing quest
      * Now has a 20% chance to sell Royal Thorns (1:2) after finishing quest
    * Robber Shop:
      * Now has a 50% chance to sell Spider Eggs (6:20)
      * Now has a 25% chance to sell Snake Eggs (2:6)
      * Now has a 25% chance to sell Griffin Eggs (2:6)
      * Now has a 50% chance to sell either Pirates (50:100) or Sea Dogs (25:50)
    * Aron's Temple:
      * Now sells Inquisitors (20:40) after becoming a Baron
      * Now sells Inquisitors (75:5:150) after becoming an Earl
      * Now sells Inquisitors (400:50:800) after becoming a Lord
  * DARION_1_DUNGEON_1.EMBRYOS.LOC - Snake Trader now sells Snake Eggs (10:30)
  * DARION_2_EMBRYOS.LOC (Verlon Forest)
    * Shop at entrance to Verlon Forest:
      * Now has a 25% chance to sell Dragon Fly Eggs (50:5:125)
      * Now has a 20% chance to sell Thorn Seeds (25:5:75)
      * Now has a 10% chance to sell Griffin Eggs (1:5)
      * Now has a 10% chance to sell Royal Thorns (1:2)
      * Now has a chance to sell more Griffins (5:10 -> 10:20)
    * River Farm:
      * Now has a 50% chance to sell Dragon Fly Eggs (100:10:250)
      * Now has a 50% chance to sell Thorn Seeds (50:10:150)
      * Now has a 20% chance to sell Griffin Eggs (2:10)
      * Now has a 50% chance to sell Thorns and Thorn Warriors
      * Now has a 25% chance to sell a Level 1 Elf troop (Sprites or Lake Faeries) (75:5:150)
      * Now has a 20% chance to sell Royal Thorns (was 16.7%)
      * Now has a chance to sell more Royal Thorns (1 -> 2:4)
    * Dragon's Castle:
      * Now has a 50% chance to sell Dragon Fly Eggs (50:10:150)
      * Now has a 50% chance to sell Spider Eggs (20:40)
      * Now has a 20% chance to sell Griffin Eggs (5:10)
    * Druid's Shop:
      * Now sells Thorn Seeds (100:10:200)
      * Now has a 25% Chance to sell Griffin Eggs (5:20)
      * Has a 10% Chance to sell Ent Seeds (1:3)
      * Now sells Druids (40:5:100)
      * Now sells either:
        * Sprites: 250:50:500
        * Lake Faeries: 250:50:500
	* Dryads: 100:25:250
      * Now has a 40% chance to sell either Griffins (20:5:100) or Royal Thorns (1:5)
    * Robber House:
      * Now has a 75% chance to sell Spider Eggs (50:5:100)
      * Now has a 20% Chance to sell Griffin Eggs (5:10)
      * Now has a 10% chance to sell Skeleton Graves (5:20)
    * Viking Ship:
      * Now has a 25% Chance to sell Griffin Eggs (5:15)
      * Now has a 25% chance to sell Griffins (10:5:50)
      * Now has a 10% chance to sell Druids (10:5:50) or Royal Thorns (2:5)
  * DARION_3_EMBRYOS.LOC (Marshan Swamp)
    * Tavern - now has a chance to sell more knights (2:5 -> 4:10)
    * Robber House:
      * Now has a 25% chance to sell Skeleton Graves (15:30)
      * Now has a 10% chance to sell Vampire Coffins (5:10)
    * Tomb (03):
      * Now has a 40% chance to sell Skeleton Graves (30:5:60)
      * Now has a 20% chance to sell Vampire Coffins (10:20)
      * Now has a 33.3% chance to sell Undead Spiders (250:25:400)
    * Tomb (01):
      * Now has a 40% chance to sell Skeleton Graves (30:5:60)
      * Now has a 20% chance to sell Vampire Coffins (10:20)
      * Now sells more Spider Eggs (10 -> 10:5:50)
      * Now has a 16.7% chance to sell Undead Spiders (250:25:400)
      * Now has a 25% chance to sell Cursed Zombies (50:5:100)
      * Now has a 25% chance to sell Cursed Ghosts (50:5:100)
    * Frogus Castle:
      * Now has a 10% chance to sell Thorn Seeds (25:5:75)
      * Now has a 50% chance to sell Spider Eggs (30:5:60)
      * Now has a 25% chance to sell Snake Eggs (10:30)
      * Now has a 22.2% chance to sell Royal Thorns (3:10)
      * Now has a 20% chance to sell Thorn Seeds (50:10:150) after completing quest
      * Now sells Spider Eggs (60:10:120) after completing quest
      * Now has a 50% chance to sell Snake Eggs (20:5:60) after completing quest
    * Bagaba Castle:
      * Now has a 60% chance to sell Spider Eggs (45:5:75)
      * Now has a 30% chance to sell Snake Eggs (15:5:45)
      * Now sells Spider Eggs (90:10:150) after completing quest
      * Now has a 60% chance to sell Snake Eggs (30:5:90) after completing quest
    * Furious Paladin:
      * Now has an 80% chance to sell Skeleton Graves (50:5:150) when dead
      * Now has a 40% chance to sell Vampire Coffins (20:40) when dead
      * Undead Spiders (33% chance) moved to group of Skeleton Archers and Skeletons when dead
      * Cursed Ghosts (25% chance) added to second group (50:5:100) when dead
    * Witches (Martha's) Hut (01):
      * Now has a 20% chance to sell Thorn Seeds (50:10:150)
      * Now has a 10% chance to sell Snake Eggs (10:30)
      * Now has a 33% chance of selling Royal Thorns (2:4)
    * Emenem's Castle:
      * Now has a 50% chance to sell Skeleton Graves (10:5:40)
      * Now has a 25% chance to sell Vampire Coffins (2:10)
      * Now has a 10% chance to sell a Level 4 Undead Troop (10:20)
    * Witches (Chavakha's) Hut (03):
      * Now has a 20% chance to sell Spider Eggs (45:5:90)
      * Now has a 10% chance to sell Snake Eggs (15:5:45)
  * DARION_4_EMBRYOS.LOC (Arlania)
    * Castle:
      * Now has a 25% chance to sell Dragon Fly Eggs (40:80)
      * Now has a 20% chance to sell Thorn Seeds (50:5:100)
      * Now has a 10% chance to sell Griffin Eggs (2:10)
      * Now has a 60% chance to sell Dragon Fly Eggs (80:5:160) after finishing quest
      * Now has a 50% chance to sell Thorn Seeds (100:10:200) after finishing quest
      * Now has a 25% chance to sell Griffin Eggs (4:15) after finishing quest
    * Tavern:
      * Now has a 20% chance to sell Griffin Eggs (5:20)
      * Now has a 25% chance to sell Griffins (20:5:80)
      * Increased level 4 unit count by 5 times (i.e. 2:4 -> 10:20, 1:2 -> 5:10)
    * Viking Ship:
      * Now has a 25% chance to sell Griffin Eggs (5:25)
      * Now has a 30% chance to sell Griffins (25:5:100)
      * Now has a 25% chance to sell Either Druids (20:50) or Royal Thorns (2:5)
    * Harl:
      * Now has a 25% chance to sell Dragon Fly Eggs (50:5:250)
      * Now has a chance to sell more Griffin Eggs (10 -> 10:30)
      * Now has a 50% chance to sell Dragon Fly Eggs (100:10:500) after finishing quest
      * Now has a chance to sell more Griffin Eggs (30 -> 30:5:90) after finishing quest
    * Ghost Ship:
      * Now has a 25% chance to sell Skeleton Graves (25:5:75)
      * Now has a 10% chance to sell Vampire Coffins (5:10)
      * Now has a 10% chance to sell Vampires (10:30)
  * DEMON_1_EMBRYOS.LOC (Demonis)
    * Demon Tower (02) increase max of Level 3, 4 Demons (200 -> 400)
    * Baal's Castle:
      * Fire Spiders are now available (9999)
      * Scoffer Imps are now available (9999)
      * Cerberi and Demonesses are now separated and have a 75% chance of being available
      * Demons and Archdemons are now separated and have a 75% chance of being available 
      * There is a 75% chance of getting a Level 2-4 Demon trooop (200:10:500)
      * There is another 75% chance of getting a Level 2-4 Demon trooop (200:10:500)
      * There is now a 50% chance of getting 10:30 more Archdemons
    * Building Demon (05)
      * There is now a 25% chance of getting 2:4 Level 5 Demon troops in the first slot
      * There is now a 7.7% chance of getting 2:4 Level 5 Demon troops in the second slot
    * Xeona's Castle:
      * Now has a 50% chance to sell Red Dragons Eggs (1:2)
      * Now always sells Red Dragons Eggs (2:4) after defeating Xeona
      * Scoffer Imps, Cerberi, and Demons broken out and have a 75% chance of being available after defeating Xeona
      * Fire Spiders and Imps have a 75% chance of being available (500:5:1000) after defeating Xeona
      * Now has a 50% chance to sell an additional Level 2-4 Demon troop (150:5:300) after defeating Xeona
      * Now has a 50% chance to sell Archdemons (5:15) after defeating Xeona
      * Now has a 25% chance to sell Red Dragons (5:15) after defeating Xeona
    * Wizard Tower - Priests changed to Inquisitors
  * ELLINIA_1_EMBRYOS.LOC (Magic Valley)
    * Vermeus's Shop:
      * Now has a 50% chance to sell Ent Seeds (10:30)
      * Priests changed to Inquisitors
      * Now has an 80% chance to sell Druids (200:5:300)
    * Dryad Shop:
      * Now has a 50% chance to sell Sprites (500:100:2000)
      * Now has a 50% chance to sell Lake Faeries (500:100:2000)
      * Griffins changed to Ancient Ents (5:20)
    * Flower (01) Shop:
      * Increased number of possible Thorn Seeds (30:50 -> 250:125:750)
      * Always sells Dryads
      * Has a chance to sell either Druids & Werewolf Elves (instead of Dryads and Werewolf Elves)
    * Snake Trader - increased Snake Eggs (50 -> 50:5:200)
    * Werewolf Shop:
      * Increased Thorn Seeds (100:200 -> 200:50:500)
      * Now has a 50% chance to sell Ent Seeds (5:10)
      * Now has a 50% chance to sell Gray Wolves (2000:500:9000)
    * Mushroom Shop:
      * Snake Eggs increased (10 -> 25:5:50)
      * Spider Eggs increased (10 -> 50:10:100)
      * Thorn Seeds increased (50:100 -> 125:5:250)
      * Now has a 50% chance to sell Royal Thorns (20:5:60)
    * Unicorn Shop:
      * Now sells Thorn Seeds (125:25:750)
      * Now has a 50% chance to sell either Sprites or Lake Faeries (500:100:2000)
    * Water Lily:
      * Now has a 50% chance to sell Sprites
      * Now always sells Lake Faeries
      * Now has a 50% chance to sell either Dragonflies (Lake & Fire), Sprites (both), or Thorns (both) (500:25:1500)
      * Now has a 50% to sell Dryads and Ents (was a 50% chance to sell either Dryads or Ents)
    * Dragonfly Farm:
      * Now has a 50% chance to sell Dragon Fly Eggs (150:25:400)
      * Now has a 50% chance to sell Thorn Seeds (250:25:750)
      * Now has a 50% chance to sell Ent Seeds (5:10)
      * Now always sells Lake Dragon Flies
      * Now always sells Fire Dragon Flies
      * Alternate slot is now between Sprites and Lake Faeries (removed Lake Dragon Flies)
      * Now has a 50% chance to sell Royal Thorns (15:5:45)
      * Now has a 50% chance to sell either Ents (15:5:45) or Ancient Ents (5:10)
  * ELLINIA_1_LABIRINT_1.EMBRYOS.LOC
    * Werewolf Shop:
      * Now has a 50% chance to sell Snake Eggs (100:50:400)
      * Now has a 50% chance to sell Spider Eggs (200:25:1000)
    * Dragon Shop:
      * Now has a 25% chance to sell Green Dragon Eggs (2:10)
      * Now has a 25% chance to sell Red Dragon Eggs (2:10)
      * Now has a 25% chance to sell Black Dragon Eggs (2:10)
      * Now has a 25% chance to sell Bone Dragon Eggs (2:10)
  * ELLINIA_1_LABIRINT_2.EMBRYOS.LOC
    * Tomb (03) Shop:
      * Now has a 75% chance to sell Skeleton Graves (500:50:2500)
      * Now has a 50% chance to sell Vampire Coffins (100:25:250)
      * Now sells either Necromancers (100:40:300) or Black Knights (100:40:300)
    * Skaar's Shop:
      * Now has a 50% chance to sell Green Dragon Eggs (1:5)
      * Now has a 50% chance to sell Red Dragon Eggs (1:5)
      * Now has a 50% chance to sell Black Dragon Eggs (1:5)
    * Unicorn Shop:
      * Now has a 50% change to sell Snake Eggs (400:25:800)
      * Now has a 50% change to sell Griffin Eggs (100:25:500)
      * Now has a 25% chance to sell Green Dragon Eggs (2:4)
    * Mushroom Shop:
      * Now has a 50% chance to sell Thorn Seeds (1000:250:4000)
      * Now has a 40% chance to sell Spider Eggs (500:50:2500)
      * Now has a 30% chance to sell Snake Eggs (250:25:1000)
      * Now has a 25% chance to sell Ent Seeds (25:5:100)
      * Now always sells Royal Thorns (75:10:300)
    * Pirate Shop:
      * Footman changed to equal chance of Robbers and Marauders (600:30:1200)
    * Demon Shop:
      * Now has a 20% chance to sell Fire Spiders (1000:40:2000)
      * Now has a 20% chance to sell Imps (1000:40:2000)
      * Now has a 20% chance to sell Scoffer Imps (1000:40:2000)
      * Now has a 20% chance to sell Cerberi (750:25:1500)
      * Now has a 75% chance to sell Demons (400:20:1200)
      * Now has a 75% chance to sell Archdemons (40:5:120)
    * Giant Shop:
      * Now has a 50% chance to sell Dragon Fly Eggs (500:125:2500)
      * Now has a 50% chance to sell Green Dragon Eggs (2:5)
      * Now has a 50% chance to sell Red Dragon Eggs (2:5)
      * Now has a 50% chance to sell Black Dragon Eggs (2:5)
  * ELLINIA_1_LABIRINT_3.EMBRYOS.LOC
    * Dragon Shop:
      * Now has a 25% chance to sell Green Dragon Eggs (1:5)
      * Now has a 25% chance to sell Red Dragon Eggs (1:5)
      * Now has a 25% chance to sell Black Dragon Eggs (1:5)
      * Now has a 25% chance to sell Bone Dragon Eggs (1:5)
    * Dryad Shop:
      * Now has a 20% chance to sell Green Dragon Eggs (1:2)
      * Now has a 75% chance to sell Sprites (1200:200:4800)
      * Now has a 75% chance to sell Lake Faeries (1200:200:4800)
      * Now always sells Dryads (400:80:800)
      * Now has a 50% chance of selling another Level 3 to 4 Elf Troop (200:40:400)
  * ELLINIA_2_EMBRYOS.LOC (Great Forest)
    * Neoka's Castle:
      * Now has a 50% chance to sell Ent Seeds (5:10)
      * Now has a 50% chance to sell Ent Seeds (10:25) after marrying Neoka
      * Now has a 50% chance to sell Sprites (2000:500:5000) after marrying Neoka
      * Now has a 50% chance to sell Lake Faeries (2000:500:5000) after marrying Neoka
      * Now has a 50% chance to sell Dryads (500:250:2500) after marrying Neoka
      * Now has a 50% chance to sell Druids (400:200:2000) after marrying Neoka
      * Now has a 50% chance to sell Elves (200:100:1000) after marrying Neoka
      * Now has a 50% chance to sell Hunters (100:50:500) after marrying Neoka
      * Now has a 50% chance to sell Unicorns (100:50:500) after marrying Neoka
      * Now has a 50% chance to sell Ents (50:25:250) after marrying Neoka
      * Now has a 50% chance to sell Ancient Ents (5:25) after marrying Neoka
    * Druid Shop:
      * Now has a 75% chance to sell Thorn Seeds (500:100:2000)
      * Now has a 50% chance to sell Ent Seeds (5:20)
      * Now always sells Druids (100:5:200)
      * Chance to sell Druids is now chance to sell Dryads (100:5:200)
      * Now has a 50% chance to sell Royal Thorns (50:5:100)
    * Mushroom Shop:
      * Now has a 50% chance to sell Thorn Seeds (250:125:1500)
      * Now has a 25% chance to sell Ent Seeds (10:20)
      * Increased number of possible Ents (40:60 -> 60:5:120)
    * Werewolf Shop:
      * Now always sells Gray Wolves (200:5:500), Bears (150:5:400), or Ancient Bears (100:5:300)
      * Now has a 50% chance to sell Werewolf Elves
      * Added additional unit slot that has a 50% chance to sell either Druids or Dryads (250:5:500)
    * Dryad Shop:
      * Now has a 50% chance to sell Ent Seeds (5:20)
      * Now has a 50% chance to sell Sprites (400:10:800)
      * Now has a 50% chance to sell Lake Faeries (400:10:800)
      * Now always sells Dryads (200:5:400)
      * Chance of Elves replaced with Druids (200:5:400)
      * Griffins replaced with Ents (10:25)
  * ELLINIA_3_EMBRYOS.LOC (Valley of a Thousand Rivers)
    * Castle:
      * Now has a 75% chance to sell Ent Seeds (5:10)
      * Chance of either Sprites, Lake Faeries, or Dryads is now a 75% chance to sell all 3
      * Now has a 75% chance to sell Druids (300:50:700)
      * Now always sells Ent Seeds (50:100) after killing Karador
      * Now always sells max Sprites, Lake Faeries, and Dryads (9999) after killing Karador
      * Chance of either Druids or Werewolf Elves is now always sell both after killing Karador
      * Chance of either Ents, Ancient Ents, or Unicorns is now always sell all 3 after killing Karador
    * Robber Shop - now has a 25% chance to sell Griffin Eggs (50:5:200)
    * Pirate House
      * Now has a 50% chance to sell Thorn Seeds (500:50:1000)
      * Replaced Thorn with Royal Thorn (15:5:30)
    * Water Lily Shop:
      * Now has a 75% chance to sell Thorn Seeds (250:50:1000)
      * Now has a 25% chance to sell Ent Seeds (5:30)
      * Now always sells Sprites
      * Now has a 75% chance to sell Lake Fearies
      * Now has a 75% chance to sell either Dragonflies (Lake & Fire), Sprites (both), or Thorns (both) (500:25:1500)
      * Now has a 50% chance to sell Dryads
      * Chance of Griffin replaced with Ancient Ent
      * Doubled number of possible Royal Thorns (10:15 -> 20:30)
      * Added chance of Druids (200:50:500)
    * Dryad Shop:
      * Now has a 75% chance to sell Thorn Seeds (500:50:1000)
      * Now has a 25% chance to sell Ent Seeds (10:30)
      * Now has a 50% chance to sell Sprites
      * Now has a 50% chance to sell Lake Faeries
      * Now always sells Dryads
      * Chance of Dryad replaced with Druid
      * Chance of Lake Faery replaced with Lake Dragon Fly
    * Flower Shop:
      * Now has a 75% chance to sell Thorn Seeds (500:50:1000)
      * Now has a 25% chance to sell Ent Seeds (10:30)
      * Added additional 50% chance of getting either Royal Thorns (75:5:250), Ents (50:5:200), or Ancient Ents (25:50)
    * Green Dragon Shop now sells Green Dragon Eggs (15:30)
    * Unicorn Shop:
      * Now has a 50% chance to sell Thorn Seeds (200:40:800)
      * Now has a 25% chance to sell Ent Seeds (5:20)
      * Now has a 66.7% chance to sell Druids (300:50:700)
    * Elf Shop:
      * Now has an 80% chance to sell Thorn Seeds (250:50:1000)
      * Now has a 40% chance to sell Griffin Eggs (50:100)
      * Now has a 20% chance to sell Green Dragon Eggs (5:10)
      * Chance of Bowmen changed to Druids and number halved (1000:50:3000 -> 500:25:1500)
      * Chance of Footmen changed to Sprites
      * Chance of Robbers changed to Lake Faeries
    * Druid Shop:
      * Now always sells Druids
      * Chance of Druid changed to Dryad (100:10:300)
      * Added Lake Faeries to chance of unit list (1000:50:3000)
    * Elunium's Unicorn Shop:
      * Now has a 50% chance to sell Thorn Seeds (200:50:1000)
      * Now has a 25% chance to sell Ent Seeds (10:40)
      * Now always sells Unicorns (300:50:1500)
      * Now has a 50% chance to either sell Dryads or Druids (300:50:1500)
      * Now has a 50% chance to either sell Ents (30:5:150) or Ancient Ents (5:30)
    * Beaulla's Shop:
      * Now has a 40% chance to sell Thorn Seeds (200:50:800)
      * Now has a 20% chance to sell Ent Seeds (5:20)
      * Now always sells Sprites and Lake Faeries (250:5:500)
      * Now always sells Dryads (100:25:400)
      * Now has an 80% chance to sell Thorn Seeds (400:100:1600) after finishing quest
      * Now has a 40% chance to sell Ent Seeds (10:2:40) after finishing quest
      * Now always sells Sprites and Lake Faeries (1000:5:2500) after finishing quest
      * Now always sells Dryads (800:100:1600) after finishing quest
      * Now has a 25% chance to sell Level 5 Elf (Ancient Ents) troop (5:25) after finishing quest
  * ISLAND_1_EMBRYOS.LOC (Western Islands)
    * Pirate House Shop - now has a 15% chance to sell Griffin Eggs (5:10)
    * Orc Embassy
      * Now has a 20% chance to sell Griffin Eggs (20:40)
      * Now has a 40% chance to sell Griffin Eggs (40:5:80) after finishing quest
      * Now has a 25% chance to sell Level 5 Orc troops (5:10) after finishing quest
    * Thorny Dog's Shop - now has a 20% chance to sell Griffin Eggs (5:15)
    * Pirate House (3 #1) Shop:
      * Now has a 20% chance to sell Thorn Seeds (50:25:200)
      * Now has a 10% chance to sell Griffin Eggs (5:10)
      * Now has a 22.2% chance to sell Royal Thorns (3:5)
    * Pirate House (3 #2) Shop - now has a 15% chance to sell Griffin Eggs (5:10)
    * Pirate House (3 #3) Shop - now has a 15% chance to sell Griffin Eggs (4:8)
    * Pirate House (3 #4) Shop:
      * Now has a 10% chance to sell Griffin Eggs (4:12)
      * Now has a 20% chance to sell Griffin Eggs (5:15) after finishing quest
    * Pirate House (4) Shop:
      * Now has a 15% chance to sell Griffin Eggs (5:15)
      * Now has a 30% chance to sell Griffin Eggs (5:20) after finishing quest
    * Pirate House (3 #5) Shop
      * Now has a 10% chance to sell Griffin Eggs (5:10)
      * Now has a 20% chance to sell Griffin Eggs (5:20) after finishing quest
    * Pirate House Shop
      * Increased number of possible Knights (3:5 -> 15:25)
      * Now has a 20% chance to sell Griffin Eggs (5:20)
    * Governer Thompson's Castle:
      * Now has a 40% chance to sell Thorn Seeds (100:50:200)
      * Now has a 20% chance to sell Griffin Eggs (5:25)
      * Chance for Thorns changed to Royal Thorns (3:10)
      * Now has a 60% chance to sell Thorn Seeds (100:50:400) after completing quest
      * Now has a 40% chance to sell Griffin Eggs (10:50) after completing quest
      * Now sells max Robbers (9999) after completing quest
      * Now sells max Marauders (9999) after completing quest
      * Now has a 50% chance to sell Griffins (100:25:300) after completing quest
    * House Shop (03)
      * Now has a 25% chance to sell Griffin Eggs (5:30)
      * Increased numbers of Knights (2:4 -> 10:20), Polar Bears (2:5 -> 10:25), and Griffins (15:40 -> 45:120)
  * ISLAND_2_EMBRYOS.LOC (Eastern Islands)
    * Cursed Pirate Shop - now has a 25% chance to sell Griffin Eggs (5:25)
    * Duke's Castle:
      * Now has a 20% chance to sell Griffin Eggs (5:20)
      * Now has a 40% chance to sell Griffin Eggs (10:40) after killing Duke
      * Now has a 50% chance to sell Griffins (50:5:100) after killing Duke
    * Pirate House (3) Shop - now has a 15% chance to sell Griffin Eggs (5:15)
    * Barbarian Shop - now has a 40% chance to sell Griffins (25:5:150)
    * Ghost Ship:
      * Now has a 50% chance to sell Skeleton Graves (50:10:150)
      * Now has a 20% chance to sell Vampire Coffins (10:20)
      * Now has a chance to sell Undead Spiders (300:50:600)
      * Now sells an additional Level 2-3 Undead unit (50:10:300)
    * Underwater Ship:
      * Now has a 75% chance to sell Skeleton Graves (100:10:300)
      * Now has a 30% chance to sell Vampire Coffins (20:40)
      * Now has a chance to sell Undead Spiders (100:10:200)
      * Now sells an additional Level 1 Undead troop (200:20:400)
      * Now has a 50% chance to sell an additional Level 3-4 Undead troop (25:5:100)
      * Now has a 50% chance to sell an additional Level 3 Undead troop (50:10:200)
      * Now has a 50% chance to sell an additional Level 4 Undead troop (25:5:100)
    * Viking Ship (01)
      * Now has a 30% chance to sell Griffin Eggs (10:25)
      * Now has a chance to sell Royal Thorns (3:20)
      * Now has a 75% chance to sell either Druids (100:25:250) or Griffins (100:25:250)
    * Pirate Shop - now has a 15% chance to sell Griffin Eggs (5:15)
    * Pirate Shop (03 #1) - now has a 15% chance to sell Griffin Eggs (6:18)
    * Pirate Shop (03 #2)
      * Now has a 60% chance to sell Griffin Eggs (10:40)
      * Increased Knight (2:4 -> 10:20), Unicorn (3:5 -> 15:25), Griffin (30:150 -> 60:300), and Royal Thorns (2:5 -> 4:10)
  * KORDAR_DEMONROAD.EMBRYOS.LOC (Road to Demonis)
    * Dwarf Shop
      * Now has a 20% chance to sell Thorn Seeds (200:50:2500)
      * Added chance of Royal Thorns (20:30)
  * KORDAR_DUNGEON_1.EMBRYOS.LOC (Lower Hadar)
    * Dwarf Tavern - now has a 50% chance to sell Spider Eggs (100:25:400)
  * MUROK_1.EMBRYOS.LOC
    * Orc (01) Shop:
      * Now has a 20% chance to sell Black Dragon Eggs (2:8)
    * Odium Shop:
      * Now has a 25% chance to sell Green Dragon Eggs (5:10)
      * Now has a 25% chance to sell Red Dragon Eggs (5:10)
      * Now has a 25% chance to sell Black Dragon Eggs (5:10)
  * UNDEAD_1.EMBRYOS.LOC
    * Vampire Shop:
      * Now has a 75% chance to sell Skeleton Graves (200:20:400)
      * Now has a 50% chance to sell Vampire Graves (50:10:100)
      * Now has a 20% chance to sell Bone Dragon Eggs (1:2)
      * Now has a 66.7% chance to sell either Black Knights or Necromancers (20:10:100)
    * Tomb (03):
      * Now has a 60% chance to sell Skeleton Graves (250:25:500)
      * Now has a 40% chance to sell Vampire Graves (20:5:50)
      * Now has a 20% chance to sell Bone Dragon Eggs (1:2)
    * Tomb (01):
      * Now has a 50% chance to sell Skeleton Graves (200:50:600)
      * Now has a 30% chance to sell Vampire Graves (25:5:60)
      * Now has a 10% chance to sell Bone Dragon Eggs (1:2)
    * Black Tower:
      * Now has a 90% chance to sell Skeleton Graves (100:50:800)
      * Now has a 75% chance to sell Vampire Graves (60:5:120)
      * Now has a 50% chance to sell Bone Dragon Eggs (2:5)
    * Dead House (02):
      * Now has a 50% chance to sell Skeleton Graves (40:10:160)
      * Now has a 25% chance to sell Vampire Graves (10:2:40)
      * Now has a 10% chance to sell Bone Dragon Eggs (1:2)
    * Dead Temple (01):
      * Now has a 60% chance to sell Skeleton Graves (80:10:200)
      * Now has a 40% chance to sell Vampire Graves (20:5:50)
      * Now has a 10% chance to sell Bone Dragon Eggs (1:2)
    * Ghost Ship:
      * Now has a 50% chance to sell Skeleton Graves (50:5:150)
      * Now has a 25% chance to sell Vampire Graves (20:2:60)
      * Now has a 10% chance to sell Bone Dragon Eggs (1:2)
    * Barbarian Shop - now has a 25% chance to sell Skeleton Graves (20:5:100)
  * UNDEAD_2.EMBRYOS.LOC
    * Karador's Castle:
      * Now sells Skeleton Graves (400:100:1600)
      * Now has a 75% chance to sell Vampire Graves (100:10:200)
      * Now has a 25% chance to sell Bone Dragon Eggs (10:25)
      * Chance for Skeleton Archers, Cursed Ghosts, and Cursed Zombies is to always sell those troops
      * Chance for Bone Dragons or Black Knights is to always sell those troops
      * Now has a 75% chance to sell Skeletons (1000:100:9000)
      * Now has a 75% chance to sell Undead Spiders (1000:100:9000)
      * Now has a 75% chance to sell Zombies (1000:100:9000)
      * Now has a 75% chance to sell Ghosts (1000:100:9000)
      * Now has a 75% chance to sell Vampires (500:50:2500)
      * Now has a 75% chance to sell Ancient Vampires (150:30:400)
      * Now has a 75% chance to sell Necromancers (150:30:400)
    * Werewolf Shop - now has a 66.7% chance to sell Gray Wolves (1000:100:9000)
    * Zelbarra's Shop:
      * Now has an 80% chance to sell Skeleton Graves (150:50:600)
      * Now has a 40% chance to sell Vampire Graves (50:5:100)
      * Now has a 20% chance to sell Bone Dragon Eggs (1:3)
    * Dead House (02):
      * Now has a 50% chance to sell Skeleton Graves (80:10:160)
      * Now has a 25% chance to sell Vampire Graves (15:5:80)
      * Now has a 10% chance to sell Bone Dragon Eggs (1:2)
    * Vampire Shop:
      * Now has a 90% chance to sell Skeleton Graves (200:50:700)
      * Now has a 50% chance to sell Vampire Graves (50:10:150)
      * Now has a 25% chance to sell Bone Dragon Eggs (2:4)
      * Now has a 66.7% chance to sell Necromancers (40:20:200)

Version: Beta 2012-12-01
-------------------------

* All files have been combined into a single KFS file to make installation / unintstallation easier.
* mod_h3b.kfs
  *.ATOM
    * BONEDRAGON.ATOM
      * Bone Dragon's now have the Dread feature, which decreases enemy morale based on level.
        * Level 1-2: -3 Morale
	* Level 3-4: -2 Morale
	* Level 5: -1 Morale
    * CYCLOP.ATOM
      * Ranged attack now stuns and knocks units unconscious
    * DEATH.ATOM - Ability rest values now start low and increase as the ability gets more powerful
    * DEVATRON.ATOM - Ice thorns now have a thorns ability that damages attackers and units surrounding the thorn when it explodes
    * DEVATRON_THROW.ATOM - A variant of the devatron atom for attack purposes
    * LINA.ATOM
      * Ability rest values now start low and increase as the ability gets more powerful
      * Ice Thorns
        * Now damage enemies where a thorn would go
	* Now have a random life from 1 to duration turns, after which the thorn explodes doing area of effect damage around the thorn
	* Damage attackers
	* Thorn returned damage is now a certain percentage of the thorn damage and applies to both attackers and area of effect damage
    * SHAMAN.ATOM
      * Death Totem health is now percent of Shaman health (40%)
      * Life Totem health is now percent of Shaman health (50%)
      * New parameter, init_den (for both totems), increases the totem's initiative by it's health divided by this parameter
    * SLIME.ATOM - Ability rest values now start low and increase as the ability gets more powerful
    * SPIDER_FIRE.ATOM - added the Demon arena_bonuses section since I changed them to Demons and forgot to do this previously
    * THEROCK.ATOM - Ability rest values now start low and increase as the ability gets more powerful
    * TOTEM_DEATH.ATOM
      * Totem damage doubled
    * TOTEM_LIFE.ATOM
      * Totem cure doubled
      * Removed nfeatures: plant, golem, undead - cure now affects these creatures as well
    * Dwarf ATOMs: ALCHEMIST, CANNONER, DWARF, GIANT, MINER
      * +25% Attack (except Giants and Miners) in Dungeon environments, note that Miners receive +50% Attack in Dungeons due to their Night Sight
      * -2 Morale (except Cannoneers and Giants) at Sea
      * Added the appropriate headers / hints
    * Elf ATOMs: DRUID, DRYAD, ELF, ELF2, ENT, ENT2, SPRITE, SPRITE_LAKE, UNICORN, UNICORN2, WEREWOLF, WOLF
      * +50% Attack in Forest environments
      * -1 Morale (except Black Unicorn, Werewolf, and Werewolf Elf) in Dungeon environments
      * Added the appropriate headers / hints
    * ATOMs that like the forest: BEAR, BEAR2, GRAYWOLF
      * +25% Attack in Forest environments
    * Resistant to Cold ATOMs: BEAR2, GIANT
      * GIANTS now have the Resistant to Cold feature
      * BEAR2 had Resistanct to Cold arena bonuses (the bonus hint did not mention this), but I think that was a mistake so it has been removed
    * Thorn ATOMs: KINGTHORN, THORN, THORN_WARRIOR
      * Tasty Soil: +25% Health in Forest environments
    * Undead ATOMs: ARCHER, BAT, BAT2, BLACKKNIGHT, BONEDRAGON, NECROMANT, SKELETON, VAMPIRE, VAMPIRE2, ZOMBIE, ZOMBIE2
      * +50% Defense in cemeteries (was +1 morale, but I changed it since morale does not affect the computer controlled units)
    * Underground ATOMs: SPIDER_FIRE, SPIDER_VENOM
      * SPIDER_FIRE and SPIDER_VENOM now have the Underground feature (Undead Spiders get this bonus from being Undead)
  *.LNG
    * EN(G)_BATTLE.LNG - Added new battle log labels for when spell duration is increased / decreased due to unit's resistance
    * EN(G)_HERO.LNG
      * Changed Attack hint to include:
        * Amount of attack needed to increase max damage cap and critical hit
        * Critical Hit increase per attack
        * Max Damage Cap increase per attack
        * Total Critical Hit increase
        * Max Damage Cap
      * Changed Defense hint to include:
        * Amount of defense needed to decrease min damage cap and increase resist all
        * Resist all increase per defense
        * Min Damage Cap decrease per defense
        * Total Resist all increase 
      * Changed Intellect hint to include:
        * Amount of intellect needed to increase spell power and duration
        * Amount of power increase per intellect
        * Amount of duration increase per intellect
        * Total power increase
        * Total duration increase
    * EN(G)_HOMM3_BABIES_ORCELYN.LNG
      * Changed Tyraxor's bonuses to include Shamans
      * Fixed lower case "zubin"
    * EN(G)_SKILLS.LNG - Destoyer now also increases chance of infliction (i.e. burn, poison, etc.)
    * EN(G)_SPELLS.LNG
      * Sleeping and Unconscious units always receive critical damage
      * Entangled units chance to receive a critical hit is doubled
      * Battle Cry now increases unit's morale instead of initiative
      * Haste now also increases a unit's initiative and chance to critically strike its target
      * Slow now also decreases a unit's initiative and increase its susceptibility to critical strikes
      * Stone Skin is now mass at level 3
      * Added new infliction bonus labels
      * Geyser hint now includes freeze chance
    * EN(G)_SPIRITS.LNG
      * Updated Ice Thorns description to include its new abilities
      * Added rest increases to spirit abilities where appropriate
      * Added new labels for Ice Thorns new features
      * Removed abbreviations for Orb level-up since UI now has more room
      * Added new Ice Thorn labels
      * Changed Ice Thorn levelups
    * EN(G)_UNITS.LNG
      * Updated Ice Thorns arena description
      * Updated Elf Race description
      * Updated Dwarf Race description
      * Updated Undead Race description
      * Updated Demon Race description
      * Updated Ice Thorn right-click hint to include Thorns damage and new hint
      * Added new Bone Dragon Dread morale penalty hint
    * EN(G)_UNITS_FEATURES.LNG
      * Updated Ancient Vampire's Death's Deception so that it only works 50% of the time
      * Added new Cyclops features
      * Updated Dwarf units so that they include the "Likes Dungeons" feature (with a few exceptions)
      * Updated Dwarf units so that they include the "Sea Sick" feature (with a few exceptions)
      * Updated Elf units so that they include the "Loves Forests" feature
      * Updated Elf units so that they include the "Dislikes Dungeons" feature (with a few exceptions)
      * Updated Bone Dragon to include new Dread feature
      * Removed Night Sight from Undead Spider feature list since it was redundant with their Undead feature
      * Added Underground feature to Fire Spiders and Venomous Spiders
      * Added "Likes the Forest" feature to Graywolves, Bears, and Ancient Bears
      * Added the "Tasty Soil" feature to Royal Thorns, Thorns, and Thorn Warriors
      * Added the "Throws Stones" feature to Cyclopses
      * Updated Giant Attack hint
      * Updated Ogre Attack hint
      * Added new Bone Dragon Dread hint
      * Updated Undead hint so that they gain +50% Defense in cemeteries instead of +1 Morale (since it didn't effect AI units anyway)
      * Updated Marine hint to include exact Morale increase
      * Added new Tasty Soil hint
      * Added new Likes Dungeons hint
      * Added new Likes the Forest hint
      * Added new Loves the Forest hint
      * Added new Dislikes Dungeons hint
      * Added new Sea Sick hint
    * EN(G)_UNITS_SPECIALS.LNG
      * Updated Shaman Totem hints to include Titan Energy for health and new initative parameter
      * Added new Titan Energy labels
    * EN(G)_WINDOWS.LNG - updated version number
    * TEMPLATES.LNG
      * Added new "damage" macro to hint_t0 template for displaying the Ice Thorns' "thorns" damage to attackers and for area of effect damage
      * Added the following macros to the left_t macro for displaying the new attack, defense, and intellect bonuses to the hero screen:
        * att_den - this is the amount of attack needed to increase maximum damage and unit critical hit
	* krit_inc - this is the critical hit increase per att_den attack
	* att_cap_inc - this is the maximum damage increase per att_den attack
	* att_krit - this is the total critical hit increase per hero attack
	* def_den - this is the amount of defense needed to decrease unit damage and increase unit resistance to all
	* res_inc - this is the resist all increase per def_den defense
	* def_res - this is the the actual resist all increase based on the hero's defense
	* def_dec - this is the actual damage decrease based on the hero's defense
	* int_den - this is the amount of intellect needed to increase the power of spells
	* power_inc - this is the increase in spell power per int_den
	* dur_den - this is the amount of intellect needed to increase the duration of spells
	* dur_inc - this is the increase in spell duration per dur_den
	* int_power - this is the total spell power increase based on the hero's intellect
	* int_dur - this is the total spell duration increase based on the hero's intellect
      * Added the following macros to the special_t template:
        * health_totem - lists the health of the totem, including the increase due to Titan Energy
	* health% - lists the percent of totem health based on the Shaman's health
	* titan_energy - lists how much Titan Energy is being used to increase the health of the unit
	* init_totem - lists the totem's initiative
      * Added the following macros to the int_spr_Lvlup_tAD template:
        * freeze - for the new Ice Thorns' freeze chance
	* thorns - for the new Ice Thorns' "thorns" damage
	* duration - for the new Ice Thorns' max random duration
	* freezeOld, freezeNew - for leveling up the ability
	* thornsOld, thornsNew - for leveling up the ability
      * Added the following macros to the int_spr_th0 template:
        * freeze - the freeze chance
	* thorns - the thorns percentage
      * Added the following macros to the blog_td0 template:
        * durold, durnew - new macros for the label that states when a spell / effect duration has been increased / decreased due to the target's resistance
	* restype - new macro that displays the resistance that caused the spell / effect duration to increase / decrease
      * Added the following macros to the spells_tSpell template:
        * DS04_Krit - new critical Hit increase for Haste spell
	* DS05_Krit - new Critical Hit susceptibility for Slow spell
	* DS18_Freeze - new Geyser freeze chance
  *.LUA
    * Fixed Game.Random( 100 ) errors so that the proper probability is used, files effected:
      ARENA.LUA, BOSS.LUA, PAWN.LUA, SPECIAL_ATTACKS.LUA, SPELLS.LUA, SPIRIT_LINA.LUA, UNIT_FEATURES.LUA
    * ARENA.LUA
      * Sleeping and Unconscious units always receive critical damage
      * Entangled units chance to receive a critical hit is doubled
      * Ancient Vampire's Death's Deception now only works 50% of the time
      * Slow now increases the chance of a unit receiving a critical strike from its attacker
      * The hero's attack now affects the attacker's critical hit
      * The hero's defense now affects the receiver's resistance
      * The hero's attack and defense now affect the maximum and minimum damage caps (i.e. 300% and 1/3) scaled by the attack-defence difference
      * For enemy units:
        * Since there appears to be no way of getting the enemy hero attack / defense, the enemy hero's attack / defense is computed at the beginning of combat based on the unit's current and base attack / defense after the difficulty bonus is applied.
	* If anyone knows how to get the enemy hero's attack / defense then let me know (there is a way to get the hero's intellect, but that is a special Logic library function).
	* This means that enemy units not led by an enemy hero can still potentially get:
	  * Increased Critical Hit
	  * Increased Maximum Damage Cap
	  * Decreased Minimum Damage Cap
	  * Increased Resistances
	  * Even if the unit is led by an enemy hero, the computed enemy hero attack / defense values can be quite a bit greater than the enemy hero's actual attack / defense
	  * This makes the game harder at the harder difficulty levels as the enemy units get better bonuses
      * Updated spell AI to accommodate changes to Battle Cry, Haste, and Slow
    * LOGIC_HERO.LUA
      * Leadership Reduction counters are now limited to the lr_limit value specified in CONFIG.TXT when starting a new game
    * SPECIAL_ATTACKS.LUA
      * Shaman Totem health is now a percent of the Shaman's total health
      * Shaman Totem initiative is now the same as the Shaman's base initiative + the Totem's health divided by its init_den (specified in SHAMAN.ATOM)
      * Giant Quake no longer damages Archdemons and Demonesses since they have wings (their "special" / "avoid" animations are played, respectively, instead). Note that since Giants are male humanoids that the Demoness's Beauty feature used to come into play, but now it is not needed.
    * SPECIAL_HINT.LUA
      * Updated Shaman Totem Health hint to include the Titan Energy stored on the Shaman
      * Added Shaman Totem Initiative hint
    * SPELLS.LUA
      * Freeze Immune units now have a greater possible chance of not being frozen with the Ice Snake and Geyser spells
      * Fire Immune and Demon units now have a greater possible chance of being frozen with the Ice Snake and Geyser spells
      * Ice Snake and Geyser now use a common function for determining whether units are frozen
      * Battle Cry (spell_reaction) now increases unit morale instead of initiative
      * Haste now also increases a unit's initiative and chance to critically strike its target
      * Slow now also decreases a unit's initiative and increases its susceptibility to critical strikes
      * Stone Skin is now mass at level 3
    * SPELLS_HINT.LUA
      * Updated Slow hint to include initiative reduction and increased susceptibility to critical hits
      * Updated Haste hint to include initiative increase and increased chance of critical hits
      * Added Geyser Freeze probably to hint
    * SPELLS_POWER.LUA
      * Added new dur_inc parameter
      * Added capability to show the spell / effect duration log due to the target's resistance
      * Power Slow now returns critical hit susceptibility value
      * Power Haste now returns critical hit increase value
      * Power Geyser now returns freeze chance
      * Changed how I was computing the infliction increase
    * SPIRIT_LINA.LUA
      * Implemented new functions for the Ice Thorn
    * TEXTGEN.LUA
      * Added new function to provide number descriptions to the attack, defense, and intellect tips
    * UNIT_FEATURES.LUA
      * Mind Immune createres cannot be knocked unconscious by the Giant's attack
      * The Undead can be stunned by the Ogre's attack and the Undead and Mind Immune creatures cannot be knocked unconscious
      * The Cyclop's throw attack can now stun and knock units unconscious
      * The Bone Dragon now decreases morale based on unit level
  *.PNG
    * LEVELUP_BG2_EXTENDED.PNG - New picture that allows for more room in the spirit upgrade description boxes
    * SPIRIT_LEVELUP_BUTTON_NORMAL_EXTENDED.PNG - New picture for the larger spirit upgrade description
    * SPIRIT_LEVELUP_BUTTON_ONMOUSE_EXTENDED.PNG - New picture for the larger spirit upgrade description
    * SPIRIT_LEVELUP_BUTTON_ONPRESS_EXTENDED.PNG - New picture for the larger spirit upgrade description
  *.TXT
    * CONFIG.TXT
      * New attack_config parameters
        * den - this is the hero attack divisor for computing max damage cap increase and critical hit increase
	* krit_inc - this is the amount of critical hit increase per den
	* cap_inc - this is the amount of max damage cap increase per den
      * New defense_config parameters
        * den - this is the hero defense divsor for computing min damage cap increase and resistance increase
	* res_inc - this is the increase in resist all per den
      * New hero_leadership_reduction parameter: lr_limit - this is the maximum leadership reduction counter for all units
    * HERO.TXT
      * Fixed misspelling of "spell_dispell" for Paladin and Mage heroes
    * ITEMS.TXT
      * Added sp_gain_infliction_burn to "flame_necklace" and "storm_necklace"
      * Added sp_gain_infliction_shock to "adept_staff" and "arhmage_staff" (note that it is really spelled that way)
    * ORCELYN_BABIES.TXT
      * Added Shamans to Tyraxor's bonuses
      * CRITICAL - Fixed error in Gretchen's bonus list that was causing the game to crash when Orcelyn was having babies
    * SPECIAL_PARAMS.TXT
      * Changed individual add and gain spell infliction bonuses to general effect bonuses (i.e. ..infliction_fire_arrow -> ..infliction_burn)
      * This effects bonuses in ITEMS.TXT, DIANA_BABIES.TXT, MIRABELLA_BABIES.TXT, NEOKA_BABIES.TXT, RINA_BABIES.TXT, XEONA_BABIES.TXT
    * SPELL.TXT
      * Necromancy - Added missing Sprites to Skeleton reanimate list
      * Battle Cry (spell_reaction) now increases unit morale instead of initiative
      * Haste now also increases a unit's initiative and chance to critically strike its target
      * Slow now also decreases a unit's initiative and increase its susceptibility to critical strikes
      * Stone Skin is now mass at level 3 (mana, crystals, etc. adjusted accordingly)
      * Reduced Trap base poison infliction percent to 25 (was 35)
      * Geyser now has a specified freeze chance, and increased stun chance from 10 to 15
      * Fire Arrow now has a burn chance of 20 (was 25)
      * Poison Skull now has a poison chance of 20 (was 25)
    * WIFES.TXT - Added Shaman to Orcelyn's Leadership Requirement bonus
  *.UI
    SP_LEVEL_UP.UI - Increases the size of the spirit levelup dialog to handle more text
  

Version: Beta 2012-06-21
-------------------------
* mod_homm3_babies.kfs
  * ARENA.LUA - fixed a bug where Frenzy level 2 and higher was not adding the proper amount of rage per round
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_WINDOWS.LNG - updated version number

Version: Beta 2012-06-16
-------------------------
* mod_homm3_babies.kfs
    * GERDA_BABIES.TXT - fixed where I somehow had accidentally introduced a typo into Gerda's Lorelei baby causing the game to crash when Gerda had babies

Version: Beta 2012-06-12
-------------------------
* mod_homm3_babies.kfs
  * *.ATOM
    * ENT.ATOM - added level=4 to custom parameters for its post-entangle effect
    * ENT2.ATOM
      * Added level=5 to custom parameters for its post-entangle effect
      * Increased chance of entangle to 75%
    * KINGTHORN.ATOM - added new Entangle ability
  * TEMPLATES.LNG
    * Updated "Planeswalker" baby templates
    * Added new colors for combat log skill bonuses at the start of the round
  * *.LUA
    * ARENA.LUA
      * Added capability for AI to use new Royal Thorn Entangle ability
      * Frenzy now increases the hero rage every round during combat (similar to Concentration for mana)
      * Each class now has a base mana and / or rage gain per round bonus
      * New logs for skill round bonuses
    * ITEMS_HINT.LUA
      * Fixed issues with "Planeswalker" babies elemental skill generator text
      * Finally discovered how to get a unit's level outside of combat (i.e. use Logic.cp_level) instead of having it hard coded.
    * LOGIC_HERO.LUA
      * The starting and rebirth hero army is now randomly generated from a possible list in HERO.TXT
      * The starting spells and scrolls are now randomly generated from a possible list in HERO.TXT
    * SKILLS.LUA - added new function for showing the combat rounds that the mana (Concentration) and rage (Frenzy) regeneration occur over
    * SPELLS.LUA - fixed bug where the Spell Healing damage to the Undead used the wrong bonus system
    * SPELL_EFFECTS.LUA - updated Entangle so that it also halves a units initiative
    * SPELLS_COMMON.LUA - added new unit selector for Royal Thorn Entangle ability
    * UNIT_FEATURES.LUA - updated Entangle ability not to apply to floating (soaring) units
  * *.TXT
    * DIANA_BABIES.TXT
      * Updated "Planeswalker" babies:
        * Kalt (Ice Elemental) bonus is now Physical & Poison Damage / Resistance
        * Lacus (Water Elemental) bonus is now Poison Damage / Resistance
      * Updated "Scouting" babies:
        * Piquedram's Scouting bonus is now +Rage% and +Slower% Rage Drain on Map
        * Shiva's Scouting bonus is now +Rage Inflow% and +Rage per Round
    * EFFECTS.TXT - updated Entangle ability to exclude plants as potential targets
    * FEANORA_BABIES.TXT
      * Updated "Scouting" babies:
        * Broghild's Scouting bonus is now +Rage% and +Slower% Rage Drain on Map
      * Voy "Navigation" baby - added Poison Resistance
    * GERDA_BABIES.TXT
      * Updated "Planeswalker" babies:
        * Thunar (Earth Elemental) bonus is now Physical Damage / Resistance
      * Updated "Scouting" babies:
        * Lorelei's Scouting bonus is now +Rage% and +Slower% Rage Drain on Map
    * HERO.TXT
      * Paladin and Warriors starting leadership and level-up values have been swapped such that the Paladin now leads the most troops
      * Now have a random army generation list for both starting and rebirthing (after they lose a combat)
      * Now have the cabability to randomly generate spells and scrolls based on percentages you can specify
      * Starting scroll limits updated
    * LOGIC.TXT - added new parameter for the max leadership to randomly select units when your hero loses in combat
    * MIRABELLA_BABIES.TXT
      * Leadership babies restored to previous values (i.e. Leadership Morale +1, minus one level to other skill):
        * Edric
	* Orrin
	* Sylvia
	* Haart
	* Valeska
	* Christian
	* Sorsha
	* Tyris
      * Sylvia, "Navigation" baby - added poison resistance
    * NEOKA_BABIES.TXT
      * Updated "Planeswalker" babies
        * Monere (Magic Elemental) bonus is now Magic Damage / Resistance
        * Pasis (Psychic Elemental) bonus is now Magic & Poison Damage / Resistance
      * Updated "Scouting" babies:
        * Aeris's Scouting bonus is now +Rage% and +Slower% Rage Drain on Map
    * ORCELYN_BABIES.TXT
      * Updated "Planeswalker" babies
        * Erdamon (Magma Elemental) bonus is now Physical & Fire Damage / Resistance
    * RINA_BABIES.TXT - added missing Necro Call bonus to Thant
    * SKILLS.TXT - Frenzy now adds rage per round
    * SPECIAL_PARAMS.TXT - added new rage gain per round item bonus
    * XEONA_BABIES.TXT
      * Updated "Planeswalker" babies:
        * Fiur (Energy Elemental) bonus is now Magic & Fire Damage / Resistance
        * Ignissa (Fire Elemental) bonus is now Fire Damage / Resistance
      * Updated "Scouting" babies:
        * Calh's Scouting bonus is now +Rage% and +Slower% Rage Drain on Map
        * Fiona's Scouting bonus is now +Rage%, +Slower% Rage Drain on Map, +Rage Inflow%, and +Rage per Round
        * Deemer's Scouting bonus is now +Rage%, +Rage Inflow%, and +Rage per Round (level 2)
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_BATTLE.LNG - new log templates for combat abilities at the start of the round
  * EN(G)_HOMM3_BABIES_XXX.LNG (where XXX is for each wife)
    * Updated "Planeswalker" baby generator if this wife had one of these babies
    * Updated "Armorer" baby generator to match the word (rather than just armor) so that it is consistent with all other generator names
    * Updated "Scouting" baby templates
    * Fixed lower case names in Xeona's baby file: Deemer, Malekith
  * EN(G)_SPELLS.LNG - updated Entangle description
  * EN(G)_UNITS_FEATURES.LNG
    * Updated Entangle description
    * Added "Greater Entangle" for Ancient Ent's entangle ability (affects unit levels 1-5 with a 75% chance)
  * EN(G)_UNITS_SPECIALS.LNG - updated Entangle description
  * EN(G)_WINDOWS.LNG - each class now has a base mana and / or rage generation rate
  * EN(G)_WIVES.LNG - added new generator label
* mod_homm3_portraits.kfs
  * TEX334.DAT - updated to include new ability small pictures (i.e. Royal Thorn Entangle)
  * TEX335.DAT - updated to include new ability pictures (i.e. Royal Thorn Entangle)
  * TEX334.DDS - updated to include new ability small pictures (i.e. Royal Thorn Entangle)
  * TEX335.DDS - updated to include new ability pictures (i.e. Royal Thorn Entangle)

Version: Beta 2012-04-08
-------------------------
* mod_homm3_babies.kfs
  * TEMPLATES.LNG
    * The "scouting" skill template was named incorrectly.
    * This could cause the game to lockup when cursoring over a baby that used this template.
    * The following babies were affected:
      * Feanora
        * Broghild
      * Gerda
        * Lorelei
      * Diana
        * Piquedram
	* Shiva
      * Neoka
        * Aeris
      * Xeona
        * Calh
	* Fiona
	* Deemer


Version: Beta 2012-02-25
-------------------------

* mod_homm3_babies.kfs
  * SPELLS.LUA
    * If somehow a unit is not selected from Necro Call (or Animate Dead) one will be selected at random (this is to prevent crashing in case a unit is not in the raise list)
    * Changed some of the function lists for spells associated with Enchanted Hero
    * Added new function to work with Enchanted Hero to properly apply the correct hero bonuses to the spells autocast on the unit
  * UNIT_FEATURES.LUA - fixed issues with Enchanted Hero not working correctly
  * SPELLS.TXT - CRITICAL: fixed missing units from necromancy which would cause the came to crash when cast on those units that were missing for the list


Version: Beta 2012-02-09
-------------------------

* mod_homm3_babies.kfs
  * ITEMS_HINT.LUA - fixed template generator for Xyron's spell bonus description so that it displays the spell list properly
  * SPELLS.LUA - fixed issue with the Phoenix getting its bonus to its resistances applied a second time when it resurrected itself


Version: Beta 2012-01-16
-------------------------

* mod_homm3_babies.kfs
  * ARENA.LUA - fixed error in implementation of map location bonus where I forgot to match the units with it and the difficulty bonus (the bonus was off by a factor of 100!)


Version: Beta 2012-01-14
-------------------------

* mod_homm3_babies.kfs
  * BONEDRAGON.ATOM
    * Changed Poison Cloud damage from 100-120 to 80-100


Alpha Testing Phase Complete!!!

Thanks to:

  * Fatt_Shade
  * Erkilmarl
  * saroumana

Version: Alpha 2012-01-13
-------------------------

* mod_homm3_babies.kfs
  * *.ATOM
    * Unit ATOM's
      * Removed charges for most reloadable abilities (that were added previously) due to simply disabling reloading of special attacks when the combat enters the "drudgery" phase
      * This way difficulty level affects when your units run out of their reloadable attacks and it only effects your troops
      * Charged attacks without reloads are not affected
    * ARCHDEMON.ATOM
      * Defenders no longer retaliate against the ArchDemon's attacks
      * Fixed magicstick issue with Amalgamation ability
      * As mentioned above, charges from reloadable attacks removed
    * BAT.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
    * BAT2.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
    * BEHOLDER.ATOM - now has the mage feature
    * BEHOLDER2.ATOM - now has the mage feature
    * BONEDRAGON.ATOM
      * Increased base attack damage from 50-65 to 65-80
      * Increase Poison Cloud damage from 60-80 to 100-120
      * As mentioned above, charges from reloadable attacks removed
    * DARKCRYSTAL.ATOM
      * New features (explicit immunity as well as pawn)
      * Attack now is much more powerful
      * Hitback is now much more powerful
      * Posthitslave now recharges Karrador's mana
    * DEATH.ATOM - used relative rest reduction (no functional change)
    * DRUID.ATOM - Cast Bear now has a reload of 5 (instead of 4) and as mentioned above, charges are removed
    * KINGTHORN - Cast Thorn reload is back to 4 and as mentioned above, charges are removed
    * LINA.ATOM
      * Updated Ice Thorns so that they are not as spammable at maximum level
      * Used relative rest reduction (no functional change)
    * NECROMANT.ATOM
      * Now Raise Undead (animate_dead) can permanently reanimate (resurrect) Undead troops if the hero has Necromancy
      * Raise Undead now has only 1 charge, but a charge is not consumed if it does not resurrect a troop
      * Raise Undead reload time is 3
      * Added level requirement for Raise Undead
      * As mentioned above, removed charges on other reloadable attacks
    * ORC.ATOM - added new "Ill-Tempered" feature
    * ORC2.ATOM - added new "Ill-Tempered" feature
    * PHOENIX.ATOM - new Cast Sacrifice ability
    * PHOENIX_OLD.ATOM - new Cast Sacrifice ability
    * PHOENIX_YOUNG.ATOM - new Cast Sacrifice ability
    * PRIEST.ATOM
      * Healing (cure2) now does not use the attacker's attack / defender's defense for computing damage
      * As mentioned above, charges removed from reloadable attacks
      * Healing (cure2) now has a reload time of 2
    * SLIME.ATOM - used relative rest reduction (no functional change)
    * THEROCK.ATOM - used relative rest reduction (no functional change)
    * VAMPIRE.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
    * VAMPIRE2.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
    * WEREWOLF.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
    * WOLF.ATOM - new subturn_modificator to immediately re-apply difficulty bonus to transforming troop
  * TEMPLATES.LNG
    * Added new Necromancy skill templates for unit abilities affected by it
    * Added new Necromancy spell templates for spells changed by it (Necro Call)
  * *.LUA
    * ARENA.LUA
      * Now when the battle enters the "drudgery" phase, reloadable attacks are disabled for your troops
      * Changed AI probability scoring for heal and resurrection-based abilities
      * Fixed new Priest "cure2" AI to work properly
      * Updated calls to function "necro_get_unit" to handle new function parameter list for Necro Call / Raise Undead
      * Updated AI unit scoring to include special abilities and number of targets abilities and attacks can hit
      * Added check for (Veteran) Orc critical hit received to allow their "Ill-Tempered" feature to work
      * Added check to not display the enemy hero mana regeneration message if the mana regen is 0
      * Dark Crystal health is now tied to the boss_hp difficulty level parameter
      * Unit list generated for use by Dark Crystal when summoning reinforcements
      * New function (transform_modificators) that re-applies the difficulty level bonus to transformers (this works much better than the way I did it before!)
      * The map difficulty location is an additive bonus to the difficulty bonus scaler
    * COMBAT_LOG.LUA
      * Added Necro Call resurrect hint
      * Added Phoenix Sacrifice resurrect hint
    * LOGIC_HERO.LUA - updated rune_pal comment (no functional change)
    * PAWN.LUA
      * Improved darcrystal_attack function to include new move abilities
      * Improved darkcrystal_hitback function to make it much more powerful and interesting
      * Added new darkcrystal_posthitslave function to recharge Karrador's mana when the crystal receives damage
    * SKILLS.LUA
      * Added new function "skill_power_range_dec" to handle new Necromancy skill effectiveness range
      * Fixed issue with Paladin Rune Stone ability not giving enough runes at level 2 and 3
    * SPECIAL_ATTAKCS.LUA
      * Priest "cure2" now always consumes charges
      * Updated "special_animate_dead" to resurrect Undead if hero has the Necromancy skill
      * Updated "special_ghost_cry" to do more damage if the hero has the Necromancy skill
      * When the Phoenix resurrects itself, it recharges all its abilities (i.e. Cast Sacrifice)
      * Cleaned up special_cast_thorn_sacrifice, removing code that wasn't being used
      * Added new function (special_phoenix_sacrifice) to implement new Phoenix ability
    * SPECIAL_HINT.LUA
      * Added Scream (Ghost Cry) damage hint increase if the hero has the Necromancy skill
      * Added new hint generators for Scream and Raise Undead
      * Added new hint for Phoenix Cast Sacrifice
      * Updated difficulty scaler hint to include map difficulty location
    * SPELL_EFFECTS.LUA
      * Duration of effects are now affected by the unit's magic resistance or resistance to that kind of effect (i.e. poison for effect poison)
      * The function effect_sleep_attack now applies a defense penalty to sleeping targets
      * The function effect_unconscious_attack now applies a defense penalty to sleeping targets
    * SPELLS.LUA
      * Updated belligerent check code for all spells where used to determine enemy hero level and spell level
      * Duration of spells are now affected by the unit's magic resistance or resistance to that kind of effect (i.e. poison for effect poison)
      * Updated function "necro_get_unit" to always pick the highest level undead when spell power is greater than number of units
      * Updated "spell_necromancy_attack" to handle resurrecting Undead units when hero has the Necromancy skill
      * Added new function "common_plague_attack" for applying the effects of the various Plague spells and abilities
      * The function spell_gifts_attack now removes the "Drudgery" long combat effect when used (so that the spell can be used to reload attacks after the Drudgery phase is enterred)
      * Fixed issues with lightning where it was not updating the chance of effect based on the current target
    * SPELLS_COMMON.LUA
      * Function "calccells_all_need_resurrect_ally" no longer allows selection of Undead units if hero has the Necromancy skill and is using the Resurrect Spell
      * New function "calccells_all_corpse2" for handling selection of Undead units with either Necro Call or Raise Undead and the Necromancy skill
      * New function "calccells_all_phoenix_sacrifice" for handling selection of valid resurrection targets for new Phoenix Cast Sacrifice ability
      * Function calccells_hypnosis updated to include enemy hero level in pwr_hypnosis function
      * Function calccells_sacrifice updated to include enemy hero level in pwr_sacrifice function
      * Function calccells_phantom updated to include enemy hero level in pwr_phantom function
    * SPELLS_POWER.LUA
      * For some spells, applied value limits to both lower and upper value
      * New function "res_dur" for applying resistance to alter spell or effect duration
    * SPELLS_HINT.LUA
      * Updated common hint display function
      * Updated Necro Call spell hint display funtion to show Necromancy skill bonuses
    * SPIRIT_LINA.LUA - updated mana increase function to prevent enemy units from giving your hero mana from a mana ball in rare cases
    * UNIT_FEATURES.LUA
      * New function "orc_posthitslave" to implement new (Veteran) Orc "Ill-Tempered" feature
      * Updated features_archdemon_attack to improve its implementation and add the capability to dispell beneficial spells on the target
      * Updated features_soul_drain so that it doesn't work on units of the Demon race
      * Updated features_vampirism so that it doesn't work on units of the Demon race
      * Function post_spell_dragon_slayer updated to include enemy hero level in pwr_dragon_slayer function
      * Function post_spell_demon_slayer updated to include enemy hero level in pwr_demon_slayer function
  * *.TXT
    * EFFECTS.TXT
      * Effect effect_unconscious now has a defense penalty
      * Effect effect_sleep now has a defense penalty
    * HERO.TXT - level 31 experience increased from 1 to 2 million
    * LOGIC.TXT - new difficulty scaler parameter: maplocden - now the map location difficulty adds to the difficulty scaler bonus
    * MORALE.TXT
      * Beholders and Evil Beholders add to Mega Mage
      * Removed Tolerance Morale bonus
      * Added Diplomacy Morale bonuses
    * SKILLS.TXT
      * Updated trading "trade" parameters to match skill parameters (not sure if these are used???)
      * Added second parameter to Diplomacy skill levels for the Morale bonus hint display
      * Added "Light" troop bonuses to Keeper of the Light
      * Added Resist All bonuses to Tolerance
      * Added third parameter to Runic Stone to allow proper Rune reward
      * Removed Necromancy Undead Magic Resistance bonus since they get Resist All from Tolerance
    * SPELL.TXT
      * Updated Necro Call spell unit reanimation list to allow more possibilities
      * Updated Necro Call spell to use new "calccells_all_corpse2" unit selection function
      * Updated power of spell_necromancy and derived price and mana / crystals
      * Added level requirement parameter for when Necro Call spell is used to resurrect Undead
      * Added new "dur_res_[resistance_type]" parameter for applying a unit's resistance to affect spell duration
      * The following changes were due to changing the "level model" for these spells (i.e. how does the power change from level 1 to 2, etc.)
        * Updated power of spell_stone_skin and derived price and mana / crystals
        * Updated derived parameters for spell_last_hero
        * Updated power and penalty of spell_pacifism and derived price and mana / crystals
        * Updated power of spell_dragon_slayer and derived price and mana / crystals
        * Updated power of spell_demon_slayer and derived price and mana / crystals
        * Updated power of spell_accuracy and derived price and mana / crystals
        * Updated power of spell_berserker and derived price and mana / crystals
        * Updated power of spell_shroud and derived price and mana / crystals
        * Updated power of spell_pain_mirror and derived price and mana / crystals
        * Updated power (just defense, not mana regen) of spell_magic_source and derived price and mana / crystals
        * Updated power of spell_phantom and derived price and mana / crystals
        * Updated power of spell_pygmy and derived price and mana / crystals
        * Updated power of spell_hypnosis and derived price and mana / crystals
        * Updated power of spell_oil_fog and derived price and mana / crystals
        * Updated power of spell_plague and derived price and mana / crystals
        * Updated power of spell_fire_breath and derived price and mana / crystals
        * Updated power of spell_sacrifice and derived price and mana / crystals
        * Updated power of spell_demonologist and derived price and mana / crystals
        * Updated prc_damage of spell_armageddon and derived price and mana / crystals
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_BATTLE.LNG
    * Updated drudgery combat message
    * Added new (Veteran) Orc "Get's Angry" messages for new Ill-Tempered feature
    * Added new Phoenix Sacrifice messages
    * Fixed grammar error in add_block_necro_2 message
    * Added Dark Crystal message
  * EN(G)_SKILLS.LNG
    * Updated Keeper of the Light text to include "Light Troop" bonuses
    * Updated Diplomacy to include Morale messages
    * Updated Tolerance skill to remove Morale bonus and include Resist All bonus
    * Updated Necromancy skill text to remove +Magic Resistance and reword it a bit
  * EN(G)_SPELLS.LNG
    * Updated Necro Call Necromancy skill bonus text
    * Updated Sleep description to include defense reduction
    * Updated Unconscious description to include defense reduction
  * EN(G)_UNITS.LNG - added new Diplomacy skill morale bonuses
  * EN(G)_UNITS_FEATURES.LNG
    * Added new "Ill-Tempered" feature to Orcs and Veteran Orcs
    * Added new No Retaliation to ArchDemons
    * Added new "Ill-Tempered" feature header and hint
    * Updated ArchDemon Odium hint to match current ability
  * EN(G)_UNITS_SPECIALS.LNG
    * Updated new Priest "cure2" text
    * Updated Neromancer Raise Undead text for Necromancy skill allowing Undead resurrection
    * Added new Phoenix Sacrifice name, header, and hint
    * Updated the difficulty level descriptions to include the new map location difficulty bonus


Version: Alpha 2011-12-29
-------------------------

* mod_homm3_babies.kfs
  * *.ATOM
    * GIANT.ATOM - added new Thump feature that allows the Giant to knock opponents unconscious
    * PRIEST.ATOM - added new "cure2" ability that allows the priest to heal friendlies and attack the undead
  * TEMPLATES.LNG - added new "cure2" damage hint template for Priest's new ability
  * *.LUA
    * ARENA.LUA - added AI for cure2 ability usage
    * COMBAT_LOG.LUA
      * Moved Gift of Life text messages to EN(G)_BATTLE.LNG to aid future localization efforts
      * Added custom hint for new Priest "cure2" ability to display damage and healing properly
    * SPECIAL_ATTACKS.LUA
      * Added check to Gift of Life "cast_sacrifice" to determine if temporary unit goes over hero's Leadership limit
      * New function "special_heal2" that implements the Priest's new "cure2" ability
    * SPECIAL_HINT.LUA - added new hint for Priest's "cure2" ability
    * SPELL_EFFECTS.LUA
      * Changed log name indentifier for unconscious since it is used by more than just ogres
      * New function "effect_temp_ooc" that handles temporary units going over the hero's Leadership limit
      * New function "posthitmaster_effect_temp_ooc" that aids in returning temporary units to the hero's control
      * New function "posthitslave_effect_temp_ooc" that aids in returning temporary units to the hero's control
    * SPELLS_COMMON.LUA - added new "caclcells_all_need_cure2_all" function to aid in selecting units for new Priest "cure2" ability
    * UNIT_FEATURES.LUA
      * New function "features_giant_attack" that implements the Giant's new "Thump" feature
      * Added check to Ghost "soul_drain" to determine if temporary unit goes over hero's Leadership limit
  * *.TXT
    * EFFECTS.TXT - new "effect_temp_ooc" for handling temporary units that go out of control due to being over the hero's Leadership limit
    * GERDA_BABIES.TXT - fixed error in Orwald's bonuses (+init to +speed)
    * XEONA_BABIES.TXT - removed duplicate Imp / Imp2 attack bonus from Ignatius
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_BATTLE.LNG
    * Chance unconscious log label so that it is more generic
    * Added Gift of Life text labels for future localization efforts (English text strings should not be in LUA files)
  * EN(G)_HOMM3_BABIES_NEOKA.LNG - fixed spelling error for Mephala's Armorer (armor) bonus
  * EN(G)_UNITS_FEATURES.LNG
    * Added Thump feature to Giants
    * Added Thump feature header and hint
  * EN(G)_UNITS_SPECIALS.LNG - added new Priect "cure2" ability name, header, and hint


Version: Alpha 2011-12-28
-------------------------

* mod_homm3_babies.kfs
  * *.ATOM - for virtually all reloadable abilities, they now have charges such that the abilities run out about round 15 for levels 1-3, 20 for level 4, and 25 for level 5
    * ARCHDEMON.ATOM
      * Added post-hit Odium effect
      * Added ability Amalgamation
    * CATAPULT.ATOM - new boiling_oil attack
    * DEATH.ATOM - Time Back now starts with Rest = 6
    * GOBLIN2.ATOM
      * Unit now is Furious
      * Unit now has new throw axe ability
    * OGRE.ATOM - unit has new post-hit function for "Clobbering" units
    * THEROCK.ATOM
      * Wall now has starting rest = 6
      * Quake now has starting rest = 5
  * TEMPLATES.LNG - new templates
  * *.LUA
    * ARENA.LUA
      * New function apply_long_combat_penalties - applies penalties to unit moral, then init, then speed during long combats
      * Added capability for AI Thorns to use Gift of Life on starting Thorns (instead of just level 4 and higher plants)
      * Added capability for AI to cast new Archdemon Amalgamation ability
      * Level 1-3 units with abilities should be able to go about 15 rounds before running out
      * Level 4 units should be able to go about 20 rounds before running out
      * Level 5 units should be able to go about 25 rounds before running out
    * PAWN.LUA - added difficulty leadership parameter to scale animates for Dark Crystal attack (more changes coming here later)
    * SKILLS.LUA - added Beholders / Evil Beholders Leadership Reduction to Mega Mage
    * SPECIAL_ATTACKS.LUA
      * Fixed issues with Shaman Dancing Axes
      * Added Glory scaler for leadership-based abilities
      * Fixed issue with Thorn Gift of Life and cell passability after its use
      * New Archdemon special_amalgamation function for its new ability
    * SPECIAL_HINT.LUA
      * Added "res" to parameter list for Catapult Boiling Oil attack
      * Added Glory bonus for leadership-based abilities
      * Updated Charge / Reload label so that it works with combined Charged-Reloadable abilities
    * SPELL_EFFECTS.LUA
      * Added new effect_unconscious_attack function for new Ogre Clobber feature
      * Added new unconscious_onremove function for new Ogre Clobber feature
    * SPELLS.LUA
      * Updated baby Phoenix and Evil Book bonuses so that fewer parameters are hard coded
      * Updated spell_defenseless to handle Archdemon's post-hit effect
      * Updated spell_pygmy to handle Archdemon's Amalgamation ability
      * Updated spell_blind to handle Archdemon's Amalgamation ability
      * Updated spell_ram to handle Archdemon's Amalgamation ability
    * SPELLS_COMMON.LUA
      * Fixed calccells_hypnosis so that it uses its power function properly during unit selection
      * New calccells_enemy_special_amalgamation for selecting targets for Archdemon's new ability
      * Added Glory leadership-based ability bonus during unit selection
    * SPELLS_HINT.LUA - removed hard-coded values for kid bonuses to Phoenix and Evil Book
    * SPELLS_POWER.LUA
      * New "Holy" bonus description
      * New Glory bonus description
    * UNIT_FEATURES.LUA
      * New features_ogre_attack for Ogre's new post-hit Clobber ability
      * New features_archdemon_attack for Archdemon's new post-hit Odium ability
      * Update to features_burn to added Catapult's new Boiling Oil ability
      * Added reset for Gizmo's priority for regeneration ability
  * *.TXT
    * *_BABIES.TXT - babies with HOMM3 Myticism now have double mana regeneration during combat (i.e. 1->2 and 2->4)
    * EFFECTS.TXT - new effects:
      * Unconscious
      * Burning Oil
    * LOGIC.TXT - comment updated
    * NEOKA_BABIES.TXT - missed Ice Serpent duration bonus
    * SKILLS.TXT
      * Dark Commander - Added Dragons
      * Glory - Added increase to Leadership-based Spells and Abilities
      * Mega Mage - Added Beholders / Evil Beholders
    * SPELLS.TXT - various spells updated to include their damage type keyword for future items that increase a specific damage type
      * spell_last_hero updated mana cost / crystals due to other spell changes
      * spell_gifts - increased price, mana, and crystals
      * spell_hypnosis - updated spell power, price, and mana / crystals to account for error in power calculation during selection
    * WIFES.TXT - added missing Fire spider Leadership Bonus to Xeona
    * XEONA_BABIES.TXT
      * Xyron now gives bonuses to Fire Arrow / Ball / Rain
      * Xarfax now gives bonuses to Fire Ball
      * Inteus now gives bonuses to Fire Rain
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_BATTLE.LNG
    * Added plural of Sheep to add missing label
    * Added Archdemon new ability / feature labels
    * Added Ogre new feature labels
    * Added new long combat labels
  * EN(G)_HOMM3_BABIES_NEOKA.LNG - fixed spelling error in Josephine's label that caused game lockup
  * EN(G)_HOMM3_BABIES_XEONA.LNG
    * Xyron now gives bonuses to Fire Arrow / Ball / Rain
    * Xarfax now gives bonuses to Fire Ball
    * Inteus now gives bonuses to Fire Rain
  * EN(G)_SKILLS.LNG
    * Dark Commander - updated text to include Dragons
    * Glory - updated text to include leadership-based spells and abilities
    * Healer - updated text so that Phantom is now included in the list
    * Mega Mage - updated text to include Beholders / Evil Beholders
    * Necromancy - updated text to improve readability.
  * EN(G)_SPELLS.LNG
    * New Holy Spell bonus label
    * New Glory Spell bonus label
    * New effect Burning Oil label and description
    * New effect Unconscious label and description
  * EN(G)_SPIRITS.LNG - adding missing Rage Cost for Rage Gain upgrades
  * EN(G)_UNIT_FEATURES
    * Updated Furious Goblin features
    * Updated Ogre features
    * Fixed spelling error in Vampire / Vampire2 Regeneration feature
    * Updated Archdemon features
    * Added new Clobber feature
    * Updated Chaos description
    * Added new Odium feature
  * EN(G)_UNIT_SPECIALS.LNG
    * Updated Shaman Dancing Axes description
    * Added new Boiling Oil label and description
    * Added new Throw Axe label and description
    * Added new Amalgamation label and description
    * Added new Amalgamation warning
* mod_homm3_portraits.kfs
  * TEX334.DAT - updated to include new ability small pictures
  * TEX335.DAT - updated to include new ability pictures
  * TEX334.DDS - updated to include new ability small pictures
  * TEX335.DDS - updated to include new ability pictures
* mod_tougher_heroes.kfs
  * 978705779.hero - fixed errors in hero parameters for Tiberius

Version: Alpha 2011-12-10
-------------------------

* mod_homm3_babies.kfs
  * BONEDRAGON.ATOM
    * Added new header and hint for Bone Dragon's new attack
    * Added new posthitmaster script for the Bone Dragon's new attack
  * CATAPULT.ATOM
    * Ranged attack ranged penalty removed
    * Increase to resistances:
      * Physical: +20 (now is 20)
      * Poison: +20 (now is 20)
  * GOBLIN.ATOM - increase to resistances:
    * Fire: +5 (now is 5)
    * Physical: +5 (now is 5)
    * Poison: +5 (now is 5)
  * GOBLIN2.ATOM - increase to resistances:
    * Fire: +5 (now is 5)
    * Physical: +5 (now is 5)
    * Poison: +5 (now is 5)
  * OGRE.ATOM - increase to resistances:
    * Fire: +10 (now is 20)
    * Physical: +10 (now is 20)
    * Poison: +10 (now is 20)
  * ORC.ATOM - increase to resistances:
    * Fire: +10 (now is 10)
    * Poison: +10 (now is 10)
  * ORC2.ATOM - increase to resistances:
    * Fire: +15 (now is 15)
    * Physical: +5 (now is 15)
    * Poison: +15 (now is 15)
  * SHAMAN.ATOM - increase to resistances:
    * Fire: +10 (now is 10)
    * Physical: +10 (now is 10)
    * Poison: +10 (now is 10)
  * TOTEM_DEATH.ATOM - description describes that damage is magic, but damage was physical.
    * Damage type changed to magic
  * TEMPLATES.LNG
    * Added new templates for Shaman's Dancing Axes attack
  * PAWN.LUA - no changes, just beautified the code a little bit
  * SPECIAL_ATTACKS.LUA
    * Changed how Shaman's Dancing Axes works:
      * 80% of damage becomes "Titan Energy" that resurrects friendly Orc troops
      * 80% of the remaining Titan Energy not used by resurrecting friendly Orc troops heals other friendly troops
      * 80% of the remaining Titan Energy not used by healing friendly troops is stored on the Shaman for use later
      * The 20% dissipation only occurs if the energy is used at that step:
        * I.e. if there are no friendly Orc troops to heal then 20% of the energy is not lost
	* I.e. if there are no friendly troops to heal then 20% of the energy is not lost
	* I.e. at the beginning of combat no one is typically hurt yet, so 80% of the damage is stored on the Shaman as Titan Energy in this case
      * The Titan Energy stored on the Shaman dissipates 20% each round until one of its abilities is used again
      * If the Shaman casts one of its Totems, then 80% of the energy is used to increase the health of the totem with 20% dissipating and being stored on the Shaman.
    * This change is HIGHLY experimental and may make Orcs too powerful - we'll have to playtest to see...
  * SPECIAL_HINT.LUA - updated the Shaman's Dancing Axes hint
  * SPELLS.LUA - needed to change the following function's argument lists (due to Bone Dragon's new attack):
    * spell_scare_attack - added target
    * spell_weakness_attack - added target
    * spell_crue_fate_attack - added target
    * spell_ram_attack - added target
  * UNIT_FEATURES.LUA
    * New function features_bonedragon_attack that implements the new Bone Dragon posthit attack
    * New function features_dissipate_energy that implements the new Shaman Titan Energy dissipation
  * SKILLS.TXT
    * Training - the Defense increase has been moved to Combat Readiness
    * Combat Readiness - see above
  * WIFE_NAME_BABIES.TXT - this refers to all the wife baby files:
    * Babies with the HOMM3 Scouting Ability:
      * Now get these variants:
        * +Rage% and +Rage Inflow% (if only 1 child from wife they get this one)
	* +Rage% (x2 above) (if mother has more than 1 child)
	* +Rage Inflow% (x2 above) (if mother has more than 1 child)
    * Babies with the HOMM3 Tactics Skill now have these variants:
      * +Attack / Defense (same as before)
      * -Enemy Speed or -Enemy Initiative (depends on number of babies under wife)
      * -Enemy Speed and -Initiative (if baby had Advanced Tactics - Lacus is the only one)
    * Babies with Necromancy (pretty much all Rina's babies)
      * If the baby had a bonus to an undead unit, the Necromany Skill was changed to increase the level of their other skill by 1
      * Some other babies with Necromancy left alone
      * I.e. Charna had Necromancy, Tactics, and Wights (Wights -> Ghosts) and so her Necromancy became Advanced Tactics
      * I.e. Sandro (Rina) stays the same
      * I.e. Young Sandro (Feanora) gets Expert Sorcery (only baby with Expert Sorcery)!
      * This makes Rina's children a little bit more varied:
        * Babies are more useful if you want to use other units with her
	* Lessens the focus on her for getting so many undead units
    * Babies with HOMM3 Leadership (a lot of Mirabella's babies)
      * Similar to Necromancy, to prevent so many morale bonuses, the babies other skill increased a level
      * Helps give fewer morale bonuses from Mirabella's babies so that you can't get as much +morale (but get other bonuses instead)
      * Gives a bit more variety to her children
      * Sylvia's Leadership to Expert Navigation
      * Haart's Leadership to Expert Estates
    * Babies with HOMM3 Mysticism now get +2 or +4 mana per round instead of +1 or +2 per round (2x)
    * Babies with HOMM3 Navigation:
      * Bonus now applies to Forest and Snow combat as well (babies affected: Voy and Sylvia)
    * Babies with HOMM3 Eagle Eye now have the varients:
      * Intellect: +%
      * Enemy Resistance: -% (based on mother's resistance, i.e. Gerda would be -Resist All)
    * Babies with HOMM3 Offense or Archery:
      * Now they need at least Advanced skill level for +1 to damage type
      * Now they need Expert level for +2 to damage type
      * +Damage bonus stays the same
    * Babies with HOMM3 Scholar - bonus has been halved
  * WIFES.TXT - fixed misspelling in Mirabella's footman Leadership Reduction bonus
* mod_homm3_babies_en(g)_lng.kfs
  * EN(G)_BATTLE.LNG
    * Added new logs:
      * Bone Dragon's new attack
      * Modified logs related to Shaman's Dancing Axes attack
  * EN(G)_SKILLS.LNG
    * Updated Training description
    * Updated Combat Readiness description
  * EN(G)_UNITS_FEATURES.LNG
    * Added Bone Dragon's Chaos feature
  * EN(G)_UNITS_SEPCIALS.LNG
    * Changed Shaman's Dancing Axes description
  * EN(G)_HOMM3_BABIES_WIFE.LNG - refers to all the wife babies *.LNG files
    * Skill templates changed to match changes to skills
    * New skill templates used for skill variants
  * EN(G)_WIVES.LNG - added new variants for the child alternate HOMM3 skill bonuses

Version: Alpha 2011-12-01
-------------------------

* mod_homm3_babies.kfs
  * LINA.ATOM
    * Ice Orb now starts with 200 health (this is standard, was 150)
    * Ice Orb health upgrades adjusted to match new health
  * ORB.ATOM
    * Ice Orb now only starts with 30% Physical Resistance (was 80%)
    * Ice Orb now only starts with -100% Fire Resistance (was -50%)
  * TEMPLATES.LNG - changed some of the templates for Lina's Ice Orb upgrade
  * SPIRIT_HINTS.LUA - updated Ice Orb hints to match changes
  * SPIRIT_LINA.LUA
    * Ice Orb now has +Defense, Physical, and Fire Resistance for defense upgrades
    * This change makes it so that Ice Orb is not as powerful at the start, but will still get to the same power at its highest level
* mod_homm3_babies_en(g)_lng.kfs
  * en(g)_chat_1315394584_0068736578.lng - somehow when I moved the *.LNG files into separate KFS files, I omitted this file, which is needed for Diana's dialog
  * en(g)_chat_1315394584_0076798669.lng - somehow when I moved the *.LNG files into separate KFS files, I omitted this file, which is needed for Diana's dialog


Version: Alpha 2011-11-26
-------------------------

* mod_homm3_babies.kfs
  * GHOST.ATOM - percent drain restored to 30% (was 100%)
  * GHOST2.ATOM - percent drain restored to 50% (was 100%)
  * UNIT_FEATURES.LUA - Soul Drain now increases units by the lower of amount killed and Ghost health divided into damage
  * SKILLS.TXT - updated the Necromancy Skill
    * Adds to Defense / Health / Magic Resistance @ values of 5, 10, and 15% for Levels 1, 2, 3
    * Everything else remains the same
* mod_homm3_babies_en(g)_lng.kfs (this refers to both KFS *.LNG files)
  * EN(G)_SKILLS.LNG - updated the Necromancy Skill text

Version: Alpha 2011-11-26
-------------------------

* mod_homm3_babies.kfs
  * UNIT_FEATURES.LUA
    * Ghosts Soul Drain now increases units by the amount of units killed instead of damage
    * Thanks to Fatt_Shade for suggesting this!
  For all the wife_babies text files thanks to both Fatt_Shade and Erkilamrl!
  * FEANORA_BABIES.TXT - fixed some child bonus errors
  * GERDA_BABIES.TXT - fixed some child bonus errors
  * MIRABELLA_BABIES.TXT - fixed some child bonus errors
  * XEONA_BABIES.TXT - fixed some child bonus errors

Updates:

Version: Alpha 2011-11-25
-------------------------

Updates:

* mod_homm3_babies.kfs
  * UNIT_FEATURES.LUA
    * Fixed the massive damage bug in the implementation of one of the Enchanted Hero spell casts.
    * Removed that from the bugs list below.
    * This is a *HUGE* buxfix and I've been trying to track this down for months and finally found it - yay!
  * SPELLS.TXT - fixed Enchanted Hero so it cannot be cast on the Undead or Plants
  * WIFES.TXT - fixed Mirabella's missing Griffin morale bonus - thanks Fatt_Shade!

Version: Alpha 2011-11-23
-------------------------

Updates:

* New KFS Organization - *.LNG files are in their own KFS (ZIP)
  * mod_homm3_babies_eng_lng.kfs - contains the ENG_*.LNG English Language Localization files
  * mod_homm3_babies_en_lng.kfs - contains the EN_*.LNG English Language Localization files
  * The files are collectively refered to as mod_homm3_babies_en(g)_lng.kfs.
* mod_homm3_babies_en(g)_lng.kfs (this refers to both KFS *.LNG files)
  * EN(G)_SPELLS.LNG - fixed a few spells descriptions that were incorrect
  * EN(G)_HOMM3_BABIES_RINA.LNG - updated baby descriptors for Vidomina, Lord (Death) Haart, Isra, Thant, and Finneas.
  * EN(G)_SKILLS.LNG - updated Glory skill description
* mod_homm3_babies.kfs
  * NECROMANT.ATOM - experimental change making all 3 of the Necromancer's skills reloadable (kind of more like the Human Archmage).
  * TEMPLATES.LNG - removed Necro Call bonus for Necromancy Skill Template
  * SKILLS.LUA - commented out the sp_lead_unit bonuses for all Undead units
  * SPELLS.LUA - code cleanup
  * SKILLS.TXT
    * Corrected a few skill values - thanks to Fatt_Shade for the Dark Commander errors!
    * Glory's Leadership Reduction Requirement no longer applies to Undead since it is in the Paladin tree.
    * Ranged Specialist - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%).
    * Archmage - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%).
    * Necromancy - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%)
  * SPECIAL_PARAMS.TXT - commented out the sp_lead_(group) bonuses since they are now longer used
  * SPELLS.TXT - updated mana_cost for a few spells for ARENA.LUA - spell_auto_cast function that AI uses
  * RINA_BABIES.TXT - made some minor tweaks to some of her babies (Vidomina, Lord (Death) Haart, Isra, Thant, and Finneas).
  * WIFES.TXT - Zombie Rina didn't have Black Knights in her Undead sp_lead_unit bonuses.
  * XEONA_BABIES.TXT - fixed an error with Dace - thanks to Fatt_Shade for finding this!
* mod_tougher_eheroes.kfs
  * 276213879.hero - error in Martin Vodash's attack value (was 5 should have been 8)

Version: Alpha 2011-11-19
-------------------------

Fixes:

* LOGIC_HERO.LUA had an error in it where for Easy and Normal difficulty level, the level up didn't work correctly.

Thanks to erkki (Erkilmarl) for helping find and fix this bug!

Changes:

* Updated Sleem's Cloud of Poison such that the early levels mana increase is less and for the 2nd upgrade you need Sleem to be higher level to get it.
  & I recently updated Sleem's Cloud of Poison before restarting my new game and as I played the previous values didn't feel right.

Additions:

* I've added the en_ language files for those users of the game with the alternate English locality files.

Version: Alpha 2011-11-13
-------------------------

Crash Fixes:

* Rina had a mispelling in one of her child names in wifes.txt. This would cause a crash to desktop when Rina was having a baby.

Version: Alpha 2011-11-11
-------------------------

This archive contains all the files for the HOMM3 Babies mod / micro / mini expansion pack for King's Bounty: The Legend. This work will be referred to loosely as the mod in the rest of this document.

There are many changes to the game, but at this time I do not have them listed here. In the future, this file will list those changes. In the mean time, visit the YouTube video page: http://youtu.be/JE0VbSnfYkM and ***NOTE: This Forum is No Longer Available*** the King's Bounty: The Legend Mod forum for more information: http://forum.1cpublishing.eu/showthread.php?p=360731#post360731.


