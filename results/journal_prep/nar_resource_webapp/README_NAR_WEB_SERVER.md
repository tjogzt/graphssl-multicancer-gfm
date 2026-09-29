# NAR Resource Track Web Server: C3L 112-Checkpoint Registry Explorer
Streamlit 3-page app (Home / SHA Verifier / TOST equivalence).

## Local run
```bash
export C3L_PROJECT_ROOT=/Volumes/thinkplus/network/subject1
cd results/journal_prep/nar_resource_webapp
pip install -r requirements.txt
streamlit run app.py --server.port 8501 --browser.gatherUsageStats false
```

## HuggingFace Spaces deployment (NAR submission required)
1. Create HF Space `labname/c3l-checkpoint-registry` with **Streamlit SDK**.
2. Upload `app.py` + `requirements.txt`.
3. For zero-dependency demo mode, bundle a stripped `checkpoint_registry_demo.json` (10-rows) + S12B/S12C CSVs alongside the Space so reviewers can evaluate UI offline without C3L_PROJECT_ROOT.

## NAR Resource / Web Server Track mandatory compliance: (1) 24/7 public URL (2) Help pages + GIF tutorials (3) Benchmark Table (4) OSI-approved License.
