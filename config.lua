Config = Config or {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

Config.Cityhalls = {
    coords = vector3(-543.94, -196.79, 38.23),
    showBlip = true,
    blipData = {
        sprite = 487,
        display = 4,
        scale = 1.0,
        colour = 0,
        title = "市政府"
    },
    licenses = {
        ["id_card"] = {
            label = "身分證",
            cost = 1250,
        },
        ["driver_license"] = {
            label = "駕駛執照",
            cost = 1250,
            metadata = "driver"
        },
    }
}

Config.Peds = {
    -- Cityhall Ped
    {
        model = 's_m_m_fiboffice_02',
        coords = vector4(-542.53, -197.14, 38.24, 74.52),
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        cityhall = true,
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0,
            debugPoly = false
        }
    },
}
