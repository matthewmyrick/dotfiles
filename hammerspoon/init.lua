-- Hammerspoon config to auto-size applications for Stage Manager + SketchyBar

-- Height of sketchybar (adjust if your bar is different)
local SKETCHYBAR_HEIGHT = 32
-- Add extra padding to ensure no overlap
local EXTRA_PADDING = 5

-- List of applications that should be maximized when opened
-- Set to true to resize ALL apps, or add specific apps to the list
local RESIZE_ALL_APPS = true  -- Change this to false to only resize specific apps

local appsToMaximize = {
    -- Microsoft Apps
    "Microsoft Teams",
    "Microsoft Excel",
    "Microsoft OneNote",
    "Microsoft Outlook",
    "Skype for Business",
    
    -- Browsers
    "Google Chrome",
    "Chrome",
    "Safari",
    "Firefox",
    
    -- Development
    "Visual Studio Code",
    "Code",
    "Ghostty",
    "Terminal",
    "iTerm2",
    "Warp",
    "Lens",
    "Rancher Desktop",
    "VirtualBox",
    
    -- Productivity
    "Slack",
    "Discord",
    "Notion",
    "Obsidian",
    "Spotify",
    "zoom.us",
    "OneDrive",
    "Keeper Password Manager",
    "Keeper Commander",
    
    -- Work/Enterprise
    "Citrix Workspace",
    "Company Portal",
    "Enterprise Connect",
    "Netskope Client",
    "VIP Access",
    "TeamViewerHost",
    "Tailscale",
    "RabbitSync",
    "Self Service",
    
    -- Window Management (might not need resizing)
    "Rectangle",
    "Hammerspoon",
    "Karabiner-Elements",
    "Karabiner-EventViewer"
}

-- Function to check if screen is the built-in laptop display
function isLaptopScreen(screen)
    local screenName = screen:name()
    -- Built-in displays usually contain "Built-in" or "Color LCD" in their name
    return string.find(screenName, "Built%-in") ~= nil or 
           string.find(screenName, "Color LCD") ~= nil or
           string.find(screenName, "Liquid Retina") ~= nil
end

-- Function to get safe frame that doesn't overlap sketchybar
function getSafeFrame(screen)
    local frame = screen:frame()

    -- Account for SketchyBar at top (all screens)
    frame.y = frame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING
    frame.h = frame.h - SKETCHYBAR_HEIGHT - EXTRA_PADDING

    return frame
end

-- Function to check if window overlaps with sketchybar
function windowOverlapsBar(window)
    if not window then return false end

    local screen = window:screen()
    local frame = window:frame()
    local screenFrame = screen:frame()

    -- Check if window starts too close to the top of the screen (including padding)
    return frame.y < (screenFrame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING)
end

-- Function to fix window if it overlaps sketchybar
function fixWindowIfNeeded(window)
    if window and window:isStandard() then
        local screen = window:screen()

        if windowOverlapsBar(window) then
            local currentFrame = window:frame()
            local screenFrame = screen:frame()

            -- Adjust the window to not overlap sketchybar (with padding)
            if currentFrame.y < (screenFrame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING) then
                currentFrame.y = screenFrame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING
                -- Adjust height if window goes beyond screen bottom
                local maxHeight = screenFrame.h - SKETCHYBAR_HEIGHT - EXTRA_PADDING
                if currentFrame.h > maxHeight then
                    currentFrame.h = maxHeight
                end
                window:setFrame(currentFrame)
                print("Fixed window overlap on " .. screen:name() .. ": " .. (window:title() or "Unknown"))
            end
        end
    end
end

-- Function to resize a window (respects menu bar and sketchybar)
function resizeWindow(window, showNotification)
    if window then
        local screen = window:screen()
        local safeFrame = getSafeFrame(screen)

        -- Add some debug logging
        print("Resizing window: " .. (window:title() or "Unknown"))
        print("Safe frame: " .. safeFrame.x .. "," .. safeFrame.y .. " " .. safeFrame.w .. "x" .. safeFrame.h)

        -- Set the window frame to safe area (not covering sketchybar)
        window:setFrame(safeFrame)

        -- Show notification only when explicitly requested (for new windows)
        if showNotification then
            hs.alert.show("Window auto-sized: " .. (window:title() or "Window"), 1)
        end
    end
