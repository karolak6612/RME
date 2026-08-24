# Remere's Map Editor: Redux

<div align="center">

<img src="docs/readme/divider.svg" width="1200" alt="divider">

<p>
  <a href="https://github.com/Open-Tibia-Tools/remeres-map-editor-redux/releases"><img src="https://img.shields.io/badge/version-4.1.2-7B61FF?style=flat-square&amp;labelColor=131A2B" alt="version"/></a>
  <a href="https://github.com/Open-Tibia-Tools/remeres-map-editor-redux/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/Open-Tibia-Tools/remeres-map-editor-redux/build.yml?label=build&amp;color=00D4FF&amp;style=flat-square&amp;labelColor=131A2B" alt="build"/></a>
  <img src="https://img.shields.io/badge/C++-23-00599C?style=flat-square&amp;labelColor=131A2B" alt="C++23"/>
  <img src="https://img.shields.io/badge/OpenGL-4.6_core-5586A4?style=flat-square&amp;labelColor=131A2B" alt="OpenGL"/>
  <img src="https://img.shields.io/badge/wxWidgets-3.3-E4002B?style=flat-square&amp;labelColor=131A2B" alt="wxWidgets"/>
  <img src="https://img.shields.io/badge/license-GPL--3.0-9B59B6?style=flat-square&amp;labelColor=131A2B" alt="license"/>
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux-2ECC71?style=flat-square&amp;labelColor=131A2B" alt="platform"/>
</p>

<p>
  <a href="https://suppi.pl/karolak6612" style="text-decoration: none; border: none;"><img src="https://github.com/user-attachments/assets/39c46c55-bcdb-42d0-9f2a-b23bb05b4019" alt="Suppi" width="160" height="90" style="display: inline-block; vertical-align: middle;"></a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="https://revolut.me/karolak6612" style="text-decoration: none; border: none;"><img width="160" height="90" alt="obraz" src="https://github.com/user-attachments/assets/6f2c7220-9108-4274-817d-fbabeb5cdcc3" /></a>
</p>

</div>

> **Redux** takes the battle-tested RME workflow and rebuilds the backend: decoupled single-responsibility modules, a `C++23` / `OpenGL 4.6` core renderer, and a Lua/sol2 scripting surface — without breaking OTBM compatibility (`otbmVersions 1–4`, 36 client packs from `7.4` to `13.20`).

---

## What's New

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

| Area | Before → After (verified in repo) |
|---|---|
| **Structure** | Monolith → ~770 files in `source/{app,brushes,rendering,palette,ui,map,game,io,lua,editor,…}` single target `rme` (`source/CMakeLists.txt`, `CMakeLists.txt:81`) |
| **Rendering** | `GL 1.x` fixed-function → **GL 4.6 core** (`glad 4.6`, `#version 450 core` in `sprite_batch.cpp:9`, `primitive_renderer.cpp:8`, MDI `GL 4.3+`, ring buffer `GL 4.4/4.5` in `ring_buffer.cpp:66`) |
| **GUI layer** | wxDC only → **NanoVG** overlay passes + wxWidgets `3.3` (`vcpkg.json`, `CMakeLists.txt:42` `find_package(wxWidgets 3.3 ...)`) |
| **Map renderer** | Immediate draw → **async sprite loading** (`sprite_preloader.cpp`), **sprite batching** (`sprite_batch.cpp`), **ring buffers** (`ring_buffer.h:20`), **texture atlas/array** (`texture_atlas.cpp`, `texture_array.cpp`), **multi-draw indirect** (`multi_draw_indirect_renderer.h:11`) |
| **Light** | CPU loop → **GPU light buffer** (`light_buffer.h/.cpp`, `sprite_light.h`, `light_calculator.cpp`, `light_drawer.cpp`) |
| **Language** | Legacy C++ → **C++23** (`CMakeLists.txt:6` `CMAKE_CXX_STANDARD 23`, MSVC `/W3 /EHsc`, GCC/Clang `-Wall -Wextra`) |

<div align="center">
  <img src="docs/readme/divider.svg" width="1200" alt="divider"/>
</div>

## Features

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

<table>
<tr>
<td width="50%">

**Editor**
- **NanoVG tooltip** system
- **Autoborder preview** (`brushes/managers/autoborder_preview_manager.*`)
- **Doodad preview** (`doodad_preview_manager.*`)
- **Tool options surface** — brush size X/Y, exact/aspect lock, thickness, spawn, door-lock (`ui/tool_options_surface.cpp` — fully functional, not "broken")

</td>
<td width="50%">

