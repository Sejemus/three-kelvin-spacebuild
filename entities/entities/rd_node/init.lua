AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	
	self.netid = 0
	self.range =  0
	self.rangesqr =  0
	self.netdata = {res = {}, entities = {}, update = {}, node = self}
	TK.RD.Register(self, true)
	self:SetRange(self.data.range)
end

function ENT:SetNetID(netid)
	self:SetNWInt("NetID", netid)
	self.netid = netid
end

function ENT:SetRange(val)
	self:SetNWInt("Range", val)
	self.range = val
	self.rangesqr = val * val
end

function ENT:GetNetTable()
	return self.netdata
end

function ENT:Unlink()
	return TK.RD.Unlink(self)
end

function ENT:SupplyResource(idx, amt)
	return TK.RD.NetSupplyResource(self.netid, idx, amt)
end

function ENT:ConsumeResource(idx, amt)
	return TK.RD.NetConsumeResource(self.netid, idx, amt)
end

function ENT:GetResourceAmount(idx)
	return TK.RD.GetNetResourceAmount(self.netid, idx)
end

function ENT:GetUnitResourceAmount(idx)
	return 0
end

function ENT:GetResourceCapacity(idx)
	return TK.RD.GetNetResourceCapacity(self.netid, idx)
end

function ENT:GetUnitResourceCapacity(idx)
	return 0
end

function ENT:Think()
	for k,v in ipairs(self.netdata.entities) do
		if (v:GetPos() - self:GetPos()):LengthSqr() > self.rangesqr then
			v:Unlink()
			v:SoundPlay(0)
		end
	end
	
	for k,v in ipairs(self.netdata.entities) do
		local valid, info = pcall(v.DoThink, v)
		if !valid then print(info) end
	end
	
	if !self.netdata.update.network then
		self.netdata.update.network = true
		
		for k,v in ipairs(self.netdata.entities) do
			local valid, info = pcall(v.UpdateValues, v)
			if !valid then print(info) end
		end
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	TK.RD.RemoveNet(self)
end

function ENT:PreEntityCopy()
	TK.RD.MakeDupeInfo(self)
end

function ENT:PostEntityPaste(ply, ent, CreatedEntities)
	TK.RD.ApplyDupeInfo(ent, CreatedEntities)
end