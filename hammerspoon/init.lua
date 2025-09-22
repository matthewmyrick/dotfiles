-- Hammerspoon config to auto-maximize certain applications

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

-- Function to maximize a window (Stage Manager compatible)
function maximizeWindow(window)
    if window then
        local screen = window:screen()
        local max = screen:frame()
        
        -- Add some debug logging
        print("Maximizing window: " .. (window:title() or "Unknown"))
        print("Screen frame: " .. max.x .. "," .. max.y .. " " .. max.w .. "x" .. max.h)
        
        -- Try different approaches for Stage Manager
        window:setFrame(max)
        
        -- Alternative: Use maximize function if available
        if window.maximize then
            window:maximize()
        end
        
        -- Show alert for debugging
        hs.alert.show("Maximized: " .. (window:title() or "Window"), 1)
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

-- Show notification when Hammerspoon loads
hs.alert.show("Hammerspoon loaded - Auto-maximize enabled")