**Preview & Shaders**
- **In-game preview** with floor visibility + walking sim (`ingame_preview/*` — `ingame_preview_manager.h`, `floor_visibility_calculator.cpp`)
- **Post-process** stack: `screen` · `scanline` (Retro-CRT) · `xbrz` (`rendering/postprocess/effects/{screen,scanline,xbrz}.cpp`)
- **SVG** via `wxBitmapBundle::FromSVGFile` + tinting (`util/image_manager.cpp:66`, `svg/solid/*.svg`)

</td>
</tr>
<tr>
<td>

**Replacement**
- **Replace Tool** with visual-similarity engine (`ui/replace_tool/*` — `visual_similarity_service.cpp`, `replacement_engine.cpp`, `rule_manager.cpp`, `ALGORITHM_DOCS.md`)

</td>
<td>

**Scripting & Assets**
- **Lua (sol2)** API: `Map`, `Tile`, `Item`, `Position`, `Selection`, `Brush`, `Color`, `json`, `http`, `noise`, `algo`, `geo`, `Dialog` + `procedural` helpers
- **Client packs** `data/<version>/` driven by `source/clients.toml` (36 packs, default `12.86` `default = true`)

</td>
</tr>
</table>

> Precisely: `protobuf` appearances (`source/protobuf/appearances.proto` via `protobuf_generate_cpp`) and `dat`/`otb`/`xml` parsers (`item_definitions/formats/*`) are already in-tree — `Native assets/Protobuf loading` is **not** future-only.

## Performance

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

- **Batch everything**: sprite instances are collected in `SpriteBatch` and flushed via **MDI** (`glMultiDrawElementsIndirect`) — one dispatch per frame per layer.
- **Stream textures**: `PixelBufferObject` + `TextureArray` + `TextureAtlas` with `glCopyImageSubData` (`GL 4.3+`) and garbage collection.
- **Zero stalls**: persistent-mapped **ring buffer** (`glNamedBufferStorage`, `GL 4.5`) decouples CPU/GPU.
- **Async**: `SpritePreloader` + `AtlasManager` load off the main thread.
- **Measure it**: toggle `SHOW_FPS_COUNTER` (`app/settings.cpp:396`) and watch `render_timer.cpp` / `frame_pacer.cpp` / `fps_counter.cpp`. Previous `160+ FPS` claim depends on hardware/map — the engine is *capable*, not guaranteed.

## Clients

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

| Range | Example `dataDirectory` | `otbmVersions` | Notes |
|---|---|---|---|
| `7.4 – 7.92` | `740`, `760`, `780`… | `1` | `Tibia.dat/.spr`, pre-transparency |
| `8.00 – 8.60` | `800`, `860` | `2`→`3` | extended switches at `860` |
| `9.x` | `900`–`986` | `3` | extended, variable signatures |
| `10.x` | `1010`–`1098` | `3` | transparency, frameGroups at `1077`+ |
| `12.71 – 13.20` | `1271`–`1320` | `3` | current era, `1286` is `default` |

All 36 packs live in `data/` (`.gitignore` ships them, runtime copies `data` → `<bindir>/data` post-build in `CMakeLists.txt:88`). Same for `source/assets` → `<bindir>/assets`. Missing assets/data → crash at startup — always build through the scripts below.

## Build

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

**Windows** — needs VS `2022+` (Desktop C++), CMake `3.28+`, `VCPKG_ROOT` at baseline `1940ee77e81573713c0d364c42f5990172198be1`:

```bat
:: quick MSBuild solution + exe
build_windows.bat          :: -> build\Release\rme.exe  +  build\rme.sln  (log build.log)

:: fast Ninja + compile_commands.json at repo root
build_ninja.bat            :: -> build-ninja\rme.exe    (needs ninja on PATH)

:: persistent VS workspace (gitignored)
vcproj\generate_vcproj.bat :: -> vcproj\rme.sln
```

CMake presets: `ninja-vcpkg` (`build-ninja`), `vs2022-vcpkg` (`build-vs2022`), `vs2026-vcpkg` (`build-vs2026`)
→ `cmake --preset ninja-vcpkg` / `cmake --build --preset ninja-release`.

> All Windows scripts verify `VCPKG_ROOT`, CMake version, toolchain, and that the required baseline is an ancestor of `HEAD` — if stale: `git -C "%VCPKG_ROOT%" pull`. `vcpkg integrate install` failure → retry as Admin.

**Linux** — hybrid `apt` + `Conan` (only `glad`, `tomlplusplus` come from Conan, rest from `apt`):

```bash
./setup_conan.sh   # apt deps + conan profile  (log build_conan/setup_conan.log)
./build_clang.sh   # Clang + Mold + Ninja + ccache, Debug -O0 -g0 -j2  -> build_clang/build/Debug/rme
./linux_build.sh   # Ninja Release                                -> linux_build/build/Release/rme
```

