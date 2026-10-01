#!/usr/bin/env bash
# ================================================================
# 中文说明: 13 类 投稿占位符 一键替换 + 残留 0 验证 脚本 v2.0 CRM Edition
#          · v1 只处理 manuscript/*.tex 3 个文件 (旧 13 占位符 NSFC/HPC/NAME×3)
#          · v2 覆盖：
#              ① 6 作者真实 ORCID (Mo/Chen/Xu/Wang/Hu/Sun; Zhu 已填) +
#              ② 5 类真实 DOI (OSF + Zenodo B1 + Zenodo B2 + CRM Paper DOI + OSF full)
#              ③ Software Heritage swh:1:dir:<40>
#              ④ 2 个 Git SHA (Long 40 / Short 12)
#              ⑤ 2 HPC + NAME S1/S2/S3 (v1 保留)
#          · v2 目标文件矩阵: README.md · README_zh-CN.md · CITATION.cff ·
#                                 authors_and_fundings_registry_crm.json ·
#                                 archive/manuscript_stale/main.tex
#                                 manuscript/supplementary.tex
#                                 manuscript/cover_letter.tex
#          · 运行模式:
#              --dry-run     (默认, 不改任何文件, 只扫描 + 打印替换前报告)
#              --apply       真实执行, 先完整备份 archive/docs/placeholder_bak_*, 再替换
#              --verify-only 不替换, 只跑残留检查 (投稿前最后一步)
# English : v2 one-shot sed + grep-verifier for full 13-placeholder CRM submission
#           matrix (DOIs / ORCIDs / SHA / SWH / HPC / 3x ACK names).
#           Placeholder values MUST be real IDs; NEVER fabricate.
# Usage:
#   1) OPTION A (preferred): fill CSV at archive/docs/13_placeholders_INPUT_TEMPLATE.csv
#      so values are version-controlled alongside the repo.
#      OR
#      OPTION B: fill bash variables in PI_FILL section below.
#   2) bash scripts/13_placeholders_replace_and_verify_v2.sh --dry-run  (first)
#   3) bash scripts/13_placeholders_replace_and_verify_v2.sh --apply    (real run)
#   4) Check summary. RES_TOTAL must be EXACTLY 0 after --apply, else fix + rerun.
# ================================================================
set -euo pipefail

# --------------------   RUN MODE  ---------------------------
MODE="dry-run"
for a in "$@"; do
  case "$a" in
    --apply        ) MODE="apply" ;;
    --verify-only  ) MODE="verify-only" ;;
    --dry-run|"-h"|--help) MODE="dry-run" ;;
    *) echo "Unknown arg: $a"; echo "Usage: $0 [--dry-run|--apply|--verify-only]"; exit 2 ;;
  esac
done

# ================================================================
# ■■■  PI FILL  SECTION  v2.0  — fill ALL of the below  ■■■
# 填法一: 本脚本填 (默认)
# 填法二: 用 archive/docs/13_placeholders_INPUT_TEMPLATE.csv, 但仍然要把值
#         拷到这里, 保持 bash 变量单一真源, 避免 bash 解析 CSV 正则陷阱.
# ================================================================
# [A · DOI block (5)]
OSF_DOI_SHORT="XXXXX"                                  # 5 chars, e.g. "KT6P2" (from osf.io/<xxxxx>). Replaces OSF.IO/XXXXX everywhere.
ZENODO_B1_CODE_DOI="10.5281/zenodo.23074742"           # Deposition B1 CODE: https://zenodo.org/deposit/23074742  (reserved 2026-10-01, access=restricted, PI to publish post-acceptance)
ZENODO_B2_DATA_DOI="10.5281/zenodo.23074744"           # Deposition B2 DATA: https://zenodo.org/deposit/23074744  (reserved 2026-10-01, embargoed 2027-06-30; lite payload 65MB shipped: processed pt + manifest + download R script. PI drag-drop 8.7G raw TCGA/ tissue ppi post-acceptance, or let users rebuild via --mode full)
CRM_METHODS_PAPER_DOI="10.1016/j.crmeth.2026.TBD2"     # FROM editor, post-acceptance
SWH_DIR_ID="swh:1:dir:TBD00000000000000000000000000000000000000"  # swh:1:dir:<40 lowercase hex>

