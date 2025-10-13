# VpnToggle for Hammerspoon

**VpnToggle** shows your VPN status in the menubar and lets you toggle it with a hotkey.

* Works with **any VPN** via macOS system APIs — no need to open the VPN app
* Shows status: **Connected / Disconnected**

---

## Installation

1. Put `VpnToggle.lua` in `~/.hammerspoon/`
2. Copy the `icons` folder from the repository root into `~/.hammerspoon/`:

   ```
   connected.svg
   connecting.svg
   disconnected.svg
   ```

---

## Usage

Add to `~/.hammerspoon/init.lua`:

```lua
require("VpnToggle")
```

---

## Configuration

Inside `VpnToggle.lua` you can adjust:

```lua
local hotkeyKey         -- Hotkey to toggle VPN
local updateInterval    -- Interval to update the icon (in seconds)
```
