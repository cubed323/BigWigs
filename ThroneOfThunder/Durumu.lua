--[[
TODO:
	figure out/verify real lingering gaze range
	there are no CLEU events for blue and red ray controllers as of 10 N PTR, so keep an eye out for these
	verify that red ray controller gets 3 debuffs too with same names
	somehow verify overall life drain duration
	figure out where to start ForceOfWill in the DisintegrationBeam phase
]]--
if select(4, GetBuildInfo()) < 50200 then return end
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Durumu the Forgotten", 930, 818)
if not mod then return end
mod:RegisterEnableMob(68036)

--------------------------------------------------------------------------------
-- Locals
--
local forceOfWill = mod:SpellName(136932)
local blueRayController, redRayController = nil, nil
local pName = UnitName("player")
local redAddLeft = 3
local lifedranJumps = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.rays_spawn = "Rays spawn"
	L.ray_controller = "Ray controller"
	L.ray_controller_desc = "Announce the ray direction controllers for the red and blue rays."
	L.ray_controller_icon = 22581 -- hopefully some fitting icon
	L.red_ray_controller = "You are the |c000000FFBlue|r ray controller"
	L.blue_ray_controller = "You are the |c00FF0000Red|r ray controller"
	L.red_spawn_trigger = "The Infrared Light reveals a Crimson Fog!"
	L.blue_spawn_trigger = "The Blue Rays reveal an Azure Eye!"
	L.red_add = "|c00FF0000Red|r add"
	L.blue_add = "|c000000FFBlue|r add"
	L.clockwise = "Clockwise"
	L.counter_clockwise = "Counter clockwise"
	L.death_beam = "Death beam"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{133767, "TANK"}, {133765, "TANK_HEALER"}, {138467, "PROXIMITY", "FLASH"}, {136932, "FLASH"}, {"ej:6891", "FLASH"}, "ej:6898", "ej:6892",
		{133798, "ICON"}, "ej:6882", 140502,
		"berserk", "bosskill",
	}, {
		[133767] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Log("SPELL_PERIODIC_DAMAGE", "EyeSore", 140502)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "DisintegrationBeam", "boss1")
	self:Log("SPELL_AURA_REMOVED", "LifeDrainRemoved", 133798)
	self:Log("SPELL_AURA_APPLIED", "LifeDrainApplied", 133798)
	self:Log("SPELL_AURA_APPLIED", "RedRayController", 133732) -- this is the stacking debuff, because there is no similar CLEU like the for blue
	self:Log("SPELL_AURA_APPLIED_DOSE", "RedRayController", 133732)
	self:Log("SPELL_AURA_APPLIED", "BlueRayController", 133675) -- this is the one that keept racks of you being in ray
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:Log("SPELL_CAST_SUCCESS", "ForceOfWill", 136932)
	self:Log("SPELL_DAMAGE", "LingeringGazeDamage", 134044)
	self:Log("SPELL_CAST_START", "LingeringGaze", 138467)
	self:Log("SPELL_CAST_START", "HardStare", 133765) -- the reason we have this too is to help healers pre shield, and if shield fully absorbs, Serious Wound does not happen
	self:Log("SPELL_AURA_APPLIED_DOSE", "SeriousWound", 133767) -- this is for the tanks
	self:Log("SPELL_AURA_APPLIED", "SeriousWound", 133767)
	self:Death("Deaths", 68036, 69052, 69050) -- Boss, Blue add, Red add
end