# [B · Git SHA block (2)]
GITHUB_COMMIT_SHA_LONG="a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4" # 40 char. `git rev-parse main` on frozen commit. PI fills real value in wave-2.
__DEF_SHA_LONG__="a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"      # INTERNAL sentinel — do NOT touch this line.
GITHUB_COMMIT_SHA_SHORT="a1b2c3d4e5f6"                            # 12 char. Derived = ${GITHUB_COMMIT_SHA_LONG:0:12} if not set manually in wave-2.
__DEF_SHA_SHORT__="a1b2c3d4e5f6"                                  # INTERNAL sentinel — do NOT touch this line.

# [C · ORCID block (6, Zhu Tao pre-filled as SKIP)]
ORCID_MO_QINGQING="TBD-MO-ORCID-TBD"
ORCID_CHEN_PINGBO="TBD-CHEN-ORCID-TBD"
ORCID_XU_CHENG="TBD-XU-ORCID-TBD"        # NSFC 82403759 PI
ORCID_WANG_YA="TBD-WANG-ORCID-TBD"       # NSFC 82403616 PI
ORCID_HU_TING="TBD-HU-ORCID-TBD"
ORCID_SUN_QIAN="TBD-SUN-ORCID-TBD"

# [D · HPC + 3x ACK names block (5), v1 legacy]
HPC_CENTER="[HPC CENTER NAME]"
HPC_INSTITUTION="[INSTITUTION NAME]"
ACK_S1="[NAME S1]"
ACK_S2="[NAME S2]"
ACK_S3="[NAME S3]"
# (funding 1-3 already written permanently as NSFC 82403759+82403616+none in manuscript. Legacy block preserved.)
FUNDING_AGENCY_1="National Natural Science Foundation of China"; GRANT_1="82403759"
FUNDING_AGENCY_2="National Natural Science Foundation of China"; GRANT_2="82403616"
FUNDING_AGENCY_3="(none declared)";                         GRANT_3="(none declared)"
# ================================================================
#  END OF PI FILL SECTION
# ================================================================

# -------- auto-derive short SHA if PI has filled a real 40-char LONG SHA (wave-2) --------
if [[ "$GITHUB_COMMIT_SHA_LONG" != "$__DEF_SHA_LONG__" &&
      "$GITHUB_COMMIT_SHA_LONG" =~ ^[a-f0-9]{40}$ &&
      "$GITHUB_COMMIT_SHA_SHORT" == "$__DEF_SHA_SHORT__" ]]; then
  GITHUB_COMMIT_SHA_SHORT="${GITHUB_COMMIT_SHA_LONG:0:12}"
fi

# -------- ROOT & target files matrix (v2 wide scope) --------
if [[ -n "${PLACEHOLDER_PROJECT_ROOT:-}" && -d "${PLACEHOLDER_PROJECT_ROOT}" ]]; then
  ROOT="${PLACEHOLDER_PROJECT_ROOT}"
else
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
# Target files (order not important for scan, but for backup we copy all 7)
TGT_README_EN="${ROOT}/README.md"
TGT_README_ZH="${ROOT}/README_zh-CN.md"
TGT_CIT_CFF="${ROOT}/CITATION.cff"
TGT_REG_JSON="${ROOT}/results/journal_prep/authors_and_fundings_registry_crm.json"
TGT_MAIN_TEX="${ROOT}/archive/manuscript_stale/main.tex"
TGT_SUPPL_TEX="${ROOT}/manuscript/supplementary.tex"
TGT_COVER_TEX="${ROOT}/manuscript/cover_letter.tex"

ALL_FILES=(
  "$TGT_README_EN" "$TGT_README_ZH" "$TGT_CIT_CFF" "$TGT_REG_JSON"
  "$TGT_MAIN_TEX" "$TGT_SUPPL_TEX" "$TGT_COVER_TEX"
)
# Validate existence (soft-warn, not die, since some users may not have copied manuscript dirs to /tmp mocks)
for F in "${ALL_FILES[@]}"; do
  if [[ ! -f "$F" ]]; then
    echo "⚠  [TARGET MISSING] $F (continue anyway — dry-run / verify mode OK, apply mode will just skip this file)"
  fi
done

