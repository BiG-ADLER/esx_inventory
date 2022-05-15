--Help For Inventory to use ESX FrameWork

-- Add All Code in your Core (es_extended, essentialmode, etc...)

-- First in login.lua (get info of player from databse) add this:

function loaduser(user)  -- this function is exist in your file but maybe name of function be different
    if user.inventory then
        user.inventory = json.decode(user.inventory)
    else
        user.inventory = {}
    end

    Users[source] = CreatePlayer(Source, user.inventory) -- its already exist too and you should add inventory to that
end

-- Then open classes/player.lua (All code are exist and you sould edit them)

function CreatePlayer(source, inventory)

    local self = {}

    self.source = source
    self.inventory = {}
    self.inventorydisabled  = false

    self.set = function(k, v)
		if k == "aduty" then
			local temp = v
			if temp == 1 then
				temp = true
			elseif temp == 0 then
				temp = false
			end
		end
		self[k] = v
	end

	self.get = function(k)
		return self[k]
	end

    if inventory ~= nil then
		for _, item in pairs(inventory) do
			local iteminfo = ESX.Items[item.name]
			if iteminfo then
				self.inventory[item.slot] = {
					name = iteminfo.name,
					count = item.count,
					info = item.info ~= nil and item.info or "",
					label = iteminfo.label,
					description = "",
					weight = iteminfo.weight,
					type = iteminfo.type,
					unique = iteminfo.unique,
					useable = ESX.UsableItemsCallbacks[item.name] ~= nil,
					image = iteminfo.image,
					shouldClose = iteminfo.shouldClose,
					slot = item.slot,
					combinable = iteminfo.combinable,
				}
			else
				print(('Inventory: invalid item "%s" removed!'):format(item.name))
			end
		end
	end

    self.getInventoryItem = function(check)
		local Item = {}
		local count = 0
		local inventoryMe = self.inventory
		if inventoryMe ~= nil and next(inventoryMe) ~= nil then
			for slot, item in pairs(inventoryMe) do
				if inventoryMe[slot] ~= nil then
					if item.name == check then
						count = count + item.count
					end
				end
			end
		end
		Item.count = count
		return Item
	end

    self.GetItemByName = function(item)
		local item = tostring(item):lower()
		local slot = ESX.GetFirstSlotByItem(self.inventory, item)
		if slot ~= nil then
			return self.inventory[slot]
		end
		return nil
	end

	self.GetItemBySlot = function(slot)
		local slot = tonumber(slot)
		if self.inventory[slot] ~= nil then
			return self.inventory[slot]
		end
		return nil
	end

    self.addInventoryItem = function(item, amount, slot, info)
		local totalWeight = ESX.GetTotalWeight(self.inventory)
		local itemInfo = ESX.Items[item:lower()]
		if itemInfo == nil then return end
		local amount = tonumber(amount)
		local slot = tonumber(slot) ~= nil and tonumber(slot) or ESX.GetFirstSlotByItem(self.inventory, item)
		if itemInfo.type == "weapon" and (info == nil or info.quality == nil) then
			amount = 1
			info = {
				serie = "No Serie",
				quality = 100
			}
		elseif itemInfo.name == 'id-card' and info == nil then
			info = {}
			info.identifier = self.identifier
			info.firstname = self.firstname
			info.lastname = self.lastname
		end
		if (totalWeight + (itemInfo.weight * amount)) <= 150000 then
			if (slot ~= nil and self.inventory[slot] ~= nil) and (self.inventory[slot].name:lower() == item:lower()) and (itemInfo.type == "item" and not itemInfo.unique) then
				self.inventory[slot].count = self.inventory[slot].count + amount
				TriggerEvent("esx:onAddInventoryItem", self.source, item, amount)
				return true
			elseif (not itemInfo.unique and slot or slot ~= nil and self.inventory[slot] == nil) then
				self.inventory[slot] = {name = itemInfo.name, count = amount, info = info ~= nil and info or "", label = itemInfo.label, description = "", weight = itemInfo.weight, type = itemInfo.type, unique = itemInfo.unique, useable = itemInfo.useable, image = itemInfo.image, shouldClose = itemInfo.shouldClose, slot = slot, combinable = itemInfo.combinable}
				TriggerEvent("esx:onAddInventoryItem", self.source, item, amount)
				return true
			elseif (itemInfo.unique) or (not slot or slot == nil) or (itemInfo.type == "weapon") then
				for i = 1, 25, 1 do
					if self.inventory[i] == nil then
						self.inventory[i] = {name = itemInfo.name, count = amount, info = info ~= nil and info or "", label = itemInfo.label, description = "", weight = itemInfo.weight, type = itemInfo.type, unique = itemInfo.unique, useable = itemInfo.useable, image = itemInfo.image, shouldClose = itemInfo.shouldClose, slot = i, combinable = itemInfo.combinable}
						TriggerEvent("esx:onAddInventoryItem", self.source, item, amount)
						return true
					end
				end
			end
		end
		return false
	end

	self.removeInventoryItem = function(item, amount, slot)
		local amount = tonumber(amount)
		local slot = tonumber(slot)
		if slot ~= nil then
			if self.inventory[slot].count > amount then
				self.inventory[slot].count = self.inventory[slot].count - amount
				local event = {name = self.inventory[slot].name, count = self.inventory[slot].count}
				TriggerEvent("esx:onRemoveInventoryItem", self.source, event, amount)
				return true
			else
				local event = {name = self.inventory[slot].name, count = 0}
				TriggerEvent("esx:onRemoveInventoryItem", self.source, event, amount)
				self.inventory[slot] = nil
				return true
			end
		else
			local slots = ESX.GetSlotsByItem(self.inventory, item)
			local amountToRemove = amount
			if slots ~= nil then
				for _, slot in pairs(slots) do
					if self.inventory[slot].count > amountToRemove then
						self.inventory[slot].count = self.inventory[slot].count - amountToRemove
						local event = {name = self.inventory[slot].name, count = self.inventory[slot].count}
						TriggerEvent("esx:onRemoveInventoryItem", self.source, event, amount)
						return true
					elseif self.inventory[slot].count == amountToRemove then
						local event = {name = self.inventory[slot].name, count = 0}
						TriggerEvent("esx:onRemoveInventoryItem", self.source, event, amount)
						self.inventory[slot] = nil
						return true
					end
				end
			end
		end
		return false
	end

    self.setInventoryItem = function(items)
		self.inventory = items
	end

	self.ClearInventory = function()
		self.inventory = {}
	end
