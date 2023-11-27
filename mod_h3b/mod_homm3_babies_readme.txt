Heroes of Might and Magic 3 Babies (HOMM3 Babies) Mod / Micro / Mini Expansion Pack for King's Bounty: The Legend
-----------------------------------------------------------------------------------------------------------------

Created by: Matt Caspermeyer (matt.caspermeyer@cox.net)
-------------------------------------------------------

You are free to use any part of my work in your projects so long as you give me credit.


Version: Alpha 2011-12-10
-------------------------

* mod_homm3_babies.kfs
  & BONEDRAGON.ATOM
    ^ Added new header and hint for Bone Dragon's new attack
    ^ Added new posthitmaster script for the Bone Dragon's new attack
  & CATAPULT.ATOM
    ^ Ranged attack ranged penalty removed
    ^ Increase to resistances:
      % Physical: +20 (now is 20)
      % Poison: +20 (now is 20)
  & GOBLIN.ATOM - increase to resistances:
    ^ Fire: +5 (now is 5)
    ^ Physical: +5 (now is 5)
    ^ Poison: +5 (now is 5)
  & GOBLIN2.ATOM - increase to resistances:
    ^ Fire: +5 (now is 5)
    ^ Physical: +5 (now is 5)
    ^ Poison: +5 (now is 5)
  & OGRE.ATOM - increase to resistances:
    ^ Fire: +10 (now is 20)
    ^ Physical: +10 (now is 20)
    ^ Poison: +10 (now is 20)
  & ORC.ATOM - increase to resistances:
    ^ Fire: +10 (now is 10)
    ^ Poison: +10 (now is 10)
  & ORC2.ATOM - increase to resistances:
    ^ Fire: +15 (now is 15)
    ^ Physical: +5 (now is 15)
    ^ Poison: +15 (now is 15)
  & SHAMAN.ATOM - increase to resistances:
    ^ Fire: +10 (now is 10)
    ^ Physical: +10 (now is 10)
    ^ Poison: +10 (now is 10)
  & TOTEM_DEATH.ATOM - description describes that damage is magic, but damage was physical.
    ^ Damage type changed to magic
  & TEMPLATES.LNG
    ^ Added new templates for Shaman's Dancing Axes attack
  & PAWN.LUA - no changes, just beautified the code a little bit
  & SPECIAL_ATTACKS.LUA
    ^ Changed how Shaman's Dancing Axes works:
      % 80% of damage becomes "Titan Energy" that resurrects friendly Orc troops
      % 80% of the remaining Titan Energy not used by resurrecting friendly Orc troops heals other friendly troops
      % 80% of the remaining Titan Energy not used by healing friendly troops is stored on the Shaman for use later
      % The 20% dissipation only occurs if the energy is used at that step:
        $ I.e. if there are no friendly Orc troops to heal then 20% of the energy is not lost
	$ I.e. if there are no friendly troops to heal then 20% of the energy is not lost
	$ I.e. at the beginning of combat no one is typically hurt yet, so 80% of the damage is stored on the Shaman as Titan Energy in this case
      % The Titan Energy stored on the Shaman dissipates 20% each round until one of its abilities is used again
      % If the Shaman casts one of its Totems, then 80% of the energy is used to increase the health of the totem with 20% dissipating and being stored on the Shaman.
    ^ This change is HIGHLY experimental and may make Orcs too powerful - we'll have to playtest to see...
  & SPECIAL_HINT.LUA - updated the Shaman's Dancing Axes hint
  & SPELLS.LUA - needed to change the following function's argument lists (due to Bone Dragon's new attack):
    ^ spell_scare_attack - added target
    ^ spell_weakness_attack - added target
    ^ spell_crue_fate_attack - added target
    ^ spell_ram_attack - added target
  & UNIT_FEATURES.LUA
    ^ New function features_bonedragon_attack that implements the new Bone Dragon posthit attack
    ^ New function features_dissipate_energy that implements the new Shaman Titan Energy dissipation
  & SKILLS.TXT
    ^ Training - the Defense increase has been moved to Combat Readiness
    ^ Combat Readiness - see above
  & WIFE_NAME_BABIES.TXT - this refers to all the wife baby files:
    ^ Babies with the HOMM3 Scouting Ability:
      % Now get these variants:
        % +Rage% and +Rage Inflow% (if only 1 child from wife they get this one)
	% +Rage% (x2 above) (if mother has more than 1 child)
	% +Rage Inflow% (x2 above) (if mother has more than 1 child)
    ^ Babies with the HOMM3 Tactics Skill now have these variants:
      % +Attack / Defense (same as before)
      % -Enemy Speed or -Enemy Initiative (depends on number of babies under wife)
      % -Enemy Speed and -Initiative (if baby had Advanced Tactics - Lacus is the only one)
    ^ Babies with Necromancy (pretty much all Rina's babies)
      % If the baby had a bonus to an undead unit, the Necromany Skill was changed to increase the level of their other skill by 1
      % Some other babies with Necromancy left alone
      % I.e. Charna had Necromancy, Tactics, and Wights (Wights -> Ghosts) and so her Necromancy became Advanced Tactics
      % I.e. Sandro (Rina) stays the same
      % I.e. Young Sandro (Feanora) gets Expert Sorcery (only baby with Expert Sorcery)!
      % This makes Rina's children a little bit more varied:
        $ Babies are more useful if you want to use other units with her
	$ Lessens the focus on her for getting so many undead units
    ^ Babies with HOMM3 Leadership (a lot of Mirabella's babies)
      % Similar to Necromancy, to prevent so many morale bonuses, the babies other skill increased a level
      % Helps give fewer morale bonuses from Mirabella's babies so that you can't get as much +morale (but get other bonuses instead)
      % Gives a bit more variety to her children
      % Sylvia's Leadership to Expert Navigation
      % Haart's Leadership to Expert Estates
    ^ Babies with HOMM3 Mysticism now get +2 or +4 mana per round instead of +1 or +2 per round (2x)
    ^ Babies with HOMM3 Navigation:
      % Bonus now applies to Forest and Snow combat as well (babies affected: Voy and Sylvia)
    ^ Babies with HOMM3 Eagle Eye now have the varients:
      % Intellect: +%
      % Enemy Resistance: -% (based on mother's resistance, i.e. Gerda would be -Resist All)
    ^ Babies with HOMM3 Offense or Archery:
      % Now they need at least Advanced skill level for +1 to damage type
      % Now they need Expert level for +2 to damage type
      % +Damage bonus stays the same
    ^ Babies with HOMM3 Scholar - bonus has been halved
  & WIFES.TXT - fixed misspelling in Mirabella's footman Leadership Reduction bonus
* mod_homm3_babies_en(g)_lng.kfs
  & EN(G)_BATTLE.LNG
    ^ Added new logs:
      % Bone Dragon's new attack
      % Modified logs related to Shaman's Dancing Axes attack
  & EN(G)_SKILLS.LNG
    ^ Updated Training description
    ^ Updated Combat Readiness description
  & EN(G)_UNITS_FEATURES.LNG
    ^ Added Bone Dragon's Chaos feature
  & EN(G)_UNITS_SEPCIALS.LNG
    ^ Changed Shaman's Dancing Axes description
  & EN(G)_HOMM3_BABIES_WIFE.LNG - refers to all the wife babies *.LNG files
    ^ Skill templates changed to match changes to skills
    ^ New skill templates used for skill variants
  & EN(G)_WIVES.LNG - added new variants for the child alternate HOMM3 skill bonuses

Version: Alpha 2011-12-01
-------------------------

* mod_homm3_babies.kfs
  & LINA.ATOM
    ^ Ice Orb now starts with 200 health (this is standard, was 150)
    ^ Ice Orb health upgrades adjusted to match new health
  & ORB.ATOM
    ^ Ice Orb now only starts with 30% Physical Resistance (was 80%)
    ^ Ice Orb now only starts with -100% Fire Resistance (was -50%)
  & TEMPLATES.LNG - changed some of the templates for Lina's Ice Orb upgrade
  & SPIRIT_HINTS.LUA - updated Ice Orb hints to match changes
  & SPIRIT_LINA.LUA
    ^ Ice Orb now has +Defense, Physical, and Fire Resistance for defense upgrades
    ^ This change makes it so that Ice Orb is not as powerful at the start, but will still get to the same power at its highest level
* mod_homm3_babies_en(g)_lng.kfs
  & en(g)_chat_1315394584_0068736578.lng - somehow when I moved the *.LNG files into separate KFS files, I omitted this file, which is needed for Diana's dialog
  & en(g)_chat_1315394584_0076798669.lng - somehow when I moved the *.LNG files into separate KFS files, I omitted this file, which is needed for Diana's dialog


Version: Alpha 2011-11-26
-------------------------

* mod_homm3_babies.kfs
  & GHOST.ATOM - percent drain restored to 30% (was 100%)
  & GHOST2.ATOM - percent drain restored to 50% (was 100%)
  & UNIT_FEATURES.LUA - Soul Drain now increases units by the lower of amount killed and Ghost health divided into damage
  & SKILLS.TXT - updated the Necromancy Skill
    ^ Adds to Defense / Health / Magic Resistance @ values of 5, 10, and 15% for Levels 1, 2, 3
    ^ Everything else remains the same
* mod_homm3_babies_en(g)_lng.kfs (this refers to both KFS *.LNG files)
  & EN(G)_SKILLS.LNG - updated the Necromancy Skill text

Version: Alpha 2011-11-26
-------------------------

* mod_homm3_babies.kfs
  & UNIT_FEATURES.LUA
    ^ Ghosts Soul Drain now increases units by the amount of units killed instead of damage
    ^ Thanks to Fatt_Shade for suggesting this!
  For all the wife_babies text files thanks to both Fatt_Shade and Erkilamrl!
  & FEANORA_BABIES.TXT - fixed some child bonus errors
  & GERDA_BABIES.TXT - fixed some child bonus errors
  & MIRABELLA_BABIES.TXT - fixed some child bonus errors
  & XEONA_BABIES.TXT - fixed some child bonus errors

Updates:

Version: Alpha 2011-11-25
-------------------------

Updates:

* mod_homm3_babies.kfs
  & UNIT_FEATURES.LUA
    ^ Fixed the massive damage bug in the implementation of one of the Enchanted Hero spell casts.
    ^ Removed that from the bugs list below.
    ^ This is a *HUGE* buxfix and I've been trying to track this down for months and finally found it - yay!
  & SPELLS.TXT - fixed Enchanted Hero so it cannot be cast on the Undead or Plants
  & WIFES.TXT - fixed Mirabella's missing Griffin morale bonus - thanks Fatt_Shade!

Version: Alpha 2011-11-23
-------------------------

Updates:

* New KFS Organization - *.LNG files are in their own KFS (ZIP)
  & mod_homm3_babies_eng_lng.kfs - contains the ENG_*.LNG English Language Localization files
  & mod_homm3_babies_en_lng.kfs - contains the EN_*.LNG English Language Localization files
  & The files are collectively refered to as mod_homm3_babies_en(g)_lng.kfs.
* mod_homm3_babies_en(g)_lng.kfs (this refers to both KFS *.LNG files)
  & EN(G)_SPELLS.LNG - fixed a few spells descriptions that were incorrect
  & EN(G)_HOMM3_BABIES_RINA.LNG - updated baby descriptors for Vidomina, Lord (Death) Haart, Isra, Thant, and Finneas.
  & EN(G)_SKILLS.LNG - updated Glory skill description
* mod_homm3_babies.kfs
  & NECROMANT.ATOM - experimental change making all 3 of the Necromancer's skills reloadable (kind of more like the Human Archmage).
  & TEMPLATES.LNG - removed Necro Call bonus for Necromancy Skill Template
  & SKILLS.LUA - commented out the sp_lead_unit bonuses for all Undead units
  & SPELLS.LUA - code cleanup
  & SKILLS.TXT
    ^ Corrected a few skill values - thanks to Fatt_Shade for the Dark Commander errors!
    ^ Glory's Leadership Reduction Requirement no longer applies to Undead since it is in the Paladin tree.
    ^ Ranged Specialist - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%).
    ^ Archmage - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%).
    ^ Necromancy - Leadership Reduction values are now -2, -5, and -10% (was -5, -10, and -15%)
  & SPECIAL_PARAMS.TXT - commented out the sp_lead_(group) bonuses since they are now longer used
  & SPELLS.TXT - updated mana_cost for a few spells for ARENA.LUA - spell_auto_cast function that AI uses
  & RINA_BABIES.TXT - made some minor tweaks to some of her babies (Vidomina, Lord (Death) Haart, Isra, Thant, and Finneas).
  & WIFES.TXT - Zombie Rina didn't have Black Knights in her Undead sp_lead_unit bonuses.
  & XEONA_BABIES.TXT - fixed an error with Dace - thanks to Fatt_Shade for finding this!
* mod_tougher_eheroes.kfs
  & 276213879.hero - error in Martin Vodash's attack value (was 5 should have been 8)

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

There are many changes to the game, but at this time I do not have them listed here. In the future, this file will list those changes. In the mean time, visit the YouTube video page: http://youtu.be/JE0VbSnfYkM and the King's Bounty: The Legend Mod forum for more information: http://forum.1cpublishing.eu/showthread.php?p=360731#post360731.


Installation:
-------------

1. This mod is not compatible with any other mods since I've most likely modified a file that another mod uses.
  a. You will need to remove all mods from your King's Bounty: The Legend "mods" folder before installation of this mod.
  b. Ensure that the "mods" folder exists, it is typically located here: C:\Program Files (x86)\1C Company\King's Bounty\data\mods
    i. If the "mods" folder does not exist then create it below the "data" folder using the path above as a guide.
2. Extract the 4 *.KFS files included in this archive to the King's Bounty: The Legend folder.
  a. This folder is typically here: C:\Program Files (x86)\1C Company\King's Bounty\data\mods
  b. If the "mods" folder does not exist, then see note 1ai above.
  c. The 4 KFS files are:
    i.   mod_homm3_portraits.kfs - stand alone game picture resources containing all *.DAT and *.DDS files that may be used in other mods.
    ii.  mod_tougher_eheroes.kfs - stand alone tougher heroes containing all *.HERO files that may be used in other mods.
    iii. mod_homm3_babies.kfs - core HOMM3 babies mod files containing all *.ACT, *.ATOM, *.CHAT, *.LUA, and *.TXT files modified for this mod.
    iv.  mod_homm3_babies_eng_lng.kfs ***OR*** mod_homm3_babies_en_lng.kfs - updated *.LNG files
      1) Use mod_homm3_babies_eng_lng.kfs for your English localization with eng_*.lng
      2) Use mod_homm3_babies_en_lng.kfs for your English localization with en_*.lng
      3) DO NOT USE BOTH FILES!!! Just one or the other!!!
  d. All 4 KFS files are needed for the complete HOMM3 babies mod experience!
