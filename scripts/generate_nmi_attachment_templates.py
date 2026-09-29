#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# 生成 NMI 投稿前 8 份 attachments 占位模板 PDF / xlsx
# ----------------------------------------------------------------
# 中文说明：生成命名完全对齐 NMI Portal 要求的 8+ 份标准占位文件，
#           PI 团队只需要「用真实扫描件/数据覆盖同名文件」无需手动改路径。
# English: Generate named attachment templates matching NMI Portal naming;
#           PI team only needs to overwrite each with the real signed/scanned
#           file -- no path changes required.
# ----------------------------------------------------------------
import os, sys, subprocess, shutil, tempfile

ROOT="/Volumes/thinkplus/network/subject1"
ATT=f"{ROOT}/manuscript/attachments"
os.makedirs(ATT, exist_ok=True)

TEX = "/Users/taozhu/Library/TinyTeX/bin/universal-darwin/pdflatex"

def move_cross_device(src, dst):
    # os.replace fails cross-device (/tmp vs thinkplus); use copy+unlink
    if os.path.exists(src):
        shutil.copyfile(src, dst)
        try: os.unlink(src)
        except: pass
        return os.path.getsize(dst)
    raise FileNotFoundError(src)

def pdflatex_to(tex_code, out_pdf_name):
    work = tempfile.mkdtemp(prefix="_nmiatt_")
    base = os.path.basename(out_pdf_name).replace(".pdf","")
    tp = os.path.join(work, f"{base}.tex")
    with open(tp,"w",encoding="utf-8") as f:
        f.write(tex_code)
    # capture_output=False + errors=replace → 避免中文 UnicodeDecodeError
    r = subprocess.run(
        [TEX, "-interaction=nonstopmode", f"-output-directory={work}", tp],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    produced = os.path.join(work, f"{base}.pdf")
    if not os.path.exists(produced):
        # 失败时把 log 打印出尾部 60 行
        logp = os.path.join(work, f"{base}.log")
        if os.path.exists(logp):
            with open(logp,"r",errors="replace") as fl:
                lines = fl.read().splitlines()[-60:]
            print(f"    [pdflatex fail tail] {'/'.join(out_pdf_name.split('/')[-2:])}")
            for l in lines: print(f"    | {l}")
        raise RuntimeError(f"pdflatex produced nothing for {out_pdf_name}")
    sz = move_cross_device(produced, os.path.join(ATT, out_pdf_name))
    shutil.rmtree(work, ignore_errors=True)
    return sz

# =====================================================================
# 共用 preamble
# =====================================================================
PREAMBLE = r"""
\documentclass[11pt,a4paper]{article}
\usepackage[margin=2.3cm]{geometry}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{hyperref,longtable,array,graphicx}
\hypersetup{colorlinks=true,linkcolor=blue,urlcolor=blue}
\pagestyle{plain}
"""

# =====================================================================
# (1) IRB/Ethics 红头豁免
# =====================================================================
print("(1/8) ethics_irb_exemption_IEC-2025-037-EXP.pdf ... ", end="")
print(f"{pdflatex_to(PREAMBLE + r'''
\begin{document}
\begin{center}
{\Huge\textbf{IRB / Ethics Exemption (Placeholder Template)}}\\[8pt]
{\Large\texttt{IEC-2025-037-EXP}\quad--\quad PI replace with institutional red-letterhead scan}
\end{center}
\bigskip
\subsection*{Protocol}
\begin{itemize}
\item \textbf{Committee:} [INSTITUTION NAME] Institutional Ethics Committee (IEC)
\item \textbf{Protocol ID:} \texttt{IEC-2025-037-EXP}
\item \textbf{Title:} Self-Supervised Pretraining on Multi-Cancer Molecular Networks
\item \textbf{Category:} Exempt under 45 CFR 46.102(d)(2) / 46.104 (secondary research on de-identified, publicly released data sets)
\item \textbf{Approval date:} 15 Jun 2026 (PI override with actual)
\item \textbf{Responsible PI:} Tao Zhu (Corresponding Author, zhutao@[INSTITUTION].edu.cn)
\end{itemize}
\subsection*{Rationale}
All data sets (TCGA, GTEx, METABRIC, STRING, Enrichr, GDSC/CCLE, KEGG, ESM-2) are public and fully de-identified. No biological specimens, no human subjects interaction. See two separate dbGaP DUCs (TCGA \texttt{phs000178.v11.p8}, GTEx \texttt{phs000424.v8.p2}) and METABRIC EGA approval uploaded separately; all uses conform to GRU / permitted-use restrictions and no re-identification is attempted.
\subsection*{Signature (PI override)}
\bigskip
\begin{tabular}{ll}
IEC Chair/Secretary signature: & \textit{(redacted -- use real scan)}\\
Institutional seal (red chop): & \textit{(redacted -- use real scan)}\\
Date: & 15 Jun 2026
\end{tabular}
\vfill \small\textit{--- Placeholder PDF; replace with the signed IEC letterhead PDF before Portal upload. ---}
\end{document}
''', "ethics_irb_exemption_IEC-2025-037-EXP.pdf")} bytes ✅")

# =====================================================================
# (2) dbGaP DUC TCGA phs000178
# =====================================================================
def duc_doc(label, phs, uses):
    return PREAMBLE + rf"""
\begin{{document}}
\begin{{center}}
{{\Huge\textbf{{dbGaP Data Use Certification (DUC)}}}}\\[8pt]
{{\Large {label} \quad \texttt{{{phs}}} }}\\[4pt]
\textit{{(PI replace with signed dbGaP-issued DUC PDF)}}
\end{{center}}
\subsection*{{Certification}}
\begin{{enumerate}}
\item \textbf{{Signatory PI:}} Tao Zhu; DAR submitted \textit{{[DATE]}}, approved \textit{{[DATE]}}.
\item \textbf{{Use:}} Secondary computational only; no re-identification; no record linkage that would enable re-ID.
\item \textbf{{Publication rule:}} Only aggregated summary-level results released. No cells with $n<5$ individuals in Source Data.
\item \textbf{{Security:}} Controlled data encrypted at rest (AES-256) on institutional HPC only.
\item \textbf{{Oversight:}} Project-level PI T.Z.; data steward Q3 2026.
\end{{enumerate}}
\subsection*{{Study use (this manuscript)}}
{uses}
\vfill \small\textit{{--- Placeholder DUC PDF; replace with the signed dbGaP PDF you received. ---}}
\end{{document}}
"""

print("(2/8) dbGaP_DUC_TCGA_phs000178_v11_p8.pdf ... ", end="")
print(f"{pdflatex_to(duc_doc('TCGA phs000178.v11.p8 GRU','phs000178.v11.p8',
r'TCGA pan-cancer RNA-seq + clinical, 21 cohorts, $n=10{,}298$ tumours (GRU). Used for: (i) multi-cancer PPI graph construction; (ii) 7-tissue subset 4,998-edge equal-budget graph; (iii) 21-cancer patient-level classification downstream; (iv) PAAD held-out cross-cohort transfer (Methods \\S Downstream).'),
                  'dbGaP_DUC_TCGA_phs000178_v11_p8.pdf')} bytes ✅")

# =====================================================================
# (3) dbGaP DUC GTEx phs000424.v8.p2
# =====================================================================
print("(3/8) dbGaP_DUC_GTEx_phs000424_v8_p2.pdf ... ", end="")
print(f"{pdflatex_to(duc_doc('GTEx phs000424.v8.p2 GRU','phs000424.v8.p2',
r'GTEx v8 multi-tissue normal RNA-seq. Used for tissue-normal gene-expression covariance filtering in Limitations (vii) phantom-edge quantification ($p<10^{{-6}}$ edge thresholding against GTEx permuted null).'),
                  'dbGaP_DUC_GTEx_phs000424_v8_p2.pdf')} bytes ✅")

# =====================================================================
# (4) EGA METABRIC access confirmation
# =====================================================================
print("(4/8) EGA_access_confirmation_METABRIC.pdf ... ", end="")
print(f"{pdflatex_to(PREAMBLE + r'''
\begin{document}
\begin{center}
{\Huge\textbf{EGA Approved-Access Confirmation -- METABRIC}}\\[6pt]
Study \texttt{EGAS00000000083} / Dataset \texttt{EGAD00001001753}\\[4pt]
\textit{(PI replace with actual EGA approval e-mail print + annex D.U.C.)}
\end{center}
\subsection*{Application}
\begin{itemize}
\item PI: Tao Zhu; Affil: [INSTITUTION NAME]
\item Project: Self-Supervised Pretraining on Multi-Cancer Molecular Networks
\item DAC ref: [EGA-REF --- PI fill]
\item Approved: [DATE]
\item Permitted use: Breast cancer ER-status molecular stratification, cross-cohort validation only (Methods \S METABRIC downstream, frozen 70/30 split seed 42).
\item Prohibited: Re-identification / release of any cohort strata smaller than $n<10$ / commercial use.
\end{itemize}
\subsection*{EGA helpdesk excerpt (PI paste actual mail body here)}
\begin{quote}\small
Dear Dr. Zhu, Your DAC-approved access to EGAS00000000083 / EGAD00001001753 (METABRIC) has been activated for listed authorized users (Mo, Chen, Xu). $\dots$
\end{quote}
\vfill \small\textit{--- Placeholder PDF; replace with print-to-PDF of the real EGA e-mail. ---}
\end{document}
''', "EGA_access_confirmation_METABRIC.pdf")} bytes ✅")

# =====================================================================
# (5) Reporting Summary (print of filled md template)
# =====================================================================
print("(5/8) life_sciences_reporting_summary.pdf ... ", end="")
md_path = f"{ATT}/reporting_summary_nmi_fields.md"
try:
    with open(md_path,'r',errors='replace') as f:
        md = f.read()
except:
    md = "(reporting_summary_nmi_fields.md missing)"
# escape for LaTeX verbatim
md_safe = md.replace("\\","\\textbackslash{}").replace("_","\\_").replace("^","\\^")\
           .replace("#","\\#").replace("%","\\%").replace("$","\\$").replace("&","\\&")\
           .replace("~","\\textasciitilde{}").replace("{","\\{").replace("}","\\}")
body_tex = "\n".join(md_safe.split("\n")[:260])
sz = pdflatex_to(PREAMBLE + rf"""
\begin{{document}}
\begin{{center}}
{{\Huge\textbf{{Life Sciences Reporting Summary (NMI Template Print)}}}}\\[4pt]
\textit{{PI: complete every one of the 40 Nature-template fields, re-export the official PDF, overwrite this file.}}
\end{{center}}
\subsection*{{Print of \texttt{{reporting\_summary\_nmi\_fields.md}} (first 260 lines)}}
\begin{{verbatim}}
{body_tex}
\end{{verbatim}}
\vfill \small\textit{{--- Placeholder print; Portal upload must use the official Nature generated PDF. ---}}
\end{{document}}
""", "life_sciences_reporting_summary.pdf")
print(f"{sz} bytes ✅")

# =====================================================================
# (6) CRediT author roles (print of md matrix)
# =====================================================================
print("(6/8) credit_author_roles_statement.pdf ... ", end="")
md_path = f"{ATT}/credit_author_contributions.md"
try:
    with open(md_path,'r',errors='replace') as f:
        md = f.read()
except:
    md = "(credit_author_contributions.md missing)"
md_safe = md.replace("\\","\\textbackslash{}").replace("_","\\_").replace("^","\\^")\
           .replace("#","\\#").replace("%","\\%").replace("$","\\$").replace("&","\\&")\
           .replace("~","\\textasciitilde{}").replace("{","\\{").replace("}","\\}")
sz = pdflatex_to(PREAMBLE + rf"""
\begin{{document}}
\begin{{center}}
{{\Huge\textbf{{CRediT Author Roles (7 $\times$ 14 Taxonomy)}}}}\\[4pt]
\textit{{Must match main.tex L345--346 exactly. Guarantor \textbf{{= Tao Zhu}} (sole).}}
\end{{center}}
\subsection*{{Print of \texttt{{credit\_author\_contributions.md}}}}
\begin{{verbatim}}
{md_safe[:4200]}
\end{{verbatim}}
\vfill \small\textit{{--- Placeholder print; PI corrects role allocations then uses this to tick Portal checkboxes. ---}}
\end{{document}}
""", "credit_author_roles_statement.pdf")
print(f"{sz} bytes ✅")

# =====================================================================
# (7) Significance statement (≤120w; print for team review + Portal paste)
# =====================================================================
print("(7/8) significance_statement_print.pdf ... ", end="")
sig_src = f"{ATT}/significance_statement.tex"
try:
    with open(sig_src,'r',errors='replace') as f:
        sig = f.read()
except:
    sig = "Significance statement."
sig_body = []
capture=False
for line in sig.split("\n"):
    if r"\begin{document}" in line: capture=True; continue
    if r"\end{document}" in line: break
    if capture: sig_body.append(line)
sig_body = "\n".join(sig_body).strip() or sig.strip()
sz = pdflatex_to(PREAMBLE + rf"""
\begin{{document}}
\begin{{center}}
{{\Huge\textbf{{Significance Statement (Significance)}}}}\\[4pt]
Portal paste target; $\leq 120$ words. PI 学术润色后直接贴到 Portal 文本框。
\end{{center}}
\bigskip\noindent {sig_body}
\vfill \small\textit{{--- Team-review print; actual upload is a pure-text Portal paste, not a PDF file. ---}}
\end{{document}}
""", "significance_statement_print.pdf")
print(f"{sz} bytes ✅")

# =====================================================================
# (8) Cover letter unsigned print
# =====================================================================
print("(8/8) cover_letter_print_unsigned.pdf ... ", end="")
cov_src = f"{ROOT}/manuscript/cover_letter.tex"
# compile to ATT; need TEXINPUTS include github_submit/figures (cover_letter usually includes no figures; harmless)
work = tempfile.mkdtemp(prefix="_cover_")
env = os.environ.copy()
env["TEXINPUTS"] = f"{ROOT}/github_submit/figures//:{ROOT}/manuscript//:" + env.get("TEXINPUTS","")
subprocess.run([TEX,"-interaction=nonstopmode",f"-output-directory={work}",cov_src],
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
pdf = os.path.join(work, "cover_letter.pdf")
if not os.path.exists(pdf):
    logp = os.path.join(work, "cover_letter.log")
    if os.path.exists(logp):
        with open(logp,"r",errors="replace") as fl:
            for l in fl.read().splitlines()[-60:]: print(f"    | {l}")
    raise RuntimeError("cover_letter produced no pdf")
sz = move_cross_device(pdf, f"{ATT}/cover_letter_print_unsigned.pdf")
shutil.rmtree(work, ignore_errors=True)
print(f"{sz} bytes ✅  (PI: 7 作者加电子签名后重命名 cover_letter_signed.pdf 上传)")

print("\n8/8 attachments placeholders generated. ls -la:")
for nm in sorted(os.listdir(ATT)):
    p=f"{ATT}/{nm}"
    if os.path.isfile(p):
        print(f"   {os.path.getsize(p):>9d} B   {nm}")
