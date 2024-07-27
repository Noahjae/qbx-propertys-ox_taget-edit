local interiorShell
local decorationObjects = {}
local properties = {}
local insideProperty = false
local isPropertyRental = false
local interactions
local isConcealing = false
local concealWhitelist = {}
local blips = {}

local function prepareKeyMenu()
    local keyholders = lib.callback.await('qbx_properties:callback:requestKeyHolders')
    local options = {
        {
            title = locale('menu.add_keyholder'),
            icon = 'plus',
            arrow = true,
            onSelect = function()
                local insidePlayers = lib.callback.await('qbx_properties:callback:requestPotentialKeyholders')
                local options = {}
                for i = 1, #insidePlayers do
                    options[#options + 1] = {
                        title = insidePlayers[i].name,
                        icon = 'user',
                        arrow = true,
                        onSelect = function()
                            local alert = lib.alertDialog({
                                header = insidePlayers[i].name,
                                content = locale('alert.give_keys'),
                                centered = true,
                                cancel = true
                            })
                            if alert == 'confirm' then
                                TriggerServerEvent('qbx_properties:server:addKeyholder', insidePlayers[i].citizenid)
                            end
                        end
                    }
                end
                lib.registerContext({
                    id = 'qbx_properties_insideMenu',
                    title = locale('menu.people_inside'),
                    menu = 'qbx_properties_keyMenu',
                    options = options
                })
                lib.showContext('qbx_properties_insideMenu')
            end
        }
    }
    for i = 1, #keyholders do
        options[#options + 1] = {
            title = keyholders[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = keyholders[i].name,
                    content = locale('alert.want_remove_keys'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:removeKeyholder', keyholders[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_keyMenu',
        title = locale('menu.keyholders'),
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_keyMenu')
end

local function prepareDoorbellMenu()
    local ringers = lib.callback.await('qbx_properties:callback:requestRingers')
    local options = {}
    for i = 1, #ringers do
        options[#options + 1] = {
            title = ringers[i].name,
            icon = 'user',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = ringers[i].name,
                    content = locale('alert.want_let_person_in'),
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:letRingerIn', ringers[i].citizenid)
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_doorbellMenu',
        title = locale('menu.doorbell_ringers'),
        menu = 'qbx_properties_manageMenu',
        options = options
    })
    lib.showContext('qbx_properties_doorbellMenu')
end

local function prepareManageMenu()
    local hasAccess = lib.callback.await('qbx_properties:callback:checkAccess')
    if not hasAccess then exports.qbx_core:Notify(locale('notify.no_access'), 'error') return end
    local options = {
        {
            title = locale('menu.manage_keys'),
            icon = 'key',
            arrow = true,
            onSelect = function()
                prepareKeyMenu()
            end
        },
        {
            title = locale('menu.doorbell'),
            icon = 'bell',
            arrow = true,
            onSelect = function()
                prepareDoorbellMenu()
            end
        },
    }
    if isPropertyRental then
        options[#options+1] = {
            title = 'Stop Renting',
            icon = 'file-invoice-dollar',
            arrow = true,
            onSelect = function()
                local alert = lib.alertDialog({
                    header = 'Stop Renting',
                    content = 'Are you sure that you want to stop renting this place?',
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('qbx_properties:server:stopRenting')
                end
            end
        }
    end
    lib.registerContext({
        id = 'qbx_properties_manageMenu',
        title = locale('menu.manage_property'),
        options = options
    })
    lib.showContext('qbx_properties_manageMenu')
end

local function setupInteractionTargets()
    local interactOptions = {
        ['stash'] = function(coords)
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = 1.5,  -- Slightly increased radius for better targeting
                debug = false,  -- Set to true during development for visualization
                options = {
                    {
                        name = 'openStash',
                        event = 'qbx_properties:server:openStash',
                        icon = 'fas fa-box-open',
                        label = 'Open Stash',
                        distance = 2.0,  -- Interaction distance
                        onSelect = function()
                            TriggerServerEvent('qbx_properties:server:openStash')
                        end
                    }
                }
            })
        end,
        ['exit'] = function(coords)
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = 1.5,
                debug = false,
                options = {
                    {
                        name = 'exitProperty',
                        event = 'qbx_properties:server:exitProperty',
                        icon = 'fas fa-door-open',
                        label = 'Exit Property',
                        distance = 2.0,
                        onSelect = function()
                            DoScreenFadeOut(1000)
                            while not IsScreenFadedOut() do Wait(0) end
                            TriggerServerEvent('qbx_properties:server:exitProperty')
                        end
                    },
                    {
                        name = 'manageProperty',
                        icon = 'fas fa-cog',
                        label = 'Manage Property',
                        distance = 2.0,
                        onSelect = function()
                            prepareManageMenu()
                        end,
                        key = 47 -- Optional key for interaction
                    }
                }
            })
        end,
        ['clothing'] = function(coords)
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = 1.5,
                debug = false,
                options = {
                    {
                        name = 'openOutfitMenu',
                        icon = 'fas fa-tshirt',
                        label = 'Outfit Menu',
                        distance = 2.0,
                        onSelect = function()
                            TriggerEvent('illenium-appearance:client:openOutfitMenu')
                        end,
                        key = 47 -- Optional key for interaction
                    }
                }
            })
        end,
        ['logout'] = function(coords)
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = 1.5,
                debug = false,
                options = {
                    {
                        name = 'logoutProperty',
                        event = 'qbx_properties:server:logoutProperty',
                        icon = 'fas fa-sign-out-alt',
                        label = 'Logout',
                        distance = 2.0,
                        onSelect = function()
                            DoScreenFadeOut(1000)
                            while not IsScreenFadedOut() do Wait(0) end
                            TriggerServerEvent('qbx_properties:server:logoutProperty')
                        end
                    }
                }
            })
        end,
    }

    for i = 1, #interactions do
        interactOptions[interactions[i].type](interactions[i].coords)
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if insideProperty then
            setupInteractionTargets()
            break
        end
    end
