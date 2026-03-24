local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "EnygmaXIT, by Enygma",
    Icon = 95163525434706,
    LoadingTitle = "EnygmaXIT",
    LoadingSubtitle = "by Enygma",
    ShowText = "⬇️",
    Theme = "Black",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {Enabled = false, FolderName = nil, FileName = "EnygmaXIT"}
})
local CombatTab = Window:CreateTab("Combat⚔️", 95163525434706)
local PlayerTab = Window:CreateTab("Player👤", 95163525434706)
local FarmTab = Window:CreateTab("NPCS⚡", 95163525434706)
local ItemsTab = Window:CreateTab("Items🔑", 95163525434706)
local TeleportsTab = Window:CreateTab("Teleports🧘‍♂️", 95163525434706)
local GameplayTab = Window:CreateTab("Gameplay🌌", 95163525434706)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local BodyLockEnabled = false
local BodyLockConnection = nil
local BodyLockRange = 10
local function getClosestPlayer()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local closestPlayer, shortestDist = nil, BodyLockRange
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetHRP = p.Character.HumanoidRootPart
            local dist = (root.Position - targetHRP.Position).Magnitude
            if dist < shortestDist then
                closestPlayer = p
                shortestDist = dist
            end
        end
    end
    return closestPlayer
end
local function enableBodyLock()
    BodyLockEnabled = true
    if BodyLockConnection then
        BodyLockConnection:Disconnect()
    end
    BodyLockConnection = RunService.Heartbeat:Connect(function()
        if not BodyLockEnabled then return end
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not (character and root and humanoid) then return end
        local target = getClosestPlayer()
        if target and target.Character then
            local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(targetHrp.Position.X, root.Position.Y, targetHrp.Position.Z))
            end
        end
    end)
end
local function disableBodyLock()
    BodyLockEnabled = false
    if BodyLockConnection then
        BodyLockConnection:Disconnect()
        BodyLockConnection = nil
    end
end
local ESPBoxes = {}
local ESPConnection = nil
local function createESP(player)
    if ESPBoxes[player] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255,0,0)
    box.Thickness = 1
    box.Filled = false
    ESPBoxes[player] = box
end
local function removeESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player]:Remove()
        ESPBoxes[player] = nil
    end
end
local function updateESP()
    for player, box in pairs(ESPBoxes) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000
                local size = Vector2.new(1.7*scale,2.5*scale)
                box.Size=size
                box.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                box.Visible=true
            else box.Visible=false end
        else box.Visible=false end
    end
end
local function enableESP()
    for _, p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
    ESPConnection = RunService.RenderStepped:Connect(updateESP)
    Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then createESP(p) end end)
    Players.PlayerRemoving:Connect(removeESP)
end
local function disableESP()
    if ESPConnection then ESPConnection:Disconnect() ESPConnection=nil end
    for _, box in pairs(ESPBoxes) do box:Remove() end
    ESPBoxes={}
end
CombatTab:CreateToggle({
    Name="ESP Box",
    CurrentValue=false,
    Flag="Combat_ESPBox",
    Callback=function(state) if state then enableESP() else disableESP() end end
})
local NameESPEnabled = false
local NameESPConnections = {}
local function createNameESP(player)
    if player==LocalPlayer then return end
    local function attachESP()
        local char = player.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        local old = head:FindFirstChild("NameESP")
        if old then old:Destroy() end
        local billboard = Instance.new("BillboardGui")
        billboard.Name="NameESP"
        billboard.Adornee=head
        billboard.Size=UDim2.new(0,75,0,50)
        billboard.StudsOffset=Vector3.new(0,2,0)
        billboard.AlwaysOnTop=true
        billboard.Parent=head
        local label = Instance.new("TextLabel",billboard)
        label.Size=UDim2.new(1,0,1,0)
        label.BackgroundTransparency=1
        label.Text=player.Name
        label.TextColor3=Color3.new(1,0,0)
        label.TextStrokeTransparency=0
        label.Font=Enum.Font.SourceSansBold
        label.TextScaled=true
    end
    if not NameESPConnections[player] then
        NameESPConnections[player] = player.CharacterAdded:Connect(function() if NameESPEnabled then task.wait(0.5) attachESP() end end)
    end
    if player.Character then attachESP() end
end
local function enableNameESP()
    NameESPEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do createNameESP(p) end
    Players.PlayerAdded:Connect(function(p) if NameESPEnabled then createNameESP(p) end end)
end
local function disableNameESP()
    NameESPEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if NameESPConnections[p] then NameESPConnections[p]:Disconnect() NameESPConnections[p]=nil end
        if p.Character and p.Character:FindFirstChild("Head") then
            local gui = p.Character.Head:FindFirstChild("NameESP")
            if gui then gui:Destroy() end
        end
    end
end
CombatTab:CreateToggle({
    Name="ESP Name",
    CurrentValue=false,
    Flag="Combat_ESPName",
    Callback=function(state) if state then enableNameESP() else disableNameESP() end end
})
local HighlightEnabled = false
local HighlightConnections = {}
local function createHighlightESP(player)
    if player==LocalPlayer then return end
    local function attachHighlight()
        local char = player.Character
        if not char then return end
        local old = char:FindFirstChild("HighlightESP")
        if old then old:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name="HighlightESP"
        highlight.FillColor=Color3.new(1,0,0)
        highlight.FillTransparency=0.5
        highlight.OutlineColor=Color3.new(1,1,1)
        highlight.OutlineTransparency=0
        highlight.Adornee=char
        highlight.Parent=char
    end
    if not HighlightConnections[player] then
        HighlightConnections[player] = player.CharacterAdded:Connect(function() if HighlightEnabled then task.wait(0.5) attachHighlight() end end)
    end
    if player.Character then attachHighlight() end
