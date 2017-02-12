assert(BigWigs, "BigWigs not found!")

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsCThunGroups")

L:RegisterTranslations("enUS", function() return {

	mod = "CThunGroups",
	cmd = "CThunGroups",
	
	opt_name = "C'Thun Groups",
	opt_desc = "Options for the C'Thun Groups Module.",
	
	post = "Post Groups",
	post_name = "Post Groups",
	post_desc = "Post Groups to RAID chat"
	
} end)

----------------------------------
--      Module Declaration      --
----------------------------------

BigWigsCThunGroups = BigWigs:NewModule(L["mod"])
BigWigsCThunGroups.revision = tonumber(string.sub("$Revision: 19013 $", 12, -3))
BigWigsCThunGroups.defaults = { }
BigWigsCThunGroups.defaultDB = { }
BigWigsCThunGroups.external = true
BigWigsCThunGroups.consoleCmd = L["cmd"]
BigWigsCThunGroups.consoleOptions = {
	type = "group",
	name = L["opt_name"],
	desc = L["opt_desc"],
	args = {
		[L["post"]] = {
			type = "execute",
			name = L["post_name"],
			desc = L["post_desc"],
			func = function() BigWigsCThunGroups:BigWigs_PostGroups() end,
		},
	}
}

------------------------------
--      Initialization      --
------------------------------

function BigWigsCThunGroups:OnEnable()


end


------------------------------
--      Event Handlers      --
------------------------------


function BigWigsCThunGroups:BigWigs_PostGroups()
	local raidnum = GetNumRaidMembers()
	
	--create and fill the groups
	if ( raidnum > 0 ) then
		for raidmember = 1, raidnum do
			local rName, rRank, rSubgroup, rLevel, rClass = GetRaidRosterInfo(raidmember)
			
			i = 1
			for groupnr = 1, 8 do
				if rSubgroup == groupnr then
					BigWigsCThunGroups_Group..groupnr[i] = {}
					BigWigsCThunGroups_Group..groupnr[i].rName = rName
					BigWigsCThunGroups_Group..groupnr[i].rClass = rClass
					i = i + 1
				end
			end
		end
	end
	
	--create run in order
	for groupnr = 1, 8 do
		for k, v ipairs in (BigWigsCThunGroups_Group..groupnr) do 
		
			--Nr 1
			if v.rClass == "Warrior" or not v.rOrder == 1 then
				v.rOrder = 1
			elseif v.rClass == "Rogue" or not v.rOrder == 1 then
				v.rOrder = 1
			elseif v.rClass == "Druid" or not v.rOrder == 1 then
				v.rOrder = 1
			elseif v.rClass == "Shaman" or not v.rOrder == 1 then
				v.rOrder = 1
			elseif v.rClass == "Warlock" then
			
			elseif v.rClass == "Mage" then
			
			elseif v.rClass == "Priest" then
			
			end
			
			--Nr 2
			if v.rClass == "Warrior" or not v.rOrder == 2 then
				v.rOrder = 2
			elseif v.rClass == "Rogue" or not v.rOrder == 2 then
				v.rOrder = 2
			elseif v.rClass == "Druid" or not v.rOrder == 2 then
				v.rOrder = 2
			elseif v.rClass == "Shaman" or not v.rOrder == 2 then
				v.rOrder = 2
			elseif v.rClass == "Warlock" then
			
			elseif v.rClass == "Mage" then
			
			elseif v.rClass == "Priest" then
			
			end
			
		end
	end
	
end
