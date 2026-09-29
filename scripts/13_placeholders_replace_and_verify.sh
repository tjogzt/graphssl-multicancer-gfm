#!/usr/bin/env bash
# ================================================================
# 中文说明：13 处投稿占位符一键替换 + 残留 0 验证脚本（PI 投稿前 72h 运行）
#          占位符清单（共 13 处，禁止伪造，所有值需 PI 提供）：
#          ┌────────────────────────────────────────────┬────────────────────────────────────────┬──────────┐
#          │ KEY                                        │ 说明                                    │ 出现次数 │
#          ├────────────────────────────────────────────┼────────────────────────────────────────┼──────────┤
#          │ OSF_DOI_SHORT                              │ OSF 5-char handle (after OSF.IO/)        │    5     │
#          │ ZENODO_CODE_DEP_DOI                       │ Zenodo Code+Trained Checkpoints DOI      │    1     │
#          │ ZENODO_DATA_PROC_DOI                      │ Zenodo Processed Data DOI                │    1     │
#          │ ZENODO_SUPPL_DATA_DOI                     │ Zenodo Supplementary Data DOI            │    1     │
#          │ SWH_DIR_ID                                 │ Software Heritage swh:1:dir:<HASH>       │    1     │
#          │ GITHUB_REPO_COMMIT_SHA_LONG                │ GitHub repo 40-char full commit SHA      │    1     │
#          │ OSF_FROZEN_SCRIPT_COMMIT_SHORT             │ Frozen analysis script commit (short)    │    1     │
#          │ FUNDING_AGENCY_1 / GRANT_1                 │ 基金 1 机构 + 编号                       │    1     │
#          │ FUNDING_AGENCY_2 / GRANT_2                 │ 基金 2                                    │    1     │
#          │ FUNDING_AGENCY_3 / GRANT_3                 │ 基金 3                                    │    1     │
#          │ HPC_CENTER / HPC_INSTITUTION               │ HPC 中心 + 依托单位                      │    1     │
#          │ ACK_S1 / ACK_S2 / ACK_S3                   │ 致谢 3 人                                 │    1     │
#          └────────────────────────────────────────────┴────────────────────────────────────────┴──────────┘
#          总计 13 个占位符类型 × 共 17 处文本出现。
# English : One-shot sed + grep-verifier for 13 submission-placeholder replacements
#           (PI runs ~72h before NMI Portal upload). Placeholder values MUST be
#           real IDs — NEVER fabricate OSF/Zenodo/SWH/Git/funders/ack.
# Usage:
#   1) Copy this file, fill real values at the top section.
#   2) Run:  bash scripts/13_placeholders_replace_and_verify.sh
#   3) Check summary. If any RESIDUAL count > 0 → fix source, rerun.
# ================================================================
set -euo pipefail

# ================================================================
# ■■■  PI FILL  SECTION  —  replace ALL of the following values  ■■■
# ================================================================
# OSF pre-registration handle: full DOI is 10.17605/OSF.IO/<THIS>. Get from https://osf.io/<XXXX5>/registrations
OSF_DOI_SHORT="XXXXX"                     # ⚠ MUST BE REAL OSF.IO HANDLE (5 chars, eg "KT6P2")
# Zenodo DOIs: format "10.5281/zenodo.1234567" — minted on submission, available after Zenodo UI "Reserve DOI"
ZENODO_CODE_DEP_DOI="10.5281/zenodo.TBD1" # Code + Trained Checkpoints deposit
ZENODO_DATA_PROC_DOI="10.5281/zenodo.TBD2" # Processed intermediate matrices deposit
ZENODO_SUPPL_DATA_DOI="10.5281/zenodo.TBD3" # Supplementary data deposit
# Software Heritage persistent ID: format swh:1:dir:<40-char lowercase hex> — via https://archive.softwareheritage.org/save
SWH_DIR_ID="swh:1:dir:TBD0000000000000000000000000000000000000"
# GitHub repository state: 40-char full commit SHA pushed the same day OSF was registered
GITHUB_REPO_COMMIT_SHA_LONG="a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"
# Frozen analysis script commit hash (displayed in Results section — can be short 12 chars, or full 40)
OSF_FROZEN_SCRIPT_COMMIT_SHORT="a1b2c3d4e5f6"
# Funding: [3 agencies × 3 grant numbers] — MUST match CRediT author contributions & institution letters
# ▲2026-09-27 PI confirmed: NSFC grants 82403759 (Xu/CX) and 82403616 (Wang/YW). Funding slot 3 is explicitly declared "none" in main.tex Acknowledgements.
FUNDING_AGENCY_1="National Natural Science Foundation of China"; GRANT_1="82403759"
FUNDING_AGENCY_2="National Natural Science Foundation of China"; GRANT_2="82403616"
FUNDING_AGENCY_3="(none declared)"; GRANT_3="(none declared)"
# HPC acknowledgement
HPC_CENTER="[HPC CENTER NAME]"; HPC_INSTITUTION="[INSTITUTION NAME]"
# Acknowledgements — 3 names only
ACK_S1="[NAME S1]"; ACK_S2="[NAME S2]"; ACK_S3="[NAME S3]"
# ================================================================
#  END OF PI FILL SECTION
# ================================================================