end
local function enableHighlightESP()
    HighlightEnabled = true
    for _, p in ipairs(Players:GetPlayers()) do createHighlightESP(p) end
    Players.PlayerAdded:Connect(function(p) if HighlightEnabled then createHighlightESP(p) end end)
end
local function disableHighlightESP()
    HighlightEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if HighlightConnections[p] then HighlightConnections[p]:Disconnect() HighlightConnections[p]=nil end
        if p.Character then local hl=p.Character:FindFirstChild("HighlightESP") if hl then hl:Destroy() end end
    end
end
CombatTab:CreateToggle({
    Name="ESP Highlight",
    CurrentValue=false,
    Flag="Combat_ESPHighlight",
    Callback=function(state) if state then enableHighlightESP() else disableHighlightESP() end end
})
local HitboxEnabled = false
local HitboxSize = 50
local HitboxTransparency = 0.7
local HitboxLoopConnection = nil
local function applyCustomHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            hrp.Transparency = HitboxTransparency
            hrp.BrickColor = BrickColor.new("Really red")
            hrp.Material = Enum.Material.Neon
            hrp.CanCollide = false
        end
    end
end
local function resetHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 0
            hrp.BrickColor = BrickColor.new("Medium stone grey")
            hrp.Material = Enum.Material.Plastic
            hrp.CanCollide = true
        end
    end
end
local function hitboxLoop()
    if not HitboxEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            applyCustomHitbox(player)
        end
    end
end
local function setupCharacterHook(player)
    player.CharacterAdded:Connect(function()
        if HitboxEnabled then
            repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            applyCustomHitbox(player)
        end
    end)
end
local function enableHitbox()
    HitboxEnabled = true
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupCharacterHook(player)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                applyCustomHitbox(player)
            end
        end
    end
    Players.PlayerAdded:Connect(setupCharacterHook)
    if HitboxLoopConnection then
        HitboxLoopConnection:Disconnect()
    end
    HitboxLoopConnection = RunService.Heartbeat:Connect(hitboxLoop)
end
local function disableHitbox()
    HitboxEnabled = false
    if HitboxLoopConnection then
        HitboxLoopConnection:Disconnect()
        HitboxLoopConnection = nil
    end
    for _, player in ipairs(Players:GetPlayers()) do
        resetHitbox(player)
    end
end
CombatTab:CreateToggle({
    Name = "Custom Hitbox On/Off",
    CurrentValue = false,
    Flag = "Hitbox_Toggle",
    Callback = function(state)
        if state then
            enableHitbox()
        else
            disableHitbox()
        end
    end
})
CombatTab:CreateInput({
    Name = "Hitbox Size",
    PlaceholderText = tostring(HitboxSize),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then HitboxSize = num end
    end
})
CombatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = HitboxTransparency,
    Flag = "Hitbox_Transparency",
    Callback = function(value)
        HitboxTransparency = value
    end
})
_G.PlayerHeadSize = 25
_G.PlayerHitboxEnabled = false
_G.PlayerHitboxTransparency = 0.5
local function applyPlayerHitbox()
    if not _G.PlayerHitboxEnabled then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local head = character.Head
                head.Size = Vector3.new(_G.PlayerHeadSize, _G.PlayerHeadSize, _G.PlayerHeadSize)
                head.Transparency = _G.PlayerHitboxTransparency
                head.CanCollide = false
                head.Massless = true
            end
        end
    end
end
local function restoreOriginalSizes()
    for _, player in pairs(game.Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("Head") then
            local head = character.Head
            head.Size = Vector3.new(2, 1, 1)
            head.Transparency = 0
            head.CanCollide = true
            head.Massless = false
        end
    end
end
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if _G.PlayerHitboxEnabled and character and character:FindFirstChild("Head") and player ~= game.Players.LocalPlayer then
            local head = character.Head
            head.Size = Vector3.new(_G.PlayerHeadSize, _G.PlayerHeadSize, _G.PlayerHeadSize)
            head.Transparency = _G.PlayerHitboxTransparency
            head.CanCollide = false
            head.Massless = true
        end
    end)
end)
spawn(function()
    while true do
        task.wait(1)
        if _G.PlayerHitboxEnabled then
            applyPlayerHitbox()
        end
    end
end)
CombatTab:CreateToggle({
    Name = "Enable Player Head Hitbox",
    CurrentValue = false,
    Flag = "PlayerHitboxToggle",
    Callback = function(Value)
        _G.PlayerHitboxEnabled = Value
        if Value then
            applyPlayerHitbox()
        else
            restoreOriginalSizes()
        end
    end,
})
CombatTab:CreateInput({
    Name = "Hitbox Size",
    PlaceholderText = "Enter size (default: 25)",
    RemoveTextAfterFocusLost = false,
    Flag = "PlayerHitboxSize",
    Callback = function(Text)
        local size = tonumber(Text)
        if size and size > 0 then
            _G.PlayerHeadSize = size
            if _G.PlayerHitboxEnabled then
                applyPlayerHitbox()
            end
        end
    end,
})
CombatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "PlayerHitboxTransparency",
    Callback = function(Value)
        _G.PlayerHitboxTransparency = Value
        if _G.PlayerHitboxEnabled then
            applyPlayerHitbox()
        end
    end,
})
CombatTab:CreateToggle({
    Name = "Body Lock",
    CurrentValue = false,
    Flag = "Combat_BodyLock",
    Callback = function(state)
        if state then
            enableBodyLock()
        else
            disableBodyLock()
        end
    end
})
CombatTab:CreateInput({
    Name = "Body Lock Distance",
    PlaceholderText = tostring(BodyLockRange),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            BodyLockRange = num
        end
    end
})
local AimFOVSettings = {
    Enabled = false,
    FOVSize = 60,
    TeamCheck = false,
    WallCheck = false,
    MaxDistance = 400,
    MaxTransparency = 0.1,
    AimPart = "Head"
}
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(255, 0, 0)
FOVring.Filled = false
FOVring.NumSides = 64
FOVring.Radius = AimFOVSettings.FOVSize
FOVring.Transparency = AimFOVSettings.MaxTransparency
local function updateFOVCircle()
    if Camera and Camera.ViewportSize then
        FOVring.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVring.Radius = AimFOVSettings.FOVSize
        FOVring.Visible = AimFOVSettings.Enabled
    end
