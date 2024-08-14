
-- The Rayfield devs for the UI framework
-- Shafer#8116 and Commander_Blob#3674 for testing
-- MyWorld for the hidden fling
-- Outliers for helping with the code
-- Luraph for the obfuscation
-- and guest257351 for writing this script and these awesome credits no one will read cuz private script :)
if not LPH_OBFUSCATED then
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_OBFUSCATED = false
end

jinja={run=function()end,var=function()end}
jinja.run[[ extends "templates/whitelist.lua" ]]

jinja.run[[ block program]]
local program = "Fling"
jinja.run[[ endblock ]]

jinja.run[[ block script ]]

local Exit = false
local connections = {}
local window
local lib
local keybindService
local flyKeyDown
local flyKeyUp
local clickConnection
local downedConnection
local nameBox
local nbUpdateFunc
local nbSelection
local statusGood = true
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

if not wlv2 and LPH_OBFUSCATED then while true do end end -- prevent accidentally releasing script without whitelist system

workspace.FallenPartsDestroyHeight = 0 / 0
if setfpscap then
    setfpscap(9999)
end
local limbPositions = {
    {0.44, 0, -0.44},
    {-0.44, 0, -0.44},
    {0.44, 0, 0.44},
    {-0.44, 0, 0.44}
}

-- check if heartbeat is defined, an integer, and if it's difference from current time is less than 4 secconds
-- if not, return false
_G["LIMBLOCK"] = false
local function isHeartbeat()
    local heartbeat = _G['HEARTBEAT']
    if not heartbeat or heartbeat == nil then
        heartbeat = math.huge
    end
    if type(heartbeat) == "number" and math.abs(os.time() - heartbeat) > 4 then
        return true
    end
    return false
end

-- sends a roblox notification
local function notify(title, content)
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = title,
        Text = content,
    })
end

local function try(...)
    local status, err = pcall(...)
    if not status then
        warn(err)
    else
        return err
    end
end

local function ancestorOf(instance, parent)
    while true do
        if instance == parent then
            return true
        end
        if instance.Parent == nil then
            return false
        end
        instance = instance.Parent
    end
end

local function findFirstAncestor(instance, name)
    while true do
        if instance.Name == name then
            return instance
        end
        if instance.Parent == nil then
            return nil
        end
        instance = instance.Parent
    end
end

local function findFirstAncestorOfClass(instance, class)
    while true do
        if instance:IsA(class) then
            return instance
        end
        if instance.Parent == nil then
            return nil
        end
        instance = instance.Parent
    end
end

local function findHumanoid(instance)
    if instance:IsA("Humanoid") then
        return instance
    end
    while true do
        if instance.Parent == nil then
            return nil
        end
        local humanoid = instance.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid
        end
        instance = instance.Parent
    end
end

local function unhovername()
    if nbUpdateFunc then
        nbUpdateFunc:Disconnect()
    end
    if nameBox then
        nameBox:Destroy()
    end
    if nbSelection then
        nbSelection:Destroy()
    end
end


local clickTarget = nil
local lastTargetCheck = 0
local clickTargetConnection = mouse.Move:Connect(function()
    if lastTargetCheck + 0.1 > tick() then
        return
    end
    lastTargetCheck = tick()
    if mouse.Target and _G["ENABLED"] and _G["CLICKFLING"] then
        -- find closest player within 10 studs
        local closestPlayer = nil
        local closestDistance = 10
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game:GetService("Players").LocalPlayer then
                local character = player.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.RootPart then
                        local distance = (humanoid.RootPart.Position - mouse.Hit.Position).Magnitude
                        if distance < closestDistance then
                            closestPlayer = player
                            closestDistance = distance
                        end
                    end
                end
            end
        end
        if closestPlayer then
            clickTarget = closestPlayer
        else
            clickTarget = nil
        end
    else
        clickTarget = nil
    end
end)
    
    

local hovernameGui = game:GetService("CoreGui"):FindFirstChild("HoverName") or Instance.new("ScreenGui", game:GetService("CoreGui"))
hovernameGui.Name = "HoverName"

local function cycleSpectrum(color)
    local currentTime = tick()
    local frequency = 1
    
    local r = math.sin(frequency * currentTime + 0) * 127 + 128
    local g = math.sin(frequency * currentTime + 2) * 127 + 128
    local b = math.sin(frequency * currentTime + 4) * 127 + 128
    
    return Color3.new(r / 255, g / 255, b / 255)
end

local function cycleSpectrumText(guiObject)
    while true do
        local color = cycleSpectrum()
        guiObject.TextColor3 = color
        wait(0.1)
    end
end

local function cycleSpectrumNBSelection(guiObject)
    while true do
        local color = cycleSpectrum()
        guiObject.Color3 = color
        wait(0.1)
    end
end



local function hovername()
    local nameBox = Instance.new("TextLabel")
    nameBox.Name = "HoverName"
    nameBox.Parent = hovernameGui
    nameBox.BackgroundTransparency = 1
    nameBox.Size = UDim2.new(0, 200, 0, 30)
    nameBox.Font = Enum.Font.Code
    nameBox.TextSize = 16
    nameBox.Text = ""
    nameBox.TextStrokeTransparency = 0
    nameBox.TextXAlignment = Enum.TextXAlignment.Left
    nameBox.ZIndex = 10

    local nbSelection = Instance.new('SelectionBox')
    nbSelection.Name = "HoverSelection"
    nbSelection.LineThickness = 0.03
    nbSelection.Color3 = Color3.new(1, 1, 1)  -- Initial color

    spawn(function()
        cycleSpectrumText(nameBox)
    end)

    spawn(function()
        cycleSpectrumNBSelection(nbSelection)
    end)

    local function updateNameBox()
		local t
		local target = mouse.Target

		if target then
			local humanoid = clickTarget and clickTarget.Character and clickTarget.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and _G["ENABLED"] and humanoid.Parent ~= game:GetService("Players").LocalPlayer.Character then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = mouse.X
			local y = mouse.Y
			local xP
			local yP
			if mouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = mouse.Move:Connect(updateNameBox)
end

local function cleanUp()
    for _, connection in ipairs(connections) do
        local status, err = pcall(function()
            connection:Disconnect()
        end)
        if not status then
            print(err)
        end
    end
end


local function exitCleanUp()
    cleanUp()
    unhovername()
    if flyKeyUp then
        flyKeyUp:Disconnect()
    end
    if flyKeyDown then
        flyKeyDown:Disconnect()
    end
    if clickConnection then
        clickConnection:Disconnect()
    end
    if keybindService then
        keybindService:Disconnect()
    end
    if downedConnection then
        downedConnection:Disconnect()
    end
    if clickTargetConnection then
        clickTargetConnection:Disconnect()
    end
end

-- Print only if output is enabled
local externalPrint = false
local function Print(text)
    if _G['OUTPUT'] then
        if not externalPrint then
            print(text)
        else
            rconsolename('Criminality Fling')
            rconsoleprint(tostring(text)..'\n')
        end
    end
end

-- converts table to string
local function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = 0
    local tmp = string.rep(" ", depth)
    if name then tmp = tmp .. name .. " = " end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    elseif typeof(val) == "Color3" then
        tmp = tmp .. "Color3.new(" .. tostring(val.r) .. "," .. tostring(val.g) .. "," .. tostring(val.b) .. ")"
    elseif typeof(val) == 'EnumItem' then
        tmp = tmp .. tostring(val)
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end
    return tmp
end

_G["SERIALIZE"] = serializeTable

local settings = {}
_G["SETTINGS"] = settings

-- write the value to the save file
local function save(name, value)
    if _G['AUTOSAVING'] or name == 'AutoSaving' then
        local data
        if isfile('crimfling.rosex') then
            data = loadstring(readfile('crimfling.rosex'))()
        else
            data = {}
        end
        data[name] = value
        data = 'return ' .. serializeTable(data)
        writefile('crimfling.rosex', data)
        settings[name] = value
        Print('SAVED ' .. name:upper() .. '!')
    end
end

-- get a value from the save file
local function getSav(name)
    local status, data
    if isfile('crimfling.rosex') then
        status, data = pcall(loadstring, readfile('crimfling.rosex'))
        if status then
            status, data = pcall(data)
        end
        if not status then
            notify("Error", "Save data was courupted, resetting")
            writefile('crimfling.rosex', 'return {}')
            data = {}
        end
    else
        data = {}
    end
    return data[name]
end

-- return the saved value or default if not saved
local function defaultSetting(default, name)
    local saveValue = getSav(name)
    if saveValue == nil then
        saveValue = default
    end
    settings[name] = saveValue
    return saveValue
end

local function getEnumItems(enum)
    local items = {}
    for _,v in pairs(enum:GetEnumItems()) do
        table.insert(items, v.Name)
    end
    table.sort(items)
    return items
end

local function getEnumItem(enum, name)
    return enum[name]
end

-- send out a heartbeat
local function heartbeat()
    _G['HEARTBEAT'] = os.time()
end

local function exitCallback(exitType, arg1, arg2)
    if exitType == "error" then
        warn('CRASHED DUE TO ERROR:\n'..arg1)
        Print('CRASHED DUE TO ERROR:\n'..arg1)
        notify('Crashed', 'Script has crashed!')
    elseif exitType == "normal" then
        notify('Exited', 'Script has exited!')
        Print('EXITED VIA GUI!')
    end
    _G['ENABLED'] = false
    _G['HEARTBEAT'] = false
    _G['HIDDEN'] = false
    _G['VELOCITY'] = false
    _G['MAINLOOP'] = false
    lib:Destroy()
    exitCleanUp()
end

if wlv2 then 
    wlv2.exitCallback = exitCallback
    wlv2.callbackOnError = true
end