# Allow override via env so script can be copied elsewhere (e.g. /tmp mock tests)
# without ROOT auto-derive failing (cross-filesystem mock scenarios).
if [[ -n "${PLACEHOLDER_PROJECT_ROOT:-}" && -d "${PLACEHOLDER_PROJECT_ROOT}" ]]; then
  ROOT="${PLACEHOLDER_PROJECT_ROOT}"
else
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
MANUSCRIPT_TEX="${ROOT}/archive/manuscript_stale/main.tex"
SUPPL_TEX="${ROOT}/manuscript/supplementary.tex"
COVER_TEX="${ROOT}/manuscript/cover_letter.tex"
BACKUP_DIR="${ROOT}/archive/manuscript_stale/placeholder_bak_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${BACKUP_DIR}"
LOG="${BACKUP_DIR}/replacements.log"

# ---------- Backup originals FIRST (non-negotiable, 3-2-1 rule) ----------
for F in "${MANUSCRIPT_TEX}" "${SUPPL_TEX}" "${COVER_TEX}"; do
  cp -a "${F}" "${BACKUP_DIR}/$(basename ${F})"
done
echo "[BACKUP] All 3 source TeX files copied → ${BACKUP_DIR}" | tee "${LOG}"

# ---------- Utility: gsub_with_count (file, pattern, replacement, label) ----------
_safe_count_matches(){
  # $1=pattern, $2=file. Always prints exactly one integer (last-line-only, whitespace-trimmed).
  local C
  C=$(grep -cE "$1" "$2" 2>/dev/null) || C=0
  # Trim newline/whitespace (macOS grep -c + `|| echo 0` double-print guard).
  C=$(printf '%s' "$C" | tail -n 1 | tr -d '[:space:]')
  [[ -z "$C" ]] && C=0
  printf '%s' "$C"
}
gsub(){
  local F="$1" P="$2" R="$3" LABEL="$4"
  local BEFORE AFTER N
  BEFORE=$(_safe_count_matches "$P" "$F")
  # Safe sed delimiter: '%' (never appears in LaTeX / DOIs / placeholder text).
  # Using `|` would collide with regex alternation `|` in pattern.
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' -E "s%${P}%${R}%g" "$F"
  else
    sed -i -E    "s%${P}%${R}%g" "$F"
  fi
  AFTER=$(_safe_count_matches "$P" "$F")
  N=$((BEFORE - AFTER))
  echo "  [REPLACE ${LABEL}]  file=$(basename "$F")  occurrences_before=${BEFORE}  remaining=${AFTER}  net_replaced=${N}" | tee -a "${LOG}"
}