end
local function lookAt(target)
    if not AimFOVSettings.Enabled then return end
    local lookVector = (target - Camera.CFrame.Position).unit
    local newCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    Camera.CFrame = newCFrame
end
local function isPlayerAlive(player)
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end
local function isPlayerVisibleThroughWalls(player, trg_part)
    if not AimFOVSettings.WallCheck then
        return true
    end
    local localPlayerCharacter = LocalPlayer.Character
    if not localPlayerCharacter then
        return false
    end
    local part = player.Character and player.Character:FindFirstChild(trg_part)
    if not part then
        return false
    end
    local ray = Ray.new(Camera.CFrame.Position, part.Position - Camera.CFrame.Position)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayerCharacter})
    if hit and hit:IsDescendantOf(player.Character) then
        return true
    end
    local direction = (part.Position - Camera.CFrame.Position).unit
    local nearRay = Ray.new(Camera.CFrame.Position + direction * 2, direction * AimFOVSettings.MaxDistance)
    local nearHit, _ = workspace:FindPartOnRayWithIgnoreList(nearRay, {localPlayerCharacter})
    return nearHit and nearHit:IsDescendantOf(player.Character)
end
local function getClosestPlayerInFOV()
    if not AimFOVSettings.Enabled then return nil end
    local nearest = nil
    local last = math.huge
    local playerMousePos = Camera.ViewportSize / 2
    local localPlayer = LocalPlayer
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not AimFOVSettings.TeamCheck or player.Team ~= localPlayer.Team) and isPlayerAlive(player) then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local part = player.Character and player.Character:FindFirstChild(AimFOVSettings.AimPart)
            if humanoid and part then
                local ePos, isVisible = Camera:WorldToViewportPoint(part.Position)
                local distance = (Vector2.new(ePos.x, ePos.y) - Vector2.new(playerMousePos.X, playerMousePos.Y)).Magnitude
                if distance < last and isVisible and distance < AimFOVSettings.FOVSize and distance < AimFOVSettings.MaxDistance and isPlayerVisibleThroughWalls(player, AimFOVSettings.AimPart) then
                    last = distance
                    nearest = player
                end
            end
        end
    end
    return nearest
end
RunService.RenderStepped:Connect(function()
    updateFOVCircle()
    local closest = getClosestPlayerInFOV()
    if closest and closest.Character and closest.Character:FindFirstChild(AimFOVSettings.AimPart) then
        lookAt(closest.Character[AimFOVSettings.AimPart].Position)
        FOVring.Color = Color3.fromRGB(0, 255, 0)
    else
        FOVring.Color = Color3.fromRGB(255, 0, 0)
    end
end)
CombatTab:CreateToggle({
    Name = "Aim FOV",
    CurrentValue = false,
    Flag = "Combat_AimFOV",
    Callback = function(state)
        AimFOVSettings.Enabled = state
        updateFOVCircle()
    end
})
CombatTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = AimFOVSettings.FOVSize,
    Flag = "Combat_FOVSize",
    Callback = function(value)
        AimFOVSettings.FOVSize = value
        updateFOVCircle()
    end
})
CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "Combat_TeamCheck",
    Callback = function(state)
        AimFOVSettings.TeamCheck = state
    end
})
CombatTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "Combat_WallCheck",
    Callback = function(state)
        AimFOVSettings.WallCheck = state
    end
})
CombatTab:CreateButton({
    Name = "Camlock (Enygma Locker)",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/meqHVUZh"))()
    end
})
local WalkSpeed = 16
local JumpPower = 50
local loopWalkSpeed = false
local loopJumpPower = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local function startLoopWalkSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        originalWalkSpeed = humanoid.WalkSpeed
    end
    loopWalkSpeed = true
end
local function stopLoopWalkSpeed()
    loopWalkSpeed = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = originalWalkSpeed
    end
end
local function startLoopJumpPower()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        originalJumpPower = humanoid.JumpPower
    end
    loopJumpPower = true
end
local function stopLoopJumpPower()
    loopJumpPower = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = originalJumpPower
    end
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if loopWalkSpeed then humanoid.WalkSpeed = WalkSpeed end
            if loopJumpPower then humanoid.JumpPower = JumpPower end
        end
    end
