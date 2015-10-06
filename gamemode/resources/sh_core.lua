TK.RD = TK.RD or {}

hook.Add("Initialize", "TK.RD", function()
    TK.RD:AddResource("kilowatt", "Kilowatt")
    TK.RD:AddResource("kilojoules", "Kilojoules")
    TK.RD:AddResource("oxygen", "Oxygen")
    TK.RD:AddResource("carbon_dioxide", "Carbon Dioxide")
    TK.RD:AddResource("nitrogen", "Nitrogen")
    TK.RD:AddResource("hydrogen", "Hydrogen")
    TK.RD:AddResource("liquid_nitrogen", "Liquid Nitrogen")
    TK.RD:AddResource("water", "Water")
    TK.RD:AddResource("raw_tiberium", "Raw Tiberium")
    TK.RD:AddResource("raw_asteroid_ore", "Raw Asteroid Ore")
end)
