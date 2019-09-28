-- convert total amount of money in unit copper to other units
local function ConvertToGold(totalCopper) return floor(abs(totalCopper/10000)) end
local function ConvertToSilver(totalCopper) return floor(abs(mod(totalCopper/100,100))) end
local function ConvertToCopper(totalCopper) return floor(abs(mod(totalCopper,100))) end


--[[
	query the item mouse is over in auction house
	returns the name of the frame under the mouse, if it's named
--]]
local function MyAuctionQuery()
	local frame = GetMouseFocus()
	if frame then
		local name = frame:GetName()
		local bagInd, itemInd = string.match(name, 'ContainerFrame(%d)Item(%d+)$')
		bagInd = tonumber(bagInd)-1 -- Frame name and GetContainerItemID zählen anders daher umrechnen
		local numberOfSlots = GetContainerNumSlots(bagInd);
		itemInd = (numberOfSlots+1)-tonumber(itemInd)
		local itemID = GetContainerItemID(bagInd,itemInd)
		local itemName = select(1, GetItemInfo(itemID))
		print("QueryAuctionItems -> "..itemName)
		QueryAuctionItems(itemName)
	end
end


local function MyAuctionSort(reversed)
	SortAuctionClearSort("list") -- clear any existing criteria
	SortAuctionSetSort("list", "buyout") -- apply some criteria of our own
	SortAuctionSetSort("list", "quantity", reversed) -- apply the criteria to the server query
	SortAuctionApplySort("list")
end


SLASH_MOOAUCTION1 = "/mooauction";
function SlashCmdList.MOOAUCTION(msg, editbox)

	local canQuery, canMassQuery = CanSendAuctionQuery("list")

	if canQuery then
	
		if msg=="query" then MyAuctionQuery() end
	
		if msg=="sortBuyout" then
			MyAuctionSort(false)
		end
		
		if msg=="sortBuyoutReversed" then
			MyAuctionSort(true)
		end
		
		if msg=="queryBuyout" then
			MyAuctionSort(false)
			MyAuctionQuery()
		end
		
		if msg=="queryBuyoutReversed" then
			MyAuctionSort(true)
			MyAuctionQuery()
		end
		
		if msg=="priceperitem" then
			local index = GetSelectedAuctionItem("list")
			local aItemInfo = {GetAuctionItemInfo("list", index)}
			local aItemName = aItemInfo[1]
			local aItemCount = aItemInfo[3]
			local aItemBuyout = aItemInfo[10]
			print("1 x "..aItemName..": "..ConvertToGold(aItemBuyout/aItemCount).." Gold, "..ConvertToSilver(aItemBuyout/aItemCount).." Silber, "..ConvertToCopper(aItemBuyout/aItemCount).." Kupfer")
		end
	end
	
	
end


local f = CreateFrame("FRAME")
f:RegisterEvent("AUCTION_HOUSE_SHOW")
f:SetScript("OnEvent", function(self, event, ...)
	MyAuctionSort(false)
end)
