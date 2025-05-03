if shared.night then
    shared.night:uninject()
end
local loadtime = tick()
local cloneref = cloneref or function(i) return i end
local mp = cloneref(game:GetService("MarketplaceService"))
local plrs = cloneref(game:GetService("Players"))
local https = cloneref(game:GetService("HttpService"))
local uis = cloneref(game:GetService("UserInputService"))
local ts = cloneref(game:GetService("TweenService"))
local rs = cloneref(game:GetService("RunService"))

local totalusages = nil

local mainlib = {}

local setarea = gethui or function() return pcall(function() return plrs.LocalPlayer:FindFirstChildWhichIsA("PlayerGui") end) end
if not setarea() then plrs.LocalPlayer:Kick("please use something better your exploit cant even access playergui :sob:") end

if not isfolder("Night") then
    makefolder("Night")
end
if not isfolder("Night/Config") then
    makefolder("Night/Config")
end


if not isfile("Night/Config/Executions.lua") then
    writefile("Night/Config/Executions.lua", "1")
else
    local data = readfile("Night/Config/Executions.lua")
    local value = tonumber(data)
    if value then
        value += 1
        writefile("Night/Config/Executions.lua", tostring(value))
    end
end

local totalexecutions = readfile("Night/Config/Executions.lua")

local rootid = game.PlaceId
pcall(function()
    local req 
    req = http.request({
        Url = "https://games.roblox.com/v1/games?universeIds="..tostring(game.GameId),
        Method = "GET"
    }).Body
    rootid = https:JSONDecode(req).data[1].rootPlaceId
end)

pcall(function()
    local req
    req = http.request({
        Url = "https://sammz.pythonanywhere.com/count",
        Method = "GET"
    }).Body
    totalusages = req
end)



if not isfolder(string.format("Night/Config/%s", rootid)) then
    makefolder(string.format("Night/Config/%s", rootid))
end


local nightcons = {}
local buttons = {}
local notificationlocation = "Right"
local togglenotis = true
local usenotis = true

local maingui = Instance.new("ScreenGui", setarea())
maingui.ResetOnSpawn = false



shared.night = {
    togglecode = Enum.KeyCode.Quote,
    gui = maingui,
    library = mainlib,
    modules = {},
    tabs = {},
    sliderdata = {},
    config = {
        toggles = {},
        minitoggles = {},
        sliders = {},
        dropdowns = {},
        textboxes = {},
        keybinds = {}
    },
    uninject = function()
        task.wait(0.05)
        for i,v in next, shared.night.modules do
            v.call(false, false, false)
        end
        table.clear(mainlib)
        table.clear(buttons)
        for i,v in next, nightcons do
            if v and v.Connected then
                v:Disconnect()
            end
        end
        table.clear(nightcons)
        maingui:Destroy()
        shared.night = nil
    end
}

if not isfile(string.format("Night/Config/%s/config.json", rootid)) then
    writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode({}))
else
    local data = readfile(string.format("Night/Config/%s/config.json", rootid))
    local decode = https:JSONDecode(data)
    local found = 0
    for i,v in next, decode do
        found += 1
    end
    if found == 6 then
        shared.night.config = decode
    end
end


smoothdrag = function(ui)
    local dragging
    local dragin
    local start
    local spos

    local update = function(input)
        local delta = input.Position - start
        ts:Create(ui, TweenInfo.new(0.25), {Position = UDim2.new(spos.X.Scale, spos.X.Offset + delta.X, spos.Y.Scale, spos.Y.Offset + delta.Y)}):Play()
    end

    table.insert(nightcons, ui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            start = input.Position
            spos = ui.Position

            table.insert(nightcons, input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end))
        end
    end))

    table.insert(nightcons,ui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragin = input
        end
    end))

    table.insert(nightcons, rs.PreRender:Connect(function()
        if dragging then
            update(dragin)
        end
    end))
end



local notificationframe = Instance.new("Frame", maingui)
notificationframe.AnchorPoint = Vector2.new(1,0.5)
notificationframe.BackgroundTransparency = 1
notificationframe.Position = UDim2.new(1,0,0.5,0)
notificationframe.Size = UDim2.new(1,0,1,0)
notificationframe.ZIndex = 3
local notificationlist = Instance.new("UIListLayout", notificationframe)
notificationlist.Padding = UDim.new(0,5)
notificationlist.FillDirection = Enum.FillDirection.Vertical
notificationlist.HorizontalAlignment = Enum.HorizontalAlignment.Right
notificationlist.SortOrder = Enum.SortOrder.LayoutOrder
notificationlist.VerticalAlignment = Enum.VerticalAlignment.Bottom
local npad = Instance.new("UIPadding", notificationframe)
npad.PaddingBottom = UDim.new(0,10)
npad.PaddingTop = UDim.new(0,10)
npad.PaddingRight = UDim.new(0,5)
npad.PaddingLeft = UDim.new(0,5)

mainlib.notify = function(args)
    if not usenotis then return end
    local info = args.info
    local mode = args.mode
    local time = args.time

    local text = info
    if mode == "enable" then
        text = string.format('<font color="rgb(0,200,0)"><font weight="semibold">Enabled</font></font> %s', info)
    elseif mode == "disable" then
        text = string.format('<font color="rgb(200,0,0)"><font weight="semibold">Disabled</font></font> %s', info)
    end

    local mainframe = Instance.new("Frame", notificationframe)
    mainframe.AutomaticSize = Enum.AutomaticSize.X
    mainframe.BackgroundTransparency = 0.2
    mainframe.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
    mainframe.Size = UDim2.new(0,0,0,0)
    local corner = Instance.new("UICorner", mainframe)
    corner.CornerRadius = UDim.new(0,15)
    local pad = Instance.new("UIPadding", mainframe)
    pad.PaddingLeft = UDim.new(0,38)
    pad.PaddingRight = UDim.new(0,10)
    
    local bell = Instance.new("ImageLabel", mainframe)
    bell.AnchorPoint = Vector2.new(1,0.5)
    bell.BackgroundTransparency = 1
    bell.Position = UDim2.new(0,-7,0.5,0)
    bell.Size = UDim2.new(0.4,0,0.5,0)
    bell.ImageColor3 = Color3.fromRGB(255,255,255)
    bell.ScaleType = Enum.ScaleType.Stretch
    bell.Image = "rbxassetid://11295275950"
    bell.ImageTransparency = 1
    local bellratio = Instance.new("UIAspectRatioConstraint", bell)
    bellratio.AspectRatio = 1
    bellratio.AspectType = Enum.AspectType.FitWithinMaxSize
    bellratio.DominantAxis = Enum.DominantAxis.Height
    
    local information = Instance.new("TextLabel", mainframe)
    information.AutomaticSize = Enum.AutomaticSize.X
    information.BackgroundTransparency = 1
    information.Position = UDim2.new(0,0,0,0)
    information.Size = UDim2.new(1,0,1,0)
    information.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
    information.Text = text
    information.TextSize = 14
    information.TextColor3 = Color3.fromRGB(255,255,255)
    information.TextXAlignment = Enum.TextXAlignment.Left
    information.TextTransparency = 1
    information.RichText = true
    local infopad = Instance.new("UIPadding", information)
    infopad.PaddingBottom = UDim.new(0,1)
    
    spawn(function()
        ts:Create(mainframe, TweenInfo.new(0.15), {Size = UDim2.new(0,0,0,40)}):Play()
        ts:Create(bell, TweenInfo.new(0.1), {ImageTransparency = 0}):Play()
        ts:Create(information, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        
        spawn(function()
            for i = 1,2 do
                ts:Create(bell, TweenInfo.new(0.3), {Rotation = 15}):Play()
                task.wait(0.25)
                ts:Create(bell, TweenInfo.new(0.3), {Rotation = -15}):Play()
                task.wait(0.25)
                ts:Create(bell, TweenInfo.new(0.3), {Rotation = 0}):Play()
            end
        end)

        task.wait(time + 0.2)

        ts:Create(bell, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
        ts:Create(information, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
        ts:Create(mainframe, TweenInfo.new(0.1), {Size = UDim2.new(0,0,0,0)}):Play()
    end)
end


local mainframe = Instance.new("Frame", maingui)
mainframe.AnchorPoint = Vector2.new(0.5,0.5)
mainframe.Position = UDim2.new(0.5,0,0.5,0)
mainframe.Size = UDim2.new(0, 750,0, 500)
mainframe.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
mainframe.BackgroundTransparency = 1
Instance.new("UICorner", mainframe)

table.insert(nightcons, uis.InputBegan:Connect(function(nput, gamevent)
    if nput.KeyCode == shared.night.togglecode and not gamevent then
        mainframe.Visible = not mainframe.Visible
    end
end))

smoothdrag(mainframe)

local mainpad = Instance.new("UIPadding", mainframe)
mainpad.PaddingBottom = UDim.new(0,5)
mainpad.PaddingRight = UDim.new(0,10)
mainpad.PaddingTop = UDim.new(0,5)

local mainglow = Instance.new("ImageLabel", mainframe)
mainglow.AnchorPoint = Vector2.new(0.5,0.5)
mainglow.BackgroundTransparency = 1
mainglow.Position = UDim2.new(0.5,0,0.5,0)
mainglow.Position = UDim2.new(0.5,5,0.5,0)
mainglow.Size = UDim2.new(1,60,1,60)
mainglow.Image = "rbxassetid://6014261993"
mainglow.ImageColor3 = Color3.fromRGB(51,67,151)
mainglow.ImageTransparency = 1
mainglow.ScaleType = Enum.ScaleType.Slice
mainglow.SliceScale = 1
mainglow.ZIndex = -1
mainglow.SliceCenter = Rect.new(49, 49, 450, 450)
ts:Create(mainframe, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
ts:Create(mainglow, TweenInfo.new(0.25), {ImageTransparency = 0.5}):Play()


local titlebar = Instance.new("Frame", mainframe)
titlebar.BackgroundTransparency = 1
titlebar.Size = UDim2.new(1,0,0.06,0)
titlebar.Position = UDim2.new(0,0,0,0)

local title = Instance.new("TextLabel", titlebar)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,0,0,0)
title.Size = UDim2.new(1,0,1,0)
title.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
title.TextColor3 =Color3.new(255,255,255)
title.TextWrapped = true
title.TextScaled = true
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Night RBX"

local titlegrad = Instance.new("UIGradient", title)
titlegrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 53, 128)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})