end)
PlayerTab:CreateInput({
    Name = "WalkSpeed",
    PlaceholderText = tostring(WalkSpeed),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then WalkSpeed = num end
    end
})
PlayerTab:CreateToggle({
    Name = "Loop WalkSpeed",
    CurrentValue = false,
    Flag = "Player_LoopWalkSpeed",
    Callback = function(state)
        if state then startLoopWalkSpeed() else stopLoopWalkSpeed() end
    end
})
PlayerTab:CreateInput({
    Name = "JumpPower",
    PlaceholderText = tostring(JumpPower),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then JumpPower = num end
    end
})
PlayerTab:CreateToggle({
    Name = "Loop JumpPower",
    CurrentValue = false,
    Flag = "Player_LoopJumpPower",
    Callback = function(state)
        if state then startLoopJumpPower() else stopLoopJumpPower() end
    end
})
local GravityValue = 196.2
local loopGravity = false
local originalGravity = Workspace.Gravity
local function startLoopGravity()
    originalGravity = Workspace.Gravity
    loopGravity = true
end
local function stopLoopGravity()
    loopGravity = false
    Workspace.Gravity = originalGravity
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if loopGravity then
            Workspace.Gravity = GravityValue
        end
    end
end)
PlayerTab:CreateInput({
    Name = "Gravity Value",
    PlaceholderText = tostring(GravityValue),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then GravityValue = num end
    end
})
PlayerTab:CreateToggle({
    Name = "Loop Gravity",
    CurrentValue = false,
    Flag = "Player_LoopGravity",
    Callback = function(state)
        if state then
            startLoopGravity()
        else
            stopLoopGravity()
        end
    end
})
local HipHeightValue = 0
local loopHipHeight = false
local originalHipHeight = 0
local function getHumanoid()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end
local function startLoopHipHeight()
    local humanoid = getHumanoid()
    if humanoid then
        originalHipHeight = humanoid.HipHeight
    end
    loopHipHeight = true
end
local function stopLoopHipHeight()
    loopHipHeight = false
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.HipHeight = originalHipHeight
    end
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if loopHipHeight then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid.HipHeight = HipHeightValue
            end
        end
    end
end)
PlayerTab:CreateInput({
    Name = "HipHeight Value",
    PlaceholderText = tostring(HipHeightValue),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num then HipHeightValue = num end
    end
})
PlayerTab:CreateToggle({
    Name = "Loop HipHeight",
    CurrentValue = false,
    Flag = "Player_LoopHipHeight",
    Callback = function(state)
        if state then
            startLoopHipHeight()
        else
            stopLoopHipHeight()
        end
    end
})
local infiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "Player_InfiniteJump",
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})
local noclipEnabled = false
PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "Player_NoClip",
    Callback = function(state)
        noclipEnabled = state
    end
})
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
if _G.FlyForRayfieldLoaded then return end
_G.FlyForRayfieldLoaded = true
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local flySpeed = 50
local flyTransparency = 1
local FLYING = false
local CFloop
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local function startCFrameFlyLoop()
    if not character or not character:FindFirstChild("Head") then return end
    FLYING = true
    local Head = character.Head
    Head.Anchored = true
    CFloop = RunService.Heartbeat:Connect(function(deltaTime)
        local effectiveSpeed = flySpeed * 2
        local moveDirection = humanoid.MoveDirection * (effectiveSpeed * deltaTime)
        local headCFrame, camera = Head.CFrame, workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition, headPosition = cameraCFrame.Position, headCFrame.Position
        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
        Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
    end)
end
local function setFlying(state)
    if FLYING == state or not character or not character.Parent then return end
    if state then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = flyTransparency
            end
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        startCFrameFlyLoop()
    else
        FLYING = false
        if CFloop then
            CFloop:Disconnect()
            CFloop = nil
        end
        if character and character:FindFirstChild("Head") then
            character.Head.Anchored = false
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                if part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 0
                end
            end
        end
    end
end
local keyMap = {
    [Enum.KeyCode.W] = "F",
    [Enum.KeyCode.S] = "B",
    [Enum.KeyCode.A] = "L",
    [Enum.KeyCode.D] = "R",
    [Enum.KeyCode.Q] = "Q",
    [Enum.KeyCode.E] = "E"
}
local valueMap = {
    [Enum.KeyCode.W] = 1,
    [Enum.KeyCode.S] = -1,
    [Enum.KeyCode.A] = -1,
    [Enum.KeyCode.D] = 1,
    [Enum.KeyCode.Q] = -1,
    [Enum.KeyCode.E] = 1
}
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not keyMap[input.KeyCode] then return end
    CONTROL[keyMap[input.KeyCode]] = valueMap[input.KeyCode]
end)
UserInputService.InputEnded:Connect(function(input)
    if keyMap[input.KeyCode] then
        CONTROL[keyMap[input.KeyCode]] = 0
    end
end)
player.CharacterAdded:Connect(function(newChar)
    if CFloop then
        CFloop:Disconnect()
        CFloop = nil
    end
    FLYING = false
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)
local FlyToggle = PlayerTab:CreateToggle({
    Name = "Fly spectator mode",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        setFlying(Value)
    end
})
local SpeedInput = PlayerTab:CreateInput({
    Name = "Fly Speed",
    PlaceholderText = "Enter speed (1-500)",
    RemoveTextAfterFocusLost = false,
    Flag = "FlySpeedInput",
    Callback = function(Text)
        local speed = tonumber(Text)
        if speed and speed >= 1 and speed <= 500 then
            flySpeed = speed
        end
    end
})
local isInvisible = false
local function toggleInvisibility()
	if not game.Players.LocalPlayer.Character then return end
	isInvisible = not isInvisible
	local player = game.Players.LocalPlayer
	local char = player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if isInvisible then
		local savedPosition = hrp.CFrame
		player.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
		task.wait(0.15)
		local seat = Instance.new("Seat")
		seat.Name = "invischair"
		seat.Anchored = false
		seat.CanCollide = false
		seat.Transparency = 1
		seat.Position = Vector3.new(-25.95, 84, 3537.55)
		seat.Parent = workspace
		local weld = Instance.new("Weld")
		weld.Part0 = seat
		weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
		weld.Parent = seat
		task.wait()
		seat.CFrame = savedPosition
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 0.5
			end
		end
	else
		local invisChair = workspace:FindFirstChild("invischair")
		if invisChair then invisChair:Destroy() end
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then
				part.Transparency = 0
			end
		end
	end
