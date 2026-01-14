-- YOU VS HOMER SCRIPT [v3.9.4]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local T_INFO = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local TARGET_ID = 8816493943
local PROFILE_LINK = "https://www.roblox.com/users/"..TARGET_ID.."/profile"

-- // GLOBAL STATES
_G.espActive = false
_G.noclipActive = false
_G.floatActive = false
_G.afkFarmActive = false
_G.fullbrightActive = false
_G.zoomUnlocked = false
_G.killBartsActive = false
_G.biggerHitboxActive = false

local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origGlobalShadows = Lighting.GlobalShadows

-- // ROLE HELPER (DYNAMIC)
local function getRoleInfo(p)
    if not p or not p.Character then return "Lobby", Color3.new(1, 1, 1) end
    if p.Character:FindFirstChild("Homer") or (p.Team and p.Team.Name == "Homer") then return "HOMER", Color3.new(1, 0, 0) end
    if p.Character:FindFirstChild("Bart") or (p.Team and p.Team.Name == "Bart") then return "BART", Color3.new(1, 1, 0) end
    return "Player", Color3.new(1, 1, 1)
end

local function ClearAllESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            if v.Character:FindFirstChild("HHubESP") then v.Character.HHubESP:Destroy() end
            if v.Character:FindFirstChild("HHubTag") then v.Character.HHubTag:Destroy() end
        end
    end
end

-- // FOLLOW CHECKER (STRICT)
local function checkFollowStatus()
    local success, result = pcall(function()
        local url = "https://friends.roproxy.com/v1/users/"..player.UserId.."/followings?limit=100"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, followedUser in pairs(data.data) do
                if tonumber(followedUser.id) == TARGET_ID then return true end
            end
        end
        return false
    end)
    return success and result
end

