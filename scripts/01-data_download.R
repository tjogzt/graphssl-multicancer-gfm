# ==========================================================================
# GraphSSL-MultiCancer-GFM 数据自动下载与校验脚本
# Automated data download + integrity verification for B2 Zenodo deposit reproduction.
# --------------------------------------------------------------------------
# R >= 4.3.0; Deps: utils, tools, (optional) BiocManager, TCGAbiolinks, jsonlite, R.utils
# Usage:
#   Rscript scripts/01-data_download.R --out_dir data --mode lite  # 1.8G 40 min METABRIC+STRING
#   Rscript scripts/01-data_download.R --out_dir data --mode full  # 9.7G TCGA+METABRIC+STRING 4-6h
# ==========================================================================
suppressPackageStartupMessages({requireNamespace("utils"); requireNamespace("tools")})
parse_args <- function(argv = commandArgs(trailingOnly = TRUE)) {
  opts <- list(out_dir = "data", mode = "lite", skip_checksum = FALSE)
  for (i in seq_along(argv)) {
    if (argv[[i]] == "--out_dir" && i < length(argv)) opts$out_dir <- argv[[i+1]]
    if (argv[[i]] == "--mode"    && i < length(argv)) opts$mode    <- argv[[i+1]]
    if (argv[[i]] == "--skip_checksum") opts$skip_checksum <- TRUE
  }
  stopifnot(opts$mode %in% c("lite","full")); opts
}
opt <- parse_args()
dir.create(opt$out_dir, recursive = TRUE, showWarnings = FALSE)
msg <- function(...) cat(sprintf(...), sep = "\n")
# ------- 1. STRING DB v12.0 Homo sapiens PPI -------
msg("[1/3] Download STRING PPI v12.0 (3 files, 1.2GB compressed)")
sdir <- file.path(opt$out_dir,"raw","string"); dir.create(sdir, recursive=TRUE, showWarnings=FALSE)
urls <- c(
  "https://stringdb-downloads.org/download/protein.links.full.v12.0/9606.protein.links.full.v12.0.txt.gz",
  "https://stringdb-downloads.org/download/protein.aliases.v12.0/9606.protein.aliases.v12.0.txt.gz",
  "https://stringdb-downloads.org/download/protein.info.v12.0/9606.protein.info.v12.0.txt.gz"
)
for (u in urls) {
  gz <- file.path(sdir, basename(u)); dest <- sub("\\.gz$","",gz)
  if (!file.exists(dest)) {
    if (!file.exists(gz)) utils::download.file(u, gz, mode="wb", method="libcurl")
    if (requireNamespace("R.utils", quietly=TRUE)) R.utils::gunzip(gz, destname=dest, remove=TRUE, overwrite=TRUE)
    else system(sprintf("gunzip -c %s > %s", shQuote(gz), shQuote(dest)))
  }
  msg("  ok: %s (%.1f MB)", dest, file.size(dest)/1048576)
}
# ------- 2. METABRIC BRCA (cBioPortal DataHub GitHub raw) -------
msg("[2/3] Download METABRIC (cBioPortal) ~ 0.9GB")
mdir <- file.path(opt$out_dir,"raw","metabric"); dir.create(mdir, recursive=TRUE, showWarnings=FALSE)
root <- "https://media.githubusercontent.com/media/cBioPortal/datahub/master/public/brca_metabric/"
for (f in c("data_mrna_illumina_microarray.txt","data_clinical_patient.txt","data_clinical_sample.txt","data_CNA.txt","data_mutation.txt")) {
  d <- file.path(mdir, f)
  if (!file.exists(d)) utils::download.file(paste0(root, f), d, mode="wb", method="libcurl")
  msg("  ok: %s (%.1f MB)", d, file.size(d)/1048576)
}
# ------- 3. TCGA 20 cancers STAR-counts + clinical (GDC/TCGAbiolinks) -------
if (opt$mode == "full") {
  msg("[3/3] TCGA 32 cancer types via TCGAbiolinks (Bioc). ETA 3-6h, ~8.7 GB.")
  if (!requireNamespace("BiocManager", quietly=TRUE)) utils::install.packages("BiocManager", repos="https://cloud.r-project.org")
  if (!requireNamespace("TCGAbiolinks", quietly=TRUE)) BiocManager::install("TCGAbiolinks", ask=FALSE, update=FALSE)
  ctypes <- c("ACC","BLCA","BRCA","CESC","CHOL","COAD","DLBC","ESCA","GBM","HNSC",
              "KICH","KIRC","KIRP","LGG","LIHC","LUAD","LUSC","MESO","OV","PAAD",
              "PCPG","PRAD","READ","SARC","SKCM","STAD","TGCT","THCA","THYM","UCEC","UCS","UVM")
  edir <- file.path(opt$out_dir,"raw","tcga","expression"); dir.create(edir, recursive=TRUE, showWarnings=FALSE)
  cdir <- file.path(opt$out_dir,"raw","tcga","clinical");   dir.create(cdir, recursive=TRUE, showWarnings=FALSE)
  gcache <- file.path(opt$out_dir,"raw","tcga","gdc_cache"); dir.create(gcache, recursive=TRUE, showWarnings=FALSE)
  for (ct in ctypes) {
    re <- file.path(edir, sprintf("%s_expression.rds", ct)); rc <- file.path(cdir, sprintf("%s_clinical.rds", ct))
    if (!file.exists(re)) {
      q <- TCGAbiolinks::GDCquery(project = paste0("TCGA-",ct),
                                  data.category = "Transcriptome Profiling",
                                  data.type = "Gene Expression Quantification",
                                  workflow.type = "STAR - Counts")
      TCGAbiolinks::GDCdownload(q, directory = gcache, method="api")
      se <- TCGAbiolinks::GDCprepare(q, directory = gcache, summarizedExperiment = FALSE)
      saveRDS(se, re)
    }
    if (!file.exists(rc)) saveRDS(TCGAbiolinks::GDCquery_clinic(project = paste0("TCGA-",ct), type="clinical"), rc)
    msg("  TCGA-%s cached.", ct)
  }
} else msg("[3/3] --mode=lite: skip TCGA full download. Use --mode full after acceptance.")
# ------- 4. SHA-256 checksum vs manifest.json -------
if (!opt$skip_checksum) {
  mp <- Sys.glob(file.path(opt$out_dir, "..", "data_manifest.json"))
  if (length(mp) >= 1 && requireNamespace("jsonlite", quietly=TRUE)) {
    m <- jsonlite::fromJSON(mp[[1]], simplifyVector=FALSE)
    fail <- 0L
    for (b in names(m$datasets)) for (rec in m$datasets[[b]][["_files"]]) {
      fp <- file.path(opt$out_dir, "..", rec$file)
      if (file.exists(fp) && !is.null(rec$sha256)) {
        got <- tolower(sub("^.*=\\s*","",system(paste("shasum -a 256", shQuote(fp)), intern=TRUE)[[1]]))
        if (got != tolower(rec$sha256)) { fail <- fail+1L; msg("CHECKSUM FAIL: %s", rec$file) }
      }
    }
    msg("[4/4] checksum fails=%d", fail)
  } else msg("[4/4] manifest missing or jsonlite not installed; skip checksum.")
}
msg("DONE.")
