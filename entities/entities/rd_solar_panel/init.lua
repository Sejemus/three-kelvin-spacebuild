AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:SetPowered(true)
	self:AddResource("energy", 0, true)
	
	WireLib.CreateOutputs(self, {"On", "Output"})
end

function ENT:TurnOn()
	if self.IsActive then return end
	self:SetActive(true)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:Use()

end

function ENT:DoThink()
	local pos = self:LocalToWorld(self:OBBCenter())
	local direct = -1
	for k,v in pairs(TK.AT.GetSuns()) do
		local ang = self:GetUp():Dot((v - pos):GetNormal())
		direct = math.max(direct, ang)
	end
	
	if direct <= 0 || !self:GetEnv():InSun(self) then
		self:TurnOff()
	else
		self:TurnOn()
		local output = math.floor(self.data.energy * direct)
		self:SupplyResource("energy", output)
		WireLib.TriggerOutput(self, "Output", output)
	end
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end