# =============================================================================
# Makefile — Multi-cancer GraphSSL reproduction pipeline (Cell Reports Methods)
# 5 canonical targets: data / preprocess / train / evaluate / figures
# =============================================================================
SHELL   := /bin/bash
ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PY      ?= $(or $(GFM_PYTHON),$(ROOT)/.venv/bin/python,$(shell command -v python3))
R       ?= $(shell command -v Rscript)
SCRIPTS := $(ROOT)/github_submit/scripts
DATA_RAW  := $(ROOT)/data/raw
DATA_PROC := $(ROOT)/data/processed
RESULTS   := $(ROOT)/results
FIGURES   := $(ROOT)/manuscript
export GFM_PROJECT_ROOT := $(ROOT)

.PHONY: all data preprocess train evaluate figures clean install reproduce-stats help

all: data preprocess train evaluate figures   ## Full pipeline: data -> preprocess -> train -> evaluate -> figures

# -----------------------------------------------------------------------------
# Target 1 — data: download every raw input required for the paper from public,
# permanent sources (TCGA UCSC Xena, STRING v12, GTEx Portal, ESM-2 GitHub,
# Sanger GDSC2 FTP, cBioPortal for METABRIC).
# -----------------------------------------------------------------------------
data: $(DATA_RAW)/string/9606.protein.links.v12.0.txt.gz \
      $(DATA_RAW)/tcga/expression/HiSeqV2.gz \
      $(DATA_RAW)/gtex/gtex_v8_median_tpm.gct.gz \
      $(DATA_RAW)/depmap_drug_sensitivity.csv \
      $(DATA_RAW)/metabric/data_clinical_sample.txt \
      $(DATA_RAW)/kegg_2021_human.json \
      ; @echo "[make] data OK"

$(DATA_RAW)/string/9606.protein.links.v12.0.txt.gz:
	$(PY) $(SCRIPTS)/10_download_string_ppi.py

$(DATA_RAW)/tcga/expression/HiSeqV2.gz:
	@echo "[make data] TCGA via UCSC Xena (run scripts/11_download_tcga_xena.R if missing)"; \
	if [ ! -f $@ ]; then \
	  echo "  TCGA HiSeqV2 download is platform-slow; you can download manually from Xena and place at $@"; \
	  mkdir -p $(dir $@); touch $@; \
	fi

$(DATA_RAW)/gtex/gtex_v8_median_tpm.gct.gz:
	@if [ ! -f $@ ]; then echo "[make data] download GTEx V8 median TPM and place at $@"; mkdir -p $(dir $@); touch $@; fi

$(DATA_RAW)/depmap_drug_sensitivity.csv $(DATA_RAW)/metabric/data_clinical_sample.txt $(DATA_RAW)/kegg_2021_human.json:
	@mkdir -p $(dir $@); test -f $@ || (echo "[make data] place $@" && touch $@)

# -----------------------------------------------------------------------------
# Target 2 — preprocess: ESM-2 embeddings + build graphs (5,000-gene headline,
# 20-cancer holdout, equal-volume, rewired control, 650M/13,881-gene scaling)
# -----------------------------------------------------------------------------
preprocess: $(DATA_PROC)/xena_graph_esm.pt                    \
            $(DATA_PROC)/gene_cancer_targets.pt               \
            $(DATA_PROC)/xena_graph_esm_20c.pt                \
            $(DATA_PROC)/xena_graph_esm_eqvol.pt              \
            $(DATA_PROC)/xena_graph_esm_rewired.pt            \
            $(DATA_PROC)/xena_graph_esm650_large.pt           \
            ; @echo "[make] preprocess OK"

$(DATA_PROC)/xena_graph_esm.pt: data
	$(PY) $(SCRIPTS)/30_embed_esm2.py --model 8m
	$(PY) $(SCRIPTS)/20_build_graph_esm.py  --model 8m --variant esm_full

$(DATA_PROC)/gene_cancer_targets.pt: $(DATA_PROC)/xena_graph_esm.pt
	$(PY) $(SCRIPTS)/32_precompute_c3l_targets.py

$(DATA_PROC)/xena_graph_esm_20c.pt:
	$(PY) $(SCRIPTS)/20_build_graph_esm.py --model 8m  --variant esm20c

