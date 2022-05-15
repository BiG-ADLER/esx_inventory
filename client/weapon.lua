Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            local Weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
            local WeaponBullets = GetAmmoInPedWeapon(GetPlayerPed(-1), Weapon)
            if Config.WeaponsList[Weapon] ~= nil and Config.WeaponsList[Weapon]['AmmoType'] ~= nil then
               if Config.WeaponsList[Weapon]['IdName'] ~= 'weapon_unarmed' then
                if IsPedShooting(GetPlayerPed(-1)) or IsPedPerformingMeleeAction(GetPlayerPed(-1)) then
                    if Config.WeaponsList[Weapon]['IdName'] == 'weapon_molotov' then
                        TriggerServerEvent('esx:RemoveItem', 'weapon_molotov', 1)
                        TriggerEvent('esx_weapons:client:set:current:weapon', nil)
                    else
                        TriggerServerEvent("esx_weapons:server:UpdateWeaponQuality", Config.CurrentWeaponData, 1)
                        if WeaponBullets == 1 then
                          TriggerServerEvent("esx_weapons:server:UpdateWeaponAmmo", Config.CurrentWeaponData, 1)
                        else
                          TriggerServerEvent("esx_weapons:server:UpdateWeaponAmmo", Config.CurrentWeaponData, tonumber(WeaponBullets))
                        end
                    end
                end
                if Config.WeaponsList[Weapon]['AmmoType'] ~= 'AMMO_FIRE' then
                  if IsPedArmed(GetPlayerPed(-1), 6) then
                    if WeaponBullets == 1 then
                        DisableControlAction(0, 24, true) 
                        DisableControlAction(0, 257, true)
                        if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                            SetPlayerCanDoDriveBy(PlayerId(), false)
                        end
                    else
                        EnableControlAction(0, 24, true) 
                        EnableControlAction(0, 257, true)
                        if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                            SetPlayerCanDoDriveBy(PlayerId(), true)
                        end
                    end
                  else
                      Citizen.Wait(1000)
                  end
                end
            else
                Citizen.Wait(1000)
            end
          end
        end
    end
end)

RegisterNetEvent('esx_weapons:client:set:current:weapon')
AddEventHandler('esx_weapons:client:set:current:weapon', function(data)
    if data ~= false then
        Config.CurrentWeaponData = data
    else
        Config.CurrentWeaponData = {}
    end
end)

RegisterNetEvent('esx_weapons:client:set:quality')
AddEventHandler('esx_weapons:client:set:quality', function(amount)
    if Config.CurrentWeaponData ~= nil and next(Config.CurrentWeaponData) ~= nil then
        TriggerServerEvent("esx_weapons:server:SetWeaponQuality", Config.CurrentWeaponData, amount)
    end
end)

RegisterNetEvent("esx_weapons:client:EquipAttachment")
AddEventHandler("esx_weapons:client:EquipAttachment", function(ItemData, attachment)
    local weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
    local WeaponData = Config.WeaponsList[weapon]
    if weapon ~= GetHashKey("WEAPON_UNARMED") then
        WeaponData['IdName'] = WeaponData['IdName']:upper()
        if Config.WeaponAttachments[WeaponData['IdName']] ~= nil then
            if Config.WeaponAttachments[WeaponData['IdName']][attachment] ~= nil then
                TriggerServerEvent("esx_weapons:server:EquipAttachment", ItemData, Config.CurrentWeaponData, Config.WeaponAttachments[WeaponData['IdName']][attachment])
            else
                ESX.ShowNotification("This weapon does not support this attachment.", 'error')
            end
        end
    else
        ESX.ShowNotification("You don't have a weapon in your hand..", 'error')
    end
end)

RegisterNetEvent('esx_weapons:client:reload:ammo')
AddEventHandler('esx_weapons:client:reload:ammo', function(AmmoType, AmmoName)
 local Weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
 local WeaponBullets = GetAmmoInPedWeapon(GetPlayerPed(-1), Weapon)
 if Config.WeaponsList[Weapon] ~= nil and Config.WeaponsList[Weapon]['AmmoType'] ~= nil then
 local NewAmmo = WeaponBullets + Config.WeaponsList[Weapon]['MaxAmmo']
 if Config.WeaponsList[Weapon]['AmmoType'] == AmmoType then
    if WeaponBullets <= (NewAmmo/2) then
		TriggerEvent("mythic_progbar:client:progress", {
            name = "reload",
            duration = 5000,
            label = "Reloading...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(status)
            if not status then
                SetAmmoInClip(GetPlayerPed(-1), Weapon, 0)
				SetPedAmmo(GetPlayerPed(-1), Weapon, NewAmmo)
				TriggerServerEvent('esx:RemoveItem', AmmoName, 1)
				TriggerServerEvent("esx_weapons:server:UpdateWeaponAmmo", Config.CurrentWeaponData, tonumber(NewAmmo))
            end
        end)
    else
        ESX.ShowNotification("You already have bullets loaded.", 'error')
    end
  end
 end
end)

RegisterNetEvent('esx_weapons:client:set:ammo')
AddEventHandler('esx_weapons:client:set:ammo', function(Amount)
 local Weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
 local WeaponBullets = GetAmmoInPedWeapon(GetPlayerPed(-1), Weapon)
 local NewAmmo = WeaponBullets + tonumber(Amount)
 if Config.WeaponsList[Weapon] ~= nil and Config.WeaponsList[Weapon]['AmmoType'] ~= nil then
  SetAmmoInClip(GetPlayerPed(-1), Weapon, 0)
  SetPedAmmo(GetPlayerPed(-1), Weapon, tonumber(NewAmmo))
  TriggerServerEvent("esx_weapons:server:UpdateWeaponAmmo", Config.CurrentWeaponData, tonumber(NewAmmo))
  ESX.ShowNotification("Successful "..Amount..'x bullets ('..Config.WeaponsList[Weapon]['Name']..')', "success")
 end
end)

RegisterNetEvent("esx_weapons:client:addAttachment")
AddEventHandler("esx_weapons:client:addAttachment", function(component)
 local weapon = GetSelectedPedWeapon(GetPlayerPed(-1))
 local WeaponData = Config.WeaponsList[weapon]
 GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(WeaponData['IdName']), GetHashKey(component))
end)

function GetAmmoType(Weapon)
 if Config.WeaponsList[Weapon] ~= nil then
     return Config.WeaponsList[Weapon]['AmmoType']
 end
end