local titlepad = Instance.new("UIPadding", title)
titlepad.PaddingLeft = UDim.new(0,10)
titlepad.PaddingTop = UDim.new(0,5)

local titlecon = Instance.new("UITextSizeConstraint", title)
titlecon.MaxTextSize = 20

local tabs = Instance.new("Frame", mainframe)
tabs.AnchorPoint = Vector2.new(0,1)
tabs.Position = UDim2.new(0,0,1,0)
tabs.Size = UDim2.new(0.22,0,0.94,0)
tabs.BackgroundTransparency = 1
tabs.ZIndex = 2
Instance.new("UICorner", tabs)

local tabgrad = Instance.new("UIGradient", tabs)
tabgrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 22, 27)), ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))})

local tabslist = Instance.new("UIListLayout", tabs)
tabslist.FillDirection = Enum.FillDirection.Vertical
tabslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabslist.SortOrder = Enum.SortOrder.LayoutOrder
tabslist.VerticalAlignment = Enum.VerticalAlignment.Top

local tabpadding = Instance.new("UIPadding", tabs)
tabpadding.PaddingTop = UDim.new(0,8)



local selecttabwork
createtab = function(name, icontouse, open)
    local mainbutton = Instance.new("TextButton", tabs)
    mainbutton.AutoButtonColor = false
    mainbutton.BackgroundColor3 = Color3.fromRGB(39,53,128)
    mainbutton.BackgroundTransparency = open and 0 or 1
    mainbutton.Size = UDim2.new(1,0,0,36)
    mainbutton.ZIndex = 3
    mainbutton.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.SemiBold)
    mainbutton.Text = name
    mainbutton.TextColor3 = open and Color3.fromRGB(225, 225, 225) or Color3.fromRGB(150, 150, 150)
    mainbutton.TextScaled = true
    mainbutton.TextSize = 16
    mainbutton.TextWrapped = true
    mainbutton.TextXAlignment = Enum.TextXAlignment.Left

    local selectedtabcorner = Instance.new("UICorner", mainbutton)
    selectedtabcorner.CornerRadius = UDim.new(1,0)

    local textcon = Instance.new("UITextSizeConstraint", mainbutton)
    textcon.MaxTextSize = 16

    local padding = Instance.new("UIPadding", mainbutton)
    padding.PaddingLeft = UDim.new(0,55)

    local work = Instance.new("Frame", mainbutton)
    work.BackgroundColor3 = Color3.fromRGB(39,53,128)
    work.Position = UDim2.new(0.001,-55,0,0)
    work.Size = UDim2.new(0,20,0,36)
    work.BorderSizePixel = 0
    work.ZIndex = 2
    work.BackgroundTransparency = open and 0 or 1
    if open then selecttabwork = work end

    local icon = Instance.new("ImageLabel", mainbutton)
    icon.Position = UDim2.new(0,-35,0.5,0)
    icon.Size = UDim2.new(0,26,0.57,0)
    icon.AnchorPoint = Vector2.new(0,0.5)
    icon.ZIndex = 3
    icon.BackgroundTransparency = 1
    icon.Image = icontouse
    icon.ImageColor3 = open and Color3.fromRGB(225, 225, 225) or Color3.fromRGB(150, 150, 150)
    icon.ScaleType = Enum.ScaleType.Fit

    local dashiconratio = Instance.new("UIAspectRatioConstraint", icon)
    dashiconratio.AspectRatio = 1
    dashiconratio.AspectType = Enum.AspectType.FitWithinMaxSize
    dashiconratio.DominantAxis = Enum.DominantAxis.Width
    buttons[name] = mainbutton
    return mainbutton, work
end

creatediv = function(name)
    local label = Instance.new("TextLabel", tabs)
    label.AnchorPoint = Vector2.new(0.5,1)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0.085,0)
    label.ZIndex = 4
    label.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
    label.TextColor3 = Color3.fromRGB(150,150,150)
    label.TextSize = 15
    label.Text = name
    label.TextXAlignment = Enum.TextXAlignment.Left

    local labelpad = Instance.new("UIPadding", label)
    labelpad.PaddingLeft = UDim.new(0,7)
    return label
end

local actualbuttons = {
    dashboard = createtab("Dashboard", "http://www.roblox.com/asset/?id=14989190133", true),
    creatediv("MAIN"),
    modules = createtab("Modules", "http://www.roblox.com/asset/?id=18399519017", false),
    premium = createtab("Premium", "http://www.roblox.com/asset/?id=18707837298", false),
    themes = createtab("Themes", "http://www.roblox.com/asset/?id=18399524763", false),
    creatediv("MISC"),
    configs = createtab("Configs", "http://www.roblox.com/asset/?id=14989181594", false),
    credits = createtab("Credits", "http://www.roblox.com/asset/?id=14989183005", false),
    guides = createtab("Guides", "http://www.roblox.com/asset/?id=18399510262", false),
    creatediv("SETTINGS"),
    hide = createtab("Hide", "http://www.roblox.com/asset/?id=18425180410", false),
    settings = createtab("Settings", "http://www.roblox.com/asset/?id=6031280882", false),
}

local tabholder = Instance.new("Frame", mainframe)
tabholder.AnchorPoint = Vector2.new(1,1)
tabholder.BackgroundTransparency = 1
tabholder.Position = UDim2.new(1,0,1,0)
tabholder.Size = UDim2.new(0.77,0,1,0)
tabholder.ClipsDescendants = true

local dashboard = Instance.new("ScrollingFrame", tabholder)
dashboard.BackgroundTransparency = 1
dashboard.Position = UDim2.new(0,0,0,0)
dashboard.Size = UDim2.new(1,0,1,0)
dashboard.ClipsDescendants = true
dashboard.AutomaticCanvasSize = Enum.AutomaticSize.Y
dashboard.ScrollBarThickness = 0

local dahsboardlayout = Instance.new("UIListLayout", dashboard)
dahsboardlayout.Padding = UDim.new(0,5)
dahsboardlayout.FillDirection = Enum.FillDirection.Vertical
dahsboardlayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
dahsboardlayout.SortOrder = Enum.SortOrder.LayoutOrder
dahsboardlayout.VerticalAlignment = Enum.VerticalAlignment.Top

local dashpad = Instance.new("UIPadding", dashboard)
dashpad.PaddingBottom = UDim.new(0,5)
dashpad.PaddingRight = UDim.new(0,10)
dashpad.PaddingTop = UDim.new(0,5)

local dashstatsframe = Instance.new("Frame", dashboard)
dashstatsframe.BackgroundTransparency = 1
dashstatsframe.Size = UDim2.new(1,0,0,60)
dashstatsframe.LayoutOrder = -1

local dashstatslist = Instance.new("UIListLayout", dashstatsframe)
dashstatslist.Padding = UDim.new(0,5)
dashstatslist.FillDirection = Enum.FillDirection.Horizontal
dashstatslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
dashstatslist.SortOrder = Enum.SortOrder.LayoutOrder
dashstatslist.VerticalAlignment = Enum.VerticalAlignment.Center


makestat = function(name, textvalue, icon, layout)
    local mainframea = Instance.new("Frame", dashstatsframe)
    mainframea.BackgroundTransparency = 1
    mainframea.LayoutOrder = layout
    mainframea.Size = UDim2.new(0.32,0,0.9,0)
    local theicon = Instance.new("Frame", mainframea)
    theicon.AnchorPoint = Vector2.new(0,0.5)
    theicon.BackgroundColor3 = Color3.fromRGB(34,34,34)
    theicon.Position = UDim2.new(0.003,0,0.5,0)
    theicon.Size = UDim2.new(0.3,0,0.68,0)
    local iconorner = Instance.new("UICorner", theicon)
    iconorner.CornerRadius = UDim.new(1,0)
    local iconratio = Instance.new("UIAspectRatioConstraint", theicon)
    iconratio.AspectRatio = 1
    iconratio.AspectType = Enum.AspectType.FitWithinMaxSize
    iconratio.DominantAxis = Enum.DominantAxis.Height
    local mainicona = Instance.new("ImageLabel", theicon)
    mainicona.AnchorPoint = Vector2.new(0.5,0.5)
    mainicona.BackgroundTransparency = 1
    mainicona.Position = UDim2.new(0.5,0,0.5,0)
    mainicona.Size = UDim2.new(0.6,0,0.6,0)
    mainicona.Image = icon
    mainicona.ImageColor3 = Color3.fromRGB(255,255,255)
    mainicona.ScaleType = Enum.ScaleType.Fit

    local maintextlabelicon = Instance.new("TextLabel", mainframea)
    maintextlabelicon.BackgroundTransparency = 1
    maintextlabelicon.Position = UDim2.new(0,0,0,0)
    maintextlabelicon.Size = UDim2.new(1,0,1,0)
    maintextlabelicon.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
    maintextlabelicon.LineHeight = 1.3
    maintextlabelicon.TextColor3 = Color3.fromRGB(255,255,255)
    maintextlabelicon.TextDirection = Enum.TextDirection.Auto
    maintextlabelicon.TextSize = 17
    maintextlabelicon.TextXAlignment = Enum.TextXAlignment.Left
    maintextlabelicon.RichText = true
    maintextlabelicon.Text = string.format('<font size="13"><font color="rgb(150,150,150)"><b>%s</b></font></font>\n%s', name, textvalue)
    local textpad = Instance.new("UIPadding", maintextlabelicon)
    textpad.PaddingLeft = UDim.new(0,45)
end

