#!/usr/bin/env bash
# =====================================================================
#  NMI Final Verify - 5 hard metrics 0-fail (本地裸机 /bin/bash)
#  ------------------------------------------------------------------
#  功能：
#   1. 4 阶段 LaTeX 正式编译 main.tex（主文稿）
#   2. 编译 main.tex 后 5 大硬指标 0 fail 验证：
#       ① Err non-Bbbk = 0
#       ② Citation undefined = 0
#       ③ Undefined reference = 0
#       ④ Overfull ≥50pt (non-maketitle) = 0
#       ⑤ Placeholder residual (OSF/TBD/a1b2c3d4/swh/[FUNDING/NAME S/HPC/INSTITUTION]) = 0
#   3. 输出 /tmp/nmi_final_build/NMI_MAIN_FINAL_<TS>.pdf + 拷贝到 manuscript/
#  ------------------------------------------------------------------
#  用法（投稿前 48h 必须跑一次，0-fail 才可 Submission Portal Next）：
#      bash scripts/nmi_final_verify.sh [--skip-build]
#  --skip-build : 跳过 pdflatex 编译，只跑 5 大指标（用于之前已编译过）
# =====================================================================
set -euo pipefail

ROOT="/Volumes/thinkplus/network/subject1"
MAN_DIR="$ROOT/archive/manuscript_stale"
OUT="/tmp/nmi_final_build"
FIG_DIR="$ROOT/github_submit/figures"
TEX="$(command -v pdflatex || ls /Users/taozhu/Library/TinyTeX/bin/*/pdflatex 2>/dev/null | head -1)"

SKIP_BUILD=0
for arg in "$@"; do case "$arg" in
  --skip-build) SKIP_BUILD=1;;
  -h|--help)
    sed -n '1,30p' "$0"
    exit 0;;
esac; done

mkdir -p "$OUT"
export TEXINPUTS="${FIG_DIR}//:${MAN_DIR}//:${TEXINPUTS:-}"

if [[ $SKIP_BUILD -eq 0 ]]; then
  echo "[STEP 1/2] 4-phase pdflatex build (outputs to $OUT) ..."
  rm -f "$OUT/main.aux" "$OUT/main.bbl" "$OUT/main.log" "$OUT/main.out" "$OUT/main.toc" "$OUT/main.pdf"
  cd "$MAN_DIR" >/dev/null
  for i in 1 2 3 4; do
    echo "   pdflatex run $i / 4 ..."
    $TEX -interaction=nonstopmode -output-directory="$OUT" main.tex > "$OUT/run$i.log" 2>&1 \
      || { echo "   ⚠️ pdflatex run $i non-zero (允许 biber step, 查看 $OUT/run$i.log)"; }
    if [[ $i -eq 2 ]]; then
      # 本项目使用 embedded thebibliography，biber 永远不参与。
      # 若 main.bbl 不存在（预期），无任何副作用；Citation undefined=0 即证明 refs OK.
      :
    fi
  done
  TS=$(date +%Y%m%d_%H%M)
  cp "$OUT/main.pdf" "$ROOT/manuscript/NMI_MAIN_FINAL_${TS}.pdf"
  echo "   📦 已拷贝 PDF → $ROOT/manuscript/NMI_MAIN_FINAL_${TS}.pdf"
else
  echo "[STEP 1/2] --skip-build 生效；跳过 pdflatex，使用已存在 $OUT/main.log"
fi

LOG="$OUT/main.log"
MAN_SRC="$MAN_DIR/main.tex"
OUT_TEX="$OUT/main.tex"
# 若 OUT 无 main.tex 则读源文件
CHECK_TEX="$MAN_SRC"
[[ -r "$OUT_TEX" ]] && CHECK_TEX="$OUT_TEX"