end)

function checkInteractions()
    if interactions then
        for k, v in pairs(interactions) do
        end
    end
end

RegisterNetEvent('qbx_properties:client:updateInteractions', function(interactionsData, isRental)
    DoScreenFadeIn(1000)
    interactions = interactionsData
    insideProperty = true
    isPropertyRental = isRental
    checkInteractions()
end)

RegisterNetEvent('qbx_properties:client:createInterior', function(interiorHash, interiorCoords)
    lib.requestModel(interiorHash, 2000)
    interiorShell = CreateObjectNoOffset(interiorHash, interiorCoords.x, interiorCoords.y, interiorCoords.z, false, false, false)
    FreezeEntityPosition(interiorShell, true)
    SetModelAsNoLongerNeeded(interiorHash)
end)

RegisterNetEvent('qbx_properties:client:loadDecorations', function(decorations)
    for i = 1, #decorations do
        local decoration = decorations[i]
        lib.requestModel(decoration.model, 2000)
        decorationObjects[i] = CreateObjectNoOffset(decoration.model, decoration.coords.x, decoration.coords.y, decoration.coords.z, false, false, false)
        FreezeEntityPosition(decorationObjects[i], true)
        SetEntityHeading(decorationObjects[i], decoration.coords.w)
        SetModelAsNoLongerNeeded(decoration.model)
    end
end)

RegisterNetEvent('qbx_properties:client:unloadProperty', function()
    DoScreenFadeIn(1000)
    insideProperty = false
    if DoesEntityExist(interiorShell) then DeleteEntity(interiorShell) end
    for i = 1, #decorationObjects do
        if DoesEntityExist(decorationObjects[i]) then DeleteEntity(decorationObjects[i]) end
    end
    interiorShell = nil
    decorationObjects = {}
end)

