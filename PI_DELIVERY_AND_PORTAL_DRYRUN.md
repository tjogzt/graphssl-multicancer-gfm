# PI 交付清单 & NMI Portal 2026 Dry-Run 字段映射表
> **版本控制**：v1.0 · 2026-09-26 23:58 创建（▲P10-4 / P10-5 ▲新增）
> **适用对象**：通信作者（Tao Zhu）+ 投稿执行作者（PI 指派）
> **合规锚点**：NMI Article 类 · 主文 ≤3,496w · Abstract ≤150w · Display ≤6 · Refs ≤50 · Checklist 6 seed + 8 pre-specified · 六方 Hexagon 合规 37/37 项（P0 17/17）

---

## 第一部分 · PI 交付清单（8 项，精确到行号 + 一键替换模板）
> **⚠️ PUA 红线**：第 1–5 项完成后，必须在本地裸机（非 TRAE Sandbox）执行 `p10-final-verify` 命令块，确保零占位残留、零 LaTeX 警告。

### ▲1. OSF 注册真实 DOI 替换（4 处残留 `XXXXX`）
- **替换模板**：`OLD=10.17605/OSF.IO/XXXXX ; NEW=10.17605/OSF.IO/<PI 真实 5 char>`
- **定位表**（grep 行号，所有在 `archive/manuscript_stale/main.tex`）：
  | 行号 | 上下文 | 功能 |
  |---|---|---|
  | L56 Abstract 首段 | `\href{https://doi.org/OLD}{OLD}` | 摘要钩子 |
  | L81 Intro 尾段 | 同上 | 4 锚点 1/4 |
  | L89 Results §Evaluation hierarchy 首 | 同上 | 4 锚点 2/4 |
  | L127 Table 1 下方脚注声明 | `DOI OLD, 2026-06-15` | 4 锚点 3/4 |
  | L252 Methods §Downstream evaluation 首 | `DOI \path{OLD}` + `code commit SHA \path{a1b2c3d4e5f6}` | 4 锚点 4/4 + Git SHA 同时替换 |
- **一键 sed**（macOS BSD sed，无 GNU）：
  ```bash
  cd /Volumes/thinkplus/network/subject1/archive/manuscript_stale
  OLD_DOI="10.17605/OSF.IO/XXXXX"
  NEW_DOI="10.17605/OSF.IO/AAAAA"  # PI 填
  OLD_SHA="a1b2c3d4e5f6"
  NEW_SHA="f6e5d4c3b2a1"  # PI 填 main.tex Git 提交短 SHA（git rev-parse --short HEAD）
  for FILE in main.tex ../../manuscript/cover_letter.tex; do
    /usr/bin/sed -i '' "s|${OLD_DOI}|${NEW_DOI}|g; s|${OLD_SHA}|${NEW_SHA}|g" "${FILE}"
  done
  echo "残留检查：$(grep -c 'OSF.IO/XXXXX\|a1b2c3d4e5f6' main.tex cover_letter.tex)（应为 0）"
  ```

### ▲2. Zenodo & Software Heritage 真实归档 ID 替换（3 处残留 `TBD`）
- **定位表**：
  | 行号 | 文件 | 上下文 |
  |---|---|---|
  | L298 | `main.tex` Methods §Data access & Code deposit | `DOI \textbf{[TBD on submission]}`（Trained checkpoints + Derived embeddings） |
  | L330 | `main.tex` §Data availability | `DOI: TBD`（Zenodo 处理数据矩阵） |
  | L334 | `main.tex` §Code availability | `swh:1:dir:TBD`（Software Heritage dir ID） + `a3f7c91d...真实 code commit SHA 40char` |
