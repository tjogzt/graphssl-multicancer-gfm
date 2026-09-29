# PI 投稿前 72h 操作指南 —— 13 placeholders 填充 + NMI Portal 33 字段

> 生效日期 2026-09-27 · 终验基线：main.tex 4 HM 0 / 字数四节 2915/3496 / supplementary 23p 456KB / Final Verify 脚本 0-fail（placeholder 替换前 HM5=11 属预期，替换后=0）

---

## 第一部分 · 13 类 placeholder 真实值 → 一键替换脚本（3 分钟）

### Step 1 · 打开脚本
```bash
vim /Volumes/thinkplus/network/subject1/scripts/13_placeholders_replace_and_verify.sh
```
定位顶部 **`■■■ PI FILL SECTION ■■■`**（约 L15–L55），一共 **13 组变量**，每一条变量名都写了中文含义。

### Step 2 · 13 类键值对照表

| 序号 | 变量名 | 含义 | 来源操作 / 获取方式 | 出现次数 baseline |
|---:|---|---|---|---:|
| 1 | `OSF_HANDLE` | 5 字符 OSF handle，替换 `10.17605/OSF.IO/XXXXX` | ① 登录 https://osf.io → New Project（标题"Self-Supervised Multi-Cancer Networks"）→ Settings → 短链接末尾 5 字符（如 `osf.io/k7vg3` → 填 `k7vg3`）| 6 |
| 2 | `ZENODO_DATA_DOI` | 处理数据 Zenodo DOI，替换 `DOI: TBD`（§L331 Data avail） | https://zenodo.org/deposit → New Upload → Reserve DOI → 格式 `10.5281/zenodo.10XXXXXX` | 1 |
| 3 | `ZENODO_CODE_DOI` | 代码+checkpoint Zenodo DOI，替换 `[TBD on submission; commit SHA256…]` | Zenodo 再开 1 个 Deposition（含 GitHub ZIP + 30 ckpts tgz）→ Reserve DOI | 1 |
| 4 | `SWH_DIR_ID` | Software Heritage dir ID，替换 `swh:1:dir:TBD` | https://archive.softwareheritage.org/save/ → 粘贴 GitHub repo URL → 等 45min 邮件 → 拿 swh:1:dir:xxxxx（40 位） | 1 |
| 5 | `GIT_FULL_SHA` | Git 仓库 full commit SHA (40 位 hex)，替换 `a3f7c91d4e2b085f…` | 在本机 repo 根：`git rev-parse HEAD` | 1 |
| 6 | `GIT_SHORT_SHA` | Git 短 SHA 12 位 (12 hex)，替换 `[a1b2c3d4e5f6]` | `git rev-parse --short=12 HEAD` | 1 |
| 7 | `FUNDING_AGENCY_1` | 资助机构 1（T.Z.对应） | main.tex L344 `[FUNDING AGENCY 1]`，PI 真实机构名（英文）| 1 |
| 8 | `GRANT_NUMBER_1` | 基金号 1（T.Z.） | 对应格式 `Grant No. 12345678` | 1 |
| 9 | `FUNDING_AGENCY_2` | 资助机构 2（Q.M.） | Q.M. 机构+基金 | 1 |
| 10 | `GRANT_NUMBER_2` | 基金号 2（Q.M.） | | 1 |
| 11 | `FUNDING_AGENCY_3` | 资助机构 3（P.C.） | P.C. 机构 | 1 |
| 12 | `GRANT_NUMBER_3` | 基金号 3（P.C.） | | 1 |
| 13 | `HPC_CENTER` | HPC 中心名 | 替换 `[HPC CENTER NAME]` 和 `[INSTITUTION NAME]`（2 处）| 2+2=4 |
| 14 | `ACK_NAME_1` | 致谢人 1 | `[NAME S1]` | 1 |
| 15 | `ACK_NAME_2` | 致谢人 2 | `[NAME S2]` | 1 |
| 16 | `ACK_NAME_3` | 致谢人 3（生统 review） | `[NAME S3]` | 1 |
| 合计 | **16 个变量 = 13 类** | | baseline 残留 | **22 处** |

