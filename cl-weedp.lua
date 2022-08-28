ESX = nil
local Licenses	= {}
local Planta = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)		
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
	
	while ESX.GetPlayerData().org == nil do
        Citizen.Wait(10)
    end
	rechercheplanta()
	TriggerServerEvent("refreshlicenseweedp")	
	TriggerEvent("weedp:distanceplantatrue")		
    ESX.PlayerData = ESX.GetPlayerData()
	Citizen.Wait(1000)
	refreshpropsarbre()
end)

RegisterNetEvent('weedp:loadLicenses')
AddEventHandler('weedp:loadLicenses', function (licenses)
	for i = 1, #licenses, 1 do
		Licenses[licenses[i].type] = true
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setOrg')
AddEventHandler('esx:setOrg', function(org)
    ESX.PlayerData.org = org
end)

function rechercheplanta()
	ESX.TriggerServerCallback('testweed', function(planta)
		Planta  = planta
	end)
end

function refreshpropsarbre()
	for _,v in pairs(Planta) do 
			local playerPos = GetEntityCoords(PlayerPedId())	
			local weedp = json.decode(v.pos)			
			local weedPosWeed = vector3(weedp.x,weedp.y,weedp.z-1)
			local distancePlayer = #(weedPosWeed-playerPos)
		if distancePlayer <= 100000 then	
			local HashKey = GetHashKey("prop_weed_01")	
			ESX.Game.SpawnObject(HashKey, weedp, function(HashKey)
			PlaceObjectOnGroundProperly(HashKey)			
			end)
		end
	end		
end

Citizen.CreateThread(function()
    while true do
		rechercheplanta()
		Citizen.Wait(60000) -- refresh des planta toute les 1 minutes(60000mS = 60 secondes)
	end
end)

local removeprops = {
    "prop_weed_01",
}

function removeobject()
    for i = 1, #removeprops do 
		local player = PlayerId()
		local plyPed = GetPlayerPed(player)
        local plyPos = GetEntityCoords(plyPed, false)
         
        local prop = GetClosestObjectOfType(plyPos.x, plyPos.y, plyPos.z, 200.0, GetHashKey(removeprops[i]), false, 0, 0)
		if prop ~= 0 then
               SetEntityAsMissionEntity(prop, true, true)
               DeleteObject(prop)
			SetEntityAsNoLongerNeeded(prop)
			print(prop .. " plante de weedp détruite")
		end
	end
end

Citizen.CreateThread(function()
    while true do
		
		local playerInZone = 1000
		local playerPos = GetEntityCoords(PlayerPedId())	
		distanceplantatrue()
        for _,v in pairs(Planta) do 				  
--[[			
			print(v.id)
			print(v.pos)
			print(v.weedPouse)
			print(v.owner)
			print(v.date)
]]
			local weedp = json.decode(v.pos)			
            local weedPosWeed = vector3(weedp.x,weedp.y,weedp.z)
            local distancePlayer = #(weedPosWeed-playerPos)

                    if distancePlayer <= 20 then				
                        playerInZone = 7					
                        DrawMarker(1, weedPosWeed.x, weedPosWeed.y, weedPosWeed.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 2.0, 55, 255, 0, 255, 1, 1, 2, 1, nil, nil, 0) 
						
						if distancePlayer <= 3 then	
	
							if distancePlayer <= 1 then	

								distanceplantafalse()	
							
								SetTextComponentFormat('STRING')
								AddTextComponentString("Appuie ~INPUT_CONTEXT~ pour recolter")
								DisplayHelpTextFromStringLabel(0, 0, 1, -1)								
																	
								if IsControlJustPressed(0, 51)  then							
										ESX.ShowNotification('~b~Check de la plante.')
										Wait(1000)										
									if v.weedPouse == 59 then	
										if Licenses['weed'] ~= nil then									
											TriggerServerEvent('weedp:ramase', v.id, v.pos, v.weedPouse, v.owner, v.date)
										--	ESX.ShowNotification('Plantation du ' ..v.date.. ' croissance de ' ..v.weedPouse)
											removeobject()
										--	DeleteObject("prop_weed_01",weedPosWeed.x, weedPosWeed.y, weedPosWeed.z - 1)
										Wait(1000)
											rechercheplanta()
											else
											TriggerServerEvent('weedp:ramase', v.id, v.pos, v.weedPouse, v.owner, v.date)
											ESX.ShowNotification('Attention vous n\'avez pas de ~r~permis')
											removeobject()
										--	DeleteObject("prop_weed_01",weedPosWeed.x, weedPosWeed.y, weedPosWeed.z - 1)
										Wait(1000)
											rechercheplanta()
										end
										else
										--	TriggerServerEvent('weedp:ramase', v.id, v.pos, v.weedPouse, v.owner, v.date)					
										ESX.ShowNotification('Plantation du ~g~' ..v.date.. ' ~w~croissance de ~g~' ..v.weedPouse)	
										ESX.ShowNotification('La croissance de cette ~g~plante ~w~n\'est pas encore au ~r~max')	
										Wait(1000)
											rechercheplanta()
									end								
								end
							end						
												
						end
						
                    end											
			end 
		
		Wait(playerInZone)
		
    end
end)

local zones = {
	--Gang
    { ['x'] = 104.69, ['y'] = -1939.96, ['z'] = 20.80},
    { ['x'] = -135.86, ['y'] = -1593.21, ['z'] = 20.80},
	{ ['x'] = 361.06, ['y'] = -2041.28, ['z'] = 22.80},
	{ ['x'] = 1441.85, ['y'] = -1496.11, ['z'] = 63.80},
	{ ['x'] = -1574.31, ['y'] = -409.11, ['z'] = 48.80},
	--Orga
	{ ['x'] = -1540.31, ['y'] = 111.84, ['z'] = 56.80},
	{ ['x'] = 1539.94, ['y'] = 2193.66, ['z'] = 78.80},
	{ ['x'] = 61.02, ['y'] = 3703.67, ['z'] = 39.80},	
}

local closestZone = 1
Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(5)
    end
    
    while true do
        local playerPed = PlayerPedId()
        local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
        local minDistance = 100000
        for i = 1, #zones, 1 do
            dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
            if dist < minDistance then
                minDistance = dist
                closestZone = i		
            end
        end
        Citizen.Wait(10000)
    end
end)

