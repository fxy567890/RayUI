local R, L, P, G = unpack(select(2, ...)) --Import: Engine, Locales, ProfileDB, GlobalDB
local UF = R:GetModule("UnitFrames")
local oUF = RayUF or oUF

--Cache global variables
--Lua functions
local tinsert = table.insert
local max = math.max

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPVP = UnitIsPVP

function UF:Construct_PlayerFrame(frame, unit)
    frame.mouseovers = {}
    frame.UNIT_WIDTH = self.db.units[unit].width
    frame.UNIT_HEIGHT = self.db.units[unit].height

    frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT)
    frame.Health = self:Construct_HealthBar(frame, true, true)
    frame.Power = self:Construct_PowerBar(frame, true, true)
    frame.Name = self:Construct_NameText(frame)
    frame.Mouseover = self:Construct_Highlight(frame)
    frame.ThreatHlt = self:Construct_Highlight(frame)
    frame.PvP = self:Construct_PvPIndicator(frame)
    frame.QuestIcon = self:Construct_QuestIcon(frame)
    frame.RaidIcon = self:Construct_RaidIcon(frame)
    frame.Combat = self:Construct_CombatIndicator(frame)
    frame.Resting = self:Construct_RestingIndicator(frame)

    self:EnableHealPredictionAndAbsorb(frame)

    frame.Health.value:Point("TOPRIGHT", frame.Health, "TOPRIGHT", -8, -2)
    frame.Power.value:Point("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -8, 2)

    if self.db.healthColorClass then
        frame:Tag(frame.Name, "[RayUF:name] [RayUF:info]")
    else
        frame:Tag(frame.Name, "[RayUF:color][RayUF:name] [RayUF:info]")
    end

    if self.db.showPortrait then
        frame.Portrait = self:Construct_Portrait(frame)
    end

    if self.db.castBar then
        local castbar = self:Construct_CastBar(frame)
        castbar:ClearAllPoints()
        castbar:Point("BOTTOM",R.UIParent,"BOTTOM",0,305)
        castbar:Width(self.db.units[unit].castbar.width)
        castbar:Height(self.db.units[unit].castbar.height)
        castbar.Iconbg:Size(max(self.db.units[unit].castbar.height, 20))
        if self.db.units[unit].castbar.showicon then
            castbar.Iconbg:Show()
        else
            castbar.Iconbg:Hide()
        end
        castbar.Iconbg:ClearAllPoints()
        if self.db.units[unit].castbar.iconposition == "LEFT" then
            castbar.Iconbg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMLEFT", -5, 0)
        else
            castbar.Iconbg:SetPoint("BOTTOMLEFT", castbar, "BOTTOMRIGHT", 5, 0)
        end
        castbar.Text:ClearAllPoints()
        castbar.Text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 5, -2)
        castbar.Time:ClearAllPoints()
        castbar.Time:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", -5, -2)

        castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")
        castbar.SafeZone:SetDrawLayer("OVERLAY", 5)
        castbar.SafeZone:SetTexture(R["media"].normal)
        castbar.SafeZone:SetVertexColor(1, 0, 0, 0.75)

        R:CreateMover(castbar, "PlayerCastBarMover", L["施法条锚点"], true, nil, "ALL,RAID")
        frame.Castbar = castbar
    end

    frame.Debuffs = self:Construct_Debuffs(frame)
    frame.Debuffs["growth-x"] = "LEFT"
    frame.Debuffs["growth-y"] = "UP"
    frame.Debuffs.initialAnchor = "BOTTOMRIGHT"
    frame.Debuffs:Point("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 8)

    frame.Fader = self:Construct_Fader(frame)

    frame.ClassIcons = self:Construct_ClassBar(frame)
    frame.ClassBar = "ClassIcons"

    if R.myclass == "DEATHKNIGHT" then
        frame.Runes = self:Construct_DeathKnightResourceBar(frame)
        frame.ClassBar = "Runes"
    elseif R.myclass == "DRUID" then
        frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
    elseif R.myclass == "MONK" then
        frame.Stagger = self:Construct_Stagger(frame)
    elseif R.myclass == "PRIEST" then
        frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
    elseif R.myclass == "SHAMAN" then
        frame.AdditionalPower = self:Construct_AdditionalPowerBar(frame)
    end
    frame.USE_CLASSBAR = true
    frame.MAX_CLASS_BAR = 0

    if UF.db.aurabar then
        frame.AuraBars = self:Construct_AuraBarHeader(frame)
        frame.AuraBars:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 33)
        frame.AuraBars:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 33)
    end
end

tinsert(UF["unitstoload"], "player")
