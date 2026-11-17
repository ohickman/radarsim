# Radar Sim

A marine radar and ARPA (automatic radar plotting aid) simulator for training and as a game. A Python program simulates own ship, traffic, weather, land, the radar video and the ARPA tracking. A Windows (WPF) program shows the radar picture and takes the controls. They talk over TCP on 127.0.0.1.

## Run it

You need Python 3.11 or newer with numpy, and the .NET SDK with the Windows desktop (WPF) workload. The project targets `net10.0-windows`; with an older SDK, change `TargetFramework` in `gui/RadarSim.csproj` to match `dotnet --version`.

```
dotnet run --project gui
```

Or double-click `RadarSim.bat` in the project folder, which does the same (it builds first if anything changed, and keeps a console window open for the log lines).

The display starts the sim itself and stops it when you close the window. It finds the project folder by looking upward from its executable for `radarsim.toml`; from anywhere else use `--root <project folder>`. `--no-launch` connects to a sim you started by hand (`python sim/sim_main.py`). The Python path is `general.python_executable` in `radarsim.toml`.

Self-tests: `dotnet run --project gui -- --selftest` (writes `selftest_results.txt`) and `python sim/test_m0.py` up to `python sim/test_m10.py`. `python sim/test_m10.py --soak` runs 30 sim-minutes at 10 times real time.

## Configuration: radarsim.toml

Keys marked `(runtime)` in the file can also be changed while the sim runs; all others are read at start-up.

| Section | What it holds |
| --- | --- |
| `[general]` | seed, scenario (`random` or `calibration`), port, Python path, sim speed, physics step, message verbosity |
| `[own_ship]` | size, start position, engine and telegraph speeds, rudder and turn limits, gyro and log errors |
| `[environment]` | wind, sea state (or from the wind), current, rain |
| `[traffic]` | contact limit, density, the mix of kinds |
| `[traffic.ship]`, `[traffic.tug_tow]`, `[traffic.fishing]`, `[traffic.pleasure]` | speeds, sizes, radar cross sections and behaviour of each kind of contact |
| `[radar]` | antenna, pulse, beam, range scales, video range, land and clutter model |
| `[radar_controls]` | gain, STC and FTC |
| `[arpa]` | tracker, acquisition, CPA and TCPA limits, guard zones, alarms |
| `[display]` | colours, rings, orientation, motion, vectors, trails, brilliance, instructor overlay |
| `[game]` | what happens on a collision or a grounding, and the collision distance |

## The window

