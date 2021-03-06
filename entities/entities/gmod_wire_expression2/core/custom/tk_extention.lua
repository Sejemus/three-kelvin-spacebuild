
local function ValidAction(self, ent)
    if not IsValid(ent) or ent:IsPlayer() then return false end
    if not E2Lib.isOwner(self, ent) then return false end

    return true
end

__e2setcost(5)

///--- Resources ---\\\
e2function number entity:link(entity ent)
    if not ValidAction(self, this) or not ValidAction(self, ent) then return 0 end
    if not this.IsTKRD or this.IsNode or not ent.IsNode then return 0 end

    return this:Link(ent.netid) and 1 or 0
end

e2function number entity:unLink()
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:Unlink() and 1 or 0
end

e2function number entity:getPowerGrid()
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetPowerGrid()
end

e2function number entity:getResourceAmount(string res)
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetResourceAmount(res)
end

e2function number entity:getUnitPowerGrid()
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetUnitPowerGrid()
end

e2function number entity:getUnitResourceAmount(string res)
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetUnitResourceAmount(res)
end

e2function number entity:getResourceCapacity(string res)
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetResourceCapacity(res)
end

e2function number entity:getUnitResourceCapacity(string res)
    if not ValidAction(self, this) then return 0 end
    if not this.IsTKRD then return 0 end

    return this:GetUnitResourceCapacity(res)
end

///--- Loadouts ---\\\
__e2setcost(30)
local function GetLoadout(self)
        local loadout = TK.DB:GetPlayerData(self.player, "player_loadout")

        local validents = {
            n = {},
            ntypes = {},
            s = {},
            stypes = {},
            size = 0
        }

        local n = 0

        for k, v in pairs(loadout) do
            if string.match(k, "[%w]+$") ~= "item" or v == 0 then continue end
            n = n + 1
            local key = string.sub(k, 1, -6)
            validents.s[key] = v
            validents.stypes[key] = "n"
        end

        validents.size = n

        return validents
end

e2function table getLoadout()
    return GetLoadout(self)
end

local function CreateLOent(self,item,pos,angles,freeze)
    local ply = self.player
    if not TK.LO:CanSpawn(ply, item) then return nil end
    local ent = TK.LO:SpawnItem(ply, item, pos, angles)
    local phys = ent:GetPhysicsObject()

    if phys:IsValid() then
        if (angles ~= nil) then
            phys:SetAngles(angles)
        end

        phys:Wake()

        if (freeze > 0) then
            phys:EnableMotion(false)
        end
    end

    undo.Create(ent.PrintName)
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    ply:AddCleanup(ent.PrintName, ent)

    return ent
end

e2function entity loSpawn(string slot, number frozen)
    local loadout = GetLoadout(self)

    return CreateLOent(self, loadout.s[slot], self.entity:GetPos() + self.entity:GetUp() * 25, self.entity:GetAngles(), frozen)
end

e2function entity loSpawn(number item, number frozen)
    return CreateLOent(self, item, self.entity:GetPos() + self.entity:GetUp() * 25, self.entity:GetAngles(), frozen)
end

e2function entity loSpawn(string slot, vector pos, number frozen)
    local loadout = GetLoadout(self)

    return CreateLOent(self, loadout.s[slot], Vector(pos[1], pos[2], pos[3]), self.entity:GetAngles(), frozen)
end

e2function entity loSpawn(number item, vector pos, number frozen)
    return CreateLOent(self, item, Vector(pos[1], pos[2], pos[3]), self.entity:GetAngles(), frozen)
end

