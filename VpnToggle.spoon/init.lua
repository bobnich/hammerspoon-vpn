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

local vpn = hs.execute([[scutil --nc list | awk -F'"' '/\*/{print $2}']]):gsub("\n", "")

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

local function vpnStatus()
    local output = hs.execute(string.format('scutil --nc status "%s" 2>/dev/null', vpn)) or ""
    output = trim(output)
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

local function waitForStatusChange(oldStatus, timeout, interval)
    local elapsed = 0

    local function shouldStop(newStatus)
        if newStatus ~= oldStatus
           and newStatus ~= statuses.connecting
           and newStatus ~= statuses.disconnecting then
            return true
        end
        return elapsed >= timeout
    end

    local timer
    timer = hs.timer.doEvery(interval, function()
        elapsed = elapsed + interval
        local newStatus = vpnStatus()
        updateIcon(newStatus)
        if shouldStop(newStatus) then
            timer:stop()
        end
    end)
end

local function toggleVPN()
    if isBusy() then return end

    local oldStatus = vpnStatus()

    if oldStatus == statuses.connected then
        updateIcon(statuses.disconnecting)
        hs.execute(string.format('scutil --nc stop "%s"', vpn))
    else
        updateIcon(statuses.connecting)
        hs.execute(string.format('scutil --nc start "%s"', vpn))
    end

    waitForStatusChange(oldStatus, 3, 0.5)
end

-------------------------------------------------------
-- Spoon Methods
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

function obj:start()
    for _, hk in ipairs(obj.hotkeys) do
        local mods, key = hk.mods or {}, hk.key
        hs.hotkey.bind(mods, key, toggleVPN)
    end

    local updateInterval = 3
    hs.timer.doEvery(updateInterval, updateIcon)

    updateIcon()
    return self
end

return obj
