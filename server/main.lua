ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Drops = {}
Trunks = {}
Gloveboxes = {}
Stashes = {}
ShopItems = {}

RegisterServerEvent("esx_inventory:server:LoadDrops")
AddEventHandler('esx_inventory:server:LoadDrops', function()
	local src = source
	if next(Drops) ~= nil then
		TriggerClientEvent("esx_inventory:client:AddDropItem", -1, dropId, source)
		TriggerClientEvent("esx_inventory:client:AddDropItem", src, Drops)
	end
end)

RegisterServerEvent("esx_inventory:server:addTrunkItems")
AddEventHandler('esx_inventory:server:addTrunkItems', function(plate, items)
	Trunks[plate] = {}
	Trunks[plate].items = items
end)

RegisterServerEvent("esx_inventory:server:set:inventory:disabled")
AddEventHandler('esx_inventory:server:set:inventory:disabled', function(bool)
	local Player = ESX.GetPlayerFromId(source)
	Player.set("inventorydisabled", bool)
end)

RegisterServerEvent("esx_inventory:server:combineItem")
AddEventHandler('esx_inventory:server:combineItem', function(item, fromItem, toItem, RemoveToItem)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	local CombineFrom = Player.GetItemByName(fromItem)
	local CombineTo = Player.GetItemByName(toItem)
	local GetItemData = ESX.Items[item]
	if CombineFrom ~= nil and CombineTo ~= nil then
		if GetItemData['type'] == 'weapon' then
			local Info = {quality = 100.0, melee = false, ammo = 2}
			if GetItemData['ammotype'] == nil or GetItemData['ammotype'] == 'nil' then
				Info = {quality = 100.0, melee = true}
	  			Player.addInventoryItem(item, 1, false, Info)
			else
				Player.addInventoryItem(item, 1, false, Info)
			end
		else
			Player.addInventoryItem(item, 1)
		end
		Player.removeInventoryItem(fromItem, 1)
	  if RemoveToItem then
	    Player.removeInventoryItem(toItem, 1)
	  end
	  Player.set("inventorydisabled", false)
	else
	  TriggerClientEvent('esx:showNotification', src, "Je hebt deze spullen niet eens bij je hoe dan???")
	end
end)

RegisterServerEvent("esx_inventory:server:CraftItems")
AddEventHandler('esx_inventory:server:CraftItems', function(itemName, itemCosts, count, toSlot, points)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	local count = tonumber(count)
	if itemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.removeInventoryItem(k, (v*count))
		end
		Player.addInventoryItem(itemName, count, toSlot)
		Player.set("inventorydisabled", false)
		TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent("esx_inventory:server:CraftWeapon")
AddEventHandler('esx_inventory:server:CraftWeapon', function(ItemName, itemCosts, count, toSlot, ItemType)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	local count = tonumber(count)
	if ItemName ~= nil and itemCosts ~= nil then
		for k, v in pairs(itemCosts) do
			Player.removeInventoryItem(k, (v*count))
		end
		if ItemType == 'weapon' then
		  Player.addInventoryItem(ItemName, count, toSlot, {serie = tostring(Config.RandomInt(2) .. Config.RandomStr(3) .. Config.RandomInt(1) .. Config.RandomStr(2) .. Config.RandomInt(3) .. Config.RandomStr(4)), ammo = 1, quality = 100.0})
		else
		  Player.addInventoryItem(ItemName, count, toSlot)
		end
		Player.set("inventorydisabled", false)
		TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, false)
	end
end)

RegisterServerEvent("esx_inventory:server:SetIsOpenState")
AddEventHandler('esx_inventory:server:SetIsOpenState', function(IsOpen, type, id)
	if not IsOpen then
		if type == "stash" then
			Stashes[id].isOpen = false
		elseif type == "trunk" then
			Trunks[id].isOpen = false
		elseif type == "glovebox" then
			Gloveboxes[id].isOpen = false
		end
	end
end)

