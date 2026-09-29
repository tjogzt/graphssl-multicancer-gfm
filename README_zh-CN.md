# GraphSSL-MultiCancer-GFM · 中文版 README

**面向 20 种癌症分子网络的图自监督预训练框架 GFM：  
任务设计原则与蛋白质语言模型特征的作用研究**

> *Cell Reports Methods（方法学期刊 Methods Track）, 2026 — 开源可复现实验包*

> 🌐 **[English README](./README.md)** | 📖 本文件为中文说明文档  
> ☝️ 点击上方「English README」切换到英文版（GitHub 默认展示）

---

### 🛡️ 快速状态板

| Streamlit NAR 资源服务器 | CRM Methods Track · FDA TOST 等效性 | 开源协议 | 最新 Commit SHA (HEAD) | OSF 预注册 |
|---|---|---|---|---|
| [![NAR Streamlit 状态: 在线](https://img.shields.io/badge/NAR%20%E8%B5%84%E6%BA%90%E6%9C%8D%E5%8A%A1%E5%99%A8-%E5%9C%A8%E7%BA%BF-green?logo=streamlit)](./results/journal_prep/nar_resource_webapp/README_NAR_WEB_SERVER.md) | [![FDA TOST Δ₀ = 0.002 · PASS (Schuirmann 1987)](https://img.shields.io/badge/FDA%20TOST-%CE%94%E2%82%80%20%3D%200.002%20%E2%9C%93-1167b1?logo=r)](./results/journal_prep/fig_s12c_tost_equivalence_plot.pdf) | [![开源协议: MIT](https://img.shields.io/badge/%E5%BC%80%E6%BA%90%E5%8D%8F%E8%AE%AE-MIT-yellow.svg)](./LICENSE) | [![Commit SHA: TBD](https://img.shields.io/badge/SHA-TBD-lightgrey?logo=git)](./project.md) | [![OSF 预注册: 10.17605/OSF.IO/XXXXX](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2FXXXXX-blue?logo=osf)](https://doi.org/10.17605/OSF.IO/XXXXX) |

| Zenodo · 代码与脚本 Bundle 1 | Zenodo · 训练数据与检查点 Bundle 2 | 期刊论文 DOI (CRM Methods) | Software Heritage 归档 |
|---|---|---|---|
| [![DOI](https://img.shields.io/badge/Zenodo%20Bundle%201-10.5281%2Fzenodo.TBD1-blue?logo=zenodo)](https://doi.org/10.5281/zenodo.TBD1) | [![DOI](https://img.shields.io/badge/Zenodo%20Bundle%202-10.5281%2Fzenodo.TBD2-blue?logo=zenodo)](https://doi.org/10.5281/zenodo.TBD2) | [![期刊论文](https://img.shields.io/badge/Cell%20Reports%20Methods-10.1016%2Fj.crmeth.2026.TBD2-f39c12?logo=elsevier)](https://doi.org/10.1016/j.crmeth.2026.TBD2) | [![SWH](https://img.shields.io/badge/SWH-swh%3A1%3Adir%3ATBD-9370db?logo=softwareheritage)](https://archive.softwareheritage.org/) |

---

## 📌 一句话核心贡献

我们提出 **GFM**（*GraphSSL-MultiCancer-GFM*），一套覆盖 **20 种人类癌症** 的「五臂严格对照」图自监督学习评估协议；框架融合 **ESM-2 蛋白质语言模型** 嵌入与 5,000 基因的 PPI 骨架，并采用 **FDA 级 Schuirmann-1987 TOST 双单侧等效性检验**（Δ₀ = 0.002，α = 0.05）完成可复现性证明。

---

## 🌟 方法学四大亮点（Methods-first · CRM Methods Track）

| # | 方法学亮点 | 证据 / 产物 |
|---|---|---|
| **①** | **双任务 SSL 设计原则验证** · CSP（上下文子图预测）+ NAMR（节点属性遮蔽重建）双任务消融在 20 癌种 TCGA holdout 上验证。 | 5 组 × 5 随机种子 × 500 epoch；脚本 [`scripts/40_pretrain.py`](./scripts/40_pretrain.py) |
| **②** | **ESM-2 蛋白语言模型两级缩放验证** · 两种尺度 regime：*ESM-2 8M*（默认）与 *ESM-2 650M*（13,881 基因全基因组扩展）。 | 650M 扩展评估；脚本 [`scripts/30_embed_esm2.py`](./scripts/30_embed_esm2.py) |
| **③** | **多癌种 · 多任务基准测试** · TCGA（20 种肿瘤）+ METABRIC（乳腺癌）+ PAAD 患者级留出 + STRING v12 PPI + GTEx V8 + DepMap 药物敏感性。 | Makefile 5 大目标；脚本 [`Makefile`](./Makefile) |
| **④** | **FDA 级可复现性金标准证明** · Schuirmann 1987 TOST：*POOLED 组合队列*（n = 17）与 *ELIM-B 精简队列*（n = 15）双双在 Δ₀ = 0.002 下达到统计等效。 | 4 类产物（CSV/PDF/JSON/LaTeX）；脚本 [`code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R`](./code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R) |

---

## 🚀 10 命令完整复现（5 HM · CRM Methods Track）

> **环境要求。** macOS / Linux · Python ≥ 3.10 · R ≥ 4.3 · 推荐 64 GB 内存（纯 CPU 下 32 GB 也可跑，只慢一些）。  
> 所有随机种子**固定**为 `42, 7, 123, 21, 99` — 除可控 RNG 外无任何随机性。

```bash
# (1) 克隆本仓库（或直接下载 Zenodo Bundle 1）
git clone https://github.com/tjogzt/graphssl-multicancer-gfm.git
cd graphssl-multicancer-gfm

# (2) 安装 Python + R 依赖（≤ 10 分钟）
python3 -m venv .venv && source .venv/bin/activate
pip install --upgrade pip && pip install -r requirements.txt
Rscript -e "install.packages(c('data.table','ggplot2','parallel'), repos='https://cloud.r-project.org')"

# (3) 下载 / 放置公开原始数据集
#     TCGA / STRING / GTEx / METABRIC / DepMap — 具体 URL 见 docs/DATA_LAYOUT.md
make data

# (4) 构建图结构 + 生成 ESM-2 嵌入（默认 ESM-2 8M）
make preprocess

# (5) 5 个随机种子预训练 GFM（默认 500 epoch · CPU 约 18h；NVIDIA GPU 约加速 2×）
make train

# (6) 执行下游评估 + 检查点 SHA256 来源审计
make evaluate

# (7) 编译主文 + 补充材料图表（PDF · Cairo 设备矢量）
make figures

# (8) FDA TOST 等效性验证 (Schuirmann 1987)
Rscript code/09-JOURNAL-S12C-TOST-EQUIVALENCE.R
# 预期输出: POOLED equivalent=TRUE ; ELIM-B equivalent=TRUE ; Δ₀=0.002 PASS

# (9) 最终可复现性审计 (nmi_final_verify.sh)
bash scripts/nmi_final_verify.sh
# 预期: RESIDUAL_COUNT=0/0 且 5HM=0

# (10) （可选）启动 NAR 风格 Streamlit 资源服务器在线浏览产物
pip install streamlit
streamlit run results/journal_prep/nar_resource_webapp/app.py
```

---

## 🧬 数据集（全部公开 · 永久 URL）

| 数据集 | 来源 | 大小 | 用途 |
|---|---|---|---|
| TCGA Pan-Cancer HiSeqV2 | UCSC Xena (永久公开) | ~1.3 GB | 20 种肿瘤表达矩阵 |
| STRING v12 | https://string-db.org/ | 9606.protein.links.v12.0.txt.gz (112 MB) | 5,000 基因 PPI 骨架 |
| GTEx V8 median TPM | GTEx Portal (dbGaP 授权) | gtex_v8_median_tpm.gct.gz (~2.8 GB) | 正常组织基线对照 |
| METABRIC (BRCA) | cBioPortal | data_clinical_sample.txt | 乳腺癌患者级留出验证 |
| DepMap 药物敏感性 | DepMap Sanger / Broad | depmap_drug_sensitivity.csv (~320 MB) | 药物响应迁移任务 |
| ESM-2 权重 8M / 650M | Meta ESM-2 (HuggingFace) | 8M / 1.3 GB | 蛋白语言模型嵌入 |
| KEGG 2021 human pathways | KEGG REST API (kegg_2021_human.json) | 16 MB | 通路成员探针 |

所有下载脚本与手动放置指引统一在 [`docs/DATA_LAYOUT.md`](./docs/DATA_LAYOUT.md)。

---

## 🏗️ 仓库目录结构

```
graphssl-multicancer-gfm/
├── R/                          # R 入口脚本 (TOST / CRediT 工具)
│   └── RunMultiCancerSSL.R
├── scripts/                    # 2 位数编号 Python 脚本（ENGLISH ONLY 规范）
│   ├── 10_download_string_ppi.py
│   ├── 20_build_graph_esm.py
│   ├── 30_embed_esm2.py
│   ├── 40_pretrain.py          # 5 种子预训练
│   ├── 50_eval_checkpoint.py
│   ├── 72_c3l_probe.py
│   ├── 79_build_control_graphs.py
│   ├── 85_make_figures.py
│   ├── 90_audit_*.py           # 稿件数值审计套件
│   ├── config.py               # 图参数单一真源 (§6 规范)
│   └── ...
├── tests/                      # pytest 套件 (~10 用例 · 损失/图对齐)
├── code/                       # R 补充脚本 (TOST 等效检验)
│   └── 09-JOURNAL-S12C-TOST-EQUIVALENCE.R
├── manuscript/                 # LaTeX 主文 + 补充材料 + CRM Cover Letter
│   ├── main.tex                # CRM Methods Track Article（≤ 7000 words · 5HM=0）
│   ├── supplementary.tex
│   └── cover_letter.tex
├── figures/                    # 4 主图 + 12 补充图（PDF 矢量 + PNG 预览）
├── docs/                       # DATA_LAYOUT.md · PIPELINE.md · FIGURE_REVIEW.md
├── data/                       # raw/ + processed/ (二进制被 .gitignore 排除 · Zenodo bundle2)
├── results/                    # checkpoints 注册表 · TOST 判决 · 消融 JSON
│   ├── journal_prep/           # Streamlit + Zenodo bundles + CRediT JSON
│   └── checkpoint_registry.json
├── Makefile                    # 5 .PHONY 目标: data preprocess train evaluate figures
├── requirements.txt
├── project.md                  # Rule13 权威全日志 ▲▼■⚠（唯一中文原始记录）
├── README_zh-CN.md             # 本文件
├── LICENSE                     # MIT 协议
├── CITATION.cff                # GitHub 一键引用（7 作者 CRM 顺序）
├── CODE_OF_CONDUCT.md          # Contributor Covenant v2.1
└── .github/                    # CODEOWNERS / FUNDING / PR / ISSUE 模板
```

---

## 📊 结果速览（完整交互表格请登录 Zenodo / Streamlit 浏览）

| 任务 | 度量指标 | GFM (CSP + NAMR) | ESM-2 only | 随机初始化 | 提升 Δ |
|---|---|---|---|---|---|
| PPI 边预测 (AUROC) | Level-1 主结局（5 seeds, mean±std） | **0.827 ± 0.006** | 0.741 ± 0.009 | 0.500 | **+8.6** |
| KEGG 通路探针 (macro-AUC) | Level-2 自洽性 | 0.714 ± 0.008 | 0.650 | 0.500 | **+6.4** |
| METABRIC DR5 生存 (C-index) | Level-3 外部扩展 | 0.639 | 0.589 | 0.500 | **+5.0** |
| TCGA PAAD 患者留出 | Level-3 外部扩展 | 0.612 | 0.557 | 0.500 | **+5.5** |
| **FDA TOST 等效性** | POOLED (n=17) at Δ₀=0.002 | ✔ **统计等效** | — | — | p_TOST = 3.2e-4 |

完整按种子明细 + 箱线图交互浏览：
→ **[NAR Streamlit 资源服务器 (本地启动)](./results/journal_prep/nar_resource_webapp/README_NAR_WEB_SERVER.md)**

---

## 👥 作者信息与基金（CRM Methods Track 署名顺序）

**莫青青¹²·†**，**陈平波¹²·†**，**徐成¹²·†**，**王亚¹²**，**胡婷¹²**，**孙倩¹²**，**朱涛¹²·*·§**

¹ 华中科技大学同济医学院附属同济医院妇产科，国家妇产疾病临床医学研究中心，武汉，中国  
² 华中科技大学同济医学院附属同济医院，教育部肿瘤侵袭与转移重点实验室，湖北省肿瘤侵袭与转移重点实验室，武汉，中国  
† 共同第一作者  
\* 通讯作者：<zhutao@tjh.tjmu.edu.cn> · ORCID: [0009-0001-0779-2245](https://orcid.org/0009-0001-0779-2245)  
§ Lead Contact & Guarantor（总责任人 & 稿件担保人）

**基金资助。** 本工作受**国家自然科学基金 (NSFC)** 资助 **82403759（徐成）** 与 **82403616（王亚）**；无其他额外资助。基金方未参与研究设计、数据采集与分析、稿件撰写或投稿决策。

---

## 📚 如何引用

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

**若仅引用本软件包**，使用：

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

也可直接点击 GitHub 仓库右侧 **「Cite this repository」** 小部件（自动从 [`CITATION.cff`](./CITATION.cff) 生成）。

---

## 🧪 常见问题 FAQ

1. **问：`make train` 跑太慢 — 能不能先做烟雾测试？**  
   答：可以。执行 `SEEDS=42 make train`（单种子，CPU 约 3.6h）。但单种子 TOST 等效性检验**不会通过**；完整声明必须跑满 **5 种子**（42, 7, 123, 21, 99）。

2. **问：ESM-2 650M 在 < 64 GB RAM 的机器加载失败？**  
   答：使用默认 `--model 8m` 即可。650M arm 是 Level-3 扩展性实验，不影响主结论。

3. **问：跑 `09-JOURNAL-S12C-TOST-EQUIVALENCE.R` 时 R 报 TOST 相关错误？**  
   答：确认 R ≥ 4.3。执行 `Rscript -e "sessionInfo()"` 检查 `ggplot2 ≥ 3.5` 与 `data.table ≥ 1.15`。

4. **问：手动下载的原始数据放哪？**  
   答：遵循 [`docs/DATA_LAYOUT.md`](./docs/DATA_LAYOUT.md) 第 3 节的目录结构图；Makefile 仅校验存在性，README 配方里有完整的 URL。

---

## 🛡️ 开源协议

MIT License — 详见 [`LICENSE`](./LICENSE) 。稿件咨询与 PR：建议先开 Issue 或邮件联系通讯作者朱涛 <zhutao@tjh.tjmu.edu.cn>。

---

> 🌐 [返回 **英文 README**](./README.md) | 本文件最后更新: 2026-09-30
