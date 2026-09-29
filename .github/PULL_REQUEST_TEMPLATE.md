## Pull Request Summary

### 🎯 Motivation and Context

*[Why is this change required? What problem does it solve? If it fixes an open issue, please link to the issue here.]*

### ✅ Checklist for Methods-Track Reproducibility Compliance (Cell Reports Methods)

- [ ] **No hard-coded business data or config parameters (except random seeds 42/7/123/21/99 allowed)
- [ ] New scripts follow naming convention: `scripts/NN_description.py` or `scripts/NN_description.R` (NN = 2-digit index)
- [ ] All code + comments in **ENGLISH ONLY** (CJK characters forbidden except `project.md`)
- [ ] If changing a graph-building / training script → 5-seed protocol explicitly documented; at least 1 seed (42) smoke-passed locally
- [ ] README.md 10-command reproduction recipe updated if CLI flags / targets changed
- [ ] `project.md` §3.x ChangeLog appended with Rule13 `▲` marker + date + verifier

### 🔬 What kind of change is it?

Delete irrelevant option:

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation / housekeeping (pipeline/CI)
- [ ] Manuscript / figures / CITATION.cff (no logic changes only

### 🧪 How Has This Been Tested?

```
# Paste the minimal reproduction shell + output tail (至少包含 exit code + final score line
$ bash scripts/nmi_final_verify.sh
...
RESIDUAL_COUNT=0/0   # or paste the relevant lines
```

### 📦 Does the Zenodo / SHA256 Registry

- [ ] If new data files → SHA in `results/checkpoint_registry.json` updated & sha256sum pasted

---