end
PlayerTab:CreateToggle({
	Name = "Invisibility",
	CurrentValue = false,
	Flag = "InvisibilityToggle",
	Callback = function(value)
		toggleInvisibility()
	end
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local platform = nil
local connection = nil
local offsetY = -3.5
PlayerTab:CreateInput({
	Name = "Platform height",
	PlaceholderText = "-3.5",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		local number = tonumber(Text)
		if number then
			offsetY = number
		end
	end
})
PlayerTab:CreateToggle({
	Name = "Platform",
	CurrentValue = false,
	Flag = "PlatformToggle",
	Callback = function(Value)
		if Value then
			local character = player.Character or player.CharacterAdded:Wait()
			local hrp = character:WaitForChild("HumanoidRootPart")
			platform = Instance.new("Part")
			platform.Size = Vector3.new(6, 1, 6)
			platform.Anchored = true
			platform.CanCollide = true
			platform.Transparency = 0.7
			platform.Color = Color3.fromRGB(255, 0, 0)
			platform.Name = "FloatingPlatform"
			platform.Parent = workspace
			connection = RunService.RenderStepped:Connect(function()
				if character and hrp and platform then
					platform.Position = hrp.Position + Vector3.new(0, offsetY, 0)
				end
			end)
		else
			if connection then
				connection:Disconnect()
				connection = nil
			end
			if platform then
				platform:Destroy()
				platform = nil
			end
		end
	end
})
PlayerTab:CreateButton({
    Name = "Anti-AFK",
    Callback = function()
        LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
})
PlayerTab:CreateButton({
    Name = "Anti-Lag",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            elseif obj:IsA("Explosion") then
                obj:Destroy()
            elseif obj:IsA("Decal") then
                obj.Transparency = 1
            elseif obj:IsA("Texture") then
                obj:Destroy()
            end
        end
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 100000
        lighting.FogStart = 0
        lighting.FogColor = Color3.new(1,1,1)
        lighting.Brightness = 1
    end
})
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local OriginalFOV = camera.FieldOfView
GameplayTab:CreateToggle({
    Name = "FOV 100",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(Value)
        if Value then
            camera.FieldOfView = 100
        else
            camera.FieldOfView = OriginalFOV
        end
    end
})
local Lighting = game:GetService("Lighting")
local function applyBloodRedSky()
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
    local redSky = Instance.new("Sky")
    redSky.Name = "BloodRedSky"
    local assetId = "rbxassetid://151164359"
    redSky.SkyboxBk = assetId
    redSky.SkyboxDn = assetId
    redSky.SkyboxFt = assetId
    redSky.SkyboxLf = assetId
    redSky.SkyboxRt = assetId
    redSky.SkyboxUp = assetId
    redSky.Parent = Lighting
    Lighting.Ambient = Color3.fromRGB(150, 0, 0)
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 20, 20)
    Lighting.FogColor = Color3.fromRGB(120, 0, 0)
    Lighting.FogStart = 0
    Lighting.FogEnd = 800
    Lighting.Brightness = 2
    Lighting.ClockTime = 18
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.TintColor = Color3.fromRGB(200, 0, 0)
    colorCorrection.Contrast = 0.2
    colorCorrection.Saturation = -0.2
    colorCorrection.Brightness = 0.1
    colorCorrection.Parent = Lighting
end
local function restoreDefaultSky()
    for _, obj in pairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") or obj:IsA("ColorCorrectionEffect") then
            obj:Destroy()
        end
    end
    local defaultSky = Instance.new("Sky")
    defaultSky.Name = "DefaultSky"
    local defaultId = "rbxassetid://159454299"
    defaultSky.SkyboxBk = defaultId
    defaultSky.SkyboxDn = defaultId
    defaultSky.SkyboxFt = defaultId
    defaultSky.SkyboxLf = defaultId
    defaultSky.SkyboxRt = defaultId
    defaultSky.SkyboxUp = defaultId
    defaultSky.Parent = Lighting
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.FogColor = Color3.fromRGB(255, 255, 255)
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.Brightness = 3
    Lighting.ClockTime = 14
end
GameplayTab:CreateToggle({
    Name = "Enygma House:)",
    CurrentValue = false,
    Flag = "Troll_BloodRedSky",
    Callback = function(state)
        if state then
            applyBloodRedSky()
        else
            restoreDefaultSky()
        end
    end
})
PlayerTab:CreateButton({
    Name = "Give TP Tool",
    Callback = function()
        local player = game.Players.LocalPlayer
        local backpack = player:WaitForChild("Backpack")
        if backpack:FindFirstChild("EnygmaTp") then
            backpack:FindFirstChild("EnygmaTp"):Destroy()
        end
        if player.Character and player.Character:FindFirstChild("EnygmaTp") then
            player.Character:FindFirstChild("EnygmaTp"):Destroy()
        end
        local mouse = player:GetMouse()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "EnygmaTp"
        tool.Activated:Connect(function()
            local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
            pos = CFrame.new(pos.X, pos.Y, pos.Z)
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = pos
            end
        end)
        tool.Parent = backpack
    end
})
local NPCESP = false
local connection
local function addESP(model)
if not NPCESP then return end
if game.Players:GetPlayerFromCharacter(model) then return end
if model:FindFirstChild("NPC_ESP") then return end
local h = Instance.new("Highlight")
h.Name = "NPC_ESP"
h.FillColor = Color3.fromRGB(255,0,0)
h.OutlineColor = Color3.fromRGB(255,255,255)
h.Parent = model
end
local function enableESP()
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent then
        addESP(v.Parent)
    end
end
connection = workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Humanoid") and v.Parent then
        task.wait()
        addESP(v.Parent)
    end
end)
end
local function disableESP()
if connection then
connection:Disconnect()
connection = nil
end
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Highlight") and v.Name == "NPC_ESP" then
        v:Destroy()
    end
