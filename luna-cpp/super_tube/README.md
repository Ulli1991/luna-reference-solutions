# Super-hard 1D tube: luna-cpp's runs

luna-cpp's runs of its super-hard 1D tube (definition: `../../luna/super_tube/README.md`), static and moving mesh, at
N = 4096 and 32768 initial cells, t = 0.1 and t = 2. **Not a truth and not an external reference**: a record of what this code
gives, for comparison. The static runs equal LUNA's MC runs at the same N to rounding (1e-10 at N = 4096, t = 0.1).

## Runs

luna-cpp eb972bd (branch super-tube-run, on fix-23 a46f384), voronoi-cpp 2c8c509 (the `extern/voronoi-cpp` pin), driver
`src/bench/hydro_1d.cpp super-tube <N> --t-end=<t> [--moving]`. MUSCL-Hancock, HLLC, face-centroid MC limiter, FP64.

- static: LUNA's time-step rule, Courant 0.8; OpenMP build (gcc 15.1, Kokkos 5.0.99, -march=icelake-server), one core of a
  Xeon Platinum 8360Y.
- moving (1D Voronoi mesh): AREPO's rule, Courant 0.4. N = 4096 on one core as above; N = 32768 on one A100 (CUDA 13.0 build).
  Keys `x_left`, `x_right` give the cells.

The moving mesh does not reach t = 2 (luna-cpp issue #25): cells collapse at stage E's contact from t of about 0.12; at
N = 4096 the step falls to about 1e-8 and the run stands at t = 0.1416 after 7.5 million steps, at N = 32768 at t = 0.1343 after
8.0 million steps. No moving file at t = 2.

Keys as `luna/shu_osher/shu_osher_mc.npz` (`rho`, `u`, `p`, `problem`, `lx`, `t`, `gamma`, `limiter`, `riemann_solver`,
`precision`, `n_run`) plus code, repository, commit, branch, voronoi_cpp, build, backend, mesh, time_step, steps, wall_s.
