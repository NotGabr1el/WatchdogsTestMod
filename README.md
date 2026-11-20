# Five Car Call — Watch Dogs 2 (PC)

**Release status:** ScriptHook prototype only. No dependency-free patch is included. The native version still needs the APB, Gang Attack and dispatch records from the game.

## Install on Windows

1. Install Nomad Group’s WD2 ScriptHook with the trainer data first, and close the game.
2. **[Download the installer ZIP](Five-Car-Call-Prototype-Installer.zip?raw=true)** and choose **Extract All**. You do not need to clone the repository.
3. Double-click `Install.cmd`, then paste the Watch Dogs 2 folder that contains `bin/WatchDogs2.exe`. Restart in offline story mode.

**Updating?** Move your existing `data/scripts/five_car_call` folder outside the scripts directory first. The installer never overwrites it. For a manual install, copy the extracted `five_car_call` folder into `data/scripts/`.

## Play

Aim directly at a pedestrian on a wide, level street, then press:

| Key | Action |
| --- | --- |
| F6 | Stage five police cars and request a police pursuit of the reticle target |
| F7 | Stage five 580s muscle cars and request a gang pursuit |
| F8 | Stage five FBI SUVs and request FBI pursuit (police AI if no FBI faction is exposed) |
| F9 | Remove the staged vehicles, without changing heat or cancelling game AI |
| F10 | Fleet mashup: stage police cruisers, gang cars and an FBI SUV together; request one random response profile |
| F11 | Switch future calls between a surround ring and a five-car roadblock line |

These are separate shortcuts, not replacements for the profiler hacks. Each valid call replaces the previous set of cars. Vehicle positions are relative to the target, not snapped to roads; avoid interiors, slopes and traffic. The reticle can also hit props, so check your aim.

**Prototype limits:** spawning vehicles and requesting pursuit are separate operations. The cars are not crewed arrest units. ScriptHook's trainer demonstrates `FelonyStartChase` against the player; whether the game accepts a particular NPC as its target needs in-game testing. Neither gang detention nor an FBI arrest animation is implemented. Requires the `VehicleArchetype` and `Fractions` tables used by the [WD2 trainer](https://github.com/clemenzi/wd2). Remove the mod folder and restart to uninstall.

## Preparing the no-ScriptHook version

The [WD2 archive file list](https://github.com/DrTexx/Watch_Dogs-2-Modding/blob/master/filelist.txt) identifies native reinforcement, wave and affiliation databases, but does not include their contents. To help identify which records the APB and Gang Attack hacks actually use, run this in Windows PowerShell from this repository, against your **unpacked** game data (use the effective patched versions):

```powershell
.\tools\Collect-DispatchRecords.ps1 -UnpackedRoot 'D:\WD2-unpacked'
```

Attach `wd2-dispatch-inputs.zip` for analysis, plus the profiler hack definitions if you have them. The collector does not change the game, extract packed archives, or run during gameplay. The ZIP is research input, not a patch; do not install it. A working patch needs to change the NPC-targeted calls without changing ordinary player pursuits.
