-- PLAYTEST SCRIPT [α1.2.0]
local OWNER_ID = 8816493943 
local TARGET_USERNAME = "derWolfderwutet"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local profileLink = "https://www.roblox.com/users/" .. OWNER_ID .. "/profile"

-- UI COLORS & THEME
local Theme = {
    Main = Color3.fromRGB(10, 10, 10),
    Accent = Color3.fromRGB(170, 0, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(25, 25, 25),
    Hover = Color3.fromRGB(40, 40, 40)
}

-- 1. STABLE VERIFICATION
local function isFollowing()
    if player.UserId == OWNER_ID then return true end
    local success, result = pcall(function()
        local url = "https://friends.roproxy.com/v1/users/" .. player.UserId .. "/followings?limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        if data and data.data then
            for _, v in pairs(data.data) do
                if v.id == OWNER_ID then return true end
            end
        end
        return false
    end)
    return success and result or false
end

-- 2. ANIMATION UTILS
local function SmoothPop(obj)
    obj.Size = UDim2.new(0, 0, 0, 0)
    obj.Visible = true
    local targetSize = (obj.Name == "MainFrame") and UDim2.new(0, 280, 0, 320) or UDim2.new(0, 300, 0, 220)
    TweenService:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = targetSize}):Play()
end

-- 3. INTERFACE BUILDER
local function createButton(parent, text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text
    btn.Parent = parent
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Theme.Button
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Theme.Accent
    stroke.Thickness = 1.2
    stroke.Transparency = 0.6

    -- Immersive Hover Effects
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Hover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Button}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.6}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- 4. MAIN HUB
local function LoadMainScript()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame")
    f.Name = "MainFrame"
    f.Parent = sg
    f.BackgroundColor3 = Theme.Main
    f.BackgroundTransparency = 0.15
    f.Position = UDim2.new(0.5, -140, 0.5, -160)
    f.Active = true
    f.Draggable = true
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local s = Instance.new("UIStroke", f) s.Color = Theme.Accent s.Thickness = 2

    local title = Instance.new("TextLabel", f)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "PLAYTEST v1.2.0"
    title.TextColor3 = Theme.Accent
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    createButton(f, "Auto Treats: OFF", UDim2.new(0.05, 0, 0.25, 0), function(btn)
        _G.TreatLoop = not _G.TreatLoop
        btn.Text = _G.TreatLoop and "Auto Treats: ON" or "Auto Treats: OFF"
        btn.TextColor3 = _G.TreatLoop and Color3.fromRGB(0, 255, 150) or Theme.Text
        
        task.spawn(function()
            while _G.TreatLoop do
                pcall(function()
                    local folder = Workspace:FindFirstChild("SpawnedDogTreats", true)
                    local items = folder and folder:GetChildren() or {}
                    for _, v in pairs(items) do
                        if not _G.TreatLoop then break end
                        if v:IsA("BasePart") or v:IsA("Model") then
                            local target = v:IsA("Model") and (v.PrimaryPart or v:GetModelCFrame()) or v
                            player.Character.HumanoidRootPart.CFrame = target.CFrame
                            task.wait(0.3)
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end)

    createButton(f, "Teleport Shop", UDim2.new(0.05, 0, 0.45, 0), function()
        local shop = Workspace:FindFirstChild("ShopPart", true) or Workspace:FindFirstChild("SimonShopStand", true)
        if shop and player.Character then
            player.Character.HumanoidRootPart.CFrame = (shop:IsA("Model") and shop:GetModelCFrame() or shop.CFrame) + Vector3.new(0, 3, 0)
        end
    end)

    createButton(f, "Unload Script", UDim2.new(0.05, 0, 0.75, 0), function() sg:Destroy() _G.TreatLoop = false end)

    SmoothPop(f)
end

-- 5. VERIFICATION UI
local function ShowLock()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame")
    f.Name = "LockFrame"
    f.Parent = sg
    f.BackgroundColor3 = Theme.Main
    f.BackgroundTransparency = 0.1
    f.Position = UDim2.new(0.5, -150, 0.5, -110)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 15)
    Instance.new("UIStroke", f).Color = Theme.Accent

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, 0, 0, 70)
    lbl.Text = "ACCESS RESTRICTED\nFollow @" .. TARGET_USERNAME
    lbl.TextColor3 = Theme.Text
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16

    createButton(f, "Copy Profile Link", UDim2.new(0.05, 0, 0.4, 0), function(btn)
        if setclipboard then
            setclipboard(profileLink)
            btn.Text = "Link Copied!"
            task.wait(2)
            btn.Text = "Copy Profile Link"
        end
    end)

    createButton(f, "Verify Access", UDim2.new(0.05, 0, 0.65, 0), function(btn)
        btn.Text = "Verifying..."
        if isFollowing() then
            sg:Destroy()
            LoadMainScript()
        else
            btn.Text = "Not Detected!"
            task.wait(2)
            btn.Text = "Verify Access"
        end
    end)

    SmoothPop(f)
end

if isFollowing() then LoadMainScript() else ShowLock() end