# -------- backup for --apply --------
if [[ "$MODE" == "apply" ]]; then
  BACKUP_DIR="${ROOT}/archive/docs/placeholder_bak_v2_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "${BACKUP_DIR}"
  LOG="${BACKUP_DIR}/replacements.log"
  echo "[BACKUP][$MODE] copying 7 target files to ${BACKUP_DIR}" | tee "${LOG}"
  for F in "${ALL_FILES[@]}"; do
    [[ -f "$F" ]] && cp -a "$F" "${BACKUP_DIR}/" || true
  done
  # preserve CSV template too for audit
  cp -a "${ROOT}/archive/docs/13_placeholders_INPUT_TEMPLATE.csv" "${BACKUP_DIR}/" 2>/dev/null || true
  echo -e "[RUN][$MODE] v2.0 CRM placeholder pass starting at $(date +%FT%T)\n" | tee -a "${LOG}"
else
  LOG="/dev/stdout"
  BACKUP_DIR="(n/a — ${MODE} mode)"
  echo -e "═══════════════════════════════════════════════════════════"
  echo -e " DRY-RUN / VERIFY MODE. No files will be modified.\n"
fi

# -------- utility: safe_count_matches --------
_safe_count_matches(){
  # $1=ERE pattern, $2=file. Prints exactly one integer.
  local C=0
  if [[ -f "$2" ]]; then
    C=$(grep -cE "$1" "$2" 2>/dev/null) || C=0
  fi
  C=$(printf '%s' "$C" | tail -n 1 | tr -d '[:space:]')
  [[ -z "$C" ]] && C=0
  printf '%s' "$C"
}
_safe_count_fixed(){
  # $1=fixed string (NOT regex)  $2=file
  local C=0
  if [[ -f "$2" ]]; then
    C=$(grep -cF "$1" "$2" 2>/dev/null) || C=0
  fi
  C=$(printf '%s' "$C" | tail -n 1 | tr -d '[:space:]')
  [[ -z "$C" ]] && C=0
  printf '%s' "$C"
}

gsub_fixed(){
  # $1=file  $2=fixed-old   $3=new-str  $4=label (NO regex, NO sed metachar risks)
  local F="$1" OLD="$2" NEW="$3" LABEL="$4"
  if [[ ! -f "$F" ]]; then echo "    ↺ skip missing $(basename "$F"): $LABEL" >> "$LOG" 2>/dev/null; return 0; fi
  local BEFORE AFTER NET
  BEFORE=$(_safe_count_fixed "$OLD" "$F")
  if [[ "$MODE" == "apply" ]]; then
    # python3 str.replace = zero metachar risk (DOIs / ORCIDs may contain & which sed treats badly)
    python3 - "$F" "$OLD" "$NEW" <<'PYEOF'
import sys, pathlib
p, old, new = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
s = p.read_text(encoding='utf-8')
if old in s:
  p.write_text(s.replace(old, new), encoding='utf-8')
PYEOF
  fi
  AFTER=$(_safe_count_fixed "$OLD" "$F")
  NET=$((BEFORE - AFTER))
  echo "  [REPLACE ${LABEL}]  F=$(basename "$F")  before=${BEFORE}  remaining=${AFTER}  net=${NET}" | tee -a "${LOG}"
}

