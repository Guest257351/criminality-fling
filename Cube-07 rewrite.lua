LPH_NO_VIRTUALIZE = function(...) return ... end
LPH_JIT = function(...) return ... end
LPH_JIT_MAX = function(...) return ... end
LPH_OBFUSCATED = false

jinja={run=function()end,var=function()end}
jinja.run[[ extends "templates/whitelist.lua" ]]

jinja.run[[ block program]]
local program = "Fling"
jinja.run[[ endblock ]]

jinja.run[[ block script ]]
--[[

  __  __           _        ____          ______ _ _             _             _ _ _         
 |  \/  |         | |      |  _ \        |  ____| (_)           (_)           | (_| |        
 | \  / | __ _  __| | ___  | |_) |_   _  | |__  | |_ _ __   __ _ _ _ __   __ _| |_| |_ _   _ 
 | |\/| |/ _` |/ _` |/ _ \ |  _ <| | | | |  __| | | | '_ \ / _` | | '_ \ / _` | | | __| | | |
 | |  | | (_| | (_| |  __/ | |_) | |_| | | |    | | | | | | (_| | | | | | (_| | | | |_| |_| |
 |_|  |_|\__,_|\__,_|\___| |____/ \__, | |_|    |_|_|_| |_|\__, |_|_| |_|\__,_|_|_|\__|\__, |
                                   __/ |                    __/ |                       __/ |
                                  |___/                    |___/                       |___/ 

Intellectual Property (IP) protected under Digital Millenium Copyright Act (DMCA)

]]--
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local eventsFolder = ReplicatedStorage:WaitForChild("Events")

local radgollModule = eventsFolder["__DFfDD"]

local camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local localCharacter = localPlayer.Character or localPlayer["CharacterAdded"]:Wait() and localPlayer.Character
local localHumanoid = localCharacter:WaitForChild("Humanoid")
local localRoot = localCharacter:WaitForChild("HumanoidRootPart")
local localHead = localCharacter:FindFirstChild("Head")
local localTorso = localCharacter:FindFirstChild("Torso")
local charactersFolder = workspace:WaitForChild("Characters")

local limbsArray = {
    localCharacter:WaitForChild("Right Arm"),
    localCharacter:WaitForChild("Left Arm"),
    localCharacter:WaitForChild("Right Leg"),
    localCharacter:WaitForChild("Left Leg"),
}

local tweenInfo = {
    AdminFadeOut = TweenInfo.new(
        .5,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )
}

local isLocalPlayerAlive = true

local currentTarget = {}
local settings = {}

local _debug = false
local _dontUseConfigFile = false

local flingCube
local flingCubeHighlight
local flingCubePosition

local pumpkinStinkAnimation

local fling, get, redPing, connections, logs, handler, fileSys, GUI -- //Table stuff

local scriptEnabled
--\\
do
    scriptEnabled = shared["Cube-07Enabled"]

    if scriptEnabled then
        shared["Cube-07Enabled"] = false
    end

    task.wait(1)

    scriptEnabled = true
    shared["Cube-07Enabled"] = true
end
--//

local safeProperties = {
    FlingTarget = {Target = "Model"}
}

local function generateTween(inst, tweenInfoIndex, properties)
    return TweenService:Create(inst, tweenInfo[tweenInfoIndex], properties)
end

local function verifyPropertiesValues(dictionary, safePropertiesIndex)
	local safePropertiesDict = safeProperties[safePropertiesIndex]

	local errorMessage

	if not dictionary then
        errorMessage = logs:ErrorLog("NoProperties", safePropertiesIndex)
	elseif typeof(dictionary) ~= "table" then
        errorMessage = logs:ErrorLog("InvalidPropertiesTypeOf", safePropertiesIndex, "table", typeof(dictionary))
	end

	for index, value in safePropertiesDict do
		local dictionaryValue = dictionary[index]

		if not index then
            errorMessage = logs:ErrorLog("NilProperty", safePropertiesIndex, index)
		else
			local dictValueTypeOf = typeof(dictionaryValue)

			if dictValueTypeOf ~= value then
                if dictValueTypeOf ~= "Instance" or not dictionaryValue:IsA(value) then
                    logs:ErrorLog("InvalidPropertyValue", safePropertiesIndex, index, value, dictValueTypeOf)
                end
			end
		end
	end

	if errorMessage then
		return false, errorMessage
	else
		return true
	end
end

local function verifyPassedProperties(dictionary, funcIndex)
	local success, _error = verifyPropertiesValues(dictionary, funcIndex)

	if not success then
		logs:ErrorLog(funcIndex, _error)
	end
end

local function loadLog(table_, tableIndex)
    table_.mt = {}

    setmetatable(table_, table_.mt)

    setmetatable(table_, {
        __newindex = function(tablIndex, index, func)
            if not func then
                return
            end

            rawset(tablIndex, index, func)

            logs:LogMessage("SubLoaded", index, tableIndex)
        end
    })
end

local function initializeLogging()
    local tableIndex = "Logging"

    do
        logs = {}

        if _debug then
            loadLog(logs, tableIndex)
        end
    end

    local dateTime = DateTime.now()
    local currentTime = dateTime:FormatLocalTime("LTS L", "en_us")

    local prefix = "Cube-07"

    local messages = {
        SubLoaded = prefix .. " :: %s under %s loaded!",
        Loaded = prefix .. " :: %s loaded!",
        GEFoundPlayer = prefix .. " :: Found player: %s.",
        FlingStarted = prefix .. " :: Fling started running on: %s",
        Respawning = prefix .. " :: Trying to respawn...",
        AddedConnection = prefix .. " :: Added connection: %s.",
        DisconnectedConnection = prefix .. " :: Disconnected connection: %s.",
        DisconnectedAll = prefix .. " :: Disconnected %s connections.",
        FirstTimeConfig = prefix .. " :: Config doesn't exist, generating..."
    }

    local errorMessages = {
        NoProperties = prefix .. " :: %s :: No properties table passed.",
        InvalidPropertiesTypeOf = prefix .. " :: %s :: Expect properties %s, got: %s",
        NilProperty = prefix .. " :: %s :: Property: %s not found.",
        InvalidPropertyValue = prefix .. " :: %s :: Invalid property %s value expected: %s got: %s"
    }

    local function generateMessage(messageType, messageIndex, ...)
        if messageType == "error" then
            return string.format(currentTime .. " " .. errorMessages[messageIndex], ...) -- // timestamps
        else
            return string.format(currentTime .. " " .. messages[messageIndex], ...) -- // timestamps
        end
    end
    
    local function generateErrorMessage(messageIndex, ...)
        return string.format(currentTime .. " " .. messages[messageIndex], ...) -- // timestamps
    end

    function logs:StartBigLog()
        local inbetweenLine = string.rep("⸻", 23)

        local desiredText = {
            "",
            inbetweenLine,
            "Start of logs " .. currentTime .. ".",
            inbetweenLine
        }

        print(table.concat(desiredText, "\n"))
    end

    function logs:LogMessage(messageIndex, ...)
        print(generateMessage("Message", messageIndex, ...))
    end

    function logs:ErrorMessage(messageIndex, ...)
        warn(generateErrorMessage("error", messageIndex, ...))
    end

    do -- //Post loading
        logs:StartBigLog()
    end
end

local function initializeConnections()
    local tableIndex = "Connections"

    do
        connections = {}

        if _debug then
            loadLog(connections, tableIndex)
        end
    end

    local connectionsData = {}

    local function onCharacterAdded(player, character)
        -- //Do other players stuff here
    end

    local function onPlayerAdded(player)
        local isAdmin, groupType = handler:IsAdmin(player)

        if isAdmin then
            handler:ProcessAdmin(player, groupType, true)
        end

        player["CharacterAdded"]:Connect(onCharacterAdded)
    end

    function connections:Add(index, connection)
        if _debug then
            logs:LogMessage("AddedConnection", index)
        end

        connectionsData[index] = connection
    end

    function connections:Disconnect(index)
        if _debug then
            logs:LogMessage("DisconnectedConnection", index)
        end

        connectionsData[index]:Disconnect()
        connectionsData[index] = nil
    end

    function connections:DoesExist(index)
        return connectionsData[index] and true or false
    end

    function connections:DisconnectAll()
        local connectionsAmount = 0

        for _, connection in connectionsData do
            connectionsAmount += 1

            connection:Disconnect()
        end

        logs:LogMessage("DisconnectedAll", tostring(connectionsAmount))
    end

    do -- //Post loading
        connections:Add("LocalCharacterAdded", localPlayer["CharacterAdded"]:Connect(handler.OnLocalCharacterAdded))
        connections:Add("PlayerAdded", Players["PlayerAdded"]:Connect(onPlayerAdded))
        -- //Local

        for _, player in pairs(Players:GetChildren()) do
            if not player:IsA("Player") then
                continue
            end

            local isAdmin, groupType = handler:IsAdmin(player)

            handler:ProcessAdmin(player, groupType, false)
        end

        logs:LogMessage("Loaded", tableIndex)
    end
end

local function initializeFileSys()
    local tableIndex = "FileSys"

    do
        fileSys = {}

        if _debug then
            loadLog(fileSys, tableIndex)
        end
    end

    local defaultSettings = {
        ["AutoSaving"] = true,
        ["FlingEnabled"] = false,
        ["MultiTargetEnabled"] = false,
        ["FlingStyle"] = "Follow camera",
        ["BodyFlingEnabled"] = false,
        ["BodyFlingKeybind"] = "B",
        ["HideCubeEnabled"] = false,
        ["HideCubeKeybind"] = "H",
        ["KillauraEnabled"] = false,
        ["KillauraKeybind"] = "R",
        ["KillAllEnabled"] = false,
        ["FlySpeed"] = 70,
        ["PredictionType"] = "Advanced",
        ["RayCastPredictionEnabled"] = true,
        ["AutoRubberBandingEnabled"] = true,
        ["MinRubberbanding"] = .1,
        ["MaxRubberbanding"] = 6,
        ["CircleSensitivity"] = .4,
        ["PerlinNoiseMagnitude"] = .05,
        ["PerlinNoiseRotSpeed"] = 10,
        ["KillauraRadius"] = 100,
        ["RandomRadius"] = 5,
        ["OrbitRadius"] = 5,
        ["OrbitSpeed"] = 2,
        ["CubeTransparency"] = .5,
        ["CubeMaterial"] = "ForceField",
        ["HighlightEnabled"] = true,
        ["HighlightTransparency"] = 0,
        ["HighlightMode"] = "Static Mode",
        ["StaticColor"] = Color3.fromRGB(0, 0, 250),
        ["TransitionColor1"] = Color3.fromRGB(238, 68, 182),
        ["TransitionColor2"] = Color3.fromRGB(237, 147, 68)
    }

    local encodedDefaultSettings = HttpService:JSONEncode(defaultSettings)

    local fileName = "Cube-07_Flinginality.gay"

    local saveToFile = true

    function verifyIntegrity()
        if isfile(fileName) then
            return true
        end
    end

    local function generateConfigFile()
        writefile(fileName, encodedDefaultSettings)
    end

    function fileSys:UpdateConfig(index, data, dontSave)
        settings[index] = data

        if saveToFile and dontSave then
            writefile(fileName, HttpService:JSONEncode(settings))
        end
    end

    function fileSys:LoadSettings()
        if not verifyIntegrity() then
            logs:LogMessage("FirstTimeConfig")

            generateConfigFile()

            settings = defaultSettings
        else
            settings = HttpService:JSONDecode(readfile(fileName))

            for i,v in pairs(settings) do
                print(i,v)
            end
        end
    end

    function fileSys.ToggleSaving(state)
        saveToFile = not saveToFile
    end

    do -- //Post loading
        if _dontUseConfigFile then
            settings = defaultSettings
        else
            fileSys:LoadSettings()
        end

        logs:LogMessage("Loaded", tableIndex)
    end
end

local function initializeEnvironment()
    local tableIndex = "GetEnv"

    do
        get = {}

        if _debug then
            loadLog(get, tableIndex)
        end
    end

    local perlinNoiseArray = {}

    local adminNotifUI = {}
    local adminNotificationContainer = Instance.new("ScreenGui")
    local textLabel = Instance.new("TextLabel")

    local uiCorner = Instance.new("UICorner", textLabel)
    local uiPadding = Instance.new("UIPadding")

    adminNotificationContainer.DisplayOrder = 9e99
    adminNotificationContainer.Parent = CoreGui

    textLabel["TextWrapped"] = true
    textLabel["TextStrokeTransparency"] = 0.6100000143051147
    textLabel["BorderSizePixel"] = 0
    textLabel["TextScaled"] = true
    textLabel["BackgroundColor3"] = Color3.fromRGB(0, 0, 0)
    textLabel["FontFace"] = Font.new([[rbxasset://fonts/families/Ubuntu.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    textLabel["TextSize"] = 14
    textLabel["TextColor3"] = Color3.fromRGB(209, 0, 0)
    textLabel["AnchorPoint"] = Vector2.new(0.5, 0)
    textLabel["Size"] = UDim2.new(0.6499999761581421, 0, 0.10000000149011612, 0)
    textLabel["BorderColor3"] = Color3.fromRGB(0, 0, 0)
    textLabel["BackgroundTransparency"] = 0.5
    textLabel["Position"] = UDim2.new(0.5, 0, 0.10000000149011612, 0)

    uiPadding["PaddingTop"] = UDim.new(0, 10);
    uiPadding["PaddingBottom"] = UDim.new(0, 10);
    uiPadding.Parent = textLabel

    local function verifyIsATypeOf(value, isAOrTypeOf)
        local valueTypeOf = typeof(value)

        if valueTypeOf == isAOrTypeOf then
            return true
        elseif valueTypeOf == "Instance" and value:IsA(isAOrTypeOf) then
            return true
        end
    end

    local function fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function grad(hash, x, y, z)
        local h = hash % 16
        local u = h < 8 and x or y
        local v = h < 4 and y or (h == 12 or h == 14) and x or z
        return ((h % 2) == 0 and u or -u) + ((h % 3) == 0 and v or -v)
    end

    local function lerp(t, a, b)
        return a + t * (b - a)
    end

    function get:PerlinNoise(x, y, z)
        local X = math.floor(x) % 256
        local Y = math.floor(y) % 256
        local Z = math.floor(z) % 256
        x = x - math.floor(x)
        y = y - math.floor(y)
        z = z - math.floor(z)
        local u = fade(x)
        local v = fade(y)
        local w = fade(z)
        local A = perlinNoiseArray[X] + Y
        local AA = perlinNoiseArray[A] + Z
        local AB = perlinNoiseArray[A + 1] + Z
        local B = perlinNoiseArray[X + 1] + Y
        local BA = perlinNoiseArray[B] + Z
        local BB = perlinNoiseArray[B + 1] + Z

        return lerp(w,
            lerp(v,
                lerp(u, grad(perlinNoiseArray[AA], x, y, z), grad(perlinNoiseArray[BA], x - 1, y, z)),
                lerp(u, grad(perlinNoiseArray[AB], x, y - 1, z), grad(perlinNoiseArray[BB], x - 1, y - 1, z))
            ),
            lerp(v,
                lerp(u, grad(perlinNoiseArray[AA + 1], x, y, z - 1), grad(perlinNoiseArray[BA + 1], x - 1, y, z - 1)),
                lerp(u, grad(perlinNoiseArray[AB + 1], x, y - 1, z - 1), grad(perlinNoiseArray[BB + 1], x - 1, y - 1, z - 1))
            )
        )
    end

    function get:AdminJoinedNotification(text)
        local _textLabel = textLabel:Clone()
        _textLabel.Text = text
        _textLabel.Parent = adminNotificationContainer

        return _textLabel
    end

    function get:Player(playerName)
        if not playerName or #playerName < 4 then
            return
        end

        playerName = string.lower(playerName)

        local playersArray = Players:GetChildren()
        table.remove(playersArray, table.find(playersArray, localPlayer))

        if playerName == "random" then
            return playersArray[math.random(1, #playersArray)]
        else
            for _, player in pairs(playersArray) do
                local targPlayerName = player.Name
                local targPlayerDisplayName = player.DisplayName

                if string.sub(string.lower(targPlayerName), 1, #playerName) == playerName or
                    string.sub(string.lower(targPlayerDisplayName), 1, #playerName) == playerName
                then
                    logs:LogMessage("GEFoundPlayer", player.Name, player.DisplayName)

                    return player
                end
            end
        end
    end

    function get:Character(target)
        if verifyIsATypeOf(target, "Player") then
            return target.Character or charactersFolder[target.Name]
        elseif verifyIsATypeOf(target, "string") then
            local player = get:Player(target)

            if player then
                return player.Character
            end
        end
    end

    function get:Humanoid(target)
        if verifyIsATypeOf(target, "Model") then
            return target:FindFirstChild("Humanoid") or target:FindFirstChildWhichIsA("Humanoid")
        elseif verifyIsATypeOf(target, "Player") or verifyIsATypeOf(target, "string") then
            local character = get:Character(target)

            if character then
                return character:FindFirstChild("Humanoid") or character:FindFirstChildWhichIsA("Humanoid")
            end
        end
    end

    function get:Root(target)
        if verifyIsATypeOf(target, "Model") then
            return target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        elseif verifyIsATypeOf(target, "Player") or verifyIsATypeOf(target, "Player") then
            local character = get:Character(target)

            if character then
                return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
            end
        end
    end

    function get:Head(target)
        if verifyIsATypeOf(target, "Model") then
            return target:FindFirstChild("Head") or target.PrimaryPart
        elseif verifyIsATypeOf(target, "Player") or verifyIsATypeOf(target, "Player") then
            local character = get:Character(target)

            if character then
                return character:FindFirstChild("Head") or character.PrimaryPart
            end
        end
    end

    do
        for index = 0, 255 do
            perlinNoiseArray[index] = math.random(0, 255)
        end

        for index = 0, 255 do
            local randomFactor = math.random(0, 255)

            perlinNoiseArray[index], perlinNoiseArray[randomFactor] = perlinNoiseArray[randomFactor], perlinNoiseArray[index]
        end

        for index = 0, 511 do
            perlinNoiseArray[index] = perlinNoiseArray[index % 256]
        end

        logs:LogMessage("Loaded", tableIndex)
    end
end

local function initializePrediction()
    local tableIndex = "RedPing"

    do
        redPing = {}

        if _debug then
            loadLog(redPing, tableIndex)
        end
    end

    local raycastParamsPrediction =  RaycastParams.new()
    raycastParamsPrediction.FilterDescendantsInstances = {charactersFolder}

    local V2CircleMod = 1

    local predictionData = {
        CurrentTarget = nil,
        Position = nil,
        Velocity = nil,
        Tick = tick()
    }

    local rubberBandSimple
    local rubberBandAdvanced

    function redPing:Orbit(target)
        local targetRoot = get:Root(target)
        local targetPosition = targetRoot.Position
        local targetVelocity = targetRoot.Velocity

        local orbitTime = settings["orbitSpeed"]
        local radius = settings["orbitRadius"]
        local eclipse = 1
        local rot = CFrame.Angles(0 , 0 , 0)
        local sin = math.sin
        local cos = math.cos
        local rotSpeed = math.pi * 2 / orbitTime

        local orbitTargetMath =  rot * Vector3.new(sin(rot) * eclipse , 0 , cos(rot) * radius) + targetPosition

        eclipse = eclipse * radius
        rot = rot + task.wait() * rotSpeed

        if target:FindFirstChild("Torso") and target:FindFirstChild("HumanoidRoot") then
            return orbitTargetMath
        else
            return Vector3.new(0 , 0 , 0)
        end
    end

    local function generateRandomizedVector(position, range)
        local XRandom, ZRandom = math.random(-range, range), math.random(-range, range)

        return position + Vector3.new(XRandom, 0, ZRandom)
    end

    function redPing:SimplePrediction(target)
        local localLatency = localPlayer:GetNetworkPing()

        local targetRoot = get:Root(target)
        local targetPosition = targetRoot.Position
        local targetVelocity = targetRoot.Velocity

        if rubberBandSimple > settings["MaxRubberBand"] then
            rubberBandSimple = settings["MinRubberBand"] -- //Reset rubberband to starting position.
        else
            rubberBandSimple += settings["RubberBandSpeed"]
        end

        localLatency *= 2 -- //To account for other players latency.

        if not settings["VerticalPrediction"] then
            targetVelocity *= (Vector3.yAxis * 0)
        end

        local predictedVelocity = targetVelocity * rubberBandSimple
        local predictedPosition = targetPosition * (targetVelocity * localLatency)

        return predictedPosition
    end

    function redPing:AdvancedPrediction(target)
        local localLatency = localPlayer:GetNetworkPing()

        local targetRoot = get:Root(target)
        local targetPosition = targetRoot.Position
        local targetVelocity = targetRoot.Velocity * settings["PredictionOffset"]

        if predictionData.CurrentTarget ~= target then
            predictionData.CurrentTarget = target
            predictionData.Velocity = targetVelocity
            predictionData.Tick = tick()
        end

        local prevToCurrDiffMag = (predictionData.Position - targetPosition).Magnitude
        local elapsedTime = tick() - predictionData.Tick
        local expectedVelocity = predictionData.Velocity * elapsedTime

        local expectedToCurrentComparison = prevToCurrDiffMag / expectedVelocity

        if expectedToCurrentComparison < settings["CircleSensitivity"] then
            V2CircleMod = expectedToCurrentComparison
        else
            V2CircleMod = 1
        end

        predictionData.Position = targetPosition
        predictionData.Velocity = targetVelocity
        predictionData.Tick = tick()

        if rubberBandAdvanced > settings["MaxRubberBand"] then
            rubberBandAdvanced = settings["MinRubberBand"] -- //Reset rubberband to starting position.
        else
            rubberBandAdvanced += settings["RubberBandSpeed"] + (math.random(10, 50) / 300)
        end

        localLatency *= 2 -- //To account for other players latency.

        if not settings["VerticalPrediction"] then
            targetVelocity *= (Vector3.yAxis * 0)
        end

        local predictedVelocity = (targetVelocity * rubberBandAdvanced) * V2CircleMod
        local predictedPosition = targetPosition * (targetVelocity * localLatency)

        if settings["RayCastPrediction"] then
            local predictionRay = workspace:Raycast(targetPosition, predictedPosition - targetPosition, raycastParamsPrediction)

            if predictionRay then
                local rayPredictionDifference = predictionRay.Position - targetPosition.Position

                targetPosition = (target.Character.Torso.Position + rayPredictionDifference * 2) / 3
            end
        end

        return targetPosition
    end

    do -- //Post loading
        logs:LogMessage("Loaded", tableIndex)
    end
end

local function lerpColor(color1, color2, t)
    return Color3.new(
        color1.r + (color2.r - color1.r) * t,
        color1.g + (color2.g - color1.g) * t,
        color1.b + (color2.b - color1.b) * t
    )
end

local function initializeFling()
    local tableIndex = "FlingEnv"

    do
        fling = {}

        if _debug then
            loadLog(fling, tableIndex)
        end
    end

    local doingFling = false

    local function isDead(humanoid)
        return humanoid and humanoid.Health <= 0 or true
    end

    function fling:KillAllToggle(isEnabled)
        if isEnabled then
            while settings["KillAllEnabled"] and task.wait(.5) do
                for _, player in pairs(Players:GetChildren()) do
                    if player == localPlayer then
                        continue
                    end

                    flingTargetDict({
                        Target = character,
                        DontFlashback = true
                    })

                    while doingFling and settings["KillAllEnabled"] do
                        task.wait(.1)
                    end

                    if not settings["KillAllEnabled"] then
                        break
                    end
                end
            end
        end
    end

    function fling:FlingTarget(flingTargetDict)
        verifyPassedProperties(flingTargetDict, "FlingTarget")

        if doingFling then
            return false
        end

        local target = flingTargetDict["Target"]
        local targetRoot = get:Root(target)
        local targetHumanoid = get:Humanoid(target)

        local flashbackPosition

        if not flingTargetDict["DontFlashback"] then
            flashbackPosition = flingCube.Position
        end

        doingFling = true

        if _debug then
            logs:LogMessage("FlingStarted", flingTarget.Name)
        end

        while scriptEnabled and doingFling and settings["FlingEnabled"] and isLocalPlayerAlive and isDead(targetHumanoid) do
            task.wait()

            if not settings["PredictionEnabled"] then
                flingCubePosition = targetRoot.Position
            else
                local predictionType = settings["PredictionType"]

                if predictionType == "Advanced" then
                    flingCubePosition = redPing:AdvancedPrediction(target)
                else -- //Its simple
                    flingCubePosition = redPing:SimplePrediction(target)
                end
            end
        end

        doingFling = false

        flingCubePosition = flashbackPosition or flingCubePosition
    end

    do -- //Post loading
        logs:LogMessage("Loaded", tableIndex)
    end
end


local function initializeGUI()
    local tableIndex = "GUI"
    do
        GUI = {}

        if _debug then
            loadLog(GUI, tableIndex)
        end
    end

    local guiElements = {}

    getgenv().SecureMode = true
    local rayfieldLib = loadstring(game:HttpGet("https://cdn.guest.gay/libs/rayfield.lua"))()

    guiElements["Window"] = rayfieldLib:CreateWindow({
        Name = "Cube-07",
        LoadingTitle = "Loading Cube-07 || Flinginality",
        LoadingSubtitle = "Made by ItsLush and guest",
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

    local mainTab = guiElements["Window"]:CreateTab("Main")
    local settingsTab = guiElements["Window"]:CreateTab("Setting")
    local brickCustomizationTab = guiElements["Window"]:CreateTab("Brick Customization")
    local creditsTab = guiElements["Window"]:CreateTab("Credits")

    --[[
         __  __       _         _        _
        |  \/  |     (_)       | |      | |
       | \  / | __ _ _ _ __   | |_ __ _| |__
      | |\/| |/ _` | | _ \  | __/ _` | "_ \
     | |  | | (_| | | | | | | || (_| | |_) |
    |_|  |_|\__,_|_|_| |_|  \__\__,_|_.__/
    ]]

    mainTab:CreateToggle({
        Name = "Config save",
        Callback = fileSys.ToggleSaving,
        CurrentValue = settings["AutoSaving"]
    })

    mainTab:CreateToggle({
        Name = "Enable fling",
        Callback = handler.OnFlingStateChanged,
        CurrentValue = settings["FlingEnabled"]
    })

    mainTab:CreateToggle({
        Name = "Enable fling mutli targetting",
        Callback = handler.OnFlingMultiTargetStateChanged,
        CurrentValue = settings["FlingEnabled"]
    })

    mainTab:CreateDropdown({
        Name = "Fling style",
        Options = {
            "Follow camera",
            "Rotational",
            "Perlin noise",
            "Locked angle"
        },
        MultipleOptions = false,
        Callback = handler.OnFlingStyleStateChanged,
        CurrentOption = {settings["FlingStyle"]}
    })

    -- //Indexed
    guiElements["BodyFling"] = mainTab:CreateToggle({
        Name = "Enable bodyfling",
        Callback = handler.OnBodyFlingStateChanged,
        CurrentValue = settings["BodyFlingEnabled"]
    })

    mainTab:CreateKeybind({
        Name = "Bodyfling keybind",
        Callback = handler.OnBodyFlingKeybind,
        CurrentKeybind = settings["BodyFlingKeybind"]
    })

    guiElements["HideCube"] = mainTab:CreateToggle({
        Name = "Hide cube",
        Callback = handler.OnHideCubeStateChanged,
        CurrentValue = settings["HideCubeEnabled"]
    })

    mainTab:CreateKeybind({
        Name = "Hide cube keybind",
        Callback = handler.OnHideCubeKeybind,
        CurrentKeybind = settings["HideCubeKeybind"]
    })

    -- //Indexed
    guiElements["KillAura"] = mainTab:CreateToggle({
        Name = "Enable killaura",
        Callback = handler.OnKillAuraStateChanged,
        CurrentValue = settings["KillauraEnabled"]
    })

    mainTab:CreateKeybind({
        Name = "killaura keybind",
        Callback = handler.OnKillAuraKeybind,
        CurrentKeybind = settings["KillauraKeybind"]
    })

    mainTab:CreateToggle({
        Name = "Kill all",
        Callback = handler.OnKillAllStateChanged,
        CurrentValue = settings["KillAllEnabled"]
    })


    mainTab:CreateButton({
        Name = "Close script",
        Callback = handler.OnCloseScript
    })

    --[[
     __  __       _         _        _                      _
    |  \/  |     (_)       | |      | |                    | |
    | \  / | __ _ _ _ __   | |_ __ _| |__     ___ _ __   __| |
    | |\/| |/ _` | | "_ \  | __/ _` | "_ \   / _ | "_ \ / _` |
    | |  | | (_| | | | | | | || (_| | |_) | |  __| | | | (_| |
    |_|  |_|\__,_|_|_| |_|  \__\__,_|_.__/   \___|_| |_|\__,_|


     _____      _   _   _
    / ____|    | | | | (_)
    | (___   ___| |_| |_ _ _ __   __ _ ___
    \___ \ / _ | __| __| | "_ \ / _` / __|
    ____) |  __| |_| |_| | | | | (_| \__ \
   |_____/ \___|\__|\__|_|_| |_|\__, |___/
                                __/ |
                               |___/
    ]]

    settingsTab:CreateSlider({
        Name = "Cube fly speed",
        Callback = handler.OnFlySpeedChanged,
        Range = {0, 500},
        Increment = 1,
        Suffix = "speed",
        CurrentValue = settings["FlySpeed"]
    })

    settingsTab:CreateDropdown({
        Name = "Prediction type",
        Options = {
            "Simple",
            "Advanced"
        },
        MultipleOptions = false,
        CurrentOption = settings["PredictionType"]
    })
    
    settingsTab:CreateToggle({
        Name = "Raycast Prediction",
        Callback = handler.OnRaycastStateChanged,
        CurrentOption = settings["RayCastPredictionEnabled"]
    })

    settingsTab:CreateToggle({
        Name = "Auto RubberBanding",
        Callback = handler.OnAutoRubberbandingStateChanged,
        CurrentOption = settings["AutoRubberBandingEnabled"]
    })

    settingsTab:CreateSlider({
        Name = "Minimum RubberBanding",
        Callback = handler.OnMinRubberbandStateChanged,
        Range = {0, 15},
        Increment = .1,
        Suffix = "Studs",
        CurrentValue = settings["MinRubberbanding"]
    })

    settingsTab:CreateSlider({
        Name = "Max RubberBanding",
        Callback = handler.OnMaxRubberbandStateChanged,
        Range = {0, 15},
        Increment = .1,
        Suffix = "Studs",
        CurrentValue = settings["MaxRubberbanding"]
    })

    settingsTab:CreateSlider({
        Name = "Advanced circlular motion detection",
        Callback = handler.OnCircleSensitivityStateChanged,
        Range = {0, 15},
        Increment = .1,
        Suffix = "Studs",
        CurrentValue = settings["CircleSensitivity"]
    })

    settingsTab:CreateSlider({
        Name = "Killaura radius",
        Callback = handler.OnKillAuraRadiusStateChanged,
        Range = {0, 1000},
        Increment = 5,
        Suffix = "Studs",
        CurrentValue = settings["KillauraRadius"]
    })

    settingsTab:CreateSlider({
        Name = "Random Radius",
        Callback = handler.OnRandomRadiusStateChanged,
        Range = {0, 20},
        Increment = .1,
        Suffix = "Multiplied by",
        CurrentValue = settings["RandomRadius"]
    })

    settingsTab:CreateSlider({
        Name = "Orbit Radius",
        Callback = handler.OnOrbitRadiusStateChanged,
        Range = {0, 50},
        Increment = .1,
        Suffix = "Studs",
        CurrentValue = settings["OrbitRadius"]
    })

    settingsTab:CreateSlider({
        Name = "Orbit Speed",
        Range = {0, 50},
        Increment = .1,
        Suffix = "Per os.Time",
        CurrentValue = settings["OrbitSpeed"]
    })

    settingsTab:CreateSlider({
        Name = "Perlin noise rotation speed",
        Callback = handler.OnPerlinNoiseRotationalSpeedChanged,
        Range = {0.1, 15},
        Increment = .1,
        Suffix = "StudsPerOsTime",
        CurrentValue = settings["PerlinNoiseRotSpeed"]
    })

    settingsTab:CreateSlider({
        Name = "Perlin magnitude",
        Callback = handler.OnPerlinNoiseMagnitudeSpeedChanged,
        Range = {0.1, 15},
        Increment = 0.1,
        Suffix = "Multiplied by",
        CurrentValue = settings["PerlinNoiseMagnitude"]
    })

    --[[
    ______           _    ____   __    _____      _   _   _
   |  ____|         | |  / __ \ / _|  / ____|    | | | | (_)
   | |__   _ __   __| | | |  | | |_  | (___   ___| |_| |_ _ _ __   __ _ ___
   |  __| | "_ \ / _` | | |  | |  _|  \___ \ / _ | __| __| | "_ \ / _` / __|
   | |____| | | | (_| | | |__| | |    ____) |  __| |_| |_| | | | | (_| \__ \
   |______|_| |_|\__,_|  \____/|_|   |_____/ \___|\__|\__|_|_| |_|\__, |___/
                                                                 __/ |
                                                                |___/
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------------
      _____      _             _____          _                  _          _   _
     / ____|    | |           / ____|        | |                (_)        | | (_)
    | |    _   _| |__   ___  | |    _   _ ___| |_ ___  _ __ ___  _ ______ _| |_ _  ___  _ __
    | |   | | | | '_ \ / _ \ | |   | | | / __| __/ _ \| '_ ` _ \| |_  / _` | __| |/ _ \| '_ \
    | |___| |_| | |_) |  __/ | |___| |_| \__ | || (_) | | | | | | |/ | (_| | |_| | (_) | | | |
    \_____\__,_|_.__/ \___|  \_____\__,_|___/\__\___/|_| |_| |_|_/___\__,_|\__|_|\___/|_| |_|

    ]]

    brickCustomizationTab:CreateSlider({
        Name = "Cube Transparency",
        Range = {0, 100},
        Increment = 1,
        CurrentValue = settings["CubeTransparency"],
        Callback = handler.OnCubeTransparencyChanged
    })

    brickCustomizationTab:CreateDropdown({
        Name = "Brick material",
        Options = {
            "Plastic", "Wood", "Slate",	"Concrete",
            "CorrodedMetal", "CorrodedMetal", "DiamondPlate",
            "Foil", "Grass", "Ice",
            "Marble", "Granite", "Brick",
            "Pebble", "Sand", "Fabric",
            "Fabric", "SmoothPlastic", "Metal",
            "WoodPlanks", "Cobblestone", "Rock",
            "Glacier", "Snow", "Sandstone",
            "Mud", "Basalt", "Ground",
            "CrackedLava", "Neon", "Glass",
            "Asphalt", "LeafyGrass", "Salt",
            "Limestone", "Pavement", "ForceField",
            "Cardboard", "Carpet", "CeramicTiles",
            "CeramicTiles", "ClayRoofTiles", "RoofShingles",
            "Leather", "Plaster", "Rubber"
        },
        MultipleOptions = false,
        Callback = handler.OnCubeMaterialStateChanged,
        CurrentOption = {settings["CubeMaterial"]}
    })

    brickCustomizationTab:CreateToggle({
        Name = "Enable highlight",
        CurrentValue = settings["HighlightEnabled"],
        Callback = handler.OnHighlightEnabledChanged
    })

    brickCustomizationTab:CreateSlider({
        Name = "Highlight transparency",
        Range = {0, 100},
        Increment = 1,
        CurrentValue = settings["HighlightTransparency"],
        Callback = handler.OnHighlightTransparencyStateChanged
    })

    brickCustomizationTab:CreateDropdown({
        Name = "Highlight mode",
        Options = {
            "RGB Mode",
            "Transition mode",
            "Static Mode"
        },
        CurrentOption = {settings["HighlightMode"]},
        Callback = handler.OnHightlightModeChanged
    })

    brickCustomizationTab:CreateColorPicker({
        Name = "Static Color",
        Color = settings["StaticColor"],
        Callback = handler.OnStaticColorChanged
    })

    brickCustomizationTab:CreateColorPicker({
        Name = "Transition mode Color1",
        Color = settings["TransitionColor1"],
        Callback = handler.OnTransitionColor1Changed
    })

    brickCustomizationTab:CreateColorPicker({
        Name = "Transition mode Color2",
        Color = settings["TransitionColor2"],
        Callback = handler.OnTransitionColor2Changed
    })


    --[[
     ______           _    ____   __    _____      _             _____          _                  _          _   _
    |  ____|         | |  / __ \ / _|  / ____|    | |           / ____|        | |                (_)        | | (_)
    | |__   _ __   __| | | |  | | |_  | |    _   _| |__   ___  | |    _   _ ___| |_ ___  _ __ ___  _ ______ _| |_ _  ___  _ __
    |  __| | '_ \ / _` | | |  | |  _| | |   | | | | '_ \ / _ \ | |   | | | / __| __/ _ \| '_ ` _ \| |_  / _` | __| |/ _ \| '_ \
    | |____| | | | (_| | | |__| | |   | |___| |_| | |_) |  __/ | |___| |_| \__ | || (_) | | | | | | |/ | (_| | |_| | (_) | | | |
    |______|_| |_|\__,_|  \____/|_|    \_____\__,_|_.__/ \___|  \_____\__,_|___/\__\___/|_| |_| |_|_/___\__,_|\__|_|\___/|_| |_|

    ----------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------------------
      _____              _ _ _
     / ____|            | (_| |
    | |     _ __ ___  __| |_| |_ ___
    | |    | '__/ _ \/ _` | | __/ __|
    | |____| | |  __| (_| | | |_\__ \
    \_____|_|  \___|\__,_|_|\__|___/

    ]]

    creditsTab:CreateLabel("Rewrite made by ItsIush")
    creditsTab:CreateLabel("Itslush for the fling method")
    creditsTab:CreateLabel("guest257351 creator of the original script")
    creditsTab:CreateLabel("Sirius for the UI framework")

    --[[
      ______           _    ____   __    _____              _ _ _
    |  ____|         | |  / __ \ / _|  / ____|            | (_| |
    | |__   _ __   __| | | |  | | |_  | |     _ __ ___  __| |_| |_ ___
    |  __| | '_ \ / _` | | |  | |  _| | |    | '__/ _ \/ _` | | __/ __|
    | |____| | | | (_| | | |__| | |   | |____| | |  __| (_| | | |_\__ \
    |______|_| |_|\__,_|  \____/|_|    \_____|_|  \___|\__,_|_|\__|___/
    ]]

    -- //Post-loading
    do
        guiElements["Window"] = rayfieldLib
        GUI.Data = guiElements

        logs:LogMessage("Loaded", tableIndex)
    end
end

local function initializeHandler()
    local tableIndex = "Handler"

    do
        handler = {}
        handler.Data = {}

        if _debug then
            loadLog(handler, tableIndex)
        end
    end

    local bodyThrust = Instance.new("BodyThrust")

    local RGBModeActive = false
    local transitionModeActive = false

    local closingInProgress = false

    local highlightColorIndexes = {
        Dead = Color3.fromRGB(0, 0, 0),
        UserChoiceColor = settings["FlingCubeColor"]
    }

    local limbCubeOffsets = {
        CFrame.new(.5, 0, .5),
        CFrame.new(.5, 0, -.5),
        CFrame.new(-.5, 0, .5),
        CFrame.new(-.5, 0, -.5),
    }

    local tempNotificationContainer

    handler.Data.MultiPredictionCFrames = {}

    local flingStyles = {
        ["Follow camera"] = function()
            bodyThrust.Parent = nil

            for _, limb in pairs(limbsArray) do
                limb.Velocity = Vector3.new(9e7, 9e17, 9e7)
            end
        end,
        ["Locked angle"] = function()
            bodyThrust.Parent = nil

            for _, limb in pairs(limbsArray) do
                limb.Velocity = Vector3.zero
            end
        end,
        ["Rotational"] = function()
            bodyThrust.Parent = nil

            bodyThrust.Force = Vector3.new(0, 2e4, 2e4)
            bodyThrust.Location = Vector3.new(6, 10, -8)

            for _, limb in pairs(limbsArray) do
                limb.Velocity = Vector3.new(9e7, 9e17, 9e7)
            end
        end,
        ["Perlin noise"] = function()
            local osTime = os.time() * settings["PerlinNoiseRotSpeed"]

            local XAxis = get:PerlinNoise(osTime, 0, 0)  * settings["PerlinNoiseMagnitude"]
            local YAxis = get:perlinNoise(0, osTime, 0) * settings["PerlinNoiseMagnitude"]
            local ZAxis = get:PerlinNoise(0, 0, osTime) * settings["PerlinNoiseMagnitude"]

            flingCube.CFrame *= CFrame.Angles(XAxis, YAxis, ZAxis)
        end,
        ["Penis mode???"] = function()
            -- // up and coming penis gay shenanigans partnered with gnaa executives and gay thug shaker jerome
        end
    }

    local previousHighlightColor
    local oldCFrame

    function handler:GetClosest()
        local closestMagnitude = settings["MaximumDistance"]

        local closestPlayer

        for _, player in pairs(Players:GetChildren()) do
            if player == localPlayer then
                continue
            end

            local targetRootPart = get:Root(player)

            if not targetRootPart then
                continue
            end

            local targetRootPosition = targetRootPart.Position

            local distFromTarget = (flingCubePosition - targetRootPosition).Magnitude

            if distFromTarget < closestMagnitude then
                closestMagnitude = distFromTarget
                closestPlayer = player
            end
        end

        return closestPlayer
    end

    function handler:GetClosestLookingPlayer()
        local closestMagnitude = settings["MaximumDistance"]
        local lookingPlayer

        for _, player in pairs(Players:GetChildren()) do
            if player == localPlayer then
                continue
            end

            local targetRootPart = get:Root(player)

            if not targetRootPart then
                continue
            end

            local targetRootPosition = targetRootPart.Position
            local targetLookVector = targetRootPosition.LookVector

            local distFromTarget = (flingCubePosition - targetRootPosition).Magnitude
            local dotResult = flingCube.LookVector:Dot(targetLookVector)

            if distFromTarget < closestMagnitude and dotResult < -.5 then
                closestMagnitude = distFromTarget
                lookingPlayer = player
            end
        end

        return closestPlayer
    end

    function handler:IsAdmin(player)
        local groupName = ""

        local mainGroupSuccess, mainGroupRank
        local modGroupSuccess, modGroupRank

        while not mainGroupSuccess and task.wait() do
            mainGroupSuccess, mainGroupRank = pcall(function()
                return player:GetRankInGroup(4165692)
            end)
        end

        while not modGroupSuccess and task.wait() do
            modGroupSuccess, modGroupRank = pcall(function()
                return player:GetRankInGroup(32406137)
            end)
        end

        if mainGroupRank > 1 then
            return true, "main"
        end

        if modGroupRank > 0 then
            return true, "mod"
        end

        return false
    end

    function handler:ProcessAdmin(player, groupType, didJoin)
        if isAdmin then
            local desiredString

            if didJoin then
                desiredString = string.format("Admin: [%s / %s] from %s group has joined the game, stay safe. Disabling fling is recommended!",
                    player.Name,
                    player.DisplayName,
                    groupType
                )
            else
                desiredString = string.format("Admin: [%s / %s] from %s group found in game, stay safe. Not using fling is recommended!",
                    player.Name,
                    player.DisplayName,
                    groupType
                )
            end


            if tempNotificationContainer then
                local previousText = tempNotificationContainer.Text

                tempNotificationContainer:Destroy()

                desiredString = previousText .. "\n" .. desiredString
            end

            tempNotificationContainer = get:AdminJoinedNotification(desiredString)

            local _tempNotificationContainer = tempNotificationContainer

            task.delay(10, function()
                local fadeOutTween = generateTween(adminNotification, "AdminFadeOut", {BackgroundTransparency = 1, TextTransparency = 1})
                fadeOutTween:Play()

                fadeOutTween["Completed"]:Once(function()
                    if _tempNotificationContainer then
                        _tempNotificationContainer:Destroy()
                    end
                end)
            end)
        end
    end

    function handler:AutoFling()
        local autoFlingClosestTarget = GetClosest()

        fling:Fling(autoFlingClosestTarget)
    end

    function handler:AnimationToggle(isEnabled)
        if not isEnabled then
            if pumpkinStinkAnimation then
                pumpkinStinkAnimation:Stop()
                pumpkinStinkAnimation:Destroy()
            end

            return
        end

        local fallingAnimation = Instance.new("Animation")
        fallingAnimation.AnimationId = "rbxassetid://181526230"

        pumpkinStinkAnimation = localHumanoid:LoadAnimation(fallingAnimation)

        pumpkinStinkAnimation:Play()
        pumpkinStinkAnimation:AdjustSpeed(0)

        task.spawn(function()
            while pumpkinStinkAnimation and settings["FlingEnabled"] and scriptEnabled and task.wait(1) do
                pumpkinStinkAnimation:Play()
                pumpkinStinkAnimation:AdjustSpeed(0)
            end

            pumpkinStinkAnimation:Stop()
        end)
    end

    function handler:FixCamera()
        camera:Destroy()

        task.wait()

        camera = workspace.CurrentCamera
        camera.CameraSubject = localHumanoid
    end

    function handler:AddVisibleChat()
        local ChatFrame = playerGui.Chat.Frame

        ChatFrame.ChatChannelParentFrame.Visible = true
        ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), ChatFrame.ChatChannelParentFrame.Size.Y)
    end

    function handler:DisableVisibleChat()
        local ChatFrame = playerGuilayerGui.Chat.Frame

        ChatFrame.ChatChannelParentFrame.Visible = false
        ChatFrame.ChatBarParentFrame.Position = ChatFrame.ChatChannelParentFrame.Position + UDim2.new(0, 0, 0, 0)
    end

    function handler:FullBright()
        local Lighting = game:GetService("Lighting")
        local defaultFog = Lighting.FogEnd

        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    function handler:RestoreCameraEffects()

    end

    function handler:ModifyCameraEffects()
        localPlayer.CameraMaxZoomDistance = 9e9
    end

    function handler:LerpTransitionColors(color1, color2, deltaTime)
        local lerpAlpha = deltaTime and 1-math.exp(-6 * deltaTime) or 1

        local alpha = (math.sin(tick()) + 1) / 2

        return color1:Lerp(color2, alpha * lerpAlpha)
    end

    function handler:RGBColorMode()
        local timeElapsed = 0
        local totalTime = 3.5

        while scriptEnabled and RGBModeActive do
           local deltaTime = RunService["RenderStepped"]:Wait()

           local hue = (os.time() / 10) * (deltaTime / (1 / 60))
           flingCubeHighlight.Color3 = Color3.fromHSV(hue, 1, 1)
        end
    end

    function handler:TransitionColorMode(isStatusBad)
        while scriptEnabled and transitionModeActive do
            local deltaTime = RunService["RenderStepped"]:Wait()

            local color1 = isStatusBad and Color3.new(0, 0, 0) or settings["HighlightColor1"]
            local color2 = isStatusBad and Color3.new(1, 0, 0) or settings["HighlightColor2"]

            local lerpedColor = handler:LerpTransitionColors(color1, color2, deltaTime)

            flingCubeHighlight.Color3 = lerpedColor
        end
        -- //Code
    end

    function handler:ChangeHighlightsColor(colorIndex)
        colorIndex = colorIndex or previousHighlightColorIndex

        if not localTorso.Neck.Enabled or colorIndex == "StatusBad" then -- //Status Bad!! Niggaaa
            transitionModeActive = false
            RGBModeActive = false

            handler:TransitionColorMode(true)
        elseif colorIndex == "RGBMode" then
            transitionModeActive = false
            RGBModeActive = true

            handler:RGBColorMode()
        elseif colorIndex == "ColorTransition" then
            RGBModeActive = false
            transitionModeActive = true

            handler:TransitionColorMode()
        else
            flingCubeHighlight.Color3 = highlightColorIndexes[colorIndex]
        end

        flingCube.Transparency = settings["CubeTransparency"]
        flingCube.Material = settings["CubeMaterial"]

        previousHighlightColorIndex = colorIndex
    end

    function handler:Suicide()
        local localNeck = localCharacter:WaitForChild("Neck")

        while scriptEnabled and isLocalPlayerAlive do
            localCharacter:BreakJoints()
        end
    end

    function handler:AddSemiACBypass()
        local SemiAnticheatBypass = Instance.new("LocalScript")

        SemiAnticheatBypass.Name = "ADONIS_FLIGHT"
        SemiAnticheatBypass.Parent = localRoot
    end

    function handler:FlyToggle(isEnabled)
        if not isEnabled then
            if connections:DoesExist("FlyLoop") then
                connections:Disconnect("FlyLoop")
            end

            return
        end

        local keyDirections = {
            [Enum.KeyCode.W] = -Vector3.zAxis,
            [Enum.KeyCode.A] = -Vector3.xAxis,
            [Enum.KeyCode.S] =  Vector3.zAxis,
            [Enum.KeyCode.D] =  Vector3.xAxis,
            [Enum.KeyCode.Q] = -Vector3.yAxis,
            [Enum.KeyCode.E] =  Vector3.yAxis,
        }

        local function getDirection()
            local direction = Vector3.zero

            for key, directionValue in pairs(keyDirections) do
                if UserInputService:IsKeyDown(key) then
                    direction += directionValue
                end
            end

            return direction.Magnitude == 0 and Vector3.zero or direction.Unit
        end

        local function updateCFrame(deltaTime)
            local direction = CFrame.new((getDirection() * deltaTime) * settings["FlySpeed"])

            flingCubePosition = ((camera.CFrame.Rotation + flingCubePosition) * direction).Position
        end

        local function flyLoop(deltaTime)
            if not isLocalPlayerAlive then
                return
            end

            updateCFrame(deltaTime)
        end

        connections:Add("FlyLoop", RunService["Heartbeat"]:Connect(flyLoop))
    end

    function handler:Initialize()
        flingCubePosition = localRoot.Position

        flingCube = Instance.new("Part")
        flingCube.Name = "FlingCube"
        flingCube.CanCollide = false
        flingCube.Transparency = settings["CubeTransparency"]
        flingCube.Size = Vector3.new(2, 2, 2)
        flingCube.Anchored = true
        flingCube.Position = flingCubePosition

        flingCubeHighlight = Instance.new("Highlight", flingCube)
        flingCubeHighlight.Enabled = settings["HighlightEnabled"]

        task.spawn(function()
            repeat
                task.wait(.25)
            until shared["Cube-07Enabled"]

            handler.OnCloseScript()
        end)

        setfpscap(9999)
    end

    function handler.FlingCubeLoop()
        if scriptEnabled and settings["FlingEnabled"] then
            flingCube.Position = flingCubePosition
        end
    end

    function handler.VelocityLoop()
        if scriptEnabled and isLocalPlayerAlive and settings["FlingEnabled"] or settings["BodyFlingEnabled"] then
            flingStyles[settings["FlingStyle"]]()
        end
    end


    function handler.VisualVelocityLoop()
        if scriptEnabled and isLocalPlayerAlive and settings["FlingEnabled"] or
           settings["BodyFlingEnabled"] and settings["FlingStyle"] ~= "Rotational"
        then
            for _, limb in pairs(limbsArray) do
                limb.Velocity = Vector3.zero
            end
        end
    end

    function handler.LimbLoop()
        if scriptEnabled and isLocalPlayerAlive and settings["FlingEnabled"] or settings["BodyFlingEnabled"] then
            if settings["HideCubeEnabled"] then
                for _, limb in pairs(limbsArray) do
                    limb.CFrame = CFrame.new(0,9e9,0)
                end
            elseif settings["MultiTargetEnabled"] then
                for index, limb in pairs(limbsArray) do
                    limb.CFrame = handler.Data.MultiPredictionCFrames[index]
                end
            else
                for index, limb in pairs(limbsArray) do
                    limb.CFrame = flingCube.CFrame * limbCubeOffsets[index]
                end
            end
        end
    end

    function handler:FlingToggle(isEnabled)
        handler:FlyToggle(isEnabled)
        handler:AnimationToggle(isEnabled)

        if isEnabled then
            oldCFrame = localRoot.CFrame
            flingCubePosition = localRoot.Position

            flingCube.Parent = localCharacter

            for _, limb in pairs(limbsArray) do
                limb.Transparency = 0
            end

            camera.CameraSubject = flingCube
        else
            flingCube.Parent = nil

            for _, limb in pairs(limbsArray) do
                limb.Transparency = 0
            end

            localHumanoid:ChangeState(7)

            camera.CameraSubject = localHumanoid
        end
    end

    function handler.OnCloseScript()
        if closingInProgress then
            return
        else
            closingInProgress = true
        end

        connections:DisconnectAll()

        scriptEnabled = false
        shared["Cube-07Enabled"] = false

        flingCube:Destroy()

        GUI.Data["Window"]:Destroy()

        if isLocalPlayerAlive then
            camera.CameraSubject = localHumanoid
        end
    end

    -- //Non-persistent settings
    function handler.OnFlingStateChanged(state)
        fileSys:UpdateConfig("FlingEnabled", state, true)

        handler:FlingToggle(state)
    end

    function handler.OnBodyFlingStateChanged(state)
        handler:BodyFlingToggle(state)

        fileSys:UpdateConfig("BodyFlingEnabled", state, true)
    end

    function handler.OnHideCubeStateChanged(state)
        fileSys:UpdateConfig("CubeHideEnabled", state, true)
    end

    function handler.OnKillAllStateChanged(state)
        fileSys:UpdateConfig("KillAllEnabled", state, true)

        fling:KillAllToggle(state)
    end

    -- //Persistent settings
    function handler.OnFlingMultiTargetStateChanged(state)
        fileSys:UpdateConfig("MultiTargetEnabled", state)
    end

    function handler.OnKillAuraStateChanged(state)
        fileSys:UpdateConfig("KillauraEnabled", state)
    end

    function handler.OnKillAuraRadiusStateChanged(amount)
        fileSys:UpdateConfig("KillauraRadius", amount)
    end

    function handler.OnFlySpeedChanged(speed)
        fileSys:UpdateConfig("FlySpeed", speed)
    end

    function handler.OnRaycastStateChanged(state)
        fileSys:UpdateConfig("RayCastPrediction", state)
    end

    function handler.OnFlingStyleStateChanged(state)
        fileSys:UpdateConfig("FlingStyle", state)
    end

    function handler.OnAutoRubberbandingStateChanged(state)
        fileSys:UpdateConfig("AutoRubberBanding", state)
    end

    function handler.OnMinRubberbandStateChanged(minRubberBand)
        fileSys:UpdateConfig("MaxRubberBand", minRubberBand / 100)
    end

    function handler.OnMaxRubberbandStateChanged(maxRubberBand)
        fileSys:UpdateConfig("MaxRubberBand", maxRubberBand / 100)
    end

    function handler.OnCircleSensitivityStateChanged(sensitivity)
        fileSys:UpdateConfig("CircleSensitivity", sensitivity / 100)
    end

    function handler.OnRandomRadiusStateChanged(radius)
        fileSys:UpdateConfig("RandomRadius", radius)
    end

    -- //Perlin noise settings
    function handler.OnPerlinNoiseMagnitudeSpeedChanged(speed)
        fileSys:UpdateConfig("PerlinNoiseMagnitude", radius)
    end

    function handler.OnPerlinNoiseRotationalSpeedChanged(speed)
        fileSys:UpdateConfig("PerlinNoiseRotSpeed", radius)
    end

    -- //Orbit settings
    function handler.OnOrbitRadiusStateChanged(radius)
        fileSys:UpdateConfig("OrbitSpeed", radius)
    end

    function handler.OnOrbitSpeedStateChanged(speed)
        fileSys:UpdateConfig("OrbitSpeed", speed)
    end

    -- //Cube
    function handler.OnCubeTransparencyChanged(transparency)
        fileSys:UpdateConfig("CubeTransparency", transparency / 100)

        flingCube.Transparency = settings["CubeTransparency"]
    end

    function handler.OnHighlightTransparencyStateChanged(transparency)
        fileSys:UpdateConfig("HighlightTransparency", transparency / 100)

        flingCubeHighlight.Transparency = settings["CubeTransparency"]
    end

    function handler.OnCubeMaterialStateChanged(material)
        local actualMaterial = Enum.Material[material]

        if actualMaterial then
            fileSys:UpdateConfig("CubeMaterial", material)
        end
    end

    -- //Cube highlight
    function handler.OnHighlightEnabledChanged(state)
        fileSys:UpdateConfig("HighlightEnabled", state)

        flingCubeHighlight.Enabled = state
    end

    function handler.OnHightlightModeChanged(highlightMode)
        highlightMode = string.gsub(table.unpack(highlightMode), " ", "")

        fileSys:UpdateConfig("HighlightMode", highlightMode)
        handler:ChangeHighlightsColor(settings["HighlightMode"])
    end

    function handler.OnStaticColorChanged(color3)
        fileSys:UpdateConfig("StaticColor", color3)
    end

    function handler.OnTransitionColor1Changed(color3)
        fileSys:UpdateConfig("TransitionColor1", color3)
    end

    function handler.OnTransitionColor2Changed(color3)
        fileSys:UpdateConfig("TransitionColor2", color3)
    end

    -- //Keybinds
    function handler.OnBodyFlingKeybind()
        GUI.Data["BodyFling"]:Set(not settings["BodyFlingEnabled"])
    end

    function handler.OnKillAuraKeybind()
        GUI.Data["KillAura"]:Set(not settings["KillauraEnabled"])
    end

    function handler.OnHideCubeKeybind()
        GUI.Data["HideCube"]:Set(not settings["HideCubeEnabled"])
    end

    -- //Non-gui connections
    function handler.RadgollLoop()
        if isLocalPlayerAlive and settings["FlingEnabled"] then
            radgollModule:FireServer("__--r", localRoot.Velocity, localRoot.CFrame)

            localRoot.CFrame = CFrame.new(0, -2.75, math.random(1, 5) / 10) * oldCFrame
            localHead.CFrame = localTorso.CFrame

            localHead.Velocity = Vector3.zero
            localRoot.Velocity = Vector3.new(0, 50, 0)
        end
    end

    function handler.NoclipLoop()
        if not isLocalPlayerAlive or not settings["FlingEnabled"] then
            return
        end

        for _, part in pairs(localCharacter:GetChildren()) do
            if part:IsA("BasePart") and not part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    function handler.LoopChangeState16()
        if isLocalPlayerAlive and settings["FlingEnabled"] then
            localHumanoid:ChangeState(16)
        end
    end

    function handler.OnHumanoidDied()
        isLocalPlayerAlive = false

        handler:ChangeHighlightsOptions("StatusBad")

        flingCube.Parent = nil

        task.wait(1)

        while scriptEnabled and isLocalPlayerAlive and task.wait(.3) do
            local deathGui = playerGui:WaitForChild("DeathGUI")
            local respawnButton = deathGui.Frame.Frame2:FindFirstChild("RespawnButton")

            getconnections(respawnButton.MouseButton1Down)[1]:Fire()

            if _debug then
                logs:LogMessage("Respawning")
            end
        end
    end

    function handler.OnLocalCharacterAdded(character)
        localCharacter = character
        localHumanoid = localCharacter:WaitForChild("Humanoid")
        localRoot = localCharacter:WaitForChild("HumanoidRootPart")

        limbsArray = {
            localCharacter:WaitForChild("Right Arm"),
            localCharacter:WaitForChild("Left Arm"),
            localCharacter:WaitForChild("Right Leg"),
            localCharacter:WaitForChild("Left Leg"),
        }

        handler:AddSemiACBypass()

        isLocalPlayerAlive = true

        connections:Disconnect("OnHumanoidDied")
        connections:Add("OnHumanoidDied", localHumanoid["Died"]:Connect(handler.OnHumanoidDied))
    end

    -- //Post loading
    do
        task.delay(.2, function()
            connections:Add("NoclipLoop", RunService["PreSimulation"]:Connect(handler.NoclipLoop))
            connections:Add("RadgollLoop", RunService["PostSimulation"]:Connect(handler.RadgollLoop))
            connections:Add("LoopChangeState16", RunService["PostSimulation"]:Connect(handler.LoopChangeState16))

            connections:Add("VelocityLoop", RunService["PostSimulation"]:Connect(handler.VelocityLoop))
            connections:Add("VisualVelocityLoop", RunService["PreSimulation"]:Connect(handler.VisualVelocityLoop))
            connections:Add("FlingCube", RunService["PreSimulation"]:Connect(handler.FlingCubeLoop))
            connections:Add("FlingCubePositionVisual", RunService["PostSimulation"]:Connect(handler.FlingCubeLoop))
            connections:Add("LimbLoop", RunService["PostSimulation"]:Connect(handler.LimbLoop))

            connections:Add("OnHumanoidDied", localHumanoid["Died"]:Connect(handler.OnHumanoidDied))

            handler:Initialize()

            logs:LogMessage("Loaded", tableIndex)
        end)
    end
end

local function initialize()
    initializeLogging()
    initializeFileSys()
    initializeHandler()
    initializeConnections()
    initializeEnvironment()
    initializePrediction()
    initializeFling()
    initializeGUI()
end

initialize()