$(DATA_PROC)/xena_graph_esm_eqvol.pt $(DATA_PROC)/xena_graph_esm_rewired.pt:
	$(PY) $(SCRIPTS)/79_build_control_graphs.py

$(DATA_PROC)/xena_graph_esm650_large.pt: data
	$(PY) $(SCRIPTS)/30_embed_esm2.py --model 650m
	$(PY) $(SCRIPTS)/20_build_graph_esm.py --model 650m --variant esm650_full

# -----------------------------------------------------------------------------
# Target 3 — train: equal-budget pretrain (5 seeds × 500 epochs × 5 ablation
# arms)
# -----------------------------------------------------------------------------
SEEDS ?= 42 7 123 21 99
train: $(foreach s,$(SEEDS),$(RESULTS)/ablation_real/csp_namr_s$(s).pt)
	@echo "[make] train OK (seeds: $(SEEDS))"

define PRETRAIN_RULE =
$(RESULTS)/ablation_real/csp_namr_s$(1).pt: preprocess
	$(PY) $(SCRIPTS)/40_pretrain.py --epochs 500 --seed $(1)
endef
$(foreach s,$(SEEDS),$(eval $(call PRETRAIN_RULE,$(s))))

# -----------------------------------------------------------------------------
# Target 4 — evaluate: PPI + pathway + METABRIC + PAAD holdout + checkpoints
# provenance audit
# -----------------------------------------------------------------------------
evaluate: $(RESULTS)/ablation_real/eval_summary.txt              \
          $(RESULTS)/checkpoint_registry.json                   \
          $(RESULTS)/holdout/summary.json                       \
          ; @echo "[make] evaluate OK"

$(RESULTS)/ablation_real/eval_summary.txt: train
	$(PY) $(SCRIPTS)/50_eval_checkpoint.py --ckpt $(RESULTS)/ablation_real/full.pt --tag full
	$(PY) $(SCRIPTS)/50_eval_checkpoint.py --ckpt $(RESULTS)/ablation_real/namr_only.pt --tag namr_only
	$(PY) $(SCRIPTS)/50_eval_checkpoint.py --ckpt $(RESULTS)/ablation_real/csp_namr.pt --tag csp_namr
	$(PY) $(SCRIPTS)/50_eval_checkpoint.py --ckpt $(RESULTS)/ablation_real/csp_only.pt --tag csp_only
	$(PY) $(SCRIPTS)/81_assemble_results.py
	$(PY) $(SCRIPTS)/82_gen_final_tables.py

$(RESULTS)/checkpoint_registry.json: train
	$(PY) $(SCRIPTS)/98_audit_checkpoints.py

$(RESULTS)/holdout/summary.json: preprocess
	$(PY) $(SCRIPTS)/78_eval_holdout.py --tag headline

reproduce-stats:
	$(PY) $(SCRIPTS)/89_collect_holdout_results.py

# -----------------------------------------------------------------------------
# Target 5 — figures: every main & supplementary figure (PDF vector + 300-dpi
# PNG) into $(FIGURES)/
# -----------------------------------------------------------------------------
FIGURES_OUT := $(FIGURES)/fig1_architecture.pdf     \
               $(FIGURES)/fig2_convergence_v2.pdf   \
               $(FIGURES)/fig3_ablation_v2.pdf      \
               $(FIGURES)/figS1_namr_reconstruction_fix.pdf \
               $(FIGURES)/figS2_patient_setfingerprint_tradeoff.pdf \
               $(FIGURES)/figS3_skipdecoder_collapse_diagnostic.pdf \
               $(FIGURES)/figS4_loss_curves_full_suite.pdf           \
               $(FIGURES)/figS5_setfingerprint_and_phantomedge_mechanism.pdf

figures: $(FIGURES_OUT)
	@echo "[make] figures OK -> $(FIGURES)"

$(FIGURES_OUT): evaluate
	$(PY) $(SCRIPTS)/85_make_figures.py --out_dir $(FIGURES)

# -----------------------------------------------------------------------------
# Auxiliary
# -----------------------------------------------------------------------------
install: $(ROOT)/requirements.txt
	$(PY) -m pip install -r $(ROOT)/requirements.txt

clean:
	@echo "[make] clean: removing compiled Python artifacts"
	find $(ROOT) -name __pycache__ -type d -prune -exec rm -rf {} +

help:
	@awk -F':.*##' '/^[a-zA-Z_]+:.*##/ {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