# ================================================================
# PASS 1:  Pre-run SCAN report (always; counts target occurrences)
# ================================================================
echo -e "[SCAN] 13-category placeholder occurrence counts — 7 target files matrix\n"
printf "%-28s  %6s %6s %6s %6s %6s %6s %6s  | %6s\n" "CATEGORY" "README" "RM_CN" "CFF" "REGJ" "MAIN" "SUPPL" "COVER" "SUM"
printf "%-28s  %6s %6s %6s %6s %6s %6s %6s  + %6s\n" "----------------------------" "------" "------" "------" "------" "------" "------" "------" "------"
scan_row(){
  local label="${1:-}" pat="${2:-}"
  local c1 c2 c3 c4 c5 c6 c7 sum
  c1=0; c2=0; c3=0; c4=0; c5=0; c6=0; c7=0; sum=0
  [[ -z "$label" || -z "$pat" ]] && { echo "  ⚠ scan_row called empty label=$label pat=$pat" >>"$LOG" 2>/dev/null; return 0; }
  c1=$(_safe_count_fixed "$pat" "$TGT_README_EN")
  c2=$(_safe_count_fixed "$pat" "$TGT_README_ZH")
  c3=$(_safe_count_fixed "$pat" "$TGT_CIT_CFF")
  c4=$(_safe_count_fixed "$pat" "$TGT_REG_JSON")
  c5=$(_safe_count_fixed "$pat" "$TGT_MAIN_TEX")
  c6=$(_safe_count_fixed "$pat" "$TGT_SUPPL_TEX")
  c7=$(_safe_count_fixed "$pat" "$TGT_COVER_TEX")
  sum=$((c1+c2+c3+c4+c5+c6+c7))
  printf "%-28s  %6s %6s %6s %6s %6s %6s %6s  | %6s\n" "$label" "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7" "$sum"
}
scan_row "OSF.IO/XXXXX"                  "OSF.IO/XXXXX"
scan_row "zenodo.TBD1 (Code)"            "zenodo.TBD1"
scan_row "zenodo.TBD2 (Data)"            "zenodo.TBD2"
scan_row "2026.TBD2 (Paper DOI)"         "crmeth.2026.TBD2"
scan_row "swh:1:dir:TBD"                 "swh:1:dir:TBD"
scan_row "SHA_LONG 40char a3f7c91d…"     "a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"
scan_row "SHA_SHORT 12ch a1b2c3d4e5f6"   "a1b2c3d4e5f6"
scan_row "[HPC CENTER NAME]"             "[HPC CENTER NAME]"
scan_row "[INSTITUTION NAME]"            "[INSTITUTION NAME]"
scan_row "[NAME S1]"                     "[NAME S1]"
scan_row "[NAME S2]"                     "[NAME S2]"
scan_row "[NAME S3]"                     "[NAME S3]"
scan_row "ORCID 6× TBD (CFF TBD-*-ORCID)""TBD-MO-ORCID-TBD"
echo -e "\n[SCAN END] — above counts are what --apply will rewrite.\n" | tee -a "${LOG}"