3. Run the game
  a. Start a new game to play!
  b. It is not recommended to continue your current game, please restart.
  c. For your first play through:
    i.   Please do not use any cheats (i.e. Save Game Scanner, etc.)
    ii.  Please do not use with any other mods (probably won't work anyway)
    iii. You'll be able to experience the mod as I intended it to be played.


Uninstallation:
---------------

1. Simply delete the 3 KFS files from your "mods" folder:
  a. mod_homm3_portraits.kfs
  b. mod_tougher_eheroes.kfs
  c. mod_homm3_babies.kfs
2. Done!


Notes:
------

1. This mod was developed using the Gamer's Gate V1.7 version of King's Bounty: The Legend.
2. I have not tried it with other versions.
3. This mod uses the English localizations using both the "eng_" and "en_" prefixes for the localization files.
  a. As mentioned above, only one of those files is needed to play the game.
  b. Other versions may have other prefixes and so you may be able to get this mod to work with your localization version by changing the prefixes of the *.LNG localization files.
    i.   The *.LNG files are located inside mod_homm3_babies_en_lng.kfs or mod_homm3_babies_eng_lng.kfs both file sets are identical so either may be used as a baseline.
    ii.  Simply rename *.kfs to *.zip and extract files if you wish to attempt this.
    iii. Currently, you're on your own if you want to get it to work with a different localization, but if you'd like to help with localizations in your country then please let me know.


Issues / Bugs:
--------------

Since this is an alpha release of this mod, it is quite possible that your game with crash or you'll find bugs in this mod. Please provide me feedback on any issues that you are having with my mod so that I can make improvements and make your playing experience more enjoyable.

If you have any problems during play, here are some pointers:

1. If it is a game crash, note which action caused the crash.
2. If the game appears to lock up, ALT-TAB back to Windows to see if there is a pop-up.
  a. If there is a pop-up window, note the message and then click OK to proceed.
  b. After you click OK, the game will most likely crash exit to Windows.
  c. If the game does not crash after you click OK, it is highly recommended to quit your game rather than continue since behavior may be strange.
3. Save your game often just in case!
4. If the game crashes right after a battle and you've asked your wife for children then it is due to a spelling error in one of that wife's children.
  a. I just ran into this problem where I had a mispelling in one of Rina's children.

Crash List
----------

1. I've had crashes with a failure to allocate more memory a couple of times.
  a. The solution is to reload your most recent save game and simply continue.
  b. Let me know if you see this problem, but currently I have no idea how to resolve it (I probably would need 1CC or Katauri Interactive's help with this one).

Bug List - there is one bug that I'm not sure if I've squished or not:
--------

1. Damage causing effects (i.e. burning and poison):
  a. If an AI unit is killed by a damage causing effect and if the next unit to move is another AI unit, then their damage causing effect is skipped if they have one.
  b. I worked and worked trying to fix this bug, but to no avail.
    i.  I'm pretty sure that it is a bug with the game itself as I don't think they intended for damaging effects to kill units.
    ii. As such, I don't know how to fix this bug, but if you have any ideas then please let me know!

If you notice any other problems or issues, then please let me know!

It is my intent to make this mod as bug free and enjoyable as possible!


Updates:
--------

1. As this version of the mod is in an alpha state, there are still changes that are being done; however:
  a. The mod is stable enough to play the game completely through - enjoy!
  b. Every change has been checked at least once, but I'm in the quality assurance phase rechecking the code.
  c. I'm about to start a new Paladin game to check gameplay some more.
2. At this stage, changes should not require you to restart your game - simply install the new files and continue playing.
3. Updates will most likely occur on a bi-monthly basis depending on severity and other factors.
4. Once the quality assurance phase is completed and sufficient feedback is garnered, the project will transition to the beta release phase.
5. The beta release phase will have all features properly implemented and all controllable bugs fixed.
  a. Changes will be focused on editing data files (i.e. *.ATOM, *.TXT) to improve game balance and user enjoyability.
  b. Once the beta phase has garnered sufficient feedback, the project will transition to the official release phase - more information on that once the beta phase is reached.


Modders:
--------

1. I've made many changes under the hood that only modders or code aficionados would notice.
2. I've added comments where warranted to the areas in the game that I've changed.
  a. Feel free to look at these comments and provide me feedback if you know of a better way to implement something.
  b. Certain comments have the word "HACK" where I did not know how to do it a better way - once again if you know a better way to implement this feature then please let me know!
3. I've unified many *.LUA functions (i.e. like SPELLS_POWER.LUA) so that they all use the same bonus system, etc.
4. I've made common functions for dealing with redundant code.
  a. The original *.LUA files had lots and lots of redundant code.
  b. I've replaced most of the redundant code in the *.LUA functions I've edited to reduce error and provide code consistency.
5. I've beautified the sections of the *.LUA files I've changed to make reading the code much, much easier.
6. The changes I've made really form the basis of a new code base from which you can create new mods.


Copyright Issues:
-----------------

1. This work contains images from the Heroes of Might and Magic 3 game and those images are copyrighted.
2. The picture for Orcelyn Ordy I found via the web, but I have not been able to find out who created that source image.
  a. If you have any information about who created this picture please let me know and I'll give credit to the author.
3. I created all the new ability icons.
4. All of my effort is being freely distributed to the public domain.
  a. Please give me credit if you use any portion of my work in your projects - thanks! :-)
  b. Feel free to use this code base as a starting point for your own mod!


THANK YOU!!!
------------

1. Thanks to all the people posting in the King's Bounty forums, especially those with modding tips!
2. Thanks for trying out my mod and providing feedback!


/C\/C\ Matt Caspermeyer
