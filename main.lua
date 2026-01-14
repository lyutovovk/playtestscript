-- PLAYTEST SCRIPT [α1.0.6]
-- REWORKED FOR STABILITY
local OWNER_ID = 8816493943 
local TARGET_USERNAME = "derWolfderwutet"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local profileLink = "https://www.roblox.com/users/" .. OWNER_ID .. "/profile"

-- 1. STRENGTHENED FOLLOW CHECK
local function checkFollowing()
    if player.UserId == OWNER_ID then return true end
    
    local success, result = pcall(function()
        -- Method A: Check Relationship Status (Fastest)
        local url1 = "https://friends.roproxy.com/v1/users/" .. player.UserId .. "/friends/statuses?userIds=" .. OWNER_ID
        local res1 = game:HttpGet(url1)
        local data1 = HttpService:JSONDecode(res1)
        
        if data1 and data1.data and #data1.data > 0 then
            return true
        end

        -- Method B: Check Recent Followers (Backup)
        local url2 = "https://friends.roproxy.com/v1/users/" .. OWNER_ID .. "/followers?limit=20&sortOrder=Desc"
        local res2 = game:HttpGet(url2)
        local data2 = HttpService:JSONDecode(res2)

        if data2 and data2.data then
            for _, follower in pairs(data2.data) do
                if follower.id == player.UserId then return true end
            end
        end
        
        return false
    end)
    
    return success and result or false
end

-- 2. UI UTILS
local function smoothPop(obj, targetSize)
    obj.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = targetSize}):Play()
end

-- 3. MAIN MENU
local function LoadMainMenu()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "PlaytestGui"
    local f = Instance.new("Frame", sg)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.Position = UDim2.new(0.5, -105, 0.5, -130)
    f.Size = UDim2.new(0, 210, 0, 260)
    Instance.new("UICorner", f)
    local s = Instance.new("UIStroke", f) s.Color = Color3.fromRGB(170, 0, 255) s.Thickness = 2

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 0, 40)
    t.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
    t.Text = "PLAYTEST v1.0.6"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    Instance.new("UICorner", t)

    local function b(txt, pos, cb)
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(0.85, 0, 0, 35)
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = txt
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", btn)
        btn.MouseButton1Click:Connect(function() cb(btn) end)
    end

    -- REWORKED AUTO TREATS (Scans Workspace better)
    b("Auto Treats: OFF", UDim2.new(0.075, 0, 0.25, 0), function(btn)
        _G.Collect = not _G.Collect
        btn.Text = _G.Collect and "Auto Treats: ON" or "Auto Treats: OFF"
        btn.BackgroundColor3 = _G.Collect and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
        
        task.spawn(function()
            while _G.Collect do
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not _G.Collect then break end
                        if (v.Name:find("Treat") or v.Name:find("Bone")) and v:IsA("BasePart") then
                            player.Character.HumanoidRootPart.CFrame = v.CFrame
                            task.wait(0.2)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end)

    b("Speed (100)", UDim2.new(0.075, 0, 0.45, 0), function() player.Character.Humanoid.WalkSpeed = 100 end)
    b("Teleport Shop", UDim2.new(0.075, 0, 0.65, 0), function() 
        local shop = Workspace:FindFirstChild("Shop", true) or Workspace:FindFirstChild("Store", true)
        if shop then player.Character.HumanoidRootPart.CFrame = shop:GetModelCFrame() or shop.CFrame end
    end)

    smoothPop(f, UDim2.new(0, 210, 0, 260))
    f.Draggable = true
    f.Active = true
end

-- 4. VERIFICATION SCREEN
local function ShowVerify()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 250, 0, 180)
    f.Position = UDim2.new(0.5, -125, 0.5, -90)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", f)
    local s = Instance.new("UIStroke", f) s.Color = Color3.fromRGB(170, 0, 255) s.Thickness = 2

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 0, 60)
    t.Text = "ACCESS DENIED\nFollow " .. TARGET_USERNAME
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold

    local v1 = Instance.new("TextButton", f)
    v1.Size = UDim2.new(0.8, 0, 0, 45)
    v1.Position = UDim2.new(0.1, 0, 0.5, 0)
    v1.Text = "Verify Follow"
    v1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    v1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", v1)

    v1.MouseButton1Click:Connect(function()
        v1.Text = "Checking..."
        if checkFollowing() then 
            sg:Destroy() 
            LoadMainMenu() 
        else
            v1.Text = "Failed! Follow & Wait 10s"
            task.wait(2)
            v1.Text = "Verify Follow"
        end
    end)
    smoothPop(f, UDim2.new(0, 250, 0, 180))
end

-- Launch
if checkFollowing() then LoadMainMenu() else ShowVerify() end
