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

### Bind Hotkeys

Specify the hotkeys to toggle your VPN:

```lua
spoon.VpnToggle:bindHotkeys({
    { mods = {"cmd", "ctrl"}, key = "v" }, -- ⌘ + Ctrl + V
    { mods = {}, key = "f13" },            -- F13
})
```

* `mods` — table of modifier keys (`"cmd"`, `"ctrl"`, `"alt"`, `"shift"`)
* `key` — the key used to toggle the VPN

### Enable Sleep/Wake Handling

Automatically disconnects VPN before sleep and reconnects after wake:

```lua
spoon.VpnToggle:addSleepWatcher()  -- default delay of 3 seconds
```

Optionally, specify a custom delay (in seconds) before reconnecting:

```lua
spoon.VpnToggle:addSleepWatcher({delay = 5})
```

### Start the Spoon

```lua
spoon.VpnToggle:start()
```
