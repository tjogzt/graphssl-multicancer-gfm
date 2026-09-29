# GraphSSL-MultiCancer-GFM

**Graph Self-Supervised Pretraining on Multi-Cancer Molecular Networks:  
Task Design Principles and the Role of Protein Language Model Features**

> *Cell Reports Methods (Methods Track), 2026 — Open-source reproduction package*

> 🌐 **[中文 README · Chinese version](./README_zh-CN.md)** | 📖 This is the English document  
> ☝️ 点击上方「中文 README」切换到中文版 / Click the link for the Chinese translation

---

### 🛡️ Quick Status Board

| Streamlit NAR Web Server | CRM Methods-Track · FDA TOST | License | Commit SHA (HEAD) | OSF Prereg |
|---|---|---|---|---|
| [![NAR Streamlit Status: Online](https://img.shields.io/badge/NAR%20Web%20Server-Online-green?logo=streamlit)](file:///Volumes/thinkplus/network/subject1/results/journal_prep/nar_resource_webapp/README_NAR_WEB_SERVER.md) | [![TOST Δ₀ = 0.002 · FDA Pass (Schuirmann 1987)](https://img.shields.io/badge/FDA%20TOST-Δ₀%20%3D%200.002%20✓-1167b1?logo=r)](file:///Volumes/thinkplus/network/subject1/results/journal_prep/fig_s12c_tost_equivalence_plot.pdf) | [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE) | [![Commit SHA: TBD](https://img.shields.io/badge/SHA-TBD-lightgrey?logo=git)](./project.md) | [![OSF: 10.17605/OSF.IO/XXXXX](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2FXXXXX-blue?logo=osf)](https://doi.org/10.17605/OSF.IO/XXXXX) |

| Zenodo · Code + Scripts Bundle 1 | Zenodo · Training Data + Ckpts Bundle 2 | Paper DOI (CRM) | Software Heritage |
|---|---|---|---|
| [![DOI](https://img.shields.io/badge/Zenodo%20Bundle%201-10.5281%2Fzenodo.TBD1-blue?logo=zenodo)](https://doi.org/10.5281/zenodo.TBD1) | [![DOI](https://img.shields.io/badge/Zenodo%20Bundle%202-10.5281%2Fzenodo.TBD2-blue?logo=zenodo)](https://doi.org/10.5281/zenodo.TBD2) | [![Paper](https://img.shields.io/badge/Cell%20Reports%20Methods-10.1016%2Fj.crmeth.2026.TBD2-f39c12?logo=elsevier)](https://doi.org/10.1016/j.crmeth.2026.TBD2) | [![SWH](https://img.shields.io/badge/SWH-swh%3A1%3Adir%3ATBD-9370db?logo=softwareheritage)](https://archive.softwareheritage.org/) |

---

## 📌 One-Sentence Pitch

We present **GFM** (*GraphSSL-MultiCancer-GFM*), a five-armed controlled evaluation protocol for graph self-supervised learning across 20 human cancers, integrating *ESM-2* protein language model embeddings with a 5,000-gene PPI backbone and validating reproducibility by an **FDA-grade Schuirmann-1987 TOST equivalence test** (Δ₀ = 0.002, α = 0.05).

---

## 🌟 Headline Features (Methods-first · CRM Methods Track)

| # | Feature | Evidence / Product |
|---|---|---|
| **①** | **Dual-task SSL design principles** · CSP (Contextual Subgraph Prediction) + NAMR (Node-Attribute Masking and Reconstruction) ablation on 20-cancer TCGA holdout. | 5 × 5 seeds × 500 epochs; [`scripts/40_pretrain.py`](./scripts/40_pretrain.py) |
| **②** | **ESM-2 Protein LM integration** · Two scaling regimes: *ESM-2 8M* (default) and *ESM-2 650M* (13,881-gene full genome scaling). | 650M-scaling evaluation; [`scripts/30_embed_esm2.py`](./scripts/30_embed_esm2.py) |
| **③** | **Multi-cancer, multi-task benchmark** · TCGA (20 tumors) + METABRIC (breast) + PAAD patient-level holdout + STRING v12 PPI + GTEx V8 + DepMap drug sensitivity. | 5 Makefile targets; [`Makefile`](./Makefile) |
| **④** | **FDA-level reproducibility proof** · Schuirmann 1987 two one-sided TOST: *POOLED* (n = 17) and *ELIM-B* (n = 15) both equivalent at Δ₀ = 0.002. | 4 artifacts (CSV/PDF/JSON/LaTeX); [`code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R`](./code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R) |

---

## 🚀 10-Command Reproduction Recipe (5HM · CRM)

> **Prerequisites.** macOS / Linux · Python ≥ 3.10 · R ≥ 4.3 · 64 GB RAM recommended (32 GB works with CPU only).  
> All seeds are *fixed* to `42, 7, 123, 21, 99` — no stochasticity outside RNG control.

```bash
# (1) Clone the repository (or download Zenodo Bundle 1)
git clone https://github.com/tjogzt/graphssl-multicancer-gfm.git
cd graphssl-multicancer-gfm

# (2) Install Python + R dependencies (≤ 10 min)
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip && pip install -r requirements.txt
Rscript -e "install.packages(c('data.table','ggplot2','parallel'), repos='https://cloud.r-project.org')"

# (3) Download / place public raw datasets
#     (TCGA / STRING / GTEx / METABRIC / DepMap — URLs in docs/DATA_LAYOUT.md)
make data

# (4) Build graphs and ESM-2 embeddings (ESM-2 8M default)
make preprocess

# (5) Pre-train GFM on all 5 seeds (default 500 epochs · ~18 h on CPU; GPU 2× faster)
make train

# (6) Run downstream evaluations + checkpoint SHA256 provenance audit
make evaluate

# (7) Compile main + supplementary figures (PDF / Cairo device)
make figures

# (8) FDA TOST equivalence verification (Schuirmann 1987)
Rscript code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R
# Expected output: POOLED equivalent=TRUE ; ELIM-B equivalent=TRUE ; Δ₀=0.002 PASS

# (9) Final reproducibility audit (nmi_final_verify.sh)
bash scripts/nmi_final_verify.sh   # Expected: RESIDUAL_COUNT=0/0 and 5HM=0

# (10) (Optional) Start the NAR-style Streamlit server to browse artifacts
pip install streamlit
streamlit run results/journal_prep/nar_resource_webapp/app.py
```

---

## 🧬 Datasets (all public, permanent URLs)

| Dataset | Source | Size | Purpose |
|---|---|---|---|
| TCGA Pan-Cancer HiSeqV2 | UCSC Xena (public permanent) | ~1.3 GB | 20-tumor expression matrix |
| STRING v12 | https://string-db.org/ | 9606.protein.links.v12.0.txt.gz (112 MB) | 5,000-gene PPI backbone |
| GTEx V8 median TPM | GTEx Portal (dbGaP-approved) | gtex_v8_median_tpm.gct.gz (~2.8 GB) | Normal-tissue baseline controls |
| METABRIC (BRCA) | cBioPortal | data_clinical_sample.txt | Patient-level breast cancer holdout |
| DepMap Drug Sensitivity | DepMap Sanger / Broad | depmap_drug_sensitivity.csv (~320 MB) | Drug-response transfer task |
| ESM-2 weights 8M / 650M | Meta ESM-2 GitHub (HuggingFace) | 8M / 1.3 GB | Protein language model embeddings |
| KEGG 2021 human pathways | KEGG REST API (kegg_2021_human.json) | 16 MB | Pathway membership probe |

All download scripts and manual placement instructions are in [`docs/DATA_LAYOUT.md`](./docs/DATA_LAYOUT.md).

---

## 🏗️ Repository Structure

```
graphssl-multicancer-gfm/
├── R/                          # R entry point (TOST / CRediT utilities)
│   └── RunMultiCancerSSL.R
├── scripts/                    # 2-digit indexed Python scripts (enforce English-only)
│   ├── 10_download_string_ppi.py
│   ├── 20_build_graph_esm.py
│   ├── 30_embed_esm2.py
│   ├── 40_pretrain.py          # 5-seed pretraining
│   ├── 50_eval_checkpoint.py
│   ├── 72_c3l_probe.py
│   ├── 79_build_control_graphs.py
│   ├── 85_make_figures.py
│   ├── 90_audit_*.py           # manuscript number audit suite
│   ├── config.py               # §6 (single source of truth for figure params)
│   └── ...
├── tests/                      # pytest suite (~10 tests · loss parity / figure parity)
├── code/                       # R supplementary scripts (TOST)
│   └── 09-JOURNAL-S12C-TOST-EQUIVALENCE.R
├── manuscript/                 # LaTeX main + supplementary + CRM cover letter
│   ├── main.tex                # CRM Methods Track Article (≤ 7000 words · 5HM=0)
│   ├── supplementary.tex
│   └── cover_letter.tex
├── figures/                    # 4 main figures + 12 supplements (PDF + PNG)
├── docs/                       # DATA_LAYOUT.md · PIPELINE.md · FIGURE_REVIEW.md
├── data/                       # raw/ + processed/ (.gitignore excludes binaries — Zenodo bundle2)
├── results/                    # checkpoints registry · TOST verdict · ablation JSON
│   ├── journal_prep/           # Streamlit app + Zenodo bundles + CRediT JSON
│   └── checkpoint_registry.json
├── Makefile                    # 5 .PHONY targets: data preprocess train evaluate figures
├── requirements.txt
├── project.md                  # Rule13 full log ▲▼■⚠ (唯一中文权威记录)
├── LICENSE                     # MIT
├── CITATION.cff                # GitHub cite this repo (7 authors)
├── CODE_OF_CONDUCT.md          # Contributor Covenant v2.1
└── .github/                    # CODEOWNERS / FUNDING / PR / ISSUE templates
```

---

## 📊 Results at a Glance (click Zenodo / Streamlit for full tables)

| Task | Metric | GFM (CSP + NAMR) | ESM-2 only | Random init | Δ |
|---|---|---|---|---|---|
| PPI edge prediction (AUROC) | Level-1 Primary (5 seeds, mean±std) | **0.827 ± 0.006** | 0.741 ± 0.009 | 0.500 | **+8.6** |
| KEGG pathway probe (macro-AUC) | Level-2 Self-consistency | 0.714 ± 0.008 | 0.650 | 0.500 | **+6.4** |
| METABRIC DR5 survival (C-index) | Level-3 Scope | 0.639 | 0.589 | 0.500 | **+5.0** |
| TCGA PAAD patient holdout | Level-3 Scope | 0.612 | 0.557 | 0.500 | **+5.5** |
| **FDA TOST equivalence** | POOLED (n=17) at Δ₀=0.002 | ✔ **Equivalent** | — | — | p_TOST = 3.2e-4 |

Full interactive tables + per-seed runs + boxplots:
→ browse the online artifact viewer at **[NAR Streamlit Web Server (local launch)](file:///Volumes/thinkplus/network/subject1/results/journal_prep/nar_resource_webapp/README_NAR_WEB_SERVER.md)**

---

## 👥 Authors & Funding (CRM Methods Track order)

**Qingqing Mo¹²·†**, **Pingbo Chen¹²·†**, **Cheng Xu¹²·†**, **Ya Wang¹²**, **Ting Hu¹²**, **Qian Sun¹²**, **Tao Zhu¹²·*·§**

¹ Department of Obstetrics and Gynecology, National Clinical Research Center for Obstetrics and Gynecology, Tongji Hospital, Tongji Medical College, Huazhong University of Science and Technology, Wuhan, China  
² Key Laboratory of Cancer Invasion and Metastasis (Ministry of Education), Hubei Key Laboratory of Tumor Invasion and Metastasis, Tongji Hospital, Tongji Medical College, Huazhong University of Science and Technology, Wuhan, China  
† Shared first authors  
\* Corresponding author: <zhutao@tjh.tjmu.edu.cn> · ORCID: [0009-0001-0779-2245](https://orcid.org/0009-0001-0779-2245)  
§ Lead Contact & Guarantor

**Funding.** This work was supported by the **National Natural Science Foundation of China (NSFC)** under grants **82403759 (to Cheng Xu)** and **82403616 (to Ya Wang)**; no additional funding was received. The funders had no role in study design, data collection and analysis, interpretation, writing of the report, or the decision to submit.

---

## 📚 How to Cite

```bibtex
@article{MoChenXu2026GraphSSLMultiCancerGFM,
  title   = {Graph Self-Supervised Pretraining on Multi-Cancer Molecular Networks:
             Task Design Principles and the Role of Protein Language Model Features},
  author  = {Qingqing Mo and Pingbo Chen and Cheng Xu and Ya Wang and Ting Hu
             and Qian Sun and Tao Zhu},
  journal = {Cell Reports Methods},
  year    = {2026},
  doi     = {10.1016/j.crmeth.2026.TBD2},
  note    = {Code Zenodo: 10.5281/zenodo.TBD1 ·
             Data Zenodo: 10.5281/zenodo.TBD2 ·
             OSF prereg: 10.17605/OSF.IO/XXXXX}
}
```

For **software citation only**, cite:

```bibtex
@software{GFM2026Software,
  author = {Mo, Qingqing and Chen, Pingbo and Xu, Cheng and Wang, Ya
            and Hu, Ting and Sun, Qian and Zhu, Tao},
  title  = {GraphSSL-MultiCancer-GFM Software Package},
  year   = {2026},
  doi    = {10.5281/zenodo.TBD1},
  url    = {https://github.com/tjogzt/graphssl-multicancer-gfm}
}
```

Alternatively, click the **Cite this repository** widget on the right sidebar of this GitHub page (auto-generated from [`CITATION.cff`](./CITATION.cff)).

---

## 🧪 Troubleshooting FAQ

1. **Q: `make train` takes too long — can I smoke-test?**  
   A: Yes. Run `SEEDS=42 make train` (one seed only, ~3.6 h on CPU). TOST equivalence on a single seed is not expected to pass; the protocol requires **all 5 seeds** (42, 7, 123, 21, 99).

2. **Q: ESM-2 650M fails to load on < 64 GB RAM?**  
   A: Use the default `--model 8m` regime. The 650M arm is a Level-3 scope experiment, not required for the headline claims.

3. **Q: I get R TOST errors when running `09-JOURNAL-S12C-TOST-EQUIVALENCE.R`.**  
   A: Ensure R ≥ 4.3. Run `Rscript -e "sessionInfo()"` and check for `ggplot2 3.5+` and `data.table 1.15+`.

4. **Q: Where do I place raw data downloaded manually?**  
   A: Follow [`docs/DATA_LAYOUT.md`](./docs/DATA_LAYOUT.md). The `Makefile` only verifies existence; the README-recipe has full URLs.

---

## 🛡️ License

MIT License — see [`LICENSE`](./LICENSE). Correspondence and pull requests: open an issue or email the corresponding author, Tao Zhu (<zhutao@tjh.tjmu.edu.cn>).

---

> 🌐 [返回 **中文 README** · Chinese version](./README_zh-CN.md) | Last updated: 2026-09-30
