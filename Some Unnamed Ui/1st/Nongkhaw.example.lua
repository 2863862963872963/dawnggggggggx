local Env = loadstring(game:HttpGet("https://raw.githubusercontent.com/MerrySubs4t/96soul/refs/heads/main/Utilities/NongkhawKawaii-UI.luau", true))()

local Banner = {
	['Genral'] = 101849161408766,
	['Auto'] = 110162136250435,
	['Setting'] = 72210587662292,
	['Misc'] = 84034775913393,
	['Items'] = 98574803492996,
	['Shop'] = 74630923244478,
	['Teleport'] = 137847566773112,
	['Visual'] = 123257335719276,
	['Combat'] = 112935442242481,
	['Update'] = 86844430363710,
}

local Window = Env:Window({
	Title = "Nong Khaw",
	Desc = "- Project"
})

local Update = Window:Add({
	Title = "Update",
	Desc = "Update and Change Log",
	Banner = Banner.Update
})
local Settings = Window:Add({
	Title = "Settings",
	Desc = "Update and Change Log",
	Banner = Banner.Setting
})

local Section = Update:Section({
	Title = "Section General",
	Side = 'l'
})

local Section = Settings:Section({
	Title = "Setting",
	Side = 'l'
})

local Section1 = Settings:Section({
	Title = "Setting",
	Side = 'r'
})

Section:Button({
	Title = "Button",
	Callback = function()
		print("Click!")
	end
})

Section:Button({
	Title = "Button",
	Desc = "Description",
	Icon = 139073550150476,
	Callback = function()
		print("Click!")
	end
})

Section1:Discord("Kuy")

Section1:Line()


Section1:Toggle({
	Title = "Toggle",
	Desc = "Description",
	Value = false,
	Callback = function(v)
		print(v)
	end,
})

Section1:Toggle({
	Title = "Toggle",
	Desc = "Description",
	Icon = 94911502105059,
	Value = false,
	Callback = function(v)
		print(v)
	end,
})

Section1:Line()

Section1:Textbox({
	Value = "Textbox",
	PlaceHolder = "Place",
	ClearOnFocus = false,
	Callback = function(v)
		print(v)
	end
})

Section1:Line()

Section1:Slider({
	Title = "Slider",
	Min = 5,
	Max = 100,
	Value = 50,
	Rounding = 2,
	CallBack = function(v)
		print(v)
	end,
})

Section:Dropdown({
	Title = "Select",
	Multi = true,
	List = {"Hello", "AJ", "List1", "1", "2"},
	Value = {"Hello", "AJ", "List", "1", "2"},
	Callback = function(v)
		print(v)
	end,
})

Section:Keybind({
	Title = "Keybind",
	Key = Enum.KeyCode.E,
	Value = false,
	Callback = function(key, value)
		print(key, value)
	end
})

Section:ThumnailsImage({
	Banner = 138127867432976
})

Section:Paragarp({
	Title = "Paragarp",
	Desc = "DescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZDescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZ"
})
