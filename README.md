# Five Car Call — Watch Dogs 2 (PC)

**Release status:** ScriptHook prototype only. No dependency-free patch is included. The native version still needs the APB, Gang Attack and dispatch records from the game.

An experimental single-player Lua mod for Nomad Group's WD2 ScriptHook. With ScriptHook installed, copy `five_car_call` into `Watch_Dogs2/data/scripts/` so the manifest is at `data/scripts/five_car_call/manifest.json`. Restart the game in offline story mode.

Aim directly at a pedestrian on a wide, level street, then press:

| Key | Action |
| --- | --- |
| F6 | Stage five police cars and request a police pursuit of the reticle target |
| F7 | Stage five 580s muscle cars and request a gang pursuit |
| F8 | Stage five FBI SUVs and request FBI pursuit (police AI if no FBI faction is exposed) |
| F9 | Remove the staged vehicles, without changing heat or cancelling game AI |

These are separate shortcuts, not replacements for the profiler hacks. Each valid call replaces the previous set of cars. Vehicle positions are relative to the target, not snapped to roads; avoid interiors, slopes and traffic. The reticle can also hit props, so check your aim.

**Prototype limits:** spawning vehicles and requesting pursuit are separate operations. The cars are not crewed arrest units. ScriptHook's trainer demonstrates `FelonyStartChase` against the player; whether the game accepts a particular NPC as its target needs in-game testing. Neither gang detention nor an FBI arrest animation is implemented. Requires the `VehicleArchetype` and `Fractions` tables used by the [WD2 trainer](https://github.com/clemenzi/wd2). Remove the mod folder and restart to uninstall.
