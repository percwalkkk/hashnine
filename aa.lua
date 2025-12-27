--[[
    ██████╗ ██████╗ ██████╗ ██████╗  █████╗     ██╗   ██╗██╗
   ██╔════╝██╔═══██╗██╔══██╗██╔══██╗██╔══██╗    ██║   ██║██║
   ██║     ██║   ██║██████╔╝██████╔╝███████║    ██║   ██║██║
   ██║     ██║   ██║██╔══██╗██╔══██╗██╔══██║    ██║   ██║██║
   ╚██████╗╚██████╔╝██████╔╝██║  ██║██║  ██║    ╚██████╔╝██║
    ╚═════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═╝
    
    COBRA UI Library v1.0
    A sleek dark gaming interface for Roblox script hubs
    
    Usage:
        local CobraUI = loadstring(game:HttpGet("YOUR_RAW_URL"))()
        local Window = CobraUI:CreateWindow({
            Title = "COBRA",
            Subtitle = "Premium Script Suite",
            Size = UDim2.new(0, 680, 0, 480)
        })
        
        local Tab = Window:CreateTab({
            Name = "Priority",
            Icon = "rbxassetid://7733960981"
        })
        
        Tab:CreateToggle({
            Name = "Autotime",
            Default = true,
            Callback = function(value)
                print("Autotime:", value)
            end
        })
]]

local CobraUI = {}
CobraUI.__index = CobraUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Theme Configuration
local Theme = {
    Background = {
        Primary = Color3.fromRGB(13, 13, 13),
        Secondary = Color3.fromRGB(20, 20, 20),
        Tertiary = Color3.fromRGB(26, 26, 26),
        Card = Color3.fromRGB(22, 22, 22),
        Hover = Color3.fromRGB(31, 31, 31),
        Active = Color3.fromRGB(37, 37, 37)
    },
    Accent = {
        Primary = Color3.fromRGB(34, 197, 94),
        Dim = Color3.fromRGB(22, 163, 74),
        Subtle = Color3.fromRGB(34, 197, 94)
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(161, 161, 161),
        Muted = Color3.fromRGB(107, 107, 107)
    },
    Border = Color3.fromRGB(42, 42, 42),
    BorderHover = Color3.fromRGB(58, 58, 58),
    
    -- Sizing
    Radius = {
        Small = UDim.new(0, 6),
        Medium = UDim.new(0, 10),
        Large = UDim.new(0, 14),
        XLarge = UDim.new(0, 20)
    },
    
    -- Fonts
    Font = {
        Regular = Enum.Font.Gotham,
        Medium = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
        Mono = Enum.Font.Code
    }
}

-- Utility Functions
local function Create(class, properties, children)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    for _, child in pairs(children or {}) do
        child.Parent = instance
    end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(instance, radius)
    return Create("UICorner", {
        CornerRadius = radius or Theme.Radius.Medium,
        Parent = instance
    })
end

local function AddStroke(instance, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = instance
    })
end

local function AddPadding(instance, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = instance
    })
end

local function AddListLayout(instance, padding, direction, alignment)
    return Create("UIListLayout", {
        Padding = UDim.new(0, padding or 4),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = alignment or Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = instance
    })
end

local function Ripple(button)
    local ripple = Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = button
    })
    AddCorner(ripple, UDim.new(1, 0))
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- ============================================================
-- WINDOW
-- ============================================================

