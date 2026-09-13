# v0.3.0
- Fixed typo with `GAMEPLAY.DISABLED_CONTROLS` causing weapon wheel to still work.
- Swapped notifications default position to top right; it sits behind inventory and is annoying its a quick fix for now.
- Moved player emit event `before_save` to before actually before the save.

# v0.2.0

- Swapped `gui` prefix to `nui` throughout
- Added proper support for progressbars
- Swapped bar type header to message and added /1000 to circles timer to keep both systems api uniform