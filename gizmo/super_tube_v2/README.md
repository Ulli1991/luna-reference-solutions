# Super-hard 1D tube v2: GIZMO MFM and MFV on four branches (t = 0.1)

GIZMO runs of luna-cpp's super-hard 1D tube v2 (luna-cpp `research_notes/super_tube_v2_2026-11-18.md`; LUNA's and luna-cpp's runs in
`luna/super_tube_v2/` and `luna-cpp/super_tube_v2/`), for comparison. An independent code's run, not a truth.

**The m0 tube.** GIZMO cannot hold stage M: the Mach 1e4 stream leaves through the open wall at x = 0, and GIZMO has no open wall
(its stand-in, ambient gas beyond x = 0, stops the stream in a shock that runs back into the tube). These runs are of `super-tube-v2-m0`,
v2 with stage M's stream and bump replaced by the ambient gas (`problems_1d.super2_initial(..., m0=True)`), as luna-cpp's moving mesh;
stages A to H are the same as in v2 at t = 0.1.

## Branches and builds

| directory | branch, commit | build |
|---|---|---|
| `starforge_dev/` | starforge_dev 770ad72 (2026-11-18) | classic layout; no Raven machine block, so gcc 14 / OpenMPI 4 settings on the make command line (`-O3 -march=icelake-server`) |
| `stella_dev/` | stella_dev caf944d (2026-11-18) | classic layout; the branch's own `Raven-OpenMPI` block (`-O3 -march=native`) |
| `gku_stella_dev/` | gku_stella_dev b45666c (2026-11-18) | Kokkos layout (`src/`), Kokkos 4.6.01 OpenMP on CPU (`Lonestar6_CPU` block, Raven paths, `-O2 -march=icelake-server`) |
| `gpu_kokkos_unified/` | gpu_kokkos_unified b5f4503 (2026-11-18) | as gku_stella_dev |
| `gpu_kokkos_unified_gpu/` | gpu_kokkos_unified b5f4503 | Kokkos 4.6.01 CUDA, sm_80 (`Lonestar6` block, Raven paths, cuda/12.8), one A100, one rank; N = 4096 only |

All unmodified; config and parameters as for v1 (`gizmo/super_tube/README.md`: MFM or MFV, `FORCE_EQUAL_TIMESTEPS`, CourantFac 0.2,
DesNumNgb 4, MaxNumNgbDeviation 0.01; mirror wall with ambient pads). CPU runs on Raven Xeon 8360Y with 2 (N = 4096) or 15 (N = 32768)
MPI ranks. The A100 runs at N = 32768 were stopped by their 6 h limit (MFM at t = 0.079 of v1 and 0.086 of m0, 2.8 steps per second,
against 10 per second on 15 CPU cores) and are not stored.

## What the branches give (L1 of rho over stages A to H, t = 0.1)

| N | MFM, all four branches | MFV starforge_dev, stella_dev | MFV gku_stella_dev | MFV gpu_kokkos_unified |
|---|---|---|---|---|
| 4096 | 1.82 | 2.02 | 1.58 | 1.59 |
| 32768 | 0.265 to 0.266 | 0.892 | 0.221 | 0.221 |

- MFM is the same on all four branches to the digits shown, per stage too.
- MFV on the two classic branches (starforge_dev, stella_dev, identical to each other) loses total energy: -21 of 1329 by t = 0.1 at both
  N, and mass by -5e-5 (4096) and -1e-5 (32768); its errors in stages S and H are 4 to 10 times the Kokkos branches' at 32768. The Kokkos
  branches keep energy within 0.4 and mass to 1e-12. This is the MFV non-conservation of the earlier gizmo-cpp branch.
- gpu_kokkos_unified at b5f4503 (with "MFV: the faces of a pair move with the mesh-generating points, not with the fluid") and
  gku_stella_dev at b45666c differ in MFV by up to about 15 % per stage; MFM is the same.
- The A100 and the CPU (2 ranks) give the same steps and states to about 1e-10 relative (largest |delta rho| 6.6e-10).

Keys: as `gizmo/super_tube/README.md`; `branch`, `commit` per file; `l1_<stage>` per v2 stage (M absent).