# ================================================================
# PASS 2:  APPLY replacements (--apply only; longest-first order)
# ================================================================
if [[ "$MODE" == "apply" ]]; then
  echo -e "[APPLY BEGIN] Order: DOI block → SHA → ORCID → HPC/ACK names.\n" | tee -a "${LOG}"
  # -------- DOI block (A1-5) --------
  for F in "${ALL_FILES[@]}"; do
    gsub_fixed "$F" "OSF.IO/XXXXX"                                  "OSF.IO/${OSF_DOI_SHORT}"                     "A1_OSF_SHORT"
    gsub_fixed "$F" "10.5281/zenodo.TBD1"                           "${ZENODO_B1_CODE_DOI}"                       "A2_ZENODO_B1"
    gsub_fixed "$F" "10.5281/zenodo.TBD2"                           "${ZENODO_B2_DATA_DOI}"                       "A3_ZENODO_B2"
    gsub_fixed "$F" "10.1016/j.crmeth.2026.TBD2"                    "${CRM_METHODS_PAPER_DOI}"                    "A4_CRM_DOI"
    # A5: Free-text "Zenodo DOI TBD" appears in archive/manuscript_stale/main.tex L397 (Code Availability table, scripts 01-107).
    # Replace only in .tex files with a proper LaTeX \href + \path hyperlink pointing to the B1 code deposition DOI.
    if [[ "$F" == *.tex ]]; then
      gsub_fixed "$F" \
        "Zenodo DOI TBD" \
        "\\href{https://doi.org/${ZENODO_B1_CODE_DOI}}{\\path{${ZENODO_B1_CODE_DOI}}}" \
        "A5_FREE_ZENODO_TBD_MAINTEX"
    fi
    gsub_fixed "$F" "swh:1:dir:TBD"                                 "${SWH_DIR_ID}"                               "A5_SWH"
  done
  # -------- SHA block (B1-2): only run when PI has filled REAL values in wave-2 (not defaults) --------
  if [[ "$GITHUB_COMMIT_SHA_LONG" != "$__DEF_SHA_LONG__" || "$GITHUB_COMMIT_SHA_SHORT" != "$__DEF_SHA_SHORT__" ]]; then
    for F in "${ALL_FILES[@]}"; do
      gsub_fixed "$F" "a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"     "${GITHUB_COMMIT_SHA_LONG}"                   "B1_SHA_LONG"
      gsub_fixed "$F" "a1b2c3d4e5f6"                                  "${GITHUB_COMMIT_SHA_SHORT}"                  "B2_SHA_SHORT"
    done
  else
    echo "  ↺ skip SHA block (wave-2 not yet filled — LONG/SHORT both sentinel defaults)" | tee -a "${LOG}"
  fi
  # -------- ORCID block (C1-6): two forms each — registry.json (bare) + CITATION.cff (prefixed https://orcid.org/) --------
  _apply_orcid_pair(){
    local FILE="$1" AUTHOR_KEY="$2" BARE_OLD="$3" ORCID_NEW="$4" LABEL="$5"
    # Skip the "default TBD" values so users can replace ORCIDs ONE AT A TIME in waves
    if [[ "$ORCID_NEW" == "TBD-${AUTHOR_KEY}-ORCID-TBD" || -z "$ORCID_NEW" || "$ORCID_NEW" == TBD ]]; then
      echo "    ↺ skip $(basename "$FILE") — ORCID ${LABEL} still TBD" | tee -a "${LOG}"
      return 0
    fi
    # CITATION.cff uses https://orcid.org/BARE form
    gsub_fixed "$FILE" "https://orcid.org/${BARE_OLD}"               "https://orcid.org/${ORCID_NEW}"              "C_${LABEL}_CFF_HTTPS"
    # legacy typo-correction in CITATION.cff: line 42 is TBD-MO-ORCID-TBD on the XU Cheng row (replace both there & in registry)
    gsub_fixed "$FILE" "https://orcid.org/TBD-MO-ORCID-TBD"          "https://orcid.org/${ORCID_NEW}"              "C_${LABEL}_CFF_MO_XU_LEGACY_MOPUP"
    # registry.json uses bare 19-char "XXXX-XXXX-XXXX-XXXX" string
    gsub_fixed "$FILE" "\"orcid\": null"                             "\"orcid\": \"${ORCID_NEW}\""                 "C_${LABEL}_REGISTRY_JSON_NULL_TO_VALUE"
  }
  # We need per-author row in registry.json to match author, not any `"orcid": null`. So we do a different strategy for registry.json
  # (line-by-line via python to avoid rewriting wrong author). CITATION.cff is positional so fixed strings OK.
  # --- CITATION.cff (3 occurrences of TBD-*-ORCID + one legacy MO_onserted_on_Xu_row handled in mopups above)
  gsub_fixed "$TGT_CIT_CFF" "TBD-MO-ORCID-TBD"    "$ORCID_MO_QINGQING"      "C1_MO_CFF_BARE"
  gsub_fixed "$TGT_CIT_CFF" "TBD-CHEN-ORCID-TBD"  "$ORCID_CHEN_PINGBO"      "C2_CHEN_CFF_BARE"
  gsub_fixed "$TGT_CIT_CFF" "TBD-XU-ORCID-TBD"    "$ORCID_XU_CHENG"         "C3_XU_CFF_BARE"
  gsub_fixed "$TGT_CIT_CFF" "TBD-WANG-ORCID-TBD"  "$ORCID_WANG_YA"          "C4_WANG_CFF_BARE"
  gsub_fixed "$TGT_CIT_CFF" "TBD-HU-ORCID-TBD"    "$ORCID_HU_TING"          "C5_HU_CFF_BARE"
  gsub_fixed "$TGT_CIT_CFF" "TBD-SUN-ORCID-TBD"   "$ORCID_SUN_QIAN"         "C6_SUN_CFF_BARE"
  # https prefix form in CITATION.cff — mop up all "https://orcid.org/any-still-TBD"
  for TAG in MO CHEN XU WANG HU SUN; do
    for F in "$TGT_CIT_CFF" "$TGT_README_EN" "$TGT_README_ZH"; do
      [[ -f "$F" ]] || continue
      before=$(grep -cF "https://orcid.org/TBD-${TAG}-ORCID-TBD" "$F" 2>/dev/null || echo 0)
      [[ "$before" -gt 0 ]] && gsub_fixed "$F" "https://orcid.org/TBD-${TAG}-ORCID-TBD" "https://orcid.org/ORCID_${TAG}_TO_BE_BOUND_BELOW"  "C_${TAG}_https_mop_up"
    done
  done
  # Bind the mop-up placeholder just inserted to each real ORCID
  _bind_placeholder(){ local F="$1" OLD="$2" NEW="$3" L="$4"
    if [[ ! -f "$F" ]]; then return 0; fi
    if [[ "$NEW" == TBD-*-ORCID-TBD || "$NEW" == TBD || -z "$NEW" ]]; then
      echo "    ↺ skip $(basename $F) label=$L value=$NEW still TBD" | tee -a "${LOG}"
    else
      gsub_fixed "$F" "$OLD" "$NEW" "$L"
    fi
  }
  for F in "$TGT_CIT_CFF"; do
    _bind_placeholder "$F" "ORCID_MO_TO_BE_BOUND_BELOW"    "$ORCID_MO_QINGQING"    "C1_MO_bind"
    _bind_placeholder "$F" "ORCID_CHEN_TO_BE_BOUND_BELOW"  "$ORCID_CHEN_PINGBO"    "C2_CHEN_bind"
    _bind_placeholder "$F" "ORCID_XU_TO_BE_BOUND_BELOW"    "$ORCID_XU_CHENG"       "C3_XU_bind"
    _bind_placeholder "$F" "ORCID_WANG_TO_BE_BOUND_BELOW"  "$ORCID_WANG_YA"        "C4_WANG_bind"
    _bind_placeholder "$F" "ORCID_HU_TO_BE_BOUND_BELOW"    "$ORCID_HU_TING"        "C5_HU_bind"
    _bind_placeholder "$F" "ORCID_SUN_TO_BE_BOUND_BELOW"   "$ORCID_SUN_QIAN"       "C6_SUN_bind"
  done
  # --- registry.json per-author orcid:python targeted by email (single true source of CRM order)
  if [[ -f "$TGT_REG_JSON" ]]; then
    echo "  [C_ORCID_REGISTRY_JSON] python targeted update by author email (only TBD values touched)" | tee -a "${LOG}"
    python3 - "$TGT_REG_JSON" \
      "$ORCID_MO_QINGQING" "$ORCID_CHEN_PINGBO" "$ORCID_XU_CHENG" \
      "$ORCID_WANG_YA" "$ORCID_HU_TING" "$ORCID_SUN_QIAN" <<'PYEOF'
