# v0.5.0
- Added missing `KeyValuePairs` ui handlers and client events
- Added `keys.lua` client side module
- Added `zones.lua` client module, just a smaller version of my `zone_creator` script in graft without the drawn ui
- Client side gameplay loops now wait until player is playing
- Added `TextUI` & `DUISprite` from `rig_interactions`
- Added new `dui.lua` client module
- Added all exports for textui into client `nui.lua` module
- Combined `TextUI` & `KeyValuePairs` into new `displays` folder

# v0.4.0
- Added new menu system that was built for `rig_admin` have some other use cases for it than just that; `exports.rig:open_quickmenu(menu)`, `close_quickmenu()`, `is_quickmenu_open()`, `push_quickmenu_update()`.
- Moved `helpers.js` to `ui/` instead of being nested in framework stuff.
- Added `rig:copycoords` command from `rig_admin` into here instead.
- Added a smaller version of my paid radial menu; `exports.rig:open_radial(menu)`, `is_radial_open()`, `close_radial()`

# v0.3.0
- Fixed typo with `GAMEPLAY.DISABLED_CONTROLS` causing weapon wheel to still work.
- Swapped notifications default position to top right; it sits behind inventory and is annoying its a quick fix for now.
- Moved player emit event `before_save` to before actually before the save.
- Added inventory UI stuff back into UI kit.

# v0.2.0

- Swapped `gui` prefix to `nui` throughout
- Added proper support for progressbars
- Swapped bar type header to message and added /1000 to circles timer to keep both systems api uniformW