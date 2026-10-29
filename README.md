# luna-reference-solutions

Reference solutions that the LUNA hydrodynamics code (github.com/Ulli1991/LUNA) is compared against, one directory
per code, then per problem. LUNA itself holds code only; its tests and tools find this repository through
`luna.reference_data.reference_path("<code>/<problem>/<file>")`, which checks every file's sha256 against
`MANIFEST.json` and fails (never skips) when the repository or a file is missing or altered.

Where LUNA looks: `$LUNA_REFERENCE_SOLUTIONS`, else a sibling checkout `../luna-reference-solutions` next to the
LUNA repository, else `~/luna-reference-solutions`.

## Layout

    <source-code>/<problem>/<file>

| directory | what | external? |
|---|---|---|
| `athenak/` | AthenaK runs from LUNA's ICs, reduced with LUNA's test metrics (`athenak/README.md` has the full provenance) | external code |
| `arepo/` | Arepo: A16 comoving cross-check (public Arepo); WD models A/A2 and the burn grid (Arepo2_WD branch) | external code |
| `ramses/` | mini-ramses: A16 comoving cross-check | external code |
| `microphysics/` | AMReX-Astro Microphysics 99b9b47 outputs (Helmholtz EOS, burns, CJ detonation, aprox13 RHS, screen5, sneut5, rates) | external code |
| `pencil/` | McNally, Lyra & Passy (2012) Pencil Code curves, digitised from the paper's figures | external (published) |
| `spectral/` | pseudo-spectral Taylor-Green runs (euler3d, the LUNA author's spectral code) | independent code |
| `tables/` | input table subsets (Timmes-Swesty Helmholtz table, the nodes the references touch) | external table |
| `luna/` | **LUNA's own high-resolution / frozen outputs: regression only, not external.** A pass against these says LUNA did not change, not that it is right | LUNA |

## Provenance and licences

`MANIFEST.json` lists every file: path, sha256, size, source code + version/commit, how it was produced
(script, SLURM job where known), problem, the LUNA tests/tools that read it, and a licence / redistribution
note **per file**. Where the redistribution terms are not established the note says `unknown`; resolve those
before making this repository public. Most npz files also carry their own provenance keys
(`provenance`, `git_rev`, `readme`, `arepo_commit`, ...).

Files are stored byte-identical to the originals (copied from LUNA `tests/data/` at 2763e7f and from
`/ptmp/uli/jax-hydro/luna_tests/wd_research/` on Raven, 2026-10-30).

## Changing a file

Add or replace the file, extend the matching rule in `make_manifest.sh` (an unmatched file stops the script),
run `bash make_manifest.sh`, commit both. A LUNA test then fails on the sha256 until the manifest is committed.

## Not here

Chemistry golden values and DVODE trajectories (`$LUNA_DATA/chemistry/chemistry_*_golden.npz`,
`chemistry_cie_trajectories.npz`, `energy_table_abhe0079_every25.npz`) exist only on Viper; the net17
trajectories (`net17*_trajectories.npz`, ~20 MB each) are on Raven's `$LUNA_DATA` but not moved yet.
