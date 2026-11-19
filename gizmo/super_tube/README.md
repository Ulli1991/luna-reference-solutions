# Super-hard 1D tube: GIZMO MFM and MFV

GIZMO runs of luna-cpp's super-hard 1D tube (luna-cpp `research_notes/super_tube_2026-11-10.md`, problem `super-tube` of
`scripts/problems_1d.py`), for the comparison with luna-cpp, LUNA and Arepo (`arepo/super_tube/README.md` has the comparison, the
settings that match and those that cannot). An independent code's run, not a truth.

## Code

GIZMO (P. F. Hopkins; GPL-3.0), github.com/pfhopkins/gizmo, the default branch `gpu_kokkos_unified` at
7fe89853c117e1ad817ef20cfc0e71e8b731d16d (2026-11-17), unmodified. Built with the Kokkos 4.6.01 OpenMP backend on CPU (the
`Lonestar6_CPU` machine block with Raven paths, gcc 14, OpenMPI 4, `-O2 -march=icelake-server`); run on Raven CPUs (Xeon Platinum
8360Y), FP64, MPI ranks as given per file (`provenance`).

Config: `HYDRO_MESHLESS_FINITE_MASS` (MFM) or `HYDRO_MESHLESS_FINITE_VOLUME` (MFV, default mesh motion
`HYDRO_FIX_MESH_MOTION=5`), `BOX_SPATIAL_DIMENSION=1`, `SELFGRAVITY_OFF`, `EOS_GAMMA=(1.4)`, `FORCE_EQUAL_TIMESTEPS`,
`DEVELOPER_MODE`, double-precision I/O. GIZMO's second-order scheme with its defaults (HLLC, its slope limiter, cubic-spline
kernel), `DesNumNgb 4`, `MaxNumNgbDeviation 0.01`, `CourantFac 0.2`: GIZMO's step is C (2 h / NumNgb) / (vsig / 2), about C dx / c,
so 0.2 gives luna-cpp's and Arepo's 0.4 (dx / 2) / c. Units 1, `MinGasTemp 0`.

Earlier runs of this tube with the `gizmo-cpp` branch (519be7d) are not kept: there MFV gained a third of the total energy by
t = 0.1 (and also fails to conserve on GIZMO's own Sod and Woodward-Colella problems), which the current branch does not (+0.09 of
1148 by t = 0.1 at N = 4096).

## The four maintained branches (t = 0.1)

The files at the top of this directory are `gpu_kokkos_unified` 7fe8985. The subdirectories hold t = 0.1 at N = 4096 and 32768 on each
of the four maintained branches at their heads of 2026-11-18, MFM and MFV, same configuration, parameters and walls:
`starforge_dev/` (770ad72), `stella_dev/` (caf944d), `gku_stella_dev/` (b45666c), `gpu_kokkos_unified/` (b5f4503) on CPU, and
`gpu_kokkos_unified_gpu/` (b5f4503, Kokkos CUDA on one A100, N = 4096 only). Builds: `gizmo/super_tube_v2/README.md`.

L1 of rho / v / P over all stages:

| branch | MFM 4096 | MFM 32768 | MFV 4096 | MFV 32768 |
|---|---|---|---|---|
| starforge_dev, stella_dev (identical) | 1.10 / 2.51 / 20.0 | 0.168 / 0.547 / 2.72 | 1.35 / 2.51 / 29.7 | 0.801 / 1.43 / 17.8 |
| gku_stella_dev | 1.10 / 2.51 / 20.0 | 0.169 / 0.548 / 2.73 | 0.896 / 1.72 / 18.1 | 0.133 / 0.315 / 2.51 |
| gpu_kokkos_unified b5f4503 | 1.10 / 2.51 / 20.0 | 0.169 / 0.548 / 2.73 | 0.888 / 1.73 / 18.1 | 0.129 / 0.316 / 2.52 |
| gpu_kokkos_unified 7fe8985 (top level) | 1.10 / 2.51 / 20.0 | 0.168 / 0.548 / 2.72 | 0.894 / 1.71 / 18.0 | 0.134 / 0.315 / 2.51 |

