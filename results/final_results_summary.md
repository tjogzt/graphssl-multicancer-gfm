# Final results summary

Generated: 2026-09-11T14:51:15 | artifacts under `/Volumes/thinkplus/network/subject1/results` (no hand-transcribed numbers).

## 1. Ablation + baseline evaluation
| tag | cluster acc (mean +/- SD) | PPI ratio | PPI AUC |
|---|---|---|---|
| full | 0.8519 +/- 0.0193 | 1.104x | 0.5752 |
| namr_only | 0.8025 +/- 0.0160 | 2.461x | 0.8578 |
| csp_only | 0.8466 +/- 0.0234 | 1.021x | 0.5237 |
| csp_namr | 0.8799 +/- 0.0126 | 1.986x | 0.7136 |
| esm_only | 0.7049 +/- 0.0183 | 1.028x | 0.6221 |
| pca_input | 0.4648 +/- 0.0417 | -95.425x | 0.7048 |
| random_init_hgt | 0.4882 +/- 0.0220 | 1.000x | 0.6625 |

## 2. Loss convergence (first -> last, min)
- csp_namr_eqvol_s123.pt: csp: (0.6933, 0.3525, 0.314), namr: (1.0709, 1.049, 1.0037), c3l: (0.0, 0.0, 0.0), total: (1.7642, 1.4015, 1.3602)
- csp_namr_eqvol_s42.pt: csp: (0.6934, 0.3451, 0.3081), namr: (1.1258, 1.0277, 1.0174), c3l: (0.0, 0.0, 0.0), total: (1.8193, 1.3727, 1.3525)
- csp_namr_eqvol_s7.pt: csp: (0.6933, 0.4019, 0.2819), namr: (1.0854, 1.0773, 0.9955), c3l: (0.0, 0.0, 0.0), total: (1.7787, 1.4793, 1.2922)
- csp_namr_legacy_s123.pt: csp: (0.6933, 0.4227, 0.3737), namr: (1.0709, 1.0593, 1.0082), c3l: (0.0, 0.0, 0.0), total: (1.7642, 1.482, 1.4251)
- csp_namr_legacy_s21.pt: csp: (0.6931, 0.4104, 0.3763), namr: (1.0697, 1.0853, 1.0007), c3l: (0.0, 0.0, 0.0), total: (1.7629, 1.4957, 1.4112)
- csp_namr_legacy_s42.pt: csp: (0.6934, 0.4124, 0.3152), namr: (1.1258, 1.0502, 1.0229), c3l: (0.0, 0.0, 0.0), total: (1.8192, 1.4625, 1.363)
- csp_namr_legacy_s7.pt: csp: (0.6933, 0.2894, 0.2389), namr: (1.0854, 1.0512, 1.0155), c3l: (0.0, 0.0, 0.0), total: (1.7787, 1.3406, 1.3143)
- csp_namr_legacy_s99.pt: csp: (0.6933, 0.463, 0.3659), namr: (1.1126, 1.0801, 1.0047), c3l: (0.0, 0.0, 0.0), total: (1.8059, 1.5431, 1.4284)
- csp_namr_rewired_s123.pt: csp: (0.6933, 0.4219, 0.3739), namr: (1.0709, 1.0593, 1.0083), c3l: (0.0, 0.0, 0.0), total: (1.7642, 1.4812, 1.4248)
- csp_namr_rewired_s42.pt: csp: (0.6934, 0.3646, 0.3646), namr: (1.1258, 1.0431, 1.0239), c3l: (0.0, 0.0, 0.0), total: (1.8192, 1.4077, 1.4077)
- csp_namr_rewired_s7.pt: csp: (0.6933, 0.3619, 0.326), namr: (1.0854, 1.09, 1.0045), c3l: (0.0, 0.0, 0.0), total: (1.7787, 1.4519, 1.3443)
- csp_namr_s123.pt: csp: (0.6933, 0.4269, 0.3659), namr: (1.0709, 1.1068, 1.0058), c3l: (3.0448, 3.0847, 3.0082), total: (1.7642, 1.5337, 1.3814)
- csp_namr_s7.pt: csp: (0.6933, 0.4316, 0.3608), namr: (1.0854, 1.1193, 0.9899), c3l: (3.0457, 3.0923, 2.996), total: (1.7787, 1.5509, 1.3672)
- csp_namr_skipdiag_s42.pt: csp: (0.6934, 0.3609, 0.2725), namr: (1.0916, 0.2205, 0.2164), c3l: (3.0451, 3.0868, 2.9947), total: (1.785, 0.5814, 0.493)
- csp_only.pt: csp: (0.6934, 0.3784, 0.3598), namr: (0.0, 0.0, 0.0), c3l: (3.0452, 3.0815, 3.0047), total: (0.6934, 0.3784, 0.3598)
- csp_only_s123.pt: csp: (0.6933, 0.3879, 0.3274), namr: (0.0, 0.0, 0.0), c3l: (3.0446, 3.1161, 2.9668), total: (0.6933, 0.3879, 0.3274)
- csp_only_s7.pt: csp: (0.6933, 0.4423, 0.3701), namr: (0.0, 0.0, 0.0), c3l: (3.0455, 3.0872, 2.9882), total: (0.6933, 0.4423, 0.3701)
- full.pt: csp: (0.6934, 0.3821, 0.3486), namr: (1.1258, 1.098, 1.0192), c3l: (3.0451, 3.0394, 3.0308), total: (3.3418, 2.9997, 2.9441)
- full_20c.pt: csp: (0.6934, 0.3521, 0.3178), namr: (1.1358, 0.996, 0.9948), c3l: (2.995, 2.9947, 2.9712), total: (3.3267, 2.8454, 2.8454)
- full_650.pt: csp: (0.6931, 0.3029, 0.2115), namr: (1.0834, 1.0928, 1.0608), c3l: (3.0456, 3.0447, 3.0128), total: (3.2993, 2.918, 2.8294)
- full_650_20c.pt: csp: (0.6931, 0.2735, 0.2302), namr: (1.1137, 1.0924, 1.0635), c3l: (2.9955, 2.9928, 2.9766), total: (3.3046, 2.8623, 2.8233)
- full_legacy_s123.pt: csp: (0.6933, 0.3871, 0.319), namr: (1.0709, 1.1044, 1.0028), c3l: (3.0448, 3.0436, 3.0306), total: (3.2866, 3.0133, 2.8651)
- full_legacy_s21.pt: csp: (0.6931, 0.4375, 0.3491), namr: (1.0697, 1.074, 0.9782), c3l: (3.0439, 3.059, 3.0261), total: (3.2848, 3.041, 2.9223)
- full_legacy_s99.pt: csp: (0.6933, 0.428, 0.3734), namr: (1.1126, 1.1072, 1.014), c3l: (3.0453, 3.0461, 3.0247), total: (3.3285, 3.0582, 2.9424)
- full_s7.pt: csp: (0.6932, 0.3934, 0.3271), namr: (1.1351, 0.2147, 0.2097), c3l: (3.0455, 3.0483, 3.0096), total: (3.3511, 2.1322, 2.0684)
- full_s7o.pt: csp: (0.6933, 0.4298, 0.363), namr: (1.0854, 1.1192, 0.9899), c3l: (3.0457, 3.0416, 3.0324), total: (3.3016, 3.0698, 2.8964)
- namr_only.pt: csp: (0.6934, 0.6955, 0.6892), namr: (1.1258, 1.0638, 0.9855), c3l: (3.0451, 3.0418, 3.0265), total: (1.1258, 1.0638, 0.9855)
- namr_only_20c.pt: csp: (0.6934, 0.6894, 0.6871), namr: (1.1358, 0.9709, 0.9709), c3l: (2.995, 3.0033, 2.9844), total: (1.1358, 0.9709, 0.9709)
- namr_only_650.pt: csp: (0.6931, 0.6899, 0.6863), namr: (1.0834, 1.0652, 1.0339), c3l: (3.0456, 3.0435, 3.0376), total: (1.0834, 1.0652, 1.0339)
- namr_only_650_20c.pt: csp: (0.6931, 0.6938, 0.6908), namr: (1.1137, 1.0571, 1.0336), c3l: (2.9955, 2.9967, 2.9853), total: (1.1137, 1.0571, 1.0336)
- namr_only_s7.pt: csp: (0.6932, 0.693, 0.6903), namr: (1.1351, 0.2125, 0.211), c3l: (3.0455, 3.0401, 3.004), total: (1.1351, 0.2125, 0.211)
- namr_only_s7o.pt: csp: (0.6933, 0.6933, 0.6912), namr: (1.0854, 1.0912, 0.9619), c3l: (3.0457, 3.056, 3.027), total: (1.0854, 1.0912, 0.9619)
- patient_paad.pt: csp: (0.6932, 0.4536, 0.3718), namr: (1.1589, 0.2197, 0.2181), c3l: (0.0, 0.0, 0.0), total: (31.1699, 1.8561, 1.717)
- single_BRCA_esm.pt: csp: (0.6934, 0.3954, 0.3674), namr: (1.1038, 1.1271, 1.0009), total: (1.7971, 1.5226, 1.4064)