end

-- Then add this to server/functions.lua

ESX.GetTotalWeight = function(items)
	local weight = 0
	if items ~= nil then
		for slot, item in pairs(items) do
			weight = weight + (item.weight * item.count)
		end
	end
	return tonumber(weight)
end

ESX.GetSlotsByItem = function(items, itemName)
	local slotsFound = {}
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				table.insert(slotsFound, slot)
			end
		end
	end
	return slotsFound
end

ESX.GetFirstSlotByItem = function(items, itemName)
	if items ~= nil then
		for slot, item in pairs(items) do
			if item.name:lower() == itemName:lower() then
				return tonumber(slot)
			end
		end
	end
	return nil
end

-- Also edit these in server/functions.lua

ESX.RegisterUsableItem = function(item, cb)
	ESX.UsableItemsCallbacks[item] = cb
end

ESX.UseItem = function(source, item)
	ESX.UsableItemsCallbacks[item.name](source, item)
end

ESX.GetItemLabel = function(item)
	if ESX.Items[item] ~= nil then
		return ESX.Items[item].label
	end
end

-- and in drop player event handler for save player data in database use this (edit only)

AddEventHandler('playerDropped', function(resoan)
	local Source = source
	if(Users[Source])then
		TriggerEvent("esx:playerDropped", Source, Users[Source])
		local invent = {}
		local inventoryMe = Users[Source].inventory
		if inventoryMe ~= nil and next(inventoryMe) ~= nil then
			for slot, item in pairs(inventoryMe) do
				if inventoryMe[slot] ~= nil then
					table.insert(invent, {
						name = item.name,
						count = item.count,
						info = item.info,
						type = item.type,
						slot = slot,
					})
				end
			end
		end
		MySQL.update('UPDATE users SET `inventory` = @inventory WHERE identifier = @identifier',
		{
			['@inventory']  = json.encode(invent),
			['@identifier']	= Users[Source].identifier
		})

		Users[Source] = nil
	end
end)

-- and add this 2 event to server side on your core

RegisterServerEvent("esx:RemoveItem")
AddEventHandler('esx:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = ESX.GetPlayerFromId(src)
	Player.removeInventoryItem(itemName, amount, slot)
end)

