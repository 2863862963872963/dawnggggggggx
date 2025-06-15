islclosure, getgc, hookfunction, getrenv = islclosure, getgc, hookfunction, getrenv
getgenv, identifyexecutor, setclipboard, makefolder, isfolder = getgenv, identifyexecutor, setclipboard, makefolder, isfolder
writefile, isfile, readfile, delfile, sethiddenproperty, getnilinstances = writefile, isfile, readfile, delfile, sethiddenproperty, getnilinstances
cloneref, getconnections, getsenv,fireclickdetector,fireproximityprompt,firetouchinterest = cloneref, getconnections, getsenv,fireclickdetector,fireproximityprompt,firetouchinterest
----------------------------------------------------
local Configs: SharedTable = {} or {...};
local __Class: SharedTable = {} or {...};
local Funcs: SharedTable = {} or {...};
local Players: Players = game:GetService("Players");
local VirtualInputManager: VirtualInputManager = game:GetService("VirtualInputManager");
local CollectionService: CollectionService = game:GetService("CollectionService");
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage");
local TeleportService: TeleportService = game:GetService("TeleportService");
local RunService: RunService = game:GetService("RunService");
local VirtualUser: VirtualUser = game:GetService("VirtualUser");
local HttpService: HttpService = game:GetService("HttpService");
local TweenService: TweenService = game:GetService("TweenService");
local CoreGui: any? = game:GetService("CoreGui");
local PlaceId: number = game.PlaceId;
local JobId: number? | string? | any? = game.JobId;
local Camera: Instance = workspace.CurrentCamera;
local Tick: TimerService | number = tick();
local LocalPlayer: Client | any? = Players.LocalPlayer;
local Backpack: Backpack = LocalPlayer.Backpack;
local PlayerGui: PlayerGui = LocalPlayer.PlayerGui;
local PlayerScript: PlayerScripts =  LocalPlayer.PlayerScripts;
local Name: string = LocalPlayer.Name;
local DisplayName: string = LocalPlayer.DisplayName;
local PlayerId: number = LocalPlayer.UserId;
local Team: string = tostring(LocalPlayer.Team);
local Folder: string = "Fetching'Script/Config/" .. PlayerId .. "/" .. PlaceId .. ".json";
local Character: Instance = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
local HumanoidRootPart: Instance | Part = Character:WaitForChild("HumanoidRootPart");
local Humanoid: Instance | Humanoid = Character:WaitForChild("Humanoid");
local RenderStepped: any? = RunService.RenderStepped;
local Heartbeat: any? = RunService.Heartbeat;
local Stepped: any? = RunService.Stepped;
local Executor: string = string.upper(identifyexecutor());
local Blacklist_Executor: boolean = table.find({"SOLARA", "XENO"}, Executor);

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter;
	Humanoid = Character:WaitForChild('Humanoid');
	HumanoidRootPart = Character:WaitForChild('HumanoidRootPart');
	Backpack = LocalPlayer:WaitForChild("Backpack");
end);

task.spawn(function()
	pcall(function()
		if getconnections then
			for _,v in pairs(getconnections(LocalPlayer.Idled)) do
				if v["Disable"] then
					v["Disable"](v);
				elseif v["Disconnect"] then
					v["Disconnect"](v);
				end;
			end;
		else
			LocalPlayer.Idled:Connect(function()
				VirtualUser:CaptureController();
				VirtualUser:ClickButton2(Vector2.new());
			end);
		end;
	end);
end);

function __Class:Render()
	return Heartbeat:Wait();
end;

function __Class:tp(pos: any, v: func)
	if not HumanoidRootPart then return end
	pcall(function()
		if typeof(pos) == "CFrame" then
			HumanoidRootPart.CFrame = v and (pos * CFrame.Angles(math.rad(-90), 0, 0)) or pos
		elseif typeof(pos) == "Vector3" then
			HumanoidRootPart.CFrame = v and (CFrame.new(pos) * CFrame.Angles(math.rad(-90), 0, 0)) or CFrame.new(pos)
		elseif typeof(pos) == "Instance" and pos:IsA("Model") then
			HumanoidRootPart.CFrame = v and (pos:GetPivot() * CFrame.Angles(math.rad(-90), 0, 0)) or pos:GetPivot()
		elseif typeof(pos) == "Instance" and pos:IsA("BasePart") then
			HumanoidRootPart.CFrame = v and (pos.CFrame * CFrame.Angles(math.rad(-90), 0, 0)) or pos.CFrame
		end
	end)
end

function __Class:tween(Position)
	if not HumanoidRootPart then return end
	local Distance = (Position.Position - HumanoidRootPart.Position).Magnitude
	if Distance > 0 and Distance < 300 then
		return TweenService:Create(HumanoidRootPart,TweenInfo.new(0.08, Enum.EasingStyle.Linear),{CFrame = Position}):Play()
	else
		return TweenService:Create(HumanoidRootPart,TweenInfo.new(Distance / 300, Enum.EasingStyle.Linear),{CFrame = Position}):Play()
	end
end


function __Class:rotate(v: Vector3)
	if HumanoidRootPart then
		pcall(function()
			HumanoidRootPart.Rotation = v;
		end);
	end;
end

function __Class:Equip(Tool: Tool)
	if Character then
		if Backpack:FindFirstChild(Tool) and not Character:FindFirstChild(Tool) then
			Humanoid:EquipTool(Backpack:FindFirstChild(Tool));
		else
			return;
		end;
	end;
end;