end
end
FarmTab:CreateToggle({
Name = "NPC ESP",
CurrentValue = false,
Callback = function(v)
NPCESP = v
if v then
enableESP()
else
disableESP()
end
end
})
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local NPCESP = false
local drawings = {}
local renderConn
local addConn
local function addESP(model)
if not NPCESP then return end
if Players:GetPlayerFromCharacter(model) then return end
if drawings[model] then return end
local root = model:FindFirstChild("HumanoidRootPart")
if not root then return end
local text = Drawing.new("Text")
text.Size = 16
text.Center = true
text.Outline = true
text.Color = Color3.fromRGB(255,0,0)
text.Text = model.Name
text.Visible = false
drawings[model] = text
end
local function enableESP()
for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("Humanoid") and v.Parent then
        addESP(v.Parent)
    end
end
addConn = workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Humanoid") and v.Parent then
        task.wait()
        addESP(v.Parent)
    end
end)
renderConn = RunService.RenderStepped:Connect(function()
    for model,draw in pairs(drawings) do
        if model and model:FindFirstChild("HumanoidRootPart") then
            local pos, visible = Camera:WorldToViewportPoint(model.HumanoidRootPart.Position)
            if visible then
                draw.Position = Vector2.new(pos.X, pos.Y)
                draw.Visible = true
            else
                draw.Visible = false
            end
        else
            draw:Remove()
            drawings[model] = nil
        end
    end
end)
end
local function disableESP()
if addConn then addConn:Disconnect() end
if renderConn then renderConn:Disconnect() end
for _,v in pairs(drawings) do
    v:Remove()
end
drawings = {}
end
FarmTab:CreateToggle({
Name = "NPC Name ESP",
CurrentValue = false,
Callback = function(v)
NPCESP = v
if v then
enableESP()
else
disableESP()
end
end
})
_G.HeadSize = 12
_G.HitboxEnabled = false
_G.HitboxTransparency = 0.6
spawn(function()
    while task.wait(0.5) do
        for _, v in pairs(game.Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(v) then
                local head = v:FindFirstChild("Head")
                if head and _G.HitboxEnabled then
                    if head.Size ~= Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize) then
                        head.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                        head.Transparency = _G.HitboxTransparency
                        head.CanCollide = false
                        head.Massless = true
                    end
                elseif head and not _G.HitboxEnabled then
                    if head.Size ~= Vector3.new(2, 1, 1) then
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                        head.CanCollide = true
                        head.Massless = false
                    end
                end
            end
        end
    end
end)
FarmTab:CreateToggle({
    Name = "Enable NPC Hitbox",
    CurrentValue = false,
    Flag = "NPCHitboxToggle",
    Callback = function(Value)
        _G.HitboxEnabled = Value
    end,
})
FarmTab:CreateInput({
    Name = "Hitbox Size",
    PlaceholderText = "Enter desired size",
    RemoveTextAfterFocusLost = false,
    Flag = "HitboxSizeInput",
    Callback = function(Text)
        local size = tonumber(Text)
        if size and size > 0 then
            _G.HeadSize = size
        end
    end,
})
FarmTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.6,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        _G.HitboxTransparency = Value
    end,
})
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
_G.AimbotNPC = false
_G.WallCheck = false
_G.FOV_Size = 150
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true
FOVCircle.Radius = _G.FOV_Size
FarmTab:CreateToggle({
    Name = "Aimbot NPC",
    CurrentValue = false,
    Flag = "AimbotNPC",
    Callback = function(Value)
        _G.AimbotNPC = Value
    end
})
FarmTab:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "WallCheckNPC",
    Callback = function(Value)
        _G.WallCheck = Value
    end
})
FarmTab:CreateSlider({
    Name = "FOV Size",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = 150,
    Flag = "FOVSizeNPC",
    Callback = function(Value)
        _G.FOV_Size = Value
        FOVCircle.Radius = Value
    end
})
local function GetTarget()
    local target = nil
    local dist = _G.FOV_Size
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent and v.Parent:FindFirstChild("Head") and v.Health > 0 then
            if v.Parent ~= LocalPlayer.Character then
                local head = v.Parent.Head
                if not Players:GetPlayerFromCharacter(v.Parent) then
                    local pos, visible = Camera:WorldToViewportPoint(head.Position)
                    if visible then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < dist then
                            if _G.WallCheck then
                                local parts = Camera:GetPartsObscuringTarget({Camera.CFrame.Position, head.Position}, {LocalPlayer.Character, v.Parent})
                                if #parts == 0 then
                                    target = head
                                    dist = mag
                                end
                            else
                                target = head
                                dist = mag
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end
RunService.RenderStepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Radius = _G.FOV_Size
    if _G.AimbotNPC then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
