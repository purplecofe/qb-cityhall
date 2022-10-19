local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
local pedsSpawned = false
local blips = {}

-- Functions

local function createBlip(options)
    if not options.coords or type(options.coords) ~= 'table' and type(options.coords) ~= 'vector3' then return error(('createBlip() expected coords in a vector3 or table but received %s'):format(options.coords)) end
    local blip = AddBlipForCoord(options.coords.x, options.coords.y, options.coords.z)
    SetBlipSprite(blip, options.sprite or 1)
    SetBlipDisplay(blip, options.display or 4)
    SetBlipScale(blip, options.scale or 1.0)
    SetBlipColour(blip, options.colour or 1)
    SetBlipAsShortRange(blip, options.shortRange or false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(options.title or 'No Title Given')
    EndTextCommandSetBlipName(blip)
    return blip
end

local function deleteBlips()
    if not next(blips) then return end
    for i = 1, #blips do
        local blip = blips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

local function initBlips()
    local hall = Config.Cityhalls
    if hall.showBlip then
        blips[#blips+1] = createBlip({
            coords = hall.coords,
            sprite = hall.blipData.sprite,
            display = hall.blipData.display,
            scale = hall.blipData.scale,
            colour = hall.blipData.colour,
            shortRange = true,
            title = hall.blipData.title
        })
    end
end

local function spawnPeds()
    if not Config.Peds or not next(Config.Peds) or pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, true, true)
        current.pedHandle = ped
        if Config.UseTarget then
            local opts = { label = Lang:t("info.menu"), icon = 'fa-solid fa-city', event = 'qb-cityhall:client:RegistrationDocs', }
            exports['qb-target']:AddTargetEntity(ped, {
                options = {opts},
                distance = 2.0
            })
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not Config.Peds or not next(Config.Peds) or not pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end

-- Events

RegisterNetEvent('qb-cityhall:client:RegistrationDocs', function()
    local Menu = {}
    Menu[#Menu + 1] = { isMenuHeader = true, header =  Lang:t('info.menu'), txt = "", }
    for k,v in pairs(Config.Cityhalls.licenses) do
        Menu[#Menu + 1] = { header = v.label, txt = '申請費: $'..v.cost, params = { event = 'qb-cityhall:client:requestId', args = { item = k } }}
    end
    exports['qb-menu']:openMenu(Menu)
end)

RegisterNetEvent('qb-cityhall:client:requestId', function(data)
    TriggerServerEvent('qb-cityhall:server:requestId', data.item)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    deletePeds()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deleteBlips()
    deletePeds()
end)

-- Threads
CreateThread(function()
    initBlips()
    spawnPeds()
end)
