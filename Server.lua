game.OnClose = function() wait(5) end
local Workspace = game:WaitForChild("Workspace")

local generate = false

game.Players.PlayerAdded:connect(function(Player)
	local clientClone = script.Client:Clone()
	clientClone.Parent = Player
	
	repeat wait() until Player.Character
	Player.Character.Humanoid.WalkSpeed = 60
	
	local Client = require(clientClone)
	clientClone.Internal.ServerLoaded.Value = true
	
	require(clientClone):PlayIntro(false)
end)

game.Players.PlayerRemoving:connect(function(Player)
	
end)

game.Workspace.ChildAdded:connect(function(hat)
	if hat:IsA("Hat") then hat:Destroy() end
end)

local function findCollectables(searchQuery)
	for _, query in pairs(searchQuery:GetChildren()) do
		if query.Name == "Collectable" then
			local handlingCooldown = false
			query.Cooldown.Changed:connect(function(value)
				if not handlingCooldown then
					handlingCooldown = true
					local function setActive(search, state)
						for _, child in pairs(search:GetChildren()) do
							if child:IsA("BasePart") then
								if state then
									child.Transparency = 0
								else
									child.Transparency = 1
								end
								child.CanCollide = state
							else
								setActive(child, state)
							end
						end
					end
					setActive(query.Active, false)
					for x = value, 0, -1 do
						wait(1)
						query.Cooldown.Value = x
					end
					setActive(query.Active, true)
					handlingCooldown = false
				end
			end)
		else
			findCollectables(query)
		end
	end
end
findCollectables(game.Workspace)

if generate then -- Generation Manager
	local generationType = "Cavern"
	local genSizeX, genSizeY, genOffset = 5, 5, 220
	for x = 1, genSizeX do
		for y = 1, genSizeY do
			if x == 1 and y == 1 then
				local instance = game.ServerStorage.Templates[generationType].Corner:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset))
				instance.Parent = game.Workspace.Terrain
			elseif x == 1 and y == genSizeY then
				local instance = game.ServerStorage.Templates[generationType].Corner:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(90), 0))
				instance.Parent = game.Workspace.Terrain
			elseif x == genSizeY and y == genSizeY then
				local instance = game.ServerStorage.Templates[generationType].Corner:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(180), 0))
				instance.Parent = game.Workspace.Terrain
			elseif x == genSizeX and y == 1 then
				local instance = game.ServerStorage.Templates[generationType].Corner:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(270), 0))
				instance.Parent = game.Workspace.Terrain
			elseif x == 1 then
				local instance = game.ServerStorage.Templates[generationType].Edge:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset))
				instance.Parent = game.Workspace.Terrain
			elseif y == 1 then
				local instance = game.ServerStorage.Templates[generationType].Edge:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(270), 0))
				instance.Parent = game.Workspace.Terrain
			elseif x == genSizeX then
				local instance = game.ServerStorage.Templates[generationType].Edge:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(180), 0))
				instance.Parent = game.Workspace.Terrain
			elseif y == genSizeY then
				local instance = game.ServerStorage.Templates[generationType].Edge:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, 1, (y*100)-genOffset) * CFrame.Angles(0, math.rad(90), 0))
				instance.Parent = game.Workspace.Terrain
			else
				local terrain = {}
				for _, template in pairs(game.ServerStorage.Templates[generationType].Terrain:GetChildren()) do
					for x = 1, template.Rarity.Value do
						table.insert(terrain, template[generationType])
					end
				end
				local randomGen = math.random(1, #terrain)
				local instance = terrain[randomGen]:Clone()
				instance:SetPrimaryPartCFrame(CFrame.new((x*100)-genOffset, math.random() + 1, (y*100)-genOffset)
					* CFrame.Angles(0, math.rad(90 * math.random(0, 3)), 0)
				)
				instance.Parent = game.Workspace.Terrain
			end
			wait(0.1)
		end
		wait(0.1)
	end
end
