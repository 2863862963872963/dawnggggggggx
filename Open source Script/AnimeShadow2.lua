-- made by Stellar Hub | discord.gg/FmMuvkaWvG

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "StellarLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 1
bg.ZIndex = 0
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

local word = "STELLAR"
local letters = {}

local function tweenOutAndDestroy()
	for _, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
	end
	TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
	wait(0.6)
	screenGui:Destroy()
	blur:Destroy()
end

for i = 1, #word do
	local char = word:sub(i, i)

	local label = Instance.new("TextLabel")
	label.Text = char
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 1 
	label.TextTransparency = 1
	label.TextScaled = false
	label.TextSize = 30 
	label.Size = UDim2.new(0, 60, 0, 60)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)), -- biru muda cerah
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))   -- biru muda gelap
	})
	gradient.Rotation = 90
	gradient.Parent = label

	local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
	tweenIn:Play()

	table.insert(letters, label)
	wait(0.25)
end

wait(2)

tweenOutAndDestroy()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()


local Window = Fluent:CreateWindow({
    Title = game:GetService("MarketplaceService"):GetProductInfo(136755111277466).Name .. " 〢 Stellar",
    SubTitle = "discord.gg/FmMuvkaWvG",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "StellarHubMini"
gui.ResetOnSpawn = false

local icon = Instance.new("ImageButton")
icon.Name = "StellarIcon"
icon.Size = UDim2.new(0, 55, 0, 50)
icon.Position = UDim2.new(0, 200, 0, 150)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://105059922903197" 
icon.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8) 
corner.Parent = icon

local dragging, dragInput, dragStart, startPos

icon.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = icon.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

icon.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		icon.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

local isMinimized = false
icon.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	Window:Minimize(isMinimized)
end)
local Tabs = {
    DevUpd = Window:AddTab({ Title = "Information", Icon = "info"}),
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Raid = Window:AddTab({ Title = "Trial & Tower", Icon = "swords" }),
    Trait = Window:AddTab({ Title = "Trait", Icon = "refresh-ccw" }),   
    Hatch = Window:AddTab({ Title = "Star", Icon = "star" }),
    Collect = Window:AddTab({ Title = "Rewards", Icon = "archive" }),
    AntiAfk = Window:AddTab({ Title = "Anti-Afk", Icon = "clock" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Tabs.DevUpd:AddParagraph({
        Title = "Stellar Hub",
        Content = "Thank you for using the script! Join the discord if you have problems and suggestions with the script"
    })
        Tabs.DevUpd:AddParagraph({
        Title = "Information",
        Content = "If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!"
    })

    Tabs.DevUpd:AddSection("Discord")
    Tabs.DevUpd:AddButton({
        Title = "Discord",
        Description = "Copy the link to join the discord!",
        Callback = function()
            setclipboard("https://discord.gg/FmMuvkaWvG")
            Fluent:Notify({
                Title = "Notification",
                Content = "Successfully copied to the clipboard!",
                SubContent = "", -- Optional
                Duration = 3 
            })
        end
    })

    local selected_world = "Shadow City"
    local shadowcitymobs = {"AxeGuardian", "KingGuardian", "MaceGuardian", "SingerGuardian", "SwordGuardian"}
    local slayerislandmobs = {"Akazha", "Dake", "Dhoma", "Enmo", "Gyutaru", "Hantego", "Kokoshibo", "Ruih", "Susamaro"}
    local dragonworldmobs = {"Androidi", "Boo", "Broli", "Couler", "Frieza", "GokoBlack", "Gran", "Jeren", "Zamaso", "Zell"}
    local marinemobs = {"Buggi", "Crocodele", "Figarlend", "Kaku", "Riokugiu", "Shiriu"}
    local bleachmobs = {"Coyoti", "Grimmjew", "Haribol", "HollowIchigu", "Yhwache"}
    local world_to_mobs = {
        ["Shadow City"] = shadowcitymobs,
        ["Slayer Island"] = slayerislandmobs,
        ["Dragon World"] = dragonworldmobs,
        ["Marine Island"] = marinemobs,
        ["Bleach Island"] = bleachmobs,
    }

    
    local selectworld = Tabs.Main:AddDropdown("selectworld", {
        Title = "Select World",
        Values = {"Shadow City", "Slayer Island", "Dragon World", "Marine Island","Bleach Island"},
        Multi = false,
        Default = "Shadow City",
    })

    
    local selectenemies = Tabs.Main:AddDropdown("selectenemies", {
        Title = "Select Enemies",
        Values = shadowcitymobs, 
        Multi = true,
        Default = {}, 
    })

 
    selectworld:OnChanged(function(Value)
        selected_world = Value
        local newValues = world_to_mobs[selected_world]
        if newValues then
            selectenemies:SetValues(newValues) 
            selectenemies:SetValue({}) 
        end
    end)

  
    selectenemies:OnChanged(function(Value)
        local selectedEnemies = {}
        for mobName, isSelected in pairs(Value) do
            if isSelected then
                table.insert(selectedEnemies, mobName)
            end
        end
    end)

    local selecteddifficulty = { "Easy" }

    local selectdifficulty = Tabs.Main:AddDropdown("selectdifficulty", {
        Title = "Select Difficulties",
        Values = {"Easy", "Medium", "Hard", "Impossible", "Boss", "Raid Boss"},
        Multi = true,
        Default = { Easy = true },
    })

    selectdifficulty:OnChanged(function(Value)
        local Values = {}
        for difficulty, isSelected in next, Value do
            if isSelected then
                table.insert(Values, difficulty)
            end
        end
    end)

    local goto_closest = false
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local user_input_service = cloneref(game:GetService('UserInputService'))
    local local_player = cloneref(game:GetService('Players').LocalPlayer)
    local tween_service = cloneref(game:GetService('TweenService'))
    local run_service = cloneref(game:GetService('RunService'))
    local workspace = cloneref(game:GetService('Workspace'))

    function closest_mob()
        local mob = nil
        local distance = math.huge
        local selectedEnemies = selectenemies.Value or {}
        local selectedDifficulties = selectdifficulty.Value or {}
        local enemiesFolder = workspace.Server.Enemies:FindFirstChild(selected_world)
        if not enemiesFolder then return nil end
        for _, v in ipairs(enemiesFolder:GetChildren()) do
            local mobName = v.Name
            local mobDifficult = v:GetAttribute("Difficult")
            local mobHealth = v:GetAttribute("Health")

            if mobHealth and mobHealth > 0 and selectedEnemies[mobName] and selectedDifficulties[mobDifficult] then
                local dist = (v.Position - local_player.Character:GetPivot().Position).Magnitude
                if dist < distance then
                    distance = dist
                    mob = v
                end
            end
        end

        return mob
    end

    local Toggle3 = Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Default = false
    })
    Toggle3:OnChanged(function(Value)
        goto_closest = Value
        if Value then
            task.spawn(function()
                while goto_closest do
                    local mob = closest_mob()
                    if mob and local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = local_player.Character.HumanoidRootPart
                        local targetPos = mob.Position + Vector3.new(0, y or 0, 6)
                        if (hrp.Position - targetPos).Magnitude > 13 then
                            hrp.CFrame = CFrame.new(targetPos, mob.Position)
                        end
                    end
                end
            end)
        end
    end)
    local autoattack = Tabs.Main:AddToggle("autoattack", {Title = "Auto Fast Click", Description = "You can also use this in trial", Default = false })
    autoattack:OnChanged(function()
        while Options.autoattack.Value do
            local args = {
                "Shadows",
                "Attack",
                "Click"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
        end
    end)
    Options.autoattack:SetValue(false)
    local autoattackunit = Tabs.Main:AddToggle("autoattackunit", {Title = "Auto Attack Units", Default = false })
    local auto_attack = false
    autoattackunit:OnChanged(function(Value)
        auto_attack = Value
        if Value then
            task.spawn(function()
                while auto_attack do
                    local mob = closest_mob()
                    if mob then
                        local args = {
                            "Shadows",
                            "Attack",
                            "Attack_All",
                            "World",
                            mob  -- dynamically target current mob
                        }
                        replicated_storage:WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                    end
                    task.wait(0.3) -- control attack rate here ckksz
                end
            end)
        end
    end)

    local timer = workspace.Server.Trial.Lobby.Timer.BillboardGui.TextLabel.Text
    local TimerParagraph = Tabs.Raid:AddParagraph({
        Title = "Trial Countdown",
        Content = "..."
    })

    task.spawn(function()
        while true do
            local success, timerText = pcall(function()
                return workspace.Server.Trial.Lobby.Timer.BillboardGui.TextLabel.Text
            end)

            if success and timerText then
                TimerParagraph:SetDesc(timerText)
            end
        end
    end)

    local vim = game:GetService("VirtualInputManager")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local goto_closest_raid = false
    local replicated_storage = cloneref(game:GetService('ReplicatedStorage'))
    local local_player = cloneref(game:GetService('Players').LocalPlayer)
    local workspace = cloneref(game:GetService('Workspace'))

    function closest_raid_mob()
        local closestMob = nil
        local shortestDistance = math.huge
        local enemiesFolder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Trial") and workspace.Server.Trial:FindFirstChild("Enemies")
        if not enemiesFolder then return nil end

        for _, mob in ipairs(enemiesFolder:GetChildren()) do
            local mobHealth = mob:GetAttribute("Health")
            if mobHealth and mobHealth > 0 then
                local distance = (mob.Position - local_player.Character:GetPivot().Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end

        return closestMob
    end

    local ToggleRaidFarm = Tabs.Raid:AddToggle("AutoRaidFarm", {
        Title = "Auto Trial",
        Default = false
    })

    ToggleRaidFarm:OnChanged(function(Value)
        goto_closest_raid = Value
        if Value then
            task.spawn(function()
                while goto_closest_raid do
                    local character = player.Character or player.CharacterAdded:Wait()
                    local timerText = workspace.Server.Trial.Lobby.Timer.BillboardGui.TextLabel.Text

                    if character and timerText == "STARTS AT: 00:05" then
                        local args = {
                            "Gamemodes",
                            "Trial",
                            "Join"
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                    end
                    local mob = closest_raid_mob()
                    if mob and local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = local_player.Character.HumanoidRootPart
                        local targetPos = mob.Position + Vector3.new(0, 0, 6)
                        if (hrp.Position - targetPos).Magnitude > 13 then
                            hrp.CFrame = CFrame.new(targetPos, mob.Position)
                        end
                    end
                end
            end)
        end
    end)

    local auto_attack_raid = false

    local ToggleRaidAttack = Tabs.Raid:AddToggle("AutoRaidAttackUnits", {
        Title = "Auto Attack Units",
        Default = false
    })

    ToggleRaidAttack:OnChanged(function(Value)
        auto_attack_raid = Value
        if Value then
            task.spawn(function()
                while auto_attack_raid do
                    local mob = closest_raid_mob()
                    if mob then
                        local args = {
                            "Shadows",
                            "Attack",
                            "Attack_All",
                            "Trial",
                            mob
                        }
                        replicated_storage:WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                    end
                end
            end)
        end
    end)

    local wavetoleave
    local inputwave = Tabs.Raid:AddInput("inputwave", {
        Title = "Wave To Leave",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            wavetoleave = Value
        end
    })

    local savedposition 

    local autoleavewave = Tabs.Raid:AddToggle("autoleavewave", {
        Title = "Leave Wave to Save Position",
        Default = false
    })

    autoleavewave:OnChanged(function()
        while Options.autoleavewave.Value do
            if game:GetService("Players").LocalPlayer.PlayerGui.UI.HUD.Trial.Frame.Wave.Value.Text == wavetoleave then
                local enemies = workspace.Server.Trial.Enemies:GetChildren()
                if #enemies > 0 then
                    local args = {
                        "Gamemodes",
                        "Trial",
                        "Leave"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                end

                if savedposition then
                    task.wait(1)
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = savedposition
                    end
                end
            end
        end
    end)

    Options.autoleavewave:SetValue(false)
    Tabs.Raid:AddButton({
        Title = "Save Current Position",
        Callback = function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                savedposition = char.HumanoidRootPart.CFrame
                Fluent:Notify({
                    Title = "Stellar Hub",
                    Content = "Successfully Saved Position",
                    Duration = 3
                })
            end
        end
    })
    Tabs.Raid:AddButton({
        Title = "Teleport to Saved Position",
        Callback = function()
            local char = game.Players.LocalPlayer.Character
            if savedposition and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = savedposition
                Fluent:Notify({
                    Title = "Stellar Hub",
                    Content = "Teleported to Saved Position",
                    Duration = 3
                })
            end
        end
    })

Tabs.Raid:AddSection("Tower")
Tabs.Raid:AddParagraph({
    Title = "WIP Features",
    Content = "Automatically enters Tower, leaves at a specified wave, teleports, and restarts."
})

local waveToLeave = nil
local targetCFrame = CFrame.new(2283, 14, -2274)
local autoTowerRunning = false
Tabs.Raid:AddInput("TowerLeaveWave", {
    Title = "Wave To Leave",
    Description = "Example: 5",
    Numeric = false,
    Default = "",
    Callback = function(Value)
        waveToLeave = tostring(Value)
        print("Wave to leave set to:", waveToLeave)
    end
})
Tabs.Raid:AddToggle("AutoTowerStart", {
    Title = "Auto Start Tower Mode",
    Default = false
}):OnChanged(function(Value)
    autoTowerRunning = Value

    if Value then
        if not tonumber(waveToLeave) then
            library:Notify("Please enter a valid wave number before enabling Auto Start.")
            Options.AutoTowerStart:SetValue(false)
            return
        end

        startTowerLoop()
    end
end)
function startTowerLoop()
    task.spawn(function()
        while autoTowerRunning do
            -- Step 1: Create Tower lobby
            print("Creating Tower lobby for wave:", waveToLeave)
            game:GetService("ReplicatedStorage")
                :WaitForChild("Remotes")
                :WaitForChild("Bridge")
                :FireServer("Gamemodes", "Tower", "Create")

            -- Step 2: Monitor wave progression
            local waveReached = false

            while autoTowerRunning and not waveReached do
                local success, currentWave = pcall(function()
                    return game.Players.LocalPlayer
                        .PlayerGui
                        .UI
                        .HUD
                        .Tower
                        .Frame
                        .Wave
                        .Value.Text
                end)
                if success and tostring(currentWave) == tostring(waveToLeave) then
                    local enemies = workspace:WaitForChild("Server")
                        :WaitForChild("Tower")
                        :WaitForChild("Enemies")
                        :GetChildren()
                    if #enemies == 0 then
                        waveReached = true
                        print("Target wave reached and no enemies remain. Leaving Tower mode...")
                        -- Step 3: Leave Tower mode
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Remotes")
                            :WaitForChild("Bridge")
                            :FireServer("Gamemodes", "Tower", "Leave")
                        task.wait(3)
                        -- Step 4: Teleport to lobby position
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = targetCFrame
                            print("Teleported to lobby position.")
                        end
                        task.wait(2)
                    end
                end
            end
        end
    end)
end

 --Tower Raids --


-- Tabs Hatch


    local autohatchsingle = Tabs.Hatch:AddToggle("autohatchsingle", {
        Title = "Auto Hatch Single",
        Default = false
    })

    autohatchsingle:OnChanged(function()
        while Options.autohatchsingle.Value do
            vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)  -- Press E
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game) -- Release E
            task.wait(0.1) 

        end
    end)

    Options.autohatchsingle:SetValue(false)

    local autohatchmulti = Tabs.Hatch:AddToggle("autohatchmulti", {
        Title = "Auto Hatch Multi",
        Default = false
    })

    autohatchmulti:OnChanged(function()
        while Options.autohatchmulti.Value do
            vim:SendKeyEvent(true, Enum.KeyCode.Q, false, game)  
            task.wait(0.05)
            vim:SendKeyEvent(false, Enum.KeyCode.Q, false, game) 
            task.wait(0.1) 
        end
    end)

    Options.autohatchmulti:SetValue(false)

    local removehatchanimation = Tabs.Hatch:AddToggle("removehatchanimation", {Title = "Remove Hatch Animation", Default = false })

    removehatchanimation:OnChanged(function()
        while Options.removehatchanimation.Value do
            game:GetService("Players").LocalPlayer.PlayerGui.Star_View.Enabled = false
        end
    end)
    
    Options.removehatchanimation:SetValue(false)


    local Toggle4 = Tabs.AntiAfk:AddToggle("AntiAfk", {
        Title = "Anti-Afk", 
        Description = "This will prevent you from being kicked when AFK", 
        Default = false 
    })
    
    Toggle4:OnChanged(function()
        task.spawn(function()
            while Options.AntiAfk.Value do
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                task.wait(10)
            end
        end)
    end)
    Options.AntiAfk:SetValue(false)

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local ui = playerGui:WaitForChild("UI")
    local traitFrame = ui.Frames.Traits
    local uid = tostring(player.UserId)

    local shadowMap = {}
    local traitas = {}
    local selectedTraits = {}

    local ShadowDrop = Tabs.Trait:AddDropdown("Dropdown_Shadow", {
        Title = "Select Pet",
        Values = {""},
        Multi = false,
        Default = 1,
    })

    local TraitDrop = Tabs.Trait:AddDropdown("Dropdown_Trait", {
        Title = "Select Traits",
        Values = {""},
        Multi = true,
        Default = {},
        Callback = function(value)
            selectedTraits = {}

            for trait, isSelected in pairs(value) do
                if isSelected then
                    table.insert(selectedTraits, trait)
                end
            end

            local selectedPetDisplay = ShadowDrop.Value
            local internalName = shadowMap[selectedPetDisplay]
            local petFolder = workspace.Server.Shadows:FindFirstChild(uid)

            local found = false
            for _, trait in ipairs(selectedTraits) do
                if trait == currentTrait then
                    found = true
                    break
                end
            end

            if found then
                Fluent:Notify({
            Title = "Stellar Hub",
            Content = "You have taken the selected trait",
            SubContent = "You have taken the selected trait",
            Duration = 2
        })
            else

            end
        end
    })

    local Toggle = Tabs.Trait:AddToggle("Toggle_Spin", {
        Title = "Auto Spin",
        Default = false,
    })

    local function getCurrentTraitFromPet(petInternalName)
        local petFolder = workspace.Server.Shadows:FindFirstChild(uid)
        if not petFolder then return nil end

        local sombra = petFolder:FindFirstChild(petInternalName)
        if not sombra then return nil end

        return sombra:GetAttribute("Trait")
    end


    local function refreshShadows()
        shadowMap = {}
        local shadowFolders = workspace.Server.Shadows:GetChildren()
        local dropdownValues = {}

        for _, folder in pairs(shadowFolders) do
            if folder:IsA("Folder") and folder.Name == uid then
                for _, sombra in pairs(folder:GetChildren()) do
                    local nameAttr = sombra.Value
                    local level = sombra:GetAttribute("Level")
                    if nameAttr and level then
                        local displayName = string.format("%s (Level: %s)", nameAttr, level)
                        shadowMap[displayName] = sombra.Name
                        table.insert(dropdownValues, displayName)
                    end
                end
            end
        end

        ShadowDrop:SetValues(dropdownValues)
        ShadowDrop:SetValue(dropdownValues[1] or "")
    end

    local function refreshTraits()
        traitas = {}
        local lista = traitFrame.Index.Frame.List:GetChildren()

        for _, traits in pairs(lista) do
            if traits:IsA("Frame") then
                table.insert(traitas, traits.Name)
            end
        end

        TraitDrop:SetValues(traitas)
        TraitDrop:SetValue({})
    end

    Toggle:OnChanged(function(state)
        _G.autospinm = state

        if _G.autospinm then
            task.spawn(function()
                while _G.autospinm do
                    local selectedPetDisplay = ShadowDrop.Value
                    local selectedTraitMap = TraitDrop.Value
                    local internalName = shadowMap[selectedPetDisplay]
                    local currentTrait = internalName and getCurrentTraitFromPet(internalName) or nil

                    local traitList = {}
                    for trait, isSelected in pairs(selectedTraitMap) do
                        if isSelected then
                            table.insert(traitList, trait)
                        end
                    end

                    local traitEquipped = false
                    for _, trait in ipairs(traitList) do
                        if trait == currentTrait then
                            traitEquipped = true
                            break
                        end
                    end

                    if internalName and not traitEquipped then
                        local args = {
                            "General",
                            "Traits",
                            "Reroll",
                            internalName
                        }

                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
                        local lastTrait = currentTrait
                        local timeout = 3
                        local elapsed = 0
                        repeat
                            task.wait(1)
                            currentTrait = getCurrentTraitFromPet(internalName)
                            elapsed += 1
                        until currentTrait ~= lastTrait or elapsed >= timeout
                    elseif traitEquipped then
                        _G.autospinm = false
                        break
                    else
                        task.wait(1.5)
                    end
                end
            end)
        end
    end)

    Tabs.Trait:AddButton({
        Title = "Refresh Shadows",
        Callback = refreshShadows
    })

    refreshShadows()
    refreshTraits()

    local dailycollectdelay = 5
    local autocollectdailyrewards = Tabs.Collect:AddToggle("autocollectdailyrewards", {Title = "Auto Collect Daily Rewards", Default = false })

   autocollectdailyrewards:OnChanged(function()
        while Options.autocollectdailyrewards.Value do
            for i = 1, 7 do
                local args = {
                    "General",
                    "DailyRewards",
                    "Claim",
                    i
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
            end
            task.wait(dailycollectdelay)
        end
    end)
    
    Options.autocollectdailyrewards:SetValue(false)

    local dailydelayinput = Tabs.Collect:AddInput("dailydelayinput", {
        Title = "Delay (seconds)",
        Default = "5",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            dailycollectdelay = Value
        end
    })

    local collectdelay = 5
    local autocollectafkrewards = Tabs.Collect:AddToggle("autocollectafkrewards", {Title = "Auto Collect Afk Rewards", Default = false })

    autocollectafkrewards:OnChanged(function()
        while Options.autocollectafkrewards.Value do
            local args = {
                "General",
                "Afk Rewards",
                "Collect"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bridge"):FireServer(unpack(args))
            task.wait(collectdelay)
        end
    end)
    
    Options.autocollectafkrewards:SetValue(false)

    local delayinput = Tabs.Collect:AddInput("delayinput", {
        Title = "Delay (seconds)",
        Default = "5",
        Numeric = true, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            collectdelay = Value
        end
    })

end  

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)

SaveManager:IgnoreThemeSettings()
-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/Build an Island")



InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "Stellar Hub",
    Content = "The script has been loaded.",
    Duration = 3
})
task.wait(3)
Fluent:Notify({
    Title = "Stellar Hub",
    Content = "Join the discord for more updates",
    Duration = 8
})
-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
