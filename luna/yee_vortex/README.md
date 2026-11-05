# Yee vortex: LUNA's own runs

LUNA's runs of the stationary isentropic vortex of Yee, Sandham & Djomehri (1999, JCP 150, 199, eqs. 3.1-3.2), with a
sound-wave control on the same settings, kept as data for benchmarking hydro codes. **Regression only, not an external
reference and not a truth.** The exact solution is the initial state, so the gate is exact, with a periodic-image floor
(below). An independent code's run of this problem does not exist in this repository (`GAPS.md`). No LUNA test reads these
files: `tests/test_hydro_accuracy_yee.py` computes its own error against the exact solution.

## Definition

gamma = 1.4, beta = 5, periodic box [-5, 5]^2 (LUNA's [0, 10]^2 with the vortex at the centre), t = 10, r^2 = x^2 + y^2:

    f   = exp(1 - r^2)
    T   = 1 - (gamma - 1) beta^2 / (8 gamma pi^2) f
    rho = T^(1 / (gamma - 1))
    P   = rho T
    u   = -beta / (2 pi) sqrt(f) y
    v   = +beta / (2 pi) sqrt(f) x

One vortex: each point takes its nearest image of the centre, the images are not summed. The initial state is the exact
cell average of (rho, rho u, rho v, E) by 8 x 8 Gauss-Legendre points per cell (`ic_quad = 8`), E = P / (gamma - 1) +
rho (u^2 + v^2) / 2; `ic_quad = 1` samples the cell centre. The exact solution at t = 10 is the same state, or with bulk flow
v = (1, 1) the same state translated by one box length. 3D is the extruded slab 10 x 10 x 2.5, nx x nx x nx/4 cells.

## Scheme

Unsplit PLM MUSCL-Hancock, HLLC, FP64, CFL 0.8 unless stated, the Pallas kernel, one A100 (`LIMITER` 0 minmod, 1 MC, 2 van
Leer; `ORDER=1`). `LIMITER` takes only those three values: there is no limiter-off run.

## Provenance

The runs of 2026-11-05 on ravg1002 ran from a worktree at LUNA **debcdae with the Yee work uncommitted**, not from a commit.
That work became 60cf841 at 03:48:37, after they finished; only the amp 1e-8 sound runs (job 31920134) ran at clean 60cf841.
The worktree no longer exists, so the uncommitted tree cannot be diffed against 60cf841. Instead job 31920564 reran 8 cases
from clean 60cf841 (2D nx 512 with all three limiters, 2D nx 128 minmod, 2D nx 128 MC v = (1, 1), 3D nx 128 MC at quad 8 and
1, `sound_x` nx 256 MC amp 1e-6): all 8 end states are bitwise identical to the originals, all stored norms and step counts
identical. The other cases were not rerun. Each npz carries `git_rev`, `git_dirty`, `slurm_job_ids` (end states
`slurm_job_id`), `date`, `node`, `device`, `provenance` (JSON: jobs, GPU, modules, environment, settings, run line, the
reproduction) and `driver_source` (the scratch driver over `luna.launch`, whose vortex config is LUNA's
`scripts/validation/runs/yee_vortex_run.py`). Per run: `git_rev_run`, `slurm_job_id`, `gpu_uuid`, `gpu_clock_mhz`.

| file | content |
|---|---|
| `yee_vortex_convergence.npz` | 64 vortex runs, one array entry per run: 2D nx 32..2048, 3D nx 32..256, per limiter; 2D bulk flow v = (1, 1) minmod and MC nx 32..512, 3D MC nx 32..128; 2D MC CFL 0.3 nx 64..256; 3D point-sampled IC (`ic_quad = 1`) nx 32..256 and CFL 0.3 |
| `yee_vortex_sound_control.npz` | 46 sound runs (below), norms divided by `amp` |
| `yee_vortex_end_mc_512.npz`, `yee_vortex_end_minmod_512.npz` | 2D end states at rest, nx 512: `rho`, `mx`, `my`, `E`, cell averages indexed [ix, iy], x = -5 + (i + 0.5) h, float32 |

Keys of the convergence file: `avg_<rho|v|P>_<L1|L2|Linf>` against exact cell averages (**the norms to compare**);
`pt_...` the same run against the exact solution sampled at cell centres; `field_<rho|v|P>_L1` the run as a piecewise-constant
field against the exact field, `floor_...` the exact averages against the exact field; `band_<rho|v|P>_<r_lt1|r_1_2|r_2_4|r_gt4>`
L1 per radial band (bands sum to the L1), `_r_at_max` the radius of Linf; `steps`, `cfl`, `vx`, `vy`, `gpu_seconds` (LUNA's
Total runtime), `mcells_per_s_timed`, `peak_gpu_gb` (JAX peak bytes), `z_spread`, `rho_min`, `rho_min_exact`;
`floor_table_*`, `image_*`.

Why these end states: MC and minmod bracket the behaviour (minmod asymptotic, MC not), and nx 512 is moderate, cheap to match,
and MC's rate there is still above 2. float32 because FP64 does not compress (7.1 MB per state, against 2.7-2.9 MB), and it is
enough: recomputed from the stored float32, MC norms change by at most 0.03 % (Linf; L1 0.005 %), minmod by 0.001 %. `norms_fp64`
and `norms_float32` hold both, `fp64_sha256` the FP64 array. Van Leer, other resolutions and the FP64 states (2.6 GB) are not here.

## Computing the same norms

Primitives come from the cell-averaged conserved variables on both sides, not from averaging primitives. v is the vector
norm. L1, L2, Linf are the mean, root mean square and maximum over cells of |d rho|, |d v|, |d P| (3D: first the z mean of
the plane). This recomputes the stored norms of an end state:

```python
import numpy as np
G, BETA, L, Q = 1.4, 5.0, 10.0, 8

def prim(x, y):
    f = np.exp(1 - x * x - y * y)
    T = 1 - (G - 1) * BETA**2 / (8 * G * np.pi**2) * f
    rho, w = T ** (1 / (G - 1)), BETA / (2 * np.pi) * np.sqrt(f)
    return rho, -w * y, w * x, rho * T

def exact_averages(n):
    h, (a, wt) = L / n, np.polynomial.legendre.leggauss(Q)
    c = -L / 2 + (np.arange(n) + 0.5) * h
    U = np.zeros((4, n, n))
    for ax, wx in zip(a, wt):
        for ay, wy in zip(a, wt):
            x = (c[:, None] + 0.5 * h * ax + L / 2) % L - L / 2
            y = (c[None, :] + 0.5 * h * ay + L / 2) % L - L / 2
            r, u, v, p = prim(x, y)
            U += 0.25 * wx * wy * np.stack([r, r * u, r * v, p / (G - 1) + 0.5 * r * (u * u + v * v)])
    return U

def fields(U):
    r, u, v = U[0], U[1] / U[0], U[2] / U[0]
    return r, u, v, (G - 1) * (U[3] - 0.5 * r * (u * u + v * v))

def norms(U, n):
    a, b = fields(np.asarray(U, dtype=float)), fields(exact_averages(n))
    d = dict(rho=abs(a[0] - b[0]), v=np.hypot(a[1] - b[1], a[2] - b[2]), P=abs(a[3] - b[3]))
    return {k: dict(L1=x.mean(), L2=np.sqrt((x * x).mean()), Linf=x.max()) for k, x in d.items()}

f = np.load("yee_vortex_end_mc_512.npz")
print(norms(np.stack([f["rho"], f["mx"], f["my"], f["E"]]), 512))
```

## Results at rest, 2D, cell-average IC, against exact cell averages

| limiter | nx | steps | rho L1 | order | v L1 | order | P L1 | order | rho Linf | v Linf |
|---|---|---|---|---|---|---|---|---|---|---|
| minmod | 32 | 130 | 8.547e-03 |  | 2.745e-02 |  | 1.264e-02 |  | 1.740e-01 | 2.448e-01 |
| minmod | 64 | 267 | 2.788e-03 | 1.62 | 8.058e-03 | 1.77 | 4.135e-03 | 1.61 | 4.783e-02 | 8.792e-02 |
| minmod | 128 | 540 | 7.148e-04 | 1.96 | 2.027e-03 | 1.99 | 1.052e-03 | 1.97 | 1.272e-02 | 2.739e-02 |
| minmod | 256 | 1084 | 1.759e-04 | 2.02 | 5.048e-04 | 2.01 | 2.588e-04 | 2.02 | 3.558e-03 | 8.454e-03 |
| minmod | 512 | 2171 | 4.327e-05 | 2.02 | 1.254e-04 | 2.01 | 6.377e-05 | 2.02 | 9.573e-04 | 2.510e-03 |
| minmod | 1024 | 4343 | 1.072e-05 | 2.01 | 3.127e-05 | 2.00 | 1.582e-05 | 2.01 | 2.486e-04 | 7.106e-04 |
| minmod | 2048 | 8685 | 2.668e-06 | 2.01 | 7.805e-06 | 2.00 | 3.938e-06 | 2.01 | 6.384e-05 | 1.936e-04 |
| MC | 32 | 133 | 3.816e-03 |  | 1.162e-02 |  | 5.887e-03 |  | 9.085e-02 | 1.326e-01 |
| MC | 64 | 270 | 5.653e-04 | 2.75 | 1.696e-03 | 2.78 | 8.753e-04 | 2.75 | 1.320e-02 | 2.288e-02 |
| MC | 128 | 543 | 8.678e-05 | 2.70 | 2.719e-04 | 2.64 | 1.254e-04 | 2.80 | 2.279e-03 | 4.667e-03 |
| MC | 256 | 1086 | 1.503e-05 | 2.53 | 4.823e-05 | 2.49 | 2.100e-05 | 2.58 | 3.542e-04 | 1.226e-03 |
| MC | 512 | 2172 | 2.641e-06 | 2.51 | 9.323e-06 | 2.37 | 3.766e-06 | 2.48 | 4.725e-05 | 2.733e-04 |
| MC | 1024 | 4343 | 5.610e-07 | 2.24 | 2.148e-06 | 2.12 | 7.886e-07 | 2.26 | 1.087e-05 | 1.026e-04 |
| MC | 2048 | 8686 | 1.308e-07 | 2.10 | 4.867e-07 | 2.14 | 1.806e-07 | 2.13 | 2.755e-06 | 1.197e-05 |
| vanLeer | 32 | 132 | 4.884e-03 |  | 1.306e-02 |  | 7.434e-03 |  | 1.072e-01 | 1.576e-01 |
| vanLeer | 64 | 270 | 8.900e-04 | 2.46 | 2.168e-03 | 2.59 | 1.346e-03 | 2.47 | 1.666e-02 | 3.533e-02 |
| vanLeer | 128 | 542 | 1.285e-04 | 2.79 | 3.432e-04 | 2.66 | 1.874e-04 | 2.84 | 3.240e-03 | 7.905e-03 |
| vanLeer | 256 | 1086 | 1.996e-05 | 2.69 | 6.534e-05 | 2.39 | 2.831e-05 | 2.73 | 5.619e-04 | 1.939e-03 |
| vanLeer | 512 | 2172 | 3.281e-06 | 2.60 | 1.238e-05 | 2.40 | 4.686e-06 | 2.59 | 8.848e-05 | 4.427e-04 |
| vanLeer | 1024 | 4343 | 6.377e-07 | 2.36 | 2.611e-06 | 2.25 | 8.991e-07 | 2.38 | 1.334e-05 | 9.180e-05 |
| vanLeer | 2048 | 8686 | 1.393e-07 | 2.19 | 5.572e-07 | 2.23 | 1.932e-07 | 2.22 | 2.702e-06 | 1.846e-05 |

The 3D slab's rho L1 is within 1.2 % of 2D at every nx (`z_spread` <= 4.4e-16), at about 1.34 times the steps. Bulk flow v = (1, 1)
at nx 512: rho L1 1.85 times the rest value with minmod, 4.1 times with MC.

## Caveats

- **MC and van Leer are not asymptotic, even at nx 2048.** Their rho L1 order falls from about 2.7 towards 2 and is still 2.10 and
  2.19 at 1024 -> 2048, in L2 2.16 and 2.34. MC's v Linf goes 2.733e-04, 1.026e-04, 1.197e-05 at nx 512, 1024, 2048, orders 1.41
  then 3.10. A rate above 2 here is not a higher-order scheme: the slopes are limited in a shrinking set of cells (MC, rho
  along x, at nx 256..2048: the limiter changes the central slope in 6.2, 3.7, 2.4, 1.4 % of the cells with a nonzero slope). Minmod holds 2.00-2.02 in L1 from nx 128.
  Compare codes at matching nx, not by extrapolated rates.
- **A piecewise-constant field norm has an O(h) floor.** L1 of a cell-constant field against the continuous exact field cannot
  go below the same norm for the exact averages, whatever the scheme. It is the table below: first order, and from nx 128 on it
  hides MC's error completely (`field_rho_L1` at nx 2048 is 3.295e-05, the floor sampled the same way 3.288e-05, the cell-average
  norm 1.308e-07). Compare cell averages against cell averages. `field_*` and `floor_*` were sampled on a 4096^2 grid, only 2
  subcells per cell at nx 2048, where they read 7 % low and 1.6 % at 1024; `floor_table_*_fine` is the same quantity with 8
  to 256 subcells per axis, from the exact formula alone.
