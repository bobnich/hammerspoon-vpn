-- Configuration
local hotkeyKey = "f13"
local updateInterval = 2

-- Script
local vpn = hs.execute([[scutil --nc list | awk -F'"' '/\*/{print $2}']]):gsub("\n", "")

local vpnMenu = hs.menubar.new()

local iconsPath = "~/.hammerspoon/icons/"
local icons = {
    connected    = iconsPath .. "connected.svg",
    connecting   = iconsPath .. "connecting.svg",
    disconnected = iconsPath .. "disconnected.svg",
}

local statuses = {
    connected    = "connected",
    connecting   = "connecting",
    disconnected = "disconnected",
}

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
    else
        return statuses.disconnected
    end
end

local function isBusy()
    return vpnStatus() == statuses.connecting
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

    local status = vpnStatus()
    if status == statuses.connected then
        updateIcon(statuses.disconnected)
        hs.execute(string.format('scutil --nc stop "%s"', vpn))
    else
        updateIcon(statuses.connected)
        hs.execute(string.format('scutil --nc start "%s"', vpn))
    end
end

hs.hotkey.bind({}, hotkeyKey, toggleVPN)

hs.timer.doEvery(updateInterval, updateIcon)
