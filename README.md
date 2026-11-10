# luna-reference-solutions

Cite: [`CITATION.cff`](CITATION.cff) (Zenodo DOI after the first release). Code: [LUNA](https://github.com/Ulli1991/LUNA), DOI [10.5281/zenodo.23874689](https://doi.org/10.5281/zenodo.23874689).

Reference solutions for the test suite of the LUNA astrophysical hydrodynamics code. The repository collects what
LUNA's tests are checked against, each file with its sha256, source code and version, how it was produced, the
LUNA tests that read it and its licence terms in MANIFEST.json. Provided are: AthenaK runs from LUNA's initial
conditions at high resolution (PPMX/RK4 and PLM), reduced to the tests' metrics, for shock tubes (Shu-Osher,
Titarev-Toro, Woodward-Colella), 2D Riemann problems and the Liska-Wendroff implosion, Kelvin-Helmholtz (McNally
et al. 2012), Rayleigh-Taylor and Richtmyer-Meshkov instabilities, the Gresho vortex, sound and Jeans waves, an
isothermal atmosphere, Taylor-Green and the Evrard collapse; Arepo and mini-RAMSES runs of comoving expansion and
top-hat collapse, and Arepo white-dwarf models and one-zone nuclear burns; AMReX Microphysics outputs (Helmholtz
equation of state, aprox13 rates and right-hand side, screening, neutrino losses, helium burning, Chapman-Jouguet
detonations); pseudo-spectral Taylor-Green runs and published Brachet et al. (1983) data; Pencil Code curves
digitised from McNally et al. (2012); JAX-AMR parity outputs; a subset of the Timmes-Swesty Helmholtz table; and
LUNA's own high-resolution outputs, which serve as regression references only.

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
| `luna-cpp/` | luna-cpp's runs (the LUNA author's C++ moving-mesh hydro, github.com/Ulli1991/luna-cpp): a record for comparison, not a truth (`luna-cpp/super_tube/README.md`) | luna-cpp |
| `luna/` | **LUNA's own high-resolution / frozen outputs: regression only, not external.** A pass against these says LUNA did not change, not that it is right (`luna/yee_vortex/README.md` for the Yee vortex data) | LUNA |

## Provenance and licences

`MANIFEST.json` lists every file: path, sha256, size, source code + version/commit, how it was produced
(script, SLURM job where known), problem, the LUNA tests/tools that read it, and a licence / redistribution
note **per file**. The repository is licensed CC-BY-4.0 (`LICENSE`; cite it via `CITATION.cff`); where a
file's note in MANIFEST.json gives other terms (third-party data, published figures, other codes' tables), those
take precedence. Notes that say `unknown` mark terms not yet established. Most npz files also carry their own provenance keys
(`provenance`, `git_rev`, `readme`, `arepo_commit`, ...).

Data files are byte-identical to the originals (copied from LUNA `tests/data/` at 2763e7f, from
`/ptmp/uli/jax-hydro/luna_tests/wd_research/`, `phase0/` and `a15_ext/lit/` on Raven, 2026-10-30); only
`athenak/README.md` had its `tests/data/...` paths rewritten to this layout. `luna/yee_vortex/` was made here after v1.0, from runs of
2026-11-05; its end states are FP64 runs stored as float32 (`luna/yee_vortex/README.md`).

## Changing a file

Add or replace the file, extend the matching rule in `make_manifest.sh` (an unmatched file stops the script),
run `bash make_manifest.sh`, commit both. A LUNA test then fails on the sha256 until the manifest is committed.

## Gaps

`GAPS.md`: per validation problem, which reference exists (exact, external, literature, LUNA-self, none) and what is missing to gate it against an independent code.

## Not here

Chemistry golden values and DVODE trajectories (`$LUNA_DATA/chemistry/chemistry_*_golden.npz`,
`chemistry_cie_trajectories.npz`, `energy_table_abhe0079_every25.npz`) exist only on Viper; the net17
trajectories (`net17*_trajectories.npz`, ~20 MB each) are on Raven's `$LUNA_DATA` but not moved yet.
