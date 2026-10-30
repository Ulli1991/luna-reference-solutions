#!/bin/bash
# Regenerate MANIFEST.json from the files on disk and the per-path provenance below: bash make_manifest.sh
# Every data file must match one case; an unmatched file stops the script (no silent "unknown" rows).
set -euo pipefail
cd "$(dirname "$0")"

AK_LIC="AthenaK is BSD-3-Clause; these are the LUNA author's own AthenaK runs, reduced; no third-party data terms known"
AK_VER="AthenaK 886dd2a + branch luna_ic (6f269fe4, c0d1427d, c52f88f0), binary build_gpu_lunaic sha256 e40b2abd...877b; per-run commits, binary, SLURM job, node and GPU in the npz key 'provenance'; see athenak/README.md"
AK_VER_MG="AthenaK branch luna_ic_mg 7f1c7989 (upstream c5a0d7f9 + luna_ic), binary build_gpu_lunaic_mg sha256 fd151e3a...97f2 (self-gravity); see athenak/README.md and the npz key 'provenance'"
AK_HOW="AthenaK runs from LUNA's ICs (pgen luna_ic, LUNA tools/athenak/), reduced with LUNA's test metrics by LUNA tools/athenak_refs.py reduce; Raven A100, FP64, HLLC"
AK_TOOLS="tools/athenak_refs.py;tools/athenak_summary.py"
AK_HOW_TUBE="AthenaK runs from LUNA's test ICs (pgen luna_ic; LUNA tools/athenak_refs.py prep so|tt), the tests' N run 2026-10-15 for the site pages (luna_tests/site/ak), the PPMX reference and its half-N run 2026-10-30 (luna_tests/phase_b/ak, SLURM 31699054-31699056); reduced by LUNA tools/athenak_refs.py reduce so|tt (final rho per N, L1/L2 against the PPMX reference and LUNA's MC 2^16); Raven A100, FP64, HLLC, CFL 0.4, dfloor = pfloor = 1e-8"
LUNA_LIC="LUNA's own output (BSD-3-Clause, as LUNA)"
MP_VER="AMReX-Astro/Microphysics@99b9b47cdb6d0d459deefeacdd4d78639bbd5f93 (key 'source' in the JSON)"
MP_HOW="compiled and run outside LUNA from Microphysics sources (LUNA tools/helmholtz_reference.py and the 'source'/'inputs' keys in the JSON)"
MP_LIC="Microphysics is BSD-3-Clause; the underlying Timmes routines / rate fits: terms unknown"
WD_LIC="unknown: Arepo2_WD is a non-public Arepo branch (public Arepo is GPL-3.0); data are the LUNA author's own runs; ask the branch owners before publishing"
WD_VER="Arepo branch Arepo2_WD def96e2ab9d59d3f37acea81f5829b4e45b7cec9 (npz keys arepo_commit, Config_sh, param_txt)"

