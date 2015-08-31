local ItemType = {
	Material = "Material",
	Melee = "Melee",
	Ranged = "Ranged",
	Consumable = "Consumable",
	Magical = "Magical",
	Tool = "Tool"
}

local Dimensions = {
	Surface = "Surface"
}

local function NewItem(item)
	if type(item) == "table" then
		item.Type = item.Type or ItemType.Material
		item.Value = item.Value or 1
		item.MaxAmount = item.MaxAmount or 30
		item.Rarity = item.Rarity or 1
		item.Equip = item.Equip or false
		item.Damage = item.Damage or 0
		item.UseTime = item.UseTime or 1
		item.Dimensions = item.Dimensions or {}
		item.Constructable = item.Constructable or false
		item.Recipe = item.Recipe or {}
		item.ConstructAmount = item.ConstructAmount or 1
		item.ForbiddenKnowledge = item.ForbiddenKnowledge or false
		item.HungerRefill = item.HungerRefill or 0
		item.MagickaDrain = item.MagickaDrain or 0
	end
	local metaData = {
		__call = function()
			return "Item"
		end
	}
	setmetatable(item, metaData)
	return item
end

return {
	Flashlight = NewItem {
		MaxAmount = 1,
		Type = ItemType.Tool,
		Equip = true,
		ItemImage = 277214303,
		Dimensions = {
			Dimensions.Surface
		},
		Constructable = true,
		Recipe = {
			Battery = 2
		},
		Value = 5
	},
	Battery = NewItem {
		Type = ItemType.Consumable,
		ItemImage = 277650338,
		Dimensions = {
			Dimensions.Surface
		},
		Value = 2
	},
	Grenade = NewItem {
		Type = ItemType.Consumable,
		ItemImage = 280131753,
		Equip = true,
		Dimensions = {
			Dimensions.Surface
		},
		MaxAmount = 8,
		Damage = 45,
		Value = 15,
		UseTime = 2,
		Rarity = 5,
		Constructable = true,
		Recipe = {
			Battery = 1,
			Flashlight = 1
		},
		ConstructAmount = 2
	},
	Knife = NewItem {
		Type = ItemType.Melee,
		ItemImage = 280519406,
		Value = 5,
		MaxAmount = 1,
		Equip = true,
		Damage = 12,
		UseTime = 0.3,
		Dimension = {
			Dimensions.Surface
		}
	},
	Medkit = NewItem {
		Type = ItemType.Consumable,
		ItemImage = 280532892,
		Value = 20,
		MaxAmount = 5,
		Equip = true,
		UseTime = 10,
		Dimension = {
			Dimensions.Surface
		}
	},
	WatermelonSlice = NewItem {
		Type = ItemType.Consumable,
		ItemImage = 289107213,
		Value = 2,
		MaxAmount = 30,
		Equip = true,
		HungerRefill = 8,
		Dimension = {
			Dimensions.Surface
		}
	},
	Carrot = NewItem {
		Type = ItemType.Consumable,
		ItemImage = 289107221,
		Value = 1,
		MaxAmount = 30,
		Equip = true,
		HungerRefill = 5,
		Dimension = {
			Dimensions.Surface
		}
	},
	RetributionBook = NewItem {
		Type = ItemType.Tool,
		ItemImage = 290130849,
		Value = 0,
		MaxAmount = 1,
		Equip = true,
		Dimension = {}
	}
}
