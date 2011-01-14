--Provides timers for WORLD PVP objectives

local f = CreateFrame("frame","xanWorldPVPTimers_EventFrame",UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local pvpIconID = {
	[1] = "Interface\\Icons\\Spell_Frost_ChillingBlast",
	[2] = "Interface\\Icons\\achievement_zone_tolbarad",
}

--[[------------------------
	ENABLE
--------------------------]]

function f:PLAYER_LOGIN()

	if not XanWPT_DB then XanWPT_DB = {} end
	if XanWPT_DB.bgShown == nil then XanWPT_DB.bgShown = true end
	if XanWPT_DB.scale == nil then XanWPT_DB.scale = 1 end
	if XanWPT_DB.showWG == nil then XanWPT_DB.showWG = true end
	if XanWPT_DB.showTB == nil then XanWPT_DB.showTB = true end
	
	self:CreateFrames()
	self:PositionFrames()

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	
	SLASH_XANWORLDPVPTIMERS1 = "/xwpt";
	SlashCmdList["XANWORLDPVPTIMERS"] = function(cmd)
		local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters
		
		if a then
			if c and c:lower() == "bg" then
				XanWPT_DB.bgShown = not XanWPT_DB.bgShown
				
				for i=1, GetNumWorldPVPAreas() do
					local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
					local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
					
					if tFrm and tFrm:IsVisible() then
						--now change background
						if XanWPT_DB.bgShown then
							tFrm:SetBackdrop( {
								bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
								edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
								tile = true; tileSize = 32; edgeSize = 16;
								insets = { left = 5; right = 5; top = 5; bottom = 5; };
							} );
							tFrm:SetBackdropBorderColor(0.5, 0.5, 0.5)
							tFrm:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
						else
							tFrm:SetBackdrop(nil)
						end
					end
				end
				
				DEFAULT_CHAT_FRAME:AddMessage("xanWorldPVPTimers: Background settings have changed!")
				return true
			elseif c and c:lower() == "reset" then
				for i=1, GetNumWorldPVPAreas() do
					local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
					local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
					
					if tFrm then
						tFrm:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					end
				end
				DEFAULT_CHAT_FRAME:AddMessage("xanWorldPVPTimers: Frame position has been reset!")
				return true
			elseif c and c:lower() == "scale" then
				if b then
					local scalenum = strsub(cmd, b+2)
					if scalenum and scalenum ~= "" and tonumber(scalenum) then
						for i=1, GetNumWorldPVPAreas() do
							local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
							local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
							
							if tFrm then
								tFrm:SetScale(tonumber(scalenum))
							end
						end
						XanDUR_DB.scale = tonumber(scalenum)
						DEFAULT_CHAT_FRAME:AddMessage("xanWorldPVPTimers: scale has been set to ["..tonumber(scalenum).."]")
						return true
					end
				end
			elseif c and c:lower() == "wg" then
				XanWPT_DB.showWG = not XanWPT_DB.showWG
				
				local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(1)
				local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
				
				if tFrm then
					if XanWPT_DB.showWG then
						tFrm:Show()
					else
						tFrm:Hide()
					end
				end
				return true
			elseif c and c:lower() == "tb" then
				XanWPT_DB.showTB = not XanWPT_DB.showTB
				
				local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(2)
				local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
				
				if tFrm then
					if XanWPT_DB.showTB then
						tFrm:Show()
					else
						tFrm:Hide()
					end
				end
				return true
			end
		end

		DEFAULT_CHAT_FRAME:AddMessage("xanWorldPVPTimers");
		DEFAULT_CHAT_FRAME:AddMessage("/xwpt reset - resets the frame position");
		DEFAULT_CHAT_FRAME:AddMessage("/xwpt bg - toggles the background on/off");
		DEFAULT_CHAT_FRAME:AddMessage("/xwpt scale # - Set the scale of the XanDurability frame")
		DEFAULT_CHAT_FRAME:AddMessage("/xwpt wg - Show or hide the Wintergrasp frame")
		DEFAULT_CHAT_FRAME:AddMessage("/xwpt tb - Show or hide the Tol Barad frame")
	end
	
	local ver = GetAddOnMetadata("xanWorldPVPTimers","Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFFDF2B2B%s|r] Loaded", "xanWorldPVPTimers", ver or "1.0"))
end

--[[------------------------
	CORE
--------------------------]]

local upt_throt  = 0

f:HookScript("OnUpdate", function(self, elapsed)
	--do some throttling
	upt_throt = upt_throt + elapsed
	if upt_throt < 1 then return end
	upt_throt = 0
			
	if GetNumWorldPVPAreas() < 1 then return end
	
	for i=1, GetNumWorldPVPAreas() do
	
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]

		if tFrm and tFrm.txt and tFrm:IsVisible() then
			if not isActive and startTime and startTime > 0 then
				tFrm.txt:SetText(f:GetTimeText(startTime))
			else
				tFrm.txt:SetText("In Progress")
			end
		end
		
	end
	
