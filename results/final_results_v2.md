# Final results summary v2 (2026-08-15)

## 1. Multi-seed ablation (legacy-code NAMR; full/namr_only at 3 seeds)
| variant | seed | cluster acc | PPI AUC |
|---|---|---|---|
| full | | [full] PPI ratio=1.104x (pos 0.5690 / neg 0.5152) | AUC=0.5752 | cluster acc=0.8519 +/- 0.0193 |
| namr_only | | [namr_only] PPI ratio=2.461x (pos 0.7614 / neg 0.3094) | AUC=0.8578 | cluster acc=0.8025 +/- 0.0160 |
| csp_only | | [csp_only] PPI ratio=1.021x (pos 0.6505 / neg 0.6373) | AUC=0.5237 | cluster acc=0.8466 +/- 0.0234 |
| csp_namr | | [csp_namr] PPI ratio=1.986x (pos 0.7063 / neg 0.3557) | AUC=0.7136 | cluster acc=0.8799 +/- 0.0126 |

## 2. Equal-data single-cancer control
- csp_namr (multi-cancer): see above
- single_BRCA_esm: see eval_summary

## 3. GO enrichment
- 20/21 clusters significantly enriched (FDR<0.05)

## 4. METABRIC external validation (ER status, n=1980)
- full: K=50 AUROC 0.667 | namr_only: 0.671 | csp_namr: 0.641 | esm: 0.692 | random: 0.514

## 5. Tissue-specific PPI (GTEx v8)
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

## 6. Patient-level pretraining (PAAD, 182 patients)
- P-NAMR total loss: 31.17 -> (check patient_paad.log final)