RegisterServerEvent("esx_inventory:server:OpenInventory")
AddEventHandler('esx_inventory:server:OpenInventory', function(name, id, other)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
		if name ~= nil and id ~= nil then
			local secondInv = {}
			if name == "stash" then
				if Stashes[id] ~= nil then
					if Stashes[id].isOpen then
						local Target = ESX.GetPlayerFromId(Stashes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('esx_inventory:client:CheckOpenState', Stashes[id].isOpen, name, id, Stashes[id].label)
						else
							Stashes[id].isOpen = false
						end
					end
				end
				local maxweight = 1000000
				local slots = 50
				if other ~= nil then 
					maxweight = other.maxweight ~= nil and other.maxweight or 1000000
					slots = other.slots ~= nil and other.slots or 50
				end
				secondInv.name = "stash-"..id
				secondInv.label = "Stash-"..id
				secondInv.maxweight = maxweight
				secondInv.inventory = {}
				secondInv.slots = slots
				if Stashes[id] ~= nil and Stashes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Stash-None"
					secondInv.maxweight = 1000000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local stashItems = GetStashItems(id)
					if next(stashItems) ~= nil then
						secondInv.inventory = stashItems
						Stashes[id] = {}
						Stashes[id].items = stashItems
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
					else
						Stashes[id] = {}
						Stashes[id].items = {}
						Stashes[id].isOpen = src
						Stashes[id].label = secondInv.label
					end
				end
			elseif name == "trunk" then
				if Trunks[id] ~= nil then
					if Trunks[id].isOpen then
						local Target = ESX.GetPlayerFromId(Trunks[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('esx_inventory:client:CheckOpenState', Trunks[id].isOpen, name, id, Trunks[id].label)
						else
							Trunks[id].isOpen = false
						end
					end
				end
				secondInv.name = "trunk-"..id
				secondInv.label = "Trunk-"..id
				secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
				secondInv.inventory = {}
				secondInv.slots = other.slots ~= nil and other.slots or 50
				if (Trunks[id] ~= nil and Trunks[id].isOpen) or (ESX.SplitStr(id, "PLZI")[2] ~= nil and Player.job.name ~= "police") then
					secondInv.name = "none-inv"
					secondInv.label = "Trunk-None"
					secondInv.maxweight = other.maxweight ~= nil and other.maxweight or 60000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					if id ~= nil then 
						local ownedItems = GetOwnedVehicleItems(id)
						if IsVehicleOwned(id) and next(ownedItems) ~= nil then
							secondInv.inventory = ownedItems
							Trunks[id] = {}
							Trunks[id].items = ownedItems
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						elseif Trunks[id] ~= nil and not Trunks[id].isOpen then
							secondInv.inventory = Trunks[id].items
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						else
							Trunks[id] = {}
							Trunks[id].items = {}
							Trunks[id].isOpen = src
							Trunks[id].label = secondInv.label
						end
					end
				end
			elseif name == "glovebox" then
				if Gloveboxes[id] ~= nil then
					if Gloveboxes[id].isOpen then
						local Target = ESX.GetPlayerFromId(Gloveboxes[id].isOpen)
						if Target ~= nil then
							TriggerClientEvent('esx_inventory:client:CheckOpenState', Gloveboxes[id].isOpen, name, id, Gloveboxes[id].label)
						else
							Gloveboxes[id].isOpen = false
						end
					end
				end
				secondInv.name = "glovebox-"..id
				secondInv.label = "Glovebox-"..id
				secondInv.maxweight = 10000
				secondInv.inventory = {}
				secondInv.slots = 5
				if Gloveboxes[id] ~= nil and Gloveboxes[id].isOpen then
					secondInv.name = "none-inv"
					secondInv.label = "Glovebox-None"
					secondInv.maxweight = 10000
					secondInv.inventory = {}
					secondInv.slots = 0
				else
					local ownedItems = GetOwnedVehicleGloveboxItems(id)
					if Gloveboxes[id] ~= nil and not Gloveboxes[id].isOpen then
						secondInv.inventory = Gloveboxes[id].items
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					elseif IsVehicleOwned(id) and next(ownedItems) ~= nil then
						secondInv.inventory = ownedItems
						Gloveboxes[id] = {}
						Gloveboxes[id].items = ownedItems
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					else
						Gloveboxes[id] = {}
						Gloveboxes[id].items = {}
						Gloveboxes[id].isOpen = src
						Gloveboxes[id].label = secondInv.label
					end
				end
			elseif name == "shop" then
				secondInv.name = "itemshop-"..id
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = SetupShopItems(id, other.items)
				ShopItems[id] = {}
				ShopItems[id].items = other.items
				secondInv.slots = #other.items
			elseif name == "crafting" then
				secondInv.name = "crafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "methcrafting" then
				secondInv.name = "methcrafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "cokecrafting" then
				secondInv.name = "cokecrafting"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "crafting_weapon" then
				secondInv.name = "crafting_weapon"
				secondInv.label = other.label
				secondInv.maxweight = 900000
				secondInv.inventory = other.items
				secondInv.slots = #other.items
			elseif name == "otherplayer" then
				local OtherPlayer = ESX.GetPlayerFromId(tonumber(id))
				if OtherPlayer ~= nil then
					secondInv.name = "otherplayer-"..id
					secondInv.label = "Player-"..id
					secondInv.maxweight = 250
					secondInv.inventory = OtherPlayer.inventory
					secondInv.slots = Config.MaxInventorySlots
					Citizen.Wait(250)
				end
			else
				if Drops[id] ~= nil and not Drops[id].isOpen then
					secondInv.name = id
					secondInv.label = "Dropped-"..tostring(id)
					secondInv.maxweight = 100000
					secondInv.inventory = Drops[id].items
					secondInv.slots = 15
					Drops[id].isOpen = src
					Drops[id].label = secondInv.label
				else
					secondInv.name = "none-inv"
					secondInv.label = "Dropped-None"
					secondInv.maxweight = 100000
					secondInv.inventory = {}
					secondInv.slots = 0
				end
			end
			TriggerClientEvent("esx_inventory:client:OpenInventory", src, Player.inventory, secondInv)
		else
			TriggerClientEvent("esx_inventory:client:OpenInventory", src, Player.inventory)
		end
end)

RegisterServerEvent("esx_inventory:server:SaveInventory")
AddEventHandler('esx_inventory:server:SaveInventory', function(type, id)
	if type == "trunk" then
		if (IsVehicleOwned(id)) then
			SaveOwnedVehicleItems(id, Trunks[id].items)
		else
			Trunks[id].isOpen = false
		end
	elseif type == "glovebox" then
		if (IsVehicleOwned(id)) then
			SaveOwnedGloveboxItems(id, Gloveboxes[id].items)
		else
			Gloveboxes[id].isOpen = false
		end
	elseif type == "stash" then
		SaveStashItems(id, Stashes[id].items)
	elseif type == "drop" then
		if Drops[id] ~= nil then
			Drops[id].isOpen = false
			if Drops[id].items == nil or next(Drops[id].items) == nil then
				Drops[id] = nil
				TriggerClientEvent("esx_inventory:client:RemoveDropItem", -1, id)
			end
		end
	end
end)

RegisterServerEvent("esx_inventory:server:UseItemSlot")
AddEventHandler('esx_inventory:server:UseItemSlot', function(slot)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	local itemData = Player.GetItemBySlot(slot)
	if itemData ~= nil then
		local itemInfo = ESX.Items[itemData.name]
		if itemData.type == "weapon" then
			if itemData.info.quality ~= nil then
				if itemData.info.quality ~= 0 then
					TriggerClientEvent("esx_inventory:client:UseWeapon", src, itemData, true)
				else
					TriggerClientEvent('esx:showNotification', src, "This weapon is broken..")
				end
			else
				TriggerClientEvent('esx:showNotification', src, "Didn't find a weapon quality??", "info")
			end
			TriggerClientEvent('esx_inventory:client:ItemBox', src, itemInfo, "use")
		elseif itemData.useable then
			TriggerClientEvent("esx:UseManiItem", src, itemData)
			TriggerClientEvent('esx_inventory:client:ItemBox', src, itemInfo, "use")
		end
	end
end)

RegisterServerEvent("esx_inventory:server:UseItem")
AddEventHandler('esx_inventory:server:UseItem', function(inventory, item)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	if inventory == "player" or inventory == "hotbar" then
		local itemData = Player.GetItemBySlot(item.slot)
		if itemData ~= nil then
			TriggerClientEvent('esx_inventory:client:ItemBox', src, ESX.Items[itemData.name], "use")
			TriggerClientEvent("esx:UseManiItem", src, itemData)
		end
	end
end)

RegisterServerEvent("esx_inventory:server:SetInventoryData")
AddEventHandler('esx_inventory:server:SetInventoryData', function(fromInventory, toInventory, fromSlot, toSlot, fromCount, toCount)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	local fromSlot = tonumber(fromSlot)
	local toSlot = tonumber(toSlot)

	if (fromInventory == "player" or fromInventory == "hotbar") and (ESX.SplitStr(toInventory, "-")[1] == "itemshop" or toInventory == "crafting") then
		return
	end

	if fromInventory == "player" or fromInventory == "hotbar" then
		local fromItemData = Player.GetItemBySlot(fromSlot)
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			elseif ESX.SplitStr(toInventory, "-")[1] == "otherplayer" then
				local playerId = tonumber(ESX.SplitStr(toInventory, "-")[2])
				local OtherPlayer = ESX.GetPlayerFromId(playerId)
				local toItemData = OtherPlayer.inventory[toSlot]
				Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.inventory[fromSlot] = toItemData
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						OtherPlayer.removeInventoryItem(itemInfo.name, toCount, fromSlot)
						Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
					end
				else
					local itemInfo = ESX.Items[fromItemData.name:lower()]
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				OtherPlayer.addInventoryItem(itemInfo.name, fromCount, toSlot, fromItemData.info)
			elseif ESX.SplitStr(toInventory, "-")[1] == "trunk" then
				local plate = ESX.SplitStr(toInventory, "-")[2]
				local toItemData = Trunks[plate].items[toSlot]
				Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.inventory[fromSlot] = toItemData
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						RemoveFromTrunk(plate, fromSlot, itemInfo.name, toCount)
						Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
					end
				else
					local itemInfo = ESX.Items[fromItemData.name:lower()]
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			elseif ESX.SplitStr(toInventory, "-")[1] == "glovebox" then
				local plate = ESX.SplitStr(toInventory, "-")[2]
				local toItemData = Gloveboxes[plate].items[toSlot]
				Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.inventory[fromSlot] = toItemData
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						RemoveFromGlovebox(plate, fromSlot, itemInfo.name, toCount)
						Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
					end
				else
					local itemInfo = ESX.Items[fromItemData.name:lower()]
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			elseif ESX.SplitStr(toInventory, "-")[1] == "stash" then
				local stashId = ESX.SplitStr(toInventory, "-")[2]
				local toItemData = Stashes[stashId].items[toSlot]
				Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					--Player.inventory[fromSlot] = toItemData
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						RemoveFromStash(stashId, fromSlot, itemInfo.name, toCount)
						Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
					end
				else
					local itemInfo = ESX.Items[fromItemData.name:lower()]
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			else
				-- drop
				toInventory = tonumber(toInventory)
				if toInventory == nil or toInventory == 0 then
					CreateNewDrop(src, fromSlot, toSlot, fromCount)
				else
					local toItemData = Drops[toInventory].items[toSlot]
					Player.removeInventoryItem(fromItemData.name, fromCount, fromSlot)
					TriggerClientEvent("esx_inventory:client:CheckWeapon", src, fromItemData.name)
					if toItemData ~= nil then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
						if toItemData.name ~= fromItemData.name then
							Player.addInventoryItem(toItemData.name, toCount, fromSlot, toItemData.info)
							RemoveFromDrop(toInventory, fromSlot, itemInfo.name, toCount)
						end
					else
						local itemInfo = ESX.Items[fromItemData.name:lower()]
					end
					local itemInfo = ESX.Items[fromItemData.name:lower()]
					AddToDrop(toInventory, toSlot, itemInfo.name, fromCount, fromItemData.info)
					if itemInfo.name == "radio" then
						TriggerClientEvent('PX_radio:onRadioDrop', src)
					end
				end
			end
		else
			TriggerClientEvent("esx:showNotification", src, "You dont have this item.")
		end
	elseif ESX.SplitStr(fromInventory, "-")[1] == "otherplayer" then
		local playerId = tonumber(ESX.SplitStr(fromInventory, "-")[2])
		local OtherPlayer = ESX.GetPlayerFromId(playerId)
		local fromItemData = OtherPlayer.inventory[fromSlot]
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			local itemInfo = ESX.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				OtherPlayer.removeInventoryItem(itemInfo.name, fromCount, fromSlot)
				TriggerClientEvent("esx_inventory:client:CheckWeapon", OtherPlayer.source, fromItemData.name)
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						OtherPlayer.addInventoryItem(itemInfo.name, toCount, fromSlot, toItemData.info)
					end
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			else
				local toItemData = OtherPlayer.inventory[toSlot]
				OtherPlayer.removeInventoryItem(itemInfo.name, fromCount, fromSlot)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						OtherPlayer.removeInventoryItem(itemInfo.name, toCount, toSlot)
						OtherPlayer.addInventoryItem(itemInfo.name, toCount, fromSlot, toItemData.info)
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				OtherPlayer.addInventoryItem(itemInfo.name, fromCount, toSlot, fromItemData.info)
			end
		else
			TriggerClientEvent("esx:showNotification", src, "No Item")
		end
	elseif ESX.SplitStr(fromInventory, "-")[1] == "trunk" then
		local plate = ESX.SplitStr(fromInventory, "-")[2]
		local fromItemData = Trunks[plate].items[fromSlot]
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			local itemInfo = ESX.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				RemoveFromTrunk(plate, fromSlot, itemInfo.name, fromCount)
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			else
				local toItemData = Trunks[plate].items[toSlot]
				RemoveFromTrunk(plate, fromSlot, itemInfo.name, fromCount)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						RemoveFromTrunk(plate, toSlot, itemInfo.name, toCount)
						AddToTrunk(plate, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToTrunk(plate, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			end
		else
			TriggerClientEvent("esx:showNotification", src, "No Item")
		end
	elseif ESX.SplitStr(fromInventory, "-")[1] == "glovebox" then
		local plate = ESX.SplitStr(fromInventory, "-")[2]
		local fromItemData = Gloveboxes[plate].items[fromSlot]
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			local itemInfo = ESX.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				RemoveFromGlovebox(plate, fromSlot, itemInfo.name, fromCount)
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			else
				local toItemData = Gloveboxes[plate].items[toSlot]
				RemoveFromGlovebox(plate, fromSlot, itemInfo.name, fromCount)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						RemoveFromGlovebox(plate, toSlot, itemInfo.name, toCount)
						AddToGlovebox(plate, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToGlovebox(plate, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			end
		else
			TriggerClientEvent("esx:showNotification", src, "No Item")
		end
	elseif ESX.SplitStr(fromInventory, "-")[1] == "stash" then
		local stashId = ESX.SplitStr(fromInventory, "-")[2]
		local fromItemData = Stashes[stashId].items[fromSlot]
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			local itemInfo = ESX.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				RemoveFromStash(stashId, fromSlot, itemInfo.name, fromCount)
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						AddToStash(stashId, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			else
				local toItemData = Stashes[stashId].items[toSlot]
				RemoveFromStash(stashId, fromSlot, itemInfo.name, fromCount)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						RemoveFromStash(stashId, toSlot, itemInfo.name, toCount)
						AddToStash(stashId, fromSlot, toSlot, itemInfo.name, toCount, toItemData.info)
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToStash(stashId, toSlot, fromSlot, itemInfo.name, fromCount, fromItemData.info)
			end
		else
			TriggerClientEvent("esx:showNotification", src, "No Item")
		end
	elseif ESX.SplitStr(fromInventory, "-")[1] == "itemshop" then
		local shopType = ESX.SplitStr(fromInventory, "-")[2]
		local itemData = ShopItems[shopType].items[fromSlot]
		local itemInfo = ESX.Items[itemData.name:lower()]
		local price = tonumber((itemData.price*fromCount))
		if ESX.SplitStr(shopType, "_")[1] == "custom" then
			if Player.removeMoney(price) then
				Player.addInventoryItem(itemData.name, fromCount, toSlot, itemData.info)
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, false)
				TriggerClientEvent('esx:showNotification', src, itemInfo.label .. " bought!")
			else
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('esx:showNotification', src, "You dont have enough cash..")
			end
		elseif ESX.SplitStr(shopType, "_")[1] == "police" then
			if Player.removeMoney(price) then
				Player.addInventoryItem(itemData.name, fromCount, toSlot, itemData.info)
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, false)
				TriggerClientEvent('esx:showNotification', src, itemInfo.label .. " bought!")
			else
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('esx:showNotification', src, "You dont have enough cash..")
			end
		elseif ESX.SplitStr(shopType, "_")[1] == "Itemshop" then
			if Player.removeMoney(price) then
				Player.addInventoryItem(itemData.name, fromCount, toSlot, itemData.info)
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, false)
				TriggerClientEvent('PX_stores:client:update:store', src, itemData, fromCount)
				TriggerClientEvent('esx:showNotification', src, itemInfo.label .. " bought!")
			else
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('esx:showNotification', src, "You dont have enough cash..")
			end
		else
			if Player.removeMoney(price) then
				Player.addInventoryItem(itemData.name, fromCount, toSlot, itemData.info)
				TriggerClientEvent('esx:showNotification', src, itemInfo.label .. " bought!")
			else
				TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
				TriggerClientEvent('esx:showNotification', src, "You dont have enough cash..")
			end
		end
	elseif fromInventory == "crafting" then
		local itemData = exports['PX_crafting']:GetCraftingConfig(fromSlot)
		if hasCraftItems(src, itemData.costs, fromCount) then
			Player.set("inventorydisabled", true)
			TriggerClientEvent("esx_inventory:client:CraftItems", src, itemData.name, itemData.costs, fromCount, toSlot, itemData.points)
		else
			TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('esx:showNotification', src, "No Item")
		end
	elseif fromInventory == "crafting_weapon" then
		local itemData = exports['PX_crafting']:GetWeaponCraftingConfig(fromSlot)
		if hasCraftItems(src, itemData.costs, fromCount) then
			Player.set("inventorydisabled", true)
			TriggerClientEvent("esx_inventory:client:CraftWeapon", src, itemData.name, itemData.costs, fromCount, toSlot, itemData.type)
		else
			TriggerClientEvent("esx_inventory:client:UpdatePlayerInventory", src, true)
			TriggerClientEvent('esx:showNotification', src, "No Item")
		end
	else
		-- drop
		fromInventory = tonumber(fromInventory)
		local fromItemData = Drops[fromInventory].items[fromSlot]
		local fromCount = tonumber(fromCount) ~= nil and tonumber(fromCount) or fromItemData.count
		if fromItemData ~= nil and fromItemData.count >= fromCount then
			local itemInfo = ESX.Items[fromItemData.name:lower()]
			if toInventory == "player" or toInventory == "hotbar" then
				local toItemData = Player.GetItemBySlot(toSlot)
				RemoveFromDrop(fromInventory, fromSlot, itemInfo.name, fromCount)
				if toItemData ~= nil then
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						Player.removeInventoryItem(toItemData.name, toCount, toSlot)
						AddToDrop(fromInventory, toSlot, itemInfo.name, toCount, toItemData.info)
						if itemInfo.name == "radio" then
							TriggerClientEvent('PX_radio:onRadioDrop', src)
						end
					end
				end
				Player.addInventoryItem(fromItemData.name, fromCount, toSlot, fromItemData.info)
			else
				toInventory = tonumber(toInventory)
				local toItemData = Drops[toInventory].items[toSlot]
				RemoveFromDrop(fromInventory, fromSlot, itemInfo.name, fromCount)
				--Player.inventory[toSlot] = fromItemData
				if toItemData ~= nil then
					local itemInfo = ESX.Items[toItemData.name:lower()]
					--Player.inventory[fromSlot] = toItemData
					local toCount = tonumber(toCount) ~= nil and tonumber(toCount) or toItemData.count
					if toItemData.name ~= fromItemData.name then
						local itemInfo = ESX.Items[toItemData.name:lower()]
						RemoveFromDrop(toInventory, toSlot, itemInfo.name, toCount)
						AddToDrop(fromInventory, fromSlot, itemInfo.name, toCount, toItemData.info)
						if itemInfo.name == "radio" then
							TriggerClientEvent('PX_radio:onRadioDrop', src)
						end
					end
				else
					--Player.inventory[fromSlot] = nil
				end
				local itemInfo = ESX.Items[fromItemData.name:lower()]
				AddToDrop(toInventory, toSlot, itemInfo.name, fromCount, fromItemData.info)
				if itemInfo.name == "radio" then
			    	TriggerClientEvent('PX_radio:onRadioDrop', src)
				end
			end
		else
			TriggerClientEvent("esx:showNotification", src, "Item does not exists??")
		end
	end
end)

function hasCraftItems(source, CostItems, count)
	local Player = ESX.GetPlayerFromId(source)
	for k, v in pairs(CostItems) do
		if Player.getInventoryItem(k) ~= nil then
			if Player.getInventoryItem(k).count < (v * count) then
				return false
			end
		else
			return false
		end
	end
	return true
end

function IsVehicleOwned(plate)
	local val = false
	local wait = promise.new()
	MySQL.query("SELECT * FROM `owned_vehicles` WHERE `plate` = '"..plate.."'", function(result)
		if (result[1] ~= nil) then
			val = true
			wait:resolve(val)
		else
			val = false
			wait:resolve(val)
		end
	end)
	return Citizen.Await(wait)
end

-- Shop Items
function SetupShopItems(shop, shopItems)
	local items = {}
	if shopItems ~= nil and next(shopItems) ~= nil then
		for k, item in pairs(shopItems) do
			local itemInfo = ESX.Items[item.name:lower()]
			items[item.slot] = {
				name = itemInfo.name,
				count = tonumber(item.count),
				info = item.info ~= nil and item.info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				price = item.price,
				image = itemInfo.image,
				slot = item.slot,
			}
		end
	end
	return items
end

-- Stash Items
function GetStashItems(stashId)
	local items = {}
		MySQL.query("SELECT * FROM `inventory_stash` WHERE `stash` = '"..stashId.."'", function(result)
			if result[1] ~= nil then 
				if result[1].items ~= nil then
					result[1].items = json.decode(result[1].items)
					if result[1].items ~= nil then 
						for k, item in pairs(result[1].items) do
							local itemInfo = ESX.Items[item.name:lower()]
							items[item.slot] = {
								name = itemInfo.name,
								count = tonumber(item.count),
								info = item.info ~= nil and item.info or "",
								label = itemInfo.label,
								description = itemInfo.description ~= nil and itemInfo.description or "",
								weight = itemInfo.weight, 
								type = itemInfo.type, 
								unique = itemInfo.unique, 
								useable = itemInfo.useable, 
								image = itemInfo.image,
								slot = item.slot,
							}
						end
					end
				end
			end
		end)
	return items
end

ESX.RegisterServerCallback('esx_inventory:server:GetStashItems', function(source, cb, stashId)
	cb(GetStashItems(stashId))
end)

RegisterServerEvent('esx_inventory:server:SaveStashItems')
AddEventHandler('esx_inventory:server:SaveStashItems', function(stashId, items)
	MySQL.query("SELECT * FROM `inventory_stash` WHERE `stash` = '"..stashId.."'", function(result)
		if result[1] ~= nil then
			MySQL.query("UPDATE `inventory_stash` SET `items` = '"..json.encode(items).."' WHERE `stash` = '"..stashId.."'")
		else
			MySQL.query("INSERT INTO `inventory_stash` (`stash`, `items`) VALUES ('"..stashId.."', '"..json.encode(items).."')")
		end
	end)
end)

function SaveStashItems(stashId, items)
	if Stashes[stashId].label ~= "Stash-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end
			MySQL.query("SELECT * FROM `inventory_stash` WHERE `stash` = '"..stashId.."'", function(result)
				if result[1] ~= nil then
					MySQL.query("UPDATE `inventory_stash` SET `items` = '"..json.encode(items).."' WHERE `stash` = '"..stashId.."'")
					Stashes[stashId].isOpen = false
				else
					MySQL.query("INSERT INTO `inventory_stash` (`stash`, `items`) VALUES ('"..stashId.."', '"..json.encode(items).."')")
					Stashes[stashId].isOpen = false
				end
			end)
		end
	end
end

function AddToStash(stashId, slot, otherslot, itemName, count, info)
	local count = tonumber(count)
	local ItemData = ESX.Items[itemName]
	if not ItemData.unique then
		if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
			Stashes[stashId].items[slot].count = Stashes[stashId].items[slot].count + count
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	else
		if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
			local itemInfo = ESX.Items[itemName:lower()]
			Stashes[stashId].items[otherslot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = otherslot,
			}
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Stashes[stashId].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	end
end

function RemoveFromStash(stashId, slot, itemName, count)
	local count = tonumber(count)
	if Stashes[stashId].items[slot] ~= nil and Stashes[stashId].items[slot].name == itemName then
		if Stashes[stashId].items[slot].count > count then
			Stashes[stashId].items[slot].count = Stashes[stashId].items[slot].count - count
		else
			Stashes[stashId].items[slot] = nil
			if next(Stashes[stashId].items) == nil then
				Stashes[stashId].items = {}
			end
		end
	else
		Stashes[stashId].items[slot] = nil
		if Stashes[stashId].items == nil then
			Stashes[stashId].items[slot] = nil
		end
	end
end

-- Trunk items
function GetOwnedVehicleItems(plate)
	local items = {}
	   MySQL.query("SELECT * FROM `owned_vehicles` WHERE `plate` = '"..plate.."'", function(result)
	   	if result[1] ~= nil then
	   		if result[1].trunkitems ~= nil then
	   			result[1].trunkitems = json.decode(result[1].trunkitems)
	   			if result[1].trunkitems ~= nil then 
	   				for k, item in pairs(result[1].trunkitems) do
	   					local itemInfo = ESX.Items[item.name:lower()]
	   					items[item.slot] = {
	   						name = itemInfo.name,
	   						count = tonumber(item.count),
	   						info = item.info ~= nil and item.info or "",
	   						label = itemInfo.label,
	   						description = itemInfo.description ~= nil and itemInfo.description or "",
	   						weight = itemInfo.weight, 
	   						type = itemInfo.type, 
	   						unique = itemInfo.unique, 
	   						useable = itemInfo.useable, 
	   						image = itemInfo.image,
	   						slot = item.slot,
	   					}
	   				end
	   			end
	   		end
	   	end
	   end)
	return items
end

function SaveOwnedVehicleItems(plate, items)
	if Trunks[plate].label ~= "Trunk-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			MySQL.query("SELECT * FROM `owned_vehicles` WHERE `plate` = '"..plate.."'", function(result)
				if result[1] ~= nil then
					MySQL.query("UPDATE `owned_vehicles` SET `trunkitems` = '"..json.encode(items).."' WHERE `plate` = '"..plate.."'", function(result) 
						Trunks[plate].isOpen = false
					end)
				else
					MySQL.query("INSERT INTO `owned_vehicles` (`plate`, `trunkitems`) VALUES ('"..plate.."', '"..json.encode(items).."')", function(result) 
						Trunks[plate].isOpen = false
					end)
				end
			end)
		end
	end
end

function AddToTrunk(plate, slot, otherslot, itemName, count, info)
	local count = tonumber(count)
	local ItemData = ESX.Items[itemName]

	if not ItemData.unique then
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			Trunks[plate].items[slot].count = Trunks[plate].items[slot].count + count
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	else
		if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
			local itemInfo = ESX.Items[itemName:lower()]
			Trunks[plate].items[otherslot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = otherslot,
			}
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Trunks[plate].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	end
end

function RemoveFromTrunk(plate, slot, itemName, count)
	if Trunks[plate].items[slot] ~= nil and Trunks[plate].items[slot].name == itemName then
		if Trunks[plate].items[slot].count > count then
			Trunks[plate].items[slot].count = Trunks[plate].items[slot].count - count
		else
			Trunks[plate].items[slot] = nil
			if next(Trunks[plate].items) == nil then
				Trunks[plate].items = {}
			end
		end
	else
		Trunks[plate].items[slot]= nil
		if Trunks[plate].items == nil then
			Trunks[plate].items[slot] = nil
		end
	end
end

-- Glovebox items
function GetOwnedVehicleGloveboxItems(plate)
	local items = {}
	MySQL.query("SELECT * FROM `owned_vehicles` WHERE `plate` = '"..plate.."'", function(result)
			if result[1] ~= nil then 
				if result[1].gloveboxitems ~= nil then
					result[1].gloveboxitems = json.decode(result[1].gloveboxitems)
					if result[1].gloveboxitems ~= nil then 
						for k, item in pairs(result[1].gloveboxitems) do
							local itemInfo = ESX.Items[item.name:lower()]
							items[item.slot] = {
								name = itemInfo.name,
								count = tonumber(item.count),
								info = item.info ~= nil and item.info or "",
								label = itemInfo.label,
								description = itemInfo.description ~= nil and itemInfo.description or "",
								weight = itemInfo.weight, 
								type = itemInfo.type, 
								unique = itemInfo.unique, 
								useable = itemInfo.useable, 
								image = itemInfo.image,
								slot = item.slot,
							}
						end
					end
				end
			end
		end)
	return items
end

function SaveOwnedGloveboxItems(plate, items)
	if Gloveboxes[plate].label ~= "Glovebox-None" then
		if items ~= nil then
			for slot, item in pairs(items) do
				item.description = nil
			end

			MySQL.query("SELECT * FROM `owned_vehicles` WHERE `plate` = '"..plate.."'", function(result)
				if result[1] ~= nil then
					MySQL.query("UPDATE `owned_vehicles` SET `gloveboxitems` = '"..json.encode(items).."' WHERE `plate` = '"..plate.."'", function(result) 
						Gloveboxes[plate].isOpen = false
					end)
				else
					MySQL.query("INSERT INTO `owned_vehicles` (`plate`, `gloveboxitems`) VALUES ('"..plate.."', '"..json.encode(items).."')", function(result) 
						Gloveboxes[plate].isOpen = false
					end)
				end
			end)
		end
	end
end

function AddToGlovebox(plate, slot, otherslot, itemName, count, info)
	local count = tonumber(count)
	local ItemData = ESX.Items[itemName]

	if not ItemData.unique then
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			Gloveboxes[plate].items[slot].count = Gloveboxes[plate].items[slot].count + count
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	else
		if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
			local itemInfo = ESX.Items[itemName:lower()]
			Gloveboxes[plate].items[otherslot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = otherslot,
			}
		else
			local itemInfo = ESX.Items[itemName:lower()]
			Gloveboxes[plate].items[slot] = {
				name = itemInfo.name,
				count = count,
				info = info ~= nil and info or "",
				label = itemInfo.label,
				description = itemInfo.description ~= nil and itemInfo.description or "",
				weight = itemInfo.weight, 
				type = itemInfo.type, 
				unique = itemInfo.unique, 
				useable = itemInfo.useable, 
				image = itemInfo.image,
				slot = slot,
			}
		end
	end
end

function RemoveFromGlovebox(plate, slot, itemName, count)
	if Gloveboxes[plate].items[slot] ~= nil and Gloveboxes[plate].items[slot].name == itemName then
		if Gloveboxes[plate].items[slot].count > count then
			Gloveboxes[plate].items[slot].count = Gloveboxes[plate].items[slot].count - count
		else
			Gloveboxes[plate].items[slot] = nil
			if next(Gloveboxes[plate].items) == nil then
				Gloveboxes[plate].items = {}
			end
		end
	else
		Gloveboxes[plate].items[slot]= nil
		if Gloveboxes[plate].items == nil then
			Gloveboxes[plate].items[slot] = nil
		end
	end
end

-- Drop items
function AddToDrop(dropId, slot, itemName, count, info)
	local count = tonumber(count)
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		Drops[dropId].items[slot].count = Drops[dropId].items[slot].count + count
	else
		local itemInfo = ESX.Items[itemName:lower()]
		Drops[dropId].items[slot] = {
			name = itemInfo.name,
			count = count,
			info = info ~= nil and info or "",
			label = itemInfo.label,
			description = itemInfo.description ~= nil and itemInfo.description or "",
			weight = itemInfo.weight, 
			type = itemInfo.type, 
			unique = itemInfo.unique, 
			useable = itemInfo.useable, 
			image = itemInfo.image,
			slot = slot,
			id = dropId,
		}
	end
end

function RemoveFromDrop(dropId, slot, itemName, count)
	if Drops[dropId].items[slot] ~= nil and Drops[dropId].items[slot].name == itemName then
		if Drops[dropId].items[slot].count > count then
			Drops[dropId].items[slot].count = Drops[dropId].items[slot].count - count
		else
			Drops[dropId].items[slot] = nil
			if next(Drops[dropId].items) == nil then
				Drops[dropId].items = {}
			end
		end
	else
		Drops[dropId].items[slot] = nil
		if Drops[dropId].items == nil then
			Drops[dropId].items[slot] = nil
		end
	end
end

function CreateDropId()
	if Drops ~= nil then
		local id = math.random(10000, 99999)
		local dropid = id
		while Drops[dropid] ~= nil do
			id = math.random(10000, 99999)
			dropid = id
		end
		return dropid
	else
		local id = math.random(10000, 99999)
		local dropid = id
		return dropid
	end
end

function CreateNewDrop(source, fromSlot, toSlot, itemCount)
	local Player = ESX.GetPlayerFromId(source)
	local itemData = Player.GetItemBySlot(fromSlot)
	if Player.removeInventoryItem(itemData.name, itemCount, itemData.slot) then
		TriggerClientEvent("esx_inventory:client:CheckWeapon", source, itemData.name)
		local itemInfo = ESX.Items[itemData.name:lower()]
		local dropId = CreateDropId()
		Drops[dropId] = {}
		Drops[dropId].items = {}

		Drops[dropId].items[toSlot] = {
			name = itemInfo.name,
			count = itemCount,
			info = itemData.info ~= nil and itemData.info or "",
			label = itemInfo.label,
			description = itemInfo.description ~= nil and itemInfo.description or "",
			weight = itemInfo.weight, 
			type = itemInfo.type, 
			unique = itemInfo.unique, 
			useable = itemInfo.useable, 
			image = itemInfo.image,
			slot = toSlot,
			id = dropId,
		}
		TriggerClientEvent("esx_inventory:client:DropItemAnim", source)
		TriggerClientEvent("esx_inventory:client:AddDropItem", -1, dropId, source)
		if itemData.name:lower() == "radio" then
			TriggerClientEvent('PX_radio:onRadioDrop', source)
		end
	else
		TriggerClientEvent("esx:showNotification", src, "You dont have the item!")
		return
	end
end

TriggerEvent('es:addAdminCommand', 'giveitem', 8, function(source, args, user)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.get("aduty") then
		local Player = ESX.GetPlayerFromId(tonumber(args[1]))
		local count = tonumber(args[3])
		local itemData = ESX.Items[tostring(args[2]):lower()]
		if Player ~= nil then
			if count > 0 then
				if itemData ~= nil then
					if Player.addInventoryItem(itemData.name, count, false) then
						TriggerClientEvent('esx:showNotification', source, "You gave " ..GetPlayerName(tonumber(args[1])).." " .. itemData.name .. " ("..count.. ")")
					else
						TriggerClientEvent('esx:showNotification', source,  "Can not give the item")
					end
				else
					TriggerClientEvent('chatMessage', source, "[SYSTEM] ", {255, 0, 0}, "Item does not exist!")
				end
			else
				TriggerClientEvent('chatMessage', source, "[SYSTEM] ", {255, 0, 0}, "Count has to be higher then 0!")
			end
		else
			TriggerClientEvent('chatMessage', source, "[SYSTEM] ", {255, 0, 0}, "Player not online")
		end
	else
		TriggerClientEvent('chatMessage', source, "[SYSTEM]", {255, 0, 0}, " ^0Shoma nemitavanid dar halat ^1OffDuty ^0az command haye admini estefade konid!")
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = "Give Item", params = {{name = "id", help = "ID Player"}, {name = "item", help = "Item Name"}, {name = "amount", help = "Amount"}}})

RegisterServerEvent("esx_inventory:givecash")
AddEventHandler("esx_inventory:givecash", function(id, numb)
	if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(id))) >= 5 then return end
	local xPlayer = ESX.GetPlayerFromId(source)
	local zPlayer = ESX.GetPlayerFromId(id)
	local cash = tonumber(numb)
	if xPlayer.money >= cash then
		TriggerClientEvent("esx_inventory:doCashAnimation", xPlayer.source)
		xPlayer.removeMoney(cash)
		zPlayer.addMoney(cash)
		TriggerClientEvent("esx:showNotification", zPlayer.source, "Shoma "..cash.."$ Daryaft Kardid!")
	else
		TriggerClientEvent("esx:showNotification", source, "Shoma Pool Kafi Nadarid!")
	end
end)

ESX.RegisterUsableItem("id-card", function(source, item)
	local Player = ESX.GetPlayerFromId(source)
	if Player.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("esx_inventory:ShowId", -1, source, item.info)
    end
end)
