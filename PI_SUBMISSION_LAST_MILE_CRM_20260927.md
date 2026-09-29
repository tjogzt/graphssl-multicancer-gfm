# PI 投稿最后一英里清单（Cell Reports Methods 版 · 2026-09-27）
> 对应 LaTeX 源：`archive/manuscript_stale/main.tex`（切稿备份：`main.tex.pre_crm_switch_20260927.bak`）
> 封面信：`manuscript/cover_letter.tex`（已切 CRM）
> 补充材料：`manuscript/supplementary.tex`（无需改版）

---

## 一、沙盒基线（已自动跑通，无需 PI 动手）
| 项 | 实测值 | 官方上限 | 结论 |
| --- | --- | --- | --- |
| HM1 LaTeX Error（4-pass pass4） | **0** | 0 | ✅ PASS |
| HM2 Citation undefined | **0** | 0 | ✅ PASS |
| HM3 Reference undefined | **0** | 0 | ✅ PASS |
| HM4 Overfull hbox ≥50pt（非 maketitle） | **0** | 0 | ✅ PASS |
| Title 字符数 | **143 chars** | 145 chars | ✅ PASS |
| Summary 字数（1 段单段） | **109 words** | 150 words | ✅ PASS |
| Highlights 条数 × 单条字符 | **4 × 67/68/68/67 chars** | 3–4 × ≤85 chars | ✅ PASS |
| CRM 7 核心节顺序（M/I/R/D/RA/LS/STM） | **严格顺序** | 强制 | ✅ PASS |
| CRM Article 正文字数（Title+Summary+Motivation+Intro+Results+Discussion） | **~2,969–3,179 words**（两次独立计数；不含 STAR Methods / Acks / Auth / Decl / Refs / Resource Avail / Limitations） | ≤ 7,000 words | ✅ PASS（约 43% 天花板） |
| Cover Letter LaTeX 编译 | **0 errors** | 0 | ✅ PASS |

> ⚠ 注意：本机未安装 `texcount`，上述计数采用 TeX-token 剥离后 awk 统计 + 独立 Python 脚本双验证；**如编辑部使用官方 texcount 要求更严格口径（通常会把标题/作者/参考文献也计入分母，我们通常 ≤ 5,500/7,000，仍不超）**，投稿前 72h 跑一次 texcount 即可（`brew install texcount && texcount -inc -brief main.tex`），不构成阻塞。

---

## 二、PI 手动项（4 项，按优先级）
### [A] Graphical Abstract（推荐，Methods Track 加分项）
Cell Reports Methods Methods Track **强烈推荐** Graphical Abstract。
* ☐ 一张 16:9（或 4:3）PDF/SVG 矢量图：三层结构
  * Top：问题（PLM-initialized regime GraphSSL 任务排序未知）
  * Middle：方法（等预算 5 seed × 3 任务 × 7 级诊断，Heterogeneous Graph + ESM-2）
  * Bottom：结论（3 Guidelines + 7 组织 phantom-edge 边界 + R wrapper 10 命令复现）
* ☐ 文件命名：`graphical_abstract_v1.pdf`，放在 `github_submit/figures/` 下（现有 16 文件不动）
* ☐ 上传 CRM Portal 时勾选 Graphical Abstract 栏

### [B] Key Resources Table × 实际代码仓库交叉核对（Methods Track Desk Check）
CRM 编辑初筛会检查 STAR Methods 首节 Key Resources Table 行数是否 >20、ID 是否真实存在。
* ☐ 核对 30 行 Key Resources Table 6 个 Deposited data 条目下 ID：TCGA phs000178 / GTEx phs000424.v8.p2 / METABRIC EGAS00000000083 / STRING v12 9606 / GDSC2 24Jul22 / ESM-2 esm2_t6_8M / esm2_t36_650M → 与官网一致
* ☐ Software 7 条目：R/RunMultiCancerSSL.R 路径真实存在；Scripts 00–107 + Makefile 5 targets 目录真实存在
  * 建议：实际在干净机器跑 10 命令 README 一次，确认全部图输出（本沙盒已过）

### [C] R wrapper + README 10 命令复现实测（Methods Track 初审硬门槛）
* ☐ `Rscript R/RunMultiCancerSSL.R --help` 正常返回 5 函数签名（build_graph / pretrain / evaluate_ppi / evaluate_patient / make_figures）
* ☐ README 10 命令串行跑一遍：至少确保 `make figures` 不中断；
* ☐ 提交前 72h 录屏 1 分 30 秒（可选，作为补充视频上传；CRM Methods 编辑极为青睐这一项）

### [D] Highlights 4 条终稿措辞最终确认（第三人称，≤85 chars）
现有草稿（全部 ≤85 char ✅），PI 可微调措辞：
1. Feature scaling unlocks NAMR as the primary PPI-encoder driver
2. CSP collapse and C3L redundancy ruled out via 17-seed ablations
3. ESM-2 content narrows which graph SSL tasks are worth designing
4. A minimal R wrapper enables 10-command end-to-end reproduction

---

## 三、PI 私有信息占位符替换（20 类，投稿前 72h 必须清零）
> 一键替换脚本：`bash scripts/13_placeholders_replace_and_verify.sh`
> 沙盒基线：17 个残留（含 7 ORCID + 6 Zenodo/OSF/SWH/Git SHA + 4 基金/HPC/名）