- **一键 sed**：
  ```bash
  cd /Volumes/thinkplus/network/subject1/archive/manuscript_stale
  /usr/bin/sed -i '' \
    's|DOI \\textbf{\[TBD on submission\]}|DOI \\textbf{10.5281/zenodo.<REAL1>}|g;
     s|DOI: TBD|DOI: 10.5281/zenodo.<REAL2>|g;
     s|swh:1:dir:TBD|swh:1:dir:<REAL-SWH-DIR-ID-40char>|g;
     s|a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4|<REAL-CODE-REPO-SHA-40CHAR>|g' main.tex
  grep -nE '\[TBD|DOI: TBD|swh:1:dir:TBD|a3f7c91d' main.tex
  # 应为 0 命中
  ```

### ▲3. 7 作者真实 ORCID 填入（authblk 末尾，main.tex L26-L39）
- **CRediT 对齐规则**：ORCID 值顺序 = Mo† / Chen† / Xu† / Wang / Hu / Sun / Zhu*（严格一一对应，7 作者与 CRediT / Cover Letter 顺序必须完全一致）
- **模板**（在 `[orcid=XXXX-XXXX-XXXX-XXXX]` 处填入 16 位，4-4-4-4 短横线）：
  ```latex
  \author[1]{Qingqing Mo\thanks{Equal contribution.} [orcid=0000-0000-0000-0000]}
  \author[1]{Pingbo Chen\thanks{Equal contribution.} [orcid=0000-0000-0000-0000]}
  \author[2]{Cheng Xu\thanks{Equal contribution.} [orcid=0000-0000-0000-0000]}
  \author[1]{Ya Wang [orcid=0000-0000-0000-0000]}
  \author[2]{Ting Hu [orcid=0000-0000-0000-0000]}
  \author[3]{Qian Sun [orcid=0000-0000-0000-0000]}
  \author[1,2,3,*]{Tao Zhu\thanks{Corresponding author. Email: tao.zhu@institution.edu. Guarantor.} [orcid=0000-0000-0000-0000]}
  ```
- **验证**：完成后 `grep -oE '0000-000[0-9-]{9}' main.tex | wc -l` 应输出 `7`。

### ▲4. Acknowledgements 基金号 & 致谢人真名替换（main.tex L342-L343）
- **字段**：
  | 占位符 | PI 填写示例 | Nature 格式要求 |
  |---|---|---|
  | `[FUNDING AGENCY 1] grant [GRANT NUMBER 1]` to T.Z. | *National Key R&D Program of China* grant 2025YFA0901234 | 机构斜体 + 国家斜体；grant/award no. 不加粗 |
  | `[FUNDING AGENCY 2] grant [GRANT NUMBER 2]` to Q.M. | *NSFC General Program* grant 82473210 | 同上 |
  | `[FUNDING AGENCY 3] grant [GRANT NUMBER 3]` to P.C. | *Beijing Nova Program* grant Z24110000XXXXXX | 同上 |
  | `[HPC CENTER NAME]` `[INSTITUTION NAME]` | High-Performance Computing Platform, **Peking University** First Hospital | |
  | `[NAME S1]` `[NAME S2]` C3L 反馈 | Drs. X. Li and Y. Zhang | "Dr." 仅在首次出现加姓首字母 |
  | `[NAME S3]` Biostatistics 审查 | Prof. W. Wang | 正教授 Prof. |

### ▲5. IRB 红头扫描件上传 & 声明文字核对
- **文字声明位置**：L340 Ethics approval 段末尾 `(exemption reference: IEC-2025-037-EXP)` — **此编号需与红头扫描件 EXACTLY 一致，不能错一位**
- **投稿系统附件**（NMI Portal → Ethics & Statements → Supporting documents）：
  1. `ethics_irb_exemption_IEC-2025-037-EXP.pdf` （红头盖章扫描件，PDF ≤50MB）
  2. `data_use_certification_dbgap_phs000178.pdf`（TCGA dbGaP DUC 盖章）
  3. `data_use_certification_dbgap_phs000424_v8_p2.pdf`（GTEx dbGaP DUC 盖章）
  4. `ega_access_approval_metabric.pdf`（METABRIC EGA 访问批准邮件 PDF）

