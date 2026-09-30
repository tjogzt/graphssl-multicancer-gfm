#!/usr/bin/env bash
# ============================================================
# 中文说明：C3L (a) 错靶点 + (b) 超参扫描 的 17 条作业串行调度脚本
#          串行模式（默认）：17 runs × ~15 min ≈ 4.8 h，任何普通 8c 工作站可跑
#          并行模式（--parallel）：每 5 runs 一组，建议 ≥20 CPU
# English : Serial dispatcher for 17 C3L-elimination runs.
#           Default: serial (safe for any 8c desktop).
#           Use --parallel to run N runs concurrently on big workstations.
#
# 输出目录：./results/c3l_elimination/ (auto-created)
# 每个 run 输出：
#     log/*.log   — 训练 stdout （99_parse_c3l_results.py 解析入口）
#     ckpt/*.pt  — 训练结束 checkpoint（last10 loss 用于统计）
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS="${ROOT}/github_submit/scripts"
OUT_ROOT="${ROOT}/results/c3l_elimination"
mkdir -p "${OUT_ROOT}/logs" "${OUT_ROOT}/ckpts"
LOG_FILE="${OUT_ROOT}/runbook_$(date +%Y%m%d_%H%M%S).log"

PARALLEL=0
for arg in "$@"; do
  case "$arg" in
    --parallel=*) PARALLEL="${arg#--parallel=}" ;;
    -h|--help)
      cat <<USAGE
Usage: $0 [--parallel=N]
  --parallel=N   Run N C3L-elimination jobs concurrently (default: 0 = serial).
                 Recommend N ≤ floor(CPU_CORES / 6) on CPU-only machines.
Example:
  $0                      # serial ~ 5 h (safe)
  $0 --parallel=5         # big Xeon, ~ 1 h total, 30+ cores recommended
USAGE
      exit 0 ;;
  esac
done

# ---------- Standard training flags (all runs share the same base) ----------
# CRITICAL (2026-09-27 FIX): config.DATA_PROC defaults to a relative path inside
# github_submit/data/processed which does NOT exist in a standalone checkout.
# Always pin to the project-level absolute data directory so every child
# process cannot trigger FileNotFoundError. This was the root cause of the
# first run 10-minutes-of-no-output failure: set -e teardown on FileNotFound
# without any stderr flushed (nice 19 starvation + sandbox permissions).
DATA_ABS="${ROOT}/data/processed"
BASE_FLAGS=(
  --data "${DATA_ABS}/xena_graph_esm.pt"
  --targets "${DATA_ABS}/gene_cancer_targets.pt"
  --epochs 50
  --csp_weight 0.0
  --namr_weight 0.0
  --c3l_weight 1.0
  --log_every 5
  --save_every 50
  --standardize_features
)
# Also apply NICE_ADJUST = 19 (lowest scheduler priority) so the 17 serial
# runs never starve the other 60-thread background workload that was
# already driving 1m load avg ≈ 67 on this 16C machine.
NICE_ADJUST="${NICE_ADJUST:-19}"

# ---------- Job list (17 total) ----------
declare -a RUNS
RUN_IDX=0
# (a) Wrong-targets shuffle × seeds 42, 7
for S in 42 7; do
  OUT="${OUT_ROOT}/ckpts/c3la_shuffle_s${S}_e50.pt"
  LOG="${OUT_ROOT}/logs/c3la_shuffle_s${S}_e50.log"
  CMD=(python3 "${SCRIPTS}/99_c3l_elimination_ablation.py" "${BASE_FLAGS[@]}"
       --seed $S --c3l_shuffle_targets --out "${OUT}")
  RUNS[RUN_IDX++]="A|S${S}|${OUT}|${LOG}|${CMD[*]}"