local usernamestat = Instance.new("Frame", dashstatsframe)
usernamestat.BackgroundTransparency = 1
usernamestat.Size = UDim2.new(0.32,0,0.9,0)
usernamestat.LayoutOrder = 0
local usernameicon = Instance.new("ImageLabel", usernamestat)
usernameicon.AnchorPoint = Vector2.new(0,0.5)
usernameicon.BackgroundColor3 = Color3.fromRGB(34,34,34)
usernameicon.Position = UDim2.new(0.003,0,0.5,0)
usernameicon.Size = UDim2.new(0.61,0,0.68,0)
usernameicon.Image = plrs:GetUserThumbnailAsync(plrs.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
usernameicon.ImageColor3 = Color3.fromRGB(255,255,255)
usernameicon.ScaleType = Enum.ScaleType.Fit
local usernameiconratio = Instance.new("UIAspectRatioConstraint", usernameicon)
usernameiconratio.AspectRatio = 1
usernameiconratio.AspectType = Enum.AspectType.FitWithinMaxSize
usernameiconratio.DominantAxis = Enum.DominantAxis.Width
local usernameiconcorner = Instance.new("UICorner",usernameicon)
usernameiconcorner.CornerRadius = UDim.new(1,0)

local usernametextlabel = Instance.new("TextLabel",  usernamestat)
usernametextlabel.BackgroundTransparency = 1
usernametextlabel.Position = UDim2.new(0,0,0,0)
usernametextlabel.Size = UDim2.new(1,0,1,0)
usernametextlabel.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
usernametextlabel.LineHeight = 1.3
usernametextlabel.RichText = true
usernametextlabel.TextColor3 = Color3.fromRGB(255,255,255)
usernametextlabel.TextSize = 17
usernametextlabel.TextWrapped = true
usernametextlabel.TextXAlignment = Enum.TextXAlignment.Left
usernametextlabel.Text = string.format('<font size="13"><font color="rgb(150,150,150)"><b>Username</b></font></font>\n%s', plrs.LocalPlayer.DisplayName)
local usernametextcon = Instance.new("UITextSizeConstraint", usernametextlabel)
usernametextcon.MaxTextSize = 16
local usernamepadding = Instance.new("UIPadding", usernametextlabel)
usernamepadding.PaddingLeft = UDim.new(0,45)
usernamepadding.PaddingRight = UDim.new(0,5)


makestat("Total users", tostring(totalusages), "http://www.roblox.com/asset/?id=14989179302", 1)
makestat("Total executions", tostring(totalexecutions), "http://www.roblox.com/asset/?id=14998339806", 2)

local dashgameframe = Instance.new("Frame", dashboard)
dashgameframe.Size = UDim2.new(1,0,0,200)
dashgameframe.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
dashgameframe.LayoutOrder = 1
Instance.new("UICorner", dashgameframe)

local thumbnail = Instance.new("ImageLabel", dashgameframe)
thumbnail.Size = UDim2.new(1,0,1,0)
thumbnail.BackgroundTransparency = 1
thumbnail.Image = string.format("https://www.roblox.com/Thumbs/Asset.ashx?Width=768&Height=432&AssetID=%s", rootid)
thumbnail.ImageColor3 = Color3.fromRGB(150,150,150)
thumbnail.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", thumbnail)

local gamenameframe = Instance.new("Frame", dashgameframe)
gamenameframe.AnchorPoint = Vector2.new(0.5,1)
gamenameframe.Size = UDim2.new(1,0,1,0)
gamenameframe.Position = UDim2.new(0.5,0,1,0)
Instance.new("UICorner", gamenameframe)

local gamenameframegrad = Instance.new("UIGradient",gamenameframe)
gamenameframegrad.Offset = Vector2.new(0, 0.1)
gamenameframegrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 17, 17))})
gamenameframegrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.682, 0.15), NumberSequenceKeypoint.new(1, 0)})
gamenameframegrad.Rotation = 90

local actualgamename = Instance.new("TextLabel", gamenameframe)
actualgamename.AnchorPoint = Vector2.new(0.5,1)
actualgamename.Size = UDim2.new(1,0,0.5,0)
actualgamename.BackgroundTransparency = 1
actualgamename.Position = UDim2.new(0.5,0,1,0)
actualgamename.RichText = true
actualgamename.TextColor3 = Color3.fromRGB(150,150,150)
actualgamename.TextXAlignment = Enum.TextXAlignment.Left
actualgamename.TextSize = 19
actualgamename.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
actualgamename.Text = string.format('<font size="15">Welcome, %s\n</font>You are currently playing, %s', plrs.LocalPlayer.DisplayName, mp:GetProductInfo(rootid).Name)

local namepad = Instance.new("UIPadding", actualgamename)
namepad.PaddingTop = UDim.new(0,25)
namepad.PaddingLeft = UDim.new(0,15)

local updatesarea = Instance.new("Frame", dashboard)
updatesarea.AutomaticSize = Enum.AutomaticSize.Y
updatesarea.BackgroundTransparency = 1
updatesarea.LayoutOrder = 2
updatesarea.BorderSizePixel = 0
updatesarea.Size = UDim2.new(1,0,0,0)
local logslayout = Instance.new("UIListLayout", updatesarea)
logslayout.FillDirection = Enum.FillDirection.Vertical
logslayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
logslayout.SortOrder = Enum.SortOrder.LayoutOrder
logslayout.VerticalAlignment = Enum.VerticalAlignment.Top
Instance.new("UIPadding", updatesarea)


mainlib.createupdatelog = function(args)
    local version = args.version
    local date = args.date
    local layoutorder = args.layout
    local updatelabel = Instance.new("TextLabel", updatesarea)
    updatelabel.AutomaticSize = Enum.AutomaticSize.X
    updatelabel.BackgroundTransparency = 1
    updatelabel.LayoutOrder = layoutorder
    updatelabel.Size = UDim2.new(0,0,0,30)
    updatelabel.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
    updatelabel.RichText = true
    updatelabel.TextSize = 20
    updatelabel.TextColor3 = Color3.fromRGB(135,136,141)
    updatelabel.TextXAlignment = Enum.TextXAlignment.Left
    updatelabel.BorderSizePixel = 0
    updatelabel.Text = string.format('%s <font color="rgb(90,90,90)"><font size="14"><b>%s</b></font></font>', version, date)
    local updatelabelpad = Instance.new("UIPadding", updatesarea)
    updatelabelpad.PaddingLeft = UDim.new(0,5)

    local updateschanges = Instance.new("Frame", updatesarea)
    updateschanges.AutomaticSize = Enum.AutomaticSize.Y
    updateschanges.BackgroundTransparency = 1
    updateschanges.BorderSizePixel = 0
    updateschanges.LayoutOrder = layoutorder + 1
    updateschanges.Size = UDim2.new(1,0,0,0)
    local uclayout = Instance.new("UIListLayout", updateschanges)
    uclayout.Padding = UDim.new(0,5)
    uclayout.FillDirection = Enum.FillDirection.Vertical
    uclayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    uclayout.SortOrder = Enum.SortOrder.LayoutOrder
    uclayout.VerticalAlignment = Enum.VerticalAlignment.Top
    local elemets = {}
    elemets.addchange = function(args2)
        local change = args2.change
        local info = args2.info
        local icon
        local color
        if change == "add" then
            color = Color3.fromRGB(72, 187, 120)
            icon = "http://www.roblox.com/asset/?id=6035047377"
        elseif change == "change" then
            color = Color3.fromRGB(191, 165, 83)
            icon = "http://www.roblox.com/asset/?id=14998356922"
        elseif change == "remove" then
            color = Color3.fromRGB(255, 0, 0)
            icon = "http://www.roblox.com/asset/?id=6035067836"
        end
        local maintext = Instance.new("TextLabel", updateschanges)
        maintext.BackgroundColor3 = Color3.fromRGB(30,30,30)
        maintext.Size = UDim2.new(1,0,0,40)
        maintext.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
        maintext.Text = info
        maintext.TextColor3 = Color3.fromRGB(150,150,150)
        maintext.TextSize = 14
        maintext.TextXAlignment = Enum.TextXAlignment.Left
        maintext.BorderSizePixel = 0
        local texpad = Instance.new("UIPadding", maintext)
        texpad.PaddingLeft = UDim.new(0,45)
        local colorbar = Instance.new("Frame", maintext)
        colorbar.AnchorPoint = Vector2.new(0,0.5)
        colorbar.BackgroundColor3 = color
        colorbar.Position = UDim2.new(0,-45,0.5,0)
        colorbar.Size = UDim2.new(0,3,1,0)
        colorbar.BorderSizePixel = 0
        local image = Instance.new("ImageLabel", maintext)
        image.AnchorPoint = Vector2.new(0,0.5)
        image.BackgroundTransparency = 1
        image.Position = UDim2.new(0,-32,0.5,0)
        image.Size = UDim2.new(0,20,0,20)
        image.Image = icon
        image.ImageColor3 = Color3.fromRGB(255,255,255)
        image.ScaleType = Enum.ScaleType.Stretch
        image.BorderSizePixel = 0
    end
    return elemets
end

local modulestab = Instance.new("ScrollingFrame", tabholder)
modulestab.BackgroundTransparency = 1
modulestab.Position = UDim2.new(0,0,0,0)
modulestab.Size = UDim2.new(1,0,1,0)
modulestab.AutomaticCanvasSize = Enum.AutomaticSize.Y
modulestab.ScrollBarThickness = 0
modulestab.Visible = false
local listlayoutmodules = Instance.new("UIListLayout", modulestab)
listlayoutmodules.Padding = UDim.new(0,15)
listlayoutmodules.FillDirection = Enum.FillDirection.Vertical
listlayoutmodules.HorizontalAlignment = Enum.HorizontalAlignment.Center
listlayoutmodules.SortOrder = Enum.SortOrder.LayoutOrder
listlayoutmodules.VerticalAlignment = Enum.VerticalAlignment.Top
local paddingmodules = Instance.new("UIPadding", modulestab)
paddingmodules.PaddingBottom = UDim.new(0,10)
paddingmodules.PaddingLeft = UDim.new(0,10)
paddingmodules.PaddingRight = UDim.new(0,10)
paddingmodules.PaddingTop = UDim.new(0,10)
local modulebuttons = Instance.new("Frame", modulestab)
modulebuttons.BackgroundTransparency = 1
modulebuttons.LayoutOrder = -1
modulebuttons.Size = UDim2.new(1,0,0,25)
local modulebuttonslayout = Instance.new("UIListLayout", modulebuttons)
modulebuttonslayout.Padding = UDim.new(0,10)
modulebuttonslayout.FillDirection = Enum.FillDirection.Horizontal
modulebuttonslayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
modulebuttonslayout.SortOrder = Enum.SortOrder.LayoutOrder
modulebuttonslayout.VerticalAlignment = Enum.VerticalAlignment.Top