local function singlePropertyMenu(property, noBackMenu)
    local options = {}
    if QBX.PlayerData.citizenid == property.owner or lib.table.contains(json.decode(property.keyholders), QBX.PlayerData.citizenid) then
        options[#options + 1] = {
            title = locale('menu.enter'),
            icon = 'cog',
            arrow = true,
            onSelect = function()
                DoScreenFadeOut(1000)
                while not IsScreenFadedOut() do Wait(0) end
            end,
            serverEvent = 'qbx_properties:server:enterProperty',
            args = { id = property.id }
        }
    elseif property.owner == nil then
        if property.rent_interval then
            options[#options + 1] = {
                title = 'Rent',
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = string.format('Renting - %s', property.property_name),
                        content = string.format('Are you sure you want to rent %s for $%s which will be billed every %sh(s)?', property.property_name, property.price, property.rent_interval),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:rentProperty', property.id)
                    end
                end,
            }
        else
            options[#options + 1] = {
                title = 'Buy',
                icon = 'dollar-sign',
                arrow = true,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = string.format('Buying - %s', property.property_name),
                        content = string.format('Are you sure you want to buy %s for $%s?', property.property_name, property.price),
                        centered = true,
                        cancel = true
                    })
                    if alert == 'confirm' then
                        TriggerServerEvent('qbx_properties:server:buyProperty', property.id)
                    end
                end,
            }
        end
    else
        options[#options + 1] = {
            title = locale('menu.ring_doorbell'),
            icon = 'bell',
            arrow = true,
            serverEvent = 'qbx_properties:server:ringProperty',
            args = { id = property.id }
        }
    end
    local menu = 'qbx_properties_propertiesMenu'
    ---@diagnostic disable-next-line: cast-local-type
    if noBackMenu then menu = nil end
    lib.registerContext({
        id = 'qbx_properties_propertyMenu',
        title = property.property_name,
        menu = menu,
        options = options
    })
    lib.showContext('qbx_properties_propertyMenu')
end

local function propertyMenu(propertyList, owned)
    local options = {
        {
            title = locale('menu.retrieve_properties'),
            description = locale('menu.show_owned_properties'),
            icon = 'bars',
            onSelect = function()
                propertyMenu(propertyList, true)
            end
        }
    }
    for i = 1, #propertyList do
        if owned and propertyList[i].owner == QBX.PlayerData.citizenid or lib.table.contains(json.decode(propertyList[i].keyholders), QBX.PlayerData.citizenid) then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        elseif not owned then
            options[#options + 1] = {
                title = propertyList[i].property_name,
                icon = 'home',
                arrow = true,
                onSelect = function()
                    singlePropertyMenu(propertyList[i])
                end
            }
        end
    end
    lib.registerContext({
        id = 'qbx_properties_propertiesMenu',
        title = locale('menu.properties'),
        options = options
    })
    lib.showContext('qbx_properties_propertiesMenu')
end

function PreparePropertyMenu(propertyCoords)
    local propertyList = lib.callback.await('qbx_properties:callback:requestProperties', false, propertyCoords)
    if #propertyList == 1 then
        singlePropertyMenu(propertyList[1], true)
    else
        propertyMenu(propertyList)
    end
end

local function createPropertyZones(properties)
    for i = 1, #properties do
        local property = properties[i]
        exports.ox_target:addSphereZone({
            coords = property.xyz,
            radius = 1.5,  -- Adjust the radius as needed
            debug = false,  -- Set to true during development for visualization
            options = {
                {
                    name = 'viewProperty',
                    icon = 'fas fa-eye',
                    label = locale('drawtext.view_property'),
                    onSelect = function()
                        PreparePropertyMenu(property)
                    end
                }
            }
        })
    end
end

CreateThread(function()
    for i = 1, #ApartmentOptions do
        local data = ApartmentOptions[i]

        if not blips[data.enter] then
            blips[data.enter] = CreateBlip(data.enter, data.label)
        end
    end

    properties = lib.callback.await('qbx_properties:callback:loadProperties')
    
    -- Create interaction zones for each property
    createPropertyZones(properties)
    
    while true do
        Wait(1000)  -- Adjust the wait time as necessary
    end
end)

RegisterNetEvent('qbx_properties:client:concealPlayers', function(playerIds)
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    concealWhitelist = playerIds
    if not isConcealing then
        isConcealing = true
        while isConcealing do
            players = GetActivePlayers()
            for i = 1, #players do
                if not lib.table.contains(concealWhitelist, GetPlayerServerId(players[i])) then
                    NetworkConcealPlayer(players[i], true, false)
                end
            end
            Wait(3000)
        end
    end
end)

RegisterNetEvent('qbx_properties:client:revealPlayers', function()
    local players = GetActivePlayers()
    for i = 1, #players do NetworkConcealPlayer(players[i], false, false) end
    isConcealing = false
end)

RegisterNetEvent('qbx_properties:client:addProperty', function(propertyCoords)
    if lib.table.contains(properties, propertyCoords) then return end
    properties[#properties + 1] = propertyCoords
end)
