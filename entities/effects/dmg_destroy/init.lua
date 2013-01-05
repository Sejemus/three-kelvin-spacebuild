
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local scale = math.Clamp((data:GetScale() || 1), 1, 2)
	
	local emitter = ParticleEmitter(pos)
		for i = 0, (128 * scale) do
			local vPos = pos + Vector(math.Rand(-25, 25), math.Rand(-25, 25), math.Rand(-25, 25))
			local vVel = Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(0, 200)) * scale
			local particle = emitter:Add("particle/smokesprites_0010", vPos)
			if particle then
				particle:SetVelocity(vVel)
				particle:SetLifeTime(math.Rand(0.1, 1))
				particle:SetDieTime(math.Rand(1, 3))
				particle:SetStartAlpha(math.Rand(200, 255 ))
				particle:SetEndAlpha(0)
				particle:SetStartSize(25)
				particle:SetEndSize(math.Rand(75, 100))
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(0)
				particle:SetAirResistance(math.Rand(20, 25))
				particle:SetColor(math.random(125, 175),math.random(125, 175),math.random(125, 175))
			end
		end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end