# ---------- 13 replacements, order matters (longest token first) ----------
echo "" | tee -a "${LOG}"
echo "[RUN] Placeholder replacement pass starting at $(date +%FT%T)" | tee -a "${LOG}"
# 1) OSF.IO/XXXXX — replace in main.tex AND cover_letter.tex (pattern ALWAYS fixed to the XXXXX placeholder text, never interpolate the user-supplied value into the match pattern!)
gsub "${MANUSCRIPT_TEX}"  "OSF\.IO/XXXXX"                                 "OSF.IO/${OSF_DOI_SHORT}"  "1_OSF_HANDLE_main"
gsub "${COVER_TEX}"       "OSF\.IO/XXXXX"                                 "OSF.IO/${OSF_DOI_SHORT}"  "1_OSF_HANDLE_cover"
# 2) Zenodo DOI 1 - Code + trained checkpoints (Results section L299)
gsub "${MANUSCRIPT_TEX}"  "\[TBD on submission; commit SHA256: see .results.checkpoint_registry.json header\]" "${ZENODO_CODE_DEP_DOI}; commit SHA256: ${GITHUB_REPO_COMMIT_SHA_LONG}"  "2_ZENODO_CODE"
# 3) Zenodo DOI 2 - Data availability L331 (DOI: TBD)
gsub "${MANUSCRIPT_TEX}"  "DOI: TBD"                                       "DOI: ${ZENODO_DATA_PROC_DOI}"  "3_ZENODO_DATA"
# 4) Zenodo DOI 3 - supplementary (if present in cover_letter / suppl)
gsub "${SUPPL_TEX}"       "DOI: TBD|TBD on publication"                    "${ZENODO_SUPPL_DATA_DOI}"  "4_ZENODO_SUPPL"
# 5) Software Heritage swh:1:dir:TBD
gsub "${MANUSCRIPT_TEX}"  "swh:1:dir:TBD"                                  "${SWH_DIR_ID}"  "5_SWH_DIR"
# 6) GitHub commit SHA long (Code availability L334) - fixed 40-char placeholder hex
gsub "${MANUSCRIPT_TEX}"  "a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4"      "${GITHUB_REPO_COMMIT_SHA_LONG}"  "6_GITHUB_SHA_LONG"
# 7) Frozen script commit (Results L90 [a1b2c3d4e5f6]) — TWO LaTeX variants exist: \texttt{[short]} AND \path{short} (no brackets)
gsub "${MANUSCRIPT_TEX}"  "\[a1b2c3d4e5f6\]"                               "[${OSF_FROZEN_SCRIPT_COMMIT_SHORT}]"  "7a_OSF_SCRIPT_COMMIT_brackets"
gsub "${MANUSCRIPT_TEX}"  "\\path\{a1b2c3d4e5f6\}"                          "\\path{${OSF_FROZEN_SCRIPT_COMMIT_SHORT}}"  "7b_OSF_SCRIPT_COMMIT_path_nobrackets"
# 7c) Also patch "\path{a1b2c3d4e5f6}; Zenodo DOI TBD" on KRT row (so Zenodo DOI 1 is also applied here)
gsub "${MANUSCRIPT_TEX}"  "\\path\{a1b2c3d4e5f6\}; Zenodo DOI TBD"         "\\path{${OSF_FROZEN_SCRIPT_COMMIT_SHORT}}; Zenodo DOI ${ZENODO_CODE_DEP_DOI}"  "7c_KRT_Zenodo_bundle"
# 8/9/10) Funding agencies + grant numbers (Acknowledgements L344)
gsub "${MANUSCRIPT_TEX}"  "\[FUNDING AGENCY 1\]"                            "${FUNDING_AGENCY_1}"  "8_FUND1_AGENCY"
gsub "${MANUSCRIPT_TEX}"  "\[GRANT NUMBER 1\]"                              "${GRANT_1}"           "8_FUND1_GRANT"
gsub "${MANUSCRIPT_TEX}"  "\[FUNDING AGENCY 2\]"                            "${FUNDING_AGENCY_2}"  "9_FUND2_AGENCY"
gsub "${MANUSCRIPT_TEX}"  "\[GRANT NUMBER 2\]"                              "${GRANT_2}"           "9_FUND2_GRANT"
gsub "${MANUSCRIPT_TEX}"  "\[FUNDING AGENCY 3\]"                            "${FUNDING_AGENCY_3}"  "10_FUND3_AGENCY"
gsub "${MANUSCRIPT_TEX}"  "\[GRANT NUMBER 3\]"                              "${GRANT_3}"           "10_FUND3_GRANT"
# 11) HPC center + institution
gsub "${MANUSCRIPT_TEX}"  "\[HPC CENTER NAME\]"                             "${HPC_CENTER}"        "11_HPC_CENTER"
gsub "${MANUSCRIPT_TEX}"  "\[INSTITUTION NAME\]"                            "${HPC_INSTITUTION}"   "11_HPC_INSTITUTION"
# 12/13) Acknowledgement names 1/2/3
gsub "${MANUSCRIPT_TEX}"  "\[NAME S1\]"                                     "${ACK_S1}"            "12_ACK_S1"
gsub "${MANUSCRIPT_TEX}"  "\[NAME S2\]"                                     "${ACK_S2}"            "12_ACK_S2"
gsub "${MANUSCRIPT_TEX}"  "\[NAME S3\]"                                     "${ACK_S3}"            "13_ACK_S3"

