![demo](.github/header.gif)

# VpnToggle for Hammerspoon

**VpnToggle** is a Hammerspoon Spoon that shows your VPN status in the menubar and lets you toggle it using hotkeys.

* Works with **any macOS VPN** via system APIs — no need to open the VPN app.
* Displays status: **Connected / Connecting / Disconnecting / Disconnected**.
* Hotkeys are configurable from your `init.lua`.
* Optional **sleep/awake watcher** can automatically disconnect VPN on sleep and reconnect on wake.

---

## Installation

1. Place the `VpnToggle.spoon` folder in `~/.hammerspoon/Spoons/`.
2. Load the Spoon in your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("VpnToggle")
```

---

## Configuration

Set your preferred hotkeys in `init.lua`:

```lua
-- Example: bind VPN toggle to ⌘ + Ctrl + V and F13
spoon.VpnToggle:bindHotkeys({
    { mods = {"cmd", "ctrl"}, key = "v" },
    { mods = {}, key = "f13" },
})
-- Enable sleep/awake VPN handling
spoon.VpnToggle:addSleepWatcher()

spoon.VpnToggle:start()
```

* `mods` — table of modifier keys (`"cmd"`, `"ctrl"`, `"alt"`, `"shift"`)
* `key` — the key used to toggle the VPN
