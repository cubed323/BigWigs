--[[
TODO:
	bugged Arcing Lightning, expect a spellId or name change for this once they fix the ability ( not fixed in 10 N ptr )
]]--

if select(4, GetBuildInfo()) < 50200 then return end
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Iron Qon", 930, 817)
if not mod then return end
mod:RegisterEnableMob(68078, 68079, 68080, 68081) -- Iron Qon, Ro'shak, Quet'zal, Dam'ren

--------------------------------------------------------------------------------
-- Locals
--


--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.molten_energy = "Molten Energy"
	L.molten_energy_desc = EJ_GetSectionInfo(6973)
	L.molten_energy_icon = 137221

	L.overload_casting = "Molten Overload casting"
	L.overload_casting_desc = "Warning for when Molten Overload is casting"
	L.overload_casting_icon = 137221
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"ej:6914", 136520, 139180,
		"ej:6877", {137669, "FLASH"}, {136192, "ICON", "PROXIMITY"}, 77333,
		137221, "overload_casting", {"ej:6870", "PROXIMITY"}, "ej:6871", {137668, "FLASH"},
		{134926, "FLASH", "SAY"}, "molten_energy", "berserk", "bosskill",
	}, {
		["ej:6914"] = "ej:6867", -- Dam'ren
		["ej:6877"] = "ej:6866", -- Quet'zal
		[137221] = "ej:6865", -- Ro'shak
		[134926] = "general",
	}
end

function mod:OnBossEnable()
	-- Dam'ren
	self:Log("SPELL_DAMAGE", "FrozenBlood", 136520)
	self:Log("SPELL_CAST_SUCCESS", "DeadZone", 137226, 137227, 137228, 137229, 137230, 137231) -- figure out why it has so many spellIds
	-- Quet'zal
-- the bugged Arcing Lightning, expect a spellId or name change for this once they fix the ability
--1/18 02:39:13.776  SPELL_AURA_APPLIED,0xF15109F000002837,"Quet'zal",0x10a48,0x0,0x02000000000038DB,"Calebh",0x511,0x80,136192,"Lightning Storm",0x8,DEBUFF
	self:Log("SPELL_AURA_APPLIED", "ArcingLightningApplied", 136192)
	self:Log("SPELL_AURA_REMOVED", "ArcingLightningRemoved", 136192)
	self:Log("SPELL_DAMAGE", "StormCloud", 137669)
	self:Log("SPELL_AURA_APPLIED", "Windstorm", 136577)
	-- Ro'shak
	self:Log("SPELL_DAMAGE", "BurningCinders", 137668)
	self:Log("SPELL_AURA_APPLIED", "Scorched", 134647)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Scorched", 134647)
	self:Log("SPELL_AURA_APPLIED", "MoltenOverloadApplied", 137221)
	self:Log("SPELL_AURA_REMOVED", "MoltenOverloadRemoved", 137221)
	-- General
	self:Log("SPELL_SUMMON", "ThrowSpear", 134926)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1", "boss2", "boss3", "boss4", "boss5")

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Deaths", 68078, 68079, 68080, 68081)
end

function mod:OnEngage()
	self:Berserk(600) -- confirmed for 10 normal
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "PowerWarn", "boss2")
	self:OpenProximity("ej:6870", 10)
	self:CDBar(134926, 33) -- Throw spear
	if self:Heroic() then
		self:Bar(77333, 17) -- Whirling Winds
		self:Bar(136192, 20) -- Arcing Lightning
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Dam'ren