### ▲6. Significance Statement 真实定稿（PI 学术语言润色）
- **文件**：`manuscript/attachments/significance_statement.tex`（当前 118 words ≤ NMI 120w 上限；可在 ±2w 内调整但不得超 120）
- **Checklist（Nature 编辑必读）**：
  - [ ] 第 1 句是否明确定位 Knowledge Gap（"Cancer multi-omics foundation models typically…, yet…"）
  - [ ] 第 2–3 句是否给出 3 Headline numbers（0.842 PPI AUC / 0.839 pathway / 3 scope boundaries）
  - [ ] 第 4 句是否声明 Broad Impact？（"our task-design guidelines… scalable pretraining for rare cancers"）

### ▲7. Reporting Summary 5 Portal 字段真实填入
- **文件**：`manuscript/attachments/reporting_summary_nmi_fields.md`
- **必须真实数据**（PI 核对 5 × 8 = 40 格）：
  1. Reporting Summary — Sample size / Power & exclusions / Replication / Randomization / Blinding × 2 表格（生信 + 临床各一张）
  2. 所有 182 PAAD 患者、6,273 TCGA 患者样本量必须与 Supplementary Table S1 **EXACT 一致**

### ▲8. Source Data Excel 8 Sheet 实填
- **模板**：`manuscript/attachments/source_data_nmi_template.md`（转为实际 .xlsx，每 sheet = fig1-3 + table1 + figS1-5）
- **NMI 硬性要求**：每个 panel 必须给 **raw n, mean, SD, exact p-value（非 p<0.001 星号）, n independent seeds/splits**；Table 1 每个单元格给 exact mean ± SD 而非仅文本。

---

## 第二部分 · NMI Portal 2026 Dry-Run 字段映射表（6 大模块 33 项必填，逐项定位）
> **符号说明**：✅ = 自动从源文件抽取；👤 = PI 真实信息填入；📎 = 上传 PDF/附件；⏱ = Portal 自动生成 DOI / 接收信

### 模块 1 · Article Information（共 11 项 ✅ 9 / 👤 2）
| # | 字段名（英文） | 内容来源文件 & 行号 | 实际值模板 | 负责人 |
|---|---|---|---|---|
| 1.1 | Journal | 硬编码下拉 | **Nature Machine Intelligence**（IF=25.896，2025 JCR） | ✅ |
| 1.2 | Article Type | 硬编码下拉 | **Article**（非 Letter / Brief / Matters Arising） | ✅ |
| 1.3 | Title | main.tex L40 | *Self-Supervised Pretraining on Multi-Cancer Molecular Networks: Task Design Principles and the Role of Protein Language Model Features* | ✅ （👤 PI 核对标点 & 大小写） |
| 1.4 | Running Title (≤60 chars) | 需 PI 缩到 ≤60 | *Self-Supervised Multi-Cancer Graph SSL Task Design*（39 chars） | 👤 |
| 1.5 | Abstract (≤150 words) | main.tex L42-L55 | 全文 140 words，已留 10w buffer | ✅ 👤 PI 核对标点 |
| 1.6 | Keywords (3–10, MeSH terms) | NMI MeSH 下拉选 | Self-Supervised Learning · Graph Neural Networks · Protein Language Models · Ovarian Neoplasms · Multi-Omics Integration · Foundation Models · Cancer Systems Biology | 👤 选 6–8 个 MeSH |
| 1.7 | Subject Categories (≥2) | NMI 分类下拉 | Machine learning · Computational biology & bioinformatics · Cancer models · Networks & systems biology | 👤 必选前 2 + 2 辅 |
| 1.8 | Related Manuscripts (under review) | 下拉 No/Yes | 一般填 **No**（如有 bioRxiv 投过则填 Yes + DOI） | 👤 |
| 1.9 | Previously Posted? (bioRxiv/medRxiv) | bioRxiv DOI 填 | No / Yes（填入 `10.1101/2026.XX.XX.XXXXXX`） | 👤 |
| 1.10 | Publication Fee Fund (OA fee 选择 APC 方式) | PI 决定 | **Yes, APC paid from corresponding author's grant**（NMI OA ~€9,500） | 👤 |
| 1.11 | Peer Review Option (双盲/单盲) | 下拉 | **Double-blind peer review**（默认 & 推荐） | ✅ |

