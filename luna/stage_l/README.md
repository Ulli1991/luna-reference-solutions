# Stage L alone: LUNA's runs

Stage L of luna-cpp's super-hard tube v2, alone: one Riemann problem, (rho, v, P) = (1, 0, 0.1) next to (r, 0, 1e-7 r) at x = 0 on
[-2, 9], gamma = 1.4, open walls, to t = 4, for r = 1e-3, 1e-6, 1e-9 (problems `stage-l-3`, `-6`, `-9` of luna-cpp `problems_1d.hpp`,
branch stage-l; research_notes/stage_l_2026-11-19.md). Its waves stay within [-1.50, 8.21] to t = 4, so the exact solution holds at every
time (luna-cpp `scripts/stage_l.py`, the bisection solver of `problems_1d.riemann`). **Regression only, not external.**

LUNA 60cf841 (main; uncommitted: `docs/history/CODE_NOTES.md` only), jax 0.10.1, MUSCL-Hancock, HLLC, MC (`LIMITER=1`), CFL 0.8, FP64,
positivity floors on (`preserve_face_states`, smallr = smallc = 1e-10), CPU, one thread; driver luna-cpp `scripts/luna_1d_run.py floor=1`.

Files: `stage_l_<k>_luna_<N>_t4.npz`, k = 3, 6, 9 (density ratio 1e<k>), N = 1024 to 32768. Keys: x_left, x_right, rho, u, p, t, n_run,
density_ratio and provenance.
