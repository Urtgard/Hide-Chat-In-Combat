------------------
--Config
local t = .5 -- fade time in seconds
------------------

local hcic = CreateFrame("Frame")
local frames = {_}
--, GeneralDockManager, ChatFrameMenuButton}
local chatFrames = {}
local MouseoverFrames = {}
--Events
local event = CreateFrame("Frame")
event:SetScript(
	"OnEvent",
	function(self, event, ...)
		self[event](self, ...)
	end
)
--Register events
event:RegisterEvent("PLAYER_REGEN_ENABLED")
event:RegisterEvent("PLAYER_REGEN_DISABLED")
event:RegisterEvent("PLAYER_LOGIN")
event:RegisterEvent("PET_BATTLE_CLOSE")
event:RegisterEvent("PET_BATTLE_OPENING_START")
--Handle events
function event:PLAYER_REGEN_ENABLED()
	hcic:CombatEnd()
end
function event:PLAYER_REGEN_DISABLED()
	hcic:CombatStart()
end
function event:PLAYER_LOGIN()
	hcic:Init()
end
function event:PET_BATTLE_CLOSE()
	hcic:CombatEnd()
end
function event:PET_BATTLE_OPENING_START()
	hcic:CombatStart()
end

--
function hcic:Init()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if (f:IsShown()) then
			local chatMouseover = CreateFrame("Frame", "HCIC" .. i, UIParent)
			chatMouseover:SetPoint("BOTTOMLEFT", "ChatFrame" .. i, "BOTTOMLEFT", -20, -10)
			chatMouseover:SetPoint("TOPRIGHT", "ChatFrame" .. i, "TOPRIGHT", 10, 10)

			chatMouseover.FadeOut = function(self)
				hcic:FadeOut(self)
			end
			chatMouseover.FadeIn = function(self)
				hcic:FadeIn(self)
			end

			chatMouseover:SetScript(
				"OnEnter",
				function(self)
					if UnitAffectingCombat("player") or C_PetBattles.IsInBattle() then
						self:FadeIn(self)
					end
				end
			)
			chatMouseover:SetScript(
				"OnLeave",
				function(self)
					hcic:ChatOnLeave(self)
				end
			)

			chatMouseover.Frames = {_G["ChatFrame" .. i], _G["ChatFrame" .. i .. "Tab"], _G["ChatFrame" .. i .. "ButtonFrame"]}
			if (i == 1) then
				table.insert(chatMouseover.Frames, GeneralDockManager)
				table.insert(chatMouseover.Frames, GeneralDockManagerScrollFrame)
				if ChatFrameMenuButton:IsShown() then
					table.insert(chatMouseover.Frames, ChatFrameMenuButton)
				end
				table.insert(chatMouseover.Frames, QuickJoinToastButton)
				table.insert(chatMouseover.Frames, ChatFrameChannelButton)
			end

			chatMouseover:SetFrameStrata("BACKGROUND")
			table.insert(MouseoverFrames, _G["HCIC" .. i])
		end
	end
end

--
function hcic:CombatStart()
	for _, f in pairs(MouseoverFrames) do
		f:FadeOut()
	end
end

--
function hcic:CombatEnd()
	for _, f in pairs(MouseoverFrames) do
		f:FadeIn()
	end
end

--Fade
--0: fade in, 1: fade out
function hcic:FadeOut(self)
	hcic:fade(self, 1)
end
function hcic:FadeIn(self)
	hcic:fade(self, 0)
end
function hcic:fade(self, mode)
	for _, frame in pairs(self.Frames) do
		local alpha = frame:GetAlpha()
		--fade in
		if mode == 0 then
			--fade out
			frame.Show = Show
			frame:Show()
			UIFrameFadeIn(frame, t * (1 - alpha), alpha, 1)
		else
			UIFrameFadeOut(frame, t * alpha, alpha, 0)
			frame.Show = function()
			end
			frame.fadeInfo.finishedArg1 = frame
			frame.fadeInfo.finishedFunc = frame.Hide
		end
	end
end

function hcic:ChatOnLeave(self)
	local f = GetMouseFocus()
	if f then
		if f.messageInfo then
			return nil
		end
		if hcic:IsInArray(self.Frames, f) then
			return nil
		end
		if f:GetParent() then
			f = f:GetParent()
			if hcic:IsInArray(self.Frames, f) then
				return nil
			end
			if f:GetParent() then
				f = f:GetParent()
				if hcic:IsInArray(self.Frames, f) then
					return nil
				end
			end
		end
	end

	if UnitAffectingCombat("player") or C_PetBattles.IsInBattle() then
		self:FadeOut(self)
	end
end

WorldFrame:HookScript(
	"OnEnter",
	function()
		if UnitAffectingCombat("player") or C_PetBattles.IsInBattle() then
			hcic:CombatStart()
		end
	end
)

function hcic:IsInArray(array, s)
	for _, v in pairs(array) do
		if (v == s) then
			return true
		end
	end
	return false
end

hooksecurefunc(
	"FCF_Tab_OnClick",
	function(self)
		chatFrame = _G["ChatFrame" .. self:GetID()]
		if (chatFrame.isDocked) then
			HCIC1.Frames[1] = chatFrame
		end
	end
)
