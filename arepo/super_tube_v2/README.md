# Super-hard 1D tube v2: Arepo (t = 0.1)

Arepo runs of luna-cpp's super-hard 1D tube v2 (luna-cpp `research_notes/super_tube_v2_2026-11-18.md`), the version, configuration
and walls of `arepo/super_tube/README.md` (developers' master e6227faf, exact Riemann solver, CourantFac 0.4 with the pair term, global
step, the line and its mirror image), at N = 4096 and 32768 to t = 0.1. An independent code's run, not a truth.

**Stage M breaks Arepo.** With the full v2 the run stops at once: the end cell of the Mach 1e4 stream at the open wall (ID 1) gets a
time step of 4e-19 and Arepo terminates ("time-step of integer size 1 not allowed") at t = 0.00125 (N = 4096, 459 steps) and
t = 0.00016 (N = 32768, 447 steps). No state of the full v2 is stored. The stored runs are of `super-tube-v2-m0`, v2 with stage M's
stream replaced by the ambient gas, as luna-cpp's moving mesh and GIZMO.

At t = 0.1 (m0), L1 of rho over stages A to H: 1.03 (N = 4096) and 0.167 (N = 32768); mass and energy kept to 1e-12; 6657 and 63,013
steps, 146 s and 14,960 s on one core.

Keys: as `arepo/super_tube/README.md`; `l1_<stage>` per v2 stage (M absent).