e2function entity loSpawn(string slot, angle rot, number frozen)
    local loadout = GetLoadout(self)

    return CreateLOent(self, loadout.s[slot], self.entity:GetPos() + self.entity:GetUp() * 25, Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity loSpawn(number item, angle rot, number frozen)
    return CreateLOent(self, item, self.entity:GetPos() + self.entity:GetUp() * 25, Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity loSpawn(string slot, vector pos, angle rot, number frozen)
    local loadout = GetLoadout(self)

    return CreateLOent(self, loadout.s[slot], Vector(pos[1], pos[2], pos[3]), Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity loSpawn(number item, vector pos, angle rot, number frozen)
    return CreateLOent(self, item, Vector(pos[1], pos[2], pos[3]), Angle(rot[1], rot[2], rot[3]), frozen)
end

///--- RD Spawning ---\\\
local function CreateRD(self,class,model,pos,angles,freeze)
    if not TK.RD.EntityData[class] then return nil end

    if not TK.RD.EntityData[class][model] then
        model = table.GetFirstKey(TK.RD.EntityData[class])
    end

    local ply = self.player
    if not ply:CheckLimit(class) then return nil end
    local ent = ents.Create(class)
    ent:SetModel(model)
    ent:SetPos(pos)
    ent:SetAngles(angles)
    ent:Spawn()
    local phys = ent:GetPhysicsObject()

    if phys:IsValid() then
        if (angles ~= nil) then
            phys:SetAngles(angles)
        end

        phys:Wake()

        if (freeze > 0) then
            phys:EnableMotion(false)
        end
    end

    ply:AddCount(class, ent)
    undo.Create(class)
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    ply:AddCleanup(self.Name, ent)

    return ent
end

e2function entity rdSpawn(string class, string model, number frozen)
    return CreateRD(self, class, model, self.entity:GetPos() + self.entity:GetUp() * 25, self.entity:GetAngles(), frozen)
end

e2function entity rdSpawn(entity template, number frozen)
    if not IsValid(template) then return nil end

    return CreateRD(self, template:GetClass(), template:GetModel(), self.entity:GetPos() + self.entity:GetUp() * 25, self.entity:GetAngles(), frozen)
end

e2function entity rdSpawn(string class, string model, vector pos, number frozen)
    return CreateRD(self, class, model, Vector(pos[1], pos[2], pos[3]), self.entity:GetAngles(), frozen)
end

e2function entity rdSpawn(entity template, vector pos, number frozen)
    if not IsValid(template) then return nil end

    return CreateRD(self, template:GetClass(), template:GetModel(), Vector(pos[1], pos[2], pos[3]), self.entity:GetAngles(), frozen)
end

e2function entity rdSpawn(string class, string model, angle rot, number frozen)
    return CreateRD(self, class, model, self.entity:GetPos() + self.entity:GetUp() * 25, Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity rdSpawn(entity template, angle rot, number frozen)
    if not IsValid(template) then return nil end

    return CreateRD(self, template:GetClass(), template:GetModel(), self.entity:GetPos() + self.entity:GetUp() * 25, Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity rdSpawn(string class, string model, vector pos, angle rot, number frozen)
    return CreateRD(self, class, model, Vector(pos[1], pos[2], pos[3]), Angle(rot[1], rot[2], rot[3]), frozen)
end

e2function entity rdSpawn(entity template, vector pos, angle rot, number frozen)
    if not IsValid(template) then return nil end

    return CreateRD(self, template:GetClass(), template:GetModel(), Vector(pos[1], pos[2], pos[3]), Angle(rot[1], rot[2], rot[3]), frozen)
end

///--- Format ---\\\
__e2setcost(5)
e2function string format(number num)
    return TK:Format(num)
end

///--- Sequence ---\\\
e2function number entity:sequenceGet()
    if not ValidAction(self, this) then return 0 end

    return this:GetSequence() or 0
end

e2function number entity:sequenceLookUp(string name)
    if not ValidAction(self, this) then return 0 end
    local id = this:LookupSequence(name)

    return id or 0
end

e2function number entity:sequenceDuration(string name)
    if not ValidAction(self, this) then return 0 end
    local id, dur = this:LookupSequence(name)

    return dur or 0
end

e2function void entity:sequenceSet(number id)
    if not ValidAction(self, this) then return end
    this.AutomaticFrameAdvance = true
    this:SetSequence(id)
end

e2function void entity:sequenceReset(number id)
    if not ValidAction(self, this) then return end
    this.AutomaticFrameAdvance = true
    this:ResetSequence(id)
end

e2function void entity:sequenceSetCycle(number frame)
    if not ValidAction(self, this) then return end
    this:SetCycle(frame)
end

e2function void entity:sequenceSetRate(number speed)
    if not ValidAction(self, this) then return end
    this:SetPlaybackRate(speed)
end

e2function void entity:setPoseParameter(string param, number value)
    if not ValidAction(self, this) then return end
    this:SetPoseParameter(param, value)
end

///--- Wirelink ---\\\
local function IsWire(ent)
    if ent.IsWire and ent.IsWire == true then return true end
    if ent.Inputs or ent.Outputs then return true end
    if ent.inputs or ent.outputs then return true end

    return false
end

e2function wirelink entity:getWirelink()
    if not ValidAction(self, this) then return end
    if not IsWire(this) then return end

    if not this.extended then
        this.extended = true
        RefreshSpecialOutputs(this)
    end

    return this
end

e2function number entity:makeWirelink()
    if not ValidAction(self, this) then return 0 end
    if not IsWire(this) then return 0 end
    if this.extended then return 0 end
    this.extended = true
    RefreshSpecialOutputs(this)

    return 1
end

e2function number entity:removeWirelink()
    if not ValidAction(self, this) then return 0 end
    if not IsWire(this) then return 0 end
    if not this.extended then return 0 end
    this.extended = false
    RefreshSpecialOutputs(this)

    return 1
end

///--- Particles ---\\\
umsg.PoolString("particlebeam")
local sbox_E2_maxParticles = CreateConVar("sbox_E2_maxParticles", "5", FCVAR_ARCHIVE)
local ParticleCount = 0
local ParticleClear = 0
local ParticleBlackList = {"portal_rift_01"}

hook.Add("Think", "ParticleCount", function()
    if CurTime() >= ParticleClear then
        ParticleClear = CurTime() + 1
        ParticleCount = 0
    end
end)

local function ValidParticle(particle)
    if table.HasValue(ParticleBlackList, name) then return false end

    if ParticleCount < sbox_E2_maxParticles:GetInt() then
        ParticleCount = ParticleCount + 1

        return true
    end

    return false
end

e2function void entity:particleCreate(string particle, vector pos, angle ang)
    if not ValidAction(self, this) then return end
    if not ValidParticle(particle) then return end
    ParticleEffect(particle, pos, Angle(ang[1], ang[2], ang[3]), this)
end

e2function    void entity:particleAttach(string particle)
    if not ValidAction(self, this) then return end
    if not ValidParticle(particle) then return end
    ParticleEffectAttach(particle, PATTACH_ABSORIGIN_FOLLOW, this, 0)
end

e2function void entity:particleBeam(string particle, entity ent)
    if not ValidAction(self, this) then return end
    if not ValidAction(self, ent) then return end
    if not ValidParticle(particle) then return end

    timer.Simple(0.1, function()
        umsg.Start("particlebeam", player.GetAll())
        umsg.String(particle)
        umsg.Short(this:EntIndex())
        umsg.Short(ent:EntIndex())
        umsg.End()
    end)
end

e2function void entity:particleStop()
    if not ValidAction(self, this) then return end
    this:StopParticles()
end

///--- Effects ---\\\
local sbox_E2_maxEffects = CreateConVar("sbox_E2_maxEffects", "5", FCVAR_ARCHIVE)
local EffectCount = 0
local EffectClear = 0
local EffectBlackList = {"ptorpedoimpact",  "effect_explosion_scaleable",  "nuke_blastwave",  "nuke_blastwave_cheap",  "nuke_disintegrate",  "nuke_effect_air",  "nuke_effect_ground",  "nuke_vaporize",  "warpcore_breach"}

hook.Add("Think", "EffectCount", function()
    if CurTime() >= EffectClear then
        EffectClear = CurTime() + 1
        EffectCount = 0
    end
end)

local function ValidEffect(name)
    if table.HasValue(EffectBlackList, name) then return false end

    if EffectCount < sbox_E2_maxEffects:GetInt() then
        EffectCount = EffectCount + 1

        return true
    end

    return false
end

local function MakeEffect(self, name, origin, start, angle, magnitude, scale)
    local fx = EffectData()
    fx:SetOrigin(origin)
    fx:SetEntity(self)

    if start then
        fx:SetStart(start)
    end

    if angle then
        fx:SetAngle(Angle(angle[1], angle[2], angle[3]))
    end

    if magnitude then
        fx:SetMagnitude(magnitude)
    end

    if scale then
        fx:SetScale(scale)
    end

    util.Effect(name, fx)
end

e2function void fx(string effect, vector origin)
    if not ValidEffect(effect) then return end
    MakeEffect(self, effect, origin)
end

e2function void fx(string effect, vector origin, vector start)
    if not ValidEffect(effect) then return end
    MakeEffect(self, effect, origin, start)
end

e2function void fx(string effect, vector origin, vector start, angle ang)
    if not ValidEffect(effect) then return end
    MakeEffect(self, effect, origin, start, ang)
end

e2function void fx(string effect, vector origin, vector start, angle ang, magnitude)
    if not ValidEffect(effect) then return end
    MakeEffect(self, effect, origin, start, ang, magnitude)
end

e2function void fx(string effect, vector origin, vector start, angle ang, magnitude, scale)
    if not ValidEffect(effect) then return end
    MakeEffect(self, effect, origin, start, ang, magnitude, scale)
end

///--- Admin ---\\\
e2function number entity:isVip()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsVip() then
        return 1
    else
        return 0
    end
end

e2function number entity:isDJ()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsDJ() then
        return 1
    else
        return 0
    end
end

e2function number entity:isModerator()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsModerator() then
        return 1
    else
        return 0
    end
end

e2function number entity:isAdmin()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsAdmin() then
        return 1
    else
        return 0
    end
end

e2function number entity:isSuperAdmin()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsSuperAdmin() then
        return 1
    else
        return 0
    end
end

e2function number entity:isOwner()
    if not IsValid(this) then return 0 end
    if not this:IsPlayer() then return 0 end

    if this:IsOwner() then
        return 1
    else
        return 0
    end
end

///--- 3k ---\\\
e2function number entity:credits()
    if not IsValid(this) or not this:IsPlayer() then return 0 end

    return TK.DB:GetPlayerData(this, "player_info").credits
end

e2function number entity:score()
    if not IsValid(this) or not this:IsPlayer() then return 0 end

    return TK.DB:GetPlayerData(this, "player_info").score
end

e2function vector getSunPos()
    local sun = TK.AT:GetSuns()[1]

    return sun
end