import sys, json, pathlib, re
p = pathlib.Path(sys.argv[1])
data = json.loads(p.read_text(encoding='utf-8'))
orcids = sys.argv[2:8]
email_to_orcid = {
  "qingqingmo520@tjh.tjmu.edu.cn":  orcids[0],
  "supercpb520@163.com":            orcids[1],
  "watt15629030676@tjh.tjmu.edu.cn":orcids[2],
  "misswangya@hotmail.com":         orcids[3],
  "huting_tj@163.com":              orcids[4],
  "sunqian@tjh.tjmu.edu.cn":        orcids[5],
}
ORCID_RE = re.compile(r'^(\d{4}-){3}\d{3}[\dX]$')
changed = 0
for a in data.get('authors', []):
  e = a.get('email')
  if e in email_to_orcid:
    cand = email_to_orcid[e]
    if cand and ORCID_RE.match(cand):
      if a.get('orcid') != cand:
        a['orcid'] = cand; changed += 1
        print(f"    ✍ ORCID[{a['fn_en']:<14}] → {cand}")
    else:
      print(f"    ↺ ORCID[{a['fn_en']:<14}] skipped — cand={cand!r} not valid ORCID (still TBD wave 1 or typo)")
if changed:
  p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')
print(f"    registry.json ORCID rows updated: {changed}/6")
PYEOF
  fi
  # -------- HPC / ACK / FUNDING legacy block (D1-D5 / 8-10), only manuscript main.tex carries them --------
  for F in "$TGT_MAIN_TEX"; do
    gsub_fixed "$F" "[HPC CENTER NAME]"  "$HPC_CENTER"       "D1_HPC_CENTER"
    gsub_fixed "$F" "[INSTITUTION NAME]" "$HPC_INSTITUTION"  "D2_HPC_INST"
    gsub_fixed "$F" "[NAME S1]"          "$ACK_S1"           "D3_ACK_S1"
    gsub_fixed "$F" "[NAME S2]"          "$ACK_S2"           "D4_ACK_S2"
    gsub_fixed "$F" "[NAME S3]"          "$ACK_S3"           "D5_ACK_S3"
    gsub_fixed "$F" "[FUNDING AGENCY 1]" "$FUNDING_AGENCY_1" "D6_FUND1_AGENCY"
    gsub_fixed "$F" "[GRANT NUMBER 1]"   "$GRANT_1"          "D7_FUND1_GRANT"
    gsub_fixed "$F" "[FUNDING AGENCY 2]" "$FUNDING_AGENCY_2" "D8_FUND2_AGENCY"
    gsub_fixed "$F" "[GRANT NUMBER 2]"   "$GRANT_2"          "D9_FUND2_GRANT"
    gsub_fixed "$F" "[FUNDING AGENCY 3]" "$FUNDING_AGENCY_3" "D10_FUND3_AGENCY"
    gsub_fixed "$F" "[GRANT NUMBER 3]"   "$GRANT_3"          "D11_FUND3_GRANT"
  done
  echo -e "\n[APPLY END]\n" | tee -a "${LOG}"