translate = function(en: string, th: string)
	if _G.Thai or getgenv().Thai or _G.Thailand then
		return tostring(th);
	else
		return tostring(en);
	end;
end;

function __Class:IsAlive(v: Model | Instance | any)
	return typeof(v) == "Instance"and v:IsA("Model")and v:FindFirstChild("Humanoid") and v:FindFirstChild("Humanoid").Health > 0;
end;

function __Class:CloseFunction(a: func)
	if Blacklist_Executor then return end
	return hookfunction(a, function() return end)
end

function __Class:Distance(v: any)
	if HumanoidRootPart then
		if typeof(v) == "Instance" and v:IsA("Model") then
			return (v:GetPivot().Position - HumanoidRootPart.Position).Magnitude;
		elseif typeof(v) == "Instance" and v:IsA("BasePart") then
			return (v.Position - HumanoidRootPart.Position).Magnitude;
		elseif typeof(v) == "CFrame" then
			return (v.Position - HumanoidRootPart.Position).Magnitude;
		elseif typeof(v) == "Vector3" then
			return (v - HumanoidRootPart.Position).Magnitude;
		else
			return warn("Not Valid Argument");
		end;
	end;
	return nil;
end;

function __Class:Check(config, _table)
	for _,v in pairs(_table) do
		if config[v] == true then
			return true ;
		end ;
	end ;
	return false;
end;

function __Class:GetCloset(v: Folder | any?)
	local closest, dist, hp = nil, math.huge, math.huge;
	for _, mob in ipairs(v:GetChildren()) do
		if mob:IsA("Model") and __Class:IsAlive(mob) then
			local d = __Class:Distance(mob);
			local h = mob:FindFirstChild("Humanoid").Health;
			if d < dist or (d == dist and h < hp) then
				dist, hp, closest = d, h, mob;
			end;
		end;
	end;
	return closest;
end;

function __Class:GetClosetPlayers()
	local closest, dist, hp = nil, math.huge, math.huge;
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and __Class:IsAlive(player.Character) then
			local d = __Class:Distance(player.Character);
			local h = player.Character:FindFirstChild("Humanoid").Health;
			if d < dist or (d == dist and h < hp) then
				dist, hp, closest = d, h, player;
			end;
		end;
	end;
	return closest;
end;

function __Class:Save(key: string, value: boolean | string | number | table | any)
	if key ~= nil then Configs[key] = value;end;
	if not isfolder("Fetching'Script") then makefolder("Fetching'Script");end;
	writefile(Folder, HttpService:JSONEncode(Configs));
end;

Load = function()
	local base = "Fetching'Script/Config/" .. PlayerId;
	local path = base .. "/" .. PlaceId .. ".json";
	if not isfolder("Fetching'Script") then makefolder("Fetching'Script") end;
	if not isfolder("Fetching'Script/Config") then makefolder("Fetching'Script/Config") end;
	if not isfolder(base) then makefolder(base) end;
	if not isfile(path) then __Class:Save() end;
	return HttpService:JSONDecode(readfile(path));
end;

Default = function(v: string, a: boolean | string | number | table | any)
	if type(v) == "table" then
		for i, k in pairs(v) do
			if Configs[i] == nil then
				Configs[i] = k;
			end;
		end;
	else
		if Configs[v] == nil then
			Configs[v] = a;
		end;
	end;
end;

function __Class:Loop(Value, func, customFunc)
	while Value do
		local startTick = tick();
		if func then pcall(func);end;
		if customFunc and customFunc() then break;end;
		repeat __Class:Render();
		until tick() - startTick >= (.1)
	end;
end;

function __Class:Again(c: func)
	task.spawn(function()
		while task.wait(0.1) do
			pcall(c);
		end;
	end);
end;

function __Class:pairs(meta: Instance, callback: func)
	for _, v in pairs(meta:GetChildren()) do
		callback(v);
	end;
end;

function __Class:ipairs(meta: Instance, callback: func)
	for _, v in ipairs(meta:GetDescendants()) do
		callback(v);
	end;
end;

function __Class:touchconnect(v: BasePart)
	if v:IsA("BasePart") then
		firetouchinterest(HumanoidRootPart, v, 1);
		firetouchinterest(HumanoidRootPart, v, 0);
	end;
end;

function __Class:IsEquiped(v: string)
	return Character:FindFirstChild(v);
end;

function __Class:HaveItem(v: string)
	return Character:FindFirstChild(v) or Backpack:FindFirstChild(v);
end;

function __Class:GetScriptENV(s: LocalScript)
	return getsenv(s);
end;

function __Class:GetRuntimeENV(s: LocalScript)
	return getrenv(s);
end;

function __Class:GetTags(s: Tags, callback: func)
	for _, v in pairs(s:GetTags(s)) do
		for _, a in pairs(v:GetChildren()) do
			callback(v);
		end;
	end;
end;

function __Class:HOP()
	pcall(function()
		local ListServers = function(cursor)
			return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100" .. ((cursor and "&cursor="..cursor) or "")))
		end
		local Server, Next;
		repeat
			local Servers = ListServers(Next)
			Server = Servers.data[1]
			Next = Servers.nextPageCursor
		until Server
		TeleportService:TeleportToPlaceInstance(PlaceId,Server.id,LocalPlayer)
	end)
end

function __Class:Rejoin()
	if #Players:GetPlayers() <= 1 then
		LocalPlayer:Kick("\nRejoining...")
		wait()
		TeleportService:Teleport(PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
	end
end

Configs = Load();

return {__Class;translate;Configs;Funcs;Default}
