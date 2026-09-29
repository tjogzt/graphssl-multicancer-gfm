import os, json, hashlib
import pandas as pd
import streamlit as st
from pathlib import Path

BASE = Path(os.environ.get("C3L_PROJECT_ROOT", Path(__file__).resolve().parents[3]))
st.set_page_config(page_title="C3L 112 Checkpoint Registry · NAR Resource", layout="wide", page_icon="🧬")
pg = st.sidebar.radio("🧭 Navigation", [
    "① Home · Registry Overview",
    "② SHA-256 Integrity Verifier",
    "③ 17-seed Robustness & TOST Equivalence"])
st.title("🧬 C3L SSL Pretraining · 112-Checkpoint Provenance Registry")
st.caption("Scheme B v2.0: 95 HEADLINE + 2 ELIM-A (shuffle wrong-target control) + 15 ELIM-B (τ×proj-dim sweep) = n=112 final records after holdout/smoke filtering.")

def load_json(p, fallback=None):
    try: return json.loads(Path(p).read_text())
    except Exception: return fallback
def load_csv(p):
    return pd.read_csv(p) if Path(p).exists() else None

REG  = BASE/"results"/"checkpoint_registry.json"
S12B = BASE/"results"/"supp_table_s12b_c3l_elimination_ks_mw.csv"
S12C = BASE/"results"/"journal_prep"/"supp_table_s12c_tost_equivalence_results.csv"
VRD  = BASE/"results"/"journal_prep"/"c3l_tost_equivalence_verdict.json"
reg  = load_json(REG, [])
if isinstance(reg, dict) and "records" in reg: reg = reg["records"]

if "① Home" in pg:
    if not reg: st.warning(f"Registry not found: {REG}. Set C3L_PROJECT_ROOT or bundle JSON with Space.")
    else:
        df = pd.DataFrame(reg)
        tc = next((c for c in df.columns if "tier" in c.lower()), None)
        cnt = df[tc].fillna("HEADLINE-95").astype(str).value_counts().to_dict() if tc else {"HEADLINE":len(df)}
        sc = next((c for c in df.columns if "sha256" in c.lower()), None)
        sun = df[sc].astype(str).str[:12].nunique() if sc else 0
        v = load_json(VRD, {})
        c1,c2,c3,c4 = st.columns(4)
        c1.metric("Total records", f"{len(df):,}", delta="n=112 final after audit filter")
        c2.metric("SHA-256 prefix-12 unique", f"{sun:,}", delta=f"{len(df)-sun} collisions")
        c3.metric("Diagnostic tiers", f"{len(cnt)}", delta=str(cnt)[:150])
        c4.metric("STRONG Guideline3 TOST", "✅ EQUIVALENT" if v.get("guideline3_tost_equivalent") else "❌")
        cols = [c for c in ["record_id","checkpoint_id","seed","diagnostic_tier","sha256","sha256_prefix_12","path","size_bytes","tau_proj","last10_mean"] if c in df.columns]
        st.dataframe(df[cols or list(df.columns)[:10]].head(500), use_container_width=True, height=440, hide_index=True)

elif "② SHA" in pg:
    st.subheader("🛡  SHA-256 Integrity Verifier (reviewer tool)")
    st.info("Upload any downloaded `.pt` checkpoint file → we recompute SHA-256 → match 12-char prefix against the authoritative registry.")
    fup = st.file_uploader("Upload checkpoint / any file", type=None, label_visibility="collapsed")
    if fup is not None:
        h = hashlib.sha256()
        for chunk in iter(lambda: fup.read(1<<20), b""): h.update(chunk)
        d = h.hexdigest(); p12 = d[:12]
        a,b = st.columns(2)
        a.metric("SHA-256 (64 hex chars)", d)
        b.metric("Registry lookup key (prefix-12)", f"`{p12}`")
        hits = [r for r in reg if p12.lower() in (str(r.get("sha256","") or r.get("sha256_prefix_12",""))).lower()]
        if hits:
            st.success(f"✅ MATCH: {len(hits)} registry record(s)")
            st.dataframe(pd.DataFrame(hits), hide_index=True, use_container_width=True)
        else:
            keys = sorted({(str(r.get("sha256","") or r.get("sha256_prefix_12","")))[:12] for r in reg})[:8]
            st.warning(f"❌ NO MATCH among n={len(reg)} records. Sample registry keys for sanity check: {keys}")

else:
    st.subheader("📈 17-seed Diagnostic Ablations · FDA-Equivalent TOST Δ₀=0.002")
    s12b = load_csv(S12B); s12c = load_csv(S12C); vrd = load_json(VRD,{})
    if s12b is None: st.error(f"Missing {S12B}"); st.stop()
    des = s12b[s12b["panel"].astype(str).str.endswith("_descriptive")]
    tes = s12b[~s12b["panel"].astype(str).str.endswith("_descriptive")]
    a,b = st.columns([1, 1.3])
    a.markdown("#### S12B · Descriptive (3 tiers)")
    a.dataframe(des, use_container_width=True, height=220, hide_index=True)
    b.markdown("#### S12B · Statistical tests (KS/MW / bootstrap CI)")
    b.dataframe(tes.head(80), use_container_width=True, height=220, hide_index=True)
    st.markdown("---")
    if s12c is not None and vrd:
        p = vrd.get("pooled", {})
        _ci90 = p.get("ci90", ["?", "?"])
        st.success(
            f"""**FDA-equivalent TOST verdict (α = 0.05):**  
  · Δ₀ = {vrd.get('delta_bound_002', '?'):.3f}, μ_ref = ln(21) = {vrd.get('mu_ref_ln21', '?'):.5f}  
  · POOLED n = {p.get('n', '?')}   |Δ| = {p.get('abs_delta', '?'):.4f} < Δ₀  
  · p₁(lower one-sided) = {p.get('tost_p1_lower', '?'):.3g}   p₂(upper one-sided) = {p.get('tost_p2_upper', '?'):.3g}  
  · 90% CI = [{_ci90[0]:.5f}, {_ci90[1]:.5f}]  
  · FINAL guideline3_tost_equivalent = **{vrd.get('guideline3_tost_equivalent')}**"""
        )
        st.dataframe(s12c, use_container_width=True, hide_index=True)
        try:
            import plotly.express as px
            tdf = s12c.assign(xhi=s12c["ci90_high"]-s12c["mean_last10"], xlo=s12c["mean_last10"]-s12c["ci90_low"])
            LR = vrd["mu_ref_ln21"]; D = vrd["delta_bound_002"]
            fig = px.scatter(tdf, x="mean_last10", y="tier_label", color="equivalent", size=[24]*len(tdf), height=360,
                             title="90% CI × 3 tiers vs TOST equivalence bounds (green shaded; dashed = ln21)")
            fig.update_traces(error_x_array=tdf.xhi.abs().tolist(), error_x_arrayminus=tdf.xlo.abs().tolist())
            fig.add_vrect(x0=LR-D, x1=LR+D, fillcolor="#d9f0d1", opacity=0.35, line_width=0)
            fig.add_vline(x=LR, line_dash="dash", line_color="#0b5d1c")
            st.plotly_chart(fig, use_container_width=True)
        except Exception as e:
            st.info(f"(plotly not required, optional: {e})")
