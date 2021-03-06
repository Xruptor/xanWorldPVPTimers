--Provides timers for WORLD PVP objectives

local f = CreateFrame("frame","xanWorldPVPTimers_EventFrame",UIParent)

f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local pvpIconID = {
	[1] = "Interface\\Icons\\Spell_Frost_ChillingBlast",
	[2] = "Interface\\Icons\\achievement_zone_tolbarad",
}

--� local Timer = LibStub:GetLibrary("AceTimer-3.0")

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
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHAT_MSG_ADDON")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
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

		if tFrm and tFrm:IsVisible() then
			if not isActive and startTime and startTime > 0 then
				tFrm.txt:SetText(self:GetTimeText(startTime))
				--check to see if we need to do an icon update
				if tFrm.needsUpdate < 0 or tFrm.needsUpdate > 0 then
					tFrm.needsUpdate = 0
					self:getClaimIcons()
				end
			else
				tFrm.txt:SetText("In Progress")
				if tFrm.needsUpdate ~= 1 then
					tFrm.needsUpdate = 1
					self:getClaimIcons()
				end
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
		frm:SetWidth(115)
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
		
		local icon = frm:CreateTexture("$parentIcon", "ARTWORK")
		if pvpIconID[i] then
			icon:SetTexture(pvpIconID[i])
		else
			icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end
		icon:SetWidth(16)
		icon:SetHeight(16)
		icon:SetPoint("TOPLEFT",5,-6)
		frm.icon = icon

		local fac = frm:CreateTexture("$parentFaction", "ARTWORK")
		fac:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		fac:SetWidth(16)
		fac:SetHeight(16)
		fac:SetPoint("TOPLEFT", icon, "TOPRIGHT", 5,0)
		frm.faction = fac
		
		local g = frm:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
		g:SetJustifyH("RIGHT")
		g:SetPoint("CENTER", fac, 40,0)
		g:SetText("")
		frm.txt = g
		
		--this will trigger a faction check update if greater then or less then zero
		frm.needsUpdate = -1
		frm.currFaction = 0  --save the current faction

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
	GET CONTROL DATA
--------------------------]]

function f:PLAYER_ENTERING_WORLD()
	f:getClaimIcons()
end

function f:getClaimIcons(sSwitch)
	local sendReq = false
	--get wintergrasp data
	if self:WGMapControlled() then sendReq = true end
	--get tol barad data
	if self:TBMapControlled() then sendReq = true end
	--send a request only if it's requested
	if sendReq and not sSwitch then self:requestUpdate() end
end

function f:TBMapControlled()

	--1 = Wintergrasp
	--2 = Tol Barad
	
	--check to see if we should even bother loading the faction image
	local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(2)
	local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]

	if tFrm and tFrm:IsVisible() then
		if isActive then
			tFrm.currFaction = 3
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_arena_2v2_1")
			return false
		end

		--otherwise get the faction icon :P
		local previousMapID = GetCurrentMapAreaID()
		SetMapByID(708) --set to TB
		
		local _, controlledByLocalized, textureIndex = GetMapLandmarkInfo(1)
		SetMapByID(previousMapID)

		if textureIndex == 48 then --Horde
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_h_16")
			tFrm.currFaction = 1
			return false
		elseif textureIndex == 46 then --Alliance
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_a_16")
			tFrm.currFaction = 2
			return false
		end
		
		--something went wrong check to see if we have a stored value
		if tFrm.currFaction == 1 then --Horde
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_h_16")
			return false
		elseif tFrm.currFaction == 2 then --Alliance
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_a_16")
			return false
		end
		--oblivously we still don't have a clue so request an update
		tFrm.currFaction = 0
		tFrm.faction:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		return true
	end
	
	return false
end