## 3. Controls (single-cancer / equal-volume / rewired)
- no control tags found in eval_summary.txt

## 4. GO cluster enrichment
- go_enrichment_control.json: 0/3 clusters significantly enriched
- go_enrichment_namr_only.json: 20/21 clusters significantly enriched

## 5. KEGG cluster control
- kegg_cluster_control.json: {"namr_only": 20, "pca_input": 16, "esm_raw": 19, "random_init_hgt": 9}

## 6. METABRIC external validation (per-split AUROC, K=50)
- metabric_esm_auc_k50.npy: 0.6921 +/- 0.0326 (n=30 paired splits)
- metabric_gfm_auc_k50.npy: 0.6483 +/- 0.0072 (n=30 paired splits)
- metabric_random_auc_k50.npy: 0.5135 +/- 0.0194 (n=30 paired splits)

## 7. Tissue-specific PPI (GTEx v8)
- [Breast - Mammary Tissue] PPI before filter: 473,860
- [Breast - Mammary Tissue] PPI after  filter: 320,758  (tissue='Breast - Mammary Tissue', TPM>=1.0)
- [Breast - Mammary Tissue] removed: 153,102 (32.3%)
- [Lung] PPI before filter: 473,860
- [Lung] PPI after  filter: 338,572  (tissue='Lung', TPM>=1.0)
- [Lung] removed: 135,288 (28.6%)
- [Colon - Transverse] PPI before filter: 473,860
- [Colon - Transverse] PPI after  filter: 328,122  (tissue='Colon - Transverse', TPM>=1.0)
- [Colon - Transverse] removed: 145,738 (30.8%)
- [Liver] PPI before filter: 473,860
- [Liver] PPI after  filter: 284,854  (tissue='Liver', TPM>=1.0)
- [Liver] removed: 189,006 (39.9%)
- [Stomach] PPI before filter: 473,860
- [Stomach] PPI after  filter: 312,364  (tissue='Stomach', TPM>=1.0)
- [Stomach] removed: 161,496 (34.1%)
- [Ovary] PPI before filter: 473,860
- [Ovary] PPI after  filter: 309,322  (tissue='Ovary', TPM>=1.0)
- [Ovary] removed: 164,538 (34.7%)
- [Kidney - Cortex] PPI before filter: 473,860
- [Kidney - Cortex] PPI after  filter: 304,132  (tissue='Kidney - Cortex', TPM>=1.0)
- [Kidney - Cortex] removed: 169,728 (35.8%)
- [Prostate] PPI before filter: 473,860
- [Prostate] PPI after  filter: 328,204  (tissue='Prostate', TPM>=1.0)
- [Prostate] removed: 145,656 (30.7%)
- [Pancreas] PPI before filter: 473,860
- [Pancreas] PPI after  filter: 282,090  (tissue='Pancreas', TPM>=1.0)
- [Pancreas] removed: 191,770 (40.5%)
- [Skin - Sun Exposed (Lower leg)] PPI before filter: 473,860
- [Skin - Sun Exposed (Lower leg)] PPI after  filter: 324,092  (tissue='Skin - Sun Exposed (Lower leg)', TPM>=1.0)
- [Skin - Sun Exposed (Lower leg)] removed: 149,768 (31.6%)
- [Thyroid] PPI before filter: 473,860
- [Thyroid] PPI after  filter: 322,522  (tissue='Thyroid', TPM>=1.0)
- [Thyroid] removed: 151,338 (31.9%)
- [Uterus] PPI before filter: 473,860
- [Uterus] PPI after  filter: 313,954  (tissue='Uterus', TPM>=1.0)
- [Uterus] removed: 159,906 (33.7%)
- [Bladder] PPI before filter: 473,860
- [Bladder] PPI after  filter: 318,242  (tissue='Bladder', TPM>=1.0)
- [Bladder] removed: 155,618 (32.8%)

