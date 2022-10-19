local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function giveStarterItems()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    for _, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "駕駛執照"
        end
        Player.Functions.AddItem(v.item, 1, nil, info)
    end
end

-- Events

RegisterNetEvent('qb-cityhall:server:requestId', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local licences = Player.PlayerData.metadata["licences"]
    if not Player then return end
    local itemInfo = Config.Cityhalls.licenses[item]
    if not Player.Functions.RemoveMoney("cash", itemInfo.cost) then 
        TriggerClientEvent('QBCore:Notify', src, ('You don\'t have enough money on you, you need %s cash'):format(itemInfo.cost), 'error')
        return
    end
    local info = {}
    if item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "C 級駕駛執照"
    else
        return DropPlayer(src, 'Attempted exploit abuse')
    end
    if not Player.Functions.AddItem(item, 1, nil, info) then return end
    if itemInfo.metadata == 'driver' then
        local newLicenses = {}
        for k, v in pairs(licences) do
            local status = v
            if k == itemInfo.metadata then
                status = true
            end
            newLicenses[k] = status
        end
        Player.Functions.SetMetaData("licences", newLicenses)
    end
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
end)