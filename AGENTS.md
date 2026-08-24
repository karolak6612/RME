# AGENTS.md

## Build — Windows (vcpkg)

- Requires: VS 2022+ with **Desktop development with C++**, CMake 3.28+, `VCPKG_ROOT` set (e.g. `C:\vcpkg` cloned from `microsoft/vcpkg` baseline `1940ee77e81573713c0d364c42f5990172198be1`).
- Quick build: `build_windows.bat` → `build\Release\rme.exe`, solution `build\rme.sln`, log `build.log`.
- Fast Ninja (also emits `compile_commands.json`): `build_ninja.bat` → `build-ninja\rme.exe` + `compile_commands.json` at repo root. Requires `ninja` on PATH.
- Persistent IDE workspace: `vcproj\generate_vcproj.bat` → `vcproj\rme.sln` (gitignored; `build\` is also gitignored via `/build*`). Do not commit either.
- CMake presets (`CMakePresets.json`): `ninja-vcpkg` (→ `build-ninja`), `vs2022-vcpkg` (→ `build-vs2022`), `vs2026-vcpkg` (→ `build-vs2026`). Use `cmake --preset ninja-vcpkg` / `cmake --build --preset ninja-release`.

All Windows scripts verify `VCPKG_ROOT`, CMake version, VS toolchain, and that the required vcpkg baseline commit is an ancestor of `VCPKG_ROOT` HEAD — run `git -C "%VCPKG_ROOT%" pull` if stale. They also run `vcpkg integrate install`; failure warns — retry as Admin.

## Build — Linux (Conan + apt)

- Setup (hybrid — most deps via `apt`, only `glad`, `tomlplusplus` via Conan): `./setup_conan.sh` → log `build_conan/setup_conan.log`.
- Fast debug (Jules/AI optimized, Clang + Mold + Ninja + ccache): `./build_clang.sh` → `build_clang/build/Debug/rme` (flags `-O0 -g0`, `-fuse-ld=mold`, `-j2` to avoid OOM, log `build_clang/build_clang.log`).
- Standard release: `./linux_build.sh` → `linux_build/build/Release/rme` (log `linux_build/build_linux.log`).
- CI (`source: .github/workflows/build.yml`): Ubuntu 24.04, `run-vcpkg@v11` at same baseline, Ninja Release, triplet `x64-linux`, ccache 500M, artifacts `build/rme`.
- Linux tools install `clang`, `mold`, `lld`, `ccache`, `libwxgtk3.2-dev`, `libboost-all-dev`, etc. — `build_clang.sh` will `apt remove libstdc++-13/14-dev` to force `libstdc++-12-dev`.

## Project Structure

- Single CMake target `rme` (`CMakeLists.txt:6` `CMAKE_CXX_STANDARD 23`, `CMakeLists.txt:81` `add_executable(rme ...)`). Source list lives in `source/CMakeLists.txt` (`rme_H`/`rme_SRC`). Generated protobuf (`source/protobuf/appearances.proto`) compiles via `protobuf_generate_cpp`.
- Top-level dirs: `source/` (all code), `data/<version>/` + `source/clients.toml` (client version registry), `source/assets/` (icons/png/svg copied post-build to `<bindir>/assets`), `ext/nanovg/` (fallback if `find_package(nanovg)` misses), `scripts/` (Lua examples), `lua_tests/` (in-editor tests), `extensions/`, `brushes/`, `icons/`, `vcproj/` (generated).
- Key modules under `source/`: `app/` (entry `main.h`/`application`), `brushes/` (+ `ground/`/`wall/`/`carpet/`/`table/`/`doodad/` etc.), `rendering/` (GL 4.6 core, NanoVG GL3, sprite batching — `core/`, `drawers/`, `ui/`, `postprocess/`), `palette/`, `ui/` (+ `toolbar/`, `managers/`, `welcome/`, `replace_tool/`), `map/`, `game/`, `io/otbm/`, `item_definitions/{core,formats/{dat,otb,protobuf,xml}}`, `editor/`, `ingame_preview/`, `live/`, `net/`, `lua/` (sol2).
- Runtime copies at post-build (`CMakeLists.txt:88`): `source/assets` → `<bindir>/assets`, `data` → `<bindir>/data`. Missing assets/data → crash on startup — always build via scripts/presets, not raw `g++`.

## Dependencies

- `vcpkg.json` is truth for Windows; `conanfile.py` for Linux. Do not add a dep to one without the other (Linux conan profile omits most libs intentionally — they come from `apt`).
- Stack: wxWidgets 3.3 (`html aui gl adv core net base propgrid`), glad (GL 4.6 core), glm, protobuf, liblzma, zlib, boost thread/system, asio, nanovg, spdlog, tomlplusplus, lua + sol2, cpr, libwebp, nlohmann-json, libarchive, fmt.

## Style & Lint

- `.editorconfig`: `utf-8`, `lf`, `insert_final_newline`, `trim_trailing_whitespace`, tabs for `*.{cpp,h,lua,xml}` (size 4, K&R braces).
- `.clang-format` (C++20, 140 col): `UseTab: Never`, `IndentWidth: 4`, `BraceWrapping.AfterFunction: true`, includes sorted `source/*` → `wx/*` → `<*>` → rest. Run `clang-format --style=file -i source/**/*.cpp source/**/*.h` if unsure.
- `.clang-tidy`: clang 18. Checks `clang-diagnostic-* clang-analyzer-* bugprone-* concurrency-* modernize-* performance-* portability-* readability-*` with project overrides (`source: .clang-tidy`, `.clang-format`). Naming: `lower_case m_` for members, `camelBack` for functions.
- CI (`source: .github/workflows/clang-format.yml`): on PRs touching `source/**`, auto-runs `DoozyX/clang-format-lint-action@v0.17` (`clangFormatVersion: 18`, `inplace: true`) and auto-commits fixes, then `clang-tidy-18` on changed files only (full scan on `master`). Do not fight the bot — format before pushing.

## Tests & Verification

- No CTest/GoogleTest. Verification is **build + manual run** plus in-editor Lua suite.
- Lua tests (`source: lua_tests/README_TESTS.md`): ~18 files, ~250 cases covering `Position`, `Selection`, `Color`, `json`, `http`, `noise`, `algo`, `geo`, `Dialog`, `Items`, etc. Run **inside** running RME: `Scripts → Run Script` → `lua_tests/run_all_tests_complete.lua` (or `run_all_tests.lua` / `run_all_tests_bulk.lua` / individual `test_*.lua`). Framework is `lua_tests/framework.lua` (`framework.test`/`assert`/`summary`). Tests requiring a map fail with "No map open" — open any map first. HTTP tests use invalid URLs intentionally.
- C++ smoke test: after build, launch `rme.exe`/`rme` and open a map from `data/`. There is no single-test CLI.

## Gotchas

- `CMAKE_BUILD_TYPE` defaults to `RelWithDebInfo` if unset (`CMakeLists.txt:9`); MSVC adds `/W3 /wd4996 /wd4800 /wd4100 /wd4706 /EHsc`.
- Binary is console subsystem (`CMakeLists.txt:80` `WIN32` removed) — stdout/stderr are visible; check `build.log`/`build_clang.log` for silent failures.
- `compile_commands.json` is gitignored; `build_ninja.bat` copies it to root for clangd/clang-tidy. Delete `build*/` to clear stale CMake cache if config fails.
- `data/clients.toml` + `data/<id>/` per-version dirs drive `app/managers/version_manager` — do not rename. 12.86 is default (`default = true`).
- Leaf test files `source/test_autoborder_preview.cpp` and `source/test_image_loading.cpp` are standalone — not in `source/CMakeLists.txt` target.