meta() {   # path -> code|version|produced_by|problem|used_by(;-separated)|licence
  local p=$1 b; b=$(basename "$p")
  case $p in
    athenak/README.md) echo "athenak|see file|hand-written provenance of the AthenaK references (moved from LUNA tests/data/athenak/README.md)|all athenak problems|$AK_TOOLS|$AK_LIC";;
    athenak/jeans_wave/*) echo "athenak|$AK_VER_MG|$AK_HOW|jeans_wave (A7)|$AK_TOOLS|$AK_LIC";;
    athenak/evrard/*) echo "athenak|$AK_VER_MG|$AK_HOW|evrard (A8)|tools/site_data.py;$AK_TOOLS|$AK_LIC";;
    athenak/richtmyer_meshkov/*) echo "athenak|$AK_VER|$AK_HOW|richtmyer_meshkov (A14)|tests/test_hydro_hard_richtmyer_meshkov.py;tools/site_data.py;$AK_TOOLS|$AK_LIC";;
    athenak/taylor_green/tg_ppmx_rk4_reeff.npz) echo "athenak|AthenaK c52f88f0 (binary build_gpu_lunaic), LUNA 61c23351; npz key provenance|LUNA tools/athenak_refs.py reduce tg, SLURM 31083046 (luna_tests/phase0/report.md): Re_eff, D per N|taylor_green (A15 Re_eff)|none (tabulated in docs/TEST_PLAN.md)|$AK_LIC";;
    athenak/taylor_green/*) echo "athenak|$AK_VER|$AK_HOW|taylor_green (A15)|tools/site_data.py;$AK_TOOLS|$AK_LIC";;
    athenak/mcnally_kh/*)
      echo "athenak|$AK_VER|$AK_HOW|$(dirname "${p#athenak/}") (A5)|tests/test_hydro_hard_mcnally_kh.py;tools/site_data.py;$AK_TOOLS|$AK_LIC";;
    athenak/woodward_colella/*) echo "athenak|$AK_VER|$AK_HOW|woodward_colella (A9)|tests/test_hydro_hard_woodward_colella.py;$AK_TOOLS|$AK_LIC";;
    athenak/lw_implosion/*) echo "athenak|$AK_VER|$AK_HOW|lw_implosion (A10)|tests/test_hydro_hard_implosion.py;$AK_TOOLS|$AK_LIC";;
    athenak/kt_riemann/*) echo "athenak|$AK_VER|$AK_HOW|kt_riemann (A11)|tests/test_hydro_hard_kt_riemann.py;$AK_TOOLS|$AK_LIC";;
    athenak/shu_osher/*) echo "athenak|$AK_VER|$AK_HOW_TUBE|shu_osher|tests/test_hydro_hard_shu_osher.py;tools/athenak_refs.py|$AK_LIC";;
    athenak/titarev_toro/*) echo "athenak|$AK_VER|$AK_HOW_TUBE|titarev_toro|tests/test_hydro_hard_titarev_toro.py;tools/athenak_refs.py|$AK_LIC";;
    athenak/*) echo "athenak|$AK_VER|$AK_HOW|$(dirname "${p#athenak/}")|$AK_TOOLS|$AK_LIC";;
    arepo/cosmo_a16_xcheck/*) echo "arepo|Arepo public 1fc135a (Raven, Intel 19.1.2, IMPI 2019.8, DOUBLEPRECISION=1); details in npz key 'readme'|LUNA tools/a16_xcheck.py (ICs from LUNA's comoving tests, outputs reduced)|cosmo_a16_xcheck (A16: comoving adiabatic expansion, top-hat)|tests/test_cosmo_a16_xcheck.py;tools/a16_xcheck.py|Arepo is GPL-3.0; data are the LUNA author's own runs; no third-party data terms known";;
    ramses/cosmo_a16_xcheck/*) echo "ramses|mini-ramses 55daaa5 (Raven, gfortran, MPI); details in npz key 'readme'|LUNA tools/a16_xcheck.py (ICs from LUNA's comoving tests, outputs reduced)|cosmo_a16_xcheck (A16)|tests/test_cosmo_a16_xcheck.py;tools/a16_xcheck.py|unknown (mini-ramses licence not checked); data are the LUNA author's own runs";;
    arepo/wd_model_A/*) echo "arepo|$WD_VER|Arepo 1D-spherical WD runs from LUNA model A (ics_A.hdf5 built by wd_research/wd_ic/build_wd_ic_A.py), reduced to 1D profiles + global series; /ptmp/uli/jax-hydro/luna_tests/wd_research/arepo_runs|wd_detonation model A ($(basename "$b" .npz | sed 's/arepo_wd_A_//'))|none in LUNA yet (wd_research/luna_runs/compare.py)|$WD_LIC";;
    arepo/wd_model_A2/*) echo "arepo|$WD_VER|Arepo 1D-spherical WD runs from LUNA model A2 (ics_A2.hdf5 built by wd_research/wd_ic/build_wd_ic_A2.py), reduced to 1D profiles + global series; /ptmp/uli/jax-hydro/luna_tests/wd_research/arepo_runs|wd_detonation model A2 ($(basename "$b" .npz | sed 's/arepo_wd_A2_//'))|none in LUNA yet (wd_research/luna_runs/compare.py)|$WD_LIC";;
    arepo/wd_model_B/*) echo "arepo|$WD_VER|Arepo 1D-spherical WD runs from LUNA model B (ics_B.hdf5 built by wd_research/wd_ic/build_wd_ic_B.py from wd_coulomb/wd_ic_B/wd_1p0_co_B_profile.npz: A2 core, envelope T(rho) falling to the 1.9e6 K ambient so P_surface = P_ambient, smooth Coulomb), reduced to 1D profiles + global series; /ptmp/uli/jax-hydro/luna_tests/wd_research/arepo_runs|wd_detonation model B ($(basename "$b" .npz | sed 's/arepo_wd_B_//'))|none in LUNA yet (wd_research/luna_runs/compare.py)|$WD_LIC";;
    arepo/burn_grid/*) echo "arepo|$WD_VER|Arepo examples nuclear_network/burn_grid one-zone grid (rho x T x dt x co/he/heco), released energy; $(basename "$b" .npz | sed 's/arepo_//') species; jobs in wd_research/arepo_runs/job_burn*.out|nuclear_burn_grid|none in LUNA yet|$WD_LIC";;
    luna/wd_validation/*) echo "luna|LUNA (moved from LUNA docs/validation at f06be95; per-file git_rev/inputs keys where present)|LUNA CPU validation reports of the nuclear network, Helmholtz EOS, ZND/CJ detonations and the 1D stellar driver (LUNA tools/check_*.py)|white-dwarf / Type Ia development (not on LUNA main)|tools/nuclear_rhs_reference.py;submit/examples/detonation_raven.sbatch|$LUNA_LIC";;
    luna/wd_initial_model/*) echo "luna|LUNA $(case "$b" in wd_1p0_co.npz) echo 'model A';; wd_1p0_co_A2.npz) echo 'model A2';; wd_1p0_co_B.npz) echo 'model B Arepo shells';; wd_1p0_co_B_profile.npz) echo 'model B fine profile (wd_coulomb/wd_ic_B/build_wd_profile_B.py)';; esac) (npz keys luna_commit 0a0ad4e1, eos_table_md5, label)|wd_research/wd_ic/build_wd_ic*.py: isothermal 1.0 Msun C/O WD in HSE with LUNA's Helmholtz EOS; the shared initial star of the Arepo WD references|wd_detonation initial model|none in LUNA yet|$LUNA_LIC";;
    microphysics/helmholtz_eos/*) echo "microphysics|$MP_VER|$MP_HOW|helmholtz_eos|tests/test_reference_microphysics.py;tools/check_helmholtz.py;tools/make_helm_subset.py|$MP_LIC";;
    microphysics/helium_burn/*) echo "microphysics|$MP_VER|$MP_HOW|helium_burn|tests/test_reference_burn.py;tools/check_burn_trajectories.py|$MP_LIC";;
    microphysics/detonation_cj/*) echo "microphysics|$MP_VER|$MP_HOW|detonation_cj|tests/test_reference_microphysics.py;tests/test_reference_cj.py;tools/check_detonation_reference.py;tools/make_helm_subset.py|$MP_LIC";;
    microphysics/*) echo "microphysics|$MP_VER|$MP_HOW|$(dirname "${p#microphysics/}")|tests/test_aprox13.py|$MP_LIC";;
    tables/helmholtz/*) echo "tables|Timmes & Swesty (2000) helm_table.dat sha256 c9a57c26...81a1 (npz key 'provenance')|LUNA tools/make_helm_subset.py: the table nodes the Microphysics references touch (17929 kept)|helmholtz_eos table subset|tests/test_reference_microphysics.py;tests/test_reference_burn.py;tools/make_helm_subset.py|unknown: Timmes-Swesty Helmholtz table, redistribution terms not confirmed (release plan B5)";;
    pencil/mcnally_kh/*) echo "pencil|McNally, Lyra & Passy 2012, ApJS 201, 18 (arXiv:1111.1764v2), Pencil Code 4096^2 reference curves; source PDF sha256 in the file header|LUNA tools/mcnally_digitize.py: digitised from the arXiv figure PDF content stream|mcnally_kh (A5)|tests/test_hydro_hard_mcnally_kh.py;tools/site_data.py;tools/mcnally_digitize.py|unknown: digitised from a published figure; cite McNally et al. 2012";;
    spectral/taylor_green/*) echo "spectral|euler3d (github.com/Ulli1991/euler_3d b104c2b); provenance string in npz key 'provenance'|LUNA tools/tg_spectral_reference.py (SLURM 31078606, A100, FP64) packed by tools/tg_reference_pack.py|taylor_green inviscid (A15)|tests/test_hydro_hard_taylor_green.py;tests/test_hydro_hard_taylor_green_reynolds.py;tools/tg_reference_pack.py|unknown: the LUNA author's own code (euler_3d), licence of that repository not stated";;
    spectral/taylor_green_viscous/*) echo "spectral|euler3d (euler_3d branch viscosity 3940684); provenance string in npz key 'provenance'|LUNA tools/tg_viscous_reference.py run + pack, Re 25..1600 at 128^3|taylor_green_viscous (A15 Re_eff)|tests/test_hydro_hard_taylor_green_reynolds.py;tools/site_data.py;tools/athenak_refs.py;tools/tg_viscous_reference.py|unknown: the LUNA author's own code (euler_3d), licence of that repository not stated";;
    spectral/taylor_green_brachet1983/*) echo "spectral|Brachet et al. 1983, J. Fluid Mech. 130, 411, fig. 7 (spectral DNS dissipation rate, Re 800/1600/3000)|digitised from the paper figure (luna_tests/a15_ext/lit/digit2.py, fig7.png); plain text, peak eps and eps(t) rows|taylor_green_viscous (A15, external literature check)|none (A15 external check, luna_tests/a15_ext)|unknown: digitised from a published figure; cite Brachet et al. 1983";;
    luna/kt_riemann/*) echo "luna|LUNA 2dbf3d3b (npz key 'provenance': run line, SLURM 31109275, 4 A100)|LUNA tools/kt_riemann.py, MC + HLLC 8192^2, block averages|kt_riemann (A11) - regression only, not external|tests/test_hydro_hard_kt_riemann.py;tools/kt_riemann.py;tools/athenak_summary.py|$LUNA_LIC";;
    luna/lw_implosion/*) echo "luna|LUNA 06f5d98a (npz keys git_rev, slurm_job_id 31110659, date)|LUNA tools/implosion_reference.py, MC + HLLC 6400^2|lw_implosion (A10) - regression only, not external|tests/test_hydro_hard_implosion.py;tools/implosion_reference.py;tools/athenak_summary.py|$LUNA_LIC";;
    luna/mcnally_kh/*) echo "luna|LUNA ea8fe29 (npz keys git_rev, date, mesh, devices)|LUNA tools/mcnally_kh_reference.py, MC + HLLC 4096^2|mcnally_kh (A5) - regression only, not external|tests/test_hydro_hard_mcnally_kh.py;tools/mcnally_kh_reference.py|$LUNA_LIC";;
    luna/shu_osher/*) echo "luna|LUNA b7b0d35 (npz keys git_rev, date)|LUNA tools/hydro_reference.py, HLLC-MC FP64 65536 cells|shu_osher - regression only, not external|tests/test_hydro_hard_shu_osher.py;tools/hydro_reference.py;tools/site_data.py|$LUNA_LIC";;
    luna/titarev_toro/*) echo "luna|LUNA 8a78a8f (npz keys git_rev, date)|LUNA tools/hydro_reference.py, HLLC-MC FP64 65536 cells|titarev_toro - regression only, not external|tests/test_hydro_hard_titarev_toro.py;tools/hydro_reference.py;tools/site_data.py|$LUNA_LIC";;
    luna/woodward_colella/*) echo "luna|LUNA b7b0d35 (npz keys git_rev, date)|LUNA tools/hydro_reference.py, HLLC-MC FP64 65536 cells|woodward_colella (A9) - regression only, not external|tests/test_hydro_hard_woodward_colella.py;tools/hydro_reference.py;tools/athenak_refs.py;tools/site_data.py;tools/athenak_summary.py|$LUNA_LIC";;
    luna/stellar/stellar_golden_v2.npz) echo "luna|LUNA f9d9173 (branch golden-fix on wd-explosion 53f2990)|regenerated on purpose by LUNA tests/test_stellar_golden.py __main__ through main.py, CPU-8 FP64 (Raven login node, 2026-10-30), after composition slopes became positivity-preserving (stellar_golden.npz from 07e1d08 encoded round-off-sign slope flattening; docs/STELLAR_1D.md)|stellar 1D main-path golden - regression only, not external|tests/test_stellar_golden.py (golden-fix)|$LUNA_LIC";;
    luna/stellar/*) echo "luna|LUNA 07e1d08|written by LUNA tests/test_stellar_golden.py __main__ (luna.stellar.run frozen output)|stellar runner golden - regression only, not external|tests/test_stellar_golden.py|$LUNA_LIC";;
    *) echo "NO PROVENANCE RULE for $p" >&2; exit 1;;
  esac
}

json_list() { local IFS=';' first=1 x; printf '['; for x in $1; do [ $first = 1 ] || printf ', '; printf '"%s"' "$x"; first=0; done; printf ']'; }

files=$(find . -type f ! -path './.git/*' ! -name MANIFEST.json ! -name make_manifest.sh ! -path ./README.md ! -path ./GAPS.md | sed 's|^\./||' | LC_ALL=C sort)
{
  printf '{\n "schema": 1,\n "generator": "make_manifest.sh",\n "files": [\n'
  n=0
  for p in $files; do
    m=$(meta "$p")
    IFS='|' read -r code ver how prob used lic <<< "$m"
    [ $n = 0 ] || printf ',\n'
    printf '  {"path": "%s", "sha256": "%s", "size": %s, "source_code": "%s", "version": "%s", "produced_by": "%s", "problem": "%s", "used_by": %s, "licence": "%s"}' \
      "$p" "$(sha256sum "$p" | cut -d' ' -f1)" "$(stat -c %s "$p")" "$code" "$ver" "$how" "$prob" "$(json_list "$used")" "$lic"
    n=$((n + 1))
  done
  printf '\n ]\n}\n'
} > MANIFEST.json
echo "MANIFEST.json: $n files"
