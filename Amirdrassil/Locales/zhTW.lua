local L = BigWigs:NewBossLocale("Gnarlroot", "zhTW")
if not L then return end
if L then
	L.tortured_scream = "尖嘯"
end

L = BigWigs:NewBossLocale("Igira the Cruel", "zhTW")
if L then
	L.blistering_spear = "長矛"
	L.blistering_spear_single = "長矛"
	--L.blistering_torment = "Chain"
	L.twisting_blade = "旋刃"
	L.marked_for_torment = "折磨"
	L.umbral_destruction = "分攤"
	L.heart_stopper = "治療吸收盾"
	L.heart_stopper_single = "治療吸收盾"
end

L = BigWigs:NewBossLocale("Volcoross", "zhTW")
if L then
	--L.custom_off_all_scorchtail_crash = "Show All Casts"
	--L.custom_off_all_scorchtail_crash_desc = "Show timers and messages for all Scorchtail Crash casts instead of just for your side."

	L.flood_of_the_firelands = "分攤"
	--L.flood_of_the_firelands_single_wait = "Wait" -- Wait 3, Wait 2, Wait 1 countdown before soak debuff is applied
	--L.flood_of_the_firelands_single = "Soak"
	L.scorchtail_crash = "甩尾"
	L.serpents_fury = "噴火"
	L.coiling_flames_single = "烈焰纏繞" -- 烈焰纏繞，噴完火纏身上的，要不叫烤焦吧......
end

L = BigWigs:NewBossLocale("Council of Dreams", "zhTW")
if L then
	--L.agonizing_claws_debuff = "{421022} (Debuff)"

	L.ultimate_boss = "滿能量 (%s)"
	--L.special_bar = "Ult [%s] (%d)"
	--L.special_mythic_bar = "Ult [%s/%s] (%d)"
	--L.special_mechanic_bar = "%s [Ult] (%d)"

	L.poisonous_javelin = "標槍" -- 或者中毒/緩速
	L.song_of_the_dragon = "頌歌"
	L.polymorph_bomb = "鴨子"
	L.polymorph_bomb_single = "鴨子"
end

L = BigWigs:NewBossLocale("Larodar, Keeper of the Flame", "zhTW")
if L then
	L.custom_on_repeating_yell_smoldering_suffocation = "重覆悶燃窒息喊話"
	L.custom_on_repeating_yell_smoldering_suffocation_desc = "當你中了悶燃窒息並且生命值低於 75%，持續喊話以引起隊友注意。"

	L.blazing_coalescence_on_player_note = "在你身上"
	L.blazing_coalescence_on_boss_note = "在王身上"

	L.scorching_roots = "樹根"
	--L.blazing_thorns = "Dodges"
	L.falling_embers = "接圈"
end

L = BigWigs:NewBossLocale("Nymue, Weaver of the Cycle", "zhTW")
if L then
	--L.mythic_add_death = "%s Killed"

	L.continuum = "新的矩陣"
	--L.surging_growth = "New Soaks"
	--L.ephemeral_flora = "Red Soak"
	L.viridian_rain = "翠綠之雨" -- 原名比較短
	--L.threads = "Threads" -- From the spell description of Impending Loom (429615) "threads of energy"
end

L = BigWigs:NewBossLocale("Smolderon", "zhTW")
if L then
	L.brand_of_damnation = "坦克分攤"
	L.lava_geysers = "岩漿"
end

L = BigWigs:NewBossLocale("Tindral Sageswift, Seer of the Flame", "zhTW")
if L then
	L.seed_soaked = "踩種子" -- 之後看一下語序
	L.all_seeds_soaked = "種子踩完了！"
	L.blazing_mushroom = "蘑菇"
	L.fiery_growth = "驅散"
	L.mass_entanglement = "藤蔓"
	L.incarnation_moonkin = "梟獸型態"
	L.incarnation_tree_of_flame = "樹人型態"
	L.flaming_germination = "種子" -- 手冊寫焰種
	L.suppressive_ember = "治療吸收盾"
	L.suppressive_ember_single = "治療吸收盾"
	L.flare_bomb = "羽毛"
end

L = BigWigs:NewBossLocale("Fyrakk the Blazing", "zhTW")
if L then
	L.spirits_trigger = "卡多雷之魂"

	L.fyralaths_bite = "正面衝擊波"
	L.fyralaths_bite_mythic = "正面衝擊波"
	L.fyralaths_mark = "印記"
	L.darkflame_shades = "影子"
	L.darkflame_cleave = "分攤"

	L.incarnate_intermission = "擊飛"

	L.incarnate = "升空"
	L.molten_gauntlet = "重拳" -- 熔火護手是什麼鬼翻譯......
	--L.mythic_debuffs = "Cages" -- Shadow Cage & Molten Eruption

	L.greater_firestorm_shortened_bar = "強效火颶" -- 中文技能名短，先按原文來
	L.greater_firestorm_message_full = "強效火颶"
	L.eternal_firestorm_shortened_bar = "永恆火颶"
	L.eternal_firestorm_message_full = "永恆火颶"

	-- L.eternal_firestorm_swirl = "Eternal Firestorm Swirls"
	-- L.eternal_firestorm_swirl_desc = "Timers for Eternal Firestorm Swirls."
	-- L.eternal_firestorm_swirl_bartext = "Swirls"
end