function f:WGMapControlled()
	--1 = Wintergrasp
	--2 = Tol Barad
	
	--check to see if we should even bother loading the faction image
	local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(1)
	local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]

	if tFrm and tFrm:IsVisible() then
		if isActive then
			tFrm.currFaction = 3
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_arena_2v2_1")
			return false
		elseif GetCurrentMapContinent() ~= 4 then
			--this only works if your on northrend sorry, request an update only if we don't have something to work with
			if tFrm.currFaction == 0 then return true end
			return false
		end
		--position 11 in getmapzones is wintergrasp
		local wintergrasp = select(11,GetMapZones(4))
		local continent, zone, faction = GetCurrentMapContinent(), GetCurrentMapZone()
		SetMapZoom(4) --set northrend zoomed map
		
		for i=1, GetNumMapLandmarks() do
			local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i)
			if name == wintergrasp then
				if textureIndex == 48 then --horde
					tFrm.currFaction = 1
					tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_h_16")
					SetMapZoom(continent,zone)
					return false
				elseif textureIndex == 46 then --alliance
					tFrm.currFaction = 2
					tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_a_16")
					SetMapZoom(continent,zone)
					return false
				end
			end
		end
		
		--something went wrong check to see if we have a stored value
		if tFrm.currFaction == 1 then --Horde
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_h_16")
			return false
		elseif tFrm.currFaction == 2 then --Alliance
			tFrm.faction:SetTexture("Interface\\Icons\\achievement_pvp_a_16")
			return false
		end
		--oblivously we still don't have a clue so request an update
		tFrm.currFaction = 0
		tFrm.faction:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		return true
		
	end
	
	return false
end

function f:requestUpdate()
	--this method will ask for an update from anyone else whom has this installed, via guild and party
	if IsInGuild() then
		SendAddonMessage( "XWPT", "upt", "GUILD")
	end
	if GetNumPartyMembers() > 0 then
		SendAddonMessage( "XWPT", "upt", "PARTY")
	end
	if GetNumRaidMembers() > 0 then
		SendAddonMessage( "XWPT", "upt", "RAID")
	end
end

function f:CHAT_MSG_ADDON(event, prefix, message, msgtype, sender)
    if (prefix == "XWPT") then
		--don't do an update for ourself LOL
		--print("MSG:", prefix, message, msgtype, sender)
		
	   if message == "upt" and sender ~= UnitName("player") then
			local sentString = ""
			--generate an update string
			for i=1, GetNumWorldPVPAreas() do
				local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
				local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
				--only send faction updates, not in battle, or unknown ;P
				if tFrm and tFrm.currFaction > 0 and tFrm.currFaction < 3 then
					sentString = sentString..i..tFrm.currFaction
				end
			end
			if string.len(sentString) > 0 then
				if IsInGuild() then
					SendAddonMessage( "XWPT", sentString, "GUILD")
				end
				if GetNumPartyMembers() > 0 then
					SendAddonMessage( "XWPT", sentString, "PARTY")
				end
				if GetNumRaidMembers() > 0 then
					SendAddonMessage( "XWPT", sentString, "RAID")
				end
			end
			
		elseif sender ~= UnitName("player") and string.len(message) > 0 then
			--if we only two characters then only one faction update was sent, if it was 4 then both WG and TB
			if string.len(message) == 2 then
				--update only one faction was sent
				f:setFactionStatus(string.sub(message, 1, 1), string.sub(message, 2))
			elseif string.len(message) == 4 then
				--both TB and WG were sent
				f:setFactionStatus(string.sub(message, 1, 1), string.sub(message, 2, 2))
				f:setFactionStatus(string.sub(message, 3, 3), string.sub(message, 4))
			end
	   end
    end
	
end

function f:setFactionStatus(frmNum, factionNum)
	frmNum = tonumber(frmNum)
	factionNum = tonumber(factionNum)

	if frmNum and factionNum then
		local pvpID, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(frmNum)
		local tFrm = _G[string.format("xanWorldPVPTimers_%s", localizedName)]
		--if the faction num doesn't match then force update it
		if tFrm and tFrm.currFaction ~= factionNum then
			tFrm.currFaction = factionNum
			--force an update but don't freaking request another update, otherwise loop from hell
			f:getClaimIcons(true)
		end
	end
end

--[[------------------------
	LAYOUT SAVE/RESTORE
--------------------------]]

function f:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanWPT_DB then XanWPT_DB = {} end
	
	local opt = XanWPT_DB[frame] or nil

	if not opt then
		XanWPT_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanWPT_DB[frame]
		return
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function f:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanWPT_DB then XanWPT_DB = {} end

	local opt = XanWPT_DB[frame] or nil

	if not opt then
		XanWPT_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanWPT_DB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end