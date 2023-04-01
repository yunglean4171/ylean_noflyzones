ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

local zones = Config.zones

local entered = false
local hit = false
local closestZone = 1

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(0)
    end

    for i = 1, #zones do
        local szBlip = AddBlipForCoord(zones[i].x, zones[i].y, zones[i].z)
        SetBlipAsShortRange(szBlip, true)
        SetBlipColour(szBlip, 2)
        SetBlipSprite(szBlip, 398)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("NO FLIGHT ZONE")
        EndTextCommandSetBlipName(szBlip)
    end
end)

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(0)
    end
    while true do
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed, true)
        local minDistance = 100000
        for i = 1, #zones do
            local dist = Vdist(zones[i].x, zones[i].y, zones[i].z, coords.x, coords.y, coords.z)
            if dist < minDistance then
                minDistance = dist
                closestZone = i
            end
        end
        Citizen.Wait(15000)
    end
end)

function playerHasEnteredNFZ(isInZone)
    if isInZone then
        exports['mythic_notify']:DoHudText('error', Config.notificationText, { ['background-color'] = '#ff0000', ['color'] = '#000000' })

        local time = math.random(Config.minTime,Config.maxTime)
        Citizen.Wait((time - 5) * 1000) -- Subtract 5 seconds for the countdown sound
        
        -- Play countdown sound
        local playerPed = GetPlayerPed(-1)
        PlaySoundFrontend(-1, "5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset", 1)
        Citizen.Wait(5 * 1000) -- Wait the remaining 5 seconds before the explosion

        local ped = GetPlayerPed(player)
        local cds = GetEntityCoords(ped)
    
        AddExplosion(cds.x + 1, cds.y + 1, cds.z + 1, 4, 100.0, true, false,0.0)
        hit = true
    end
end
        
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(0)
    end

    while true do
        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(playerPed, true)
        local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, coords.x, coords.y, coords.z)
    
        if dist <= 100.0 then
            entered = true
            if not hit then
                if IsPedInAnyHeli(playerPed) then
                    local playerJob = PlayerData.job.name
                    if playerJob ~= "police" and playerJob ~= "sheriff" and playerJob ~= "ambulance" then
                        playerHasEnteredNFZ(entered)
                    end
                end
            end
        else
            hit = false
            entered = false
        end
        Citizen.Wait(1000)
    end
end)
