local default_animations = {"idle_all_01",  "menu_walk"}
local cl_playerbodygroups = GetConVar("cl_playerbodygroups")
local cl_playerskin = GetConVar("cl_playerskin")
local cl_playercolor = GetConVar("cl_playercolor")

list.Set("DesktopWindows", "PlayerEditor", {
	title = "Player Model",
	icon = "icon64/playermodel.png",
	width = 960,
	height = 700,
	onewindow = true,
	init = function(icon, window)
		local mdl = window:Add("DModelPanel")
		mdl:Dock(FILL)
		mdl:SetFOV(36)
		mdl:SetCamPos(Vector(0, 0, 0))
		mdl:SetDirectionalLight(BOX_RIGHT, Color(255, 160, 80, 255))
		mdl:SetDirectionalLight(BOX_LEFT, Color(80, 160, 255, 255))
		mdl:SetAmbientLight(Vector(-64, -64, -64))
		mdl:SetAnimated(true)
		mdl.Angles = Angle(0, 0, 0)
		mdl:SetLookAt(Vector(-100, 0, -22))
		local sheet = window:Add("DPropertySheet")
		sheet:Dock(RIGHT)
		sheet:SetSize(430, 0)
		local PanelSelect = sheet:Add("DPanelSelect")

		for name, model in SortedPairs(player_manager.AllValidModels()) do
			if not TK:CanUsePlayerModel(LocalPlayer(), model) then continue end
			local spawn_icon = vgui.Create("SpawnIcon")
			spawn_icon:SetModel(model)
			spawn_icon:SetSize(64, 64)
			spawn_icon:SetTooltip(name)
			spawn_icon.playermodel = name

			PanelSelect:AddPanel(spawn_icon, {
				cl_playermodel = name
			})
		end

		sheet:AddSheet("Model", PanelSelect, "icon16/user.png")
		local bdcontrols = window:Add("DPanel")
		bdcontrols:DockPadding(8, 8, 8, 8)
		local bdcontrolspanel = bdcontrols:Add("DPanelList")
		bdcontrolspanel:EnableVerticalScrollbar(true)
		bdcontrolspanel:Dock(FILL)
		local bgtab = sheet:AddSheet("Bodygroups", bdcontrols, "icon16/cog.png")

		-- Helper functions
		local function MakeNiceName(str)
			local newname = {}

			for _, s in pairs(string.Explode("_", str)) do
				if (string.len(s) == 1) then
					table.insert(newname, string.upper(s))
					continue
				end

				-- Ugly way to capitalize first letters.
				table.insert(newname, string.upper(string.Left(s, 1)) .. string.Right(s, string.len(s) - 1))
			end

			return string.Implode(" ", newname)
		end

		local function PlayPreviewAnimation(panel, playermodel)
			if (not panel or not IsValid(panel.Entity)) then return end
			local anims = list.Get("PlayerOptionsAnimations")
			local anim = default_animations[math.random(1, #default_animations)]

			if (anims[playermodel]) then
				anims = anims[playermodel]
				anim = anims[math.random(1, #anims)]
			end

			local iSeq = panel.Entity:LookupSequence(anim)

			if (iSeq > 0) then
				panel.Entity:ResetSequence(iSeq)
			end
		end

		-- Updating
		local function UpdateBodyGroups(pnl, val)
			if (pnl.type == "bgroup") then
				mdl.Entity:SetBodygroup(pnl.typenum, math.Round(val))
				local str = string.Explode(" ", cl_playerbodygroups:GetString())

				if (#str < pnl.typenum + 1) then
					for i = 1,  pnl.typenum + 1 do
						str[i] = str[i] or 0
					end
				end

				str[pnl.typenum + 1] = math.Round(val)
				RunConsoleCommand("cl_playerbodygroups", table.concat(str, " "))
			elseif (pnl.type == "skin") then
				mdl.Entity:SetSkin(math.Round(val))
				RunConsoleCommand("cl_playerskin", math.Round(val))
			end
		end

		local function RebuildBodygroupTab()
			bdcontrolspanel:Clear()
			bgtab.Tab:SetVisible(false)
			local nskins = mdl.Entity:SkinCount() - 1

			if (nskins > 0) then
				local skins = vgui.Create("DNumSlider")
				skins:Dock(TOP)
				skins:SetText("Skin")
				skins:SetDark(true)
				skins:SetTall(50)
				skins:SetDecimals(0)
				skins:SetMax(nskins)
				skins:SetValue(cl_playerskin:GetInt())
				skins.type = "skin"
				skins.OnValueChanged = UpdateBodyGroups
				bdcontrolspanel:AddItem(skins)
				mdl.Entity:SetSkin(cl_playerskin:GetInt())
				bgtab.Tab:SetVisible(true)
			end

			local groups = string.Explode(" ", cl_playerbodygroups:GetString())

			for k = 0,  mdl.Entity:GetNumBodyGroups() - 1 do
				if (mdl.Entity:GetBodygroupCount(k) <= 1) then continue end
				local bgroup = vgui.Create("DNumSlider")
				bgroup:Dock(TOP)
				bgroup:SetText(MakeNiceName(mdl.Entity:GetBodygroupName(k)))
				bgroup:SetDark(true)
				bgroup:SetTall(50)
				bgroup:SetDecimals(0)
				bgroup.type = "bgroup"
				bgroup.typenum = k
				bgroup:SetMax(mdl.Entity:GetBodygroupCount(k) - 1)
				bgroup:SetValue(groups[k + 1] or 0)
				bgroup.OnValueChanged = UpdateBodyGroups
				bdcontrolspanel:AddItem(bgroup)
				mdl.Entity:SetBodygroup(k, groups[k + 1] or 0)
				bgtab.Tab:SetVisible(true)
			end
		end

		local function UpdateFromConvars()
			local model = LocalPlayer():GetInfo("cl_playermodel")
			local modelname = player_manager.TranslatePlayerModel(model)
			util.PrecacheModel(modelname)
			mdl:SetModel(modelname)
			mdl.Entity.GetPlayerColor = function() return Vector(cl_playercolor:GetString()) end
			mdl.Entity:SetPos(Vector(-100, 0, -61))
			PlayPreviewAnimation(mdl, model)
			RebuildBodygroupTab()
		end

		UpdateFromConvars()

		function PanelSelect:OnActivePanelChanged(old, new)
			-- Only reset if we changed the model
			if (old ~= new) then
				RunConsoleCommand("cl_playerbodygroups", "0")
				RunConsoleCommand("cl_playerskin", "0")
			end

			timer.Simple(0.1, function()
				UpdateFromConvars()
			end)
		end

		-- Hold to rotate
		function mdl:DragMousePress()
			self.PressX, self.PressY = gui.MousePos()
			self.Pressed = true
		end

		function mdl:DragMouseRelease()
			self.Pressed = false
		end

		function mdl:LayoutEntity(Entity)
			if (self.bAnimated) then
				self:RunAnimation()
			end

			if (self.Pressed) then
				local mx = gui.MouseX()
				self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
				self.PressX, self.PressY = gui.MousePos()
			end

			Entity:SetAngles(self.Angles)
		end
	end
})