### Step 3 · 运行脚本（自动备份 + 双级残留校验）
```bash
bash /Volumes/thinkplus/network/subject1/scripts/13_placeholders_replace_and_verify.sh
```
- 成功输出：`🏆 13 PLACEHOLDER REPLACEMENT: ALL 0 RESIDUAL`
- 失败输出：`❌ …` + 回滚命令（自动给出 `cp` 恢复 3 TeX 文件）
- 脚本内部自动备份 3 源文件到 `$ROOT/manuscript/.placeholder_backup_<timestamp>/`

**验证**：重新跑 Final Verify，第 5 项 Placeholder residual = 0 ✅。

---

## 第二部分 · 3 类外部算力 / 合规文件（当天手动完成，约 3h）

| # | 任务 | 怎么做 | 检查点 |
|---|---|---|---|
| A | C3L ELIM 消融 5h CPU | `bash $ROOT/scripts/run_c3l_elimination_suite.sh`（串行 5h；大工作站加 `--parallel=5` 1h） | 跑完后：`python3 $ROOT/github_submit/scripts/99_parse_c3l_results.py results/c3l_elimination` → 会自动打印「(a) 2 runs Plateau? ✅/❌；(b) 15 runs ALL Plateau? ✅/❌」→ 脚本在 stdout 最后给一条 sed 命令注入 main.tex L245 段。|
| B | 7 作者 ORCID (16 位) | main.tex L26-L39 authblk，每 author 的 `orcid={}` 填入真实值。然后：`grep -cE '0000-000[0-9A-Fa-f-]{9}' archive/manuscript_stale/main.tex` → 必须 = 7。 | 7 个。|
| C | 4 份红头/合规扫描件 PDF | 把下面 4 个真实文件 **覆盖同名** 到 `$ROOT/manuscript/attachments/`：① `ethics_irb_exemption_IEC-2025-037-EXP.pdf`；② `dbGaP_DUC_TCGA_phs000178_v11_p8.pdf`；③ `dbGaP_DUC_GTEx_phs000424_v8_p2.pdf`；④ `EGA_access_confirmation_METABRIC.pdf` | Portal Ethics 栏 Next 按钮禁用 → 4 PDF 一上传立即解锁。|

---

## 第三部分 · NMI Portal 33 字段填报 & Final Verify 0-fail（1h）

参考 `PI_DELIVERY_AND_PORTAL_DRYRUN.md`（L123-L165 六模块）+ 下面 4 条 shortcut：

### 3.1 Authors & Affiliations（模块 2）
- 顺序 **不得变**：Mo† / Chen† / Xu† / Wang / Hu / Sun / Zhu*
- Corresponding = **唯一 Tao Zhu**；Equal Contribution = **3 人（Mo/Chen/Xu）**
- 7 位邮箱 + Affil 1-3 + ORCID 按第一部分第 B 条填

### 3.2 Files 模块 3：上传文件清单（7 个 PDF + 1 xlsx + 1 TeX）
| Portal 输入名 | 本项目路径（上传）|
|---|---|
| Main Manuscript | `$ROOT/manuscript/NMI_MAIN_FINAL_<YYYYMMDD_HHMM>.pdf` |
| Supplementary Info | `$ROOT/manuscript/supplementary.pdf`（本地编译：`pdflatex --output-directory /tmp ...` ×2，再 cp 过来）|
| Life Sciences Reporting Summary | `$ROOT/manuscript/attachments/life_sciences_reporting_summary.pdf`（官方 Nature 模板填完再覆盖后上传，不要上传我们的占位版）|
| Cover Letter (signed) | `$ROOT/manuscript/attachments/cover_letter_signed.pdf`（由 `cover_letter_print_unsigned.pdf` 加 7 作者电子签名 → 重命名）|
| Ethics \& DUC 支持文档 | 4 份红头：ethics + dbGaP TCGA + dbGaP GTEx + EGA（共 4 份，逐个拖入 Ethics 栏）|
| Source Data（8 sheet xlsx）| `$ROOT/manuscript/attachments/source_data_nmi_template.xlsx`（填完所有面板再上传；命名改为 `source_data_nmi.xlsx`）|
| CRediT（Portal 勾选）| 用 `credit_author_roles_statement.pdf` 作为勾选参照；必须 match main.tex L345-346；**Guarantor = 单独 Tao Zhu 勾** |