- **Point sampling.** `pt_*` compares a run to centre values, so it adds the O(h^2) difference between averages and centre
  values (MC rho L1 at nx 2048: 1.750e-07 against 1.308e-07). It is labelled, not a second measure of the scheme.
- **Periodic images.** The formula is one vortex in a periodic box, so it is not an exact periodic solution. At r = 5, |v| =
  2.4e-5 and 1 - rho = 8.5e-12, and the velocity jumps across the box faces. Summing the neighbouring images (+-2 boxes) adds,
  over the box, |v| mean 5.0e-7, rms 2.1e-6, max 2.4e-5 and |d rho| mean 5.9e-14, max 8.3e-12 (`image_*`). So rho is far from this
  limit, while v L1 at nx 2048 (MC 4.87e-07, van Leer 5.57e-07) is at the size of the neglected images: treat v norms
  there as the end of what this exact solution can gate. The floor is not visibly reached yet: at MC nx 2048 the strip
  max(|x|, |y|) > 4.75 (9.75 % of the box) holds 3.8 % of the v L1, with a largest error of 9.5e-7 against centre values, and r > 4 (50 % of
  the box) holds 25 %. These are one solver's numbers: the face layer has no normal flow, which HLLC should hold, so a
  more diffusive solver may meet the floor earlier (expected, not measured).