-- // MAIN CHEAT MENU
function StartCheatMenu()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "HomerHubGui"; sg.DisplayOrder = 999
    
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 520, 0, 0); main.Position = UDim2.new(0.5, -260, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BackgroundTransparency = 0.2
    main.ClipsDescendants = true; main.Active = true; main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    
    -- Modal for Closing
    local modal = Instance.new("Frame", sg)
    modal.Size = UDim2.new(0, 360, 0, 0); modal.Position = UDim2.new(0.5, -180, 0.5, -90)
    modal.BackgroundColor3 = Color3.fromRGB(20, 20, 20); modal.Visible = false; modal.ZIndex = 100; Instance.new("UICorner", modal)
    local modalTitle = Instance.new("TextLabel", modal); modalTitle.Size = UDim2.new(1, 0, 0, 50); modalTitle.BackgroundTransparency = 1; modalTitle.Text = "ARE YOU SURE?"; modalTitle.TextColor3 = Color3.new(1,1,1); modalTitle.Font = "GothamBold"; modalTitle.TextSize = 18
    local yesBtn = Instance.new("TextButton", modal); yesBtn.Size = UDim2.new(0, 130, 0, 45); yesBtn.Position = UDim2.new(0.08, 0, 0.65, 0); yesBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); yesBtn.Text = "YES"; yesBtn.Font = "GothamBold"; yesBtn.TextSize = 18; yesBtn.ZIndex = 101; Instance.new("UICorner", yesBtn)
    local noBtn = Instance.new("TextButton", modal); noBtn.Size = UDim2.new(0, 130, 0, 45); noBtn.Position = UDim2.new(0.55, 0, 0.65, 0); noBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); noBtn.Text = "NO"; noBtn.Font = "GothamBold"; noBtn.TextSize = 18; noBtn.ZIndex = 101; Instance.new("UICorner", noBtn)
    
    local closeBtn = Instance.new("TextButton", main); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -40, 0, 10); closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.Font = "GothamBold"; closeBtn.TextSize = 18; Instance.new("UICorner", closeBtn)

    closeBtn.MouseButton1Click:Connect(function() modal.Visible = true; TweenService:Create(modal, T_INFO, {Size = UDim2.new(0, 360, 0, 190)}):Play() end)
    noBtn.MouseButton1Click:Connect(function() local t = TweenService:Create(modal, T_INFO, {Size = UDim2.new(0, 360, 0, 0)}); t:Play(); t.Completed:Connect(function() modal.Visible = false end) end)
    yesBtn.MouseButton1Click:Connect(function() ClearAllESP(); sg:Destroy() end)

    local sidebar = Instance.new("Frame", main); sidebar.Size = UDim2.new(0, 140, 1, -60); sidebar.Position = UDim2.new(0, 5, 0, 55); sidebar.BackgroundColor3 = Color3.new(0,0,0); sidebar.BackgroundTransparency = 0.6; Instance.new("UICorner", sidebar)
    local container = Instance.new("Frame", main); container.Size = UDim2.new(1, -165, 1, -70); container.Position = UDim2.new(0, 155, 0, 60); container.BackgroundTransparency = 1
    local pages = {}

    local function CreateTab(name, order)
        local p = Instance.new("ScrollingFrame", container); p.Size = UDim2.new(1, 0, 1, 0); p.Visible = (order == 1); p.BackgroundTransparency = 1; p.ScrollBarThickness = 2; p.CanvasSize = UDim2.new(0,0,1.5,0)
        Instance.new("UIListLayout", p).Padding = UDim.new(0, 12); pages[name] = p
        local b = Instance.new("TextButton", sidebar); b.Size = UDim2.new(0.9, 0, 0, 45); b.Position = UDim2.new(0.05, 0, 0, (order-1)*50 + 10); b.BackgroundColor3 = Color3.fromRGB(255,255,255); b.BackgroundTransparency = 0.9; b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 16; Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() for _, pg in pairs(pages) do pg.Visible = false end p.Visible = true end)
    end

    local function AddBtn(txt, pg, toggleVar, cb)
        local btn = Instance.new("TextButton", pages[pg]); btn.Size = UDim2.new(1, -10, 0, 52); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.BackgroundTransparency = 0.4; btn.Text = txt; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; btn.TextSize = 18; Instance.new("UICorner", btn)
        local function update()
            if toggleVar and _G[toggleVar] then btn.BackgroundColor3 = Color3.fromRGB(0, 200, 80) else btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
        end
        btn.MouseButton1Click:Connect(function() cb(btn) update() end)
        update()
    end

    CreateTab("Main", 1); CreateTab("Player", 2); CreateTab("Visuals", 3); CreateTab("Teleport", 4); CreateTab("Killer", 5)
    
    AddBtn("Noclip", "Player", "noclipActive", function() _G.noclipActive = not _G.noclipActive end)
    AddBtn("Float Platform", "Player", "floatActive", function() _G.floatActive = not _G.floatActive end)
    AddBtn("Unlock Zoom", "Player", "zoomUnlocked", function() _G.zoomUnlocked = not _G.zoomUnlocked; player.CameraMaxZoomDistance = _G.zoomUnlocked and 10000 or 50 end)
    AddBtn("Toggle ESP", "Visuals", "espActive", function() _G.espActive = not _G.espActive if not _G.espActive then ClearAllESP() end end)
    AddBtn("Fullbright", "Visuals", "fullbrightActive", function() _G.fullbrightActive = not _G.fullbrightActive if not _G.fullbrightActive then Lighting.Brightness = origBrightness; Lighting.ClockTime = origClockTime; Lighting.GlobalShadows = origGlobalShadows end end)
    AddBtn("Teleport Lobby", "Teleport", nil, function() local l = Workspace:FindFirstChild("lobbyCage") if l then local sp = l.spawns:GetChildren() local t = sp[math.random(1, #sp)]:FindFirstChildWhichIsA("BasePart", true) if t then player.Character.HumanoidRootPart.CFrame = t.CFrame * CFrame.new(0, 3, 0) end end end)
    AddBtn("Teleport Map", "Teleport", nil, function() if Workspace:FindFirstChild("map") then for _, m in pairs(Workspace.map:GetChildren()) do local s = m:FindFirstChild("spawns") if s then local t = s:FindFirstChildWhichIsA("BasePart", true) if t then player.Character.HumanoidRootPart.CFrame = t.CFrame * CFrame.new(0, 3, 0) break end end end end end)
    AddBtn("Autofarm (7s)", "Teleport", "afkFarmActive", function() _G.afkFarmActive = not _G.afkFarmActive end)
    AddBtn("Kill All Barts", "Killer", "killBartsActive", function() _G.killBartsActive = not _G.killBartsActive end)
    AddBtn("Bigger Hitboxes", "Killer", "biggerHitboxActive", function() _G.biggerHitboxActive = not _G.biggerHitboxActive end)

    TweenService:Create(main, T_INFO, {Size = UDim2.new(0, 520, 0, 430)}):Play()
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode.LeftControl then local open = main.Size.Y.Offset > 0 TweenService:Create(main, T_INFO, {Size = open and UDim2.new(0, 520, 0, 0) or UDim2.new(0, 520, 0, 430), BackgroundTransparency = open and 1 or 0.2}):Play() end end)

    local floatPart = Instance.new("Part"); floatPart.Anchored = true; floatPart.Size = Vector3.new(10,1,10); floatPart.Transparency = 1
    
    RunService.RenderStepped:Connect(function()
        if _G.fullbrightActive then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false end
        if _G.noclipActive and player.Character then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if _G.floatActive and player.Character then floatPart.Parent = Workspace; floatPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0,-3.5,0) else floatPart.Parent = nil end
        
        if _G.killBartsActive and getRoleInfo(player) == "HOMER" then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and getRoleInfo(v) == "BART" then
                    player.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,1)
                end
            end
        end

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                if _G.biggerHitboxActive then
                    hrp.Size = Vector3.new(12, 12, 12); hrp.Transparency = 0.5; hrp.BrickColor = BrickColor.new("Bright red")
                else
                    hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1
                end
            end
        end

        if _G.espActive then 
            for _, v in pairs(Players:GetPlayers()) do 
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then 
                    local role, color = getRoleInfo(v) 
                    local h = v.Character:FindFirstChild("HHubESP") or Instance.new("Highlight", v.Character) 
                    h.Name = "HHubESP"; h.FillColor = color; h.DepthMode = "AlwaysOnTop" 
                    local head = v.Character:FindFirstChild("Head") 
                    if head then
                        local tag = v.Character:FindFirstChild("HHubTag") or Instance.new("BillboardGui", v.Character)
                        tag.Name = "HHubTag"; tag.Size = UDim2.new(0, 200, 0, 50); tag.AlwaysOnTop = true; tag.Adornee = head; tag.ExtentsOffset = Vector3.new(0, 3, 0) 
                        local lbl = tag:FindFirstChild("MainLabel") or Instance.new("TextLabel", tag)
                        lbl.Name = "MainLabel"; lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Font = "GothamBold"; lbl.TextSize = 16; lbl.Text = role .. " | " .. v.Name; lbl.TextColor3 = color
                    end 
                end 
            end 
        end
    end)
    
    -- // AUTOFARM LOOP (TRIGGER -> 7S WAIT -> REPEAT)
    task.spawn(function() 
        while true do 
            if _G.afkFarmActive and player.Character then 
                local w = Workspace:FindFirstChild("winpad", true) or Workspace:FindFirstChild("WinPart", true)
                if w then 
                    player.Character.HumanoidRootPart.CFrame = w.CFrame * CFrame.new(0, 7, 0)
                    task.wait(7)
                else task.wait(1) end
            else task.wait(1) end
        end 
    end)
