local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/BoostCC/STARHUBLIB/refs/heads/main/libarysrc.lua"))()

local Window = library:CreateWindow({
    library_config = {
        Cheat_Name = "STARHUB",
        Cheat_Icon = "rbxassetid://132964100967987",
        interface_keybind = "Insert"
    }
})

local Aim = Window:CreateTab({icon = "rbxassetid://133833791023200", TabText = "Aim"})
local Misc = Window:CreateTab({icon = "rbxassetid://133833791023200", TabText = "Misc"})
local Save = Window:CreateTab({icon = "rbxassetid://133833791023200", TabText = "Save"})
local AimLeftSection = Aim:CreateSection({position = "left", SectionText = "Aim Settings"})
local AimRightSection = Aim:CreateSection({position = "right", SectionText = "Aim Options"})
local ConfigSection = Save:CreateConfigSection({
})


local Toggle1 = AimLeftSection:CreateToggle({ToggleText = "Enable Aim", Callback = function(Value)
    print("Aim Toggle:", Value)
end})

local Toggle2 = AimRightSection:CreateToggle({ToggleText = "Enable Aim", Callback = function(Value)
    print("Aim Toggle:", Value)
end})

local Slider1 = AimLeftSection:CreateSlider({SliderText = "FOV", Min = 0, Max = 500, Value = 100, Callback = function(Value)
    print("FOV:", Value)
end})

local Slider2 = AimRightSection:CreateSlider({SliderText = "FOV", Min = 0, Max = 500, Value = 100, Callback = function(Value)
    print("FOV:", Value)
end})

local TextInput1 = AimRightSection:CreateTextInput({TextInputText = "Target Player", Callback = function(Text)
    print("Target:", Text)
end})

local Dropdown1 = AimLeftSection:CreateDropdown({DropdownText = "Aim Type", Options = {"Mouse", "Keyboard", "Controller"}, Callback = function(Option)
    print("Aim Type:", Option)
end})

-- Multi-select dropdown example
local MultiDropdown1 = AimRightSection:CreateDropdown({
    DropdownText = "Weapon Types", 
    Options = {"Rifle", "Pistol", "Shotgun", "Sniper", "SMG"}, 
    MultiSelect = true,
    Default = {"Rifle", "Pistol"},
    Callback = function(SelectedOptions)
        print("Selected Weapons:", table.concat(SelectedOptions, ", "))
    end
})

local Keybind1 = AimRightSection:CreateKeybind({KeybindText = "Aim Key", Callback = function(Key)
    print("Aim Key:", Key)
end})

local AccentPicker = AimRightSection:CreateColorpicker({
    ColorpickerText = "Accent Color",
    defaultColor = Color3.fromRGB(155, 77, 255),
    Callback = function(color)
  
        if library.SetAccentColor then
            library:SetAccentColor(color)
        end
        print("Accent updated", color)
    end
})


local SuccessButton = AimLeftSection:CreateToggle({
    ToggleText = "Show Success Notification", 
    Callback = function(Value)
        if Value then
            library:NotifySuccess("Configuration saved successfully!", 3, function(notification)
                print("Success notification clicked!")
            end, function(notification)
                print("Success notification closed!")
            end)
        end
    end
})


local WarningButton = AimLeftSection:CreateToggle({
    ToggleText = "Show Warning Notification", 
    Callback = function(Value)
        if Value then
            library:NotifyWarning("This action cannot be undone!", 4, function(notification)
                print("Warning notification clicked!")
            end, function(notification)
                print("Warning notification closed!")
            end)
        end
    end
})


local ErrorButton = AimRightSection:CreateToggle({
    ToggleText = "Show Error Notification", 
    Callback = function(Value)
        if Value then
            library:NotifyError("Failed to connect to server!", 5, function(notification)
                print("Error notification clicked!")
            end, function(notification)
                print("Error notification closed!")
            end)
        end
    end
})


local CustomButton = AimRightSection:CreateToggle({
    ToggleText = "Show Custom Color Notification", 
    Callback = function(Value)
        if Value then
            library:NotifyCustom("Custom purple notification!", Color3.fromRGB(155, 77, 255), 4, function(notification)
                print("Custom notification clicked!")
            end, function(notification)
                print("Custom notification closed!")
            end)
        end
    end
})


local AdvancedButton = AimLeftSection:CreateToggle({
    ToggleText = "Show Advanced Notification", 
    Callback = function(Value)
        if Value then
            library:CreateNotification({
                Text = "Advanced notification with custom settings",
                Type = "custom",
                Color = Color3.fromRGB(255, 165, 0), 
                Duration = 6,
                Callback = function(notification)
                    print("Advanced notification clicked!")
                  
                    print("Notification text:", notification.text)
                    print("Notification type:", notification.type)
                end,
                OnClose = function(notification)
                    print("Advanced notification closed!")
                end
            })
        end
    end
})


local CloseAllButton = AimRightSection:CreateToggle({
    ToggleText = "Close All Notifications", 
    Callback = function(Value)
        if Value then
            library:CloseAllNotifications()
        end
    end
})


local WatermarkToggle = AimLeftSection:CreateToggle({
    ToggleText = "Enable Watermark",
    Default = true,
    Callback = function(Value)
        print("Watermark:", Value)
        library:ToggleWatermark(Value)
    end
})

-- Example Config Section

