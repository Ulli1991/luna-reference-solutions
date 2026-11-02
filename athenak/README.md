# AthenaK references

AthenaK runs from LUNA's own initial data (pgen `luna_ic`, `tools/athenak/`), reduced with the LUNA tests'
metric functions by `tools/athenak_refs.py`. Each npz holds the metrics per N (keys `<case>_N<n>_<metric>`
or `N<n>_<metric>`) and `provenance`, a JSON string: LUNA and AthenaK commits, the binary, and per run the
AthenaK input, the log tail, SLURM job id, node, GPU (A100-SXM4-40GB) and run line. Full outputs:
`/ptmp/uli/jax-hydro/luna_tests/athenak/`. AthenaK 886dd2a + branch `luna_ic` (6f269fe4, c0d1427d;
c52f88f0 changes a comment only), CUDA 12.6, Kokkos AMPERE80, FP64, HLLC, CFL 0.4 (the CFL the viper
numbers were made with: A1 reproduces them at 0.4, not at 0.3). Made 2026-10-11 on Raven; the LUNA commit
in `provenance` is the base the (then uncommitted) tools ran on, `c6c442d` holds them. The A3, A4, A9 files
(2026-10-12) were reduced from the clean commit `cb55e38` (`luna_dirty` empty; the references themselves are
not counted); their LUNA counterparts are `tools/athenak_refs.py luna`, tabulated in `docs/TEST_PLAN.md`. The A11 files
(2026-10-14) were reduced from the clean commit f8e0a6b, after main's config-3 core box became (0.05, 0.65)^2 (an earlier
reduction at the old box is superseded); the AthenaK inputs set `dfloor = pfloor = 1e-8`.

The binary: `build_gpu_lunaic/src/athena`, sha256 `e40b2abddc8cc709ff7c14b30a814302fd03e8bce3ea327793c4ee51adbd877b`,
built 2026-10-11 15:24:45 from the `luna_ic` working tree, i.e. before the commits c0d1427d (15:27, the
`dump_vars` option) and c52f88f0 (17:28, a comment), which touch the pgen only; the hydro kernels are 886dd2a's.
`athenak_commit` in a provenance is the source HEAD at reduction; the A3/A4/A9 files also carry
`athenak_binary_sha256` and `athenak_binary_mtime`. The build's `git-state.txt` ("08ceff92b-CLEAN") is the Kokkos
submodule's, not AthenaK's. Every run used this one binary.