end

-- // VERIFICATION GATE
function StartVerification()
    local sg = Instance.new("ScreenGui", game.CoreGui); sg.Name = "HomerVerifyGui"
    local vMain = Instance.new("Frame", sg)
    vMain.Size = UDim2.new(0, 400, 0, 0); vMain.Position = UDim2.new(0.5, -200, 0.5, -125); vMain.BackgroundColor3 = Color3.fromRGB(15, 15, 15); vMain.BackgroundTransparency = 0.2; vMain.ClipsDescendants = true; Instance.new("UICorner", vMain)
    
    local vTitle = Instance.new("TextLabel", vMain); vTitle.Size = UDim2.new(1, 0, 0, 80); vTitle.BackgroundTransparency = 1; vTitle.Text = "VERIFICATION REQUIRED\nFOLLOW THE DEVELOPER"; vTitle.TextColor3 = Color3.new(1,1,1); vTitle.Font = "GothamBold"; vTitle.TextSize = 18
    local verifyBtn = Instance.new("TextButton", vMain); verifyBtn.Size = UDim2.new(0, 320, 0, 45); verifyBtn.Position = UDim2.new(0.5, -160, 0, 100); verifyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50); verifyBtn.Text = "VERIFY FOLLOW"; verifyBtn.Font = "GothamBold"; verifyBtn.TextSize = 17; Instance.new("UICorner", verifyBtn)
    local copyBtn = Instance.new("TextButton", vMain); copyBtn.Size = UDim2.new(0, 320, 0, 45); copyBtn.Position = UDim2.new(0.5, -160, 0, 160); copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); copyBtn.Text = "COPY PROFILE LINK"; copyBtn.Font = "GothamBold"; copyBtn.TextColor3 = Color3.new(1,1,1); copyBtn.TextSize = 17; Instance.new("UICorner", copyBtn)

    copyBtn.MouseButton1Click:Connect(function() setclipboard(PROFILE_LINK); copyBtn.Text = "LINK COPIED!"; task.wait(2); copyBtn.Text = "COPY PROFILE LINK" end)
    verifyBtn.MouseButton1Click:Connect(function()
        verifyBtn.Text = "CHECKING..."
        if checkFollowStatus() then
            verifyBtn.Text = "SUCCESS!"; verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100); task.wait(0.5)
            TweenService:Create(vMain, T_INFO, {Size = UDim2.new(0, 400, 0, 0), BackgroundTransparency = 1}):Play()
            task.wait(0.6); sg:Destroy(); StartCheatMenu()
        else
            verifyBtn.Text = "NOT FOLLOWED!"; verifyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); task.wait(2); verifyBtn.Text = "VERIFY FOLLOW"; verifyBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        end
    end)
    TweenService:Create(vMain, T_INFO, {Size = UDim2.new(0, 400, 0, 250)}):Play()
end

StartVerification()