MFM agrees across the branches. MFV on the classic branches (starforge_dev, stella_dev) loses total energy, -21.6 (4096) and -22.6
(32768) of 1148 by t = 0.1, with mass -8e-5 and -9e-6; the Kokkos branches keep energy within 0.4 and mass to 1e-12. The A100 run of
gpu_kokkos_unified equals its CPU run in steps and to about 1e-10 relative in the state, and took 621 s (MFM) and 911 s (MFV) against
423 s and 558 s on 2 CPU cores; luna-cpp on the same A100 (1305 MHz): 0.026 s static, 0.66 s moving.

## Initial conditions and walls

N particles at the centres of N cells of width 33.2 / N (equal volume, as luna-cpp and LUNA), mass rho h, velocity and specific
internal energy from the exact cell averages of `problems_1d.super_initial`.

Walls: LUNA's and Arepo's construction. The line and its mirror image (rho, -v, P) in an open, non-periodic box; the reflecting
wall at x = 33.2 is the mirror plane. GIZMO has no zero-gradient outflow (`BOX_OUTFLOW_X` deletes elements past the wall, and the
gas at a free end expands into vacuum), so both far ends carry 8.0 of ambient gas (1, 0, 1) at the same spacing; the vacuum
rarefaction from a free end moves at c = 1.18 and cannot reach x = 0 by t = 2. GIZMO's own reflecting wall (`BOX_REFLECT_X`) was not
used: its last particle sees a truncated kernel and starts at rho 0.60, P 60 instead of 1, 100. Stored: the particles of [0, 33.2];
cell edges at the midpoints between particles (`x_center`, `dx`).

## Files and how far the runs got

Stored: MFM and MFV at N = 4096 and 32768, t = 0.1. No state at t = 2: the runs (one 72-core node, SLURM 32572866, 4.3 h,
2026-11-19) were stopped on the owner's decision.

| run | reached | last step | why |
|---|---|---|---|
| MFM, N = 4096 (8 ranks) | t = 0.9207, 854,364 steps | 6.0e-8 | the step fell from 9.5e-7 at t = 0.906 to 6e-8 at 0.913 and stayed there: about 1.8e7 more steps (some 90 h) to t = 2. The 519be7d MFM run fell at the same time, in stage E's swept-up 1e-3 gas (its particles at spacing 1e-3 h); for this run that place is inferred, not measured (no snapshot past t = 0.1) |
| MFV, N = 4096 (8 ranks) | t = 0.9727, 840,720 steps | 2.4e-7 | slow, not stalled: about 4.3e6 more steps at 55 per second |
| MFM, N = 32768 (32 ranks) | t = 0.1750, 168,981 steps | 2.4e-7 | about 10 steps per second; t = 2 needed weeks |
| MFV, N = 32768 (24 ranks) | t = 0.1308, 158,398 steps | 4.8e-7 | likewise |

The comparison tables at t = 2 list these runs as "reached t = ..." without a score.

## Keys

`x` (particle), `x_center`, `dx`, `rho` (GIZMO's kernel density), `u`, `p` ((gamma - 1) rho u); `t`, `n_run`, `steps`, `wall_s`;
`l1_<stage>`: L1 of (rho, v, P) per stage in luna-cpp `scripts/super_tube.py`'s norm (sum of dx |W - target|; at t = 0.1 the exact
Riemann superposition for A to G and LUNA 2^20 for S, H and all; at t = 2 LUNA 2^20); `budget_mass`, `budget_energy` (particle sums
over [0, 33.2] minus the initial totals), `min_rho`, `min_p`; `provenance` (JSON: Config.sh, param.txt, layout, SLURM jobs, host).