local premiumtab = Instance.new("ScrollingFrame", tabholder)
premiumtab.BackgroundTransparency = 1
premiumtab.Position = UDim2.new(0,0,0,0)
premiumtab.Size = UDim2.new(1,0,1,0)
premiumtab.AutomaticCanvasSize = Enum.AutomaticSize.Y
premiumtab.ScrollBarThickness = 0
premiumtab.Visible = false
local listlayoutpremium = Instance.new("UIListLayout", premiumtab)
listlayoutpremium.Padding = UDim.new(0,15)
listlayoutpremium.FillDirection = Enum.FillDirection.Vertical
listlayoutpremium.HorizontalAlignment = Enum.HorizontalAlignment.Center
listlayoutpremium.SortOrder = Enum.SortOrder.LayoutOrder
listlayoutpremium.VerticalAlignment = Enum.VerticalAlignment.Top
local paddingpremium = Instance.new("UIPadding", premiumtab)
paddingpremium.PaddingBottom = UDim.new(0,10)
paddingpremium.PaddingLeft = UDim.new(0,10)
paddingpremium.PaddingRight = UDim.new(0,10)
paddingpremium.PaddingTop = UDim.new(0,10)
local exploitbuttons = Instance.new("Frame", premiumtab)
exploitbuttons.BackgroundTransparency = 1
exploitbuttons.LayoutOrder = -1
exploitbuttons.Size = UDim2.new(1,0,0,25)
local exploitbuttonslayout = Instance.new("UIListLayout", exploitbuttons)
exploitbuttonslayout.Padding = UDim.new(0,10)
exploitbuttonslayout.FillDirection = Enum.FillDirection.Horizontal
exploitbuttonslayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
exploitbuttonslayout.SortOrder = Enum.SortOrder.LayoutOrder
exploitbuttonslayout.VerticalAlignment = Enum.VerticalAlignment.Top


local settingstab = Instance.new("ScrollingFrame", tabholder)
settingstab.BackgroundTransparency = 1
settingstab.Position = UDim2.new(0,0,0,0)
settingstab.Size = UDim2.new(1,0,1,0)
settingstab.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingstab.ScrollBarThickness = 0
settingstab.Visible = false
local listlayoutsettings = Instance.new("UIListLayout", settingstab)
listlayoutsettings.Padding = UDim.new(0,15)
listlayoutsettings.FillDirection = Enum.FillDirection.Vertical
listlayoutsettings.HorizontalAlignment = Enum.HorizontalAlignment.Center
listlayoutsettings.SortOrder = Enum.SortOrder.LayoutOrder
listlayoutsettings.VerticalAlignment = Enum.VerticalAlignment.Top
local paddingsettings = Instance.new("UIPadding", settingstab)
paddingsettings.PaddingBottom = UDim.new(0,10)
paddingsettings.PaddingLeft = UDim.new(0,10)
paddingsettings.PaddingRight = UDim.new(0,10)
paddingsettings.PaddingTop = UDim.new(0,10)
local settingbuttons = Instance.new("Frame", settingstab)
settingbuttons.BackgroundTransparency = 1
settingbuttons.LayoutOrder = -1
settingbuttons.Size = UDim2.new(1,0,0,25)
local settingsbuttonlayout = Instance.new("UIListLayout", settingbuttons)
settingsbuttonlayout.Padding = UDim.new(0,10)
settingsbuttonlayout.FillDirection = Enum.FillDirection.Horizontal
settingsbuttonlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
settingsbuttonlayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsbuttonlayout.VerticalAlignment = Enum.VerticalAlignment.Top


