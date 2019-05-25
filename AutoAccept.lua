
AutoAccept = LibStub("AceAddon-3.0"):NewAddon("AutoAccept", "AceConsole-3.0", "AceEvent-3.0")
_AutoAccept = {...}
--AutoAccept.db.realm
--AutoAccept.db.char

local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()
local AceGUI = LibStub("AceGUI-3.0")
debug = true
debuglevel = 5 --1 Critical, 2 ELEVATED, 3 Info, 4, Develop, 5 SPAM THAT SHIT YO
DEBUG_CRITICAL = "|cff00f2e6[CRITICAL]|r"
DEBUG_ELEVATED = "|cffebf441[ELEVATED]|r"
DEBUG_INFO = "|cff00bc32[INFO]|r"
DEBUG_DEVELOP = "|cff7c83ff[DEVELOP]|r"
DEBUG_SPAM = "|cffff8484[SPAM]|r"


-- get option value
local function GetGlobalOptionLocal(info)
	return AutoAccept.db.global[info[#info]]
end


-- set option value
local function SetGlobalOptionLocal(info, value)
	if debug and AutoAccept.db.global[info[#info]] ~= value then
		AutoAccept:Printf("DEBUG: global option %s changed from '%s' to '%s'", info[#info], tostring(AutoAccept.db.global[info[#info]]), tostring(value))
	end
	AutoAccept.db.global[info[#info]] = value
end

function AutoAccept:OnUpdate()

end

function AutoAccept:SlashTest(input)
	AutoAccept:Print("SlashTest!");
end

function AutoAccept:MySlashProcessorFunc(input)
	--AutoAccept:Print(ChatFrame1, "Hello, World!")
	--SetMessage("test", "test")
		AutoAccept:Print("MySlashProcessorFunc!");
		AutoAccept:debug(DEBUG_SPAM, "te")
		for i = 1, 5000 do
				local mapInfo = C_Map.GetMapInfo(i)
						AutoAccept:debug(DEBUG_SPAM, mapInfo)
				if mapInfo and mapInfo.name then
				end
		end

  -- Process the slash command ('input' contains whatever follows the slash command)

end

function AutoAccept:OnEnable()
    -- Called when the addon is enabled
end

function AutoAccept:OnDisable()
    -- Called when the addon is disabled
end


local options = {
    name = "AutoAccept",
    handler = AutoAccept,
    type = "group",
	childGroups = "tab",
    args = {
		general_tab = {
			name = "Options",
			type = "group",
			order = 10,
			args = {
				quest_options = {
					type = "header",
					order = 13,
					name = "Quest Options",
				},
				autoaccept = {
					type = "toggle",
					order = 14,
					name = "Auto Accept Quests",
					desc = "Enable or disable AutoAccept auto-accepting quests.",
					width = 200,
					width = "normal",
					get =	function ()
								return AutoAccept.db.char.autoaccept
							end,
					set =	function (info, value)
								AutoAccept.db.char.autoaccept = value
								AutoAccept:debug(DEBUG_DEVELOP, "Auto Accept toggled to:", value)
							end,
				},
				autocomplete = {
					type = "toggle",
					order = 14,
					name = "Auto Complete",
					desc = "Enable or disable AutoAccept auto-complete quests.",
					width = 200,
					width = "normal",
					get =	function ()
								return AutoAccept.db.char.autocomplete
							end,
					set =	function (info, value)
								AutoAccept.db.char.autocomplete = value
								AutoAccept:debug(DEBUG_DEVELOP, "Auto Complete toggled to:", value)
							end,
				},
			},
		},
	}
}

local defaults = {
  global = {
	  temp = false,
  },
	char = {
		autoaccept = true,
		autocomplete = true
	}
}

function QUEST_PROGRESS(event, ...)
	AutoAccept:Debug(DEBUG_DEVELOP, event, ...)
    if IsQuestCompletable() then
		CompleteQuest()
    end
end

function ACCEPT_QUEST_GOSSIP(...)
	local MOP_INDEX_CONST = 7 -- was '5' in Cataclysm
	for i=1, select("#", ...), MOP_INDEX_CONST do
		local title = select(i, ...)
		local isTrivial = select(i+2, ...)
		local isRepeatable = select(i+4, ...) -- complete status
		AutoAccept:Debug(DEBUG_DEVELOP, "Accepting quest, Title:", title, "Trivial", isTrivial, "Repeatable", isRepeatable, "index", i)
		if( not isTrivial) then
			AutoAccept:Debug(DEBUG_INFO, "Accepting quest, ", title)
			SelectGossipAvailableQuest(math.floor(i/MOP_INDEX_CONST)+1)
		end
	end
end

function COMPLETE_QUEST_GOSSIP(...)
	local MOP_INDEX_CONST = 6 -- was '4' in Cataclysm
	for i=1, select("#", ...), MOP_INDEX_CONST do
		local title = select(i, ...)
		local isComplete = select(i+3, ...) -- complete status
		AutoAccept:Debug(DEBUG_DEVELOP, "Completing quest, ", title, "Complete", isComplete, "index", i)
		if ( isComplete ) then
			AutoAccept:Debug(DEBUG_INFO, "Completing quest, ", title)
			SelectGossipActiveQuest(math.floor(i/MOP_INDEX_CONST)+1)
		end
	end
end

function GOSSIP_SHOW(event, ...)
	AutoAccept:Debug(DEBUG_DEVELOP, event, ...)

	if AutoAccept.db.char.autoaccept then
		ACCEPT_QUEST_GOSSIP(GetGossipAvailableQuests())
	end
	if AutoAccept.db.char.autocomplete then
		COMPLETE_QUEST_GOSSIP(GetGossipActiveQuests())
	end
end

function QUEST_GREETING(event, ...)
	AutoAccept:Debug(DEBUG_DEVELOP, event, GetNumActiveQuests(), ...)
	--Quest already taken
	if(AutoAccept.db.char.autocomplete) then
		for index=1, GetNumActiveQuests() do
			local quest, isComplete = GetActiveTitle(index)
			AutoAccept:Debug(DEBUG_DEVELOP, quest, isComplete)
			if isComplete then
				SelectActiveQuest(index)
			end
		end
	end

	if(AutoAccept.db.char.autoaccept) then
		for index=1, GetNumAvailableQuests() do
			local isTrivial, isDaily, isRepeatable, isIgnored = GetAvailableQuestInfo(index)
			if (isIgnored) then return end -- Legion functionality
			if( not isTrivial and not isRepeatable) then
				local title = GetAvailableTitle(index)
				SelectAvailableQuest(index)
			end
		end
	end
end

function AutoAccept:TurnInQuest(rewardIndex)
	--Maybe we want to do something smart?
	GetQuestReward(rewardIndex)
end

function QUEST_ACCEPT_CONFIRM(event, ...)
	--Escort stuff
	--if(AutoAccept.db.char.autoaccept) then
    --    ConfirmAcceptQuest()
	--end
end

function QUEST_DETAIL(event, ...)
	AutoAccept:Debug(DEBUG_DEVELOP, event, ...)
	if(AutoAccept.db.char.autoaccept) then
		if QuestGetAutoAccept() then
			AutoAccept:Debug(DEBUG_INFO, "Quest already accepted")
			local QuestFrameButton = _G["QuestFrameAcceptButton"];
			if(QuestFrameButton:IsVisible()) then
				AutoAccept:Debug(DEBUG_INFO, "Blizzard auto-accept workaround")
				QuestFrameButton:Click("Accept Quest")
			else
				CloseQuest()
			end
		else
			AutoAccept:Debug(DEBUG_INFO, "AutoAccept Auto-Acceping quest")
			AcceptQuest()
		end
	end
end

-- I was forced to make decision on offhand, cloak and shields separate from armor but I can't pick up my mind about the reason...
function QUEST_COMPLETE(event, ...)
	AutoAccept:Debug(DEBUG_DEVELOP, event, ...);
	-- blasted Lands citadel wonderful NPC. They do not trigger any events except quest_complete.
	--if not AllowedToHandle() then
	--	return
	--end

	local questname = GetTitleText()
	local numOptions = GetNumQuestChoices()
	AutoAccept:Debug(DEBUG_DEVELOP, event, questname, numOptions, ...);

	if numOptions > 1 then
		AutoAccept:Debug(DEBUG_DEVELOP, "Multiple rewards! ", numOptions);
		local function getItemId(typeStr)
			local link = GetQuestItemLink(typeStr, 1) --first item is enough
			return link and link:match("%b::"):gsub(":", "")
		end

		local itemID = getItemId("choice")
		if (not itemID) then
			AutoAccept:Debug(DEBUG_DEVELOP, "Can't read reward link from server. Close NPC dialogue and open it again.");
			return
		end
		AutoAccept:Debug(DEBUG_INFO, "Multiple rewards! Please choose appropriate reward!");

	else
		AutoAccept:TurnInQuest(1)
		AutoAccept:Debug(DEBUG_DEVELOP, "Completed quest!");
	end
end

glooobball = ""
Note = nil
function AutoAccept:OnInitialize()
	print("test")
	AutoAccept:Debug(DEBUG_CRITICAL, "AutoAccept addon loaded")
	--AutoAccept:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
	--Accepted Events
	--AutoAccept:RegisterEvent("QUEST_ACCEPTED", QUEST_ACCEPTED)
	--AutoAccept:RegisterEvent("QUEST_WATCH_UPDATE", QUEST_WATCH_UPDATE);
	--AutoAccept:RegisterEvent("QUEST_TURNED_IN", QUEST_TURNED_IN)
	--AutoAccept:RegisterEvent("QUEST_REMOVED", QUEST_REMOVED)

	--When the quest is presented!
	AutoAccept:RegisterEvent("QUEST_DETAIL", QUEST_DETAIL)
	--???
	AutoAccept:RegisterEvent("QUEST_PROGRESS", QUEST_PROGRESS)
	--Gossip??
	AutoAccept:RegisterEvent("GOSSIP_SHOW", GOSSIP_SHOW)
	--The window when multiple quest from a NPC
	AutoAccept:RegisterEvent("QUEST_GREETING", QUEST_GREETING)
	--If an escort quest is taken by people close by
	AutoAccept:RegisterEvent("QUEST_ACCEPT_CONFIRM", QUEST_ACCEPT_CONFIRM)
	--When complete window shows
	AutoAccept:RegisterEvent("QUEST_COMPLETE", QUEST_COMPLETE)


	--[[self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_ACCEPTED")]]--
	--TODO: QUEST_QUERY_COMPLETE Will get all quests the character has finished, need to be implemented!


	--Old stuff that has been tried, remove in cleanup
	--Hook the questcomplete button
	--QuestFrameCompleteQuestButton:HookScript("OnClick", CUSTOM_QUEST_COMPLETE)
	--AutoAccept:RegisterEvent("QUEST_COMPLETE", QUEST_COMPLETE)
	--AutoAccept:RegisterEvent("QUEST_FINISHED", QUEST_FINISHED)
	--?? What does this do?


	-- not in classic AutoAccept:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE", QUEST_LOG_CRITERIA_UPDATE)


	AutoAccept:RegisterChatCommand("questieclassic", "MySlashProcessorFunc")
	AutoAccept:RegisterChatCommand("test", "SlashTest")
	AutoAccept:RegisterChatCommand("qc", "MySlashProcessorFunc")
	self.db = LibStub("AceDB-3.0"):New("AutoAcceptDB", defaults, true)


	--WILL ERROR; Run with reloadui!
	--x, y, z = HBD:GetPlayerWorldPosition();
	--AutoAccept:Print("XYZ:", x, y, z, "Zone: "..getPlayerZone(), "Cont: "..getPlayerContinent());
	--AutoAccept:Print(HBD:GetWorldCoordinatesFromAzerothWorldMap(x, y, ));
	--mapX, mapY = HBD:GetAzerothWorldMapCoordinatesFromWorld(x, y, 0);
	--AutoAccept:Print(mapX, mapY);
	--glooobball = C_Map.GetMapInfo(1)
	--glooobball = HBD:GetAllMapIDs()
	--AutoAccept:Print(HBD:GetAllMapIDs())
	--AutoAccept:Print(GetWorldContinentFromZone(getPlayerZone()))



	--AutoAcceptFrameOpt = AceGUI:Create("Frame")
	--AutoAccept.db.global.lastmessage = 0
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AutoAccept", options)
	--AutoAcceptFrame2 = LibStub("AceConfigDialog-3.0"):Open("AutoAccept", AutoAcceptFrameOpt)

	--AutoAcceptFrame:SetTitle("Example frame")
	--AutoAcceptFrame:SetStatusText("AceGUI-3.0 Example Container frame")
	--AutoAcceptFrame:SetCallback("OnClose", function() AutoAcceptFrame:Hide() end)
	--AutoAcceptFrame:SetLayout(options)

	self.configFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AutoAccept", "AutoAccept Classic");

  -- Code that you want to run when the addon is first loaded goes here.
  --AutoAccept:Print("Hello, world!")
  --self:RegisterChatCommand("AutoAccept", "ChatCommand")


end



function AutoAccept:Error(...)
	AutoAccept:Print("|cffff0000[ERROR]|r", ...)
end

function AutoAccept:error(...)
	AutoAccept:Error(...)
end

--debuglevel = 5 --1 Critical, 2 ELEVATED, 3 Info, 4, Develop, 5 SPAM THAT SHIT YO
--DEBUG_CRITICAL = "1DEBUG"
--DEBUG_ELEVATED = "2DEBUG"
--DEBUG_INFO = "3DEBUG"
--DEBUG_DEVELOP = "4DEBUG"
--DEBUG_SPAM = "5DEBUG"

function AutoAccept:Debug(...)
	if(debug) then
		if(debuglevel < 5 and arg[1] == DEBUG_SPAM)then return; end
		if(debuglevel < 4 and arg[1] == DEBUG_DEVELOP)then return; end
		if(debuglevel < 3 and arg[1] == DEBUG_INFO)then return; end
		if(debuglevel < 2 and arg[1] == DEBUG_ELEVATED)then return; end
		if(debuglevel < 1 and arg[1] == DEBUG_CRITICAL)then return; end
		AutoAccept:Print(...)
	end
end

function AutoAccept:debug(...)
	AutoAccept:Debug(...)
end
