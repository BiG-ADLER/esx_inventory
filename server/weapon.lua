ESX.RegisterUsableItem("pistol-ammo", function(source, item)
	local Player = ESX.GetPlayerFromId(source)
	if Player.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent('esx_weapons:client:reload:ammo', source, 'AMMO_PISTOL', 'pistol-ammo')
    end
end)

ESX.RegisterUsableItem("rifle-ammo", function(source, item)
	local Player = ESX.GetPlayerFromId(source)
	if Player.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent('esx_weapons:client:reload:ammo', source, 'AMMO_RIFLE', 'rifle-ammo')
    end
end)

ESX.RegisterUsableItem("smg-ammo", function(source, item)
	local Player = ESX.GetPlayerFromId(source)
	if Player.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent('esx_weapons:client:reload:ammo', source, 'AMMO_SMG', 'smg-ammo')
    end
end)

ESX.RegisterUsableItem("shotgun-ammo", function(source, item)
	local Player = ESX.GetPlayerFromId(source)
	if Player.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent('esx_weapons:client:reload:ammo', source, 'AMMO_SHOTGUN', 'shotgun-ammo')
    end
end)

ESX.RegisterUsableItem("pistol_suppressor", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "suppressor")
end)

ESX.RegisterUsableItem("pistol_extendedclip", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "extendedclip")
end)

ESX.RegisterUsableItem("rifle_suppressor", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "suppressor")
end)

ESX.RegisterUsableItem("rifle_extendedclip", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "extendedclip")
end)

ESX.RegisterUsableItem("rifle_flashlight", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "flashlight")
end)

ESX.RegisterUsableItem("rifle_grip", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "grip")
end)

ESX.RegisterUsableItem("rifle_scope", function(source, item)
    local Player = ESX.GetPlayerFromId(source)
    TriggerClientEvent("esx_weapons:client:EquipAttachment", source, item, "scope")
end)

RegisterServerEvent('esx_weapons:server:UpdateWeaponQuality')
AddEventHandler('esx_weapons:server:UpdateWeaponQuality', function(data, RepeatAmount)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local WeaponData = Config.WeaponsList[GetHashKey(data.name)]
    local WeaponSlot = Player.inventory[data.slot]
    local DecreaseAmount = Config.DurabilityMultiplier[data.name]
    if WeaponSlot ~= nil then
        if not IsWeaponBlocked(WeaponData['IdName']) then
            if WeaponSlot.info.quality ~= nil then
                for i = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('esx_inventory:client:UseWeapon', src, data)
                        TriggerClientEvent('esx:showNotification', src, "Your weapon is broken.", 'error')
                        break
                    end
                end
            else
                WeaponSlot.info.quality = 100
                for i = 1, RepeatAmount, 1 do
                    if WeaponSlot.info.quality - DecreaseAmount > 0 then
                        WeaponSlot.info.quality = WeaponSlot.info.quality - DecreaseAmount
                    else
                        WeaponSlot.info.quality = 0
                        TriggerClientEvent('esx_inventory:client:UseWeapon', src, data)
                        TriggerClientEvent('esx:showNotification', src, "Your weapon is broken!", 'error')
                        break
                    end
                end
            end
        end
    end
    Player.setInventoryItem(Player.inventory)
end)