local tabone
local layouta = 1
local modules = {}
local tabbuttons = {}
mainlib.newtab = function(args)
    local name = args.name or "tab"
    local tab = args.tab or "modules"

    local setlocation = {}
    if tab == "modules" then
        setlocation = {
            maintab = modulestab,
            buttons = modulebuttons
        }
    elseif tab == "premium" then
        setlocation = {
            maintab = premiumtab,
            buttons = exploitbuttons
        }
    elseif tab == "settings" then
        setlocation = {
            maintab = settingstab,
            buttons = settingbuttons
        }
    end

    local moduleinsides = {}
    local firstvis = true

    local tabdata = {}
    shared.night.tabs[name] = {
        tabdata = tabdata,
        renametab = function() end
    }

    if tab == "modules" then
        local tabbutton = Instance.new("TextButton", modulebuttons)
        tabbutton.BackgroundColor3 = not tabone and Color3.fromRGB(51,67,149) or Color3.fromRGB(44, 43, 44)
        tabbutton.LayoutOrder = layouta
        tabbutton.Size = UDim2.new(0.3,0,1,0)
        tabbutton.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
        tabbutton.Text = tostring(name):upper()
        tabbutton.TextColor3 = Color3.fromRGB(255,255,255)
        tabbutton.TextScaled = true
        tabbutton.TextSize = 18
        tabbutton.TextWrapped = true
        layouta += 1
        table.insert(tabbuttons, tabbutton)

        shared.night.tabs[name].renametab = function(newname)
            tabbutton.Text = tostring(newname):upper()
            shared.night.tabs[newname] = {
                tabdata = tabdata,
                renametab = shared.night.tabs[name].renametab
            } 
            shared.night.tabs[name] = nil
            name = newname
        end

        local cornerbutton = Instance.new("UICorner", tabbutton)
        cornerbutton.CornerRadius = UDim.new(1,0)

        local textcon = Instance.new("UITextSizeConstraint", tabbutton)
        textcon.MaxTextSize = 13

        if not tabone then 
            tabone = tabbutton 
        else
            firstvis = false
        end

        table.insert(nightcons, tabbutton.MouseButton1Click:Connect(function()
            for i,v in next, tabbuttons do
                if tabbutton ~= v then
                    ts:Create(v, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
                    ts:Create(v, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(44, 43, 44)}):Play()
                    ts:Create(v, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
                end
            end
            ts:Create(tabbutton, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            ts:Create(tabbutton, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(51,67,149)}):Play()
            ts:Create(tabbutton, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
            for i,v in next, modules do
                if not table.find(moduleinsides,v.Parent) and v and v.Parent then
                    ts:Create(v, TweenInfo.new(0.17), {BackgroundTransparency = 1}):Play()
                    v.Parent.Visible = false
                else
                    if v and v.Parent then
                        v.Parent.Visible = true
                        ts:Create(v, TweenInfo.new(0.45), {BackgroundTransparency = 0}):Play()
                    end
                end
            end
        end))
    end

    local modcount = 0

    tabdata.newmodule = function(args2)
        local name = args2.name or "toggle"
        local def = args2.def or false
        local button = args2.button or false
        local icon = args2.icon or "rbxassetid://"
        local iconsize = args2.iconsize or UDim2.new(0.5,0,0,15)
        local callback = args2.callback or function() end
        local keybindcall = args2.keybindcallback or function() end

        local modulecons = {}
        local ministuff = {}
        local dontmakevis = {}
        local rows = {}
        if modcount == 2 or #moduleinsides == 0 then
            modulesinside = Instance.new("Frame", setlocation.maintab)
            modulesinside.AutomaticSize = Enum.AutomaticSize.Y
            modulesinside.BackgroundTransparency = 1
            modulesinside.Visible = firstvis
            modulesinside.Size = UDim2.new(1,0,0,50)

            modulesinsidelayout = Instance.new("UIListLayout", modulesinside)
            modulesinsidelayout.Padding = UDim.new(0,10)
            modulesinsidelayout.FillDirection = Enum.FillDirection.Horizontal
            modulesinsidelayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            modulesinsidelayout.SortOrder = Enum.SortOrder.LayoutOrder
            modulesinsidelayout.VerticalAlignment = Enum.VerticalAlignment.Top

            Instance.new("UIPadding", modulesinside)
            table.insert(moduleinsides, modulesinside)
            table.insert(rows, modulesinside)
            modcount = 0
        end
        local backgroundframe = Instance.new("Frame", modulesinside)
        backgroundframe.BackgroundColor3 = Color3.fromRGB(31,30,31)
        backgroundframe.Size = UDim2.new(0.49,0,0,50)
        modcount += 1



        local pad = Instance.new("UIPadding", backgroundframe)
        pad.PaddingBottom = UDim.new(0,5)
        
        local modulecorner = Instance.new("UICorner", backgroundframe)
        modulecorner.CornerRadius = UDim.new(0,8)
        
        local dropstroke = Instance.new("UIStroke", backgroundframe)
        dropstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        dropstroke.Color = Color3.fromRGB(99,105,147)
        dropstroke.LineJoinMode = Enum.LineJoinMode.Round
        dropstroke.Thickness = 0

        local arrow = Instance.new("ImageButton", backgroundframe)
        arrow.AnchorPoint = Vector2.new(1,0.5)
        arrow.BackgroundTransparency = 1
        arrow.Position = UDim2.new(1,-10,0,25)
        arrow.Rotation = 180
        arrow.ZIndex = 4
        arrow.Size = UDim2.new(0,20,0,20)
        arrow.Image = "http://www.roblox.com/asset/?id=6034818379"
        arrow.ImageColor3 = Color3.fromRGB(255,255,255)
        arrow.ScaleType = Enum.ScaleType.Stretch


        local options = Instance.new("ScrollingFrame", backgroundframe)
        options.AnchorPoint = Vector2.new(0.5,0)
        options.BackgroundTransparency = 1
        options.Position = UDim2.new(0.5, 0,0, 50)
        options.Size = UDim2.new(1,0,1,-90)
        options.CanvasSize = UDim2.new(0,0,0,0)
        options.ScrollBarThickness = 0
        local optionslist = Instance.new("UIListLayout", options)
        optionslist.Padding = UDim.new(0,9)
        optionslist.FillDirection = Enum.FillDirection.Vertical
        optionslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optionslist.SortOrder = Enum.SortOrder.LayoutOrder
        optionslist.VerticalAlignment = Enum.VerticalAlignment.Top
        local optionspadding = Instance.new("UIPadding", options)
        optionspadding.PaddingLeft = UDim.new(0,4)
        optionspadding.PaddingRight = UDim.new(0,4)

        local kidcon = options.ChildAdded:Connect(function()
            options.CanvasSize = UDim2.new(0,0,0,optionslist.AbsoluteContentSize.Y + 100)
        end)

        table.insert(nightcons, kidcon)
        table.insert(modulecons, kidcon)

        local keybind = Instance.new("TextButton", backgroundframe)
        keybind.AnchorPoint = Vector2.new(0.5,1)
        keybind.BackgroundColor3 = Color3.fromRGB(44,43,44)
        keybind.Position = UDim2.new(0.5,0,0.98,0)
        keybind.Size = UDim2.new(1,-30,0,30)
        keybind.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
        keybind.Text = "BOUND TO NONE"
        keybind.TextColor3 = Color3.fromRGB(255,255,255)
        keybind.TextSize = 17
        keybind.TextTransparency = 1
        keybind.BackgroundTransparency = 1
        local keybindcorner = Instance.new("UICorner", keybind)
        keybindcorner.CornerRadius = UDim.new(1,0)

        local keybindpicked
        if shared.night.config.keybinds[name] then
            local value = shared.night.config.keybinds[name]
            if not Enum.KeyCode[value] then return end
            keybindpicked = Enum.KeyCode[value]
            keybind.Text = "BOUND TO " .. tostring(value)
            keybindcall(args2, tostring(value))
        end

        local keybindpickingcon
        local oldkeybindpickingcon = keybind.MouseButton1Click:Connect(function()
            local t = ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 1})
            t:Play()
            t.Completed:Wait()
            keybind.Text = "ENTER KEY"
            ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
            keybindpickingcon = uis.InputBegan:Connect(function(input)
                if input and input.KeyCode then
                    if input.KeyCode == Enum.KeyCode.Backspace then
                        shared.night.config.keybinds[name] = nil
                        writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                        keybindcall(args2, nil)
                        local t = ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 1})
                        t:Play()
                        keybindpicked = nil
                        keybindpickingcon:Disconnect()
                        t.Completed:Wait()
                        keybind.Text = "BOUND TO NONE"
                        ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
                    else
                        shared.night.config.keybinds[name] = input.KeyCode.Name
                        writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                        keybindcall(args2, tostring(input.KeyCode.Name))
                        local t = ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 1})
                        t:Play()
                        keybindpicked = input.KeyCode
                        keybindpickingcon:Disconnect()
                        t.Completed:Wait()
                        keybind.Text = "BOUND TO "..tostring(input.KeyCode.Name)
                        ts:Create(keybind, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
                    end
                end
            end)
        end)
        table.insert(nightcons, oldkeybindpickingcon)
        table.insert(modulecons, oldkeybindpickingcon)



        local droppeddrop = false
        local ydrop = 40
        local modoptioncon = arrow.MouseButton1Click:Connect(function()
            droppeddrop = not droppeddrop
            if droppeddrop then
                for i,v in next, ministuff do 
                    if not table.find(dontmakevis, v) then
                        v.Visible = true 
                    end
                end
                ts:Create(keybind, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
                ts:Create(keybind, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
                local extendsize = backgroundframe.Size.Y.Offset + ydrop
                if extendsize > 380 then
                    extendsize = 380
                end
                ts:Create(backgroundframe, TweenInfo.new(0.15), {Size = UDim2.new(0.49,0,0,extendsize)}):Play()
                ts:Create(dropstroke, TweenInfo.new(0.15), {Thickness = 2}):Play()
            else
                for i,v in next, ministuff do v.Visible = false end
                ts:Create(keybind, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
                ts:Create(keybind, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                ts:Create(backgroundframe, TweenInfo.new(0.15), {Size = UDim2.new(0.49,0,0,50)}):Play()
                ts:Create(dropstroke, TweenInfo.new(0.15), {Thickness = 0}):Play()
            end
        end)
        table.insert(nightcons, modoptioncon)
        table.insert(modulecons, modoptioncon)



        local modulename = Instance.new("TextButton", backgroundframe)
        modulename.AutomaticSize = Enum.AutomaticSize.X
        modulename.BackgroundTransparency = 1
        modulename.Position = UDim2.new(0,0,0,0)
        modulename.Size = UDim2.new(1,0,0,50)
        modulename.ZIndex = 3
        modulename.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
        modulename.TextColor3 = Color3.fromRGB(255,255,255)
        modulename.TextSize = 17
        modulename.TextXAlignment = Enum.TextXAlignment.Left
        modulename.Text = name
        local namepad = Instance.new("UIPadding", modulename)
        namepad.PaddingLeft = UDim.new(0,50)

        local moduleiconframe = Instance.new("Frame", backgroundframe)
        moduleiconframe.AnchorPoint = Vector2.new(0,0.5)
        moduleiconframe.BackgroundColor3 = Color3.fromRGB(38,37,38)
        moduleiconframe.Position = UDim2.new(0.02,0,0,25)
        moduleiconframe.Size = UDim2.new(0,34,0.6,0)
        local corner = Instance.new("UICorner", moduleiconframe)
        corner.CornerRadius = UDim.new(1,0)
        local ratio = Instance.new("UIAspectRatioConstraint", moduleiconframe)
        ratio.AspectRatio = 1
        ratio.AspectType = Enum.AspectType.ScaleWithParentSize
        ratio.DominantAxis = Enum.DominantAxis.Width

        local actualicon = Instance.new("ImageLabel", moduleiconframe)
        actualicon.AnchorPoint = Vector2.new(0.5,0.5)
        actualicon.BackgroundTransparency = 1
        actualicon.Position = UDim2.new(0,(34-actualicon.AbsoluteSize.X) / 2,0,(34 - actualicon.AbsoluteSize.Y) / 2)
        actualicon.Size = iconsize
        actualicon.Image = icon
        actualicon.ImageColor3 = Color3.fromRGB(255,255,255)
        actualicon.ScaleType = Enum.ScaleType.Fit

        local toggled = false

        shared.night.modules[name] = {
            call = nil,
            toggled = false
        }
        
        local toggle = function(enabled, button, save, noti)
            if enabled then
                toggled = true
                ts:Create(moduleiconframe, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(80, 106, 231)}):Play()
                pcall(callback, args2, toggled)
                if not button then
                    if noti then
                        mainlib.notify({
                            info = tostring(name),
                            mode = "enable",
                            time = 5,
                        })
                    end
                else
                    task.wait(0.01)
                    toggled = false
                    ts:Create(moduleiconframe, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(38,37,38)}):Play()
                    pcall(callback, args2, toggled)
                end
            elseif not enabled then
                toggled = false
                ts:Create(moduleiconframe, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(38,37,38)}):Play()
                pcall(callback, args2, toggled)
                if noti then
                    mainlib.notify({
                        info = tostring(name),
                        mode = "disable",
                        time = 5,
                    })
                end
            end
            shared.night.config.toggles[name] = toggled
            shared.night.modules[name]["toggled"] = toggled
            if save then
                writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
            end
            return toggled
        end

        local enabled = shared.night.config.toggles[name]
        if def and enabled == nil or enabled then
            toggle(true, button, false, false)
        end

        local togglem1con = modulename.MouseButton1Click:Connect(function()
            toggled = not toggled 

            toggle(toggled, button, true, togglenotis)
        end)

        table.insert(nightcons, togglem1con)
        table.insert(modulecons, togglem1con)

        local togglekeybindcon = uis.InputBegan:connect(function(input, game)
            if keybindpicked and input and input.KeyCode and not game then
                if input.KeyCode == keybindpicked then
                    toggled = not toggled 

                    toggle(toggled, button, true, togglenotis)
                end
            end
        end)

        table.insert(nightcons, togglekeybindcon)
        table.insert(modulecons, togglekeybindcon)

        local modulefuncs = {}
        
        shared.night.modules[name] = {
            call = toggle,
            toggled = toggled,
            elements = modulefuncs
        }

        modulefuncs.minitoggle = function(args3)
            local name = args3.name or "minitoggle"
            local def = args3.def or false
            local desc = args3.description or "This is a minitoggle"
            local flag = args3.flag or "minitoggleflag"
            local callback = args3.callback or function() end


            ydrop += 65
            local mainframetoggle = Instance.new("Frame", options)
            mainframetoggle.AutomaticSize = Enum.AutomaticSize.Y
            mainframetoggle.BackgroundTransparency = 1
            mainframetoggle.Size = UDim2.new(1,0,0,30)
            local minipad = Instance.new("UIPadding", mainframetoggle)
            minipad.PaddingBottom = UDim.new(0,5)
            table.insert(ministuff, mainframetoggle)

            local togglename = Instance.new("TextButton", mainframetoggle)
            togglename.AnchorPoint = Vector2.new(0.5,0)
            togglename.BackgroundTransparency = 1
            togglename.Position = UDim2.new(0.5,0,0,0)
            togglename.Size = UDim2.new(1,0,0,30)
            togglename.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
            togglename.TextColor3 = Color3.fromRGB(150,150,150)
            togglename.TextSize = 14
            togglename.ZIndex = 3
            togglename.TextXAlignment = Enum.TextXAlignment.Left
            togglename.Text = name
            local padname = Instance.new("UIPadding", togglename)
            padname.PaddingBottom = UDim.new(0,2)
            padname.PaddingLeft = UDim.new(0,35)

            local descriptiontext = Instance.new("TextLabel", mainframetoggle)
            descriptiontext.AnchorPoint = Vector2.new(0.5)
            descriptiontext.BackgroundTransparency = 1
            descriptiontext.Position = UDim2.new(0.5,0,1,0)
            descriptiontext.Size = UDim2.new(1,0,0,20)
            descriptiontext.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
            descriptiontext.Text = desc
            descriptiontext.TextColor3 = Color3.fromRGB(150,150,150)
            descriptiontext.TextSize = 13
            descriptiontext.TextWrapped = true
            descriptiontext.TextXAlignment = Enum.TextXAlignment.Left
            local descriptionpad = Instance.new("UIPadding", descriptiontext)
            descriptionpad.PaddingLeft = UDim.new(0,8)
            descriptionpad.PaddingRight = UDim.new(0,8)

            local enabledbox = Instance.new("Frame", mainframetoggle)
            enabledbox.BackgroundColor3 = Color3.fromRGB(38,37,38)
            enabledbox.Position = UDim2.new(0.02,0,0,5)
            enabledbox.Size = UDim2.new(0,45,0,20)
            local boxorner = Instance.new("UICorner", enabledbox)
            boxorner.CornerRadius = UDim.new(0,7)
            local boxratio = Instance.new("UIAspectRatioConstraint", enabledbox)
            boxratio.AspectRatio = 1
            boxratio.AspectType = Enum.AspectType.FitWithinMaxSize
            boxratio.DominantAxis = Enum.DominantAxis.Height
            local boxtick = Instance.new("ImageLabel", enabledbox)
            boxtick.AnchorPoint = Vector2.new(0.5,0.5)
            boxtick.BackgroundTransparency = 1
            boxtick.Position = UDim2.new(0.5,0,0.5,0)
            boxtick.Size = UDim2.new(0.7,0,0,30)
            boxtick.Image = "http://www.roblox.com/asset/?id=6031094667"
            boxtick.ImageColor3 = Color3.fromRGB(255,255,255)
            boxtick.ScaleType = Enum.ScaleType.Fit
            boxtick.ImageTransparency = 1

            local enabled = false
            pcall(callback, args3, enabled)
            local toggle = function(toggle)
                enabled = toggle
                if enabled then
                    ts:Create(boxtick, TweenInfo.new(0.15), {ImageTransparency = 0}):Play()
                    ts:Create(enabledbox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80,106,231)}):Play()
                else
                    ts:Create(boxtick, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
                    ts:Create(enabledbox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38,37,38)}):Play()
                end
                shared.night.config.minitoggles[flag] = enabled
                writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                pcall(callback, args3, enabled)
                return enabled
            end

            local data = shared.night.config.minitoggles[flag]
            if def and data == nil or data then
                toggle(true)
            end
            local minitogglem1 = togglename.MouseButton1Click:Connect(function()
                enabled = not enabled
                toggle(enabled)
            end)
            table.insert(nightcons, minitogglem1)
            table.insert(modulecons, minitogglem1)
        end
        modulefuncs.slider = function(args4)
            local name = args4.name or "slider"
            local min = args4.min or 0
            local max = args4.max or 100
            local def = args4.def or 50
            local decimals = args4.decimals or 0
            local description = args4.description or "This is a slider"
            local flag = args4.flag or "sliderflag"
            local callback = args4.callback or function() end

            ydrop += 65

            local slider =  Instance.new("Frame", options)
            slider.AutomaticSize = Enum.AutomaticSize.Y
            slider.BackgroundTransparency = 1
            slider.Size = UDim2.new(1,0,0,40)
            table.insert(ministuff, slider)

            local mainbar = Instance.new("Frame", slider)
            mainbar.AnchorPoint = Vector2.new(0.5,0)
            mainbar.BackgroundColor3 = Color3.fromRGB(43,42,43)
            mainbar.Position = UDim2.new(0.5,0,0,25)
            mainbar.Size = UDim2.new(0.98,0,0,4)
            Instance.new("UICorner", mainbar)

            local buttonfordrag = Instance.new("ImageButton", mainbar)
            buttonfordrag.AnchorPoint = Vector2.new(0,0.5)
            buttonfordrag.BackgroundTransparency = 1
            buttonfordrag.Position = UDim2.new(0,0,0.5,0)
            buttonfordrag.Size = UDim2.new(0,15,0,15)
            buttonfordrag.Image = "http://www.roblox.com/asset/?id=6031625146"
            buttonfordrag.ImageColor3 = Color3.fromRGB(80,106,231)
            buttonfordrag.ScaleType = Enum.ScaleType.Stretch

            local slidertext = Instance.new("TextBox", slider)
            slidertext.AnchorPoint = Vector2.new(1,0)
            slidertext.AutomaticSize = Enum.AutomaticSize.XY
            slidertext.BackgroundTransparency = 1
            slidertext.MultiLine = false
            slidertext.Position = UDim2.new(1,0,0,0)
            slidertext.Size = UDim2.new(0,0,0,0)
            slidertext.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
            slidertext.TextColor3 = Color3.fromRGB(150,150,150)
            slidertext.TextSize = 14
            slidertext.TextXAlignment = Enum.TextXAlignment.Right
            slidertext.TextYAlignment = Enum.TextYAlignment.Top
            slidertext.Text = def
            local slidertextpad = Instance.new("UIPadding", slidertext)
            slidertextpad.PaddingRight = UDim.new(0,8)

            local sliderdescription = Instance.new("TextLabel", slider)
            sliderdescription.AnchorPoint = Vector2.new(0.5,0)
            sliderdescription.BackgroundTransparency = 1
            sliderdescription.Position = UDim2.new(0.5,0,1,0)
            sliderdescription.Size = UDim2.new(1,0,0,20)
            sliderdescription.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
            sliderdescription.Text = description
            sliderdescription.TextColor3 = Color3.fromRGB(150,150,150)
            sliderdescription.TextSize = 13
            sliderdescription.TextWrapped = true
            sliderdescription.TextXAlignment = Enum.TextXAlignment.Left
            local descriptionpad = Instance.new("UIPadding", sliderdescription)
            descriptionpad.PaddingLeft = UDim.new(0,8)

            local slidername = Instance.new("TextLabel", slider)
            slidername.AnchorPoint = Vector2.new(0.5,0)
            slidername.BackgroundTransparency = 1
            slidername.Position = UDim2.new(0.5,0,0,0)
            slidername.Size = UDim2.new(1,0,0,40)
            slidername.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
            slidername.TextColor3 = Color3.fromRGB(150,150,150)
            slidername.TextSize = 14
            slidername.TextXAlignment = Enum.TextXAlignment.Left
            slidername.TextYAlignment = Enum.TextYAlignment.Top
            slidername.Text = name
            local namepad = Instance.new("UIPadding", slidername)
            namepad.PaddingLeft = UDim.new(0,8)

            local data = shared.night.config.sliders[flag]
            if def and data == nil then
                pcall(callback, args4, def)
                local percent = math.clamp((def-min)/(max-min), 0, 1)
                ts:Create(buttonfordrag, TweenInfo.new(0.45), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
            end
            if data then
                pcall(callback, args4, data)
                local percent = math.clamp((data-min)/(max-min), 0, 1)
                ts:Create(buttonfordrag, TweenInfo.new(0.45), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
                slidertext.Text = data
            end

            local dragging = false
            
            local dragcona = buttonfordrag.MouseButton1Down:Connect(function()
                dragging = true
            end)
            table.insert(nightcons, dragcona)
            table.insert(modulecons, dragcona)

            local dragconb = uis.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    ts:Create(mainbar, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(43,42,43)}):Play()
                    dragging = false
                end
            end)
            table.insert(nightcons, dragconb)
            table.insert(modulecons, dragconb)

            spawn(function()
                local dragconc = uis.InputChanged:Connect(function(input)
                    if dragging then
                        ts:Create(mainbar, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(40, 50, 116)}):Play()
                        local mouse = uis:GetMouseLocation()
                        local relativePos = mouse-mainbar.AbsolutePosition
                        local percent = math.clamp(relativePos.X/mainbar.AbsoluteSize.X, 0, 1)
                        local value = math.floor(((((max - min) * percent) + min) * (10 ^ decimals)) + 0.5) / (10 ^ decimals) 
                        ts:Create(buttonfordrag, TweenInfo.new(0.45), {Position = UDim2.new(percent, 0, 0.5, 0)}):Play()
                        slidertext.Text = tostring(value)
                        shared.night.config.sliders[flag] = tonumber(value)
                        writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                        pcall(callback, args4, tonumber(value))
                    end
                end)
                table.insert(nightcons, dragconc)
                table.insert(modulecons, dragconc)
                
                local dragcond = slidertext:GetPropertyChangedSignal("Text"):Connect(function()
                    local value = slidertext.Text
                    if value == "" then
                        value = 0
                    end
                    pcall(callback, args4, tonumber(value))
                    shared.night.config.sliders[flag] = tonumber(value)
                    writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                    if tonumber(value) then
                        ts:Create(mainbar, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(40, 50, 116)}):Play()
                        local percent = math.clamp((tonumber(value)-min)/(max-min), 0, 1)
                        local tween = ts:Create(buttonfordrag, TweenInfo.new(0.45), {Position = UDim2.new(percent, 0, 0.5, 0)})
                        tween:Play()
                        tween.Completed:Wait()
                        ts:Create(mainbar, TweenInfo.new(0.45), {BackgroundColor3 = Color3.fromRGB(43,42,43)}):Play()
                    end
                end)
                table.insert(nightcons, dragcond)
                table.insert(modulecons, dragcond)
            end)
            local sliderele = {}
            local lowered = false
            sliderele.toggle = function(visible)
                if visible == nil then 
                    visible = not slider.Visible 
                end
                if visible and not slider.Visible then
                    ydrop += 60
                elseif not visible and slider.Visible then
                    ydrop -= 60
                end
                if droppeddrop then
                    if visible then
                        if not slider.Visible then
                            if table.find(dontmakevis, slider) then
                                table.remove(dontmakevis, table.find(dontmakevis, slider))
                            end
                            ts:Create(backgroundframe, TweenInfo.new(0.15), {Size = UDim2.new(0.49,0,0,(ydrop))}):Play()
                            options.CanvasSize = UDim2.new(0,0,0,(ydrop + 5))
                        end
                    else
                        table.insert(dontmakevis, slider)
                        if slider.Visible  then
                            ts:Create(backgroundframe, TweenInfo.new(0.15), {Size = UDim2.new(0.49,0,0,(50 + ydrop))}):Play()
                            options.CanvasSize = UDim2.new(0,0,0,options.CanvasSize.Y.Offset - (ydrop - 75))
                        end
                    end
                end
                slider.Visible = visible
            end
            shared.night.sliderdata[flag] = sliderele
            return sliderele
        end
        modulefuncs.dropdown = function(args5)
            local name = args5.name or "dropdown"
            local description = args5.description or "This is a dropdown"
            local dropoptions = args5.options or {}
            local def = args5.def or ""
            local flag = args5.flag or "dropdownflag"
            local callback = args5.callback or function() end

            local ylevel = 30
            local buttons = {}

            ydrop += 85

            local mainbg = Instance.new("Frame", options)
            mainbg.AutomaticSize = Enum.AutomaticSize.Y
            mainbg.BackgroundTransparency = 1
            mainbg.Size = UDim2.new(1,0,0,50)
            table.insert(ministuff, mainbg)
            
            local dropname = Instance.new("TextLabel", mainbg)
            dropname.AnchorPoint = Vector2.new(0.5,0)
            dropname.BackgroundTransparency = 1
            dropname.Position = UDim2.new(0.5,0,0,0)
            dropname.Size = UDim2.new(1,0,0,50)
            dropname.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
            dropname.TextColor3 = Color3.fromRGB(150,150,150)
            dropname.TextXAlignment = Enum.TextXAlignment.Left
            dropname.TextYAlignment = Enum.TextYAlignment.Top
            dropname.Text = name
            dropname.TextSize = 14
            local namepad = Instance.new("UIPadding", dropname)
            namepad.PaddingLeft = UDim.new(0,8)

            local descriptiontext = Instance.new("TextLabel", mainbg)
            descriptiontext.AnchorPoint = Vector2.new(0.5,0)
            descriptiontext.BackgroundTransparency = 1
            descriptiontext.Position = UDim2.new(0.5,0,1.05,0)
            descriptiontext.Size = UDim2.new(1,0,0,15)
            descriptiontext.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
            descriptiontext.Text = description
            descriptiontext.TextColor3 = Color3.fromRGB(150,150,150)
            descriptiontext.TextSize = 12
            descriptiontext.TextWrapped = true
            descriptiontext.TextXAlignment = Enum.TextXAlignment.Left
            local descriptionpad = Instance.new("UIPadding", descriptiontext)
            descriptionpad.PaddingLeft = UDim.new(0,8)
            descriptionpad.PaddingRight = UDim.new(0,8)
            descriptionpad.PaddingTop = UDim.new(0,5)

            local mainframeholder = Instance.new("Frame", mainbg)
            mainframeholder.BackgroundColor3 = Color3.fromRGB(47,43,46)
            mainframeholder.Position = UDim2.new(0,10,0,20)
            mainframeholder.Size = UDim2.new(0, 165,0, ylevel)
            local mainframeholdcorner = Instance.new("UICorner", mainframeholder)
            mainframeholdcorner.CornerRadius = UDim.new(0,15)
            local mainframeholdpad = Instance.new("UIPadding", mainframeholder)
            mainframeholdpad.PaddingLeft = UDim.new(0,15)
            mainframeholdpad.PaddingRight = UDim.new(0,35)

            local selectedoption = Instance.new("TextLabel", mainframeholder)
            selectedoption.AutomaticSize = Enum.AutomaticSize.X
            selectedoption.BackgroundTransparency = 1
            selectedoption.Position = UDim2.new(0,0,0,5)
            selectedoption.Size = UDim2.new(1,20,0,20)
            selectedoption.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Bold)
            selectedoption.Text = def
            selectedoption.TextColor3 = Color3.fromRGB(255,255,255)
            selectedoption.TextSize = 15
            selectedoption.TextXAlignment = Enum.TextXAlignment.Left

            local droparrow = Instance.new("ImageButton", mainframeholder)
            droparrow.AnchorPoint = Vector2.new(1,0)
            droparrow.BackgroundTransparency = 1
            droparrow.Position = UDim2.new(1,25,0,5)
            droparrow.Size = UDim2.new(0,20,0,20)
            droparrow.Image = "http://www.roblox.com/asset/?id=6034818379"
            droparrow.ImageColor3 = Color3.fromRGB(255,255,255)
            droparrow.ScaleType = Enum.ScaleType.Stretch
            droparrow.Rotation = 180

            local optionsbg = Instance.new("Frame", mainframeholder)
            optionsbg.AutomaticSize = Enum.AutomaticSize.XY
            optionsbg.BackgroundTransparency = 1
            optionsbg.Position = UDim2.new(0,-15,0,25)
            optionsbg.Size = UDim2.new(1,50,0,0)
            optionsbg.Visible = false
            
            local listoptions = Instance.new("UIListLayout", optionsbg)
            listoptions.FillDirection = Enum.FillDirection.Vertical
            listoptions.HorizontalAlignment = Enum.HorizontalAlignment.Left
            listoptions.SortOrder = Enum.SortOrder.LayoutOrder
            listoptions.VerticalAlignment = Enum.VerticalAlignment.Top

            local pad = Instance.new("UIPadding", optionsbg)
            pad.PaddingBottom = UDim.new(0,5)
            pad.PaddingLeft = UDim.new(0,10)
            pad.PaddingRight = UDim.new(0,10)
            pad.PaddingTop = UDim.new(0,5)


            local open = false
            local ddcon = droparrow.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    options.CanvasSize = UDim2.new(0,0,0,options.CanvasSize.Y.Offset + (ylevel - 45))
                    optionsbg.Visible = true
                    ts:Create(droparrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
                    ts:Create(mainframeholder, TweenInfo.new(0.2), {Size = UDim2.new(0,165,0,ylevel)}):Play()
                    for i,v in next, buttons do

                        ts:Create(v, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
                    end
                else
                    options.CanvasSize = UDim2.new(0,0,0,options.CanvasSize.Y.Offset - (ylevel - 45))
                    ts:Create(droparrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
                    for i,v in next, buttons do
                        ts:Create(v, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
                    end
                    ts:Create(mainframeholder, TweenInfo.new(0.2), {Size = UDim2.new(0,165,0,30)}):Play()   
                    optionsbg.Visible = false
                end
            end)
            table.insert(nightcons, ddcon)
            table.insert(modulecons, ddcon)

            local data = flag and shared.night.config.dropdowns[flag]
            if data then
                pcall(callback, args5, tostring(data))
                selectedoption.Text = tostring(data)
            elseif data == nil and def then
                pcall(callback, args5, tostring(def))
                selectedoption.Text = tostring(def)
            end

            for i,v in next, dropoptions do
                local button = Instance.new("TextButton", optionsbg)
                ylevel += 22
                extended = (backgroundframe.Size.Y.Offset + ylevel)
                button.AutomaticSize = Enum.AutomaticSize.X
                button.BackgroundTransparency = 1
                button.LayoutOrder = 2
                button.Size = UDim2.new(0,0,0,20)
                button.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.SemiBold)
                button.Text = v
                button.TextColor3 = Color3.fromRGB(150,150,150)
                button.TextSize = 14
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.TextTransparency = 1
                table.insert(buttons, button)
                local ddocon = button.MouseButton1Click:Connect(function()
                    if flag and flag ~= "" then
                        shared.night.config.dropdowns[flag] = tostring(v)
                        writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                    end
                    pcall(callback, args5, tostring(v))
                    open = false
                    local ta = ts:Create(selectedoption, TweenInfo.new(0.35), {TextTransparency = 1})
                    ta:Play()
                    ts:Create(droparrow, TweenInfo.new(0.15), {Rotation = 180}):Play()
                    for i,v in next, buttons do
                        ts:Create(v, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
                    end
                    ts:Create(mainframeholder, TweenInfo.new(0.2), {Size = UDim2.new(0,165,0,30)}):Play()           
                    optionsbg.Visible = false     
                    options.CanvasSize = UDim2.new(0,0,0,options.CanvasSize.Y.Offset - ylevel)
                    ta.Completed:Wait()
                    selectedoption.Text = tostring(v)
                    ts:Create(selectedoption, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
                end)
                table.insert(nightcons, ddocon)
                table.insert(nightcons, modulecons)
            end
        end
        modulefuncs.textbox = function(argssmthiforgot)
            local name = argssmthiforgot.name
            local desc = argssmthiforgot.description
            local flag = argssmthiforgot.flag
            local callback = argssmthiforgot.callback

            local mainframe = Instance.new("Frame", options)
            mainframe.AutomaticSize = Enum.AutomaticSize.Y
            mainframe.BackgroundTransparency = 1
            mainframe.Size = UDim2.new(1,0,0,40)
            table.insert(ministuff, mainframe)

            local tbname = Instance.new("TextLabel", mainframe)
            tbname.AnchorPoint = Vector2.new(0.5,0)
            tbname.BackgroundTransparency = 1
            tbname.Position = UDim2.new(0.5,0,0,0)
            tbname.Size = UDim2.new(1,0,0,40)
            tbname.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Medium)
            tbname.Text = name
            tbname.TextColor3 = Color3.fromRGB(150,150,150)
            tbname.TextSize = 14
            tbname.TextXAlignment = Enum.TextXAlignment.Left
            tbname.TextYAlignment = Enum.TextYAlignment.Top
            local namepad = Instance.new("UIPadding", tbname)
            namepad.PaddingLeft = UDim.new(0,8)

            local descriptiontext = Instance.new("TextLabel", mainframe)
            descriptiontext.AnchorPoint = Vector2.new(0.5,0)
            descriptiontext.BackgroundTransparency = 1
            descriptiontext.Position = UDim2.new(0.5,0,1,0)
            descriptiontext.Size = UDim2.new(1,0,0,20)
            descriptiontext.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
            descriptiontext.Text = desc
            descriptiontext.TextColor3 = Color3.fromRGB(150,150,150)
            descriptiontext.TextSize = 13
            descriptiontext.TextWrapped = true
            descriptiontext.TextXAlignment = Enum.TextXAlignment.Left
            local tbdpad = Instance.new("UIPadding", descriptiontext)
            tbdpad.PaddingLeft = UDim.new(0,8)
            tbdpad.PaddingRight = UDim.new(0,8)

            local tbmain = Instance.new("TextBox", mainframe)
            tbmain.AnchorPoint = Vector2.new(0.5,0)
            tbmain.BackgroundColor3 = Color3.fromRGB(43,42,43)
            tbmain.Position = UDim2.new(0.5,0,0,20)
            tbmain.Size = UDim2.new(0.98, 0, 0, 20)
            tbmain.FontFace = Font.new("rbxassetid://11702779517", Enum.FontWeight.Regular)
            tbmain.PlaceholderColor3 = Color3.fromRGB(178,178,178)
            tbmain.PlaceholderText = desc
            tbmain.TextColor3 = Color3.fromRGB(255,255,255)
            tbmain.TextSize = 14
            tbmain.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", tbmain)
            local tbmainpad = Instance.new("UIPadding", tbmain)
            tbmainpad.PaddingLeft = UDim.new(0,8)
            local tbmaincon = Instance.new("UITextSizeConstraint", tbmain)
            tbmaincon.MaxTextSize = 13

            local data = shared.night.config.textboxes[flag] 
            if data then
                pcall(callback, args5, tostring(data))
                tbmain.Text = tostring(data)
            end

            local tbcon = tbmain.FocusLost:Connect(function()
                shared.night.config.textboxes[flag] = tostring(tbmain.Text)
                writefile(string.format("Night/Config/%s/config.json", rootid), https:JSONEncode(shared.night.config))
                pcall(callback, args5, tostring(tbmain.Text))
            end)
            table.insert(nightcons, tbcon)
            table.insert(modulecons, tbcon)
        end
        modulefuncs.destroymodule = function()
            for _,v in modulecons do
                pcall(function()
                    if v and v.Connected then v:Disconnect() end
                end)
            end
            local lowest
            local lowestpos = 0
            for i,v in next, moduleinsides do
                if v:IsA("Frame") then
                    local abpos = v.AbsolutePosition
                    if abpos.Y > lowestpos then
                        lowest = v
                        lowestpos = abpos.Y
                    end
                end
            end
            local bgparent
            if backgroundframe then
                bgparent = backgroundframe.Parent
                backgroundframe:Destroy()
            end
            if not bgparent:FindFirstChildWhichIsA("Frame") and bgparent then
                bgparent:Destroy()
            else
                if lowest and bgparent and lowest ~= bgparent then
                    if lowest:FindFirstChildWhichIsA("Frame") then
                        lowest:FindFirstChildWhichIsA("Frame").Parent = bgparent
                        if not lowest:FindFirstChildWhichIsA("Frame") then
                            lowest:Destroy()
                        end
                    else
                        lowest:Destroy()
                    end
                end
            end
            if modcount == 1 then 
                modcount = 2 
            else 
                modcount = 1 
            end
            shared.night.modules[name].call(false)
            modules[name] = nil
            shared.night.modules[name] = nil
        end
        if tab == "modules" then
            modules[name] = backgroundframe
        end
        return modulefuncs
    end
    return tabdata
end

callhide = function(hidden)
    if hidden then
        for i,v in next, actualbuttons do
            ts:Create(v, TweenInfo.new(0.45), {TextTransparency = 1}):Play()
        end
        selecttabwork.Position = UDim2.new(0.005,-48,0,0)
        ts:Create(actualbuttons.hide:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.28), {Rotation = 180}):Play()
        ts:Create(dashpad, TweenInfo.new(0.25), {PaddingTop = UDim.new(0,25)}):Play()
        ts:Create(paddingmodules, TweenInfo.new(0.25), {PaddingTop = UDim.new(0,40)}):Play()
        ts:Create(tabs, TweenInfo.new(0.35), {Size = UDim2.new(0.065, 0, 0.94, 0)}):Play()
        ts:Create(tabholder, TweenInfo.new(0.38), {Size = UDim2.new(0.935, 0,1, 0)}):Play()
    else
        for i,v in next, actualbuttons do
            ts:Create(v, TweenInfo.new(0.45), {TextTransparency = 0}):Play()
        end
        selecttabwork.Position = UDim2.new(0.001,-55,0,0)
        ts:Create(tabholder, TweenInfo.new(0.38), {Size = UDim2.new(0.77,0,1,0)}):Play()
        ts:Create(tabs, TweenInfo.new(0.35), {Size = UDim2.new(0.22,0,0.94,0)}):Play()
        ts:Create(paddingmodules, TweenInfo.new(0.25), {PaddingTop = UDim.new(0,10)}):Play()
        ts:Create(actualbuttons.hide:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.28), {Rotation = 0}):Play()
        ts:Create(dashpad, TweenInfo.new(0.25), {PaddingTop = UDim.new(0,5)}):Play()
    end
end


local hidden = false
table.insert(nightcons, actualbuttons.dashboard.MouseButton1Click:Connect(function()
    selecttabwork = actualbuttons.dashboard:FindFirstChildWhichIsA("Frame")
    callhide(hidden)
    for i,v in next, tabholder:GetChildren() do
        if v == dashboard then
            for i2, v2 in next, v:GetChildren() do
                if not v2:IsA("UIListLayout") and not v2:IsA("UIPadding") and not v2:IsA("UICorner") and not v2:IsA("UITextSizeConstraint") and not v2:IsA("UIAspectRatioConstraint") then
                    v2.Visible = true
                end
            end
        end
        for i,v in next, buttons do
            ts:Create(v, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            ts:Create(v, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            ts:Create(v:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150,150,150)}):Play()
            ts:Create(v:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        end
        ts:Create(actualbuttons.dashboard:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        ts:Create(actualbuttons.dashboard, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
        ts:Create(actualbuttons.dashboard:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(225, 225, 225)}):Play()
        ts:Create(actualbuttons.dashboard, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        dashboard.Position = UDim2.new(0, 0, -3, 0)
        dashboard.Visible = true
        ts:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,3,0)}):Play()
        ts:Create(dashboard, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
    end
end))

table.insert(nightcons, actualbuttons.modules.MouseButton1Click:Connect(function()
    selecttabwork = actualbuttons.modules:FindFirstChildWhichIsA("Frame")
    callhide(hidden)
    for i,v in next, buttons do
        ts:Create(v, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        ts:Create(v, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150,150,150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    end
    ts:Create(actualbuttons.modules:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    ts:Create(actualbuttons.modules, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.modules:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.modules, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    for i,v in next, tabholder:GetChildren() do
        modulestab.Position = UDim2.new(0, 0, -3, 0)
        modulestab.Visible = true
        ts:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,3,0)}):Play()
        ts:Create(modulestab, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
    end
end))

table.insert(nightcons, actualbuttons.premium.MouseButton1Click:Connect(function()
    selecttabwork = actualbuttons.premium:FindFirstChildWhichIsA("Frame")
    callhide(hidden)
    for i,v in next, buttons do
        ts:Create(v, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        ts:Create(v, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150,150,150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    end
    ts:Create(actualbuttons.premium:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    ts:Create(actualbuttons.premium, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.premium:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.premium, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    for i,v in next, tabholder:GetChildren() do
        premiumtab.Position = UDim2.new(0, 0, -3, 0)
        premiumtab.Visible = true
        ts:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,3,0)}):Play()
        ts:Create(premiumtab, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
    end
end))

table.insert(nightcons, actualbuttons.settings.MouseButton1Click:Connect(function()
    selecttabwork = actualbuttons.settings:FindFirstChildWhichIsA("Frame")
    callhide(hidden)
    for i,v in next, buttons do
        ts:Create(v, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
        ts:Create(v, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150,150,150)}):Play()
        ts:Create(v:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    end
    ts:Create(actualbuttons.settings:FindFirstChildWhichIsA("Frame"), TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    ts:Create(actualbuttons.settings, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.settings:FindFirstChildWhichIsA("ImageLabel"), TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(225, 225, 225)}):Play()
    ts:Create(actualbuttons.settings, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    for i,v in next, tabholder:GetChildren() do
        settingstab.Position = UDim2.new(0, 0, -3, 0)
        settingstab.Visible = true
        ts:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,3,0)}):Play()
        ts:Create(settingstab, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0,0,0,0)}):Play()
    end
end))

table.insert(nightcons, actualbuttons.themes.MouseButton1Click:Connect(function()
    mainlib.notify({
        info = "In the works!",
        time = 5
    })
end))
table.insert(nightcons, actualbuttons.configs.MouseButton1Click:Connect(function()
    mainlib.notify({
        info = "In the works!",
        time = 5
    })
end))
table.insert(nightcons, actualbuttons.credits.MouseButton1Click:Connect(function()
    mainlib.notify({
        info = "In the works!",
        time = 5
    })
end))
table.insert(nightcons, actualbuttons.guides.MouseButton1Click:Connect(function()
    mainlib.notify({
        info = "In the works!",
        time = 5
    })
end))

table.insert(nightcons, actualbuttons.hide.MouseButton1Click:Connect(function()
    hidden = not hidden
    callhide(hidden)
end))


local updated = mainlib.createupdatelog({
    version = "1.1",
    date = "19/07/2024",
    layout = 0
})
updated.addchange({
    change = "add",
    info = "Ported Super Soccer League Modules"
})


local updated = mainlib.createupdatelog({
    version = "1.0",
    date = "19/07/2024",
    layout = 1
})
updated.addchange({
    change = "add",
    info = "Ported Bladeball Modules"
})
updated.addchange({
    change = "change",
    info = "New UI"
})




local tabss = {
    settings = mainlib.newtab({name = "settings", tab = "settings"}),
    prem = mainlib.newtab({name = "premium", tab = "premium"})
}

local hudsetting = "Toggle"
local hud = tabss.settings.newmodule({
    name = "HUD", 
    icon = "rbxassetid://18563760665",
    button = true,
    callback = function(self, call)
        if call then
            if hudsetting == "Toggle" then
                mainframe.Visible = not mainframe.Visible
            elseif hudsetting == "Uninject" then
                shared.night:uninject()
            end
        end
    end,
    keybindcallback = function()
        shared.night.togglecode = nil
    end
})
hud.dropdown({
    name = "Mode",
    description = "Pick what you want the hud toggle to do",
    options = {"Toggle", "Uninject", "Reinject"},
    def = hudsetting,
    callback = function(self, call)
        hudsetting = call
    end
})
notifications = tabss.settings.newmodule({
    name = "Notifications", 
    icon = "rbxassetid://11295275950",
    def = true,
    button = false,
    callback = function(self, call) 
        usenotis = call
    end
})
notifications.dropdown({
    name = "Location",
    description = "Pick where the location of a notification is",
    options = {"Right", "Center", "Left"},
    flag = "notificationlocationdrop",
    def = notificationlocation,
    callback = function(self, call)
        notificationlocation = call
        if call == "Right" then
            notificationlist.HorizontalAlignment = Enum.HorizontalAlignment.Right
        elseif call == "Center" then
            notificationlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        elseif call == "Left" then
            notificationlist.HorizontalAlignment = Enum.HorizontalAlignment.Left
        end
    end
})
notifications.minitoggle({
    name = "ToggleNotifications",
    def = true,
    description = "Gives you a notification when a module is enabled/disabled",
    flag = "notificationstoggle",
    callback = function(self, call)
        togglenotis = call
    end
})
mainlib.notify({
    info = string.format("Loaded in %ss", tostring(math.round(tick()-loadtime))),
    time = 5
})
return mainlib
