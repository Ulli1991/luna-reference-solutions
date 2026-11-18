# Super-hard 1D tube: GIZMO MFM and MFV

GIZMO runs of luna-cpp's super-hard 1D tube (luna-cpp `research_notes/super_tube_2026-11-10.md`, problem `super-tube` of
`scripts/problems_1d.py`), for the comparison with luna-cpp, LUNA and Arepo (`arepo/super_tube/README.md` has the comparison, the
settings that match and those that cannot). An independent code's run, not a truth.

## Code

GIZMO (P. F. Hopkins; GPL-3.0), github.com/pfhopkins/gizmo, default branch `gizmo-cpp` at
519be7dccb18d6b5783a03d9ef8f7a5d0c4a0b1c (2026-10-04). One compile-only change: at this commit
`apply_special_boundary_conditions()` (`core/kicks.cc`) touches the cosmic-ray flux without a guard, so no build with
`BOX_REFLECT_X` compiles without cosmic rays; the two lines are put under `#ifdef COSMIC_RAY_FLUID`, as the 2023 code had them.
Built with gcc 14, OpenMPI 4, `-O2 -march=icelake-server`; run on Raven CPUs (Xeon Platinum 8360Y), FP64.

Config: `HYDRO_MESHLESS_FINITE_MASS` (MFM) or `HYDRO_MESHLESS_FINITE_VOLUME` (MFV), `BOX_SPATIAL_DIMENSION=1`,
`BOX_REFLECT_X=1`, `SELFGRAVITY_OFF`, `EOS_GAMMA=(1.4)`, `FORCE_EQUAL_TIMESTEPS`, `DEVELOPER_MODE`, double-precision I/O.
GIZMO's second-order scheme with its defaults (HLLC, its slope limiter, cubic-spline kernel), `DesNumNgb 4`,
`CourantFac 0.2`: GIZMO's step is C (2 h / NumNgb) / (vsig / 2), about C dx / c, so 0.2 gives luna-cpp's and Arepo's
0.4 (dx / 2) / c. Units 1, `MinGasTemp 0`.

## Initial conditions and walls

N particles at the centres of N cells of width 33.2 / N (equal volume, as luna-cpp and LUNA), mass rho h, velocity and specific
internal energy from the exact cell averages of `problems_1d.super_initial`.

Right wall: GIZMO's reflecting wall `BOX_REFLECT_X=1` (a particle past x = 33.2 is put back and its velocity flipped). Left
wall: GIZMO has no zero-gradient outflow (`BOX_OUTFLOW_X` deletes elements past the wall, and the gas at a free end expands into
vacuum), so the open wall is replaced by 8.0 of ambient gas (1, 0, 1) at the same spacing left of x = 0; the vacuum rarefaction
from the pad's free end moves at c = 1.18 and cannot reach x = 0 by t = 2. Files `*_mirrorwall_*`: a check of GIZMO's wall,
built without `BOX_REFLECT_X`, the line and its mirror image (rho, -v, P) with a pad at both far ends (LUNA's and Arepo's
construction). Stored: the particles of [0, 33.2]; cell edges at the midpoints between particles (`x_center`, `dx`).

## Keys

`x` (particle), `x_center`, `dx`, `rho` (GIZMO's kernel density), `u`, `p` ((gamma - 1) rho u); `t`, `n_run`, `steps`,
`wall_s`; `l1_<stage>`: L1 of (rho, v, P) per stage in luna-cpp `scripts/super_tube.py`'s norm (sum of dx |W - target|; at
t = 0.1 the exact Riemann superposition for A to G and LUNA 2^20 for S, H and all; at t = 2 LUNA 2^20); `budget_mass`,
`budget_energy` (particle sums over [0, 33.2] minus the initial totals), `min_rho`, `min_p`; `provenance` (JSON: Config.sh,
param.txt, layout, SLURM jobs, host, patch).