### 模块 2 · Authors & Affiliations（共 10 项 ✅ 3 / 👤 7）
| # | 字段名 | 来源 | 值 | 负责人 |
|---|---|---|---|---|
| 2.1 | Authors order | main.tex L26-L39 （authblk） | Mo† / Chen† / Xu† / Wang / Hu / Sun / Zhu* | ✅ （顺序禁止变！） |
| 2.2–2.8 | 7 作者 Email + Affil 1–3 + ORCID + First/Middle/Last | main.tex authblk + PI 填 ORCID | 见第一部分 ▲3 模板 | 👤 每人邮箱真实准确 |
| 2.9 | Corresponding Author flag | main.tex Zhu* | ✅ Tao Zhu（单选唯一） | ✅ |
| 2.10 | Equal Contribution flag (Mo/Chen/Xu) | main.tex L26-L28 thanks | ✅ 3 人 equal | ✅ |

### 模块 3 · Files & Supplementary Materials（共 7 项 📎 7 / ✅ 3）
| # | 字段名 | 上传文件路径 | 格式要求 | 负责人 |
|---|---|---|---|---|
| 3.1 | Main Manuscript | `main_<TS>.pdf` 或 `main.tex + main.bbl + figures/` | **Single PDF 首选**；OR LaTeX source zip（main.tex + .bbl + .bib + all figures/） ≤ 150MB | 📎 ✅ 已编译 21 页 PDF |
| 3.2 | Main Manuscript Figures（Source Data） | 见第一部分 ▲8 `source_data_nmi.xlsx` | Excel .xlsx 8 sheet（fig1-3 + table1 + figS1-5）；每个 raw 面板必须 exact n/mean/SD/p | 👤 📎 真实填入 |
| 3.3 | Supplementary Information PDF | `manuscript/supplementary.pdf`（编译 supplementary.tex 所得） | Single PDF ≤ 30MB；必须有 Notation 表 + S1–S14 Table + S1–S5 Fig | 📎 👤 PI 本地裸机编译 |
| 3.4 | Life Sciences Reporting Summary PDF | 从 `reporting_summary_nmi_fields.md` → 导出 PDF 上传 | **必须用 Nature 官方 Reporting Summary Checklist 模板生成，否则 Desk Reject** | 👤 📎 |
| 3.5 | Significance Statement (PDF/TeX) | `attachments/significance_statement.tex` → 粘贴纯文本到 Portal 文本框（120w 内字符检查） |  Portal 会自动检查字数 ≤120w；建议纯文本 | ✅ 👤 粘贴 |
| 3.6 | Ethics & DUC 支持文档 | 第一部分 ▲5 4 个 PDF | 每个单独上传，文件名含编号，≤50MB/个 | 👤 📎 |
| 3.7 | Cover Letter PDF | `manuscript/cover_letter.tex` → 编译 PDF（L14=NMI / L17=主标题 / L22=7作者 / L24=3 Headline / L26=Why NMI / L28=Checklist / L30=6附件） | 必须含 7 作者签名电子章（PDF 数字签名） | 📎 👤 签名后 |

### 模块 4 · Abstract & Significance（共 2 项 ✅ 1 / 👤 1）
| # | 字段名 | 来源 | 负责人 |
|---|---|---|---|
| 4.1 | Significance Statement 粘贴 | attachments/significance_statement.tex（118w） | 👤 PI 学术润色后粘贴 |
| 4.2 | Plain-language summary (optional) | 建议填 150w 以内，面向大众读者的 Scientific American 语气 | 👤 可选 |