function CobraUI:CreateWindow(config)
    config = config or {}
    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil
    
    -- Destroy existing UI
    if CoreGui:FindFirstChild("CobraUI") then
        CoreGui:FindFirstChild("CobraUI"):Destroy()
    end
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "CobraUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Window Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Theme.Background.Secondary,
        Position = config.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size = config.Size or UDim2.new(0, 720, 0, 500),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ScreenGui
    })
    AddCorner(MainFrame, Theme.Radius.Large)
    AddStroke(MainFrame, Theme.Border)
    
    -- Drop Shadow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 30, 1, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = -1,
        Parent = MainFrame
    })
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.Background.Secondary,
        Size = UDim2.new(0, 200, 1, 0),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    AddCorner(Sidebar, Theme.Radius.Large)
    
    -- Sidebar Border Right
    local SidebarBorder = Create("Frame", {
        Name = "Border",
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
        Parent = Sidebar
    })
    
    -- Logo Section
    local LogoSection = Create("Frame", {
        Name = "LogoSection",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 70),
        Parent = Sidebar
    })
    
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0.5, 0),
        Size = UDim2.new(1, -40, 0, 40),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = LogoSection
    })
    
    local LogoIcon = Create("Frame", {
        Name = "LogoIcon",
        BackgroundColor3 = Theme.Accent.Primary,
        Size = UDim2.new(0, 40, 0, 40),
        Parent = LogoContainer
    })
    AddCorner(LogoIcon, Theme.Radius.Medium)
    
    -- Logo Gradient
    local LogoGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Accent.Primary),
            ColorSequenceKeypoint.new(1, Theme.Accent.Dim)
        }),
        Rotation = 135,
        Parent = LogoIcon
    })
    
    local LogoEmoji = Create("TextLabel", {
        Name = "LogoEmoji",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Theme.Font.Bold,
        Text = config.LogoEmoji or "🐍",
        TextColor3 = Theme.Text.Primary,
        TextSize = 20,
        Parent = LogoIcon
    })
    
    local LogoTitle = Create("TextLabel", {
        Name = "LogoTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0.5, 0),
        Size = UDim2.new(1, -52, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Theme.Font.Bold,
        Text = config.Title or "COBRA",
        TextColor3 = Theme.Text.Primary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    -- Logo Section Border
    local LogoBorder = Create("Frame", {
        Name = "Border",
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = LogoSection
    })
    
    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -140),
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Background.Hover,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    })
    AddPadding(TabContainer, 12)
    AddListLayout(TabContainer, 4)
    
    -- User Section
    local UserSection = Create("Frame", {
        Name = "UserSection",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -70),
        Size = UDim2.new(1, 0, 0, 70),
        Parent = Sidebar
    })
    
    -- User Border Top
    local UserBorder = Create("Frame", {
        Name = "Border",
        BackgroundColor3 = Theme.Border,
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = UserSection
    })
    
    local UserCard = Create("Frame", {
        Name = "UserCard",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 16),
        Size = UDim2.new(1, -32, 0, 46),
        Parent = UserSection
    })
    
    local UserAvatar = Create("ImageLabel", {
        Name = "UserAvatar",
        BackgroundColor3 = Color3.fromRGB(37, 99, 235),
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = UserCard
    })
    AddCorner(UserAvatar, UDim.new(1, 0))
    
    -- Avatar Gradient
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(37, 99, 235)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 58, 237))
        }),
        Rotation = 135,
        Parent = UserAvatar
    })
    
    -- Try to get player thumbnail
    pcall(function()
        local thumbnail = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        UserAvatar.Image = thumbnail
    end)
    
    local UserName = Create("TextLabel", {
        Name = "UserName",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 4),
        Size = UDim2.new(1, -48, 0, 16),
        Font = Theme.Font.Medium,
        Text = Player.Name,
        TextColor3 = Theme.Text.Primary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = UserCard
    })
    
    local UserDisplay = Create("TextLabel", {
        Name = "UserDisplay",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 22),
        Size = UDim2.new(1, -48, 0, 14),
        Font = Theme.Font.Regular,
        Text = Player.DisplayName,
        TextColor3 = Theme.Text.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = UserCard
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundColor3 = Theme.Background.Primary,
        Position = UDim2.new(0, 200, 0, 0),
        Size = UDim2.new(1, -200, 1, 0),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    -- Fix corners for content area
    local ContentCornerFix = Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = Theme.Background.Primary,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 14, 1, 0),
        BorderSizePixel = 0,
        Parent = ContentArea
    })
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.Background.Secondary,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 60),
        BorderSizePixel = 0,
        Parent = ContentArea
    })
    
    -- Header corner fix
    local HeaderCornerFix = Create("Frame", {
        Name = "CornerFix",
        BackgroundColor3 = Theme.Background.Secondary,
        Size = UDim2.new(0, 14, 1, 0),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    local HeaderTitle = Create("TextLabel", {
        Name = "HeaderTitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0.5, 0),
        Size = UDim2.new(0.5, 0, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        Font = Theme.Font.Medium,
        Text = config.Subtitle or "Premium Script Suite",
        TextColor3 = Theme.Text.Secondary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- Header Actions
    local HeaderActions = Create("Frame", {
        Name = "HeaderActions",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0.5, 0),
        Size = UDim2.new(0, 160, 0, 36),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = Header
    })
    AddListLayout(HeaderActions, 8, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
    
    -- Header Icon Buttons
    local function CreateHeaderButton(icon, accent)
        local btn = Create("TextButton", {
            Name = "HeaderBtn",
            BackgroundColor3 = accent and Theme.Accent.Primary or Theme.Background.Tertiary,
            Size = UDim2.new(0, 36, 0, 36),
            Text = "",
            AutoButtonColor = false,
            Parent = HeaderActions
        })
        AddCorner(btn, UDim.new(1, 0))
        if not accent then
            AddStroke(btn, Theme.Border)
        end
        
        local iconLabel = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.Font.Bold,
            Text = icon,
            TextColor3 = accent and Theme.Text.Primary or Theme.Text.Secondary,
            TextSize = 16,
            Parent = btn
        })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = accent and Theme.Accent.Dim or Theme.Background.Hover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = accent and Theme.Accent.Primary or Theme.Background.Tertiary}, 0.15)
        end)
        
        return btn
    end
    
    CreateHeaderButton("⚙", true)
    CreateHeaderButton("🔔", false)
    CreateHeaderButton("⭐", false)
    CreateHeaderButton("🔍", false)
    
    -- Header Border
    local HeaderBorder = Create("Frame", {
        Name = "Border",
        BackgroundColor3 = Theme.Border,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Tab Content Container
    local TabContentContainer = Create("Frame", {
        Name = "TabContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60),
        Parent = ContentArea
    })
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
    
    -- Window Methods
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local Tab = {}
        Tab.Name = tabConfig.Name or "Tab"
        Tab.Sections = {}
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = "TabButton_" .. Tab.Name,
            BackgroundColor3 = Theme.Background.Hover,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            AutoButtonColor = false,
            Parent = TabContainer
        })
        AddCorner(TabButton, Theme.Radius.Medium)
        
        local TabIcon = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 14, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Font = Theme.Font.Regular,
            Text = tabConfig.Icon or "📁",
            TextColor3 = Theme.Text.Secondary,
            TextSize = 16,
            Parent = TabButton
        })
        
        local TabLabel = Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 46, 0.5, 0),
            Size = UDim2.new(1, -60, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Font = Theme.Font.Regular,
            Text = Tab.Name,
            TextColor3 = Theme.Text.Secondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Tab Content Page
        local TabPage = Create("ScrollingFrame", {
            Name = "TabPage_" .. Tab.Name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Background.Hover,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = TabContentContainer
        })
        AddPadding(TabPage, 24)
        
        local TabPageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 16),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Wraps = true,
            Parent = TabPage
        })
        
        -- Activate Tab
        local function ActivateTab()
            -- Deactivate all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Icon.TextColor3 = Theme.Text.Secondary
                tab.Label.TextColor3 = Theme.Text.Secondary
                tab.Page.Visible = false
            end
            
            -- Activate this tab
            Tween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(34, 197, 94)}, 0.2)
            TabButton.BackgroundTransparency = 0.9
            TabButton.BackgroundColor3 = Theme.Accent.Primary
            TabIcon.TextColor3 = Theme.Accent.Primary
            TabLabel.TextColor3 = Theme.Accent.Primary
            TabPage.Visible = true
            Window.ActiveTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(ActivateTab)
        
        TabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.5}, 0.15)
                Tween(TabLabel, {TextColor3 = Theme.Text.Primary}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
                Tween(TabLabel, {TextColor3 = Theme.Text.Secondary}, 0.15)
            end
        end)
        
        -- Store references
        Tab.Button = TabButton
        Tab.Icon = TabIcon
        Tab.Label = TabLabel
        Tab.Page = TabPage
        table.insert(Window.Tabs, Tab)
        
        -- Activate first tab
        if #Window.Tabs == 1 then
            ActivateTab()
        end
        
        -- ============================================================
        -- SECTION
        -- ============================================================
        
        function Tab:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = "Section",
                BackgroundColor3 = Theme.Background.Card,
                Size = UDim2.new(0, 300, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabPage
            })
            AddCorner(SectionFrame, Theme.Radius.Large)
            AddStroke(SectionFrame, Theme.Border)
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            AddPadding(SectionContent, 20)
            AddListLayout(SectionContent, 16)
            
            -- Section Title
            if sectionConfig.Name then
                local SectionTitle = Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    Font = Theme.Font.Medium,
                    Text = sectionConfig.Name,
                    TextColor3 = Theme.Text.Muted,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
            end
            
            Section.Frame = SectionFrame
            Section.Content = SectionContent
            table.insert(Tab.Sections, Section)
            
            -- ============================================================
            -- TOGGLE
            -- ============================================================
            
            function Section:CreateToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local Toggle = {}
                Toggle.Value = toggleConfig.Default or false
                
                local ToggleFrame = Create("Frame", {
                    Name = "Toggle_" .. (toggleConfig.Name or "Toggle"),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Parent = SectionContent
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -54, 1, 0),
                    Font = Theme.Font.Regular,
                    Text = toggleConfig.Name or "Toggle",
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Toggle.Value and Theme.Accent.Primary or Theme.Background.Tertiary,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 44, 0, 24),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = ToggleFrame
                })
                AddCorner(ToggleButton, UDim.new(0, 12))
                if not Toggle.Value then
                    AddStroke(ToggleButton, Theme.Border)
                end
                
                local ToggleThumb = Create("Frame", {
                    Name = "Thumb",
                    BackgroundColor3 = Toggle.Value and Theme.Text.Primary or Theme.Text.Secondary,
                    Position = Toggle.Value and UDim2.new(1, -4, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    AnchorPoint = Toggle.Value and Vector2.new(1, 0.5) or Vector2.new(0, 0.5),
                    Parent = ToggleButton
                })
                AddCorner(ToggleThumb, UDim.new(1, 0))
                
                local function UpdateToggle()
                    if Toggle.Value then
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Accent.Primary}, 0.2)
                        Tween(ToggleThumb, {Position = UDim2.new(1, -4, 0.5, 0), BackgroundColor3 = Theme.Text.Primary}, 0.2)
                        ToggleThumb.AnchorPoint = Vector2.new(1, 0.5)
                        if ToggleButton:FindFirstChildOfClass("UIStroke") then
                            ToggleButton:FindFirstChildOfClass("UIStroke"):Destroy()
                        end
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Theme.Background.Tertiary}, 0.2)
                        Tween(ToggleThumb, {Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = Theme.Text.Secondary}, 0.2)
                        ToggleThumb.AnchorPoint = Vector2.new(0, 0.5)
                        if not ToggleButton:FindFirstChildOfClass("UIStroke") then
                            AddStroke(ToggleButton, Theme.Border)
                        end
                    end
                    
                    if toggleConfig.Callback then
                        toggleConfig.Callback(Toggle.Value)
                    end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    UpdateToggle()
                end
                
                return Toggle
            end
            
            -- ============================================================
            -- SLIDER
            -- ============================================================
            
            function Section:CreateSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local Slider = {}
                Slider.Value = sliderConfig.Default or sliderConfig.Min or 0
                
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local increment = sliderConfig.Increment or 1
                
                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. (sliderConfig.Name or "Slider"),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    Parent = SectionContent
                })
                
                local SliderHeader = Create("Frame", {
                    Name = "Header",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Parent = SliderFrame
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Theme.Font.Regular,
                    Text = sliderConfig.Name or "Slider",
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderHeader
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Font = Theme.Font.Mono,
                    Text = tostring(Slider.Value) .. (sliderConfig.Suffix or ""),
                    TextColor3 = Theme.Text.Secondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderHeader
                })
                
                local SliderTrack = Create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = Theme.Background.Tertiary,
                    Position = UDim2.new(0, 0, 0, 32),
                    Size = UDim2.new(1, 0, 0, 6),
                    Parent = SliderFrame
                })
                AddCorner(SliderTrack, UDim.new(0, 3))
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    BackgroundColor3 = Theme.Accent.Primary,
                    Size = UDim2.new((Slider.Value - min) / (max - min), 0, 1, 0),
                    Parent = SliderTrack
                })
                AddCorner(SliderFill, UDim.new(0, 3))
                
                local FillGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.Accent.Dim),
                        ColorSequenceKeypoint.new(1, Theme.Accent.Primary)
                    }),
                    Parent = SliderFill
                })
                
                local SliderThumb = Create("Frame", {
                    Name = "Thumb",
                    BackgroundColor3 = Theme.Accent.Primary,
                    Position = UDim2.new((Slider.Value - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Parent = SliderTrack
                })
                AddCorner(SliderThumb, UDim.new(1, 0))
                
                local SliderInput = Create("TextButton", {
                    Name = "Input",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -8, 0, -8),
                    Size = UDim2.new(1, 16, 1, 16),
                    Text = "",
                    Parent = SliderTrack
                })
                
                local function UpdateSlider(value)
                    value = math.clamp(value, min, max)
                    value = math.floor(value / increment + 0.5) * increment
                    Slider.Value = value
                    
                    local percent = (value - min) / (max - min)
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                    Tween(SliderThumb, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
                    SliderValue.Text = tostring(value) .. (sliderConfig.Suffix or "")
                    
                    if sliderConfig.Callback then
                        sliderConfig.Callback(value)
                    end
                end
                
                local dragging = false
                
                SliderInput.MouseButton1Down:Connect(function()
                    dragging = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percent
                        UpdateSlider(value)
                    end
                end)
                
                SliderInput.MouseButton1Click:Connect(function()
                    local percent = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    local value = min + (max - min) * percent
                    UpdateSlider(value)
                end)
                
                function Slider:Set(value)
                    UpdateSlider(value)
                end
                
                return Slider
            end
            
            -- ============================================================
            -- BUTTON
            -- ============================================================
            
            function Section:CreateButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = "Button_" .. (buttonConfig.Name or "Button"),
                    BackgroundColor3 = buttonConfig.Primary and Theme.Accent.Primary or Theme.Background.Tertiary,
                    Size = UDim2.new(1, 0, 0, 40),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                AddCorner(ButtonFrame, Theme.Radius.Small)
                if not buttonConfig.Primary then
                    AddStroke(ButtonFrame, Theme.Border)
                end
                
                local ButtonLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Theme.Font.Medium,
                    Text = buttonConfig.Name or "Button",
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    Parent = ButtonFrame
                })
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = buttonConfig.Primary and Theme.Accent.Dim or Theme.Background.Hover}, 0.15)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = buttonConfig.Primary and Theme.Accent.Primary or Theme.Background.Tertiary}, 0.15)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Ripple(ButtonFrame)
                    if buttonConfig.Callback then
                        buttonConfig.Callback()
                    end
                end)
                
                return Button
            end
            
            -- ============================================================
            -- DROPDOWN
            -- ============================================================
            
            function Section:CreateDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local Dropdown = {}
                Dropdown.Value = dropdownConfig.Default or (dropdownConfig.Options and dropdownConfig.Options[1]) or ""
                Dropdown.Open = false
                
                local DropdownFrame = Create("Frame", {
                    Name = "Dropdown_" .. (dropdownConfig.Name or "Dropdown"),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 70),
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font.Regular,
                    Text = dropdownConfig.Name or "Dropdown",
                    TextColor3 = Theme.Text.Secondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Theme.Background.Tertiary,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 40),
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownButton, Theme.Radius.Small)
                AddStroke(DropdownButton, Theme.Border)
                
                local DropdownValue = Create("TextLabel", {
                    Name = "Value",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -48, 1, 0),
                    Font = Theme.Font.Regular,
                    Text = Dropdown.Value,
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -14, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Font = Theme.Font.Bold,
                    Text = "▼",
                    TextColor3 = Theme.Text.Muted,
                    TextSize = 10,
                    Parent = DropdownButton
                })
                
                local DropdownList = Create("Frame", {
                    Name = "List",
                    BackgroundColor3 = Theme.Background.Card,
                    Position = UDim2.new(0, 0, 0, 72),
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = DropdownFrame
                })
                AddCorner(DropdownList, Theme.Radius.Small)
                AddStroke(DropdownList, Theme.Border)
                
                local ListContent = Create("Frame", {
                    Name = "Content",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = DropdownList
                })
                AddPadding(ListContent, 4)
                AddListLayout(ListContent, 2)
                
                local function CreateOption(option)
                    local OptionButton = Create("TextButton", {
                        Name = "Option",
                        BackgroundColor3 = Theme.Background.Hover,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 32),
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 11,
                        Parent = ListContent
                    })
                    AddCorner(OptionButton, Theme.Radius.Small)
                    
                    local OptionLabel = Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        Font = Theme.Font.Regular,
                        Text = option,
                        TextColor3 = Theme.Text.Primary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11,
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0}, 0.15)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.15)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownValue.Text = option
                        Dropdown:Close()
                        
                        if dropdownConfig.Callback then
                            dropdownConfig.Callback(option)
                        end
                    end)
                end
                
                for _, option in ipairs(dropdownConfig.Options or {}) do
                    CreateOption(option)
                end
                
                function Dropdown:Open()
                    Dropdown.Open = true
                    DropdownList.Visible = true
                    local height = ListContent.AbsoluteSize.Y
                    Tween(DropdownList, {Size = UDim2.new(1, 0, 0, math.min(height, 150))}, 0.2)
                    Tween(DropdownArrow, {Rotation = 180}, 0.2)
                end
                
                function Dropdown:Close()
                    Dropdown.Open = false
                    Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    Tween(DropdownArrow, {Rotation = 0}, 0.2)
                    task.delay(0.2, function()
                        DropdownList.Visible = false
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    if Dropdown.Open then
                        Dropdown:Close()
                    else
                        Dropdown:Open()
                    end
                end)
                
                function Dropdown:Set(value)
                    Dropdown.Value = value
                    DropdownValue.Text = value
                    if dropdownConfig.Callback then
                        dropdownConfig.Callback(value)
                    end
                end
                
                return Dropdown
            end
            
            -- ============================================================
            -- TEXTBOX
            -- ============================================================
            
            function Section:CreateTextbox(textboxConfig)
                textboxConfig = textboxConfig or {}
                local Textbox = {}
                Textbox.Value = textboxConfig.Default or ""
                
                local TextboxFrame = Create("Frame", {
                    Name = "Textbox_" .. (textboxConfig.Name or "Textbox"),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 70),
                    Parent = SectionContent
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font.Regular,
                    Text = textboxConfig.Name or "Textbox",
                    TextColor3 = Theme.Text.Secondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextboxFrame
                })
                
                local TextboxInput = Create("TextBox", {
                    Name = "Input",
                    BackgroundColor3 = Theme.Background.Tertiary,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 40),
                    Font = Theme.Font.Regular,
                    Text = Textbox.Value,
                    PlaceholderText = textboxConfig.Placeholder or "Enter text...",
                    PlaceholderColor3 = Theme.Text.Muted,
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = TextboxFrame
                })
                AddCorner(TextboxInput, Theme.Radius.Small)
                AddStroke(TextboxInput, Theme.Border)
                AddPadding(TextboxInput, 12)
                
                TextboxInput.Focused:Connect(function()
                    Tween(TextboxInput:FindFirstChildOfClass("UIStroke"), {Color = Theme.Accent.Primary}, 0.15)
                end)
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    Tween(TextboxInput:FindFirstChildOfClass("UIStroke"), {Color = Theme.Border}, 0.15)
                    Textbox.Value = TextboxInput.Text
                    
                    if textboxConfig.Callback then
                        textboxConfig.Callback(TextboxInput.Text, enterPressed)
                    end
                end)
                
                function Textbox:Set(value)
                    Textbox.Value = value
                    TextboxInput.Text = value
                end
                
                return Textbox
            end
            
            -- ============================================================
            -- KEYBIND
            -- ============================================================
            
            function Section:CreateKeybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                local Keybind = {}
                Keybind.Value = keybindConfig.Default or Enum.KeyCode.Unknown
                
                local KeybindFrame = Create("Frame", {
                    Name = "Keybind_" .. (keybindConfig.Name or "Keybind"),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    Parent = SectionContent
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Theme.Font.Regular,
                    Text = keybindConfig.Name or "Keybind",
                    TextColor3 = Theme.Text.Primary,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = Theme.Background.Tertiary,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 70, 0, 28),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Font = Theme.Font.Mono,
                    Text = Keybind.Value.Name or "None",
                    TextColor3 = Theme.Text.Secondary,
                    TextSize = 12,
                    AutoButtonColor = false,
                    Parent = KeybindFrame
                })
                AddCorner(KeybindButton, Theme.Radius.Small)
                AddStroke(KeybindButton, Theme.Border)
                
                local listening = false
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButton:FindFirstChildOfClass("UIStroke"), {Color = Theme.Accent.Primary}, 0.15)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Tween(KeybindButton:FindFirstChildOfClass("UIStroke"), {Color = Theme.Border}, 0.15)
                            
                            if keybindConfig.Callback then
                                keybindConfig.Callback(input.KeyCode)
                            end
                        end
                    else
                        if input.KeyCode == Keybind.Value and not gameProcessed then
                            if keybindConfig.OnPress then
                                keybindConfig.OnPress()
                            end
                        end
                    end
                end)
                
                function Keybind:Set(keyCode)
                    Keybind.Value = keyCode
                    KeybindButton.Text = keyCode.Name
                end
                
                return Keybind
            end
            
            -- ============================================================
            -- LABEL
            -- ============================================================
            
            function Section:CreateLabel(text)
                local Label = Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font.Regular,
                    Text = text or "Label",
                    TextColor3 = Theme.Text.Secondary,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = SectionContent
                })
                
                return {
                    Set = function(_, newText)
                        Label.Text = newText
                    end
                }
            end
            
            -- ============================================================
            -- DIVIDER
            -- ============================================================
            
            function Section:CreateDivider()
                Create("Frame", {
                    Name = "Divider",
                    BackgroundColor3 = Theme.Border,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = SectionContent
                })
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- Window Controls
    function Window:Minimize()
        MainFrame.Visible = not MainFrame.Visible
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Keybind to toggle UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightControl) and not gameProcessed then
            Window:Minimize()
        end
    end)
    
    return Window
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

