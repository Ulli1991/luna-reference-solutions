# Gap analysis: which LUNA validation problem has which reference (2026-10-30; phase B update the same day)

Phase B (2026-10-30): A5, A9, A10, A11 (config 3), Shu-Osher and Titarev-Toro now gate against AthenaK in LUNA's tests
(`tests/_athenak.py`); their LUNA-self references remain as labelled regressions.

Kinds: **exact** = analytic/exact solution computed in LUNA's test code; **external** = another code's output stored
here; **literature** = published numbers/curves; **LUNA-self** = LUNA's own high-resolution or frozen output
(`luna/`, regression only); **none**. "To make it an external gate" says what is missing for the test to be gated
against an independent code. Sources: LUNA `docs/TEST_PLAN.md`, `docs/WORKPLAN_A.md` (IDs A1..A19), `tests/`.
Paths are relative to this repository.

## Hard hydro (group A)

| ID | problem | gated reference in LUNA | external reference here | missing for an external gate |
|---|---|---|---|---|
| A1 | linear sound wave | exact | `athenak/sound_wave/` (PLM, PPMX, 32..1024) | nothing (exact is the gate; AthenaK is context) |
| A2 | AMR seam pair | exact | none | AthenaK AMR `amr_linwave` run not done |
| A3 | LW smooth advection | exact | `athenak/lw_smooth_advection/` | nothing (context) |
| A4 | Gresho static/moving | exact | `athenak/gresho_vortex/` | nothing (context) |
| A5 | McNally KH | literature (Pencil curves `pencil/mcnally_kh/`) + **external** field (AthenaK PPMX 4096^2, `athenak/mcnally_kh/a5_ppmx_rk4_4096.npz`; LUNA van Leer within 5 % of AthenaK PLM, 3-4 % above it in V_y); LUNA-self field kept as regression | `athenak/mcnally_kh/` | nothing (an AthenaK PLM run at CFL 0.8 would say whether the V_y gap is LUNA's larger time step) |
| A6 | isothermal atmosphere | exact | `athenak/isothermal_atmosphere/` | nothing (context) |
| A7 | Jeans wave | exact | `athenak/jeans_wave/` | nothing (context); CFL-0.4 variant (`luna_tests/a07_a08_ak/cfl04/`) not taken |
| A8 | Evrard energy | budget (self-consistency) | `athenak/evrard/` | Arepo/Gadget Evrard not run; energy gate is a budget, no external curve gated |
| A9 | Woodward-Colella / odd-even | **external** (AthenaK PPMX 16384, `athenak/woodward_colella/a9_ppmx_rk4_16384.npz`; van Leer vs AthenaK PLM matched); LUNA-self kept as regression | `athenak/woodward_colella/` (PLM/PPMX/PPM4 1D 16384) | AthenaK PLM per-N fields not stored (the matched bound uses a triangle upper bound) |
| A10 | LW implosion | **external** at t = 0.045 (AthenaK PPMX 6400^2 no-FMA; van Leer vs AthenaK PLM matched); late time (t = 2.5) LUNA-self, regression only | `athenak/lw_implosion/` | no converged late-time reference in either code |
| A11 | Kurganov-Tadmor 3, 6 | exact 1D wall strips; config 3 outside the core **external** (AthenaK PPMX 8192^2; van Leer vs AthenaK PLM matched); cores and config 6 LUNA-self, regression only | `athenak/kt_riemann/` (PPMX 8192^2) | config 6: AthenaK PPMX rolls the slip lines up (4096 vs 8192 L1 0.044), no external laminar reference; cores do not converge in either code |
| A12 | Kamm-Timmes Sedov | closed | none | not planned |
| A13 | Rayleigh-Taylor | exact (linear growth) | `athenak/rayleigh_taylor/` | nothing (context) |
| A14 | Richtmyer-Meshkov | exact (linear) | `athenak/richtmyer_meshkov/` (printed by the GPU test) | nothing (context) |
| A15 | Taylor-Green inviscid / Re_eff | spectral (`spectral/taylor_green/`, `spectral/taylor_green_viscous/`) | `athenak/taylor_green/` (K(t), Re_eff), `spectral/taylor_green_brachet1983/` | Re 3200 spectral reference open; AthenaK raw 13 GB in `luna_tests/a15_ext/ak` not reduced beyond 256^3 |
| A16 | comoving adiabatic expansion, top-hat | exact | `arepo/cosmo_a16_xcheck/`, `ramses/cosmo_a16_xcheck/` | printed, never gated (both codes miss the gamma-7/5 term) |
| A17 | Keplerian disc | exact (steady state) | none | AthenaK pgen (point mass) not written; GIZMO IC exists (`luna_tests/lit_a17/ic_gizmo`), no GIZMO run |
| A18 | Guderley surrogate | exact (self-similar alpha) | none | AthenaK not run |
| A19 | Iliev 1 / M1 front | open | none | Iliev et al. 2006 comparison-code curves not digitised; AthenaK radiation is not M1 |

Other hydro tests: Sod/shock tubes, Riemann, Sedov, Noh (planar, multi-D), LeBlanc, Einfeldt, carbuncle, vortex,
Galilean, low Mach, well-balanced, la14379: **exact** (in LUNA's code); no external code stored, none needed for the gate.

| problem | gated reference | external reference here | missing |
|---|---|---|---|
| Shu-Osher | **external** (AthenaK PPMX 16384, `athenak/shu_osher/`; van Leer vs AthenaK PLM matched); LUNA-self kept as regression | `athenak/shu_osher/` (PPMX 16384 + 8192, PPMX/PLM 256..2048) | nothing |
| Titarev-Toro | **external** (AthenaK PPMX 65536, `athenak/titarev_toro/`; van Leer vs AthenaK PLM matched); LUNA-self kept as regression | `athenak/titarev_toro/` (PPMX 65536 + 32768, PPMX/PLM 1024..8192) | nothing |
| Agertz blob / KH / RT mixing | regression only (self-bounded) | none | AthenaK blob runs exist raw (`luna_tests/blob/ak`, 203 GB, `.hst` histories); reduce the cloud-mass histories |
| site pages (sod, sedov, kh, rm, rt, a10) | - | partly (`athenak/*` for rm, rt, a10, kh) | `luna_tests/site/ak/` (22 GB raw) not reduced |

## Gravity and cosmology

| problem | gated reference | external | missing |
|---|---|---|---|
| Maclaurin spheroid, polytrope pulsation, Jeans | exact | none | none needed |
| Evrard collapse energy | budget | `athenak/evrard/` (A8) | Arepo/Gadget Evrard energy curve not run |
| DM growth, hydro-coupled cosmology, MUSIC blocks | exact (linear growth) / self-consistency | none | no Arepo/RAMSES cosmological box stored (Arepo `cosmo_l9_dmo` snapshot only referenced by a plot script) |

## Nuclear, EOS, white dwarfs

| problem | gated reference | external here | missing |
|---|---|---|---|
| Helmholtz EOS | external | `microphysics/helmholtz_eos/`, `tables/helmholtz/` | Helmholtz table redistribution terms unknown |
| aprox13 rates, RHS, screen5, sneut5 | external | `microphysics/nuclear_rates/`, `aprox13_rhs/`, `screen5/`, `sneut5/` | none |
| He burn, CJ detonation | external | `microphysics/helium_burn/`, `detonation_cj/` | none |
| one-zone burn grid | none in LUNA | `arepo/burn_grid/` (13 and 55 species) | no LUNA test reads it yet (port of Arepo `burn_grid` planned) |
| 1D WD detonation (models A, A2) | none in LUNA | `arepo/wd_model_A/`, `arepo/wd_model_A2/`, initial star `luna/wd_initial_model/` | LUNA WD pilot stalled (cold surface cell); no test; Arepo2_WD licence unknown |
| stellar runner | LUNA-self (`luna/stellar/stellar_golden.npz`) | none | regression only by design |

## Chemistry (all references outside this repository)

| problem | gated reference | where | missing |
|---|---|---|---|
| net5 / gow17 / sympy golden | chemcool-derived golden values | `$LUNA_DATA/chemistry/chemistry_net5_golden.npz` | **Viper only**; not on Raven, not here |
| net17 golden, fixed | DVODE golden | `chemistry_net17_golden.npz`, `chemistry_net17_fixed_golden.npz` | **Viper only** |
| net17 full trajectories | DVODE rtol 1e-8 | `net17_trajectories.npz`, `net17_fixed_trajectories.npz`, `net17_tight_trajectories.npz` (Raven `$LUNA_DATA`, 20.7-21.3 MB each) | not moved: above the ~20 MB per-file limit; decide (reduce or accept size) |
| CIE cooling | golden + trajectories | `chemistry_cie_golden.npz`, `chemistry_cie_trajectories.npz` | **Viper only** (`cie_trajectories_raw.npz` 8 MB on Raven is the raw input) |
| chemistry EOS (abhe 0.079) | table | `energy_table_abhe0079_every25.npz` | **Viper only** |

The chemistry tests read these through `luna.chemistry.tables.data_path` ($LUNA_DATA), which raises when a file is
missing; they are not yet routed through `luna.reference_data`.

## Radiation

| problem | gated reference | external | missing |
|---|---|---|---|
| M1 / M2 transport, ionisation, sources | exact / self-consistency | none | Iliev et al. 2006 comparison curves (A19) not stored; M2 learned-closure weights live in LUNA (`src/luna/radiation/*.npz`, model parameters, not a reference) |
| ionisation front (Iliev 1) | open | none | see A19 |

## Not taken (exist, but superseded or raw)

- `luna_tests/a07_a08_ak/a8_*_64.npz`, `prelim/`, `cfl04/`: earlier/variant AthenaK A7/A8 reductions, superseded by `athenak/jeans_wave/`, `athenak/evrard/`.
- `luna_tests/athenak/rt/rt_ppmx_rk4_256_partial.npz`: partial, superseded by `athenak/rayleigh_taylor/rt_ppmx_rk4_512.npz`.
- `luna_tests/phase0/tg_pack_*.npz`: pack-tolerance variants of `spectral/taylor_green/tg_spectral_N128.npz`.
- `wd_research/arepo_refs/superseded_subsampled_table/`, `wd_research/wd_ic/wd_1p0_co_arepo_shells.npz` (Arepo-example shell construction, unclear provenance).
- `luna_tests/*/luna*.npz`: LUNA run outputs for docs/plots, not references.