- **No limiter-off run**, so limiter clipping cannot be separated from the scheme's own error here. The sound control is the nearest thing.
- **Timing is not a benchmark.** `gpu_seconds` includes compilation and these are single runs. The 60cf841 rerun of 2D nx 128 minmod took 10.92 s against
  3.44 s for the same steps. Below nx 1024 the column says little. GPUs ran at 1095 or 1305 MHz by device (`gpu_clock_mhz`), and
  this node has shown a slow mode in other LUNA runs. At nx 2048 the 2D rate was 1230-1409 M cells/s.

## O(h) floor of a piecewise-constant field (L1, exact averages against the exact field)

| nx | rho, 4096^2 sampling | rho, fine | v, fine | P, fine | rho L1, MC, cell averages |
|---|---|---|---|---|---|
| 32 | 2.277e-03 | 2.277e-03 | 1.270e-02 | 2.928e-03 | 3.816e-03 |
| 64 | 1.139e-03 | 1.139e-03 | 6.360e-03 | 1.466e-03 | 5.653e-04 |
| 128 | 5.692e-04 | 5.693e-04 | 3.181e-03 | 7.330e-04 | 8.678e-05 |
| 256 | 2.843e-04 | 2.846e-04 | 1.590e-03 | 3.664e-04 | 1.503e-05 |
| 512 | 1.415e-04 | 1.421e-04 | 7.943e-04 | 1.830e-04 | 2.641e-06 |
| 1024 | 6.965e-05 | 7.077e-05 | 3.955e-04 | 9.112e-05 | 5.610e-07 |
| 2048 | 3.288e-05 | 3.538e-05 | 1.977e-04 | 4.556e-05 | 1.308e-07 |

