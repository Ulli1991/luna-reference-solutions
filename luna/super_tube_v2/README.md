# Super-hard 1D tube v2: LUNA's runs

LUNA's runs of luna-cpp's super-hard 1D tube v2 (`research_notes/super_tube_v2_2026-11-18.md`, problems `super-tube-v2` and
`super-v2-<stage>` of `src/hydro/problems_1d.hpp` and `scripts/problems_1d.py`, branch super-tube-v2 df7f5ca). **Regression only,
not an external reference and not a truth.** At t = 0.1 the stages M, A to G, L, N and V have an exact solution
(`problems_1d.super2_exact`); SO, S, H and everything at t = 4 have none.

## Definition

gamma = 1.4 on [0, 40.25], left wall open (zero gradient), right wall reflecting. Fifteen stages separated by quiet buffers of
(rho, v, P) = (1, 0, 1): v1's ten (A quiet, B sound and entropy waves, C and C2 density peaks, D Toro 1, E a 1e9 pressure jump, F the
LA-14379 slow shock, S Toro 5, G Toro 2, H Woodward-Colella against the right wall) and five more: M cold gas (P = 1e-6) at Mach 1e4
(v = -11.83) with a density bump, leaving through the open wall; L density ratio 1e6 and pressure ratio 1e12; SO Shu-Osher (a Mach 3
shock into 3 wavelengths of rho = 1 + 0.2 sin 5x); N Noh's cold colliding streams (v = +-1, P = 1e-6); V a true vacuum ((1, -4, 0.4)
next to (1, 4, 0.4)). Positions and states: `scripts/super_tube_layout.py v2` and `super_tube_v2_segments` of `problems_1d.hpp`. The
initial state is the exact cell average.

## Runs

LUNA 60cf841 (main; uncommitted: `docs/history/CODE_NOTES.md` only), jax 0.10.1, MUSCL-Hancock, HLLC, MC (`LIMITER=1`), CFL 0.8,
FP64, driven by luna-cpp `scripts/luna_1d_run.py`.

- `super_tube_v2_luna_1048576_t{0.1,4}.npz`: 2^20 cells, Pallas kernel, one A100 (SLURM 32521644, 5828783 steps to t = 4 in
  3750 s). LUNA's one `BOUNDARY` cannot hold an open left and a reflecting right wall: the run is on [0, 80.5], 2^21 cells, the right
  half the mirror image (rho, -v, P), both ends open; the left half is kept. Largest difference between the halves: 0.045 (t = 0.1)
  and 1.04 (t = 4) in the conserved variables; per stage at most 2 % of rho in a cell, L1(rho) at most 1e-3. Stored as conservative
  averages on 2^17 cells (`n_run`, `n_coarse`).
- `super_tube_v2_luna_{4096,32768}_t0.1.npz`: CPU, XLA kernel, one thread. LUNA at 4096, 32768 and 2^19 does not reach t = 4: the
  pressure turns negative in stage N, where the ambient gas drives a shock into the cold stream (x = 25.40 at t = 0.323 for 4096,
  x = 25.37 at t = 0.326 for 32768), and the run goes NaN; no state is stored for those.
- `super_v2_<stage>_luna_<cells>_t0.1.npz`: the new stages alone (M, L, SO, N, V) on their windows, open walls, at the spacing of the
  tube at N = 4096, 8 and 64 times as many cells; CPU, one thread.

Keys: `rho`, `u`, `p`, plus problem, series, t, steps, wall time, reached, commit, scheme, mirror, backend.
