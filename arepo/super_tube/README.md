# Super-hard 1D tube: Arepo, and how the Arepo and GIZMO runs compare with luna-cpp and LUNA

Arepo runs of luna-cpp's super-hard 1D tube (luna-cpp `research_notes/super_tube_2026-11-10.md`, problem `super-tube` of
`scripts/problems_1d.py`): gamma = 1.4 on [0, 33.2], stages A to H, left wall open, right wall reflecting, states at t = 0.1 and
t = 2, N = 4096 and 32768. An independent code's run, not a truth. GIZMO's runs are in `gizmo/super_tube/`.

## Code

Arepo (V. Springel; GPL-3.0), the developers' repository `git@bitbucket.org:volkerspringel/arepo.git`, master
e6227fafc3eac20a0cab07222ae0de6e8118d12c, unmodified: the version of the Arepo 1D outputs on branch `arepo-1d-tests`. Built
with gcc 14, OpenMPI 4; one CPU core (Xeon Platinum 8360Y) per run (the 1D mesh, `src/voronoi_1d.c`, takes one task), FP64.

Config: `VORONOI CHUNKING ONEDIMS REFLECTIVE_X=2 GAMMA=1.4 REGULARIZE_MESH_CM_DRIFT REGULARIZE_MESH_CM_DRIFT_USE_SOUNDSPEED
REGULARIZE_MESH_FACE_ANGLE FORCE_EQUAL_TIMESTEPS DOUBLEPRECISION=1 INPUT_IN_DOUBLEPRECISION OUTPUT_IN_DOUBLEPRECISION
OUTPUT_CENTER_OF_MASS HAVE_HDF5 TREE_BASED_TIMESTEPS ENLARGE_DYNAMIC_RANGE_IN_TIME DEBUG`; parameters of
`examples/shocktube/shocktube_1d/param.txt` with CourantFac 0.4. Arepo's default second-order scheme and its default exact
Riemann solver. The earlier "matched" setting with `RIEMANN_HLLC` stops in the first step: `press < 0` at the faces of x = 18.6
(F's (1, -3.44, 1) next to the ambient gas, a strong rarefaction where HLLC's star pressure goes negative), so the Riemann
solver is not matched. `ENLARGE_DYNAMIC_RANGE_IN_TIME` only widens the integer time line (2^60 instead of 2^29 ticks).

## Initial conditions and walls

N cells of width 33.2 / N (equal volume, as luna-cpp and LUNA), each with the exact average of the conserved state
(`problems_1d.super_initial`); generators at the cell centres, mass rho h. Arepo's `REFLECTIVE_X` is one setting for both ends,
so the run is LUNA's construction: the line and its mirror image (rho, -v, P) on [0, 66.4], 2N cells, Arepo's outflow ghosts
(`REFLECTIVE_X=2`) at both ends; the reflecting wall at x = 33.2 is the mirror plane. Arepo writes an output at the first sync
point past its time (t = 0.100006 at 4096), so the t = 0.1 state is a run of its own that ends at `TimeMax = 0.1`. Stored: the
cells of [0, 33.2], edges at the midpoints of the generators.

## Keys

`x` (generator), `x_center`, `dx`, `rho`, `u`, `p`; `t`, `n_run`, `steps`, `wall_s`; `l1_<stage>`: L1 of (rho, v, P) per stage in
luna-cpp `scripts/super_tube.py`'s norm (at t = 0.1 the exact Riemann superposition for A to G and LUNA 2^20 for S, H and all;
at t = 2 LUNA 2^20, branch `super-tube`, `luna/super_tube/`); `budget_mass`, `budget_energy`, `min_rho`, `min_p`; `provenance`
(JSON: Config.sh, param.txt, layout, SLURM jobs, host).

## What is matched, and what is not

Matched for every code: the initial cell averages on N equal-volume cells, gamma, the stages, N, the end times, the norm and the
references, FP64, and the Courant number in the sense of the time step of a quiet cell (Arepo's and luna-cpp's moving rule
0.4 (dx / 2) / (c + |v - w|) with the pair term; GIZMO CourantFac 0.2 on its (2 h / NumNgb) / (vsig / 2); LUNA and luna-cpp
static use LUNA's rule at CFL 0.8), and a global time step (FORCE_EQUAL_TIMESTEPS in Arepo and GIZMO).

Not matched: the Riemann solver (luna-cpp, LUNA, GIZMO: HLLC; Arepo: exact, its HLLC fails at step 1), the limiter (luna-cpp:
MC at face centroids; LUNA: MC; Arepo and GIZMO: their own), the time integrator (luna-cpp and LUNA MUSCL-Hancock; Arepo its
half-step prediction; GIZMO its drift-kick), mesh regularisation (luna-cpp: AREPO-ng's drift plus the generator velocity of
#25 past 0.75 r; Arepo: its CM drift with the sound speed and the face-angle criterion; GIZMO MFM: none, Lagrangian; GIZMO MFV:
its default mesh motion), the open wall (luna-cpp, LUNA and Arepo: zero-gradient ghosts; GIZMO has none and gets 8.0 of ambient
gas beyond x = 0 instead; the reflecting wall is luna-cpp's own, and the mirror plane of the line and its mirror image in LUNA,
Arepo and GIZMO), the
parallel layout (Arepo one core; GIZMO 8 to 32 MPI ranks; luna-cpp one A100; LUNA one core), and the cell volume of GIZMO (kernel
volume m / rho, not the midpoint width used for the norm).