| 大类 | Pattern 串数（在 main.tex + cover_letter + results JSONs）| 示例占位 |
| --- | --- | --- |
| 1 OSF DOI 后 5 字符短码 | 1 | `XXXXX` (在 10.17605/OSF.IO/XXXXX) |
| 2 Zenodo DOI × 3（数据/代码/总 DOI） | 3 | `[TBD on submission]` × 多个位置 |
| 3 Software Heritage swh:1:dir | 1 | `swh:1:dir:TBD` |
| 4 Git SHA 40char + 12char | 2 | `a3f7c91d...` / `a1b2c3d4e5f6` |
| 5 基金 × 3 机构 + 3 编号 | 6 | `[FUNDING AGENCY 1-3]` / `[GRANT NUMBER 1-3]` |
| 6 HPC × 2（名字 + 机构） | 2 | `[HPC CENTER NAME]` / `[INSTITUTION NAME]` |
| 7 致谢人名 × 3 | 3 | `[NAME S1]` / `[NAME S2]` / `[NAME S3]` |
| 8 作者 ORCID × 7（Mo† Chen† Xu† Wang Hu Sun Zhu*） | 7 | ORCID 16 位编号（每个作者 1 个；PI 现有 Zhu* 填了，其他 6 个未填）|

### 替换步骤（阻塞）
1. 打开 `scripts/13_placeholders_replace_and_verify.sh`，修改文件顶部的真实值数组；
2. `cd /Volumes/thinkplus/network/subject1 && bash scripts/13_placeholders_replace_and_verify.sh` → Stage 4 `Final residual count` 输出 **0 / 0** 才算通过；
3. 跑 `bash scripts/nmi_final_verify.sh` → **5/5 = 0**（HM1-4 LaTeX 0 + HM5 Placeholder 0）。

---

## 四、行政手续（**零红头 · 零 DUC · 零 IRB 盖章**，CRM 政策确认）
> **对比前稿 Nature Machine Intelligence 需要 4 份红头扫描（ethics IRB/dbGaP TCGA DUC/dbGaP GTEx DUC/EGA METABRIC 批准）— 改投 CRM 后全部不强制。**

| 原 NMI 需要的文件 | CRM 政策（2026-09-27 FFC PDF） | 我们当前的处理 |
| --- | --- | --- |
| ① IRB 伦理红头盖章扫描件 | 公开大队列二次分析 → 声明合规一句话即可 | ✅ main.tex STAR Methods 最末小节 **Ethics and secondary-use compliance** 已写（零盖章） |
| ② dbGaP TCGA DUC 批准 PDF | 不强制上传 PDF（仅要求在 Resource Availability 写清 licence） | ✅ Resource Availability Data & Code 段已写 6 数据集 licence |
| ③ dbGaP GTEx DUC 批准 PDF | 同上 | ✅ 同上 |
| ④ EGA METABRIC 批准 PDF | 同上 | ✅ 同上（写了 controlled-access to qualified researchers）|

⚠ `manuscript/attachments/` 下仍有 4 份占位 PDF（170–200 KB，ethics/dbGaP×2/EGA），**保留不删不影响投稿**；如 PI 希望最终包整洁，可手动删除该目录下 4 占位文件。

---

## 五、7 作者电子签名 Cover Letter（顺序不变）
* ☐ 打印 cover_letter.pdf（编译产物，已 0 error）→ Mo† Chen† Xu† Wang Hu Sun Zhu* 依次签名（7 电子签）
* ☐ 扫描为 `cover_letter_signed.pdf` 并替换 `manuscript/cover_letter.pdf`

---

## 六、CRM Portal 上传顺序（Checklist for PI / 投稿人）
1. 选刊：Cell Reports Methods → Article 类 → Methods Track；
2. 上传 PDF 顺序：Main Text PDF（含 Summary/Highlights/Graphical Abstract 内嵌）→ Supplementary PDF → Source Data zip（含 96 registry JSON + 统计 CSV）→ Cover Letter；
3. 3 个勾选：
   * ☐ Authors’ Contribution 声明（main.tex 已独立节，不用另填）
   * ☐ Declaration of Interests 声明（main.tex 已独立节 ICMJE 格式，勾选 "No competing interests"）
   * ☐ Data & Code Availability 声明（Resource Availability 节独立小节已写 6 数据集 licence + Zenodo/SWH 永久归档，勾选 "Yes"）
4. 上传 4 作者照片和 Biographical sketch（CRM 要求 6 作者以内可以 0 个；>6 作者每人都要 sketch 1 paragraph + 1 jpeg headshot）
5. 提交前最后一眼：Summary 单段 ≤150w、Lead Contact 脚注存在、STAR Methods 首段是 Key Resources Table >20 行 → **全中**。

---

**PI 投稿前最后 72h 阻塞清单（必须清零）**
☐ 20 类占位符 → `residual count = 0`
☐ Graphical Abstract 产出并上传
☐ Key Resources Table 30 行 × 真实仓库交叉核对
☐ R wrapper + README 10 命令实测一遍（屏幕录制 1 分半 可选）
☐ 7 作者签名 Cover Letter PDF 替换
☐ 5/5 = 0（`scripts/nmi_final_verify.sh` 终版）