do
	local prev = 0
	function mod:FrozenBlood(args)
		if not UnitIsUnit(args.destName, "player") then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:Message(args.spellId, "Personal", "Info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:DeadZone(args)
	self:Message("ej:6914", "Attention", nil, args.spellId)
	self:Bar("ej:6914", 16, args.spellId)
end

-- Quet'zal

function mod:ArcingLightningApplied(args)
	self:PrimaryIcon(args.spellId, args.destName)
	self:TargetMessage(args.spellId, args.destName, "Urgent") -- no point for sound since the guy stunned can't do anything
	self:Bar(args.spellId, (self:mobId(UnitGUID("boss2")) == 68079) and 40 or 20) -- Ro'shak is there aka Heroic p1 then 40 else 20
end

function mod:ArcingLightningRemoved(args)
	self:PrimaryIcon(args.spellId)
end

do
	local prev = 0
	function mod:StormCloud(args)
		if not UnitIsUnit(args.destName, "player") then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:Message(args.spellId, "Personal", "Info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:Windstorm(args)
	if not UnitIsUnit("player", args.destName) then return end
	self:Message("ej:6877", "Attention", nil, args.spellId) -- lets leave it here to warn people who fail and step back into the windstorm
end

-- Ro'shak

do
	local prev = 0
	function mod:BurningCinders(args)
		if not UnitIsUnit(args.destName, "player") then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:Message(args.spellId, "Personal", "Info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:Scorched(args)
	args.amount = args.amount or 1
	if args.amount > 4 and UnitIsUnit(args.destName, "player") then
		self:Message("ej:6871", "Important", nil, ("%s (%d)"):format(args.spellName, args.amount), args.spellId)
	end
	if self:Heroic() and self:mobId(UnitGUID("boss4")) == 68081 then -- Dam'ren is active and heroic
		self:Bar("ej:6870", 16, 134628) -- Unleashed Flame
	else
		self:CDBar("ej:6870", 6, 134628) -- XXX Unleashed Flame - don't think there is any point to this, maybe coordinating personal cooldowns?
	end
end

do
	local prevPower = 0
	function mod:MoltenOverloadRemoved()
		prevPower = 0
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "PowerWarn", "boss2")
	end
	function mod:PowerWarn(unitId)
		if unitId ~= "boss2" then return end
		local power = UnitPower(unitId)
		if power > 64 and prevPower == 0 then
			prevPower = 65
			self:Message("molten_energy", "Attention", nil, ("%s (%d%%)"):format(L["molten_energy"], power), 137221)
		elseif power > 74 and prevPower == 65 then
			prevPower = 75
			self:Message("molten_energy", "Urgent", nil, ("%s (%d%%)"):format(L["molten_energy"], power), 137221)
		elseif power > 84 and prevPower == 75 then
			prevPower = 85
			self:Message("molten_energy", "Important", nil, ("%s (%d%%)"):format(L["molten_energy"], power), 137221)
		elseif power > 94 and prevPower == 85 then
			prevPower = 95
			self:Message("molten_energy", "Important", nil, ("%s (%d%%)"):format(L["molten_energy"], power), 137221)
		end
	end
end

function mod:MoltenOverloadApplied(args)
	self:Message("overload_casting", "Important", "Alert", args.spellId)
	self:Bar("overload_casting", 10, CL["cast"]:format(args.spellName), args.spellId) -- XXX don't think there is any point to this, maybe coordinating raid cooldowns?
	self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss2")
end

-- General

function mod:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, _, _, spellId)
	if spellId == 139172 then -- Whirling Wind
		self:Message(77333, "Attention")
		self:Bar(77333, 30)
	elseif spellId == 139181 then -- Frost Spike
		self:Message(139180, "Attention")
		self:CDBar(139180, 13)
	elseif spellId == 137656 then -- Rushing Winds - start Wind Storm bar here, should be more accurate then unitaura on player
		self:Message("ej:6877", "Positive", nil, CL["over"]:format(self:SpellName(136577)), 136577) -- Wind Storm
		self:Bar("ej:6877", 70, 136577) -- Wind Storm
	elseif spellId == 50630 then -- Eject All Passangers aka heroic phase change
		if unit == "boss2" then -- Ro'shak
			self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss2")
			self:CloseProximity("ej:6870")
			self:StopBar(137221) -- Molten Overload
			self:StopBar(134628) -- Unleashed Flame
			self:Bar("ej:6877", 50, 136577) -- Windstorm
			self:Bar(136192, 17) -- Arcing Lightning -- XXX not sure if it has to be restarted here for heroic
			self:OpenProximity(136192, 8) -- Arcing Lightning -- assume 8 yards
			self:StopBar(77333) -- Whirling Wind
		elseif unit == "boss3" then
			self:StopBar(136577) -- Windstorm
			self:StopBar(136192) -- Arcing Lightning
			self:CloseProximity(136192)
			self:OpenProximity("ej:6870", 10)
			self:Bar("ej:6914", 7, 137226) -- Dead Zone
			self:StopBar(139180) -- Frost Spike
			self:CDBar("ej:6870", 17, 134628)
		elseif unit == "boss4" then
			self:StopBar(134628) -- Unleashed Flame
			self:StopBar(137226) -- Dead zone
			self:OpenProximity(136192, 8) -- Arcing Lightning -- assume 8 yards
		end
	end
end

do
	local timer, fired = nil, 0
	local function spearWarn(spellId)
		fired = fired + 1
		local player = UnitName("boss2target")
		if player and (not UnitDetailedThreatSituation("boss2target", "boss2") or fired > 13) then
			-- If we've done 14 (0.7s) checks and still not passing the threat check, it's probably being cast on the tank
			mod:TargetMessage(spellId, player, "Urgent", "Alarm")
			mod:CancelTimer(timer)
			timer = nil
			if UnitIsUnit("boss2target", "player") then
				mod:Flash(spellId)
				mod:Say(spellId, CL["say"]:format(mod:SpellName(spellId)))
			end
			return
		end
		-- 19 == 0.95sec
		-- Safety check if the unit doesn't exist
		if fired > 18 then
			mod:CancelTimer(timer)
			timer = nil
		end
	end
	function mod:ThrowSpear(args)
		self:CDBar(args.spellId, 33)
		fired = 0
		if not timer then
			timer = self:ScheduleRepeatingTimer(spearWarn, 0.05, args.spellId)
		end
	end
end

function mod:Deaths(args)
	if args.mobId == 68079 and not self:Heroic() then -- Ro'shak
		self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss2")
		self:CloseProximity("ej:6870")
		self:StopBar(137221) -- Molten Overload
		self:StopBar(134628) -- Unleashed Flame
		self:Bar("ej:6877", 50, 136577) -- Windstorm
		self:Bar(136192, 17, 136192) -- Arcing Lightning
		self:OpenProximity(136192, 8) -- Arcing Lightning -- assume 8 yards
	elseif args.mobId == 68080 then -- Quet'zal
		if not self:Heroic() then
			self:StopBar(136577) -- Windstorm
			self:StopBar(136192) -- Arcing Lightning
			self:Bar("ej:6914", 7, 137226) -- Dead Zone
		end
		self:CloseProximity(136192)
	elseif args.mobId == 68081 then -- Dam'ren
		self:StopBar(137226) -- Dead zone
	elseif args.mobId == 68078 then -- Iron Qon
		self:Win()
	end
end