CI: Ubuntu `24.04`, `run-vcpkg@v11` at same baseline, `x64-linux`, Ninja Release, `ccache 500M` (`.github/workflows/build.yml`).

Full deps: `vcpkg.json` (Windows truth) + `conanfile.py` (Linux truth) — keep in sync. Stack: wxWidgets 3.3, glad 4.6, glm, protobuf, liblzma, zlib, boost thread/system, asio, nanovg (`ext/nanovg` fallback), spdlog, tomlplusplus, lua+sol2, cpr, libwebp, nlohmann-json, libarchive, fmt.

## Architecture

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

```
source/
  app/            application, client_version, version_manager, updater, settings, preferences/*
  brushes/        ground/ wall/ carpet/ table/ doodad/ door/ flag/ creature/ house/ spawn/ waypoint/ + ground/auto_border.*
  rendering/      core/ (graphics, atlas_manager, sprite_batch, ring_buffer, light_buffer, …)
                  drawers/{cursors,entities,tiles,overlays}  ui/  postprocess/effects/{screen,scanline,xbrz}
                  io/ (editor_sprite_loader, screen_capture)
  palette/        palette_window, hardcoded_palette_registry, house/, controls/virtual_brush_grid
  ui/             main_frame, map_window/tab, toolbar/*, managers/*, welcome/*, replace_tool/*, properties/*
  map/            map, tile, position, map_region, operations/map_processor, map_search
  game/           item, creatures, house, town, spawn, materials, waypoints
  item_definitions/  core/{item_definition_store, asset_bundle_loader, …}
                     formats/{dat,otb,protobuf,xml}
  editor/         editor, action*, selection*, operations/{draw,copy,map_version_changer}
  io/otbm/        header/tile/item/town/waypoint serialization
  ingame_preview/ preview renderer/canvas/manager + floor_visibility_calculator
  live/ net/ lua/ util/
  protobuf/appearances.proto  (generated via protobuf_generate_cpp)
```

- Single target `rme` (`CMakeLists.txt:6` `CXX_STANDARD 23`, `add_executable(rme ${rme_H} ${rme_SRC})`).
- `source/CMakeLists.txt` owns the full file list — edit there, not in `CMakeLists.txt`.
- Runtime copies `source/assets` + `data` next to the exe post-build.

## Scripting

<div align="center">
  <img src="docs/readme/divider.svg" width="520" alt="divider"/>
</div>

- No `CTest` / `ctest`. Verification = **build + run** + in-editor Lua suite.
- Lua tests: `lua_tests/` (~18 files, ~250 cases). Run **inside** the running editor:
  `Scripts → Run Script` → `lua_tests/run_all_tests_complete.lua` (or `run_all_tests.lua` / `run_all_tests_bulk.lua` / single `test_*.lua`). Framework is `lua_tests/framework.lua`.
  - Map-dependent tests need an open map (`No map open` otherwise).
  - HTTP tests intentionally hit invalid URLs.
  - Smoke: open any `data/<version>/` map after build.
- Standalone cpp leaves `source/test_autoborder_preview.cpp` and `source/test_image_loading.cpp` are **not** in the build target.

<div align="center">
  <img src="docs/readme/divider.svg" width="1200" alt="divider"/>
</div>

## Media

| | |
|---|---|
| **Autoborder preview** | https://imgur.com/7bQrM09 |
| **UI preview** | https://imgur.com/qeaMwws |
| **Performance vs RME OTA** | https://imgur.com/Y3zecwk |
| **Player walking (in-game preview)** | https://imgur.com/5ZPcuxa |

<p align="center">
  <img width="2553" alt="screenshot 1" src="https://github.com/user-attachments/assets/ee37c4f8-4997-4358-965d-f462dac4b603" />
  <img width="1485" alt="screenshot 2" src="https://github.com/user-attachments/assets/4e6e8aa9-6353-4a87-9175-ba3e8dc5fbb4" />
  <img width="1798" alt="screenshot 3" src="https://github.com/user-attachments/assets/4118bff9-6873-450a-8ba9-627c065bf40e" />
  <img width="1114" alt="screenshot 4" src="https://github.com/user-attachments/assets/7d61d223-7d74-4660-8a06-cbc1b57f36f3" />
</p>

<div align="center">
  <img src="docs/readme/divider.svg" width="1200" alt="divider"/>
  <p><sub>Docs: <a href="BUILDING.md">BUILDING.md</a> · <a href="AGENTS.md">AGENTS.md</a> · <a href="lua_tests/README_TESTS.md">Lua tests</a> · <a href="scripts/README.md">Scripting guide</a></sub></p>
</div>