function mod:OnEngage()
	self:Berserk(600) -- XXX Assumed
	self:CDBar(138467, 15) -- Lingering Gaze
	self:Bar(136932, 31, forceOfWill)
	blueRayController, redRayController = nil, nil
	redAddLeft = 3
	lifedranJumps = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:EyeSore(args)
		if not UnitIsUnit(args.destName, "player") then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:Message(args.spellId, "Personal", "Info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:DisintegrationBeam(_, spellName, _, _, spellId)
	if spellId == 136316 then -- clokwise
		self:Message("ej:6892", "Attention", nil, ("%s - |c00008000%s|r"):format(L["death_beam"], L["clockwise"]), 133778)
	elseif spellId == 133775 then -- counter clokwise
		self:Message("ej:6892", "Attention", nil, ("%s - |c00FF0000%s|r"):format(L["death_beam"], L["counter_clockwise"]), 133778)
	end
end

function mod:LifeDrainRemoved(args)
	self:PrimaryIcon(args.spellId)
end

function mod:LifeDrainApplied(args)
	self:PrimaryIcon(args.spellId, args.destName)
	lifedranJumps = lifedranJumps + 1
	self:TargetMessage(args.spellId, args.destName, "Important", "Alert", ("%s - %d%%"):format(args.spellName, lifedranJumps*60)) -- maybe this should just be the amount of jumps
end

function mod:RedRayController(args)
	-- since CLEUs are messed up, we count the amount of debuffs with same name to determine the ray controller
	-- 3 debuffs with same name means you are the controller
	local amount = 0
	for i=1, 100 do
		if UnitDebuff("player", i) == self:SpellName(133732) then -- XXX verify that the method used for blue works for red too
			amount = amount + 1
		end
	end
	if amount == 3 and redRayController ~= pName then -- try not warn if we know already that we are the controller
		redRayController = pName
		self:Message("ray_controller", "Attention", "Long", L["red_ray_controller"], args.spellId) -- can't be "Personal" cuz that'd make it too blue
	elseif amount ~= 3 then
		redRayController = nil -- we are not the ray controller
	end
end

function mod:BlueRayController(args)
	-- since CLEUs are messed up, we count the amount of debuffs with same name to determine the ray controller
	-- 3 debuffs with same name means you are the controller
	local amount = 0
	for i=1, 100 do
		if UnitDebuff("player", i) == self:SpellName(133675) then
			amount = amount + 1
		end
	end
	if amount == 3 and blueRayController ~= pName then -- try not warn if we know already that we are the controller
		blueRayController = pName
		self:Message("ray_controller", "Attention", "Long", L["blue_ray_controller"], args.spellId) -- can't be "Personal" cuz that'd make it too blue
	elseif amount ~= 3 then
		blueRayController = nil -- we are not the ray controller
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(_, msg, sender, _, _, target)
	if msg:find("134124") then -- Yellow
		self:StopBar(136932) -- Force of Will -- XXX double check if this is not too early to stop the bar
		self:Bar("ej:6891", L["rays_spawn"], 10, "inv_misc_gem_variety_02") -- only spawn this bar in one of the functions
		if UnitIsUnit("player", target) then
			self:Message("ej:6891", "Positive", "Alert", CL["you"]:format("|c00FFFF00"..sender.."|r"), 134124)
		end
	elseif msg:find("134123") then -- Red
		if UnitIsUnit("player", target) then
			self:Message("ej:6891", "Positive", "Alert", CL["you"]:format("|c00FF0000"..sender.."|r"), 134123)
		end
	elseif msg:find("134122") then -- Red
		if UnitIsUnit("player", target) then
			self:Message("ej:6891", "Positive", "Alert", CL["you"]:format("|c000000FF"..sender.."|r"), 134122)
		end
	elseif msg:find("133795") then -- HungryEyeStart this is faster than CLEU
		self:TargetMessage(133798, target, "Important", "Alert")
		self:Bar(133798, 15, CL["cast"]:format(self:SpellName(133798))) -- XXX somehow verify overall 15 sec duration
		self:PrimaryIcon(133798, target)
	elseif msg:find(L["red_spawn_trigger"]) then
		self:Message("ej:6892", "Urgent", nil, L["red_add"], 136154)
	elseif msg:find(L["blue_spawn_trigger"]) then
		self:Message("ej:6898", "Urgent", nil, L["blue_add"], 136177)
	end
end


function mod:ForceOfWill(args)
	if UnitIsUnit("player", args.destName) then
		self:Message(args.spellId, "Personal", "Long", CL["you"]:format(args.spellName))
	else
		self:Message(args.spellId, "Attention")
	end
	self:Bar(args.spellId, 20)
end

do
	local prev = 0
	function mod:LingeringGazeDamage(args)
		if not UnitIsUnit(args.destName, "player") then return end
		local t = GetTime()
		if t-prev > 1 then -- use 1 sec instead of the usual 2, getting out this fast matters
			prev = t
			self:Message(138467, "Personal", "Info", CL["underyou"]:format(args.spellName))
			self:Flash(138467)
		end
	end
end

do
	local function closeLingeringProximity(spellId)
		mod:CloseProximity(spellId)
	end
	function mod:LingeringGaze(args)
		self:Message(args.spellId, "Urgent", "Alarm")
		self:CDBar(args.spellId, 25)
		self:OpenProximity(args.spellId, 8) -- EJ says 15 but looks lot less
		self:ScheduleTimer(closeLingeringProximity, 3, args.spellId) -- cast is 2 sec according to tooltip, but lets add an extra sec for travel time
	end
end

function mod:HardStare(args)
	self:Bar(args.spellId, 12)
end

function mod:SeriousWound(args)
	args.amount = args.amount or 1
	self:StackMessage(args.spellId, args.destName, args.amount, "Attention", "Info")
end

function mod:Deaths(args)
	if args.mobId == 68036 then -- Boss
		self:Win()
	elseif args.mobId == 69050 then -- Red add
		redAddLeft = redAddLeft - 1
		if redAddLeft == 0 then
			self:Bar("ej:6892", 27, L["death_beam"], 133778)
		else
			self:Message("ej:6892", "Urgent", nil, ("%s (%d)"):format(L["red_add"], redAddLeft), 136154)
		end
	end
end