end)
local ESPEnabled = false
local ESPColor = Color3.fromRGB(255,0,0)
local function createESP(obj)
    if obj:FindFirstChild("ItemESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ItemESP"
    billboard.Size = UDim2.new(0,70,0,30)
    billboard.AlwaysOnTop = true
    billboard.Adornee = obj
    billboard.Parent = obj
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,1,0)
    label.Text = obj.Name
    label.TextColor3 = ESPColor
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
end
local function removeESP()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("ItemESP") then
            v.ItemESP:Destroy()
        end
    end
end
local function scan()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            local parent = v.Parent
            if parent and parent:IsA("BasePart") then
                createESP(parent)
            end
        end
        if v:IsA("Tool") then
            if v:FindFirstChild("Handle") then
                createESP(v.Handle)
            end
        end
    end
end
workspace.DescendantAdded:Connect(function(v)
    task.wait(0.5)
    if not ESPEnabled then return end
    if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
        local parent = v.Parent
        if parent and parent:IsA("BasePart") then
            createESP(parent)
        end
    end
    if v:IsA("Tool") then
        if v:FindFirstChild("Handle") then
            createESP(v.Handle)
        end
    end
end)
ItemsTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            scan()
        else
            removeESP()
        end
    end
})
local HighlightEnabled = false
local HighlightColor = Color3.fromRGB(255,0,0)
local function createHighlight(obj)
    if obj:FindFirstChild("ItemHighlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ItemHighlight"
    highlight.FillColor = HighlightColor
    highlight.OutlineColor = HighlightColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = obj
end
local function removeHighlights()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:FindFirstChild("ItemHighlight") then
            v.ItemHighlight:Destroy()
        end
    end
end
local function scanItems()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
            local parent = v.Parent
            if parent and parent:IsA("BasePart") then
                createHighlight(parent)
            end
        end
        if v:IsA("Tool") then
            if v:FindFirstChild("Handle") then
                createHighlight(v.Handle)
            end
        end
    end
end
workspace.DescendantAdded:Connect(function(v)
    task.wait(0.5)
    if not HighlightEnabled then return end
    if v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then
        local parent = v.Parent
        if parent and parent:IsA("BasePart") then
            createHighlight(parent)
        end
    end
    if v:IsA("Tool") then
        if v:FindFirstChild("Handle") then
            createHighlight(v.Handle)
        end
    end
end)
ItemsTab:CreateToggle({
    Name = "Item Highlight ESP",
    CurrentValue = false,
    Flag = "ItemHighlightESP",
    Callback = function(Value)
        HighlightEnabled = Value
        if HighlightEnabled then
            scanItems()
        else
            removeHighlights()
        end
    end
})
local function clickAll()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
        end
    end
end
ItemsTab:CreateButton({
    Name = "Click All ClickDetectors",
    Callback = function()
        clickAll()
    end
})
local ItemName = ""
ItemsTab:CreateInput({
    Name = "Item Name",
    PlaceholderText = "item",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        ItemName = Text
    end
})
local function getTouchItem(name)
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find(name:lower()) then
            v.CFrame = hrp.CFrame
        end
    end
end
ItemsTab:CreateButton({
    Name = "Get Touch Item",
    Callback = function()
        if ItemName ~= "" then
            getTouchItem(ItemName)
        end
    end
})
local function makePromptsInstant()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end
ItemsTab:CreateButton({
    Name = "Instant ProximityPrompts",
    Callback = function()
        makePromptsInstant()
    end
})
local PromptRange = 10
ItemsTab:CreateInput({
    Name = "Prompt Range",
    PlaceholderText = "Ex: 50",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            PromptRange = num
        end
    end
})
local function setPromptRange()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.MaxActivationDistance = PromptRange
        end
    end
end
ItemsTab:CreateButton({
    Name = "Set Prompt Range",
    Callback = function()
        setPromptRange()
    end
})
local TargetName = ""
local LoopTP = false
local LoopBring = false
local player = game.Players.LocalPlayer
TeleportsTab:CreateInput({
    Name = "Target Name",
    PlaceholderText = "Player / NPC / Item",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        TargetName = Text
    end
})
local function findTarget()
    for _,p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower():find(TargetName:lower()) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                return p.Character.HumanoidRootPart
            end
        end
    end
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find(TargetName:lower()) then
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                return v.HumanoidRootPart
            elseif v:IsA("BasePart") then
                return v
            end
        end
    end
end
local function teleportBehindTarget()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local target = findTarget()
    if hrp and target then
        local behind = target.CFrame.LookVector * -5
        local pos = target.Position + behind
        hrp.CFrame = CFrame.new(pos, target.Position)
    end
end
local function bringTarget()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local target = findTarget()
    if hrp and target then
        local forward = hrp.CFrame.LookVector * 6
        local pos = hrp.Position + forward
        target.CFrame = CFrame.new(pos)
    end
end
TeleportsTab:CreateButton({
    Name = "Teleport Behind Target",
    Callback = function()
        teleportBehindTarget()
    end
})
TeleportsTab:CreateToggle({
    Name = "Loop Teleport Behind",
    CurrentValue = false,
    Flag = "LoopTPBehind",
    Callback = function(Value)
        LoopTP = Value
        while LoopTP do
            teleportBehindTarget()
            task.wait(0.05)
        end
    end
})
TeleportsTab:CreateToggle({
    Name = "Loop Bring",
    CurrentValue = false,
    Flag = "LoopBring",
    Callback = function(Value)
        LoopBring = Value
        while LoopBring do
            bringTarget()
            task.wait(0.05)
        end
    end
})
local player = game.Players.LocalPlayer
local bringingEnabled = false
local bringDistance = 5
local connection = nil
local function isPlayerModel(model)
    return game.Players:GetPlayerFromCharacter(model) ~= nil
end
local function bringNPCs()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model")
        and v:FindFirstChildOfClass("Humanoid")
        and not isPlayerModel(v) then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local targetHRP = v:FindFirstChild("HumanoidRootPart")
            if hum and targetHRP and hum.Health > 0 then
                local offset = hrp.CFrame.LookVector * bringDistance
                local pos = hrp.Position + offset + Vector3.new(0, 0, 0)
                targetHRP.CFrame = CFrame.new(pos, hrp.Position)
            end
        end
    end
end
local function startBringing()
    if connection then connection:Disconnect() end
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if bringingEnabled then
            bringNPCs()
        end
    end)
