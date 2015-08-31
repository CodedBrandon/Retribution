return {
	Screen = script.Parent:WaitForChild("PlayerGui").Screen,
	EquipItem = function(self, item)
		if script.Parent.Character then
			local equipItem = nil
			for _, tool in pairs(script.Parent.Backpack:GetChildren()) do
				if tool.Name == item then
					equipItem = tool
					break
				end
			end
			if equipItem then
				script.Parent.Character:FindFirstChild("Humanoid"):EquipTool(equipItem)
			end
		end
	end,
	UnequipItems = function(self)
		if script.Parent.Character then
			script.Interface.EquippedItem.Value = nil
			script.Parent.Character:FindFirstChild("Humanoid"):UnequipTools()
		end
	end,
	PushChat = function(self, chat, color, bold)
		local bold = bold or false
		for x = 1, 7 do
			self.Screen.SendChat.List["Chat"..x].Text = self.Screen.SendChat.List["Chat"..x+1].Text
			self.Screen.SendChat.List["Chat"..x].TextColor3 = self.Screen.SendChat.List["Chat"..x+1].TextColor3
			self.Screen.SendChat.List["Chat"..x].Font = self.Screen.SendChat.List["Chat"..x+1].Font
		end
		self.Screen.SendChat.List.Chat8.Text = chat
		self.Screen.SendChat.List.Chat8.TextColor3 = color
		if bold then
			self.Screen.SendChat.List.Chat8.Font = Enum.Font.ArialBold
		else
			self.Screen.SendChat.List.Chat8.Font = Enum.Font.Arial
		end
	end,
	Message = function(self, sendMsg, color)
		self.Screen:WaitForChild("Display"):WaitForChild("Message")
		if sendMsg then
			local color = color or Color3.new(1,1,1)
			self.Screen.Display.Message.Text = sendMsg
			self.Screen.Display.Message.TextColor3 = color
			self.Screen.Display.Message.TextShadow.Text = sendMsg
			return sendMsg
		else
			return self.Screen.Display.Message.Text
		end
	end,
	EmptyInventorySlot = function(self)
		for row = 1, 5 do
			for col = 1, 5 do
				local slot = script.Inventory["Row"..row]["Item"..col]
				if not slot:FindFirstChild("Item") then
					return true, slot
				end
			end
		end
		return false, nil
	end,
	FindItemInInventory = function(self, itemKey)
		
	end,
	PlayIntro = function(self, actuallyPlay)
		local intro, waitTime = self.Screen:WaitForChild("Intro"):WaitForChild("Screen"), 0.8
		if actuallyPlay then
			wait()
			intro.SpinEffect.Top:TweenSizeAndPosition(
				UDim2.new(0, 120, 2, 5),
				UDim2.new(0.5, -60, -1.5, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime
			)
			intro.SpinEffect.Bottom:TweenSizeAndPosition(
				UDim2.new(0, 120, 2, 5),
				UDim2.new(0.5, -60, 0.5, -5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime
			)
			wait(waitTime)
			for x = 0, 45 do
				intro.SpinEffect.Rotation = x * 4
				wait(0.001)
			end
			intro.SpinEffect.Top:TweenPosition(
				UDim2.new(0.85, -60, -1.5, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime
			)
			intro.SpinEffect.Bottom:TweenPosition(
				UDim2.new(0.15, -60, 0.5, -5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime
			)
			wait(waitTime)
			intro.SpinEffect.Top.ColorBlast:TweenSizeAndPosition(
				UDim2.new(20, 0, 3, 0),
				UDim2.new(-9, 0, -1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime, false, function()
					wait(waitTime)
					intro.SpinEffect.Top.ColorBlow:TweenSizeAndPosition(
						UDim2.new(20, 0, 3, 0),
						UDim2.new(-9, 0, -1, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						waitTime
					)
				end
			)
			wait(waitTime)
			intro.SpinEffect.Bottom.ColorBlast:TweenSizeAndPosition(
				UDim2.new(20, 0, 3, 0),
				UDim2.new(-9, 0, -1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				waitTime, false, function()
					intro.SpinEffect.Bottom.ColorBlow:TweenSizeAndPosition(
						UDim2.new(20, 0, 3, 0),
						UDim2.new(-9, 0, -1, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						waitTime, false, function()
							intro.SpinEffect.Visible = false
						end
					)
				end
			)
			wait(waitTime)
			intro.SlideEffect:TweenSize(
				UDim2.new(0, 700, 0, 700),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				1
			)
			
			wait(1)
			for x = 0, 20 do
				intro.Transparency = x / 10
				intro.Parent.Transparency = x / 10
				wait(0.05)
			end
		else
			intro.Parent.Visible = false
		end
	end
}