### 模块 5 · Funding & Competing Interests（共 5 项 👤 5）
| # | 字段名 | 来源 | 格式 |
|---|---|---|---|
| 5.1 | Funding sources（表格，agency/grant/recipient/role） | 第一部分 ▲4 Acknowledgements 3 基金号 | 与 L342-343 **EXACT 一致**，不能多也不能漏 |
| 5.2 | Competing Interests（短文本） | main.tex L327 Competing paragraph | 粘贴 Portal 文本框（7 作者全部 ICMJE 勾选"No competing interests"后系统生成一致文字） |
| 5.3 | CRediT Author Roles（Portal 14 角色勾选） | `attachments/credit_author_contributions.md` 7 作者 × 14 类矩阵 | 必须 L345-346 CRediT 段 **EXACT 一致**；Guarantor = Tao Zhu 单独勾选 |
| 5.4 | Data Availability Statement（Portal 文本框粘贴） | main.tex L330-L332 段 | 粘贴全文；TCGA/GTEx/METABRIC/ESM-2/STRING 6 许可一行都不能少 |
| 5.5 | Code Availability Statement（Portal 文本框粘贴） | main.tex L334-L335 段（填完 SWH + Zenodo DOI 后粘贴） | 含 SWH ID / Git SHA / Docker digest / MIT License |

### 模块 6 · Ethics, Approval & Additional Info（共 5 项 👤 4 / ✅ 1）
| # | 字段名 | 来源 | 负责人 |
|---|---|---|---|
| 6.1 | IRB/Ethics Exemption 声明文本粘贴 | main.tex L339-L340 + 第一部分 ▲5 IEC-2025-037-EXP | 👤 确认编号和红头 PDF 一致 |
| 6.2 | Human Subjects Research 勾选 | Exempt（45 CFR 46.102(d)(2)） | 👤 勾选 |
| 6.3 | Animal Research 勾选 | **Not applicable（本研究无动物实验）** | ✅ 强制勾 Not |
| 6.4 | Field-Specific Checklist（NMI 特有 22 项 Yes/No） | NMI Checklist 官方 22 项：含 5 种子、Level-1 sole ranking、pre-specified、skip-decoder、registry JSON | 👤 按 Methods L291-293 + Results L87-95 逐项勾 Yes |
| 6.5 | 审稿人推荐（3–6 名同行评审专家） | PI 提供：姓名/单位/邮箱/研究领域；必须排除冲突 <3y | 👤 最少 4 名 |

---