fi

# ================================================================
# PASS 3:  VERIFY residual placeholders (dry-run / apply / verify-only)
# ================================================================
echo -e "[VERIFY] Residual placeholder scan — ANY NON-ZERO → FAIL (target: 0/0).\n"
RES_TOTAL=0
declare -A FILE_FAIL
declare -A FILE_SCAN
for F in "${ALL_FILES[@]}"; do
  [[ -f "$F" ]] || continue
  FILE_FAIL["$F"]=0
  FILE_SCAN["$F"]=0
done
res_check_fixed(){
  local pat="$1" label="$2"
  for F in "${ALL_FILES[@]}"; do
    [[ -f "$F" ]] || continue
    c=$(_safe_count_fixed "$pat" "$F")
    FILE_SCAN["$F"]=$((FILE_SCAN["$F"] + 1))
    if [[ "$c" -gt 0 ]]; then
      echo "  ✗ RESIDUAL=${c}  label=${label}  pattern='${pat}'  file=$(basename "$F")" | tee -a "${LOG}"
      RES_TOTAL=$((RES_TOTAL + c))
      FILE_FAIL["$F"]=$((FILE_FAIL["$F"] + c))
    fi
  done
}
res_check_ERE(){
  local pat="$1" label="$2"
  for F in "${ALL_FILES[@]}"; do
    [[ -f "$F" ]] || continue
    c=$(_safe_count_matches "$pat" "$F")
    FILE_SCAN["$F"]=$((FILE_SCAN["$F"] + 1))
    if [[ "$c" -gt 0 ]]; then
      echo "  ✗ RESIDUAL=${c}  label=${label}  ERE='${pat}'  file=$(basename "$F")" | tee -a "${LOG}"
      RES_TOTAL=$((RES_TOTAL + c))
      FILE_FAIL["$F"]=$((FILE_FAIL["$F"] + c))
    fi
  done
}
res_check_fixed "OSF.IO/XXXXX"                                   "1_OSF_SHORT"
res_check_fixed "10.5281/zenodo.TBD1"                            "2_ZEN_B1"
res_check_fixed "10.5281/zenodo.TBD2"                            "3_ZEN_B2"
res_check_fixed "crmeth.2026.TBD2"                               "4_CRM_DOI"
res_check_fixed "zenodo.TBD"                                     "2b_ZEN_any_TBD"
res_check_fixed "swh:1:dir:TBD"                                  "5_SWH"
res_check_fixed "a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"      "6_SHA_LONG"
res_check_fixed "a1b2c3d4e5f6"                                   "7_SHA_SHORT"
res_check_fixed "[HPC CENTER NAME]"                              "8_HPC_CENTER"
res_check_fixed "[INSTITUTION NAME]"                             "9_HPC_INST"
res_check_fixed "[NAME S1]"                                      "10_ACK_S1"
res_check_fixed "[NAME S2]"                                      "11_ACK_S2"
res_check_fixed "[NAME S3]"                                      "12_ACK_S3"
res_check_fixed "[FUNDING AGENCY 1]"                             "13_FUND1"
res_check_fixed "[FUNDING AGENCY 2]"                             "14_FUND2"
res_check_fixed "[FUNDING AGENCY 3]"                             "15_FUND3"
res_check_fixed "[GRANT NUMBER 1]"                               "16_GRANT1"
res_check_fixed "[GRANT NUMBER 2]"                               "17_GRANT2"
res_check_fixed "[GRANT NUMBER 3]"                               "18_GRANT3"
res_check_fixed "DOI: TBD"                                       "1b_MANUSCRIPT_ZENODO_DATA_DOI_COLON"
res_check_fixed "Zenodo DOI TBD"                                 "1c_MANUSCRIPT_ZENODO_DOI_IN_TEXT"
res_check_fixed "TBD on submission"                               "1d_MANUSCRIPT_TBD_ON_SUBMISSION"
res_check_ERE   'TBD-(MO|CHEN|XU|WANG|HU|SUN)-ORCID-TBD'         "19_ORCID_CFF_BARE_TBD"
res_check_ERE   'orcid.org/(ORCID_|TBD|XXXX)'                    "20_ORCID_HTTPS_mopups_left"
res_check_fixed '"orcid": null'                                  "21_REGISTRY_JSON_ORCID_NULL_count"
echo ""

