# Experiment provenance (review item 5.16)

This file records the version history behind the manuscript numbers so a reader
does not have to reconstruct it from the Results text. The FINAL method is the
plain-decoder NAMR (MSE + 0.1*(1-cosine) reconstruction), standardized ESM-2 PCA-256
features, 500 epochs, seeds {42, 7, 123, 21, 99}. Only runs marked FINAL feed the
headline tables. Earlier/discarded runs are kept here, not in the Results narrative.

## Final protocol (used throughout)
- Graph: 5,000-gene ESM-2 subgraph (544,908 PPI edges) + 21 one-hot cancer nodes
  + 105,000 complete-bipartite gene-cancer edges. Full-scale: 13,881 genes, ESM-2 650M.
- Tasks: NAMR (denoise, sigma=0.5, 15% nodes), CSP (binary PPI link prediction),
  C3L (21-way InfoNCE against real expression-specificity targets).
- Decoder: PLAIN (MLP head: hidden -> feature). The skip-connected decoder is a
  diagnostic only and is NOT used for any headline number.
- Evaluation: known-edge cosine probe (2,000 pos / 2,000 neg, seed 42), KEGG
  pathway-membership AUROC (K=20), K-means recoverability (self-consistency only).

## Version history (discarded / superseded)
1. Skip-connected NAMR decoder (`--decoder skip`, input [h_i; x_noisy_i]):
   reaches low reconstruction loss (0.21) but known-edge AUC 0.601. SUPERSEDED by
   the plain decoder. Checkpoints: results/ablation_real/csp_namr_skipdiag_s42.pt,
   results/namr5_skip_decoder_DISCARDED/namr_only_s123.pt.
2. Early decoder-variant multi-seed runs (full-model same-seed spread 0.534 vs 0.713)
   were produced with the skip decoder and are NOT reproduced by the plain decoder.
3. CUDA-era evaluations (torch 2.7.x / PyG 2.7.x) are the primary numbers; MPS
   (torch 2.13.0 / PyG 2.8.0.post1, Apple M4 Max) is the same-code replication.
   The two platforms agree on rankings; absolute PPI AUC differs at matched seeds
   (full model seed 42: 0.575 CUDA vs 0.708 MPS).
4. Post-audit / pinned-stack: the K-means recoverability and known-edge AUC rows
   were regenerated on a pinned sklearn 1.9.0 stack (seeded random-init HGT
   cluster accuracy 0.4882 vs CUDA-era 0.5755); known-edge AUC is stack-invariant
   (0.6625).

## Reproducibility
- CUDA server: Python 3.11, torch 2.7.x, PyG 2.7.x. GPU model / VRAM / CUDA / cuDNN
  were NOT recorded before the server was retired; the environment file
  (subject1_repo/requirements.txt) pins the Python packages but not the driver.
- MPS: Python 3.11, torch 2.13.0, PyG 2.8.0.post1, sklearn 1.9.0, numpy 2.4.6,
  pandas 3.0.5, Apple M4 Max.
- graph_hash / feature_hash: to be computed by hashing data/processed/xena_graph_esm.pt
  and data/processed/esm2_gene_embeddings.pt (placeholder in run_ledger.json).

## Checkpoint identity audit (2026-09-18)

Every released checkpoint was hashed (SHA256, `results/checkpoint_hashes.json`) and its
**decoder was measured on the checkpoint itself** rather than inferred from the file name
(`results/checkpoint_decoder_map.json`): the NAMR head's first-layer input width is 256 for
the plain decoder and 512 for the skip-connected decoder. Findings:

* The naming convention is unreliable: `*_s7.pt` is the **skip** run of seed 7 and
  `*_s7o.pt` the **plain** run of the same seed.
* Skip-decoder checkpoints in the tree: `csp_namr_skipdiag_s42.pt`, `csp_only.pt`,
  `full_s7.pt`, `namr_only_s7.pt`, `patient_paad.pt`.
* Re-evaluating every per-seed value reproduces the tabulated numbers from **plain** runs:
  CSP+NAMR 0.7136/0.7913/0.5681/0.5523/0.5509 (= Table S12 0.714/0.791/0.568/0.552/0.551);
  Full 0.5752/0.5747/0.7158/0.5538/0.5454 (= 0.575/0.575/0.716/0.554/0.545);
  NAMR-only 0.8578 (namr_only.pt) and 0.8262 (namr_only_s7o.pt).
* `namr_only_s7.pt` (skip, NAMR 1.1351 -> 0.2125) reproduces 0.6012 = the skip bar in Fig. S3.
* Exception, documented in Supplementary Tables S12/S23: the CSP-only **seed-42** checkpoint
  came from a run launched with the skip-decoder flag, but the NAMR objective is disabled in
  that arm (its NAMR loss is identically 0.0000 throughout), so the untrained NAMR head cannot
  affect the encoder and the CSP-only values stand.
* Run logs record neither a decoder flag nor a unique run ID; the release should therefore
  ship a run manifest (arm, seed, checkpoint, decoder, hash, graph file).
