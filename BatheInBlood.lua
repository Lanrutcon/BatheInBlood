local Addon = CreateFrame("FRAME");

local damageTaken, healTaken, startTime, inCombat = 0, 0;

local round = math.floor;

local frame;

--"initing" the frame
local function initFrame()
	frame = CreateFrame("FRAME", "BIBFrame", UIParent);
	frame:SetSize(100,75);
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
	frame:SetBackdrop(
		{bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 6, right = 6, top = 6, bottom = 6 }});

	frame.dtps = frame:CreateFontString("BIBDtps", "OVERLAY", "GameFontNormal");
	frame.dtps:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE");
	frame.dtps:SetTextColor(1, 0.2, 0.2, 1);
	frame.dtps:SetPoint("TOP", 0, -15);
	frame.dtps:SetText("DTPS");

	frame.htps = frame:CreateFontString("BIBHtps", "OVERLAY", "GameFontNormal");
	frame.htps:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE");
	frame.htps:SetTextColor(0.2, 1, 0.2, 1);
	frame.htps:SetPoint("BOTTOM", 0, 15);
	frame.htps:SetText("HTPS");

	frame:SetScript("OnMouseDown", function(self, button)
		if IsAltKeyDown() and IsShiftKeyDown() and button == "LeftButton" then
			self:SetMovable(true);
			self:StartMoving();
		end
	end);
	frame:SetScript("OnMouseUp", function(self, button)
		self:SetMovable(false);
		self:StopMovingOrSizing();
		local point, _, relativePoint, x, y = self:GetPoint();
		BatheInBloodSV[UnitName("player")] = { point, relativePoint, x, y };
	end);

	frame:Show();
end



local function updateValues()
	local duration = GetTime() - startTime;
	if duration == 0 then
		duration = 1;
	end
	frame.dtps:SetText(round(damageTaken/duration + 0.5));
	frame.htps:SetText(round(healTaken/duration + 0.5));
end


Addon:SetScript("OnEvent", function(self, event, ...)
	local unit, action, _, value = ...;
	if inCombat and event == "UNIT_COMBAT" and unit == "player" then
		if action == "WOUND" then
			damageTaken = damageTaken + value;
		elseif action == "HEAL" then
			healTaken = healTaken + value;
		end
		if not startTime then
			startTime = GetTime();
		end
		updateValues();
	elseif event == "PLAYER_REGEN_DISABLED" then
		inCombat = true;
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false;
		damageTaken = 0;
		healTaken = 0;
		startTime = nil;
	elseif event == "VARIABLES_LOADED" then
		initFrame();
		local point, _,relativePoint, x, y;
		if(type(BatheInBloodSV) ~= "table") then
			BatheInBloodSV = {};
			point, _,relativePoint, x, y = frame:GetPoint();
			BatheInBloodSV[UnitName("player")] = { point, relativePoint, x, y};
		elseif(BatheInBloodSV[UnitName("player")]) then
			point, relativePoint, x, y = BatheInBloodSV[UnitName("player")][1], BatheInBloodSV[UnitName("player")][2], BatheInBloodSV[UnitName("player")][3], BatheInBloodSV[UnitName("player")][4];
			frame:SetPoint(point, UIParent, relativePoint, x, y);
		else
			point, relativePoint, x, y = frame:GetPoint();
			BatheInBloodSV[UnitName("player")] = { point, relativePoint, x, y};
		end
	end
end);

Addon:RegisterEvent("VARIABLES_LOADED");
Addon:RegisterEvent("UNIT_COMBAT");
Addon:RegisterEvent("PLAYER_REGEN_DISABLED");
Addon:RegisterEvent("PLAYER_REGEN_ENABLED");