# --- per-file fail summary ---
echo -e "[VERIFY per-file summary]\n"
printf "%-55s  %8s  %8s\n" "FILE" "RESIDUAL" "PASS?"
for F in "${ALL_FILES[@]}"; do
  [[ -f "$F" ]] || continue
  fail="${FILE_FAIL[$F]:-0}"
  mark=$([[ "$fail" -eq 0 ]] && echo "✅ PASS" || echo "❌ FAIL($fail)")
  printf "%-55s  %8s  %8s\n" "$F" "$fail" "$mark"
done
echo ""
# CITATION.cff author-row ORCID sanity (for apply mode): count how many authors have a valid https://orcid.org/NNNN-NNNN-NNNN-NNNN
if [[ -f "$TGT_CIT_CFF" ]]; then
  echo "[CITATION.cff ORCID sanity] 作者 7 行 其中含有效 ORCID 的行数:"
  grep -cE 'orcid:\s*"https://orcid.org/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]"' "$TGT_CIT_CFF" || echo 0
  echo "  (Target = 7/7 after wave-2 ORCID delivery.)"
fi
if [[ -f "$TGT_REG_JSON" ]]; then
  echo -e "\n[registry.json ORCID sanity] 7 作者 ORCID:"
  python3 - "$TGT_REG_JSON" <<'PYEOF'
import json, pathlib, sys, re
data = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8'))
OR=re.compile(r'^(\d{4}-){3}\d{3}[\dX]$')
for a in data['authors']:
  o=a.get('orcid')
  ok = "✅" if isinstance(o,str) and OR.match(o) else ("⚠️  empty" if (o is None or o=="") else "❌ bad")
  print(f"  {ok} [{a['order']}] {a['fn_en']:<14} → orcid={o!r}   CRM={a.get('role_tag','')[:28]}")
PYEOF
fi

echo -e "\n════════════════════════════════════════════════════════════════"
if [[ "${RES_TOTAL}" -eq 0 ]]; then
  echo "🏆  [RESULT v2] PLACEHOLDER_ZERO: RES_TOTAL=0.  ALL WRITTEN PLACEHOLDERS ARE 0-RESIDUAL."
  echo "     Backup dir = ${BACKUP_DIR}"
  echo "     Next: (A) pdflatex manuscript × 2 recompile; (B) bash scripts/nmi_final_verify.sh; (C) GitHub Pages main/(root) publish."
  if [[ "$MODE" != "apply" ]]; then echo "     (this was a $MODE run — rerun with --apply to actually persist the DOIs/ORCIDs.)"; fi
  exit 0
else
  echo "❌  [RESULT v2] PLACEHOLDER_FAIL: RES_TOTAL=${RES_TOTAL} residual(s) left."
  echo "     SAFE ROLLBACK (if --apply ran):  cp -a ${BACKUP_DIR}/* ${ROOT}/"
  echo "     Fix PI_FILL section & rerun (recommended order: 6 ORCIDs first wave, then DOI block in wave 2)."
  exit 1
fi
