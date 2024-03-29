local inside_zone = false

local greenzones = Config.Greenzones

local function ShowInfo(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(true, false)
end

Citizen.CreateThread(function()
  while true do
    local playerPed = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(playerPed, false)
    for k, v in pairs(greenzones) do
      local location = vector3(v.location.x, v.location.y, v.location.z)
      if #(plyCoords - location) < (v.diameter) - (v.diameter / 150) then
        if (not inside_zone) then
          local temp_append = ""
          --ShowInfo("Tady nekrop demente")
          lib.notify({
            title = 'Zelená zóna',
            description = 'Zde není možné střílet ale pouze mířit',
            type = 'success',
            position = 'top',
        })
          inside_zone = true
          if (v.customrestrictions.enabled and v.customrestrictions.loop == false) then
            Config.Greenzones[k].customrestrictions.run(v)
          end
        end
        -- Enforce Restrictions.
        if (v.restrictions.blockattack) then
          SetEntityCanBeDamaged(playerPed, false)
          SetPlayerCanDoDriveBy(playerPed, false)
          DisablePlayerFiring(playerPed, true)
          DisableControlAction(0, 140) -- Melee R
        end
        if (v.restrictions.speedlimit ~= nil and tonumber(v.restrictions.speedlimit)) then
          SetEntityMaxSpeed(GetVehiclePedIsIn(playerPed, false), tonumber(v.restrictions.speedlimit) / 2.237)
        end
        if (v.customrestrictions.enabled and v.customrestrictions.loop == true) then
          Config.Greenzones[k].customrestrictions.run(v)
        end
      elseif (inside_zone) then
        -- Remove Restrictions.
        -- The reason why we do inside_zone == true is so that if the first if statement fails,
        -- We can restore the normal functions outside of the zone without looping through this constantly.

        -- Since the natives used to restrict attacks are called per frame, we don't need to put anything here to reset that.
        --ShowInfo("Tady muzes ale mej duvod")
        lib.notify({
          title = 'Červená zóna',
          description = 'Zde je možné střílet, ale dávej si pozor! musíš mít k tomu dobrý důvod jinak můžeš být zabanován',
          type = 'error',
          position = 'top',
      })

        SetEntityCanBeDamaged(playerPed, true)
        SetEntityMaxSpeed(GetVehiclePedIsIn(playerPed, false), 99999.9)

        -- NOTE: This doesn't increase the speed of vehicles.
        -- This only removes the cap/speedlimit that was applied while inside the restricted zone.

        Config.Greenzones[k].customrestrictions.stop(v)

        inside_zone = false

      end
    end
    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function()
  while true do
    local playerPed = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(playerPed, false)
    for k, v in pairs(greenzones) do
      local location = vector3(v.location.x, v.location.y, v.location.z)
      if #(plyCoords - location) < (v.diameter) - (v.diameter / 150) then
        DrawMarker(28, v.location.x, v.location.y, v.location.z, 0, 0, 0, 0, 0, 0, v.diameter + 0.0, v.diameter + 0.0, v.diameter + 0.0, v.color.r, v.color.g, v.color.b, 0, 0, 0, 0, 0)
      elseif (#(plyCoords - location) < (v.diameter) - (v.diameter / 150) + v.visabilitydistance) then
        DrawMarker(28, v.location.x, v.location.y, v.location.z, 0, 0, 0, 0, 0, 0, v.diameter + 0.0, v.diameter + 0.0, v.diameter + 0.0, v.color.r, v.color.g, v.color.b, v.color.a, 0, 0, 0, 0)
      end
    end
    Citizen.Wait(0)
  end
   
 local blip25 = AddBlipForRadius(  -69.47, -1731.39, 29.31, 200.33) --spawn
    SetBlipHighDetail(blip25, true)
    SetBlipColour(blip25, 2)
    SetBlipAlpha (blip25, 128)


end)