## 8. PAAD held-out transfer (per-split Spearman rho)
- paad_rho_esm650_namr20c.npy: 0.1357 +/- 0.0342 (n=30 splits)
- paad_rho_esm650_namr21c.npy: 0.1357 +/- 0.0342 (n=30 splits)
- paad_rho_esm650_namr650_20c.npy: 0.1357 +/- 0.0342 (n=30 splits)
- paad_rho_esm650_namr650_20c_full.npy: 0.1392 +/- 0.0419 (n=30 splits)
- paad_rho_esm650_namr650_21c_full.npy: 0.1392 +/- 0.0419 (n=30 splits)
- paad_rho_esm8m_namr20c.npy: 0.1681 +/- 0.0374 (n=30 splits)
- paad_rho_esm8m_namr21c.npy: 0.1681 +/- 0.0374 (n=30 splits)
- paad_rho_esm8m_namr650_20c.npy: 0.1681 +/- 0.0374 (n=30 splits)
- paad_rho_namr20c.npy: 0.2623 +/- 0.0290 (n=30 splits)
- paad_rho_namr21c.npy: 0.2425 +/- 0.0311 (n=30 splits)
- paad_rho_namr650_20c.npy: 0.2612 +/- 0.0313 (n=30 splits)
- paad_rho_namr650_20c_full.npy: 0.2364 +/- 0.0472 (n=30 splits)
- paad_rho_namr650_21c_full.npy: 0.2444 +/- 0.0507 (n=30 splits)
- paad_rho_esm8m_namr650_20c_full.npy: not usable as a numeric array

## 9. Patient-level pretraining
- few-shot accuracy curve (from patient_fewshot_acc.json): K=1:0.238, K=2:0.302, K=5:0.390, K=10:0.459, K=20:0.520, K=30:0.555
- PAAD patient-level training log tail: Done in 200.5 min | conv=PASS (mid 2.8678 -> end 1.8342)
