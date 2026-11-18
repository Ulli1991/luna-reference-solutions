# Super-hard 1D tube v2: luna-cpp's runs

luna-cpp's runs of its super-hard 1D tube v2 (`research_notes/super_tube_v2_2026-11-18.md`, branch super-tube-v2 df7f5ca; the definition
is in `luna/super_tube_v2/README.md`). **Regression only, not external.**

## Runs

luna-cpp df7f5ca, voronoi-cpp 6ead543 (extern pin), MUSCL-Hancock, HLLC, face-centroid MC limiter, FP64. Static: LUNA's time-step rule
at Courant 0.8 (LUNA's scheme; at t = 0.1 the same as LUNA to the digits shown in the note). Moving: AREPO's rule at Courant 0.4.
OpenMP one core (gcc 15, Xeon 8360Y) or CUDA one A100 (gcc 14, CUDA 13.0), the npz key `backend`.

- `super_tube_v2_static_{4096,32768}_t{0.1,4}.npz`.
- `super_tube_v2_static_{524288,1048576}_t4.npz`: A100, stored as conservative averages on 2^17 cells. They check LUNA's 2^20 reference,
  which LUNA cannot check itself (LUNA at 2^19 goes NaN). 2^19 lies within 3.5e-2 of LUNA 2^20 in L1(rho) in every stage, and 2^20
  within 1e-3.
- `super_tube_v2_m0_*`: the diagnostic `super-tube-v2-m0`, stage M's stream replaced by the ambient gas. On the moving mesh stage M stops
  the run at once (luna-cpp #14), or the state turns NaN and the run reports t_end (#29); none of those states is stored. m0 lets the moving
  mesh run the other stages. By t = 4 stage M changes only the regions of M, A, B and C (static 32768, v2 against m0: from C2 on equal to
  1e-12).
- `super_v2_<stage>_{static,moving}_<cells>_t0.1.npz`: the new stages alone (M, L, SO, N, V), open walls, at the spacing of N = 4096 and
  8 times as many cells (moving M stops in 2-3 steps: none stored).
- `ic/super_tube_v2[_m0]_ic_{4096,32768}.npz`: initial cells for other codes (AREPO, GIZMO): x_left, x_right, x, rho, v, P (primitives of
  the exact cell averages) and the cell totals of mass, momentum and total energy, with gamma, walls, segments and the smooth parts as
  metadata (luna-cpp `scripts/super_tube_v2.py ic`).

Keys: `rho`, `u`, `p` (moving runs also `x_left`, `x_right`), problem, series, mesh, t, steps, wall time, reached, commit, build,
backend, time_step.