ESX.RegisterServerCallback('esx:HasItem', function(source, cb, itemName)
	local Player = ESX.GetPlayerFromId(source)
	if Player ~= nil then
		if Player.GetItemByName(itemName) ~= nil then
			cb(true)
		else
			cb(false)
		end
	end
end)

-- and edit this code on your server side of core

RegisterServerEvent('esx:useItem')
AddEventHandler('esx:useItem', function(data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if data.count > 0 then
		ESX.UseItem(source, data)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, "No Have Item")
	end
end)

-- and add this to your client side of your core

RegisterNetEvent("esx:UseManiItem")
AddEventHandler("esx:UseManiItem", function(data)
	TriggerServerEvent("esx:useItem", data)
end)


-- and replace this in your shared/functions.lua

local Charset = {}
local ICharset = {}

for i = 48,  57 do table.insert(ICharset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

ESX.GetRandomString = function(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return ESX.GetRandomString(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

ESX.GetRandomInt = function(length)
	math.randomseed(GetGameTimer())

	if length > 0 then
		return ESX.GetRandomInt(length - 1) .. ICharset[math.random(1, #ICharset)]
	else
		return ''
	end
end

ESX.GetConfig = function()
	return Config
end

ESX.FirstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

ESX.TableContainsValue = function(table, value)
	for k, v in pairs(table) do
		if v == value then
			return true
		end
	end

	return false
end

ESX.dump = function(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == 'table' then
		local s = ''
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = '{\n'
		for k,v in pairs(table) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. '['..k..'] = ' .. ESX.dump(v, nb + 1) .. ',\n'
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. '}'
	else
		return tostring(table)
	end
end

ESX.Round = function(value, numDecimalPlaces)
	return ESX.Math.Round(value, numDecimalPlaces)
end

ESX.SplitStr = function(str, delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( str, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( str, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( str, delimiter, from  )
	end
	table.insert( result, string.sub( str, from  ) )
	return result
end

-- and at the end add shared.lua in esx_inventory to core(es_extneded, essentialmode, ...)/shared/ and start in fxmanifest

--for open other player inventory use:

TriggerServerEvent("esx_inventory:server:OpenInventory", "otherplayer", playerId)
TriggerEvent("esx_inventory:server:RobPlayer", playerId)

--for open stash use:

TriggerServerEvent("esx_inventory:server:OpenInventory", "stash", "stash_"..everything) -- you can replace everything with stash name for examle job name or identifier
TriggerEvent("esx_inventory:client:SetCurrentStash", "stash_"..everything)

-- for create shop use:

Items = {
	label = "Police Gun Safe",
	slots = 5,
	items = {
		[1] = {
		  name = "weapon_pistol_mk2",
		  price = 500,
		  count = 1,
		  info = {
			  serie = "LSPD"..math.random(1000000, 10000000),
			  melee = false,
			  quality = 100.0,
			  attachments = {{component = "COMPONENT_AT_PI_FLSH_02", label = "Flashlight"}}
		  },
		  type = "weapon",
		  slot = 1,
		},
		[2] = {
		  name = "weapon_carbinerifle_mk2",
		  price = 1000,
		  count = 1,
		  info = {
			serie = "LSPD"..math.random(1000000, 10000000),
			melee = false,
			quality = 100.0,
			attachments = {{component = "COMPONENT_AT_SCOPE_MEDIUM_MK2", label = "Scope"}, {component = "COMPONENT_AT_MUZZLE_05", label = "Muzzle Demper"}, {component = "COMPONENT_AT_AR_AFGRIP_02", label = "Grip"}, {component = "COMPONENT_AT_AR_FLSH", label = "Falshlight"}}    
		  },
		  type = "weapon",
		  slot = 2,
		},
		[3] = {
		  name = "pistol-ammo",
		  price = 50,
		  count = 50,
		  info = {},
		  type = "item",
		  slot = 3,
		},
		[4] = {
		  name = "rifle-ammo",
		  price = 150,
		  count = 50,
		  info = {},
		  type = "item",
		  slot = 4,
		},
		[5] = {
		  name = "radio",
		  price = 300,
		  count = 50,
		  info = {},
		  type = "item",
		  slot = 5,
		}
	}
}

TriggerServerEvent("esx_inventory:server:OpenInventory", "shop", police, Items) --you can replace police with shop name and it can be everything but you should add in inventory server side
