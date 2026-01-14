-- PLAYTEST SCRIPT [α1.0.5]
local OWNER_ID = 8816493943 
local TARGET_USERNAME = "derWolfderwutet"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local profileLink = "https://www.roblox.com/users/" .. OWNER_ID .. "/profile"

-- 1. STRICT FOLLOW CHECK (ID-BASED)
local function checkFollowing()
    -- Bypass for you, the owner
    if player.UserId == OWNER_ID then return true end
    
    local success, result = pcall(function()
        -- This API checks if the current player follows your specific ID
        local url = "https://friends.roproxy.com/v1/users/" .. player.UserId .. "/friends/statuses?userIds=" .. OWNER_ID
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        -- Returns true only if a relationship (following) is found
        return (data and data.data and #data.data > 0)
    end)
    
    return success and result or false
end

-- 2. SMOOTH UI ANIMATIONS
local function smoothPop(obj, targetSize)
    obj.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = targetSize}):Play()
end

-- 3. MAIN MENU (ACCESS GRANTED)
local function LoadMainMenu()
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local f = Instance.new("Frame", sg)
    f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    f.Position = UDim2.new(0.5, -105, 0.5, -130)
    f.Size = UDim2.new(0, 210, 0, 260)
    Instance.new("UICorner", f)
    local s = Instance.new("UIStroke", f) s.Color = Color3.fromRGB(170, 0, 255) s.Thickness = 2

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 0, 40)
    t.BackgroundColor3 = Color3.fromRGB(100, 0, 180)
    t.Text = "PLAYTEST SCRIPT"
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

    -- AGGRESSIVE AUTO TREATS
    b("Auto Treats: OFF", UDim2.new(0.075, 0, 0.25, 0), function(btn)
        _G.Collect = not _G.Collect
        btn.Text = _G.Collect and "Auto Treats: ON" or "Auto Treats: OFF"
        btn.BackgroundColor3 = _G.Collect and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(180, 50, 50)
        
        task.spawn(function()
            while _G.Collect do
                pcall(function()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if not _G.Collect then break end
                        if v.Name:find("Treat") and (v:IsA("BasePart") or v:IsA("Model")) then
                            local target = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")) or v
                            if target and player.Character then
                                player.Character.HumanoidRootPart.CFrame = target.CFrame
                                task.wait(0.3)
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end)

    b("Troll Speed", UDim2.new(0.075, 0, 0.45, 0), function() player.Character.Humanoid.WalkSpeed = 120 end)
    b("Teleport Shop", UDim2.new(0.075, 0, 0.65, 0), function() 
        local sP = Workspace:FindFirstChild("ShopPart", true) or Workspace:FindFirstChild("Shop", true)
        if sP then player.Character.HumanoidRootPart.CFrame = sP.CFrame + Vector3.new(0,3,0) end
    end)

    smoothPop(f, UDim2.new(0, 210, 0, 260))
    f.Draggable, f.Active = true, true
end

-- 4. VERIFICATION SCREEN (ACCESS DENIED)
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
    t.Text = "Follow " .. TARGET_USERNAME .. "\nto Unlock Access"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold

    local c1 = Instance.new("TextButton", f)
    c1.Size = UDim2.new(0.8, 0, 0, 35)
    c1.Position = UDim2.new(0.1, 0, 0.4, 0)
    c1.Text = "Copy Profile Link"
    c1.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    c1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", c1)

    local v1 = Instance.new("TextButton", f)
    v1.Size = UDim2.new(0.8, 0, 0, 35)
    v1.Position = UDim2.new(0.1, 0, 0.65, 0)
    v1.Text = "Verify Follow"
    v1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    v1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", v1)

    c1.MouseButton1Click:Connect(function() 
        if setclipboard then setclipboard(profileLink) end
        c1.Text = "Link Copied!" 
    end)
    
    v1.MouseButton1Click:Connect(function()
        v1.Text = "Verifying..."
        task.wait(1.5)
        if checkFollowing() then 
            sg:Destroy() 
            LoadMainMenu() 
        else
            v1.Text = "Follow Not Found!"
            task.wait(1.5) 
            v1.Text = "Verify Follow" 
        end
    end)
    smoothPop(f, UDim2.new(0, 250, 0, 180))
end

-- Run Check
if checkFollowing() then LoadMainMenu() else ShowVerify() end