## Sound-wave control

Same box, gamma, solver, kernel, CFL 0.8 and limiters: a right-going linear eigenmode on rho = 1, P = 1/gamma (c = 1), one period,
`sound_x` k = 2 pi/10 (1, 0), t = 10; `sound_diag` k = 2 pi/10 (1, 1), t = 7.07. rho = 1 + s, P = 1/gamma + s, v = s k/|k|, with s = amp
sin(k.x) times the sinc factors that make it the exact cell average to O(amp^2). Norms are divided by `amp`. `amp` 1e-6: all
limiters nx 32..1024. `amp` 1e-8: MC nx 512..2048 both waves, minmod and van Leer `sound_x` nx 1024, 2048.

The control is clean at amp 1e-8. A smooth problem with the same settings gives L1 order 1.9-2.3 (MC
above 2, as for the vortex) and Linf order 1.3-1.6, the clipping at extrema. Use amp 1e-8 for MC at nx >= 1024: at 1e-6
the reference's own O(amp) error (in these units) sets in, MC `sound_x` nx 1024 rho L1 6.149e-06 against 5.062e-06, and the orders drop
to 1.97 and 1.84. At amp 1e-8, nx 2048, rho L1 sits above v and P (MC `sound_x` 1.362e-06 against 1.10e-06, 2.6e-15 absolute,
about 12 ulp of rho = 1); taken as accumulated round-off, not proven, so read the order from v or P there.

