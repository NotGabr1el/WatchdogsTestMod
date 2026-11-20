local script = Script()
local cars = {}
local profiles = {
    police = { car = "Police.01", factions = {"Police"} },
    gang = { car = "Muscle.Retro_03.Retro_03_580s", factions = {"580s", "The 580s"} },
    fbi = { car = "Offroad.05.05_FBI", factions = {"FBI", "Police"} }
}

local function clear()
    for _, entity in ipairs(cars) do RemoveEntity(entity) end
    cars = {}
end

local roadblock = false
local lineup = {profiles.police, profiles.gang, profiles.fbi}

local function call(profile, mixed)
    local target = GetReticleHitEntity()
    if not target or target == GetInvalidEntityId() or target == GetLocalPlayerEntityId() then
        return ScriptHook.ShowNotification("Aim at an NPC first.")
    end
    local models = {}
    for i = 1, 5 do
        local car = mixed and lineup[(i - 1) % #lineup + 1].car or profile.car
        models[i] = VehicleArchetype and VehicleArchetype[car]
        if not models[i] then return ScriptHook.ShowNotification("Missing vehicle: " .. car) end
    end
    local faction
    for _, name in ipairs(profile.factions) do
        if Fractions and Fractions[name] then faction = Fractions[name]; break end
    end
    if not faction then
        return ScriptHook.ShowNotification("Required faction missing from ScriptHook.")
    end
    local x, y, z = GetEntityPosition(target, 0), GetEntityPosition(target, 1), GetEntityPosition(target, 2)
    clear()
    for i = 1, 5 do
        local a = (i - 1) * 2 * math.pi / 5
        local dx = roadblock and (i - 3) * 5 or 14 * math.cos(a)
        local dy = roadblock and 14 or 14 * math.sin(a)
        local entity = SpawnEntityFromArchetype(models[i], x + dx, y + dy, z, 0, 0, 0)
        if entity and entity ~= GetInvalidEntityId() then cars[#cars + 1] = entity end
    end
    FelonyStartChase(target, faction, 2, 2)
    ScriptHook.ShowNotification("Pursuit requested; vehicles staged: " .. #cars .. "/5")
end

for action, profile in pairs(profiles) do
    local selected = profile
    ScriptHook.RegisterKeyHandler(action, function() call(selected) end)
end
ScriptHook.RegisterKeyHandler("mashup", function()
    call(lineup[math.random(#lineup)], true)
end)
ScriptHook.RegisterKeyHandler("formation", function()
    roadblock = not roadblock
    ScriptHook.ShowNotification(roadblock and "Next call: roadblock line" or "Next call: surround ring")
end)
ScriptHook.RegisterKeyHandler("clear", clear)
function script:OnUnload() clear() end
