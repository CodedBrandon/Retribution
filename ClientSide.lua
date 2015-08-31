local Screen = script.Parent:WaitForChild("Screen")
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Client = Player.Client
game.StarterGui:SetCoreGuiEnabled("All", false)
--game.StarterGui:SetCoreGuiEnabled("Backpack", true)
wait(1)

local debris = game.Debris
local RLib = require(game.ReplicatedStorage.RLib)

local ItemList = require(game.ReplicatedStorage.Items)
local playerRenderIndex = "http://www.roblox.com/thumbs/avatar.ashx?x=150&y=200&format=png&username="

local mouseOffsetX, mouseOffsetY = 0, 0

repeat wait() until Client.Internal.ServerLoaded.Value
local print = RLib.Print

local global = {
	settingKey = false
}

do -- GUI Animations
	local function menuButtonOpen(button)
		local pos = button.Position
		button.Position = UDim2.new(pos.X.Scale-0.5, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
		button.Visible = true
		button:TweenPosition(
			pos,
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.5, true, function()
				button.Position = pos
			end
		)
		wait(0.12)
	end
	local function menuButtonClose(button)
		local pos = button.Position
		button.Visible = true
		button:TweenPosition(
			UDim2.new(pos.X.Scale+0.25, pos.X.Offset, pos.Y.Scale, pos.Y.Offset),
			Enum.EasingDirection.In,
			Enum.EasingStyle.Back,
			0.5, true,
			function()
				button.Visible = false
				button.Position = pos
			end
		)
		wait(0.12)
	end
	
	local menuOpen, debounce, toggleMenu = false, true, function() end
	local forcedClose = false
	
	local menus = {
		Inventory = Screen.Inventory,
		Favorites = Screen.Favorites,
		Construct = Screen.Construct,
		Settings = Screen.Settings
	}
	
	local function closeAllMenus(toggle, invoke)
		for index, menu in pairs(menus) do
			if index ~= toggle then
				menu.Visible = false
			end
		end
		Screen.Container.Visible = false
		wait()
		invoke()
		if menuOpen then
			Screen.MainMenu.Visible = false
			debounce, forcedClose = true, true
			toggleMenu()
		end
	end
	
	openMenu = function() end
	
	toggleMenu = function()
		if type(openMenu) == "function" then openMenu() end
		if not forcedClose then
			Screen.Inventory.Visible = false
			Screen.Favorites.Visible = false
			Screen.Construct.Visible = false
			Screen.Settings.Visible = false
			Screen.Container.Visible = false
		else
			forcedClose = false
		end
		if debounce then
			debounce = false
			if menuOpen then
				menuButtonClose(Screen.MainMenu.Inventory)
				menuButtonClose(Screen.MainMenu.Favorites)
				menuButtonClose(Screen.MainMenu.Construct)
				menuButtonClose(Screen.MainMenu.Settings)
				wait(0.4)
				Screen.MainMenu.Visible = false
				menuOpen = false
			else
				Screen.MainMenu.Visible = true
				menuButtonOpen(Screen.MainMenu.Inventory)
				menuButtonOpen(Screen.MainMenu.Favorites)
				menuButtonOpen(Screen.MainMenu.Construct)
				menuButtonOpen(Screen.MainMenu.Settings)
				menuOpen = true
			end
			debounce = true
		end
	end
	Screen.OpenMenu.MouseButton1Down:connect(toggleMenu)
	
	local function openInventory()
		closeAllMenus("Inventory", function()
			Screen.Inventory.Visible = not Screen.Inventory.Visible
		end)
	end
	Screen.MainMenu.Inventory.MouseButton1Down:connect(openInventory)
	
	local function openFavorites()
		closeAllMenus("Favorites", function()
			Screen.Favorites.Visible = not Screen.Favorites.Visible
		end)
	end
	Screen.MainMenu.Favorites.MouseButton1Down:connect(openFavorites)
	
	local function openConstruct()
		closeAllMenus("Construct", function()
			Screen.Construct.Visible = not Screen.Construct.Visible
		end)
	end
	Screen.MainMenu.Construct.MouseButton1Down:connect(openConstruct)
	
	local function openSettings()
		closeAllMenus("Settings", function()
			Screen.Settings.Visible = not Screen.Settings.Visible
		end)
	end
	Screen.MainMenu.Settings.MouseButton1Down:connect(openSettings)
	
	local keyBinds = Client.Settings.Keybinds
	Mouse.KeyDown:connect(function(key)
		if not global.settingKey then
			if key == keyBinds.MainMenu.Value:lower() then
				toggleMenu()
			elseif key == keyBinds.Inventory.Value:lower() then
				openInventory()
			elseif key == keyBinds.Favorites.Value:lower() then
				openFavorites()
			elseif key == keyBinds.Construct.Value:lower() then
				openConstruct()
			end
		end
	end)
	
	do -- Inventory Player Render
		Screen.Inventory.Visual.PlayerRender.Image = playerRenderIndex..Player.Name
		Screen.Inventory.Visual.PlayerRender.PlayerName.Text = Player.Name
	end
	Screen.Settings.Visual.Versions.Text = string.format("%s | Roblox %s | Retribution %s",
		_VERSION, Version(), game.ReplicatedStorage.Version.Value 
	)
end

do -- Humanoid Handler
	Player.Character:WaitForChild("Humanoid").Died:connect(function()
		for _, gui in pairs(Screen:GetChildren()) do
			if gui.Name ~= "DeathScreen" then
				gui.Visible = false
			else
				gui.Visible = true
			end
		end
		Client.Interface.EquippedItem.Value = nil
	end)
	local human = Player.Character:WaitForChild("Humanoid") do
		human.WalkSpeed = 20
	end
	local status = Client.Status
	status.Health.Changed:connect(function(value) -- On Death
		if value <= 0 then
			human.Health = 0
			status.Health.Value = status.Health.MaxHealth.Value
			status.Hunger.Value = 100
			status.Stamina.Value = status.Stamina.MaxStamina.Value
		end
	end)
end

do -- Favorites Manager
	local favoritesGui, favEvents = Screen.Favorites.Visual, {}
	function restackFavorites()
		local favorites = {}
		for _, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
			if fav.Value then
				table.insert(favorites, fav.Value)
				fav.Value = nil
				for _, event in pairs(favEvents) do
					event:disconnect()
				end
			end
		end
		for x = 1, #favorites do
			Client.Inventory.Favorites["Favorite"..x].Value = favorites[x]
		end
	end
	for id, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
		fav.Changed:connect(function()
			if fav.Value then
				favoritesGui["Favorite"..id].ItemName.Text = fav.Value.Value
				favoritesGui["Favorite"..id].Equip.Visible = ItemList[fav.Value.Key.Value].Equip
				favoritesGui["Favorite"..id].ItemName.TextColor3 = Color3.new(150/255, 150/255, 150/255)
				local equipped = false
				local debounce = true
				local function equip()
					if debounce then debounce = false
						require(Player.Client):UnequipItems()
						wait(0.1)
						if
							not equipped and
							ItemList[fav.Value.Key.Value].Equip and
							fav.Value ~= Client.Interface.EquippedItem.Value
						then
							Client.Interface.EquippedItem.Value = fav.Value
							require(Player.Client):EquipItem(fav.Value.Key.Value)
							equipped = true
						else
							equipped = false
						end
					debounce = true
					end
				end
				local mouseEvent = favoritesGui["Favorite"..id].Equip.MouseButton1Down:connect(equip)
				local keyEvent = Mouse.KeyDown:connect(function(key)
					if key == tostring(id) then
						equip()
					end
				end)
				local equipEvent = Client.Interface.EquippedItem.Changed:connect(function(item)
					if item and item == fav.Value then
						favoritesGui["Favorite"..id].Equip.Text = "UNEQUIP"
					else
						favoritesGui["Favorite"..id].Equip.Text = "EQUIP"
					end
				end)
				if Client.Interface.EquippedItem.Value and Client.Interface.EquippedItem.Value == fav.Value then
					favoritesGui["Favorite"..id].Equip.Text = "UNEQUIP"
				end
				table.insert(favEvents, mouseEvent)
				table.insert(favEvents, keyEvent)
				table.insert(favEvents, equipEvent)
			else
				favoritesGui["Favorite"..id].ItemName.Text = "(empty)"
				favoritesGui["Favorite"..id].Equip.Visible = false
				favoritesGui["Favorite"..id].ItemName.TextColor3 = Color3.new(50/255, 50/255, 50/255)
			end
		end)
	end
end

do -- Inventory Manager
	local inventory = Screen.Inventory:WaitForChild("Visual"):WaitForChild("Inventory")
	local menuFocus, renderFocus = nil, nil
	local focusItemEvent = nil
	local imagesIds = {
		favoriteInactive = "rbxassetid://289122573",
		favoriteActive = "rbxassetid://289122615"
	}
	local function favoriteOpen()
		local favOpen, returnItem = false, nil
		for _, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
			if fav.Value == nil then
				return true, fav
			end
		end
		return false, nil
	end
	for row = 1, 5 do
		for col = 1, 5 do
			local item = inventory:WaitForChild("Row"..row).Items:WaitForChild("Item"..col)
			local currentItem = Client.Inventory["Row"..row]["Item"..col]
			item.MouseButton1Down:connect(function()
				if Client.Inventory.MouseItem:FindFirstChild("Item") then
					if currentItem:FindFirstChild("Item") then
						if focusItemEvent then
							focusItemEvent:disconnect()
							inventory.Parent.Info.Display.Visible = false
						end
						if Client.Inventory.MouseItem.Item.Key.Value == currentItem.Item.Key.Value then
							while
								currentItem.Item.Amount.Value < ItemList[currentItem.Item.Key.Value].MaxAmount
								and Client.Inventory.MouseItem:FindFirstChild("Item")
							do
								Client.Inventory.MouseItem.Item.Amount.Value = Client.Inventory.MouseItem.Item.Amount.Value - 1
								currentItem.Item.Amount.Value = currentItem.Item.Amount.Value + 1
								item.Amount.Text = currentItem.Item.Amount.Value
								if Client.Inventory.MouseItem.Item.Amount.Value <= 0 then
									Client.Inventory.MouseItem.Item:Destroy()
									inventory.Parent.MouseItem.Amount.Text = ""
									inventory.Parent.MouseItem.Image = ""
									break
								else
									inventory.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
								end
							end
						else
							Client.Inventory.MouseItem.Item.Parent,
							currentItem.Item.Parent = currentItem.Item.Parent,
							Client.Inventory.MouseItem.Item.Parent
							inventory.Parent.MouseItem.Image = "rbxassetid://"
								..ItemList[Client.Inventory.MouseItem.Item.Key.Value].ItemImage
							inventory.Parent.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
						end
					else
						Client.Inventory.MouseItem.Item.Parent = currentItem
					end
				else
					if renderFocus == item then
						renderFocus.BorderSizePixel = 0
						inventory.Parent.Info.Display.Visible = false
						currentItem.Item.Parent = Client.Inventory.MouseItem
						renderFocus = nil
					elseif currentItem:FindFirstChild("Item") then
						if renderFocus then renderFocus.BorderSizePixel = 0 end
						renderFocus = item
						item.BorderSizePixel = 2
						if Client.Internal.ClientLoaded.Value then
							local info = inventory.Parent.Info.Display
							info.Visible = true
							info.ItemName.Text = currentItem.Item.Value
							local function figureData() -- Data
								local listedData = ItemList[currentItem.Item.Key.Value]
								info.Data.Damage.Value.Text = listedData.Damage
								info.Data.Amount.Value.Text = currentItem.Item.Amount.Value
								info.Data.ItemValue.Value.Text = listedData.Value
								info.Data.StackValue.Value.Text = listedData.Value * currentItem.Item.Amount.Value
							end
							figureData()
							if currentItem.Item.Favorite.Value then
								info.Favorite.Text = "Unfavorite"
							else
								info.Favorite.Text = "Favorite"
							end
							if ItemList[currentItem.Item.Key.Value].Equip then
								if currentItem.Item == Client.Interface.EquippedItem.Value then
									info.Equip.Text = "Unequip"
								else
									info.Equip.Text = "Equip"
								end
								info.Equip.BackgroundColor3 = Color3.new(0, 85/255, 1)
							else
								info.Equip.Text = "Equip"
								info.Equip.BackgroundColor3 = Color3.new(100/255, 100/255, 100/255)
							end
							if focusItemEvent then focusItemEvent:disconnect() end
							focusItemEvent = currentItem.Item.Amount.Changed:connect(figureData)
						end
					else
						inventory.Parent.Info.Display.Visible = false
						if renderFocus then renderFocus.BorderSizePixel = 0 end
						renderFocus = nil
					end
					menuFocus = currentItem
				end
			end)
			local itemEvent = nil
			currentItem.ChildAdded:connect(function(newItem)
				item.Image = "rbxassetid://"..tostring(ItemList[newItem:WaitForChild("Key").Value].ItemImage)
				item.Amount.Text = newItem:WaitForChild("Amount").Value
				itemEvent = newItem.Amount.Changed:connect(function(value)
					if value < 1 then
						newItem:Destroy()
						item.Amount.Text = ""
					else
						item.Amount.Text = value
					end
				end)
			end)
			currentItem.ChildRemoved:connect(function()
				item.Image = ""
				item.Amount.Text = ""
				if itemEvent then itemEvent:disconnect() end
				inventory.Parent.Info.Display.Visible = false
				if renderFocus and renderFocus == item then
					renderFocus.BorderSizePixel = 0
					renderFocus = nil
				end
			end)
			if currentItem:FindFirstChild("Item") then
				item.Image = "rbxassetid://"..tostring(ItemList[currentItem.Item.Key.Value].ItemImage)
				item.Amount.Text = currentItem.Item.Amount.Value
				itemEvent = currentItem.Item.Amount.Changed:connect(function(value)
					if value < 1 then
						currentItem.Item:Destroy()
						item.Amount.Text = ""
					else
						item.Amount.Text = value
					end
				end)
			end
		end
	end
	inventory.Parent.Info.Display.Equip.MouseButton1Down:connect(function()
		
	end)
	local function moveMouseItem() -- Mouse Item
		repeat wait() until Client.Internal.ClientLoaded.Value
		local posX = (Mouse.X-inventory.Parent.AbsolutePosition.X)
		local posY = (Mouse.Y-inventory.Parent.AbsolutePosition.Y)
		inventory.Parent.MouseItem.Position = UDim2.new(0, posX+mouseOffsetX, 0, posY+mouseOffsetY)
	end
	do -- Mouse Events
		Mouse.Move:connect(moveMouseItem)
		inventory.Changed:connect(moveMouseItem)
	end
  	do -- Handle Mouse Item Render
		Client.Inventory.MouseItem.ChildAdded:connect(function(item)
			inventory.Parent.MouseItem.Image = "rbxassetid://"..tostring(ItemList[item:WaitForChild("Key").Value].ItemImage)
			inventory.Parent.MouseItem.Amount.Text = item:WaitForChild("Amount").Value
		end)
		Client.Inventory.MouseItem.ChildRemoved:connect(function()
			inventory.Parent.MouseItem.Image = ""
			inventory.Parent.MouseItem.Amount.Text = ""
		end)
	end
	inventory.Parent.MouseLeave:connect(function()
		if Client.Inventory.MouseItem:FindFirstChild("Item") then
			for row = 1, 5 do
				for col = 1, 5 do
					local invSlot = Client.Inventory["Row"..row]["Item"..col]
					if not invSlot:FindFirstChild("Item") then
						local item = Client.Inventory.MouseItem:FindFirstChild("Item")
						if item then item.Parent = invSlot end
						break
					end
				end
			end
		end
	end)
	inventory.Parent.Info.Display.Favorite.MouseButton1Down:connect(function()
		local favOpen, favorite = favoriteOpen()
		if menuFocus and menuFocus:FindFirstChild("Item") then
			if inventory.Parent.Info.Display.Favorite.Text == "Favorite" then
				if favOpen then
					favorite.Value = menuFocus.Item
					menuFocus.Item.Favorite.Value = true
					restackFavorites()
				end
				inventory.Parent.Info.Display.Favorite.Text = "Unfavorite"
			elseif inventory.Parent.Info.Display.Favorite.Text == "Unfavorite" then
				menuFocus.Item.Favorite.Value = false
				for _, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
					if fav.Value == menuFocus.Item then
						fav.Value = nil
						restackFavorites()
					end
				end
				inventory.Parent.Info.Display.Favorite.Text = "Favorite"
			end
		end
	end)
end

do -- Chat Manager
	local clickMessage = "Click here or press '"..Client.Settings.Keybinds.Chat.Value.."' to chat."
	local chatBox = Screen.SendChat.NameText
	Client.Settings.Keybinds.Chat.Changed:connect(function(newKey)
		if RLib.Keys[newKey:upper()] then
			clickMessage = "Click here or press '"..RLib.Keys[newKey:upper()].."' to chat."
			chatBox.Text = clickMessage
		end
	end)
	chatBox.Text = clickMessage
	chatBox.Focused:connect(function()
		if chatBox.Text == clickMessage then
			chatBox.Text = ""
		end
		Screen.Display.Visible = false
	end)
	chatBox.FocusLost:connect(function(entered)
		if entered and chatBox.Text ~= clickMessage then
			game.Workspace.Chat.Value = string.format("[%s] %s", Player.Name, chatBox.Text)
			chatBox.Text = clickMessage
		elseif chatBox.Text == "" then
			chatBox.Text = clickMessage
		end
		Screen.Display.Visible = true
	end)
	game.Workspace.Chat.Changed:connect(function(chat)
		if Client.Settings.Chat.Global.Value then
			require(Client):PushChat(
				chat,
				game.Workspace.Chat.Color.Value,
				game.Workspace.Chat.Bold.Value
			)
		end
	end)
	Mouse.KeyDown:connect(function(key)
		if not global.settingKey and key == Client.Settings.Keybinds.Chat.Value then
			chatBox:CaptureFocus()
		end
	end)
end

do -- Container Magnager
	local containerGui, events, lastMessage = Screen.Container.Visual, {}, ""
	local function validatePosition(position)
		local invPos = position
		local playerPos = Player.Character:FindFirstChild("Torso")
		local xTrue, yTrue, zTrue = false, false, false
		if playerPos then
			if math.abs(invPos.X - playerPos.Position.X) <= 20 then
				xTrue = true
			end
			if math.abs(invPos.Y - playerPos.Position.Y) <= 20 then
				yTrue = true
			end
			if math.abs(invPos.Z - playerPos.Position.Z) <= 20 then
				zTrue = true
			end
		end
		return (xTrue and yTrue and zTrue)
	end
	Mouse.Button1Down:connect(function()
		local target = Mouse.Target
		if target then
			local container = target:FindFirstChild("Container")
			
			if container and not container.IsOpen.Value and validatePosition(container.Parent.Position) then
				
				Screen.Inventory.Visible = false
				Screen.Favorites.Visible = false
				Screen.Construct.Visible = false
				Screen.Settings.Visible = false
				Client.Interface.OpenContainer.Value = container
				container.IsOpen.Value = true
				containerGui.Container.CanvasSize = UDim2.new(0, 0, 0, (container.Rows.Value * 90) + 5)
				for row = 1, #containerGui.Container:GetChildren() do
					if row <= container.Rows.Value then
						containerGui.Container["Row"..row].Visible = true
						for x = 1, 5 do
							local item = container.Inventory["Row"..row]["Item"..x]:FindFirstChild("Item")
							local containerSlot = containerGui.Container["Row"..row].Items["Item"..x]
							if item then
								containerSlot.Image = "rbxassetid://"..ItemList[item.Key.Value].ItemImage
								containerSlot.Amount.Text = item.Amount.Value
							end
							local event1 = containerSlot.MouseButton1Down:connect(function()
								local containerItem = container.Inventory["Row"..row]["Item"..x]
								if Client.Inventory.MouseItem:FindFirstChild("Item") and containerItem:FindFirstChild("Item") then
									if Client.Inventory.MouseItem.Item.Key.Value == containerItem.Item.Key.Value then
										while
											containerItem.Item.Amount.Value < ItemList[containerItem.Item.Key.Value].MaxAmount and
											Client.Inventory.MouseItem:FindFirstChild("Item")
										do
											Client.Inventory.MouseItem.Item.Amount.Value = Client.Inventory.MouseItem.Item.Amount.Value - 1
											containerItem.Item.Amount.Value = containerItem.Item.Amount.Value + 1
											containerSlot.Amount.Text = containerItem.Item.Amount.Value
											if Client.Inventory.MouseItem.Item.Amount.Value <= 0 then
												Client.Inventory.MouseItem.Item:Destroy()
												containerGui.MouseItem.Amount.Text = ""
												containerGui.MouseItem.Image = ""
												break
											else
												containerGui.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
											end
										end
									else
										if Client.Inventory.MouseItem.Item.Favorite.Value then
											Client.Inventory.MouseItem.Item.Favorite.Value = false
											for _, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
												if fav.Value == Client.Inventory.MouseItem.Item then
													fav.Value = nil
													restackFavorites()
												end
											end
										end
										Client.Inventory.MouseItem.Item.Parent,
										containerItem.Item.Parent = containerItem.Item.Parent,
										Client.Inventory.MouseItem.Item.Parent
										containerGui.MouseItem.Image = "rbxassetid://"..ItemList[Client.Inventory.MouseItem.Item.Key.Value].ItemImage
										containerGui.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
									end
								elseif containerItem:FindFirstChild("Item") then
									containerItem.Item.Parent = Client.Inventory.MouseItem
								elseif Client.Inventory.MouseItem:FindFirstChild("Item") then
									if Client.Inventory.MouseItem.Item.Favorite.Value then
										Client.Inventory.MouseItem.Item.Favorite.Value = false
										for _, fav in pairs(Client.Inventory.Favorites:GetChildren()) do
											if fav.Value == Client.Inventory.MouseItem.Item then
												fav.Value = nil
												restackFavorites()
											end
										end
									end
									Client.Inventory.MouseItem.Item.Parent = containerItem
								end
							end)
							local event2 = container.Inventory["Row"..row]["Item"..x].ChildAdded:connect(function(newItem)
								newItem:WaitForChild("Key"); newItem:WaitForChild("Amount")
								containerSlot.Image = "rbxassetid://"..ItemList[newItem.Key.Value].ItemImage
								containerSlot.Amount.Text = newItem.Amount.Value
							end)
							local event3 = container.Inventory["Row"..row]["Item"..x].ChildRemoved:connect(function()
								containerSlot.Image = ""
								containerSlot.Amount.Text = ""
							end)
							table.insert(events, event1)
							table.insert(events, event2)
							table.insert(events, event3)
						end
					else
						containerGui.Container["Row"..row].Visible = false
					end
				end
				for row = 1, 5 do
					for x = 1, 5 do
						local item = Client.Inventory["Row"..row]["Item"..x]:FindFirstChild("Item")
						local invSlot = containerGui.Inventory["Row"..row].Items["Item"..x]
						if item then
							invSlot.Image = "rbxassetid://"..ItemList[item.Key.Value].ItemImage
							invSlot.Amount.Text = item.Amount.Value
						else
							invSlot.Image = ""
							invSlot.Amount.Text = ""
						end
						local event4 = invSlot.MouseButton1Down:connect(function()
							local itemSlot = Client.Inventory["Row"..row]["Item"..x]
							if itemSlot:FindFirstChild("Item")
								and itemSlot.Item == Client.Interface.EquippedItem.Value
								and Player.Character
							then
								Player.Character.Humanoid:UnequipTools()
								Client.Interface.EquippedItem.Value = nil
							end
							if Client.Inventory.MouseItem:FindFirstChild("Item") and itemSlot:FindFirstChild("Item") then
								if Client.Inventory.MouseItem.Item.Key.Value == itemSlot.Item.Key.Value then
									while
										itemSlot.Item.Amount.Value < ItemList[itemSlot.Item.Key.Value].MaxAmount
										and Client.Inventory.MouseItem:FindFirstChild("Item")
									do
										Client.Inventory.MouseItem.Item.Amount.Value = Client.Inventory.MouseItem.Item.Amount.Value - 1
										itemSlot.Item.Amount.Value = itemSlot.Item.Amount.Value + 1
										invSlot.Amount.Text = itemSlot.Item.Amount.Value
										if Client.Inventory.MouseItem.Item.Amount.Value <= 0 then
											Client.Inventory.MouseItem.Item:Destroy()
											containerGui.MouseItem.Amount.Text = ""
											containerGui.MouseItem.Image = ""
											break
										else
											containerGui.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
										end
									end
								else
									Client.Inventory.MouseItem.Item.Parent,
									itemSlot.Item.Parent = itemSlot.Item.Parent,
									Client.Inventory.MouseItem.Item.Parent
									containerGui.MouseItem.Image = "rbxassetid://"..ItemList[Client.Inventory.MouseItem.Item.Key.Value].ItemImage
									containerGui.MouseItem.Amount.Text = Client.Inventory.MouseItem.Item.Amount.Value
								end
							elseif itemSlot:FindFirstChild("Item") then
								itemSlot.Item.Parent = Client.Inventory.MouseItem
							elseif Client.Inventory.MouseItem:FindFirstChild("Item") then
								Client.Inventory.MouseItem.Item.Parent = itemSlot
							end
						end)
						local event5 = Client.Inventory["Row"..row]["Item"..x].ChildAdded:connect(function(newItem)
							newItem:WaitForChild("Key"); newItem:WaitForChild("Amount")
							invSlot.Image = "rbxassetid://"..ItemList[newItem.Key.Value].ItemImage
							invSlot.Amount.Text = newItem.Amount.Value
						end)
						local event6 = Client.Inventory["Row"..row]["Item"..x].ChildRemoved:connect(function()
							invSlot.Image = ""
							invSlot.Amount.Text = ""
						end)
						table.insert(events, event4)
						table.insert(events, event5)
						table.insert(events, event6)
					end
				end
				
				containerGui.ConTitle.Text = container.ContainerName.Value
				Screen.Container.Visible = true
			end
		end
	end)
	Mouse.Move:connect(function()
		local posX = Mouse.X-containerGui.AbsolutePosition.X
		local posY = Mouse.Y-containerGui.AbsolutePosition.Y
		containerGui.MouseItem.Position = UDim2.new(0, posX+mouseOffsetX, 0, posY+mouseOffsetY)
		local target = Mouse.Target
		if target and target:FindFirstChild("Container") and validatePosition(target.Position) then
			lastMessage = "Open "..target.Container.ContainerName.Value
			require(Client):Message(lastMessage, Color3.new(85/255, 0, 245/255))
		elseif require(Client):Message() == lastMessage then
			require(Client):Message("")
		end
	end)
	Client.Inventory.MouseItem.ChildAdded:connect(function(item)
		containerGui.MouseItem.Image = "rbxassetid://"..ItemList[item:WaitForChild("Key").Value].ItemImage
		containerGui.MouseItem.Amount.Text = item:WaitForChild("Amount").Value
	end)
	Client.Inventory.MouseItem.ChildRemoved:connect(function()
		containerGui.MouseItem.Image = ""
		containerGui.MouseItem.Amount.Text = ""
	end)
	local function closeContainer()
		if Client.Interface.OpenContainer.Value then
			Screen.Container.Visible = false
			for _, event in pairs(events) do
				event:disconnect()
			end
			events = {}
			Client.Interface.OpenContainer.Value.IsOpen.Value = false
			Client.Interface.OpenContainer.Value = nil
		end
	end
	openMenu = closeContainer
	do -- Close Container
		Player.Changed:connect(closeContainer)
		Player.Idled:connect(closeContainer)
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then
			Player.Character.Humanoid.Jumping:connect(closeContainer)
			Player.Character.Humanoid.Strafing:connect(closeContainer)
			Player.Character.Humanoid.Changed:connect(closeContainer)
			Player.Character.Torso.Changed:connect(closeContainer)
		end
	end
end

do -- Collectables
	local focusedCollectable, lastMessage = nil, ""
	Mouse.Move:connect(function()
		local target = Mouse.Target
		if target and target.Name == "Collectable" then
			if target:FindFirstChild("Cooldown").Value <= 0 then
				focusedCollectable = target
				require(Client):Message(target.Message.Value, target.Message.Color.Value)
				lastMessage = target.Message.Value
			elseif require(Client):Message() == target.Message.Value then
				require(Client):Message("")
			end
		else
			focusedCollectable = nil
			if require(Client):Message() == lastMessage then
				require(Client):Message("")
			end
		end
	end)
	Mouse.Button1Down:connect(function()
		if focusedCollectable and focusedCollectable.Cooldown.Value <= 0 then
			local canCollect = false
			for row = 1, 5 do
				local breakLoop = false
				for col = 1, 5 do
					local slot = Client.Inventory["Row"..row]["Item"..col]
					if slot:FindFirstChild("Item") then
						if
							slot.Item.Key.Value == focusedCollectable.CollectionKey.Value
							and focusedCollectable.CollectionKey.MaxValue.Value
							< ItemList[slot.Item.Key.Value].MaxAmount - slot.Item.Amount.Value
						then
							canCollect, breakLoop = true, true
							break
						end 
					else
						canCollect, breakLoop = true, true
						break
					end
				end
				if breakLoop then break end
			end
			if canCollect then
				focusedCollectable.Cooldown.Value = math.random(
					focusedCollectable.Cooldown.MinTime.Value,
					focusedCollectable.Cooldown.MaxTime.Value
				) * 3
				local collectionAmount = math.random(
					focusedCollectable.CollectionKey.MinValue.Value,
					focusedCollectable.CollectionKey.MaxValue.Value
				)
				local collectedItem = game.ReplicatedStorage.ItemCasts[focusedCollectable.CollectionKey.Value].Item:Clone()
				collectedItem.Amount.Value = collectionAmount
				local breakLoop = false
				for row = 1, 5 do
					for col = 1, 5 do
						local slot = Client.Inventory["Row"..row]["Item"..col]
						if slot:FindFirstChild("Item") then
							if slot.Item.Key.Value == collectedItem.Key.Value then
								local breakInnerLoop = false
								while slot.Item.Amount.Value < ItemList[slot.Item.Key.Value].MaxAmount do
									slot.Item.Amount.Value = slot.Item.Amount.Value + 1
									if collectedItem.Amount.Value <= 1 then
										breakLoop, breakInnerLoop = true, true
										collectedItem:Destroy()
										break
									end
									collectedItem.Amount.Value = collectedItem.Amount.Value - 1
								end
								if breakInnerLoop then break end
							end
			 			elseif #slot:GetChildren() == 0 then
							collectedItem.Parent = slot
							breakLoop = true
							break
						end
					end
					if breakLoop then break end
					
				end
				local collectionMessage = "Collected "..collectionAmount.." "..collectedItem.Value				
				if collectionAmount > 1 then collectionMessage = collectionMessage.."s" end
				require(Client):Message( collectionMessage, focusedCollectable.Message.Color.Value)
				wait(2)
				if require(Client):Message() == collectionMessage then require(Client):Message("") end
			end
		end
	end)
end

do -- Construct Manager
	local constructGui, posIterator, focusRecipe = Screen.Construct.Visual, 0, nil
	local constructAction = function() end
	for index, item in pairs(ItemList) do
		if item.Constructable then
			local indexRecipe = constructGui.List.RecipeTemplate:Clone()
			indexRecipe.Name = "Recipe"
			indexRecipe.Position = UDim2.new(0, 5, 0, (posIterator * 65) + 5)
			indexRecipe.ItemName.Text = index
			indexRecipe.ItemDisplay.Image = "rbxassetid://"..item.ItemImage
			indexRecipe.Amount.Text = item.ConstructAmount.."x"
			indexRecipe.Visible = true
			indexRecipe.Parent = constructGui.List
			constructGui.List.CanvasSize = UDim2.new(0, 5, 0, (posIterator * 65) + 5)
			posIterator = posIterator + 1
			indexRecipe.Activate.MouseButton1Down:connect(function()
				if not focusRecipe or focusRecipe ~= index then
					focusRecipe = index
					constructGui.ItemDisplay.Image = "rbxassetid://"..item.ItemImage
					for _, gui in pairs(constructGui.Info:GetChildren()) do
						gui.Visible = true
					end
					for _, ingredientGui in pairs(constructGui.Info.Ingredients.List:GetChildren()) do
						if ingredientGui.Name == "Ingredient" then
							ingredientGui:Destroy()
						end
					end
					local ingredientIterator, ingredientGuiSize = 0, 25
					for ingredient, amount in pairs(item.Recipe) do
						constructGui.Info.ItemName.Text = index
						local ingredientGui = constructGui.Info.Ingredients.List.IngredientTemplate:Clone()
						ingredientGui.Name = "Ingredient"
						ingredientGui.Position = UDim2.new(0, 0, 0, (ingredientIterator * ingredientGuiSize))
						ingredientGui.IngredientName.Text = tostring(ingredient)
						ingredientGui.IngredientAmount.Text = tostring(amount).."x"
						ingredientGui.IngredientImage.Image = "rbxassetid://"..ItemList[ingredient].ItemImage
						ingredientGui.Visible = true
						ingredientGui.Parent = constructGui.Info.Ingredients.List
						constructGui.Info.Ingredients.List.CanvasSize = UDim2.new(0, 0, 0, (ingredientIterator * ingredientGuiSize))
						ingredientIterator = ingredientIterator + 1
					end
					if (#constructGui.Info.Ingredients.List:GetChildren())-1 > 3 then
						for _, ingredientGui in pairs(constructGui.Info.Ingredients.List:GetChildren()) do
							if ingredientGui.Name == "Ingredient" then
								ingredientGui.Size = UDim2.new(1, -15, 0, 25)
							end
						end
					end
					constructAction = function()
						if constructGui.Info.Construct.Text == "CONSTRUCT" then
							constructGui.Info.Construct.Text = "Attempting to Construct"
							constructGui.Info.Construct.FontSize = Enum.FontSize.Size18
							local collectedIngredients = {}
							for row = 1, 5 do
								for x = 1, 5 do
									local invSlot = Client.Inventory["Row"..row]["Item"..x]:FindFirstChild("Item")
									if invSlot then
										for ingredient, amount in pairs(item.Recipe) do
											if invSlot.Key.Value == ingredient then
												table.insert(collectedIngredients, invSlot)
											end
										end 
									end
									wait()
								end
							end
							local hasIngredient = {}
							for ingredient, amount in pairs(item.Recipe) do
								local itemAmount = 0
								for _, collectedIngredient in pairs(collectedIngredients) do
									if collectedIngredient.Key.Value == ingredient then
										itemAmount = itemAmount + collectedIngredient.Amount.Value
									end
								end
								hasIngredient[ingredient] = (itemAmount >= amount)
							end
							local hasAllIngredients = false
							for _, ingredientCheck in pairs(hasIngredient) do
								if not ingredientCheck then
									hasAllIngredients = false
									break
								else
									hasAllIngredients = true
								end
							end
							local openInvSlot = nil
							for row = 1, 5 do
								local breakRowLoop = false
								for x = 1, 5 do
									if not Client.Inventory["Row"..row]["Item"..x]:FindFirstChild("Item") then
										openInvSlot = Client.Inventory["Row"..row]["Item"..x]
										breakRowLoop = true
										break
									end
								end
								if breakRowLoop then break end
							end
							if hasAllIngredients then
								if openInvSlot then
									for ingredient, amount in pairs(item.Recipe) do
										local consumedAmount = amount
										for _, collectedIngredient in pairs(collectedIngredients) do
											if collectedIngredient.Key.Value == ingredient then
												if collectedIngredient.Amount.Value > consumedAmount then
													collectedIngredient.Amount.Value =
														collectedIngredient.Amount.Value - consumedAmount
													break
												else
													consumedAmount = consumedAmount - collectedIngredient.Amount.Value
													for x = 1, 8 do
														local favorite = Client.Inventory.Favorites["Favorite"..x]
														if favorite.Value == collectedIngredient then
															favorite.Value = nil
															restackFavorites()
															break
														end
													end
													collectedIngredient:Destroy()
												end
											end
										end
									end
									local itemAmount = item.ConstructAmount
									for row = 1, 5 do
										for x = 1, 5 do
											local invItem = Client.Inventory["Row"..row]["Item"..x]:FindFirstChild("Item")
											if
												invItem and
												invItem.Key.Value == index
											then
												while
													invItem.Amount.Value < ItemList[invItem.Key.Value].MaxAmount
													and itemAmount > 0
												do
													invItem.Amount.Value = invItem.Amount.Value + 1
													itemAmount = itemAmount - 1
												end
											end
										end
									end
									if itemAmount > 0 then
										local constructedItem = game.ReplicatedStorage.ItemCasts[index].Item:Clone()
										constructedItem.Parent = openInvSlot
										constructedItem.Amount.Value = itemAmount
									end
									constructGui.Info.Construct.Text = "Constructed "..item.ConstructAmount.."x "..index
								else
									constructGui.Info.Construct.Text = "No Inventory Space"
								end
							else
								constructGui.Info.Construct.Text = "Ingredients Missing"
							end
							wait(2)
							constructGui.Info.Construct.FontSize = Enum.FontSize.Size24
							constructGui.Info.Construct.Text = "CONSTRUCT"
						end
					end
				else
					for _, gui in pairs(constructGui.Info:GetChildren()) do
						gui.Visible = false
					end
					constructAction = function() end
					constructGui.ItemDisplay.Image = ""
					focusRecipe = nil
				end
			end)
		end
	end
	constructGui.Info.Construct.MouseButton1Down:connect(function()
		constructAction()
	end)
end

do -- Settings Manager
	local settingsGui = Screen.Settings.Visual
	do -- Keybinds
		local keys = require(game.ReplicatedStorage.RLib).Keys
		for _, keySetting in pairs(Client.Settings.Keybinds:GetChildren()) do
			local keyGui = settingsGui.Keybinds[keySetting.Name]
			keySetting.Changed:connect(function(newKey)
				if #newKey == 1 and keys[newKey:upper()] then
					keyGui.Key.Bind.Text = keys[newKey:upper()]
				else
					for index, key in pairs(keys) do
						if key == keyGui.Key.Bind.Text then
							keySetting.Value = index
							break
						end
					end
				end
			end)
			keyGui.Key.Bind.MouseButton1Down:connect(function()
				global.settingKey = true
				local originBind = keyGui.Key.Bind.Text
				keyGui.Key.Bind.Text = "_"
				local disconnectEvent = function() end
				local keyedEvent = Mouse.KeyDown:connect(function(key)
					if keys[tostring(key):upper()] then
						keySetting.Value = tostring(key)
					else
						keyGui.Key.Bind.Text = originBind
					end
					disconnectEvent()
					delay(1, function() global.settingKey = false end)
				end)
				disconnectEvent = function()
					keyedEvent:disconnect()
				end
			end)
		end
	end
	do -- Chat
		for index, chatSetting in pairs(Client.Settings.Chat:GetChildren()) do
			local guiSetting = settingsGui.EnableChat.Toggle[chatSetting.Name.."Enabled"]
			chatSetting.Changed:connect(function(enabled)
				if enabled then
					guiSetting.BackgroundColor3 = Color3.new(50/255, 50/255, 50/255)
				else
					guiSetting.BackgroundColor3 = Color3.new(65/255, 65/255, 65/255)
				end
			end)
			guiSetting.MouseButton1Down:connect(function()
				chatSetting.Value = not chatSetting.Value
			end)
		end
	end
end

do -- Status Manager
	local status = Client.Status
	local healthLoop = false
	status.Health.Changed:connect(function()
		if not healthLoop then
			healthLoop = true
			while status.Health.Value < status.Health.MaxHealth.Value do
				status.Health.Value = status.Health.Value + 1
				wait(math.abs(math.floor((status.Hunger.Value-1)/10)-10)*0.75)
			end
			healthLoop = false
		end
		Screen.Display.Health.Meter.Size = UDim2.new(
			status.Health.Value/status.Health.MaxHealth.Value, 0, 1, 0
		)
		Screen.Display.Health.Meter.Position = UDim2.new(
			math.abs((status.Health.Value/status.Health.MaxHealth.Value)-1), 0, 0, 0
		)
		Screen.Display.Health.Display.Text = string.format("%s/%s",
			status.Health.Value,
			status.Health.MaxHealth.Value
		)
	end)
	status.Hunger.Changed:connect(function()
		Screen.Display.Hunger.Meter.Size = UDim2.new(
			status.Hunger.Value/100, 0, 1, 0
		)
		Screen.Display.Hunger.Meter.Position = UDim2.new(
			math.abs((status.Hunger.Value/100)-1), 0, 0, 0
		)
		Screen.Display.Hunger.Display.Text = string.format("%s/%s",
			status.Hunger.Value, 100
		)
	end)
	local staminaLoop = false
	status.Stamina.Changed:connect(function()
		if not staminaLoop then
			staminaLoop = true
			while status.Stamina.Value < status.Stamina.MaxStamina.Value do
				status.Stamina.Value = status.Stamina.Value + 1
				wait(status.Stamina.StaminaRegen.Value/10)
			end
			staminaLoop = false
		end
		Screen.Display.Stamina.Meter.Size = UDim2.new(
			status.Stamina.Value/status.Stamina.MaxStamina.Value, 0, 1, 0
		)
		Screen.Display.Stamina.Display.Text = string.format("%s/%s",
			status.Stamina.Value,
			status.Stamina.MaxStamina.Value
		)
	end)
	local manaLoop = false
	status.Magicka.Changed:connect(function()
		if not manaLoop then
			manaLoop = true
			while status.Magicka.Value < status.Magicka.MaxMagicka.Value do
				status.Magicka.Value = status.Magicka.Value + 1
				wait(status.Magicka.MagickaRegen.Value/10)
			end
			manaLoop = false
		end
		Screen.Display.Magicka.Meter.Size = UDim2.new(
			status.Magicka.Value/status.Magicka.MaxMagicka.Value, 0, 1, 0
		)
		Screen.Display.Magicka.Display.Text = string.format("%s/%s",
			status.Magicka.Value,
			status.Magicka.MaxMagicka.Value
		)
	end)
end

do -- Item Manager
	local itemDown = function() end
	local itemUp = function() end
	local reloadKey = function() end
	local backpack = Player:WaitForChild("Backpack")
	do -- Handle Item Activations
		do -- Flashlight
			local flashlight = backpack:WaitForChild("Flashlight")
			local toolEquipped = false
			flashlight.Equipped:connect(function()
				toolEquipped = true
				local item = Client.Interface.EquippedItem.Value
				if item then
					flashlight.Handle.Light.Enabled = item.Data.LightOn.Value
					itemDown = function()
						item.Data.LightOn.Value = not item.Data.LightOn.Value
						if item.Data.Energy.Value > 0 then
							flashlight.Handle.Light.Enabled = item.Data.LightOn.Value
						end
					end
					Screen.Status.Flashlight.Visible = true
					Screen.Status.Flashlight.Meter.Energy.Size = UDim2.new(
						item.Data.Energy.Value/100, 0, 1, 0
					)
					Screen.Status.Flashlight.Meter.Level.Text = item.Data.Energy.Value.."%"
					local function reloadBatteries()
						local battery = nil
						for row = 1, 5 do
							for x = 1, 5 do
								local item = Client.Inventory["Row"..row]["Item"..x]
								if item:FindFirstChild("Item") and item.Item.Key.Value == "Battery" then
									battery = item.Item
									break
								end
							end
						end
						if battery then
							battery.Amount.Value = battery.Amount.Value - 1
							if item.Data.Energy.Value > 50 then
								item.Data.Energy.Value = 100
							else
								item.Data.Energy.Value = item.Data.Energy.Value + 50
							end
							flashlight.Handle.Light.Enabled = item.Data.LightOn.Value
						end
					end
					reloadKey = reloadBatteries
					Screen.Status.Flashlight.Battery.MouseButton1Down:connect(reloadBatteries)
					while toolEquipped and item == Client.Interface.EquippedItem.Value do
						if item.Data.LightOn.Value and item.Data.Energy.Value > 0 then
							item.Data.Energy.Value = item.Data.Energy.Value - 1
						elseif item.Data.Energy.Value <= 0 then
							flashlight.Handle.Light.Enabled = false
						end
						Screen.Status.Flashlight.Meter.Energy.Size = UDim2.new(
							item.Data.Energy.Value/100, 0, 1, 0
						)
						Screen.Status.Flashlight.Meter.Level.Text = item.Data.Energy.Value.."%"
						for x = 0, 3.6, 0.1 do
							if toolEquipped then
								wait(0.1)
							else
								break
							end
						end
					end
				end
			end)
			flashlight.Unequipped:connect(function()
				toolEquipped = false
				Screen.Status.Flashlight.Visible = false
			end)
			do -- GUI
				local Gui = Screen.Status.Flashlight
				Gui.Battery.MouseEnter:connect(function()
					Gui.Meter.Refill.Visible = true
				end)
				Gui.Battery.MouseMoved:connect(function()
					Gui.Meter.Refill.Visible = true
				end)
				Gui.Battery.MouseLeave:connect(function()
					Gui.Meter.Refill.Visible = false
				end)
			end
		end
		do -- Grenade
			local grenade = backpack:WaitForChild("Grenade")
			grenade.Equipped:connect(function()
				local item = Client.Interface.EquippedItem.Value
				if item then
					local debounce = true
					itemDown = function()
						local waitTime = ItemList[item.Key.Value].UseTime
						local dmgAmount = ItemList[item.Key.Value].Damage
						if debounce and item.Amount.Value > 0 then
							debounce = false
							local explosive = coroutine.create(function()
								local bomb = grenade.Handle:Clone()
								bomb.Name = "Bomb"
								bomb.CanCollide = true
								bomb.Kaboom.CanCollide = true
								bomb.Parent = game.Workspace.Debris
								local visualEffect = bomb.Kaboom
								wait(3)
								visualEffect.Parent = bomb.Parent
								bomb:Destroy()
								visualEffect.Explosion:Play()
								visualEffect.Light.Enabled = true
								visualEffect.BrickColor = BrickColor.new(255, 0, 0)
								local pos = visualEffect.CFrame
								visualEffect.Anchored = true
								visualEffect.CanCollide = false
								local dmgedPlayers = {}
								visualEffect.Touched:connect(function(part)
									local touchedPlayer = game.Players:FindFirstChild(part.Parent.Name)
									if touchedPlayer then
										local listedPlayer = false
										for _, player in pairs(dmgedPlayers) do
											if player == touchedPlayer then
												listedPlayer = true
												break
											end
										end
										if not listedPlayer then
											table.insert(dmgedPlayers, touchedPlayer)
											touchedPlayer.Client.Status.Health.Value = 
												touchedPlayer.Client.Status.Health.Value - dmgAmount
										end
									end
								end)
								for x = 0.1, 2.1, 0.1 do
									visualEffect.Size = Vector3.new(x*8, x*8, x*8)
									visualEffect.CFrame = pos
									visualEffect.Transparency = x / 2
									visualEffect.Light.Brightness = x
									wait()
								end
								visualEffect.CFrame = pos
								visualEffect:Destroy()
								explosive = nil
							end)
							coroutine.resume(explosive)
							if item.Amount.Value <= 1 then
								item:Destroy()
								require(Player.Client):UnequipItems()
							else
								item.Amount.Value = item.Amount.Value - 1
							end
							wait(waitTime)
							debounce = true
						end
					end
				end
			end)
		end
		do -- Knife
			local knife = backpack:WaitForChild("Knife")
			knife.Equipped:connect(function()
				local item = Client.Interface.EquippedItem.Value
				if item then
					local debounce = true
					itemDown = function()
						if debounce then
							debounce = false
							local target = Mouse.Target
							if target then
								local hitPlayer = game.Players:FindFirstChild(target.Parent.Name)
								if hitPlayer then
									hitPlayer.Client.Status.Health.Value =
										hitPlayer.Client.Status.Health.Value - ItemList[item.Key.Value].Damage
									wait(ItemList[item.Key.Value].UseTime)
								end
							end
							debounce = true
						end
					end
				end
			end)
		end
	end
	for _, tool in pairs(backpack:GetChildren()) do
		tool.Unequipped:connect(function()
			itemDown = function() end
			itemUp = function() end
			reloadKey = function() end
		end)
		do -- Weld
			for _, part in pairs(tool.Handle:GetChildren()) do
				if part:IsA("BasePart") then
					local weld = Instance.new("Weld")
					weld.Part0 = tool.Handle
					weld.Part1 = part
					weld.C0 = tool.Handle.CFrame:inverse() * CFrame.new(tool.Handle.Position)
					weld.C1 = part.CFrame:inverse() * CFrame.new(tool.Handle.Position)
					part.Anchored = false
					part.CanCollide = true
					weld.Parent = part
				end
			end
			tool.Handle.Anchored = false
			tool.Handle.CanCollide = true
		end
	end
	Mouse.Button1Down:connect(function()
		itemDown()
	end)
	Mouse.Button1Up:connect(function()
		itemUp()
	end)
	Mouse.KeyDown:connect(function(key)
		if not global.settingKey and key == Client.Settings.Keybinds.Reload.Value:lower() then
			reloadKey()
		end
	end)
end

Client.Internal.ClientLoaded.Value = true