done
# (b) Hyperparameter sweep: 5 τ × 3 proj = 15 runs
TAUS=(0.05 0.07 0.1 0.2 0.5)
PROJS=(64 128 256)
SEED_B=42
for T in "${TAUS[@]}"; do
  for P in "${PROJS[@]}"; do
    OUT="${OUT_ROOT}/ckpts/c3lb_s${SEED_B}_tau${T//./}_p${P}.pt"
    LOG="${OUT_ROOT}/logs/c3lb_s${SEED_B}_tau${T//./}_p${P}.log"
    CMD=(python3 "${SCRIPTS}/99_c3l_elimination_ablation.py" "${BASE_FLAGS[@]}"
         --seed "${SEED_B}" --c3l_temperature "${T}" --c3l_proj_dim "${P}" --out "${OUT}")
    RUNS[RUN_IDX++]="B|T${T}P${P}|${OUT}|${LOG}|${CMD[*]}"
  done
done

echo "[DISPATCH] $(date +%FT%T) ${#RUNS[@]} C3L elimination runs queued → ${OUT_ROOT}" | tee -a "${LOG_FILE}"
echo "[DISPATCH] parallel=${PARALLEL}  BASE_FLAGS='${BASE_FLAGS[*]}'" | tee -a "${LOG_FILE}"

if [[ "${PARALLEL}" -le 0 ]]; then
  # -------------------------------------------------------
  # SERIAL — safe, any machine
  # -------------------------------------------------------
  I=0
  for R in "${RUNS[@]}"; do
    I=$((I+1))
    IFS='|' read -r TAG META OUT LOG CMD <<<"${R}"
    echo "[RUN ${I}/${#RUNS[@]}] ${TAG} | ${META} | log=${LOG}" | tee -a "${LOG_FILE}"
    mkdir -p "$(dirname "${OUT}")" "$(dirname "${LOG}")"
    set +e
    # Wrap with nice -n NICE_ADJUST to respect background workload on the same host.
    # (The child process already runs python3; nice only affects scheduling class.)
    bash -c "nice -n ${NICE_ADJUST} ${CMD}" >"${LOG}" 2>&1
    RC=$?
    set -e
    if [[ ${RC} -ne 0 ]]; then
      echo "  ✗ FAILED exit=${RC} → tail ${LOG}:" | tee -a "${LOG_FILE}"
      tail -20 "${LOG}" | tee -a "${LOG_FILE}"
    else
      echo "  ✓ OK exit=0  wall=$(tail -5 "${LOG}" | grep -oE 'Wall-clock total:.*' || echo '?')" | tee -a "${LOG_FILE}"
    fi
  done
else
  # -------------------------------------------------------
  # PARALLEL — xargs -P, each job = 1 line, 1-indexed
  # -------------------------------------------------------
  WORK="${OUT_ROOT}/joblist"
  rm -f "${WORK}"
  for R in "${RUNS[@]}"; do
    IFS='|' read -r TAG META OUT LOG CMD <<<"${R}"
    mkdir -p "$(dirname "${OUT}")" "$(dirname "${LOG}")"
    # Each line prints header, runs cmd, captures rc, appends to runbook
    printf "echo '[RUN] %s | %s' | tee -a %s ; { %s ; } >>%s 2>&1 ; RC=$? ; echo \"  [RC %s] %s %s RC=${RC}\" | tee -a %s ; exit ${RC}\n" \
      "${TAG}" "${META}" "${LOG_FILE}" "${CMD}" "${LOG}" "${TAG}" "${META}" "${LOG}" "${LOG_FILE}" \
      >>"${WORK}"
  done
  echo "[PARALLEL] launching xargs -P ${PARALLEL} over $(wc -l <"${WORK}") jobs" | tee -a "${LOG_FILE}"
  # xargs -L 1 shell wrapper
  xargs -0 -n1 -P "${PARALLEL}" -I{} bash -c "{}" < <(tr '\n' '\0' < "${WORK}" | sed 's/\x0$//') \
    >/dev/null 2>&1 || true
fi

echo "════════════════════════════════════════════════════════════" | tee -a "${LOG_FILE}"
echo "[DISPATCH DONE] $(date +%FT%T)  parse next with:" | tee -a "${LOG_FILE}"
echo "    python3 ${SCRIPTS}/99_parse_c3l_results.py ${OUT_ROOT}" | tee -a "${LOG_FILE}"
echo "════════════════════════════════════════════════════════════" | tee -a "${LOG_FILE}"
