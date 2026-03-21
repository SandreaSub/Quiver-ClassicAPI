local Api = require "Api/Index.wow.lua"
local Const = require "Constants.pure.lua"
local FrameLock = require "Events/FrameLock.wow.lua"

local MODULE_ID = "AspectTracker"
local store = nil---@type StoreAspectTracker
local frame = nil

local DEFAULT_ICON_SIZE = 40
local INSET = 5
local TRANSPARENCY = 0.5

local chooseIconTexture = function()
	if Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Beast"]) then
		return Const.Icon.Aspect_Beast
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Cheetah"]) then
		return Const.Icon.Aspect_Cheetah
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Fox"]) then
		return Const.Icon.Aspect_Fox
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Monkey"]) then
		return Const.Icon.Aspect_Monkey
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Viper"]) then
		return Const.Icon.Aspect_Viper
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Wild"]) then
		return Const.Icon.Aspect_Wild
	elseif Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Wolf"]) then
		return Const.Icon.Aspect_Wolf
	elseif Api.Spell.PredSpellLearned(Quiver.L.Spell["Aspect of the Hawk"])
		and not Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Hawk"])
		or not Quiver_Store.IsLockedFrames
	then
		return Const.Icon.Aspect_Hawk
	else
		return nil
	end
end

-- ************ UI ************
local updateUI = function()
	local activeTexture = chooseIconTexture()
	if activeTexture then
		frame.Icon:SetTexture(activeTexture)
		frame.Icon:Show()
	else
		frame.Icon:Hide()
	end

	-- Exclude Pack from main texture, since party members can apply it.
	-- I don't have a simple way of detecting who cast it, because
	-- the cancellable bit is 1 even if a party member cast it.
	local alpha = Api.Aura.PredBuffActive(Quiver.L.Spell["Aspect of the Pack"]) and 1.0 or 0.0
	frame:SetBackdropBorderColor(0.7, 0.8, 0.9, alpha)

	if UnitOnTaxi("player") and Quiver_Store.IsLockedFrames then
		frame:Hide()
	else
		frame:Show()
	end
end

local setFramePosition = function(f, s)
	FrameLock.SideEffectRestoreSize(s, {
		w=DEFAULT_ICON_SIZE, h=DEFAULT_ICON_SIZE, dx=110, dy=40,
	})
	f:SetWidth(s.FrameMeta.W)
	f:SetHeight(s.FrameMeta.H)
	f:SetPoint("TopLeft", s.FrameMeta.X, s.FrameMeta.Y)
end

local createUI = function()
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetFrameStrata("LOW")
	f:SetBackdrop({ edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 20 })
	setFramePosition(f, store)

	f.Icon = f:CreateTexture(nil, "BACKGROUND")
	f.Icon:SetPoint("Left", f, "Left", INSET, 0)
	f.Icon:SetPoint("Right", f, "Right", -INSET, 0)
	f.Icon:SetPoint("Top", f, "Top", 0, -INSET)
	f.Icon:SetPoint("Bottom", f, "Bottom", 0, INSET)
	f.Icon:SetAlpha(TRANSPARENCY)

	FrameLock.SideEffectMakeMoveable(f, store)
	FrameLock.SideEffectMakeResizeable(f, store, { GripMargin=0 })
	return f
end

-- ************ Event Handlers ************
--- @type Event[]
local _EVENTS = {
	"PLAYER_AURAS_CHANGED",
	"UNIT_FLAGS", -- For hiding tracker on taxi
	"SPELLS_CHANGED",-- Open or click thru spellbook, learn/unlearn spell
}
local handleEvent = function()
	if event == "SPELLS_CHANGED" and arg1 ~= "LeftButton"
		or event == "PLAYER_AURAS_CHANGED"
		or event == "UNIT_FLAGS" and arg1 == "player"
	then
		updateUI()
	end
end

-- ************ Initialization ************
local onEnable = function()
	if frame == nil then frame = createUI() end
	updateUI()
	frame:SetScript("OnEvent", handleEvent)
	for _i, v in ipairs(_EVENTS) do frame:RegisterEvent(v) end
	frame:Show()
end
local onDisable = function()
	frame:Hide()
	for _i, v in ipairs(_EVENTS) do frame:UnregisterEvent(v) end
end

---@type QqModule
return {
	Id = MODULE_ID,
	GetName = function() return Quiver.T["Aspect Tracker"] end,
	GetTooltipText = function() return nil end,
	OnEnable = onEnable,
	OnDisable = onDisable,
	OnInterfaceLock = function() updateUI() end,
	OnInterfaceUnlock = function() updateUI() end,
	OnResetFrames = function()
		store.FrameMeta = nil
		if frame then setFramePosition(frame, store) end
	end,
	---@param savedVariables StoreAspectTracker
	OnSavedVariablesRestore = function(savedVariables)
		store = savedVariables
	end,
	OnSavedVariablesPersist = function() return store end,
}