- **Status line:** sim clock, sim speed (requested and achieved), range, rings, orientation, true or relative motion, trails, TRIAL while a trial maneuver is on, and the text of a collision or grounding.
- **Wheelhouse view:** the WHEELHOUSE button opens a second window with the view from the bridge: sea, land and sky, flat-lit simplified ships, own ship's bow with container stacks, a choice of foredeck (container ship, tanker, bulk carrier), a sea that follows the wind. TIME OF DAY, VISIBILITY and VIS VARIABILITY are in SETUP under ENVIRONMENT; at night ships show COLREGS navigation lights (fishing vessels, tugs and tows, sailing vessels with their own), lights are seen farther as you zoom in, and fishing vessels show their day shapes in a narrow view. The window is a normal window (not always on top). It shows bearings only (scale along the top, gyro bearing of the centre line, crosshair at 30 deg or less), never range or aspect. Left/Right look round (Shift 1 deg, Ctrl 30 deg), wheel or Up/Down zoom 180 to 4 deg, Home ahead, End astern, drag with the mouse. About 5 frames a second.
- **Buttons:** WHEELHOUSE, PAUSE, RESTART SIM, CHART (writes the chart file again, with own ship and its track so far, and opens it in the browser), SETUP (new run, environment, traffic with a TRAFFIC NOW button that adds or removes contacts at once to match DENSITY, a MIX OF VESSELS (weights for merchant ships, tugs, fishing vessels and pleasure craft), MISBEHAVING SHIPS (percentage and a switch for each mistake: no give way, late, crossing ahead of own ship), interface colours, control style and dark mode, instructor overlay), HELP.
- **PPI:** the radar picture. Left click selects a target or grabs an EBL or VRM; ACQUIRE then clicks put an acquire box at each click, until you press the button again or 8 s pass without a click; with no echo under it the box looks every revolution and is lost after a few.
- **Right column:** alarms (ACK) and the radar and ARPA controls: receiver (gain, STC, FTC), display (range, orientation, motion, stabilisation, trails, brilliance, afterglow, OFFSET then a click, CENTRE), EBL and VRM knobs or sliders, and the ARPA controls (vectors, history, limits, two guard zones, trial maneuver; with a trial on, relative vectors show the trial). **Left column:** the alarms, the CONTACTS list (every acquired target with range, bearing, CPA, TCPA and state; click a line to select it; targets inside the CPA and TCPA limits are red); and own ship in a box of its own: readouts, COURSE, HELM and SPEED order boxes, engine telegraph and the log. With an offset the bearing scale is read from own ship. The selected target's data is printed on the PPI, top left; own ship's heading (gyro) and speed (log), with ground speed and course, are printed large at the top right, in the black beside the circle. The own-ship order log and the message pane are kept small (about three lines); every order-log line starts with the sim time (HH:MM:SS), like a voyage data recorder. PI 1 and PI 2 (parallel index, under EBL / VRM) each draw a dashed line at a set direction (read like the EBLs, deg T or deg R) and a set distance from own ship (+ right of the line's direction, - left), for passing a mark at a chosen distance, or a pair for both edges of a channel. Knobs sit side by side in rows (gain, STC and FTC; the display knobs; the EBLs and VRMs); a bearing knob (EBL, PI direction, trial course, wind and current direction) turns round and round with no stops. The control style (knob, slider or hybrid: levels and bearings knobs, distances sliders), colour mode and dark mode (dark gray controls and background) are in SETUP, under INTERFACE. The trial course, speed and delay are knobs or sliders; the delay is in minutes (0.1 MIN is 6 s).
- **Message pane:** the sim's console output and the display's own messages, with the tags of `messages.py`.

Press F1 in the display for the help window. Every number in the display shows its unit.

## Hotkeys

| Keys | Action |
| --- | --- |
| PageUp, PageDown | range scale up, down |
| G, Shift+G | gain up, down (5 % steps) |
| S, Shift+S | STC up, down |
| F, Shift+F | FTC up, down |
| O | cycle orientation |
| M | relative or true motion |
| C | cycle colour mode |
| V | true or relative vectors |
| [ and ] | vector time shorter, longer |
| T | cycle trails: off, true, relative |
| 1, 2, 3, 4 | toggle and select EBL 1, EBL 2, VRM 1, VRM 2 |
| Left, Right | adjust the selected EBL by 1° (Shift 0.1°, Ctrl 10°) |
| Up, Down | adjust the selected VRM by 1 % of the range scale (Shift 0.1 %, Ctrl 10 %) |
| A | put an acquire box at the cursor |
| Delete, Ctrl+Delete | cancel the selected target, cancel all |
| Space | acknowledge alarms |
| H (held) | heading line off |
| P | pause |
| F5, F6 | sim speed down, up (1, 2, 3, 5, 10) |
| Enter, Esc | focus the course box, leave it |
| Ctrl+O, Ctrl+Shift+O | offset to the cursor, centre |
| Ctrl+Shift+T | instructor overlay on or off |
| F1 | help |

## Collision and grounding

With `[game] on_collision` or `on_grounding` set to `stop`, the sim pauses when own ship collides with a contact or runs aground; the text appears in the status line and the message pane, and P resumes. With `ignore` the sim carries on and only the message appears. An event is not repeated until the contact has moved apart, or own ship has been afloat again.

## Known limits

- Gen 1 only: land is generated from a seed, not read from a chart.
- The ARPA tracks from the radar video, so it has the limits of the video: echoes that merge are tracked as one, and a target can swap with a close neighbour (`target_swap_enabled` does not yet prevent that in near-parallel overtaking).
- The sim reports the guard-zone and trial values only as start values, so after RESTART SIM the panel shows the start values.
- Windows only for the display; the sim runs anywhere Python and numpy do.
- The speed the sim can sustain depends on the PC; the status line shows the achieved speed.

## Later generations

All knowledge of how land is made is in `sim/sim_land.py`, behind `LandModel`; the radar, traffic and game code use only `height_m_at`, `is_land`, `lanes` and `find_start`.

- **Practice chart (proof of concept, done):** at the start of every run the sim writes `chart_<seed>.svg` in the project folder, named for the scenario's seed so a saved chart is not overwritten by another scenario's (`general.write_chart`, `general.chart_file`): the run's own land, lanes, depths, spot heights, compass rose and own ship's start, in the style of a paper chart. Open it in a browser (it zooms and prints); the border shows 1 minute of latitude = 1 nm. Depths are made up from the distance to shore, since the land raster has none; the lateral buoys (red and green on every lane, with their light codes such as "Fl(2) G 6s") and the calibration scenario's buoys are shown (`sim/sim_chart.py`). The buoys also appear on the radar, in the wheelhouse view (flashing their rhythm at night) and can be hit; `lane_marks = false` in `[traffic]` turns them off and `buoyage_region = "A"` or `"B"` sets the IALA region (default B, red to starboard going toward the harbour).
- **Gen 2 (a nautical chart):** will trace coastlines from the same raster and draw a chart window with own ship, lanes and symbols. World coordinates and own-ship position already travel in the protocol, so a second window needs no change to the sim.
- **Gen 3A (land from PDF charts):** will turn chart PDFs into the same raster, with lanes entered by hand and two or more control points per PDF (pixel to latitude and longitude). `latlon_to_xy_nm` and `xy_nm_to_latlon` in `sim_common.py` are ready for it.
- The display never loads land or chart files itself; it gets world data only through the protocol.

## Files

`radarsim.toml`, `BRIEF.md` (the specification and the status log), `sim/` (Python, one flat folder; `messages.py` is the console message library), `gui/` (one .NET project, files side by side).
