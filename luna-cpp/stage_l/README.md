# Stage L alone: luna-cpp's runs

The problem is in `luna/stage_l/README.md`. **Regression only, not external.**

luna-cpp branch stage-l (from main 283fee3), voronoi-cpp 1741a1a (extern pin), MUSCL-Hancock, HLLC, face-centroid MC limiter, FP64.
Static: LUNA's time-step rule at Courant 0.8. Moving: AREPO's rule at Courant 0.4. OpenMP one core (N <= 4096) or CUDA one A100 (moving,
N >= 8192), the npz key `backend`.

Files: `stage_l_<k>_<series>_<N>_t<t>.npz`, series static or moving, t the last time the run reached:
- static: t = 4 for every ratio and N;
- moving, ratios 1e3 and 1e6: t = 4 for every N;
- moving, ratio 1e9: N = 1024 stops at t = 0.015 (the near-vacuum gas at the open right wall is heated and driven out at u = 1500;
  stored: none); N = 2048 to 32768 stop at t = 3.7 to 3.9 at that wall (luna-cpp #14); stored: the last snapshot, t = 3.5.

Keys: x_left, x_right (the cells), rho, u, p, t, reached, steps, n_run, density_ratio and provenance.