echo
echo "[STEP 2/2] 5 HARD METRICS (全部必须 = 0)"
echo "============================================================"
ERR_NON_BBBK=$( (grep -E '^!' "$LOG" 2>/dev/null | grep -cv 'Command \\Bbbk') || true )
ERR_NON_BBBK=$(echo "$ERR_NON_BBBK" | tail -n 1 | tr -d ' \n')
[[ -z "$ERR_NON_BBBK" ]] && ERR_NON_BBBK=0
CU=$( (grep -c 'Citation undefined' "$LOG" 2>/dev/null) || true )
CU=$(echo "$CU" | tail -n 1 | tr -d ' \n')
[[ -z "$CU" ]] && CU=0
UR=$( (grep -c 'Undefined reference' "$LOG" 2>/dev/null) || true )
UR=$(echo "$UR" | tail -n 1 | tr -d ' \n')
[[ -z "$UR" ]] && UR=0
OF50=$(python3 -c "
import re
with open('$LOG','r',errors='ignore') as f: log=f.read()
c=0
for l in log.split(chr(10)):
    if 'Overfull' in l and 'hbox' in l and 'maketitle' not in l:
        m=re.search(r'\((\d+\.\d+)pt\)', l)
        if m and float(m.group(1))>=50.0: c+=1
print(c)")
OF50=$(echo "$OF50" | tail -n 1 | tr -d ' \n')
[[ -z "$OF50" ]] && OF50=0
PH=$( (grep -cE \
  'OSF\.IO/XXXXX|DOI:[[:space:]]*TBD|\[TBD on submission|swh:1:dir:TBD|a3f7c91d4e2b085f6d9a2c4e7b8103956a82f1c4|a1b2c3d4e5f6|\[FUNDING AGENCY|\[GRANT NUMBER|\[NAME S[123]\]|\[HPC CENTER NAME|\[INSTITUTION NAME' \
  "$CHECK_TEX" 2>/dev/null) || true )
PH=$(echo "$PH" | tail -n 1 | tr -d ' \n')
[[ -z "$PH" ]] && PH=0

PASS=1
for metric in \
  "1_LaTeX_errors_(non-Bbbk)=$ERR_NON_BBBK" \
  "2_Citation_undefined=$CU" \
  "3_Undefined_reference=$UR" \
  "4_Overfull_hbox>=50pt_(non_maketitle)=$OF50" \
  "5_Placeholder_residual=$PH"; do
  k=${metric%%=*}; v=${metric##*=}
  if [[ "$v" -eq 0 ]]; then TAG="✅"; else TAG="❌"; PASS=0; fi
  printf "  %-45s = %4s  %s\n" "$k" "$v" "$TAG"
done

echo "============================================================"
TOTAL=$(( ERR_NON_BBBK + CU + UR + OF50 + PH ))
if [[ $PASS -eq 1 ]]; then
  echo "🏆 NMI Final Verify → 5/5 PASS (TOTAL_FAIL=$TOTAL)。可进入 NMI Portal 'Submit Manuscript → Next'."
  [[ -f "$OUT/main.pdf" ]] && pdfinfo "$OUT/main.pdf" 2>/dev/null | grep -E 'Pages|File size' | sed 's/^/  PDF meta: /'
  exit 0
else
  echo "❌ NMI Final Verify → FAIL (TOTAL_FAIL=$TOTAL)。修复后重新运行。"
  [[ $ERR_NON_BBBK -gt 0 ]] && echo "   → 第 1 项：查看 $OUT/run*.log 的 ! 开头错误行，非 Bbbk 要修。"
  [[ $CU         -gt 0 ]] && echo "   → 第 2 项：main.tex \\cite{} 了不存在的 bibitem key。"
  [[ $UR         -gt 0 ]] && echo "   → 第 3 项：main.tex \\ref{} 了不存在的 label。"
  [[ $OF50       -gt 0 ]] && echo "   → 第 4 项：Overfull ≥50pt 非 maketitle；通常长公式或 figure。"
  [[ $PH         -gt 0 ]] && echo "   → 第 5 项：Placeholder 残留；运行 scripts/13_placeholders_replace_and_verify.sh 后重跑本脚本。"
  exit 1
fi