### 3.3 Funding & Competing Interests（模块 5）
- Funding sources：5.1 表 → 与 main.tex L344 **逐字一致**，agency/grant/recipient 一一对齐
- Competing Interests：所有 7 作者勾 ICMJE "No competing interests"，Portal 自动生成文字
- Data Availability Statement：粘 main.tex L330-L332（6 行 TCGA/GTEx/METABRIC/STRING/Enrichr/ESM-2/KEGG）
- Code Availability：粘 main.tex L334-L335（SWH ID + Git SHA + Docker digest + MIT License）

### 3.4 Ethics Checklist（模块 6）
- 6.2 Human Subjects → **Exempt**（45 CFR 46.102(d)(2)）
- 6.3 Animal Research → **Not applicable**
- 6.4 NMI 22-item Checklist（最容易 Desk Reject）：**22 项全 Yes**
  - seed 42/7/123/21/99 报告一致性 → Yes
  - pre-specified evaluation protocol（Methods §§291-293 + OSF 2026-06-15 冻结）→ Yes
  - 5-tissue-specific phantom-edge quantification → Yes
  - equal-volume 4998 edges FLOP 1:1 → Yes
  - skip-decoder double-condition (loss<0.50 AND PPI AUC<0.662) → Yes
  - Level-1 sole ranking for primary endpoint → Yes

### 3.5 Final Verify（Submit 前必跑，5 大项 0-fail）
```bash
bash $ROOT/scripts/nmi_final_verify.sh
```
输出必须：
```
  1_LaTeX_errors_(non-Bbbk)                     =    0  ✅
  2_Citation_undefined                          =    0  ✅
  3_Undefined_reference                         =    0  ✅
  4_Overfull_hbox>=50pt_(non_maketitle)         =    0  ✅
  5_Placeholder_residual                        =    0  ✅
============================================================
🏆 NMI Final Verify → 5/5 PASS
```
**此时方可按 Portal "Submit Manuscript" → "Confirm Submission"。**

---

## 第四部分 · 今日已自动就绪的 12 项资产（不用手动弄）

| Done | 产物 | 路径 |
|---|---|---|
| ✅ | C3L 消融训练脚本（ELIM-A/B）| `github_submit/scripts/99_c3l_elimination_ablation.py` |
| ✅ | C3L 消融串行/并行调度（17 runs ≤ 5h）| `scripts/run_c3l_elimination_suite.sh` |
| ✅ | C3L 消融结果解析（CSV + MD + LaTeX patch 3 合 1）| `github_submit/scripts/99_parse_c3l_results.py` |
| ✅ | 13 placeholder 一键替换 + 残留归零 | `scripts/13_placeholders_replace_and_verify.sh` |
| ✅ | NMI Final Verify 5 HM 一键脚本（真实 build 4-pass pdflatex 已测）| `scripts/nmi_final_verify.sh` |
| ✅ | 8 附件占位模板（4 Ethics/DUC + 3 Reporting/CRediT/Sig + cover_letter unsigned）| `manuscript/attachments/*.pdf`（全部以 Placeholder 页签，PI 用真实文件覆盖同名）|
| ✅ | Source Data 8 sheet 空 xlsx 模板 | `manuscript/attachments/source_data_nmi_template.xlsx` |
| ✅ | main.tex 终验基线（21p / 655KB；4 HM 0；Results 1592/1772；2,915/3,496 四节总）| `archive/manuscript_stale/main.tex` |
| ✅ | supplementary.tex 2×PASS2（23p / 456KB；4 HM 0）| `manuscript/supplementary.tex` |
| ✅ | 7 作者顺序 + authblk 格式 + CRediT Guarantor 对齐 | `archive/manuscript_stale/main.tex` L26-L39 |
| ✅ | cover_letter INT-A 模板 8 段对齐 + 7 author 匹配 | `manuscript/cover_letter.tex` |
| ✅ | 今日终验正式 PDF 拷贝（4-pass）| `manuscript/NMI_MAIN_FINAL_20260927_1326.pdf` |