echo "" | tee -a "${LOG}"
echo "═══════════════════════════════════════════════════════════════" | tee -a "${LOG}"
echo "[VERIFY] Residual placeholder scan — ANY NON-ZERO → FAIL" | tee -a "${LOG}"
RES_TOTAL=0
for PATTERN in \
  "OSF\.IO/XXXXX" \
  "10\.5281/zenodo\.TBD" \
  "DOI:\s*TBD" \
  "swh:1:dir:TBD" \
  "a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4" \
  "\[a1b2c3d4e5f6\]" \
  "path\{a1b2c3d4e5f6\}" \
  "Zenodo DOI TBD" \
  "\[FUNDING AGENCY [1-3]\]" \
  "\[GRANT NUMBER [1-3]\]" \
  "\[HPC CENTER NAME\]" \
  "\[INSTITUTION NAME\]" \
  "\[NAME S[1-3]\]" ; do
  for F in "${MANUSCRIPT_TEX}" "${SUPPL_TEX}" "${COVER_TEX}"; do
    C=$(_safe_count_matches "${PATTERN}" "$F")
    if [[ "${C}" -gt 0 ]]; then
      echo "  ✗ RESIDUAL=${C}  pattern='${PATTERN}'  file=$(basename "$F")" | tee -a "${LOG}"
      RES_TOTAL=$((RES_TOTAL + C))
    fi
  done
done

# 14) Final catch-all: any capital [CAPS ... CAPS] remaining (after standard ones gone).
# Whitelist known bracket tags that appear in Results/Discussion as explicit scientific declarations
# (these are NOT placeholders and must not inflate RES_TOTAL):
#   [NOT EVALUATED], [APPLICABLE], [NOT OBSERVED],
#   [STRONG EVIDENCE], [CONDITIONAL GUIDELINE],
#   [NOT APPLICABLE], [N/A], [REPRODUCIBLE], [TRANSPARENT].
echo "[VERIFY] Catch-all: any remaining [UPPERCASE SPACE UPPERCASE] bracket pairs (whitelist-excluded)…" | tee -a "${LOG}"
_WHITELIST_RE='NOT EVALUATED|STRONG EVIDENCE|CONDITIONAL GUIDELINE|NOT OBSERVED|NOT APPLICABLE|APPLICABLE|REPRODUCIBLE|TRANSPARENT|N/A|STRONG|CONDITIONAL|WEAK|FAIL|PASS|OK|NA|YES|NO'
for F in "${MANUSCRIPT_TEX}" "${SUPPL_TEX}" "${COVER_TEX}"; do
  C=$(_safe_count_matches '\[[A-Z][A-Z0-9 &,\-]{3,}[A-Z0-9]\]' "$F")
  # How many of those are WHITELIST hits? Subtract them.
  W=$( (grep -oE '\[[A-Z][A-Z0-9 &,\-]{3,}[A-Z0-9]\]' "$F" 2>/dev/null | grep -cE "^\[($_WHITELIST_RE)\]$" 2>/dev/null) || true )
  W=$(printf '%s' "$W" | tail -n 1 | tr -d '[:space:]')
  [[ -z "$W" ]] && W=0
  SUSPICIOUS=$((C - W))
  if [[ "${SUSPICIOUS}" -gt 0 ]]; then
    echo "  ⚠ Catch-all=${SUSPICIOUS} (${C} total, ${W} whitelisted) suspicious bracket pairs in $(basename "$F"). Non-whitelist lines:" | tee -a "${LOG}"
    grep -nE '\[[A-Z][A-Z0-9 &,\-]{3,}[A-Z0-9]\]' "$F" 2>/dev/null | grep -vE "^\s*[0-9]+:\s*\[($_WHITELIST_RE)\]\s*$" | head -20 | tee -a "${LOG}" || true
    RES_TOTAL=$((RES_TOTAL + SUSPICIOUS))
  else
    echo "  ✔ Catch-all in $(basename "$F"): C=${C} whitelisted=${W} suspicious=0 (all OK)" | tee -a "${LOG}" >/dev/null
  fi
done

echo "" | tee -a "${LOG}"
if [[ "${RES_TOTAL}" -eq 0 ]]; then
  echo "🏆  [RESULT] PLACEHOLDER_ZERO: ${RES_TOTAL} residual → ALL 13 PLACEHOLDERS REPLACED, 0 RESIDUALS" | tee -a "${LOG}"
  echo "    Backup: ${BACKUP_DIR}" | tee -a "${LOG}"
  echo "    Next → run 2×pdflatex + Final Verify script in PI_DELIVERY_AND_PORTAL_DRYRUN.md Part 3" | tee -a "${LOG}"
  exit 0
else
  echo "❌  [RESULT] PLACEHOLDER_FAIL: ${RES_TOTAL} residual(s) left. See above → fix PI_FILL section or source, rerun." | tee -a "${LOG}"
  echo "    SAFE ROLLBACK:  cp -a ${BACKUP_DIR}/*.tex $(dirname ${MANUSCRIPT_TEX})/ ; cp -a ${BACKUP_DIR}/*.tex $(dirname ${SUPPL_TEX})/" | tee -a "${LOG}"
  exit 1
fi