end

-- Function to check if app should be auto-resized
function shouldResize(appName)
    -- If RESIZE_ALL_APPS is true, resize everything
    if RESIZE_ALL_APPS then
        return true
    end
    
    -- Otherwise check if it's in our list
    for _, name in ipairs(appsToMaximize) do
        if string.find(string.lower(appName), string.lower(name)) then
            return true
        end
    end
    return false
end

-- Watch for window creation events
windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
    print("Window created: " .. appName .. " - " .. (window:title() or "Unknown"))
    if shouldResize(appName) then
        print("Should resize: " .. appName)
        -- Delay to let window settle
        hs.timer.doAfter(0.5, function()
            if window and window:isVisible() then
                resizeWindow(window, true)  -- Show notification for new windows
            else
                print("Window not visible, skipping resize")
            end
        end)
    end
end)

-- Watch for application launch events (backup method)
appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched and shouldResize(appName) then
        hs.timer.doAfter(0.5, function()
            local windows = appObject:allWindows()
            for _, window in ipairs(windows) do
                if window:isStandard() then
                    resizeWindow(window, true)  -- Show notification for new app launches
                end
            end
        end)
    end
end)

appWatcher:start()

-- Watch for window focus/activation to resize every time you switch to an app
-- This will trigger EVERY time you click on an app, even if it's already open
windowFocusFilter = hs.window.filter.new()
windowFocusFilter:subscribe(hs.window.filter.windowFocused, function(window, appName, event)
    if window and shouldResize(appName) then
        print("Window focused: " .. appName .. " - " .. (window:title() or "Unknown"))
        -- Immediate resize on focus (no delay needed for focus events)
        if window:isVisible() and window:isStandard() then
            resizeWindow(window, false)  -- No notification for focus events
        end
    end
end)

-- Keyboard shortcut to manually resize current window (Cmd+Alt+M)
hs.hotkey.bind({"cmd", "alt"}, "m", function()
    local window = hs.window.focusedWindow()
    if window then
        resizeWindow(window, false)  -- No notification for manual resize
        hs.alert.show("Window resized")
    end
end)

-- Keyboard shortcut to fix all windows on all monitors (Cmd+Alt+F)
hs.hotkey.bind({"cmd", "alt"}, "f", function()
    local count = 0
    local allWindows = hs.window.allWindows()
    for _, window in ipairs(allWindows) do
        if window:isStandard() then
            local oldFrame = window:frame()
            fixWindowIfNeeded(window)
            local newFrame = window:frame()
            if oldFrame.y ~= newFrame.y then
                count = count + 1
            end
        end
    end
    hs.alert.show("Fixed " .. count .. " windows")
end)

-- Active monitoring for window movements to prevent sketchybar overlap
-- This watches ALL windows, not just the ones we auto-maximize
windowMoveWatcher = hs.window.filter.new():setDefaultFilter()
windowMoveWatcher:subscribe({
    hs.window.filter.windowMoved,
    hs.window.filter.windowResized,
    hs.window.filter.windowFullscreened,
    hs.window.filter.windowUnfullscreened
}, function(window)
    if window and window:isStandard() then
        -- Small delay to let the move/resize complete
        hs.timer.doAfter(0.1, function()
            fixWindowIfNeeded(window)
        end)
    end
end)

-- Check all existing windows on startup and debug screens
hs.timer.doAfter(0.5, function()
    -- Debug: Print all screen information
    print("=== Screen Information ===")
    local screens = hs.screen.allScreens()
    for _, screen in ipairs(screens) do
        local name = screen:name()
        local frame = screen:frame()
        print("Screen: " .. name)
        print("  Position: " .. frame.x .. "," .. frame.y)
        print("  Size: " .. frame.w .. "x" .. frame.h)
        print("  Is Laptop: " .. tostring(isLaptopScreen(screen)))
    end
    print("========================")
    
    -- Fix all existing windows
    local allWindows = hs.window.allWindows()
    for _, window in ipairs(allWindows) do
        if window:isStandard() then
            fixWindowIfNeeded(window)
        end
    end
    print("Checked all existing windows for sketchybar overlap")
end)

-- Hammerspoon loaded (silent)
-- hs.alert.show("Hammerspoon loaded - SketchyBar compatible")