RegisterServerEvent("esx_weapons:server:EquipAttachment")
AddEventHandler("esx_weapons:server:EquipAttachment", function(ItemData, CurrentWeaponData, AttachmentData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local Inventory = Player.inventory
    local GiveBackItem = nil
    if Inventory[CurrentWeaponData.slot] ~= nil then
        if Inventory[CurrentWeaponData.slot].info.attachments ~= nil and next(Inventory[CurrentWeaponData.slot].info.attachments) ~= nil then
            local HasAttach, key = HasAttachment(AttachmentData.component, Inventory[CurrentWeaponData.slot].info.attachments)
            if not HasAttach then
                if CurrentWeaponData.name == "weapon_compactrifle" then
                    local component = "COMPONENT_COMPACTRIFLE_CLIP_03"
                    if AttachmentData.component == "COMPONENT_COMPACTRIFLE_CLIP_03" then
                        component = "COMPONENT_COMPACTRIFLE_CLIP_02"
                    end
                    for k, v in pairs(Inventory[CurrentWeaponData.slot].info.attachments) do
                        if v.component == component then
                            local has, key = HasAttachment(component, Inventory[CurrentWeaponData.slot].info.attachments)
                            local item = GetAttachmentItem(CurrentWeaponData.name:upper(), component)
                            GiveBackItem = tostring(item):lower()
                            table.remove(Inventory[CurrentWeaponData.slot].info.attachments, key)
                        end
                    end
                end
                table.insert(Inventory[CurrentWeaponData.slot].info.attachments, {
                    component = AttachmentData.component,
                    label = AttachmentData.label,
                })
                TriggerClientEvent("esx_weapons:client:addAttachment", src, AttachmentData.component)
                Player.setInventoryItem(Player.inventory)
                Player.removeInventoryItem(ItemData.name, 1)
            else
                TriggerClientEvent("esx:showNotification", src, "You already have one "..AttachmentData.label:lower().."  on your gun..", "error")
            end
        else
            Inventory[CurrentWeaponData.slot].info.attachments = {}
            table.insert(Inventory[CurrentWeaponData.slot].info.attachments, {
                component = AttachmentData.component,
                label = AttachmentData.label,
            })
            TriggerClientEvent("esx_weapons:client:addAttachment", src, AttachmentData.component)
            Player.setInventoryItem(Player.inventory)
            Player.removeInventoryItem(ItemData.name, 1)
        end
    end
    if GiveBackItem ~= nil then
        Player.addInventoryItem(GiveBackItem, 1, false)
        GiveBackItem = nil
    end
end)

RegisterServerEvent("esx_weapons:server:SetWeaponQuality")
AddEventHandler("esx_weapons:server:SetWeaponQuality", function(data, hp)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local WeaponData = ESX.Weapons[GetHashKey(data.name)]
    local WeaponSlot = Player.inventory[data.slot]
    local DecreaseAmount = Config.DurabilityMultiplier[data.name]
    WeaponSlot.info.quality = hp
    Player.setInventoryItem(Player.inventory)
end)

RegisterServerEvent("esx_weapons:server:UpdateWeaponAmmo")
AddEventHandler('esx_weapons:server:UpdateWeaponAmmo', function(CurrentWeaponData, amount)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local amount = tonumber(amount)
    if CurrentWeaponData ~= nil then
        if Player.inventory[CurrentWeaponData.slot] ~= nil then
            Player.inventory[CurrentWeaponData.slot].info.ammo = amount
        end
        Player.setInventoryItem(Player.inventory)
    end
end)

ESX.RegisterServerCallback("esx_weapon:server:GetWeaponAmmo", function(source, cb, WeaponData)
    local Player = ESX.GetPlayerFromId(source)
    local retval = 0
    if WeaponData ~= nil then
        if Player ~= nil then
            local ItemData = Player.GetItemBySlot(WeaponData.slot)
            if ItemData ~= nil then
                retval = ItemData.info.ammo ~= nil and ItemData.info.ammo or 0
            end
        end
    end
    cb(retval)
end)

ESX.RegisterServerCallback('esx_weapons:server:RemoveAttachment', function(source, cb, AttachmentData, ItemData)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local Inventory = Player.inventory
    local AttachmentComponent = Config.WeaponAttachments[ItemData.name:upper()][AttachmentData.attachment]
    if Inventory[ItemData.slot] ~= nil then
        if Inventory[ItemData.slot].info.attachments ~= nil and next(Inventory[ItemData.slot].info.attachments) ~= nil then
            local HasAttach, key = HasAttachment(AttachmentComponent.component, Inventory[ItemData.slot].info.attachments)
            if HasAttach then
                table.remove(Inventory[ItemData.slot].info.attachments, key)
                Player.setInventoryItem(Player.inventory)
                Player.addInventoryItem(AttachmentComponent.item, 1)
                cb(Inventory[ItemData.slot].info.attachments)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

function IsWeaponBlocked(WeaponName)
  local retval = false
  for _, name in pairs(Config.DurabilityBlockedWeapons) do
      if name == WeaponName then
          retval = true
          break
      end
  end
  return retval
end

function HasAttachment(component, attachments)
    local retval = false
    local key = nil
    for k, v in pairs(attachments) do
        if v.component == component then
            key = k
            retval = true
        end
    end
    return retval, key
end

function GetWeaponList(Weapon)
    return Config.WeaponsList[Weapon]
end