| wave | limiter | amp | nx | rho L1 | v L1 | P L1 | order (v L1) | rho Linf |
|---|---|---|---|---|---|---|---|---|
| sound_x | minmod | 1e-06 | 512 | 2.525e-04 | 2.525e-04 | 2.525e-04 |  | 2.821e-03 |
| sound_x | minmod | 1e-06 | 1024 | 6.644e-05 | 6.644e-05 | 6.644e-05 | 1.93 | 1.136e-03 |
| sound_x | minmod | 1e-08 | 1024 | 6.640e-05 | 6.642e-05 | 6.641e-05 |  | 1.136e-03 |
| sound_x | minmod | 1e-08 | 2048 | 1.729e-05 | 1.725e-05 | 1.726e-05 | 1.94 | 4.573e-04 |
| sound_x | MC | 1e-06 | 512 | 2.417e-05 | 2.417e-05 | 2.417e-05 |  | 5.279e-04 |
| sound_x | MC | 1e-06 | 1024 | 6.149e-06 | 6.149e-06 | 6.149e-06 | 1.97 | 1.710e-04 |
| sound_x | MC | 1e-08 | 512 | 2.399e-05 | 2.400e-05 | 2.399e-05 |  | 5.224e-04 |
| sound_x | MC | 1e-08 | 1024 | 5.062e-06 | 5.040e-06 | 5.043e-06 | 2.25 | 1.711e-04 |
| sound_x | MC | 1e-08 | 2048 | 1.362e-06 | 1.103e-06 | 1.108e-06 | 2.19 | 5.597e-05 |
| sound_x | vanLeer | 1e-06 | 512 | 5.404e-05 | 5.404e-05 | 5.404e-05 |  | 1.054e-03 |
| sound_x | vanLeer | 1e-06 | 1024 | 1.313e-05 | 1.313e-05 | 1.313e-05 | 2.04 | 3.852e-04 |
| sound_x | vanLeer | 1e-08 | 1024 | 1.213e-05 | 1.212e-05 | 1.213e-05 |  | 3.856e-04 |
| sound_x | vanLeer | 1e-08 | 2048 | 2.896e-06 | 2.721e-06 | 2.722e-06 | 2.16 | 1.400e-04 |
| sound_diag | minmod | 1e-06 | 512 | 2.059e-04 | 2.062e-04 | 2.059e-04 |  | 2.461e-03 |
| sound_diag | minmod | 1e-06 | 1024 | 5.409e-05 | 5.415e-05 | 5.409e-05 | 1.93 | 9.921e-04 |
| sound_diag | MC | 1e-06 | 512 | 1.885e-05 | 1.894e-05 | 1.885e-05 |  | 3.090e-04 |
| sound_diag | MC | 1e-06 | 1024 | 5.281e-06 | 5.300e-06 | 5.281e-06 | 1.84 | 1.095e-04 |
| sound_diag | MC | 1e-08 | 512 | 1.883e-05 | 1.893e-05 | 1.884e-05 |  | 3.096e-04 |
| sound_diag | MC | 1e-08 | 1024 | 4.491e-06 | 4.509e-06 | 4.494e-06 | 2.07 | 1.094e-04 |
| sound_diag | MC | 1e-08 | 2048 | 1.224e-06 | 1.092e-06 | 1.097e-06 | 2.05 | 4.556e-05 |
| sound_diag | vanLeer | 1e-06 | 512 | 4.606e-05 | 4.630e-05 | 4.606e-05 |  | 9.065e-04 |
| sound_diag | vanLeer | 1e-06 | 1024 | 1.131e-05 | 1.134e-05 | 1.131e-05 | 2.03 | 3.314e-04 |

