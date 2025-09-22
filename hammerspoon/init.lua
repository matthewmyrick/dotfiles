-- Hammerspoon config to auto-maximize certain applications and prevent sketchybar overlap

-- Height of sketchybar (adjust if your bar is different)
local SKETCHYBAR_HEIGHT = 32
-- Add extra padding to ensure no overlap
local EXTRA_PADDING = 5

-- List of applications that should be maximized when opened
local appsToMaximize = {
    "Microsoft Teams",
    "Teams",
    "Slack",
    "Discord",
    "Code",
    "Visual Studio Code",
    "Chrome",
    "Safari",
    "Firefox",
    "Notion",
    "Obsidian"
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
    
    -- Only adjust for external monitors, not laptop screen
    if not isLaptopScreen(screen) then
        frame.y = frame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING
        frame.h = frame.h - SKETCHYBAR_HEIGHT - EXTRA_PADDING
    end
    
    return frame
end

-- Function to check if window overlaps with sketchybar
function windowOverlapsBar(window)
    if not window then return false end
    
    local screen = window:screen()
    -- Skip check for laptop screen
    if isLaptopScreen(screen) then
        return false
    end
    
    local frame = window:frame()
    local screenFrame = screen:frame()
    
    -- Check if window starts too close to the top of the screen (including padding)
    return frame.y < (screenFrame.y + SKETCHYBAR_HEIGHT + EXTRA_PADDING)
end

-- Function to fix window if it overlaps sketchybar
function fixWindowIfNeeded(window)
    if window and window:isStandard() then
        local screen = window:screen()
        
        -- Skip laptop screen
        if isLaptopScreen(screen) then
            return
        end
        
        if windowOverlapsBar(window) then
            local safeFrame = getSafeFrame(screen)
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

-- Function to maximize a window (respects menu bar and sketchybar)
function maximizeWindow(window)
    if window then
        local screen = window:screen()
        local safeFrame = getSafeFrame(screen)
        
        -- Add some debug logging
        print("Maximizing window: " .. (window:title() or "Unknown"))
        print("Safe frame: " .. safeFrame.x .. "," .. safeFrame.y .. " " .. safeFrame.w .. "x" .. safeFrame.h)
        
        -- Set the window frame to safe area (not covering sketchybar)
        window:setFrame(safeFrame)
        
        -- Show alert for debugging
        hs.alert.show("Maximized (respecting sketchybar): " .. (window:title() or "Window"), 1)
    end
end

-- Function to check if app should be maximized
function shouldMaximize(appName)
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
    if shouldMaximize(appName) then
        print("Should maximize: " .. appName)
        -- Longer delay for Stage Manager compatibility
        hs.timer.doAfter(1.0, function()
            if window and window:isVisible() then
                maximizeWindow(window)
            else
                print("Window not visible, skipping maximize")
            end
        end)
    end
end)

-- Watch for application launch events (backup method)
appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched and shouldMaximize(appName) then
        hs.timer.doAfter(0.5, function()
            local windows = appObject:allWindows()
            for _, window in ipairs(windows) do
                if window:isStandard() then
                    maximizeWindow(window)
                end
            end
        end)
    end
end)

appWatcher:start()

-- Keyboard shortcut to manually maximize current window
hs.hotkey.bind({"cmd", "alt"}, "m", function()
    local window = hs.window.focusedWindow()
    if window then
        maximizeWindow(window)
        hs.alert.show("Window maximized")
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

-- Show notification when Hammerspoon loads
hs.alert.show("Hammerspoon loaded - Sketchybar protection enabled")