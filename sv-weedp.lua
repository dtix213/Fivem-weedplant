ESX = nil
local cb = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function LoadLicenses(source)
  TriggerEvent('esx_license:getLicenses', source, function (licenses)
    TriggerClientEvent('weedp:loadLicenses', source, licenses)
  end)
end

AddEventHandler('esx:playerLoaded', function (source)
	LoadLicenses(source)
end)

RegisterServerEvent('refreshlicenseweedp')
AddEventHandler('refreshlicenseweedp', function ()
	local _source = source
	LoadLicenses(_source)
end)

RegisterServerEvent('weedp:buyLicense')
AddEventHandler('weedp:buyLicense', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.get('money') >= 1000 then
		xPlayer.removeMoney(1000)

		TriggerEvent('esx_license:addLicense', _source, 'weed', function ()
			LoadLicenses(_source)
			TriggerClientEvent('esx:showNotification', _source, "Vous avez reçu votre ~g~permis de plantation de la weed~s~")
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, 'Vous avez pas asser d\'argent')
	end
end)

ESX.RegisterServerCallback("testweed", function(source, cb)
	local planta = {}

	MySQL.Async.fetchAll('SELECT * FROM plantaWeed', {}, function(planta)
		cb(planta)
	end)
	
  end) 

RegisterNetEvent("weedp:weedpouse")
AddEventHandler("weedp:weedpouse", function(cb)
	
	local idweed = MySQL.Sync.fetchAll('SELECT * FROM plantaWeed')

	for i=1, #idweed, 1 do

	--	print(idweed[i].weedPouse)
	--	print(idweed[i].id)
	local weedPouse = idweed[i].weedPouse + 1	
	
		if weedPouse == 60  then
		
	--		print('Plantation ' ..idweed[i].id.. ' faite.')
		else	
		MySQL.Async.execute('UPDATE plantaWeed SET weedPouse = @weedPouse WHERE id = @id', {
			['@weedPouse'] = weedPouse,	
			['@id'] = idweed[i].id,
		})		
		end
		
		
	end
	
	
		
end)

Citizen.CreateThread(function()
    while true do
	TriggerEvent("weedp:weedpouse")
		Wait(10000)		
    end
end)


RegisterNetEvent("weedp:validPlantation")
AddEventHandler("weedp:validPlantation", function(playerPos)

	local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	local dateNow = os.date('%Y-%m-%d %H:%M')		
	local identifier = xPlayer.identifier
	xPlayer.removeInventoryItem('graineweed', 1)
	
    MySQL.Async.execute("INSERT INTO plantaWeed (pos, weedPouse, owner, date) VALUES (@pos, @weedPouse, @owner, @date)", {
	["@pos"] = json.encode(playerPos),
	["@owner"] = xPlayer.identifier,
	["@date"] = dateNow,
	["@weedPouse"] = 0,		
    }, function()  
	print('succes')
    end)
end)

RegisterServerEvent('weedp:ramase')
AddEventHandler('weedp:ramase', function (id,pos,weedpouse,owner,date)
	--print(id,pos,weedpouse,owner,date)
	
	local xPlayer = ESX.GetPlayerFromId(source)	
	
	MySQL.Async.fetchAll('SELECT * FROM plantaWeed WHERE pos = @pos ', {
			['@pos'] = pos
		}, function(result)
		if result[1] then
				MySQL.Async.execute('DELETE FROM plantaWeed WHERE pos = @pos', {
					['@pos'] = result[1].pos
				}, function(rowsChanged)
					
				end)
			end
		end)
	local total = math.random(1,5)	
	xPlayer.addInventoryItem('weed', total)
	TriggerClientEvent('esx:showNotification',xPlayer.source, '~w~Vous venez de recoltez ~b~' ..total..' ~w~de weed')	
end)

ESX.RegisterUsableItem('graineweed', function(source)
	xPlayer = ESX.GetPlayerFromId(source)
--	xPlayer.removeInventoryItem('graineweed', 1)
	TriggerClientEvent("weedp:posplanta", xPlayer.source)
end)

RegisterNetEvent("weedp:grainecasser")
AddEventHandler("weedp:grainecasser", function()
	local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('graineweed', 1)
end)