end)
	
function f:CreateFrames()
	
	--check if we have world areas to view from
	if GetNumWorldPVPAreas() < 1 then return end
		
	--1 = Wintergrasp
	--2 = Tol Barad
	
	for i=1, GetNumWorldPVPAreas() do
		
		--get the world pvp info
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)

		local frm = CreateFrame("frame", string.format("xanWorldPVPTimers_%s", localizedName), UIParent)
		
		frm.pvpID = pvpID
		frm:SetWidth(90)
		frm:SetHeight(27)
		frm:SetMovable(true)
		frm:SetClampedToScreen(true)
		
		frm:SetScale(XanWPT_DB.scale)
		
		if XanWPT_DB.bgShown then
			frm:SetBackdrop( {
				bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
				tile = true; tileSize = 32; edgeSize = 16;
				insets = { left = 5; right = 5; top = 5; bottom = 5; };
			} );
			frm:SetBackdropBorderColor(0.5, 0.5, 0.5)
			frm:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
		else
			frm:SetBackdrop(nil)
		end
		
		frm:EnableMouse(true)
		
		local t = frm:CreateTexture("$parentIcon", "ARTWORK")
		if pvpIconID[i] then
			t:SetTexture(pvpIconID[i])
		else
			t:SetTexture("Interface\\Icons\\Trade_Blacksmithing")
		end
		t:SetWidth(16)
		t:SetHeight(16)
		t:SetPoint("TOPLEFT",5,-6)
		frm.icon = t

		local g = frm:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
		g:SetJustifyH("LEFT")
		g:SetPoint("CENTER",8,0)
		g:SetText("")
		frm.txt = g

		frm:SetScript("OnMouseDown",function(self)
			if (IsShiftKeyDown()) then
				self.isMoving = true
				self:StartMoving();
			end
		end)
		frm:SetScript("OnMouseUp",function(self)
			if( self.isMoving ) then

				self.isMoving = nil
				self:StopMovingOrSizing()

				f:SaveLayout(self:GetName());

			end
		end)
		
		if (i == 1 and XanWPT_DB.showWG) or (i == 2 and XanWPT_DB.showTB) then
			frm:Show()
		else
			frm:Hide()
		end

	end
	
end

function f:PositionFrames()

	--check if we have world areas to view from
	if GetNumWorldPVPAreas() < 1 then return end
		
	--1 = Wintergrasp
	--2 = Tol Barad
	
	for i=1, GetNumWorldPVPAreas() do
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		f:RestoreLayout(string.format("xanWorldPVPTimers_%s", localizedName))
	end
	
end

function f:GetTimeText(timeLeft)
	local hours, minutes, seconds = 0, 0, 0
	if( timeLeft >= 3600 ) then
		hours = floor(timeLeft / 3600)
		timeLeft = mod(timeLeft, 3600)
	end

	if( timeLeft >= 60 ) then
		minutes = floor(timeLeft / 60)
		timeLeft = mod(timeLeft, 60)
	end

	seconds = timeLeft > 0 and timeLeft or 0

	if hours > 0 then
		return string.format("%02d:%02d:%02d",hours, minutes, seconds)
	elseif minutes > 0 then
		return string.format("00:%02d:%02d", minutes, seconds)
	elseif seconds > 0 then
		return string.format("00:00:%02d", seconds)
	else
		return nil
	end
end
	
--[[------------------------
	LAYOUT SAVE/RESTORE
--------------------------]]

function f:SaveLayout(frame)

	if not XanWPT_DB then XanWPT_DB = {} end

	local opt = XanWPT_DB[frame] or nil;

	if opt == nil then
		XanWPT_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = XanWPT_DB[frame];
	end

	local f = getglobal(frame);
	local scale = f:GetEffectiveScale();
	opt.PosX = f:GetLeft() * scale;
	opt.PosY = f:GetTop() * scale;
	
end

function f:RestoreLayout(frame)

	if not XanWPT_DB then XanWPT_DB = {} end	

	local f = getglobal(frame);
	local opt = XanWPT_DB[frame] or nil;

	if opt == nil then
		XanWPT_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = XanWPT_DB[frame];
	end

	local x = opt.PosX;
	local y = opt.PosY;
	local s = f:GetEffectiveScale();

	if (not x or not y) or (x==0 and y==0) then
		f:ClearAllPoints();
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		return 
	end

	--calculate the scale
	x,y = x/s,y/s;

	--set the location
	f:ClearAllPoints();
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);

end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end