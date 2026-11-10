# Super-hard 1D tube: LUNA's high-resolution runs

LUNA's runs of the super-hard 1D tube of luna-cpp (`research_notes/super_tube_2026-11-10.md`, problem `super-tube` of
`src/hydro/problems_1d.hpp` and `scripts/problems_1d.py`), at t = 0.1 and t = 2. **Regression only, not an external reference
and not a truth.** At t = 0.1 stages A to G have an exact solution (`problems_1d.super_exact`); S, H and everything at t = 2 have
none, and an independent code's run does not exist here yet.

## Definition

gamma = 1.4 on [0, 33.2], left wall open (zero gradient), right wall reflecting. Ten stages separated by quiet buffers of
(rho, v, P) = (1, 0, 1): A quiet, B a sound wave and an entropy wave (amplitude 1e-4, wavelength 0.25, linear in the conserved
state), C a stationary density peak, C2 a moving one, D Toro 1 with a sonic rarefaction, E a 1e9 pressure jump, F the LA-14379
slow shock, S Toro 5, G Toro 2 (near vacuum), H Woodward-Colella against the right wall. Positions and states: the tables
`SUPER_SEGMENTS` of `scripts/problems_1d.py` and `super_tube_segments` of `problems_1d.hpp`. The initial state is the exact
cell average.

## Runs

LUNA 60cf841 (main; uncommitted: `docs/history/CODE_NOTES.md` only), MUSCL-Hancock, HLLC, MC (`LIMITER=1`), CFL 0.8, FP64, the
Pallas kernel, one A100, 2^20 cells, driven by luna-cpp `scripts/luna_1d_run.py` (luna-cpp eb972bd). LUNA's one `BOUNDARY`
cannot hold an open left and a reflecting right wall: the run is on [0, 66.4], 2^21 cells, the right half the mirror image
(rho, -v, P), both ends open, and the left half is kept. The halves differ by rounding that grows at the strong shocks: max
|U_left - mirror(U_right)| = 0.021 at t = 0.1 and 0.10 at t = 2 (on the CPU's XLA kernel, 4e-12 to 6e-11 at 4096 and 32768
cells), so mass and energy of the kept half drift by -1.1e-8 and -2.3e-6 (of 37.6 and 1128) by t = 2.

Stored: conservative averages of the 2^20 cells on 2^17 cells (`n_run`, `n_coarse`), primitives `rho`, `u`, `p`; keys give
code, commit, branch, scheme, mirror, backend, steps and wall time.
