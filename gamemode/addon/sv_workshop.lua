
local addons = engine.GetAddons()

for _,ws_file in pairs(file.Find("addons/*.gma", "GAME")) do
    local id = string.match(ws_file, "%d+")
    for _,addon in pairs(addons) do
        if tostring(addon.wsid) == id then
            resource.AddWorkshop(id)
        end
    end
end