function CobraUI:Notify(config)
    config = config or {}
    
    local NotificationGui = CoreGui:FindFirstChild("CobraNotifications") or Create("ScreenGui", {
        Name = "CobraNotifications",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local NotificationHolder = NotificationGui:FindFirstChild("Holder") or Create("Frame", {
        Name = "Holder",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1),
        Parent = NotificationGui
    })
    
    if not NotificationHolder:FindFirstChildOfClass("UIListLayout") then
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = NotificationHolder
        })
    end
    
    local Notification = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Theme.Background.Card,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = NotificationHolder
    })
    AddCorner(Notification, Theme.Radius.Medium)
    AddStroke(Notification, Theme.Border)
    
    local NotificationContent = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = Notification
    })
    AddPadding(NotificationContent, 16)
    AddListLayout(NotificationContent, 8)
    
    local NotificationTitle = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Theme.Font.Bold,
        Text = config.Title or "Notification",
        TextColor3 = Theme.Accent.Primary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationContent
    })
    
    local NotificationMessage = Create("TextLabel", {
        Name = "Message",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Theme.Font.Regular,
        Text = config.Message or "",
        TextColor3 = Theme.Text.Secondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotificationContent
    })
    
    -- Accent bar
    Create("Frame", {
        Name = "Accent",
        BackgroundColor3 = Theme.Accent.Primary,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = Notification
    })
    
    -- Animate in
    Notification.BackgroundTransparency = 1
    task.wait()
    Tween(Notification, {BackgroundTransparency = 0}, 0.3)
    
    -- Auto dismiss
    task.delay(config.Duration or 4, function()
        Tween(Notification, {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        Notification:Destroy()
    end)
end

return CobraUI
