#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
中文说明：极简 C3L (a) 2 + (b) 15 = 17 条作业串行调度器。
          彻底避免 bash suite 的两个陷阱：① nohup + bash -c 缓冲 stdout 导致 log 看起来 0 行；
          ② 父 shell set -e 配合 nice 可能意外退出。每条 run 都由 subprocess.run() 直接启动，
          强制实时 flush（Python 打开文件 buffer=1 line-mode），每条 run 结束写 progress.json。
English : Minimalist 17-run dispatcher for C3L elimination ablations.
          Avoids bash-suite pitfalls: stdout buffering and set -e misfires.
          Each run is launched directly via subprocess.run with line-buffered logs
          and a per-run JSON progress stamp.
用法：
    python3 scripts/dispatch_c3l_17runs_serial.py \
            --root /Volumes/thinkplus/network/subject1 \
            [--nice 19] [--timeout 450]
进度监控 (1min 刷新)：
    watch -n 60 'cat results/c3l_elimination/progress.json'
"""
import argparse
import datetime as dt
import json
import os
import subprocess
import sys
import time


def build_jobs(root):
    dproc = os.path.join(root, "data", "processed")
    script = os.path.join(root, "github_submit", "scripts", "99_c3l_elimination_ablation.py")
    out_root = os.path.join(root, "results", "c3l_elimination")
    os.makedirs(os.path.join(out_root, "logs"), exist_ok=True)
    os.makedirs(os.path.join(out_root, "ckpts"), exist_ok=True)
    base = [
        "--data", os.path.join(dproc, "xena_graph_esm.pt"),
        "--targets", os.path.join(dproc, "gene_cancer_targets.pt"),
        "--epochs", "50",
        "--csp_weight", "0.0",
        "--namr_weight", "0.0",
        "--c3l_weight", "1.0",
        "--log_every", "5",
        "--save_every", "50",
        "--standardize_features",
    ]
    jobs = []
    # (a) wrong-targets shuffle × seeds 42, 7
    for s in (42, 7):
        tag = f"A_S{s}"
        out_pt = os.path.join(out_root, "ckpts", f"run_a_shuffle_seed{s}.pt")
        log_p = os.path.join(out_root, "logs", f"run_a_shuffle_seed{s}.log")
        cmd = ["python3", "-u", script] + base + [
            "--seed", str(s),
            "--c3l_shuffle_targets",
            "--out", out_pt,
        ]
        jobs.append((tag, log_p, out_pt, cmd))
    # (b) 5 τ × 3 proj = 15 runs, seed = 42
    for tau in (0.05, 0.07, 0.1, 0.2, 0.5):
        for proj in (64, 128, 256):
            ts = f"{tau:.2f}".replace(".", "")
            tag = f"B_T{tau:.2f}_P{proj}"
            out_pt = os.path.join(out_root, "ckpts", f"run_b_s42_tau{ts}_p{proj}.pt")
            log_p = os.path.join(out_root, "logs", f"run_b_s42_tau{ts}_p{proj}.log")
            cmd = ["python3", "-u", script] + base + [
                "--seed", "42",
                "--c3l_temperature", f"{tau}",
                "--c3l_proj_dim", f"{proj}",
                "--out", out_pt,
            ]
            jobs.append((tag, log_p, out_pt, cmd))
    return jobs, out_root


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True, help="absolute project root")
    ap.add_argument("--nice", type=int, default=19, help="OS scheduling nice value (19 = lowest)")
    ap.add_argument("--timeout", type=int, default=450, help="per-run timeout in seconds (450 = 7.5 min, 2x safe margin)")
    args = ap.parse_args()

    root = os.path.abspath(args.root)
    nice_prefix = ["nice", "-n", str(args.nice)] if args.nice > 0 else []
    jobs, out_root = build_jobs(root)
    progress_json = os.path.join(out_root, "progress.json")

    print(f"[DISPATCH] {len(jobs)} runs queued → {out_root}")
    print(f"[DISPATCH] nice={args.nice}  per-run timeout={args.timeout}s  ({dt.datetime.now().isoformat(timespec='seconds')})")
    state = {"total": len(jobs), "done": 0, "failed": 0, "started_at": dt.datetime.now().isoformat(timespec="seconds"),
             "per_run": []}

    for i, (tag, log_p, out_pt, cmd) in enumerate(jobs, 1):
        os.makedirs(os.path.dirname(log_p), exist_ok=True)
        os.makedirs(os.path.dirname(out_pt), exist_ok=True)
        full_cmd = nice_prefix + cmd
        start = time.time()
        print(f"\n[RUN {i}/{len(jobs)}] {tag}  log={os.path.basename(log_p)}")
        print(f"        CMD: {' '.join(full_cmd[:6])} ...")
        rc, err_msg = 0, ""
        try:
            # line-buffered text write; pipe stdout/stderr together so python -u flushes show up immediately.
            with open(log_p, "w", buffering=1) as fh:
                fh.write(f"[RUNNER] tag={tag} start={dt.datetime.now().isoformat(timespec='seconds')}\n")
                fh.write(f"[RUNNER] CMD={' '.join(full_cmd)}\n")
                fh.flush()
                proc = subprocess.run(
                    full_cmd, stdout=fh, stderr=subprocess.STDOUT,
                    timeout=args.timeout, cwd=root,
                    env=os.environ, check=False, start_new_session=True,
                )
                rc = proc.returncode
                fh.write(f"[RUNNER] finished rc={rc} elapsed={time.time()-start:.1f}s\n")
        except subprocess.TimeoutExpired as e:
            rc = 124
            err_msg = f"TIMEOUT after {args.timeout}s: {e}"
            with open(log_p, "a") as fh:
                fh.write(f"[RUNNER] {err_msg}\n")
        except Exception as e:
            rc = 255
            err_msg = f"EXCEPTION: {type(e).__name__}: {e}"
        elapsed = time.time() - start
        ok = rc == 0
        state["done"] += 1 if ok else 0
        state["failed"] += 0 if ok else 1
        state["per_run"].append({
            "i": i, "tag": tag, "rc": rc,
            "elapsed_s": round(elapsed, 1),
            "ok": ok, "err": err_msg,
            "log": log_p, "ckpt": out_pt,
        })
        # finalise JSON timestamp after every run so an external watcher always has a complete file.
        state["finished_at"] = dt.datetime.now().isoformat(timespec="seconds")
        tmp = progress_json + ".tmp"
        with open(tmp, "w") as fh:
            json.dump(state, fh, ensure_ascii=False, indent=2)
        os.replace(tmp, progress_json)
        if ok:
            print(f"  ✓ OK  rc=0  elapsed={elapsed:.1f}s")
        else:
            print(f"  ✗ FAIL  rc={rc}  err={err_msg}  tail {os.path.basename(log_p)}:")
            with open(log_p, errors="ignore") as fh:
                lines = fh.readlines()
            for ln in lines[-12:]:
                print("    " + ln.rstrip())
    # summary
    print("\n══════════════════════════════════════════════════════════════")
    print(f"[DISPATCH DONE] {dt.datetime.now().isoformat(timespec='seconds')}")
    print(f"  done={state['done']}/{state['total']}  failed={state['failed']}")
    print(f"  progress JSON: {progress_json}")
    print(f"  next:  python3 {root}/github_submit/scripts/99_parse_c3l_results.py {out_root}")
    return 0 if state["failed"] == 0 else 2


if __name__ == "__main__":
    sys.exit(main())
