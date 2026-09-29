#!/usr/bin/env python3
import json, os, sys, datetime as dt_mod
pj, tag, rc, elapsed, ne, fc, ok_str, logf, ckpt = sys.argv[1:10]
try:
    with open(pj) as fh: d = json.load(fh)
except Exception:
    d = {"total":17, "done":0, "failed":0,
         "started_at": dt_mod.datetime.now().isoformat(timespec="seconds"),
         "per_run":[]}
try:
    fc_f = float(fc) if fc and fc.strip() else None
except Exception:
    fc_f = None
pr = {"i":len(d["per_run"])+1, "tag":tag, "rc":int(rc), "elapsed_s":int(elapsed),
      "epochs_done":int(ne), "final_C3L":fc_f, "ok":ok_str=="OK",
      "err":"", "log":logf, "ckpt":ckpt}
d["per_run"].append(pr)
if ok_str == "OK": d["done"] += 1
else: d["failed"] += 1
d["finished_at"] = dt_mod.datetime.now().isoformat(timespec="seconds")
os.makedirs(os.path.dirname(pj), exist_ok=True)
tmp = pj + ".tmp"
with open(tmp, "w") as fh: json.dump(d, fh, ensure_ascii=False, indent=2)
os.replace(tmp, pj)