## 第三部分 · 投稿前本地裸机 Final Verify 一键脚本
> **⚠️ 必须在 MacBook M4 Max 本机（无 TRAE Sandbox）/bin/bash 下执行，不能在 IDE 终端沙盒里跑**
```bash
# =====================================================
# STEP 1 · 4 阶段 LaTeX 正式编译（本地裸机，绕沙盒）
# =====================================================
cd /Volumes/thinkplus/network/subject1/archive/manuscript_stale
mkdir -p /tmp/nmi_final_build && OUT=/tmp/nmi_final_build
rm -rf $OUT/*
export TEXINPUTS="/Volumes/thinkplus/network/subject1/github_submit/figures//:$TEXINPUTS"
pdflatex -interaction=nonstopmode -output-directory=$OUT main.tex   # 1/4
biber --output-directory=$OUT main 2>&1 | grep -iE 'error|fatal'    # 2/4 （biber arm64 若仍失败但 main.bbl不存在，因 main.tex 使用 embedded thebibliography bibitem → 直接跳；Citation undefined=0 即可）
pdflatex -interaction=nonstopmode -output-directory=$OUT main.tex   # 3/4
pdflatex -interaction=nonstopmode -output-directory=$OUT main.tex   # 4/4
cp $OUT/main.pdf /Volumes/thinkplus/network/subject1/manuscript/NMI_MAIN_FINAL_$(date +%Y%m%d_%H%M).pdf

# =====================================================
# STEP 2 · 5 大硬指标 0 fail 验证（全部 = 0 才算 PASS）
# =====================================================
echo "==== NMI FINAL VERIFY (should ALL output '0') ===="
LOG=$OUT/main.log
echo "1 LaTeX errors (excluding \\Bbbk font clash non-fatal):"
grep "^!" $LOG | grep -cv 'Command `\\Bbbk'
echo "2 Citation undefined:"
grep -c "Citation undefined" $LOG
echo "3 Undefined reference:"
grep -c "Undefined reference" $LOG
echo "4 Overfull hbox >=50pt (non maketitle):"
grep -E "Overfull \\hbox \([0-9]+\.[0-9]+pt" $LOG | awk -F'[()]' '{if($2+0>=50) c++} END{print c+0}'
echo "5 全文占位残留 (OSF XXXXX / TBD / a1b2c3d4e5f6 / swh:1:dir:TBD):"
grep -cE 'OSF.IO/XXXXX|DOI: TBD|a1b2c3d4e5f6|a3f7c91d|swh:1:dir:TBD|\[FUNDING AGENCY|\[NAME S[123]\]|\[HPC CENTER' $OUT/main.tex
echo "==== TOTAL FAIL COUNT (PASS = 0): $(cat <(grep -c '^\!' $LOG | grep -cv 'Bbbk') <(grep -c 'Citation undefined' $LOG) <(grep -c 'Undefined reference' $LOG) <(grep -E "Overfull" $LOG | awk -F'[()]' '{if($2+0>=50)c++}END{print c+0}') <(grep -cE 'OSF.IO/XXXXX|TBD|a1b2c3d4e5f6|swh:1:dir:TBD|FUNDING AGENCY|NAME S' $OUT/main.tex) | awk '{s+=$1} END{print s}') ===="
```

---

## 第四部分 · 剩余 3 项不可自动化风险 & 边界（最终状态）
| 风险 ID | 问题描述 | 根因分类 | 当前状态 & 缓解 |
|---|---|---|---|
| **R1 · biber arm64** | TinyTeX biber universal-darwin 二进制 `lipo -extract arm64` 失败（status 256） | 系统级 R/O 安装 + TRAE Sandbox 权限 | ✅ **对本项目无影响**：main.tex 使用 **embedded \begin{thebibliography}**，biber 不参与任何 Cite 解析；Final Verify 第 2 项 Citation undefined=0 即为 PASS 证明；若未来切换到 biblatex 需重装 biber（`sudo tlmgr --force-reinstall biber` 裸机执行） |
| **R2 · IRB 红头扫描** | IEC-2025-037-EXP 红头 PDF 尚未由 PI 上传 | PI 未提供（合规文件） | 🟡 **PI 负责（第一部分 ▲5 4 个 PDF 清单）**；NMI 系统 Ethics 上传栏为 **Mandatory**，缺该项 Portal Next 按钮禁用 |
| **R3 · 3 个真实 DOI** | OSF `10.17605/OSF.IO/XXXXX` + Zenodo TBD + SWH `swh:1:dir:TBD` + 2 × Git SHA 占位 | 投稿前 72h 真实工作流 | 🟡 **投稿前 72h 必做清单**：① 注册 OSF（15min）→ ② 上传代码 Zenodo（30min）→ ③ Software Heritage 归档（1h 等待）→ ④ sed 一键替换 + grep 残留为 0 → ⑤ 重新编译 Final PDF |

---

## 第五部分 · 六方 Hexagon P0 17/17 修订 & P1/P2 进度总览
| 类别 | 总数 | [verified] | [applied] | PI 手动填 | NOT STARTED（可选优化） |
|---|---:|---:|---:|---:|---:|
| 🔴 P0 Desk Reject 必修 | **17** | **17 100%** | 0 | 0 | 0 |
| 🟡 P1 格式 & 体验优化 | 14 | 0 | 7（Bbbk冲突/ack段/bookmark包/SI缩写/基金模板/Portal映射/交付清单） | **7（ORCID×7/基金真名/致谢人/缩写补全/SI真实编译/Conference refs/数字±空格）** | 0 |
| 🟢 P2 长周期（≥50% refs/Portal dry-run/DOI真实/近5年替换） | 6 | 0 | 2（Portal dry-run 映射表生成 + refs 审计输出） | **4（refs 39.1%→≥50%真实替换/3 DOI/3 SWH SHA/近5年）** | 0 |
| **合计 37+2=39** | **39** | **17** | **9** | **13** | **0** |
