# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

"Earth Intruders" — a Space Invaders clone written in ZX Spectrum BASIC, by Dale & Primus (SynthSpec Project). The source lives in `basic-code/Intruders.txt` and must be compiled to a `.tap` tape image to run in the bundled FUSE emulator.

## Build & Run Workflow

**Step 1 — Convert BASIC source to TAP:**
```powershell
.\tools\bas2tap-win\bas2tap.exe -sIntruders -a10 basic-code\Intruders.txt basic-code\Intruders.tap
```
- `-n Intruders` sets the program name embedded in the TAP header (max 10 chars)
- Output `.tap` goes wherever you specify as the last argument

**Step 2 — Load in FUSE emulator:**
```powershell
.\tools\fuse\fuse.exe
```
Then in FUSE: `File > Open` → select `basic-code\Intruders.tap`. The program will auto-run from tape.

## Code Architecture

The BASIC source (`basic-code\Intruders.txt`) is structured by line-number ranges:

| Lines | Purpose |
|-------|---------|
| 10–30 | REM headers (title, project, authors) |
| 100–220 | UDG setup — 7 UDGs (A–G): two frames each for the three alien types plus cannon; loaded via READ/POKE loops |
| 300–365 | Variable initialisation — `px`/`py` (player pos), `bx`/`by`/`ba` (bullet), `sc`/`ls` (score/last-score), `alive` (live alien count), `gx`/`gd`/`gy` (grid x, direction, y-offset), `mc`/`mr` (move counter/rate), `af` (animation frame 0/1), `dw` (draw-dirty flag) |
| 400–460 | Initialise `a(3,8)` alive-array (3 rows × 8 columns of invaders) |
| 500 | Main game loop entry point |
| 600–697 | Invader movement — throttled by `mc`/`mr`; on each move toggles `af`, sets `dw=1`, clears old positions (dead aliens skipped), then steps and wraps grid |
| 700–780 | Draw invaders — skipped entirely when `dw=0` (no movement this cycle); sprite selected by `CHR$ (144+(r-1)*2+af)` |
| 800–815 | Score display — only reprinted when `sc` differs from `ls` |
| 900–930 | Keyboard input — keys 5 (left), 8 (right), SPACE (fire) |
| 1000–1050 | Bullet update — moves up one row per loop iteration |
| 1100–1160 | Collision detection — bullet vs alive-array; on hit decrements `alive` counter directly |
| 1200–1210 | Draw player cannon (`CHR$ 150` = UDG G) |
| 1300–1390 | Win check (uses `alive` counter, no loop) + dynamic speed |
| 1400–1410 | Lose check — invaders reach player row |
| 1500 | `GO TO 500` (loop back) |
| 2000–2040 | Win screen |
| 3000–3040 | Game-over screen |

## UDG Sprite Data

UDGs are 8-byte bitmaps POKEd into memory at `USR "A"` onwards. Each alien type has two animation frames; the cannon is a single static sprite.

| UDG | Char | Role |
|-----|------|------|
| A | `CHR$ 144` | Small alien, frame 1 |
| B | `CHR$ 145` | Small alien, frame 2 |
| C | `CHR$ 146` | Crab alien, frame 1 |
| D | `CHR$ 147` | Crab alien, frame 2 |
| E | `CHR$ 148` | Squid alien, frame 1 |
| F | `CHR$ 149` | Squid alien, frame 2 |
| G | `CHR$ 150` | Player cannon |

The formula `CHR$ (144 + (r-1)*2 + af)` selects the correct sprite for row `r` (1–3) and animation frame `af` (0 or 1). `af` toggles each time the invader grid moves.

## Iteration History

Previous iterations are preserved in `tools\bas2tap-win\`:
- `Invaders1` — static grid, ASCII sprites (`^`/`O`)
- `Invaders2` / `Invaders2b` — intermediate steps
- `Invaders3` — same as current `Intruders.txt` (UDG sprites, moving grid, game-over condition)

## ZX Spectrum BASIC Notes

- Screen is 32 columns × 22 rows (`PRINT AT row,col`). Row 0 = score bar; rows 1–21 = play area; row 21 = player row.
- `INKEY$` is polled (non-blocking) each loop iteration.
- `BORDER`/`PAPER`/`INK` accept colour codes 0–7 (0=black, 2=red, 5=cyan, 6=yellow, 7=white).
- Only one bullet can be active at a time (`ba` flag).
- `bas2tap` requires line numbers in ascending order; each logical line ends at the newline.