| file | test | setup | content | check against the viper numbers in TEST_PLAN.md |
|---|---|---|---|---|
| `a1_plm_rk2_1024.npz` | A1 | right sound wave, EPS 1e-6, one period, N = 32..1024, PLM + RK2 | AthenaK's RMS-L1 / EPS (`errs_rms`; `dump_rms` the same from the float64 dump), per-variable L1 | 7.38e-2 .. 8.18e-5 (viper 7.4e-2 .. 8.2e-5) |
| `a1_ppmx_rk4_1024.npz` | A1 | same, PPMX + RK4 | same | 3.92e-4, 2.52e-5, floor 5.55e-6 by 256 (viper 3.9e-4, 2.5e-5, 5.5e-6) |
| `rm_ppmx_rk4_512.npz` | A14 | both cases, +-psi0, 32..512 cells per wavelength, rho every 0.02 | L1/L2/Linf of psi/psi0 and the rate error, psi(tau), the exact curve (Laplace route); `<case>_L1` = 512 | heavy-light 0.0395 / -3.16 % (viper 0.040 / -3.2 %); light-heavy 0.0500 / -1.93 % (viper 0.049 / -1.9 %) |
| `rt_ppmx_rk4_512.npz` | A13 | +-AMP eigenmode, Nx = 32..512, g in `<hydro_srcterms>` | `test_hydro_hard_rayleigh_taylor.series`: L1, L2, Linf, sigma, drift, energy | L1/sigma 0.068/0.24, 0.037/0.093, 0.0085/0.013, 0.0013/0.0016, 3.5e-4/2.9e-4 (viper ... 3.4e-4/3.0e-4) |
| `tg_ppmx_rk4_256.npz` | A15 | M = 0.1 TG, 32..256^3, to t = 20 | K(t) per unit mass every 0.1 (`N<n>_t`, `N<n>_K`) | Re_eff not computed: needs `tg_viscous_spectral.npz` (not on Raven) |
| `a3_plm_rk2_1024.npz` | A3 | LW smooth advection, [0, 2]^2, T = 4, N = 32..1024 and 200, PLM + RK2, 64^2 blocks | `test_hydro_accuracy_lw_smooth.errors`: `N<n>_relL1_pct`, `_L1`, `_L2`, `_Linf` of rho; `N64_rho` the final field | new (2026-10-12); L1 9.84e-3 .. 9.39e-6, LW 200^2 2.89e-2 % |
| `a3_ppmx_rk4_1024.npz` | A3 | same, PPMX + RK4 | same | new; fourth order, L1 3.91e-5 .. 3.93e-11 |
| `a4_plm_rk2_1024.npz` | A4 | Gresho p(0) = 5, static and moving, one revolution, N = 32..1024; LW 40^2 static, 160 x 40 moving (outflow, T = 3); PLM + RK2 | `test_hydro_hard_lw_gresho.periodic`: `<static/moving>_N<n>_<v/rho/p>_<L1/L2/Linf>`; `lw_metrics`: `lw40x40_*`, `lw160x40_*` | new; static v L1 0.0295 .. 1.70e-4 |
| `a4_ppmx_rk4_1024.npz` | A4 | same, PPMX + RK4 | same | new; static v L1 0.0132 .. 7.46e-5, flattens from 512 |
| `a4_ppm4_rk4_1024.npz` | A4 | same, PPM4 + RK4 (no extremum-preserving limiter) | same | new; static v L1 0.0137 .. 5.23e-5 |
| `a9_plm_rk2_16384.npz` | A9 | WC blast on N x 16 strips (reflect x, y; 1024 also periodic y) and 1D, N = 256..2048, T = 0.038; 1D run at 16384; PLM + RK2 | `N<n>_<r/p>_vy_max`, `_row_spread`, `_strip_minus_1d` (the test's checks, strip vs AthenaK's own 1D); `_L1_rho_strip/_1d` against the LUNA MC 2^16 reference (`luna/woodward_colella/woodward_colella_mc.npz`), `_L1_rho_strip_akplm/_1d_akplm` against this file's `ref_rho` (16384 cells); `ref_L1_vs_luna_at1024/8192` | new; checks exactly 0; L1 0.162 .. 0.0330 (0.159 .. 0.0279 against itself); ref 0.0055 from LUNA's at 1024 |
| `a9_ppmx_rk4_16384.npz` | A9 | same, PPMX + RK4, `dfloor = pfloor = 1e-8` (at AthenaK's default FLT_MIN floors: NaN at the blast collision) | same | new; checks exactly 0; L1 0.110 .. 0.0201; ref 0.0019 from LUNA's at 1024 |
| `a9_ppm4_rk4_16384.npz` | A9 | same, PPM4 + RK4, same floors | same | new; checks exactly 0; L1 0.112 .. 0.0223; ref 0.0037 |
| `a11_c3_plm_rk2_2048.npz` | A11 | KT config 3, (0, 1)^2 outflow walls, T = 0.3, N = 256..2048, 64^2 MeshBlocks, PLM + RK2, `dfloor = pfloor = 1e-8` | `c3_N<n>_<metric>`: the test's `ref_errors` (`L1`, `L2`, `L1_core`, `L1_out` on 128^2; `L1_M64`, `L1_M256`), `_ak` the same against the PPMX 8192 file, strips (`strip<if>_L1`, `_front_cells`; config 6 `pstrip<if>_L1`), `asym`, `asym_rho_L1`, `budget`, `ncycle`, `wall_s`; `c3_ref_rho256` the 2048 run on 256^2 (float32), `c3_ref_vs_luna_*` | new (2026-10-14); L1_out 1.60e-3 .. 1.82e-4 (core (0.05, 0.65)^2), strip 21 4.98e-4 at 2048, asym <= 4.8e-12 |
| `a11_c6_plm_rk2_2048.npz` | A11 | config 6, same; also 256, 512 to t = 0.25 (wall budget) | same, `c6_` | new; L1_out 1.20e-2 .. 1.72e-3 |
| `a11_c3_ppmx_rk4_8192.npz` | A11 | config 3, PPMX + RK4, N = 256..8192 (4096, 8192 on 4 ranks), same floors | same; `c3_ref_rho256` = the 8192 run (AthenaK's A11 reference), `c3_ref_self_*_4096_8192`, `c3_ref_vs_luna_*` against `luna/kt_riemann/kt_riemann_c3_mc.npz` | new; L1_out 1.34e-3 .. 1.52e-4 (8192 vs LUNA ref), asym 8.5e-4 .. 0.54 |
| `a11_c6_ppmx_rk4_8192.npz` | A11 | config 6, same | same, `c6_` | new; L1_out 7.3e-3 .. 1.7e-3 (1024), then 5.1e-3 .. 2.7e-2 (slip lines roll up from 2048): no config-6 reference |
| `a5_plm_rk2_2048.npz` | A5 | McNally KH (test IC, point-sampled), N = 128..2048, 64^2 blocks, `dfloor = pfloor = 1e-8`, to t = 1.5 as 75 chained runs of 0.02 (AthenaK clamps dt to tlim only, so each output lands on t = 0.02 k), PLM + RK2 | `N<n>_t`, `_M`, `_K` (76 times), `_eM_max`, `_eM_int` (time integral, the test's bound), `_eM_end` (signed, t = 1.5; near a zero crossing for AthenaK PLM), `_eK_max`, `_eK_end` (the test's m_errors, ke_errors), `_<rho/vy>_<L1/L2/Linf>` (field_errors vs the LUNA MC 4096 reference), the same `_ak` vs `a5_ppmx_rk4_4096.npz`, `_nat_*` on the run's own grid (N <= 1024, incl. MUSIC's relative L1(V_y)), `_steps`; no fields (only the 4096 reference's are read) | new (2026-10-14); max_t eM 0.0589 .. 4.11e-5 |
| `a5_ppmx_rk4_4096.npz` | A5 | same, PPMX + RK4, N = 128..2048 and 4096 (4 ranks): the independent A5 field reference | same; `N4096_rho`, `_my` (t = 1.5, 256^2 float32); `ref_vs_luna_*` (vs the LUNA MC 4096 reference, 256^2 and 1024^2), `ref_self_l1_*` (4096 vs 2048) | new; max_t eM 0.0299 .. 8.56e-5, 4096 2.09e-5 (order-2 Richardson 2048/4096 1.2e-6); L1(V_y) vs LUNA's 4096 2.26e-6 |
| `a5_ppm4_rk4_2048.npz` | A5 | same, PPM4 + RK4, N = 128..2048 | as the PLM file | new; max_t eM 0.0324 .. 8.45e-5 |

RM psi is measured at the dumps' actual times (AthenaK does not land on output times; offsets <= 4e-4 at 512)
and the exact curve evaluated there. `tools/rm_linear.psi_history` (Bessel series) diverges for light-heavy
beyond tau ~ 12 with scipy 1.16.3 (|psi| ~ 1e10); the Laplace route agrees with it to 4e-9 where it converges.

A10 (2026-10-14, `tools/athenak_refs.py prep|reduce a10`, `lit_a10/athenak.md`, critic `critic_a10/critic.md`): the test's
exact cell-average IC (`LW-Implosion`, not AthenaK's `lw_implode` pgen, whose interface sits dx/4 out), (0, 0.3)^2,
reflecting x1 and x2, `dfloor = pfloor = 1e-8` for every scheme, MeshBlocks 50^2 (N = 100..800, 400) or 64^2 (128,
256, 512, 1024, 3200, 6400). Reduced from the clean commit d8663c7 (`luna_dirty` empty); `reduce` also checks that the
test's own `early_errors` / `late_l1` give the stored numbers. Two binaries, both recorded in `provenance` `binaries`
(sha256, mtime) and in each run's `job.json` run line:
- `build_gpu_lunaic` (e40b2abd...877b), nvcc's default FMA contraction: runs tagged `_e` (t = 0.045), `_l` (t = 2.5),
  `jet` (400^2 at the test's JET_TIMES 2.40..2.60). Built 2026-10-11 15:24 from the `luna_ic` working tree before
  c0d1427d and c52f88f0, which change only `src/pgen/luna_ic.cpp` I/O; a fresh build of c52f88f0 reproduces its runs
  bitwise (critic_a10 job 31168524). `athenak_commit` (c52f88f0) is the source HEAD at reduction, not the binary's.
- `build_gpu_lunaic_nofma` (`/ptmp/uli/jax-hydro/luna_tests/athenak/`, 2e963374...a5a8b, 2026-10-12): the same tree
  and flags plus `-fmad=false`; runs tagged `_ne`, `_nl`, `njet`. Exactly mirror symmetric in every run.

| file | test | setup | content | check |
|---|---|---|---|---|
| `a10_plm_rk2_1024.npz` | A10 | t = 0.045 at N = 100..800, t = 2.5 at 128, 256, 400, 512, 1024, jet times at 400; both binaries; PLM + RK2 | `N<n>_<tag>_L1/_L2` (vs `luna/lw_implosion/lw_implosion_mc.npz`, the test's `early_errors`), `_L1_akppmx/_L2_akppmx` (vs this directory's PPMX 6400^2); `N<n>_<tag>_s_jet`, `_late_L1` (not at 400: no 256^2 blocking); `N400_jet_*` / `N400_njet_*` the s_jet at each JET_TIME and their `median`; every run `asym_rho/_m/_E` (max abs(q - q^T)), `dM`, `dE`, `ncycle`, `zcps` (AthenaK's zone-cycles/s), `loop_s` (cells x cycles / zcps), `wall_s` (the job's time for the run, start-up included) | L1 3.10e-3 .. 5.40e-4; jet median 0.130 (both builds) |
| `a10_ppmx_rk4_6400.npz` | A10 | same, PPMX + RK4, plus 3200^2 and 6400^2 at t = 0.045 with both binaries (jobs 31111002, 31165951; no FMA 31169076, 31167428) | same; `ref_rho` the no-FMA 6400^2 run block-averaged onto 800^2 (exactly symmetric, `ref_asym800` 3e-16; symmetrised only to store the lower triangle, float32, `tools/implosion_reference.untri`), `ref_L1_vs_luna`, `ref_L1_self` (6400 vs 3200) | L1 2.27e-3 .. 3.54e-4; ref 5.9e-5 from LUNA's (L1), self 8.7e-5; jet median 0.097 (no FMA), 0.091 (FMA) |
| `a10_ppm4_rk4_1024.npz` | A10 | as PLM, PPM4 + RK4 | same | L1 2.16e-3 .. 3.49e-4; jet median 0.158 (no FMA), 0.228 (FMA, an artefact of the asymmetric run) |

AthenaK's results depend on the MeshBlock layout at round-off (each block computes its dx from its own edges,
`athenak/src/mesh/meshblock.cpp:113-118`): L1 by <= 0.11 %, but the FMA build's late PPMX s_jet by 0.09-0.11
(critic_a10); there is no analogue of LUNA's "N shards == one device".

A7 and A8 (2026-10-14) need self-gravity, which 886dd2a lacks: they ran a different binary,
`build_gpu_lunaic_mg/src/athena`, sha256 `fd151e3a870b8d0a8c697c966ddef1aec10e25b4fdd924d429ff51b46dcf97f2`,
built from branch `luna_ic_mg` 7f1c7989 = upstream main c5a0d7f9 (multigrid PR #776) + the three luna_ic commits,
Kokkos 6739bc62 (4.7); `athenak_commit` / `athenak_upstream` / `athenak_binary_sha256` in their provenance.
It reproduces the A1 PLM run at N = 128 bitwise and at 1024 to 2e-14 (`tools/athenak/README.md`). Multigrid:
FMG then V-cycles to round-off (`threshold = 0`), periodic (mean subtracted), `four_pi_G` from the test's G;
floors `dfloor = pfloor = 1e-8`; CFL 0.3 (PLM + RK2 at 0.4 is unstable in 3D: the A7 stable wave at 128 grew to
O(0.1)); HLLC; one A100 (4 for A8 at 256).

| file | test | setup | content | check |
|---|---|---|---|---|
| `a7_plm_rk2_128.npz` | A7 | Jeans wave from the test's `initial()`, N x N/2 x N/2, N = 32, 64, 128, two (N/2)^3 MeshBlocks; n_J 0.5 one period, n_J 1.5 one e-fold; PLM + RK2 | `test_gravity_jeans_wave.errors`: `<stable/unstable>_N<n>_L1`, `_L2`, `_Linf` of (rho - exact) / AMP, `_amp` = abs(ratio / exact - 1), `_ratio`, `_ncycle` | new; stable L1 0.0611 .. 0.00102, unstable 0.0419 .. 0.00131 |
| `a7_ppmx_rk4_128.npz` | A7 | same, PPMX + RK4 | same | new; stable 2.29e-5 .. 5.87e-7, unstable 0.0109 .. 6.53e-4 (second order) |
| `a7eqdt_plm_rk2_128.npz`, `a7eqdt_ppmx_rk4_128.npz` | A7 | same at CFL 0.8/3, LUNA's dt (step counts 47, 93, 185 = LUNA's) | same | PLM stable 0.00103, unstable 0.00117 at 128 |
| `a8_plm_rk2_256.npz` | A8 | periodic Evrard (L = 4R) from `initial_conditions(cfg_for(n))`, N = 32..256, min(N, 64)^3 MeshBlocks, to t = 3; 32, 64: one run per output time (tlim = 0.25 k, exact), 128, 256: dumps at the history cadence (up to `max_t_late` past 0.25 k) | `N<n>_dE` (12 times), `_dE_t<t>`, energies `_K`, `_Th`, `_W`, `_rho_max`, `_t`, `_exact`, the dump series `_t_dump`, `_dE_dump`, `_mass_drift`, `_nonfinite`, `_ncycle` | new; abs(dE/E0) at t = 3: 2.36e-3, 2.43e-4, 2.79e-5, 3.71e-6 |
| `a8_ppmx_rk4_256.npz` | A8 | same, PPMX + RK4 | same | new; t = 3: 0.162 (32: the pressure floor fires at the bounce), 1.22e-5, 9.83e-5, 4.48e-5 |

A5 (2026-10-14, `tools/athenak_refs.py prep|reduce|luna|table a5`, `lit_a05/athenak.md`, critic
`critic_a05/critic.md`): the test's point-sampled IC; AthenaK clamps dt to tlim only, so each run is a chain of 75
runs of 0.02 from the previous final dump (M read at t = 0.02 k exactly). Reduced from the clean commit 19ef0ad
(`luna_dirty` empty); LUNA counterparts `tools/athenak_refs.py luna a5` (`luna_tests/lit_a05/luna_a5.json`). Their
provenance records `athenak_dirty` = `src/eos/primitive-solver/unit_system.cpp` (static_casts in the primitive
solver, not on the ideal-hydro path; the binary is pinned by sha256). AthenaK's end states (every 0.02, float64) stay
in `luna_tests/lit_a05/ak/<scheme>_cfl0.4_floor1e-8/`.

A6 (2026-10-14, `tools/athenak_refs.py prep|reduce|luna|table a6`, `luna_tests/lit_a06/athenak.md`): the test's
`steady(n)` (exact cell averages of rho = p = exp(-sin 2 pi x), u = 0), periodic, gamma 1.4, to T = 2 / sqrt(gamma).
AthenaK's `const_accel` is uniform only, so these runs used the pgen's new static potential (user source term, g =
-dphi/dx at the cell centres, added per RK stage from the stage primitives as `const_accel`): branch `luna_ic_a6`
687f5a64 (= `luna_ic` c52f88f0 + the potential), worktree `/u/uli/athenak_a6`, binary
`build_gpu_lunaic_a6/src/athena`, sha256 `c6ded97ec8037041832297054f679c053457d1bb2fc36a60be883b143c3134cd`, built by
job 31171756 from the working tree whose content was then committed unchanged as 687f5a64 (hydro kernels 886dd2a's).
HLLC, FP64, `dfloor = pfloor = 1e-8`, MeshBlocks of 64..256 cells (one block up to 256, then 256), one A100. Reduced
from the clean commit 05815aa (`luna_dirty` empty); LUNA counterparts `luna_tests/lit_a06/luna_a6.json` (job 31172111,
same commit).

| file | test | setup | content | check |
|---|---|---|---|---|
| `a6_plm_rk2_2048.npz` | A6 | N = 64..2048 at CFL 0.4, plus the flipped potential (phi0 = -1) at 256; PLM + RK2 | the test's `errors()`: `N<n>_<rho/mom/E>_<L1/L2/Linf>` of U(T) - U(0), `_budget` = abs(d(E + rho phi)) / (E + rho phi), `ncycle`, `zcps`, `loop_s`, `wall_s`; `N256flip_*` the teeth run | new; rho L1 4.86e-5 .. 2.04e-8 (128 .. 2048), order 2.9; flipped rho L1 1.28 (LUNA's 1.28) |
| `a6_ppmx_rk4_2048.npz` | A6 | same, PPMX + RK4 | same | new; rho L1 2.94e-5 .. 1.15e-7, order 2.0; budget <= 1.9e-9 from 128 |
| `a6_ppm4_rk4_2048.npz` | A6 | same, PPM4 + RK4 | same | new; rho L1 3.60e-5 .. 1.17e-7, order 2.1 |
| `a6eqdt_plm_rk2_2048.npz`, `a6eqdt_ppmx_rk4_2048.npz` | A6 | same at CFL 0.8 = LUNA's dt (step counts 161 .. 5121, LUNA's) | same | PLM rho L1 2.07e-8, PPMX 1.15e-7 at 2048 (dt does not matter for AthenaK) |

Shu-Osher and Titarev-Toro (2026-10-30, `tools/athenak_refs.py prep|reduce so|tt`): the tests' own IC
(`initial_conditions` of `Shu-Osher` / `Titarev-Toro`, [0, 10], zero-gradient ends, T = 1.8 / 5), binary
`build_gpu_lunaic` (e40b2abd...877b), HLLC, FP64, CFL 0.4, `dfloor = pfloor = 1e-8`, 512-cell MeshBlocks, one A100.
The runs at the tests' N (PLM + RK2 and PPMX + RK4; SO 256..2048, TT 1024..8192) were made 2026-10-15 for the site
pages (`luna_tests/site/ak/{so,tt}`, `site/run_ak.sh`, SLURM 31174897/31174898); the PPMX reference and its half-N
check run 2026-10-30 (`luna_tests/phase_b/ak/{so,tt}/ppmx_rk4_cfl0.4`, which also holds copies of the site runs;
`phase_b/ak_ref.sh`, SLURM 31699054 SO 8192 + 16384, 31699055 TT 32768, 31699056 TT 65536). Reduced (SLURM 31699122,
JAX on CPU) with `ATHENAK_DIR=/u/uli/athenak` (source c52f88f0; `athenak_dirty` as above). Each run's job record,
input and log tail are in `provenance`.

| file | test | content | check |
|---|---|---|---|
| `shu_osher/so_ppmx_rk4_16384.npz` | Shu-Osher | `ref_rho` (16384 cells, float64), `ref_L1_self`/`_L2_self` (8192 vs 16384 on 8192 cells), `ref_L1_vs_luna_at8192`/`_at1024` (vs `luna/shu_osher/shu_osher_mc.npz`); per N `N<n>_rho` (final rho), `_L1`, `_L2` (vs `ref_rho`, h-weighted as the test's `errors`), `_L1_luna`, `_L2_luna`, `_ncycle`, `_nonfinite` | self 9.0e-3, vs LUNA 6.3e-3; L1 0.470, 0.217, 0.104, 0.0484 at 256..2048 |
| `shu_osher/so_plm_rk2_2048.npz` | Shu-Osher | PLM + RK2 per N, the same keys against the PPMX file's `ref_rho` (no `ref_*`) | L1 0.725, 0.482, 0.198, 0.0791 |
| `titarev_toro/tt_ppmx_rk4_65536.npz` | Titarev-Toro | as SO: `ref_rho` 65536 cells, self 32768 vs 65536 | self 2.17e-3, vs LUNA 2.09e-3; L1 0.425, 0.0782, 0.0445, 0.0171 at 1024..8192 |
| `titarev_toro/tt_plm_rk2_8192.npz` | Titarev-Toro | PLM + RK2 per N against the PPMX `ref_rho` | L1 0.482, 0.436, 0.244, 0.0748 |
