--- === VpnToggle ===
---
--- Toggle macOS VPN connections via scutil, with menubar icon and hotkeys.
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "VpnToggle"
obj.version = "1.0"
obj.author = "Bob Nicholson"
obj.homepage = "https://github.com/bobnich/toggle-vpn-spoon"
obj.license = "MIT"

-------------------------------------------------------
-- Internal Variables
-------------------------------------------------------

obj.hotkeys = {}

local vpn

local vpnMenu = hs.menubar.new()

local iconsPath = hs.spoons.resourcePath("icons/")

local icons = {
    connected     = iconsPath .. "connected.svg",
    connecting    = iconsPath .. "progress.svg",
    disconnecting = iconsPath .. "progress.svg",
    disconnected  = iconsPath .. "disconnected.svg",
}

local statuses = {
    connected     = "connected",
    connecting    = "connecting",
    disconnecting = "disconnecting",
    disconnected  = "disconnected",
}

-------------------------------------------------------
-- Helper Functions
-------------------------------------------------------

local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-------------------------------------------------------
-- macOS System API
-------------------------------------------------------

local function systemVpnName() 
    return hs.execute(
        [[scutil --nc list | awk -F'"' '/\*/{print $2}']]
    ):gsub("\n", "")
end

local function systemVpnStatus(name)
    return hs.execute(
        string.format('scutil --nc status "%s" 2>/dev/null', name)
    ) or ""
end

local function systemStartVpn(name)
    hs.execute(
        string.format('scutil --nc start "%s"', name)
    )
end

local function systemStopVpn(name)
    hs.execute(
        string.format('scutil --nc stop "%s"', name)
    )
end

-------------------------------------------------------
-- Spoon's VPN Core
-------------------------------------------------------

local function vpnStatus()
    local output = trim(systemVpnStatus(vpn))
    if output:match("^Connected") then
        return statuses.connected
    elseif output:match("^Connecting") then
        return statuses.connecting
    elseif output:match("^Disconnecting") then
        return statuses.disconnecting
    else
        return statuses.disconnected
    end
end

local function isBusy()
    local status = vpnStatus()
    local busyStatuses = {
        [statuses.connecting] = true,
        [statuses.disconnecting] = true,
    }
    return busyStatuses[status] == true
end

local function updateIcon(status)
    if vpnMenu then
        status = status or vpnStatus()
        local iconFile = icons[status]
        if iconFile then
            vpnMenu:setIcon(iconFile)
        end
    end
end

local function toggleVPN()
    if isBusy() then return end

    local oldStatus = vpnStatus()

    if oldStatus == statuses.connected then
        updateIcon(statuses.disconnecting)
        systemStopVpn(vpn)
    else
        updateIcon(statuses.connecting)
        systemStartVpn(vpn)
    end
end

-------------------------------------------------------
-- Periodic VPN Status Check
-------------------------------------------------------

local periodicTimer

local function startPeriodicStatusCheck()
    if periodicTimer then
        periodicTimer:stop()
        periodicTimer = nil
    end

    periodicTimer = hs.timer.new(1, function()
        updateIcon()
    end, true)
    periodicTimer:start()
end

-------------------------------------------------------
-- Sleep/Wake Handling
-------------------------------------------------------

local sleepWatcher
local awakeDelay
local wasConnectedBeforeSleep = false

local function sleepWatcherCallback(eventType)
    if eventType == hs.caffeinate.watcher.systemWillSleep then
        local status = vpnStatus()
        if status == statuses.connected then
            wasConnectedBeforeSleep = true
            systemStopVpn(vpn)
            updateIcon(statuses.disconnecting)
        else
            wasConnectedBeforeSleep = false
        end
    elseif eventType == hs.caffeinate.watcher.systemDidWake then
        hs.timer.doAfter(awakeDelay, function()
            if wasConnectedBeforeSleep then
                local oldStatus = vpnStatus()
                systemStartVpn(vpn)
                updateIcon(statuses.connecting)
                wasConnectedBeforeSleep = false
            else
                updateIcon()
            end
        end)
    end
end

-------------------------------------------------------
-- Public API
-------------------------------------------------------

--- VpnToggle:bindHotkeys(hotkeyTable)
--- Method
--- Binds hotkeys for VPN toggling.
--- Example:
--- spoon.VpnToggle:bindHotkeys({
---     { mods = {"cmd", "ctrl"}, key = "v" },
---     { mods = {}, key = "f1" },
--- })
function obj:bindHotkeys(hotkeyTable)
    if type(hotkeyTable) ~= "table" then return end
    obj.hotkeys = hotkeyTable
end

--- VpnToggle:start()
--- Method
--- Starts spoon
function obj:start()
    for _, hk in ipairs(obj.hotkeys) do
        local mods, key = hk.mods or {}, hk.key
        hs.hotkey.bind(mods, key, toggleVPN)
    end

    vpn = systemVpnName()

    startPeriodicStatusCheck()

    return self
end

--- VpnToggle:addSleepWatcher(delay)
--- Method
--- Adds sleep and awake watcher
function obj:addSleepWatcher(delay)
    if sleepWatcher then return self end
    awakeDelay = delay or 5
    sleepWatcher = hs.caffeinate.watcher.new(
        sleepWatcherCallback
    )
    sleepWatcher:start()
    return self
end

--- VpnToggle:removeSleepWatcher()
--- Method
--- Removes sleep and awake watcher
function obj:removeSleepWatcher()
    if sleepWatcher then
        sleepWatcher:stop()
        sleepWatcher = nil
    end
    return self
end

return obj
