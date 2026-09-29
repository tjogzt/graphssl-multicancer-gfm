# Result reproduction status

Classes: **A** re-evaluable from the released checkpoint; **B** retrainable from the released configuration (original checkpoint absent); **C** log-only. Derived from `results/checkpoint_registry.json` and the artifacts each result is cited from.

| result | class | artifact | note |
|---|---|---|---|
| Table 1 / S12 known-edge AUC (all arms, all seeds) | **A** | results/known_edge_multiseed.json | scripts/102_known_edge_per_seed.py (probe imported from 50_eval_checkpoint.py) |
| Table 1 / S11 KEGG AUROC (per arm, per seed) | **A** | results/kegg_per_seed.json | scripts/97_kegg_per_seed.py |
| Table 1 smoothing row / S21(a) smoothing sweep | **A** | results/control/graph_smoothing_baseline.json | scripts/96_graph_smoothing_baseline.py (no training) |
| S21(b) GraphMAE-style SCE ablation | **A** | results/control/ (SCE run) | 40_pretrain.py with the SCE criterion |
| S18 held-out edge recovery / structural controls | **A** | results/holdout/, results/control/control_eval_correct.json | scripts/78_eval_holdout.py, 79_build_control_graphs.py |
| S19 NAMR denoising benchmark (trivial denoisers) | **A** | results/control/ (denoiser benchmark) | scripts/91_namr_denoiser_diagnostic.py |
| S20 geometry, skip-decoder, prototype degeneracy | **A** | results/control/csp_geometry_shortcut.json, results/control/geometry_cross_seed.json, results/control/c3l_prototype_layers.json | scripts/93_csp_geometry_shortcut.py, 101_geometry_cross_seed.py, 92_c3l_prototype_diagnostic.py |
| S24 probe-regime sensitivity | **A** | results/probe_regimes.json | scripts/91_eval_probe_regimes.py |
| S7 / S2 patient-level P-NAMR curve (21-cancer, GPU run) | **C** | results/patient_fewshot_acc.json | the trained full-patient-graph checkpoint for the GPU run is not in the released tree; results/checkpoints/p1_patient_gfm.pt and the local-rebuild depth checkpoints are present, but they are different runs (different gra |
| S7 / S17 local-rebuild patient baselines and depth sweep | **A** | results/control/ (patient baselines) | scripts/62_patient_pretrain_eval.py |
| S9 METABRIC rows (full, NAMR-only, ESM-2, random) | **A** | results/metabric_rerun_20260918/ | scripts/60_metabric_validation.py |
| S9 METABRIC CSP+NAMR row (0.641) | **C** | original run only (no per-arm array retained) | the CSP+NAMR checkpoint used for that row is not archived under that arm name, so the value cannot be regenerated; it is flagged as such in the table itself and excluded from the reproduced range |
| S6 drug-response sweep | **A** | results/drug2_*.npy, results/control/ (drug baselines) | scripts/64_drug_response_gdsc.py, 96_drug_baselines.py |
| S22 650M NAMR-only known-edge AUC (0.896 / 0.887) | **B** | results/nmi_sprint_results.md | the 650M checkpoints are released, but the evaluation that produced 0.896 was not retained as a per-run log; the value is re-derivable by running the 650M evaluation protocol, which requires the external Xena matrices |
| S22 raw ESM-2 650M baseline (0.671) | **A** | results/nmi_sprint_results.md | scripts/53_eval_esm_baseline.py (evaluation-side, no checkpoint) |
| S22 PAAD held-out correlations | **A** | results/paad_rho_*.npy | scripts/63_paad_transfer_eval.py |
| S10 GTEx tissue filtering | **A** | results/tissue_ppi/ | scripts/66_tissue_specific_ppi.py |
| Fig. 3 per-seed known-edge scatter | **A** | results/known_edge_multiseed.json | scripts/102_known_edge_per_seed.py |
| Fig. S5 mechanism panels | **A** | results/control/geometry_cross_seed.json, results/control/c3l_prototype_layers.json | scripts/101_geometry_cross_seed.py, 92_c3l_prototype_diagnostic.py |

Counts: A = 16, B = 1, C = 2
