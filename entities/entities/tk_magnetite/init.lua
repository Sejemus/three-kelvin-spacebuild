AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local ModelList = {
    [1] = "models/mandrac/asteroid/pyroxveld1.mdl",
    [2] = "models/mandrac/asteroid/pyroxveld2.mdl",
    [3] = "models/mandrac/asteroid/pyroxveld3.mdl",
    [4] = "models/mandrac/asteroid/pyroxveld4.mdl",
    [5] = "models/mandrac/asteroid/rock2.mdl",
    [5] = "models/mandrac/asteroid/rock3.mdl",
    [5] = "models/mandrac/asteroid/rock4.mdl",
    [5] = "models/mandrac/asteroid/rock5.mdl",
}

function ENT:GetField()
    return {}
end

function ENT:Initialize()
    self:SetModel(table.Random(ModelList))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
        self.MaxOre = math.Round((phys:GetVolume() / 10000) * math.Rand(0.75, 1.25))
        self.Ore = self.MaxOre
    else
        self.MaxOre = 0
        self.Ore = 0
    end
end

function ENT:Think()    
    if !self.Ore or self.Ore <= 0 then
        self:Remove()
    end
    
    self:NextThink(CurTime() + 1)
    return true
end