-- checks if the game is criminality
local validPlace = true
-- if game.PlaceId ~= 8343259840 then-
--     notify('Error', 'Script only works in criminality')
--     validPlace = false
-- end
if validPlace then


    -- check if script is already running
    if isHeartbeat() then
        _G['ENABLED'] = false -- Change to false to dissable the loop
        _G['MAINLOOP'] = true -- Change to false to disable the main loop
        if _G["ALREADYEXEC"] then
            _G["DISPERSERATELIMIT"] = tick()
        else
            _G["DISPERSERATELIMIT"] = 0
        end
        _G['OUTPUT'] = true -- Change to false to disable Printing to console
        _G['AUTOSAVING'] = defaultSetting(true, 'AutoSaving') -- enables autosaving
        local FLYING
        heartbeat()
        -- gui library
        local libstring
        for _,v in pairs({'https://cdn.guest.gay/libs/rayfield.lua', "https://sirius.menu/rayfield"}) do -- the backup wont actually work since Cube-07 uses a custom version of rayfield
            if pcall(function()
                libstring = game:HttpGet(v)
            end) then
                break
            end
        end
        getgenv().SecureMode = true
        lib = loadstring(libstring)()
        window = lib:CreateWindow({
            Name = "Cube-07",
            LoadingTitle = "Loading Cube-07 || Flinginality",
            LoadingSubtitle = "Please wait...",
            ConfigurationSaving = {
                Enabled = false,
                FolderName = "Flinginality",
                FileName = "Cube-07"
            },
            Discord = {
                Enabled = false,
                Invite = "noinvitelink",
                RememberJoins = true
            },
            KeySystem = false,
            KeySettings = {
                Title = "Untitled",
                Subtitle = "Key System",
                Note = "No method of obtaining the key is provided",
                FileName = "Key",
                SaveKey = true,
                GrabKeyFromSite = false,
                Key = {"none"}
            }
        })
        -- allows for terminating the script from another script if it breaks
        _G['GUI'] = lib
        print("Pls show boobs :)")
        
        local main = window:CreateTab('Main')

        main:CreateButton({
            Name = 'Close script', 
            Callback = function()
                task.delay(1, function()
                    if wlv2 then 
                        wlv2:closeScript()
                    else
                        exitCallback("normal")
                    end
                end)
                lib:Notify({
                    Title = "Closing GUI",
                    Content = "Exiting script, please wait...",
                    Duration = 2,
                })
                lib:Hide(false)
            end
        })

        main:CreateToggle({
            Name = 'Enable Auto Saving',
            CurrentValue = defaultSetting(true, 'AutoSaving'),
            Callback = function(enabled)
                save('AutoSaving', enabled)
                _G['AUTOSAVING'] = enabled
            end
        })


        local hiddenFling
        local flingToggled
        flingToggled = main:CreateToggle({
            Name = 'Enable Fling',
            CurrentValue = false,
            Callback = function(b)
                if _G['HIDDEN'] then
                    _G['HIDDEN'] = false
                    hiddenFling:Set(false)
                end
                _G['ENABLED'] = b
            end
        })

        main:CreateDropdown({
            Name = "Fling Method",
            Options = {
                "Normal",
                "Rotational",
                "Lock orientation",
            },
            MultipleOptions = false,
            CurrentOption = defaultSetting("Normal", 'velocityMethod'),
            Callback = function(type)
                save('velocityMethod', type[1])
            end, 
        })

        hiddenFling = main:CreateToggle({
            Name = "Hidden Fling",
            CurrentValue = false,
            Callback = function(b)
                if _G['ENABLED'] then
                    _G['ENABLED'] = false
                    flingToggled:Set(false)
                end
                _G['VELOCITY'] = false
                _G['HIDDEN'] = b
            end
        })

        main:CreateKeybind({
            Name = "Hidden Fling Keybind",
            CurrentKeybind = "H",
            Callback = function()
                if not _G["ENABLED"] then
                    _G['HIDDEN'] = not _G['HIDDEN']
                    hiddenFling:Set(_G['HIDDEN'])
                end
            end
        })

        main:CreateSlider({
            Name = "Fly Speed",
            Range = {0.1, 10},
            Increment = 0.1,
            Suffix = "speed",
            CurrentValue = defaultSetting(1, 'flySpeed'),
            Callback = function(speed)
                save('flySpeed', speed)
            end
        })

        main:CreateToggle({
            Name = "External Print",
            CurrentValue = defaultSetting(false, 'externalConsole'),
            Callback = function(b)
                save('externalConsole', b)
                externalPrint = b
            end
        })
        externalPrint = defaultSetting(false, 'externalConsole')

        local brickThemes = window:CreateTab('Brick Theme')

        brickThemes:CreateColorPicker({ 
            Name = "Brick Color",
            Color = defaultSetting(Color3.fromRGB(255, 255, 255), 'brickColor'),
            Callback = function(color)
                save('brickColor', color)
            end,
        })

        brickThemes:CreateSlider({
            Name = "Brick Transparency",
            Range = {0, 1},
            Increment = 0.1,
            Suffix = "transparency",
            CurrentValue = defaultSetting(1, 'brickTransparency'),
            Callback = function(transparency)
                save('brickTransparency', transparency)
            end
        })

        brickThemes:CreateToggle({
            Name = "Toggle Highlight",
            CurrentValue = defaultSetting(true, 'highlightToggle'),
            Callback = function(b)
                save('highlightToggle', b)
            end
        })

        brickThemes:CreateColorPicker({
            Name = "Highlight Color",
            Color = defaultSetting(Color3.fromRGB(0, 255, 0), 'highlightColor'),
            Callback = function(color)
                save('highlightColor', color)
            end,
        })

        brickThemes:CreateToggle({ -- THIS IS NOT A RAINBOW HIGHLIGHT ITS A TRANSITIONING COLOR
            Name = "Rainbow Highlight",
            CurrentValue = defaultSetting(false, 'rainbowHighlight'),
            Callback = function(b)
                save('rainbowHighlight', b)
            end
        })

        brickThemes:CreateToggle({ -- THIS IS RGB GAY CUBE MODE
            Name = "Toggle SpectrumCycling",
            CurrentValue = defaultSetting(true, 'SpectrumCycle'),
            Callback = function(b)
                save('SpectrumCycle', b)
            end
        })

        brickThemes:CreateColorPicker({
            Name = "Highlight Status Bad Color",
            Color = defaultSetting(Color3.fromRGB(0, 0, 0), 'highlightStatusBadColor'),
            Callback = function(color)
                save('highlightStatusBadColor', color)
            end,
        })

        local brickMaterial
        brickMaterial = brickThemes:CreateDropdown({
            Name = "Brick Material",
            Options = getEnumItems(Enum.Material),
            CurrentOption = defaultSetting("Plastic", 'brickMaterial'),
            MultipleOptions = false,
            Callback = function(material)
                if material[1] ~= "Air" then
                    save('brickMaterial', material[1])
                else
                    lib:Notify({
                        Title = "Error",
                        Content = "Cannot set material to air",
                    })
                    brickMaterial:Set(defaultSetting("Plastic", 'brickMaterial'))
                end
            end
        })

        local automation = window:CreateTab('Automation')

        -- local playerList = automation:CreateSelector('Target Player', function(player) end, function()
        --     local players = game:GetService("Players"):GetPlayers()
        --     table.remove(players, table.find(players, game:GetService("Players").LocalPlayer))
        --     return players
        -- end)

        local targetPlayer = nil
        local targetPlayerSelection

        local function targetPlayerCallback(text)
            if text == "" then
                targetPlayer = nil
                return
            end
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player.Name:lower():sub(1, #text) == text:lower() then
                    targetPlayer = player
                    targetPlayerSelection.InputFrame.InputBox.Text = player.Name
                end
            end

        end
        targetPlayerSelection = automation:CreateInput({
            Name = "Target Player",
            PlaceholderText = "Player to fling",
            RemoveTextAfterFocusLost = false,
            Callback = targetPlayerCallback
        })

        targetPlayerSelection.InputFrame.InputBox.Focused:Connect(function()
            targetPlayerSelection.InputFrame.InputBox.Text = ""
        end)

        automation:CreateDropdown({
            Name = "Automatic Fling Type",
            Options = {
                "Normal",
                "Predictive",
                "V2 Prediction",
                "V3 Prediction",
                -- "V4 Prediction",
                "Random",
                "Predictive Random",
                "Orbit",
                "Predictive Orbit"
            },
            CurrentOption = {defaultSetting("V3 Prediction", 'autoFlingType')},
            MultipleOptions = false,
            Callback = function(type)
                save('autoFlingType', type[1])
            end,
        })

        --[[automation:CreateKeybind({
            Name = "Hide cube keybind",
            CurrentKeybind = "T",
            Callback = function()
                if not _G["ENABLED"] then
                    _G['HIDECUBE'] = not _G['HIDECUBE']
                    cubeVisibilityToggle:Set(_G['HIDECUBE'])
                end
            end
        })

        cubeVisibilityToggle = automation:CreateToggle({
            Name = "Hide cube (cant be seen or damaged)",
            CurrentValue = false,
            Callback = function(b)
                if not _G['ENABLED'] then
                    cubeVisibilityToggle:Set(false)
                end
                _G['HIDECUBE'] = b
            end
        })]]--

        local autoFling = false
        automation:CreateButton({
            Name = 'Automatically Fling Player',
            Callback = function()
                autoFling = true
            end
        })

        local autoFlingCancel = false
        automation:CreateButton({
            Name = 'Cancel Automatic Fling',
            Callback = function()
                autoFlingCancel = true
            end
        })


        automation:CreateSection('Kill All')

        local killAll = false
        automation:CreateButton({
            Name = 'Kill All Players',
            Callback = function()
                killAll = true
            end
        })
        
        local disperseToggle = false
        automation:CreateButton({
            Name = "Split Attack",
            CurrentValue = false,
            Callback = function()
                disperseToggle = true
            end
        })

        --[[automation:CreateSlider({
            Name = "Click To Fling Range",
            Range = {5, 10000},
            Increment = 5,
            Suffix = "Distance",
            CurrentValue = defaultSetting(1000, 'CTFRange'),
            Callback = function(c)
                save('CTFRange', c)
            end
        })]]--

        automation:CreateSlider({
            Name = "Health Threshold",
            Range = {0, 114},
            Increment = 1,
            Suffix = "HP",
            CurrentValue = defaultSetting(30, 'HealthThresholdSlider'),
            Callback = function(a)
                save('HealthThresholdSlider', a)
            end
        })

        automation:CreateSlider({
            Name = "Fling aura distance",
            Range = {0, 10000},
            Increment = 0.1,
            Suffix = "studs",
            CurrentValue = defaultSetting(10, 'KillAuraMagnitude'),
            Callback = function(a)
                save('KillAuraMagnitude', a)
            end
        })

        automation:CreateSlider({
            Name = "Fling stalker distance",
            Range = {0, 1000},
            Increment = 0.1,
            Suffix = "studs",
            CurrentValue = defaultSetting(50, 'KillCreeps'),
            Callback = function(a)
                save('KillCreeps', a)
            end
        })

        automation:CreateSlider({
            Name = "Kill All Time",
            Range = {5, 10000},
            Increment = 5,
            Suffix = "frames",
            CurrentValue = defaultSetting(1000, 'killAllTime'),
            Callback = function(time)
                save('killAllTime', time)
            end
        })


        automation:CreateSection('Automation Settings')

        automation:CreateToggle({
            Name = "Focus on Target",
            CurrentValue = defaultSetting(true, 'targetCamera'),
            Callback = function(b)
                save('targetCamera', b)
            end
        })
        task.wait()
        
        hovername()
        _G["CLICKFLING"] = defaultSetting(false, 'clickToFling')
        local Players = game:GetService("Players")
        local Player = Players.LocalPlayer
        table.insert(connections, mouse.Button1Down:connect(function()
            if _G['ENABLED'] and _G["CLICKFLING"] then
                if clickTarget then
                    targetPlayer = clickTarget
                    autoFling = true
                end
            end
        end))

        -- function to set the target player and trigger autoFling on click
        automation:CreateToggle({
            Name = "Click to Fling",
            CurrentValue = defaultSetting(false, 'clickToFling'),
            Callback = function(b)
                _G["CLICKFLING"] = b
                save('clickToFling', b)
            end
        })

        automation:CreateToggle({
            Name = "Vertical Prediction",
            CurrentValue = defaultSetting(false, 'verticalPrediction'),
            Callback = function(b)
                save('verticalPrediction', b)
            end
        })

        automation:CreateToggle({
            Name = "Discord Kill Feed",
            CurrentValue = defaultSetting(false, 'killFeed'),
            Callback = function(b)
                save('killFeed', b)
            end
        })

        automation:CreateToggle({
            Name = "Skip protected",
            CurrentValue = defaultSetting(false, 'skipProtected'),
            Callback = function(b)
                save('skipProtected', b)
            end
        })

        --[[automation:CreateToggle({
            Name = "Target Head",
            CurrentValue = defaultSetting(false, 'headTarget'),
            Callback = function(b)
                save('headTarget', b)
            end
        })]]--

        automation:CreateSlider({
            Name = "Prediction Offset",
            Range = {0, 5},
            Increment = 0.1,
            Suffix = "multiplier",
            CurrentValue = defaultSetting(1, 'predictionOffset'),
            Callback = function(offset)
                save('predictionOffset', offset)
            end
        })

        automation:CreateSlider({
            Name = "Max Velocity",
            Range = {1, 500},
            Increment = 1,
            Suffix = "velocity",
            CurrentValue = defaultSetting(50, 'maxVelocity'),
            Callback = function(velocity)
                save('maxVelocity', velocity)
            end
        })

        automation:CreateSlider({
            Name = "Max Rubber Band",
            Range = {0, 10},
            Increment = 0.1,
            CurrentValue = defaultSetting(3, 'maxRubberBand'),
            Callback = function(rubberBand)
                save('maxRubberBand', rubberBand)
            end
        })

        automation:CreateSlider({
            Name = "Min Rubber Band",
            Range = {0, 10},
            Increment = 0.1,
            CurrentValue = defaultSetting(0.3, 'minRubberBand'),
            Callback = function(rubberBand)
                save('minRubberBand', rubberBand)
            end
        })

        automation:CreateSlider({
            Name = "Random Radius",
            Range = {0, 50},
            Increment = 1,
            Suffix = "studs",
            CurrentValue = defaultSetting(10, 'randomRadius'),
            Callback = function(radius)
                save('randomRadius', radius)
            end
        })

        automation:CreateSlider({
            Name = "Time (0 = inf)",
            Range = {0, 10000},
            Increment = 100,
            Suffix = "frames",
            CurrentValue = defaultSetting(1000, 'autoFlingFrames'),
            Callback = function(frames)
                save('autoFlingFrames', frames)
            end
        })

        automation:CreateSlider({
            Name = "Orbit Radius",
            Range = {0, 50},
            Increment = 1,
            Suffix = "studs",
            CurrentValue = defaultSetting(10, 'orbitRadius'),
            Callback = function(radius)
                save('orbitRadius', radius)
            end
        })

        automation:CreateSlider({
            Name = "Orbit Speed",
            Range = {0.1, 3},
            Increment = 0.1,
            Suffix = "seconds",
            CurrentValue = defaultSetting(1, 'orbitSpeed'),
            Callback = function(speed)
                save('orbitSpeed', speed)
            end
        })

        automation:CreateSlider({
            Name = "V2+ Circle Sensitivity",
            Range = {0, 1},
            Increment = 0.01,
            CurrentValue = defaultSetting(0.4, 'circleSensitivity'),
            Callback = function(sensitivity)
                save('circleSensitivity', sensitivity)
            end
        })

        --[[automation:CreateSlider({
            Name = "V4 History Length",
            Range = {0, 1000},
            Increment = 1,
            Suffix = "frames",
            CurrentValue = defaultSetting(20, 'predictionHistory'),
            Callback = function(history)
                save('predictionHistory', history)
            end
        })]]--

        local credits = window:CreateTab('Credits')

        credits:CreateLabel("|| guest257351 creator of the script ||")
        credits:CreateLabel('|| Itslush for the fling method ||')
        credits:CreateLabel('|| Sirius for the UI framework ||')
        credits:CreateLabel('|| Shafer and Commander_Blob for testing ||')

        local tips = window:CreateTab('ⓘ Tips')

        tips:CreateLabel("|| If you have low ping (50 - 120ms), set the prediction offset to 2.5 - 3.2 ||")
        tips:CreateLabel('|| If you have high ping (200 ms or higher), set the prediction offset to 2 - 1.3 ||')
        tips:CreateLabel('|| I reccommend setting the max rubberband to 5 - 6 ||')
        tips:CreateLabel('|| I reccommend setting the min rubberband to 0.2 - 0.3 ||')
        tips:CreateLabel('|| Max velocity should be set to 500. ||')
        tips:CreateLabel('|| To fix problems with flinging people going in circles, adjust V2circleSens by lowering or raising it. ||')
        -- gets a part matching the criteria
        local function gp(parent, name, className)
            local ret = nil
            pcall(function()
                for i, v in pairs(parent:GetChildren()) do
                    if (v.Name == name) and v:IsA(className) then
                        ret = v
                        break
                    end
                end
            end)
            return ret
        end

        -- returns the local player
        local getSpeaker = function()
            return game:GetService("Players").LocalPlayer
        end

        -- returns the characters root part
        local function getRoot(char)
            local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
            return rootPart
        end


        local limbCache = {}
        local limbCacheLastUpdated = 0
        local function getLimbs(speaker)
            if tick() - limbCacheLastUpdated > 5 then
                limbCache = {}
                limbCacheLastUpdated = tick()
                local char = speaker.Character
                if char then
                    local limbs = {
                        gp(char, 'Right Arm', 'BasePart'), gp(char, 'Left Arm', 'BasePart'), gp(char, 'Right Leg', 'BasePart'), gp(char, 'Left Leg', 'BasePart')
                    }
                    limbCache = limbs
                end
            end
            return limbCache
        end

        local function getTorso(speaker)
            local char = speaker.Character
            if char then
                local torso = char:FindFirstChild('FlingPart')
                if torso then
                    return torso
                end
            end
            return nil
        end

        local function getBodyPosition(speaker)
            local torso = getTorso(speaker)
            if torso then
                local bodyPosition = torso:FindFirstChildOfClass('BodyPosition')
                if bodyPosition then
                    return bodyPosition
                end
            end
            return nil
        end

        -- tries to get location and returns the old possition if it failed
        local function getLocation(original)
            local Torso = getTorso(getSpeaker())
            local loc
            if Torso then
                loc = Torso.CFrame
            end
            if not loc then
                loc = original
            end
            return loc
        end

        -- alternative to isDead(), checks if the speaker is at 0 health
        local function noHealth(speaker)
            local char = speaker.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    if hum.Health == 0 then
                        return true
                    else
                        return false
                    end
                end
            end
            return true
        end

        local function randomString()
            local length = math.random(10,20)
            local array = {}
            for i = 1, length do
                array[i] = string.char(math.random(32, 126))
            end
            return table.concat(array)
        end

        local random = randomString()

        --[[spawn(function()
            print('HIDING THE CUBE...')
            if _G['HIDECUBE'] then
                while _G['HIDECUBE'] do
                local hidingspot = CFrame.new(9999,9999,9999)
                local limbs = getLimbs(getSpeaker())

                for _, limb in pairs(limbs) do
                     print("going to hiding spot")
                    _G["LIMBLOCK"] = false
                    statusGood = false
                    limb.CFrame = hidingspot
                end
                task.wait(0.05)
            end
            end
            print('RETURNING THE CUBE...')
            _G["LIMBLOCK"] = true
            statusGood = true
        end)]]--
        
        local TweenService = game:GetService("TweenService")

        local function guestbrine(duration)
            duration = duration or 4
            repeat wait() until game:GetService("Players").LocalPlayer.Character
            local root = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local model = game:GetObjects("rbxassetid://11947723579")[1]
            model.Parent = workspace
            local target = model:FindFirstChild("HumanoidRootPart")
            target.CFrame = root.CFrame+root.CFrame.LookVector*10
        
            local connection = game:GetService("RunService").RenderStepped:Connect(function()
                local goal = {}
                goal.CFrame = CFrame.lookAt(target.Position, root.Position)
                local tween = TweenService:Create(target, TweenInfo.new(.5), goal)
                tween:Play()
            end)
            
            if duration == -1 then
                return
            end
            task.wait(duration)
            connection:Disconnect()
            model:Destroy()
        end
        
        local function jumpscare()
            local currentTime = os.date("*t")
            if currentTime.hour >= 3 and currentTime.hour < 4 then
                guestbrine(6)
            else
                warn("you're lucky")
            end
        end

        jumpscare()

        -- hidden fling thread
        heartbeat()
        spawn(function()
            local hrp, c, vel, movel = nil, nil, nil, 0.1
            Print('HIDDEN FLING PROCESS STARTED!')
            while _G["HEARTBEAT"] do
                local heartbeat = game:GetService('RunService').Heartbeat
                heartbeat:Wait()
                if _G['HIDDEN'] then
                    while lib and _G['HIDDEN'] and not (c and c.Parent and hrp and hrp.Parent) do
                        heartbeat:Wait()
                        local lp = game:GetService('Players').LocalPlayer
                        c = lp.Character
                        hrp = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart")
                    end
                    if _G['HIDDEN'] then
                        vel = hrp.Velocity
                        local r = game:GetService('RunService').RenderStepped
                        local s = game:GetService('RunService').Stepped
                        hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        r:Wait()
                        if c and c.Parent and hrp and hrp.Parent then
                            hrp.Velocity = vel
                        end
                        s:Wait()
                        if c and c.Parent and hrp and hrp.Parent then
                            hrp.Velocity = vel + Vector3.new(0, movel, 0)
                            movel = movel * -1
                        end
                    end
                end
            end
            Print('HIDDEN FLING PROCESS STOPPED!')
            _G['HIDDEN'] = false
        end)

        if identifyexecutor and identifyexecutor() ~= "Krampus" then
            local Old 
            Old = hookmetamethod(game, "__namecall", newcclosure(LPH_JIT(function(self, ...)
                local Method = getnamecallmethod()
                local Args = {
                    ...
                }
                if Method == "FireServer" and Args[1] == "FlllD" or Args[1] == "FlllH" then
                    if _G['HIDDEN'] or _G["ENABLED"] then
                        Print('PREVENTED FALL DAMAGE!')
                        return wait(9e9)
                    end
                elseif Method == "FireServer" and Args[1] == "__--r" or Args[1] == "HITRGP" or Args[1] == "FllH" then
                    if _G['HIDDEN'] then
                        Print('PREVENTED RAGDOLL!')
                        return wait(9e9)
                    end
                end
                return Old(self, ...)
            end)))

            LPH_JIT_MAX(function()
                for i,v in pairs(getgc(true)) do
                    if typeof(v) == 'table' and typeof(rawget(v, 'B')) == "function" then
                        v.B = function() end
                    end
                end
            end)()

            local Old
            Old = hookmetamethod(game, "__namecall", function(self, ...)

                if getnamecallmethod() == "FireServer" and tostring(self) == "0924023902330" then
                    return wait(9e9)
                end

                return Old(self, ...)
            end)
            local Old
            Old = hookmetamethod(game, "__namecall", function(self, ...)
    
                if getnamecallmethod() == "Destroy" and tostring(self) == random then
                    return wait(9e9)
                end
    
                return Old(self, ...)
            end)
        else
            print("SKIPPING METAMETHOD HOOKS")
        end

        local pos = nil
        pos = getLocation(pos)

        while _G['MAINLOOP'] do
            if _G['ERRORSIMULATE'] then
                _G['ERRORSIMULATE'] = nil
                error('Outliers is cool')
            end
            if _G['ENABLED'] then
                local debugFling = false -- set to true to enable Printing out stages of fling activation
                local locationDebug = false -- set to true to Print out location

                -- disables collision on the player
                local NoclipLoop = LPH_JIT_MAX(function()
                    local function characterAdded(character)
                        local function applyNoClip(part)
                            pcall(function()
                                part.CanCollide = false -- raises an error if the property doesn't exist
                                part:GetAttributeChangedSignal("CanCollide"):Connect(function()
                                    if _G["ENABLED"] then
                                        part.CanCollide = false
                                    end
                                end)
                            end)
                        end

                        for i,v in pairs(character:GetDescendants()) do
                            applyNoClip(v)
                        end
                        table.insert(connections, character.DescendantAdded:Connect(applyNoClip))
                    end
                    characterAdded(getSpeaker().Character or getSpeaker().CharacterAdded:wait())
                    table.insert(connections, getSpeaker().CharacterAdded:Connect(characterAdded))
                end)

                NoclipLoop()

                local oldPos = nil
                local function ragdollLoop()
                    local char = getSpeaker().Character
                    _G["OLDPOS"] = oldPos
                    if char then
                        local root = getRoot(char)
                        local head = char:FindFirstChild("Head")
                        local realTorso = char:FindFirstChild("Torso")
                        if root and head and _G["ENABLED"] and _G["RAGDOLL"] then
                            if realTorso and realTorso.Neck.Enabled then
                                game:GetService("ReplicatedStorage").Events.__DFfDD:FireServer("__--r", root.Velocity, root.CFrame)
                            end
                            root.CFrame = CFrame.new(0, -2.75, math.random(1, 5) / 10) * oldPos
                            head.CFrame = realTorso.CFrame
                            head.Velocity = Vector3.new(0, 0, 0)
                            root.Velocity = Vector3.new(0, 50, 0)
                        end
                    end
                end

                table.insert(connections, game:GetService('RunService').Heartbeat:Connect(ragdollLoop))

                local function tryProtectCube()
                    local limbs = getLimbs(getSpeaker())
                    local char = getSpeaker().Character
                    local hum = char:FindFirstChild("Humanoid")
                    local healingPosition = CFrame.new(9999,9999,9999)

                    if hum.Health <= settings["HealthThresholdSlider"] then
                        _G["LIMBLOCK"] = false
                        statusGood = false

                        while hum.Health <= settings["HealthThresholdSlider"] and hum.Health > 0 do
                            for _, limb in pairs(limbs) do
                                limb.CFrame = healingPosition
                            end
    
                            RunService["Heartbeat"]:Wait()
                        end
                    end

                    _G["LIMBLOCK"] = true
                    statusGood = true
                end

                local function stateLoop()
                    local char = getSpeaker().Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and _G["ENABLED"] then
                            hum:ChangeState(16)
                        end
                    end
                end

                table.insert(connections, game:GetService('RunService').Stepped:Connect(stateLoop))


                local function applySoundChecks()
                    local soundCheck = LPH_JIT_MAX(function(sound)
                        if sound:IsA("Sound") and _G['ENABLED'] then
                            task.wait()
                            sound:Destroy()
                        end
                    end)
                    task.spawn(function()
                        local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:wait()
                        for _,v in pairs(char:GetDescendants()) do
                            soundCheck(v)
                        end
                        char.DescendantAdded:Connect(soundCheck)
                    end)
                end

                local velocityLoop1 = LPH_JIT(function()
                    if _G["VELOCITY"] and settings["velocityMethod"] ~= "Rotational" then
                        local limbs = getLimbs(getSpeaker())
                        if limbs then
                            for _, limb in pairs(limbs) do
                                limb.Velocity = Vector3.new(999999, 999999*10, 999999)
                            end
                        end
                        local flingPart = getTorso(getSpeaker())
                        if flingPart then
                            local bodyThrust = flingPart:FindFirstChildOfClass('BodyThrust')
                            if bodyThrust then
                                bodyThrust:Destroy()
                            end
                        end
                    elseif _G["VELOCITY"] and settings["velocityMethod"] == "Rotational" then
                        local flingPart = getTorso(getSpeaker())
                        if flingPart then
                            local bodyThrust = flingPart:FindFirstChildOfClass('BodyThrust') or Instance.new('BodyThrust', flingPart)
                            bodyThrust.Force = Vector3.new(0, 40000, 40000)
                            bodyThrust.Location = Vector3.new(6, 10, -8)
                        end
                    end
                end)

                table.insert(connections, game:GetService("RunService").Heartbeat:Connect(velocityLoop1))

                local velocityLoop2 = LPH_JIT(function()
                    if _G["VELOCITY"] and settings["velocityMethod"] ~= "Rotational" then
                        local limbs = getLimbs(getSpeaker())
                        if limbs then
                            for _, limb in pairs(limbs) do
                                limb.Velocity = Vector3.new(0, 0, 0)
                            end
                        end
                    end
                end)

                table.insert(connections, game:GetService("RunService").RenderStepped:Connect(velocityLoop2))

                local limbLoop = LPH_JIT_MAX(function()
                    if _G["ENABLED"] and getSpeaker().Character.Torso and _G["LIMBLOCK"] then
                        local limbs = getLimbs(getSpeaker())
                        if limbs then
                            for i, offset in ipairs(limbPositions) do
                                if limbs[i] and getTorso(getSpeaker()) then
                                    limbs[i].CFrame = getTorso(getSpeaker()).CFrame * CFrame.new(unpack(offset))
                                end
                            end
                        end
                    end
                end)
                
                table.insert(connections, game:GetService('RunService').Heartbeat:Connect(limbLoop))

                local function lerpColor(color1, color2, t)
                    return Color3.new(
                        color1.r + (color2.r - color1.r) * t,
                        color1.g + (color2.g - color1.g) * t,
                        color1.b + (color2.b - color1.b) * t
                    )
                end
                
                local function getTransitionColor(t)
                    local darkPurple = Color3.fromRGB(238, 68, 182)
                    local deepOrange = Color3.fromRGB(237, 147, 68)
                    return lerpColor(darkPurple, deepOrange, t)
                end
                
                local function activateSpectrumMode()
                    local timeElapsed = 0
                    local totalTime = 3.5
                
                    local hue = (time() % 10) / 10
                    return Color3.fromHSV(hue, 1, 1)
                end
                
                local styleLoop = LPH_JIT_MAX(function()
                    local char = getSpeaker().Character
                    if char and _G["ENABLED"] then
                        local flingPart = char:FindFirstChild("FlingPart")
                        if flingPart then
                            flingPart.Transparency = settings["brickTransparency"] < 1 and settings["brickTransparency"] or 0.99
                            flingPart.Material = settings["brickMaterial"]
                            local highlight = flingPart:FindFirstChild("Highlight")
                            local realTorso = char:FindFirstChild("Torso")
                            if _G["LIMBLOCK"] then
                                for _, limb in pairs(getLimbs(getSpeaker())) do
                                    limb.Transparency = 1
                                end
                            end
                            if highlight and realTorso and settings["highlightToggle"] then
                                highlight.Enabled = true
                                local t = (math.sin(tick()) + 1) / 2
                                local userColorChoice = settings["SpectrumCycle"] and activateSpectrumMode() or settings["rainbowHighlight"] and getTransitionColor(t) or settings["highlightColor"]
                                if realTorso.Neck.Enabled or not statusGood then
                                    highlight.FillColor = settings["highlightStatusBadColor"]
                                else
                                    highlight.FillColor = userColorChoice
                                end
                            else
                                if highlight then
                                    highlight.Enabled = false
                                end
                            end
                        end
                    end
                end)

                table.insert(connections, game:GetService('RunService').Stepped:Connect(styleLoop))

                local function noclipCam(speaker)
                    local sc = (debug and debug.setconstant) or setconstant
                    local gc = (debug and debug.getconstants) or getconstants
                    if not sc or not getgc or not gc then
                        return
                    end
                    local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
                    for _, v in pairs(getgc()) do
                        if type(v) == 'function' and getfenv(v).script == pop then
                            for i, v1 in pairs(gc(v)) do
                                if tonumber(v1) == .25 then
                                    sc(v, i, 0)
                                elseif tonumber(v1) == 0 then
                                    sc(v, i, .25)
                                end
                            end
                        end
                    end
                end

                local oldCameraZoom = getSpeaker().CameraMaxZoomDistance
                local oldFogEnd = Lighting.FogEnd
                local fullBrightConnection = nil
                local function applyCameraEffects()
                    local player = getSpeaker()
                    oldCameraZoom = player.CameraMaxZoomDistance
                    player.CameraMaxZoomDistance = 9e9
                    local function fullBright()
                        Lighting.Brightness = 2
                        Lighting.ClockTime = 14
                        Lighting.FogEnd = 100000
                        Lighting.GlobalShadows = false
                        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                    end
                    --[[local ChatFrame = game.Players.LocalPlayer.PlayerGui.Chat.Frame
                    ChatFrame.ChatChannelParentFrame.Visible = true
                    ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), ChatFrame.ChatChannelParentFrame.Size.Y)]]--
                    if fullBrightConnection then
                        fullBrightConnection:Disconnect()
                    end
                    fullBrightConnection = game:GetService('RunService').RenderStepped:Connect(fullBright)
                    table.insert(connections, fullBrightConnection)
                    oldFogEnd = Lighting.FogEnd
                    noclipCam(player)
                end

                local function removeCameraEffects()
                    local player = getSpeaker()
                    player.CameraMaxZoomDistance = oldCameraZoom
                    if fullBrightConnection then
                        fullBrightConnection:Disconnect()
                    end
                    task.defer(function()
                        Lighting.FogEnd = oldFogEnd
                    end)
                    --[[local ChatFrame = game.Players.LocalPlayer.PlayerGui.Chat.Frame
                    ChatFrame.ChatChannelParentFrame.Visible = false
                    ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(0, 0, 0, 0)]]--
                    Print("REMOVED CAMERA EFFECTS!")
                end


                local function getNearestPlayer(speaker, exclusions)
                    local nearestPlayer = nil
                    local shortestDistance = math.huge
                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= speaker and not exclusions[player] then
                            local char = player.Character
                            if char then
                                local root = getRoot(char)
                                if root then
                                    local distance = (root.Position - getTorso(speaker).Position).Magnitude
                                    if distance < shortestDistance and not noHealth(player) then
                                        shortestDistance = distance
                                        nearestPlayer = player
                                    end
                                end
                            end
                        end
                    end
                    return nearestPlayer
                end

                -- destoys weird stuff
                local function destroyParts(speaker)
                    local char = speaker.Character
                    if char then
                        for _,v in pairs(char:GetDescendants()) do
                            if v.Name == "Part" or v.Name == "CharacterMesh" then
                                v:Destroy()
                            end
                        end
                    end
                end

                local function destroyFlingParts(speaker)
                    local char = speaker.Character
                    if char then
                        for _,v in pairs(char:GetDescendants()) do
                            if v.Name == "FlingPart" or v.Name == "Highlight" then
                                v:Destroy()
                            end
                        end
                        for _,limb in pairs(getLimbs(speaker)) do
                            limb.Transparency = 0
                        end
                        if char:FindFirstChildOfClass("Humanoid") then
                            char:FindFirstChildOfClass("Humanoid"):ChangeState(8)
                        end
                        local root = getRoot(char)
                        if root then
                            local nofall = root:FindFirstChild("ADONIS_FLIGHT")
                            if nofall then
                                nofall:Destroy()
                            end
                        end
                    end
                end

                local function applyCharacterModifications(speaker)
                    local char = speaker.Character
                    if char then

                        local hum = char:FindFirstChildOfClass("Humanoid")
                        hum:ChangeState(16)
                        local root = getRoot(char)
                        local nofall = Instance.new("LocalScript")
                        nofall.Name = "ADONIS_FLIGHT"
                        nofall.Parent = root
                        local torso = char:FindFirstChild("Torso")
                        root.CFrame = oldPos * CFrame.new(0, 1, 0)

                        task.wait()

                        repeat wait() until not char.Torso.Neck.Enabled

                        hum:ChangeState(16) -- // the special sauce
                        char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:wait()

                        for _,limb in pairs(getLimbs(speaker)) do
                            limb.Transparency = 1
                        end

                        local flingPart = Instance.new("Part", char)
                        flingPart.Name = "FlingPart"
                        flingPart.CanCollide = false
                        flingPart.Transparency = 0.99
                        flingPart.Size = Vector3.new(1.5,1.5,1.5)
                        flingPart.Position = oldPos.Position - Vector3.new(0, 50, 0)
                        local highlight = Instance.new("Highlight", flingPart)
                        
                        -- local bp = Instance.new("BodyPosition", flingPart)
                        -- bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        -- bp.P = 1000000
                        -- bp.Name = "TorsoPosition"
                        -- local bt = Instance.new("BodyThrust", flingPart)
                        -- bt.Force = Vector3.new(0, 40000, 40000)
                        -- bt.Location = Vector3.new(6, 10, -8)
                    end
                end

                local function applyAnimation(speaker)
                    local char = speaker.Character
                    if char then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://181526230"
                        local track = char.Humanoid:LoadAnimation(anim)
                        spawn(function()
                            while wait(1) and char and _G["ENABLED"] do
                                track:Play()
                                track:AdjustSpeed(0)
                            end
                            track:Stop()
                        end)
                    end
                end

                -- checks if the players body has despawned
                local function isDead(speaker)
                    local ISDEAD = true
                    for _, player in pairs(workspace.Characters:GetChildren()) do
                        if player.Name == speaker.Name then
                            ISDEAD = false
                            break
                        end
                    end
                    if not ISDEAD then
                        local Torso = speaker.Character:FindFirstChild("Torso")
                        if not Torso then
                            ISDEAD = true
                        end
                    end
                    if ISDEAD then
                        Print('DEAD!')
                    else
                        Print('ALIVE!')
                    end
                    return ISDEAD
                end

                -- returns the number of entries in a table
                local function GetTableLng(tbl)
                local getN = 0
                for n in pairs(tbl) do
                    getN = getN + 1
                end
                return getN
                end

                -- disables the respawn screen
                local function fixCamera()
                    workspace.CurrentCamera:Destroy()
                    task.wait()
                    workspace.CurrentCamera.CameraSubject = getSpeaker().Character.Humanoid
                end

                local function respawnWait()
                    while not noHealth(getSpeaker()) and _G["ENABLED"] do
                        getSpeaker().Character:BreakJoints()
                        heartbeat()
                        task.wait(0.5)
                        Print("WAITING FOR DEATH!")
                    end
                    while noHealth(getSpeaker()) and _G["ENABLED"] do
                        task.wait(0.5)
                        heartbeat()
                        task.spawn(function()
                            local deathGui = getSpeaker().PlayerGui:FindFirstChild("DeathGUI")
                            if deathGui then
                                local respawnButton = deathGui.Frame.Frame2:FindFirstChild("RespawnButton")
                                for _, connection in pairs(getconnections(respawnButton.MouseButton1Down)) do
                                    connection:Fire()
                                    break
                                end
                                Print("RESPAWNING!")
                            else
                                Print("WAITING FOR RESPAWN GUI!")
                            end
                        end)
                    end
                    Print("RESPAWNED!")
                end

                -- infinite yield sFLY
                local sFLY = LPH_JIT(function()
                    local Players = game:GetService("Players")
                    repeat wait() heartbeat() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

                    local t = getTorso(getSpeaker())
                    local CONTROL = {G = 0, U = 0, E = 0, S = 0, T = 0, EKEY = 0}
                    local lCONTROL = {G = 0, U = 0, E = 0, S = 0, T = 0, EKEY = 0}
                    local SPEED = 0

                    local function FLY()
                        FLYING = true
                        local BG = Instance.new('BodyGyro')
                        local BV = Instance.new('BodyVelocity')
                        BG.P = 9e4
                        BG.Parent = t
                        BG.Name = random
                        BV.Parent = t
                        BV.Name = random
                        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                        BG.cframe = t.CFrame
                        BV.velocity = Vector3.new(0, 0, 0)
                        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
                        task.spawn(function()
                            repeat wait()
                                if CONTROL.E + CONTROL.S ~= 0 or CONTROL.G + CONTROL.U ~= 0 or CONTROL.T + CONTROL.EKEY ~= 0 then
                                    SPEED = 50
                                elseif not (CONTROL.E + CONTROL.S ~= 0 or CONTROL.G + CONTROL.U ~= 0 or CONTROL.T + CONTROL.EKEY ~= 0) and SPEED ~= 0 then
                                    SPEED = 0
                                end
                                if (CONTROL.E + CONTROL.S) ~= 0 or (CONTROL.G + CONTROL.U) ~= 0 or (CONTROL.T + CONTROL.EKEY) ~= 0 then
                                    BV.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (CONTROL.G + CONTROL.U)) + ((workspace.CurrentCamera.CFrame * CFrame.new(CONTROL.E + CONTROL.S, (CONTROL.G + CONTROL.U + CONTROL.T + CONTROL.EKEY) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                                    lCONTROL = {G = CONTROL.G, U = CONTROL.U, E = CONTROL.E, S = CONTROL.S}
                                elseif (CONTROL.E + CONTROL.S) == 0 and (CONTROL.G + CONTROL.U) == 0 and (CONTROL.T + CONTROL.EKEY) == 0 and SPEED ~= 0 then
                                    BV.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (lCONTROL.G + lCONTROL.U)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lCONTROL.E + lCONTROL.S, (lCONTROL.G + lCONTROL.U + CONTROL.T + CONTROL.EKEY) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                                else
                                    BV.velocity = Vector3.new(0, 0, 0)
                                end
                                if settings["velocityMethod"] == "Lock orientation" then
                                    BG.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position)
                                else
                                    BG.CFrame = workspace.CurrentCamera.CFrame
                                end
                            until not FLYING
                            CONTROL = {G = 0, U = 0, E = 0, S = 0, T = 0, EKEY = 0}
                            lCONTROL = {G = 0, U = 0, E = 0, S = 0, T = 0, EKEY = 0}
                            SPEED = 0
                            BG:Destroy()
                            BV:Destroy()
                        end)
                    end
                    flyKeyDown = Players.LocalPlayer:GetMouse().KeyDown:Connect(function(KEY)
                        local flyspeed = settings["flySpeed"]
                        if KEY:lower() == 'w' then
                            CONTROL.G = flyspeed
                        elseif KEY:lower() == 's' then
                            CONTROL.U = -flyspeed
                        elseif KEY:lower() == 'a' then
                            CONTROL.E = -flyspeed
                        elseif KEY:lower() == 'd' then
                            CONTROL.S = flyspeed
                        elseif KEY:lower() == 'e' then
                            CONTROL.T = flyspeed*2
                        elseif KEY:lower() == 'q' then
                            CONTROL.EKEY = -flyspeed*2
                        end
                        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
                    end)
                    flyKeyUp = Players.LocalPlayer:GetMouse().KeyUp:Connect(function(KEY)
                        if KEY:lower() == 'w' then
                            CONTROL.G = 0
                        elseif KEY:lower() == 's' then
                            CONTROL.U = 0
                        elseif KEY:lower() == 'a' then
                            CONTROL.E = 0
                        elseif KEY:lower() == 'd' then
                            CONTROL.S = 0
                        elseif KEY:lower() == 'e' then
                            CONTROL.T = 0
                        elseif KEY:lower() == 'q' then
                            CONTROL.EKEY = 0
                        end
                    end)
                    FLY()
                end)

                -- infinite yield invisfling
                local function invisFling(speaker)
                    local root = getTorso(speaker)
                    -- for i,v in pairs(speaker.Character:GetChildren()) do
                    --     if v ~= root and  v.Name ~= "Humanoid" then
                    --         v:Destroy()
                    --     end
                    -- end
                    sFLY()
                    workspace.CurrentCamera.CameraSubject = root
                    _G['VELOCITY'] = true
                end
                    
                -- self explanatory
                local function gotoLocation(speaker, location, part)
                    if locationDebug then
                        Print(location)
                    end
                    if typeof(location) == "Vector3" then
                        location = CFrame.new(location)
                    end
                    -- local bodyPosition = getBodyPosition()
                    -- if location ~= nil and bodyPosition then
                    --     bodyPosition.Position = location
                    -- else
                    local torso = part or getTorso(speaker)
                    if torso and location then
                        torso.CFrame = location
                    else
                        Print('NO POSITION!')
                    end
                end

                    -- all the logic for autoFling
                    local function AutoFling(speaker, target, KILLALL, part, flashbackAfter)
                    autoFling = false
                    flashbackAfter = flashbackAfter == nil and true or flashbackAfter
                    part = part or getTorso(speaker)
                    Print("AUTOFLING PART: "..part.Name)
                    if target.Character and target.Character:FindFirstChild("Torso") and speaker.Character:FindFirstChild('FlingPart') and target.Character.Humanoid.Health > 0 then
                        local flashbackLocation = getLocation(getTorso(speaker).CFrame)
                        if not KILLALL then
                            lib:Notify({
                                Title = "AutoFling",
                                Content = "AutoFling is starting",
                                Duration = 3,
                            })
                        end
                        -- variables defined at the start persist through frames
                        local rubberBand = settings["minRubberBand"]
                        local rot = 0
                        local dead
                        local frames = 0
                        local V2pos
                        local V2vel
                        local V2tick = tick()
                        local V2mod = 1
                        local V3old
                        local V3tween
                        local historicPositions = {}

                        local function flashback()
                            if flashbackAfter then
                                gotoLocation(speaker, flashbackLocation)
                            end
                        end

                        -- function that gets the possition of head or torso depending on what flingPart is being used
                        local function getTargetLoc(velocity)
                            if not velocity then
                                return getRoot(target.Character).Position
                            else
                                return getRoot(target.Character).Velocity
                            end
                        end

                        -- returns a possition that the target is heading to
                        local function predict()
                            local latency = speaker:GetNetworkPing() -- fetch localplayer ping
                            if rubberBand > settings["maxRubberBand"] then
                                rubberBand = settings["minRubberBand"] -- reset rubber band
                            else
                                rubberBand = rubberBand + 0.03 -- increment rubber band
                            end
                            latency = latency*2 -- multiply latency to account for server to target latency
                            local pos = getTargetLoc() -- get target location
                            local vel = getTargetLoc(true) * settings["predictionOffset"] -- get velocity and add offset
                            vel = vel*rubberBand -- apply rubber banding
                            local yVector = vel.Y
                            if not settings["verticalPrediction"] then
                                yVector = 0
                            end
                            vel = Vector3.new(vel.X, yVector, vel.Z) -- remove y velocity
                            local newPos = pos + vel*latency -- create new possition and apply latency
                            return newPos
                        end

                        -- differences are below
                        -- uses a static PING for the target
                        -- circle detection
                        -- increased rubberband increment and randomized
                        local function predictV2()
                            if not V2pos then
                                V2pos = getTargetLoc()
                            end
                            if not V2vel then
                                V2vel = getTargetLoc(true).magnitude
                            end
                            -- check if frames is a multiple of 60
                            if frames%60 == 0 and frames ~= 0 then
                                local diff = V2pos - getTargetLoc()
                                local distance = diff.magnitude
                                local elapsedtime = tick() - V2tick
                                local expected = V2vel * elapsedtime
                                local comparison = distance/expected
                                if comparison < settings["circleSensitivity"] then
                                    V2mod = comparison
                                else
                                    V2mod = 1
                                end
                                Print('V2 MODIFIER: '..V2mod)
                                V2pos = getTargetLoc()
                                V2vel = getTargetLoc(true).magnitude
                                V2tick = tick()
                            end
                            local latency = speaker:GetNetworkPing() -- fetch localplayer ping
                            if rubberBand > settings["maxRubberBand"] then
                                rubberBand = settings["minRubberBand"] -- reset rubber band
                            else
                                rubberBand = rubberBand + math.random(10, 50) / 300 -- increment rubber band
                            end
                            latency = latency*2 -- add target latency
                            local pos = getTargetLoc() -- get target location
                            local vel = getTargetLoc(true)*settings["predictionOffset"] -- get velocity and add offset
                            vel = vel*rubberBand -- apply rubber banding
                            vel = vel*V2mod -- apply circle detection
                            local yVector = vel.Y
                            if not settings["verticalPrediction"] then
                                yVector = 0
                            end
                            vel = Vector3.new(vel.X, yVector, vel.Z) -- remove y velocity
                            local newPos = pos + vel*latency -- create new possition and apply latency
                            return newPos
                        end

                        local function predictV3()
                            if not V2pos then
                                V2pos = getTargetLoc()
                            end
                            if not V2vel then
                                V2vel = getTargetLoc(true).magnitude
                            end
                            -- check if frames is a multiple of 60
                            if frames%60 == 0 and frames ~= 0 then
                                local diff = V2pos - getTargetLoc()
                                local distance = diff.magnitude
                                local elapsedtime = tick() - V2tick
                                local expected = V2vel * elapsedtime
                                local comparison = distance/expected
                                if comparison < settings["circleSensitivity"] then
                                    V2mod = comparison
                                else
                                    V2mod = 1
                                end
                                Print('V3 MODIFIER: '..V2mod)
                                V2pos = getTargetLoc()
                                V2vel = getTargetLoc(true).magnitude
                                V2tick = tick()
                            end
                            local latency = speaker:GetNetworkPing() -- fetch localplayer ping
                            if rubberBand > settings["maxRubberBand"] then
                                rubberBand = settings["minRubberBand"] -- reset rubber band
                            else
                                rubberBand = rubberBand + math.random(10, 50) / 300 -- increment rubber band
                            end
                            latency = latency*2 -- add target latency
                            local pos = getTargetLoc() -- get target location
                            local vel = getTargetLoc(true) * settings["predictionOffset"] -- get velocity and add offset
                            vel = vel*rubberBand -- apply rubber banding
                            vel = vel*V2mod -- apply circle detection
                            local yVector = vel.Y
                            if not settings["verticalPrediction"] then
                                yVector = 0
                            end
                            vel = Vector3.new(vel.X, yVector, vel.Z) -- remove y velocity
                            local newPos = pos + vel*latency -- create new possition and apply latency
                            -- raycast from target to new possition, if there is a wall, then the new possition is 2/3 of the way to the wall
                            local params =  RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            params.FilterDescendantsInstances = {game:GetService('Workspace').Characters}
                            local ray = game:GetService('Workspace'):Raycast(target.Character.Torso.Position, newPos-target.Character.Torso.Position, params)
                            if ray then
                                local diff = ray.Position - target.Character.Torso.Position
                                newPos = target.Character.Torso.Position + diff*2/3
                            end
                            -- local TweenService = game:GetService('TweenService')
                            -- local tween = TweenService:Create(part, TweenInfo.new(0.1), {Position = newPos})
                            -- tween:Play()
                            -- V3tween = tween
                            local old = V3old
                            V3old = newPos
                            return old
                        end
                        
                        -- prediction but calculates the average turn rate over the historic positions
                        local function predictV4()
                            local latency = speaker:GetNetworkPing() * 2

                            if rubberBand > settings["maxRubberBand"] then
                                rubberBand = settings["minRubberBand"]
                            else
                                rubberBand = rubberBand + 0.03 -- increment rubber band
                            end

                            local pos = getTargetLoc()

                            local vel = getTargetLoc(true) * settings["predictionOffset"] * rubberBand

                            local yVector = vel.Y
                            if not settings["verticalPrediction"] then
                                yVector = 0
                            end

                            vel = Vector3.new(vel.X, yVector, vel.Z) -- remove y velocity

                            local direction = vel.Unit
                            vel = vel.Magnitude

                            -- calculate the curve of the historic positions
                            local curve = 0
                            
                        end
                        

                        -- returns the next frame in a orbit around the target
                        local function orbit(position)
                            if position == nil then
                                position = getTargetLoc()
                            end
                            local ORBIT_TIME = settings["orbitSpeed"]
                            local RADIUS = settings["orbitRadius"] -- how far the orbit is
                            local ECLIPSE = 1 -- ranges from 0 to 1, perfect circle if 1
                            local ROTATION = CFrame.Angles(0,0,0) --rotate which direction to rotate around
                            local sin, cos = math.sin, math.cos
                            local ROTSPEED = math.pi*2/ORBIT_TIME
                            ECLIPSE = ECLIPSE * RADIUS
                            rot = rot + wait() * ROTSPEED
                            if target.Character:FindFirstChild('Torso') then
                                local newPos = ROTATION * Vector3.new(sin(rot)*ECLIPSE, 0, cos(rot)*RADIUS) + position
                                return newPos
                            else
                                return Vector3.new(0,0,0)
                            end
                        end

                        -- randomizes possition within a radius, does not randomize y axis
                        local function randomize(frame, range)
                            return frame + Vector3.new(math.random(-range, range), 0, math.random(-range, range))
                        end

                        -- mainloop for autofling
                        while true do
                            if _G['ENABLED'] and not noHealth(getSpeaker()) then
                                if getTorso(speaker) and target.Character then
                                    if target.Character:FindFirstChild('Torso') then
                                        if target.Character.Torso.Velocity.magnitude < settings["maxVelocity"] then
                                            local newPos
                                            if settings["autoFlingType"] == 'Normal' then
                                                newPos = getTargetLoc()
                                            elseif settings["autoFlingType"] == 'Predictive' then
                                                newPos = predict()
                                            elseif settings["autoFlingType"] == 'V2 Prediction' then
                                                newPos = predictV2()
                                            elseif settings["autoFlingType"] == 'V3 Prediction' then
                                                newPos = predictV3()
                                            elseif settings["autoFlingType"] == 'V4 Prediction' then
                                                newPos = predictV4(settings["predictionDegree"])
                                            elseif settings["autoFlingType"] == 'Random' then
                                                newPos = randomize(getTargetLoc(), settings["randomRadius"])
                                            elseif settings["autoFlingType"] == 'Predictive Random' then
                                                newPos = randomize(predict(), settings["randomRadius"])
                                            elseif settings["autoFlingType"] == 'Orbit' then
                                                newPos = orbit()
                                            elseif settings["autoFlingType"] == "Predictive Orbit" then
                                                newPos = orbit(predict())
                                            end
                                            if _G["POSITIONDEBUG"] then
                                                Print("POSITION: "..tostring(newPos))
                                            end
                                            if _G["MAGNITUDEDEBUG"] then
                                                Print("MAGNITUDE: ".. tostring((newPos - getTargetLoc()).Magnitude))
                                            end
                                            if _G["MAGNITUDEDEBUG2"] then
                                                Print("MAGNITUDE DIFF: "..tostring((newPos - getTorso(speaker).Position).Magnitude))
                                            end
                                            if settings["targetCamera"] and target.Character:FindFirstChild('Head') then
                                                -- focus camera on target
                                                local cam = workspace.CurrentCamera
                                                cam.CameraSubject = target.Character.Head
                                            end
                                            -- convert vector3 to cframe
                                            if typeof(newPos) == 'Vector3' then
                                                newPos = CFrame.new(newPos)
                                            end
                                            gotoLocation(speaker, newPos, part)
                                        elseif settings["autoFlingType"] == 'Orbit' then
                                            wait()
                                        end
                                    else
                                        dead = true
                                    end
                                else
                                    lib:Notify({
                                        Title = "AutoFling",
                                        Content = "Target or player does not exist",
                                        Duration = 3,
                                    })
                                    if not getTorso(speaker) then
                                        if V3tween then
                                            V3tween:Cancel()
                                        end
                                        return 2
                                    else
                                        flashback()
                                        if V3tween then
                                            V3tween:Cancel()
                                        end
                                        return 1
                                    end
                                end
                            else
                                if V3tween then
                                    V3tween:Cancel()
                                end
                                return 2
                            end
                            if noHealth(target) or dead then
                                lib:Notify({
                                    Title = "AutoFling",
                                    Content = target.Name..' Was successfully flung!',
                                    Duration = 3,
                                })
                                flashback()
                                local function submitKill()
                                    if not wlv2 or not wlv2.key or not settings["killFeed"] then
                                        return
                                    end
                                    local killed = target.Name
                                    local serverCode = game:GetService("ReplicatedStorage").Values.ServerId.Value
                                    local url = 'https://guest.gay/fling/kill'
                                    local headers = {
                                        ['Content-Type'] = 'application/json',
                                        ['sender'] = "Fling",
                                        ['key'] = wlv2.key,
                                        ['server'] = serverCode,
                                        ['killed'] = killed
                                    }
                                    local payload = {
                                        Url = url,
                                        Body = game:GetService('HttpService'):JSONEncode({}),
                                        Method = "POST",
                                        Headers = headers
                                    }
                                    local request = http_request or request or HttpPost or syn.request
                                    local response = request(payload)
                                end
                                task.spawn(submitKill)
                                if V3tween then
                                    V3tween:Cancel()
                                end
                                return 0
                            end
                            heartbeat()
                            if settings["autoFlingType"] ~= 'Orbit' then
                                game:GetService('RunService').Heartbeat:Wait()
                            end
                            local frameLimit = settings["autoFlingFrames"]
                            if KILLALL then
                                frameLimit = settings["killAllTime"]
                            end
                            if frameLimit == 0 or frameLimit == nil then
                                frameLimit = math.huge
                            end
                            if frames > frameLimit then
                                break
                            else
                                frames = frames + 1
                            end
                            if autoFlingCancel then
                                task.defer(function()
                                    autoFlingCancel = false
                                end)
                                break
                            end
                            if settings["skipProtected"] and target.Character and target.Character:FindFirstChildOfClass('ForceField') then
                                break
                            end
                        end
                        flashback()
                        workspace.CurrentCamera.CameraSubject = getTorso(speaker)
                    else
                        lib:Notify({
                            Title = "AutoFling",
                            Content = "Target does not exist or is dead",
                            Duration = 3,
                        })
                        if not speaker.Character:FindFirstChild('Torso') then
                            return 2
                        else
                            return 1
                        end
                    end
                end

                -- attempt to kill all players in the game
                local function masacare(speaker, PKillAll)
                    killAll = false
                    local killCount = 0
                    local failed = false
                    for _,target in pairs(game:GetService('Players'):GetPlayers()) do
                        if target.Name ~= speaker.Name then
                            -- AutoFling can return: 0 = target was killed, 1 = target was not found, 2 = speaker was not found, abort on 2
                            local result = AutoFling(speaker, target, true)
                            if result == 0 then
                                killCount = killCount + 1
                            elseif result == 2 then
                                failed = true
                            end
                        end
                        if failed then
                            lib:Notify({
                                Title = "AutoFling",
                                Content = "KillAll is exiting because player does not exist",
                                Duration = 3,
                            })
                            break
                        end
                    end
                    local playerCount = #game:GetService('Players'):GetPlayers()
                    lib:Notify({
                        Title = "AutoFling",
                        Content = 'Killed ' .. killCount .. '/' .. playerCount .. ' players',
                        Duration = 3,
                    })
                end

                local function seeIfLooked()
                    
                    local closestPlayer = nil
                    local closestDistance = math.huge
                    local players = game:GetService("Players")
                    local Character = getSpeaker().Character
                    local flingPartPosition = Character:FindFirstChild('FlingPart').Position

                    for _, player in ipairs(players:GetPlayers()) do
                        if player ~= players.LocalPlayer then

                            local character = player.Character
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart then
                                local distance = (humanoidRootPart.Position - flingPartPosition).Magnitude

                                if distance < settings['KillCreeps'] then
                                    local flingPart = getTorso(getSpeaker())
                                    local flingPartLookVector = flingPart.CFrame.LookVector
                                    local targetLookVector = humanoidRootPart.CFrame.LookVector

                                    if flingPartLookVector:Dot(targetLookVector) < -0.5 then 
                                        if distance < closestDistance then

                                            closestDistance = distance
                                            closestPlayer = player
                                        end
                                    end
                                end
                            end
                        end
                    end

                    if closestPlayer then
                        AutoFling(getSpeaker(), closestPlayer)
                    end
                end

            local function checkForPeopleInMag()

                local closestPlayer = nil
                local closestDistance = math.huge
                local players = game:GetService("Players")
                local Character = getSpeaker().Character
                local flingPartPosition = Character:FindFirstChild('FlingPart').Position

                for _, player in ipairs(players:GetPlayers()) do
                    if player ~= players.LocalPlayer then
                        local character = player.Character
                        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                        if humanoidRootPart then
                            local distance = (humanoidRootPart.Position - flingPartPosition).Magnitude
                            print(distance)
                            if distance < settings['KillAuraMagnitude'] then
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                    print(closestPlayer)
                                end
                            end
                        end
                    end
                end

                if closestPlayer then
                    AutoFling(getSpeaker(), closestPlayer)
                end
            end

                local disperse
                disperse = function(speaker)
                    if _G["DISPERSERATELIMIT"] > tick() and LPH_OBFUSCATED then
                        lib:Notify({
                            Title = "Cooldown",
                            Content = "You can only use this feature every 2 minutes",
                            Duration = 3,
                        })
                        disperseToggle = false
                        return
                    else
                        _G["DISPERSERATELIMIT"] = tick() + 60 * 2
                    end
                    disperseToggle = false
                    _G["LIMBLOCK"] = false
                    local targetedPlayers = {}
                    local originalValue = defaultSetting(true, 'targetCamera') -- // why is rayfield so stinky
                    save('targetCamera', false)
                    statusGood = false
                    local targetedPlayers = {}
                    for _,limb in pairs(getLimbs(speaker)) do
                        if limb then
                            local nearestPlayer = getNearestPlayer(speaker, targetedPlayers)
                            limb.Transparency = 0.99
                            local highlight = Instance.new("Highlight", limb)
                            if nearestPlayer then
                                targetedPlayers[nearestPlayer] = true
                                task.defer(function(player, limb)
                                    local status, err = pcall(function()
                                        AutoFling(speaker, player, true, limb, false)
                                    end)
                                    targetedPlayers[player] = nil
                                    highlight:Destroy()
                                    limb.Transparency = 1
                                    if not status then
                                        Print('ERROR: '..err)
                                    end
                                end, nearestPlayer, limb)
                            end
                        end
                    end
                    repeat task.wait() until GetTableLng(targetedPlayers) == 0
                    statusGood = true
                    _G["LIMBLOCK"] = true
                    disperseToggle = false
                    save('targetCamera', originalValue)
                end

                --[[local function checkAvatar()
                    if LPH_OBFUSCATED then
                        if getSpeaker() then
                            local humanoidDescription = Character:FindFirstChild("HumanoidDescription")
                            if humanoidDescription then
                                local Kick = false
                                for _, v in ipairs(humanoidDescription.BodyParts) do
                                    if v ~= 0 then
                                        Kick = true
                                        break
                                    end
                                end
                                if Kick then
                                    getSpeaker():Kick("Non-blocky avatar detected || Equip a blocky avatar to use the script")
                                end
                            end
                        end
                    end
                end]]--

                local function checkAdmin(plr)
                    local groupName = ""
                    if plr:GetRankInGroup(4165692) > 1 then
                        groupName = groupName .. "Group 1 - Main Group"
                    end
                    if plr:GetRankInGroup(32406137) > 0 then
                        groupName = groupName .. "Group 2 - Mod Group"
                    end
                    if groupName ~= "" then

                        local gui = Instance.new("ScreenGui")
                        gui.DisplayOrder = 999999999
                        
                        local text = Instance.new("TextLabel")

                        text.BackgroundColor3 = Color3.fromRGB(41,41,41)
                        text.BorderSizePixel = 0
                        text.BackgroundTransparency = .2
                        text.Position = UDim2.new(0, 0, 0, 0)
                        text.AnchorPoint = Vector2.new(0, 0)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.Text = "Admin detected: "..plr.Name.." | Method: 1 | "..groupName.. " | PLEASE DO NOT LEAVE THE GAME. DISABLE FLING IMMEDIATELY"
                        text.TextColor3 = Color3.fromRGB(255, 0, 0)
                        text.TextScaled = true
                      
                        text.Parent = gui
                        gui.Parent = game:GetService("CoreGui")

                        wait(45)
                        gui.Enabled = false
                    end
                    plr.ChildAdded:Connect(function(child)
                        if child:IsA("SurfaceGui") then

                            local gui = Instance.new("ScreenGui")
                            gui.DisplayOrder = 999999999
                            
                            local text = Instance.new("TextLabel")
                            
                            text.BackgroundColor3 = Color3.fromRGB(41,41,41)
                            text.BorderSizePixel = 0
                            text.BackgroundTransparency = .2
                            text.Position = UDim2.new(0, 0, 0, 0)
                            text.AnchorPoint = Vector2.new(0, 0)
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.Text = "Admin detected: "..plr.Name.." | Method: 2 | PLEASE DO NOT LEAVE THE GAME. DISABLE FLING IMMEDIATELY"
                            text.TextColor3 = Color3.fromRGB(255, 0, 0)
                            text.TextScaled = true
                            
                            text.Parent = gui
                            gui.Parent = game:GetService("CoreGui")
                            
                            wait(45)
                            gui.Enabled = false
                        end
                    end)
                end
                
                if not _G['ALREADYEXEC'] then
                    for _, player in ipairs(game.Players:GetPlayers()) do
                        task.spawn(checkAdmin, player)
                    end
                    game.Players.PlayerAdded:Connect(checkAdmin)

                    _G['ALREADYEXEC'] = true
                end
                -- check if player is dead
                if isDead(getSpeaker()) or noHealth(getSpeaker()) then
                    lib:Notify({
                        Title = "Dead",
                        Content = "Respawning before executing...",
                        Duration = 3,
                    })
                    heartbeat()
                end

                -- mainloop
                while _G['ENABLED'] do
                    oldPos = getRoot(getSpeaker().Character).CFrame
                    _G["LIMBLOCK"] = true
                    _G["RAGDOLL"] = true
                    applyCameraEffects()
                    destroyParts(getSpeaker()) 
                    applyAnimation(getSpeaker())
                    applyCharacterModifications(getSpeaker())
                    invisFling(getSpeaker())
                    wait(0.4)
                    applySoundChecks() -- // this is useless since you cannot destroy the sound you make when you get ragdolled because of https://devforum.roblox.com/t/action-required-workspacerejectcharacterdeletions/2196175
                    gotoLocation(getSpeaker(), pos)
                    while not noHealth(getSpeaker()) and _G['ENABLED'] do
                        tryProtectCube()
                        seeIfLooked()
                        checkForPeopleInMag()
                        Print("ALIVE!")
                        workspace.CurrentCamera.CameraSubject = getTorso(getSpeaker())
                        pos = getLocation(pos)
                        destroyParts(getSpeaker())
                        if locationDebug then
                            Print(pos)
                        end
                        heartbeat()
                        if autoFling then
                            if targetPlayer then
                                if targetPlayer.Name ~= getSpeaker().Name then
                                    AutoFling(getSpeaker(), targetPlayer)
                                    autoFling = false
                                else
                                    autoFling = false
                                    for _ = 1, 30 do
                                        wait()
                                        heartbeat()
                                        notify('Retard', 'This bozo actually tried to fling himself')
                                    end
                                end
                            else
                                autoFling = false
                                lib:Notify({
                                    Title = "Error",
                                    Content = "No target selected",
                                    Duration = 3
                                })
                            end
                        end
                        if killAll then
                            masacare(getSpeaker())
                        end
                        if disperseToggle then
                            disperse(getSpeaker())
                        end
                        if _G['DESPAWNSIMULATE'] then
                            getSpeaker().Character:Destroy()
                            _G['DESPAWNSIMULATE'] = false
                        end
                        task.wait(1)
                    end
                    -- wait for respawn to finish
                    if _G['ENABLED'] then
                        limbCacheLastUpdated = 0
                        destroyFlingParts(getSpeaker())
                        getSpeaker().Character:BreakJoints()
                        lib:Notify({
                            Title = "Respawning",
                            Content = 'Body has despawned, automatically re-applying invisfling...',
                            Duration = 6.5
                        })
                        _G["RAGDOLL"] = false
                        _G["LIMBLOCK"] = false
                        respawnWait()
                        task.wait(1)
                    end
                    removeCameraEffects()
                end
                -- if the script is disabled, dissable the noclip loop
                workspace.CurrentCamera.CameraSubject = getSpeaker().Character.Humanoid
                pcall(function() game:GetService('Workspace').CurrentCamera.CameraType = Enum.CameraType.Track end)
                cleanUp()
                removeCameraEffects()
                Print('DISABLED!')
                lib:Notify({
                    Title = "Disabled",
                    Content = "Fling has been disabled!",
                    Duration = 3
                })
                task.wait(2)
                limbCacheLastUpdated = 0
                if not noHealth(getSpeaker()) then
                    local difference = getRoot(getSpeaker().Character).Position - oldPos.Position
                    local root = getRoot(getSpeaker().Character)
                    local flingPart = getTorso(getSpeaker())
                    flingPart.CFrame = root.CFrame + Vector3.new(0, 15, 0)
                    if difference.magnitude < 20 then
                        root.CFrame = oldPos
                    else
                        root.CFrame = root.CFrame + Vector3.new(0, 15, 0)
                    end
                end
                destroyFlingParts(getSpeaker())
            else
                task.wait()
                heartbeat()
            end
        end
    else
        notify('Error', 'Script is already running!')
        Print('ALREADY ACTIVE, RE-EXECUTING CAUSES BUGS!')
    end
end

jinja.run[[ endblock ]]