end
TeleportsTab:CreateToggle({
    Name = "bring NPCs",
    CurrentValue = false,
    Flag = "ToggleNPCs",
    Callback = function(Value)
        bringingEnabled = Value
        if Value then
            startBringing()
        end
    end
})
TeleportsTab:CreateSlider({
    Name = "Bring npc distance",
    Range = {0, 50},
    Increment = 1,
    CurrentValue = bringDistance,
    Flag = "SliderDistancia",
    Callback = function(Value)
        bringDistance = Value
    end
})
local player = game.Players.LocalPlayer
local LoopBringPlayers = false
local PlayerDistance = 5
local function bringPlayers()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local targetHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetHRP and hum and hum.Health > 0 then
                local offset = hrp.CFrame.LookVector * PlayerDistance
                local pos = hrp.Position + offset + Vector3.new(0,0,0)
                targetHRP.CFrame = CFrame.new(pos, pos + hrp.CFrame.LookVector)
            end
        end
    end
end
TeleportsTab:CreateSlider({
    Name = "Player Bring Distance",
    Range = {0, 50},
    Increment = 1,
    CurrentValue = 5,
    Flag = "PlayerBringDistance",
    Callback = function(Value)
        PlayerDistance = Value
    end
})
TeleportsTab:CreateToggle({
    Name = "Loop Bring Players ",
    CurrentValue = false,
    Flag = "LoopBringPlayersBack",
    Callback = function(Value)
        LoopBringPlayers = Value
        while LoopBringPlayers do
            bringPlayers()
            task.wait(0.05)
        end
    end
})
local player = game.Players.LocalPlayer
local RandomLoop = false
local CurrentTarget = nil
local function getRandomPlayer()
    local players = {}
    for _,p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                table.insert(players, p)
            end
        end
    end
    if #players > 0 then
        return players[math.random(1,#players)]
    end
end
local function teleportBehindTarget(target)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not target.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if targetHRP and hum and hum.Health > 0 then
        local behind = targetHRP.CFrame.LookVector * -5
        local pos = targetHRP.Position + behind
        hrp.CFrame = CFrame.new(pos, targetHRP.Position)
    else
        CurrentTarget = nil
    end
end
TeleportsTab:CreateToggle({
    Name = "Random Player Behind TP",
    CurrentValue = false,
    Flag = "RandomBehindTP",
    Callback = function(Value)
        RandomLoop = Value
        CurrentTarget = nil
        while RandomLoop do
            if not CurrentTarget then
                CurrentTarget = getRandomPlayer()
            end
            if CurrentTarget then
                teleportBehindTarget(CurrentTarget)
            end
            task.wait(0.05)
        end
    end
})
local player = game.Players.LocalPlayer
local SavedCFrame = nil
local SavedSpawn = nil
local LoopSavedTP = false
TeleportsTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            SavedCFrame = char.HumanoidRootPart.CFrame
        end
    end
})
TeleportsTab:CreateButton({
    Name = "Teleport To Saved Position",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and SavedCFrame then
            char.HumanoidRootPart.CFrame = SavedCFrame
        end
    end
})
TeleportsTab:CreateToggle({
    Name = "Loop Teleport To Saved Position",
    CurrentValue = false,
    Flag = "LoopSavedTeleport",
    Callback = function(Value)
        LoopSavedTP = Value
        while LoopSavedTP do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and SavedCFrame then
                char.HumanoidRootPart.CFrame = SavedCFrame
            end
            task.wait(0.05)
        end
    end
})
TeleportsTab:CreateButton({
    Name = "Set Spawn Point",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            SavedSpawn = char.HumanoidRootPart.CFrame
        end
    end
})
player.CharacterAdded:Connect(function(char)
    if SavedSpawn then
        task.wait(0.5)
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = SavedSpawn
    end
end)
CombatTab:CreateButton({
    Name = "predict Lock(not mine)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Enygmaxit/Cam-Lock/main/obf_Wxr6QgzF76G1y2Ch77KN4Zt5Nz0A6GIl61gitv3mRR2t3V103al5d0g26s4KY04r.lua.txt"))()
    end,
})
PlayerTab:CreateButton({
    Name = "Fly GUI",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Enygmaxit/Fly-gui/main/fly-gui.txt"))()
    end,
})