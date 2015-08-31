return {
	Keys = {
		Q = "Q",
		E = "E",
		R = "R",
		T = "T",
		Y = "Y",
		U = "U",
		P = "P",
		F = "F",
		H = "H",
		J = "J",
		K = "K",
		L = "L",
		Z = "Z",
		X = "X",
		C = "C",
		V = "V",
		B = "B",
		N = "N",
		M = "M",
		["["] = "[",
		["]"] = "]",
		["\\"] = "\\",
		[";"] = ";",
		["'"] = "'",
		["/"] = "/",
		["0"] = "Shift",
		["2"] = "Ctrl",
		["4"] = "Alt"
	},
	NumberFormat = function(number)
		number = tostring(number):reverse()
		local returnNumber = ""
		for x = 1, #number do
			local index = number:sub(x, x)
			if x % 3 == 0 and x > 1 then
				returnNumber = returnNumber..index..","
			else
				returnNumber = returnNumber..index
			end
			print(x, index)
		end
		return returnNumber:reverse()
	end,
	Print = function(...)
		print("["..(math.floor(time()*1000)/1000).."] ", ...)
	end
}
