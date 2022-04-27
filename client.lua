ESX = nil
local PlayerData

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

local zones = {
	{ ['x'] = 1847.916015625, ['y'] = 3675.8190917968, ['z'] = 33.767009735108},
	{ ['x'] = -1688.43811035156, ['y'] = -1073.62536621094, ['z'] = 13.1521873474121 }
	{ ['x'] = -2195.1352539063, ['y'] = 4288.7290039063, ['z'] = 49.173923492432 }
}

local entered = false
local hit = false
local closestZone = 1

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	for i = 1, #zones, 1 do
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
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

function playerhasenterednfz(isinzone)
	if isinzone then	
	exports['mythic_notify']:DoHudText('error', '⚠️ You have entered No-Flight Zone you will get shot down soon!⚠️', { ['background-color'] = '#ff0000', ['color'] = '#000000' })
	
	local time = math.random(5, 10)
	Citizen.Wait(time*1000)

	local player = source
    local ped = GetPlayerPed(player)
    local cds = GetEntityCoords(ped)

	AddExplosion(
		cds.x + 1, 
		cds.y + 1, 
		cds.z + 1, 
		4, 
		100.0, 
		true, 
		false, 
		0.0
	)
	hit = true

	end
end

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	while true do
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
		if dist <= 100.0 then  
			entered = true
			if not hit then
				if IsPedInAnyHeli(player) then
					local playerjob = PlayerData.job.name
					if playerjob ~= ("police" or playerjob ~= "sheriff" or playerjob ~= "ambulance") then
						playerhasenterednfz(entered)
					end
				end	
			end
		else
			hit = false
			entered = false
		end
	 	if DoesEntityExist(player) then	      --The -1.0001 will place it on the ground flush		-- SIZING CIRCLE |  x    y    z | R   G    B   alpha| *more alpha more transparent*
	 	   DrawMarker(1, zones[closestZone].x, zones[closestZone].y, zones[closestZone].z-1.0001, 0, 0, 0, 0, 0, 0, 200.0, 200.0, 2.0, 13, 232, 255, 155, 0, 0, 2, 0, 0, 0, 0) -- heres what all these numbers are. Honestly you dont really need to mess with any other than what isnt 0.
	 	   --DrawMarker(type, float posX, float posY, float posZ, float dirX, float dirY, float dirZ, float rotX, float rotY, float rotZ, float scaleX, float scaleY, float scaleZ, int red, int green, int blue, int alpha, BOOL bobUpAndDown, BOOL faceCamera, int p19(LEAVE AS 2), BOOL rotate, char* textureDict, char* textureName, BOOL drawOnEnts)
	 	end
	end
end)