local distanceplanta = true

function  distanceplantatrue()
 distanceplanta = true
end

function  distanceplantafalse()
 distanceplanta = false
end

RegisterNetEvent("weedp:posplanta")
AddEventHandler("weedp:posplanta", function()
	local player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(player, true))
    local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	if dist <= 100.0 then  

	if distanceplanta then	

	if Licenses['weed'] ~= nil then	
		--permis weed ok
		--TriggerEvent('esx:showNotification', "Vous avez déja un ~g~permis~s~")		
			local playerPos = GetEntityCoords(PlayerPedId())
		print('Position de votre plante de weed')
		print(playerPos)
			ExecuteCommand('e pickfromground')
			distanceplanta = false
			Wait(3000)
			TriggerServerEvent("weedp:validPlantation", playerPos)
			ESX.ShowNotification('Vous venez de planté une graine de ~g~Weed')
			ESX.ShowNotification('N\'oublier pas ou elle ce trouve')
			Wait(1000)
				rechercheplanta()
				Wait(1000)			
				SpawnObject = CreateObject("prop_weed_01", x,y,z-1)
		else
			local rand = math.random(1,2)
		--permis weed pas ok
		--TriggerServerEvent('weedp:buyLicense')	
			ESX.ShowNotification('~r~Vous n\'avez pas de permis pour planter cette graine de Weed, fait attention que personne vous vois.') 
			ESX.ShowNotification('~r~Et si vous n\'avez pas la main vert, la plante risque de ne pas pousser')
				if rand == 1 then
					ESX.ShowNotification('~r~La grain c\'est casséer')
					TriggerServerEvent("weedp:grainecasser")
					Wait(1000)
						rechercheplanta()
						Wait(1000)
						SpawnObject = CreateObject("prop_weed_01", x,y,z-1)
				elseif rand == 2 then
					local playerPos = GetEntityCoords(PlayerPedId())
				print('Position de votre plante de weed')
				print(playerPos)
					ExecuteCommand('e pickfromground')
					distanceplanta = false	
					Wait(3000)
					TriggerServerEvent("weedp:validPlantation", playerPos)
					ESX.ShowNotification('Vous venez de planté une graine de ~g~Weed')
					ESX.ShowNotification('N\'oublier pas ou elle ce trouve')
					Wait(1000)
						rechercheplanta()
						Wait(1000)		
						SpawnObject = CreateObject("prop_weed_01",x,y,z-1)
				end	
	end
	
	else	
	ESX.ShowNotification('Vous etes proche d\'une autre plantation')	
	end
	
	else	
	ESX.ShowNotification('Vous loing d\'une zone de plantation')	
	end
	
end)
