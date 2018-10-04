% -*- coding: utf-8 -*-
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{eiitfg}[2015/07/03 modified book class for UCLM EII TFG]
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\PassOptionsToClass{11pt,twoside,titlepage,openright,a4paper}{book}
\ProcessOptions\relax
\LoadClass{book}

\makeatletter

\setlength{\unitlength}{1mm}

% https://tug.org/pipermail/pstricks/2011/009122.html
\usepackage{etex}

% Codificación UTF8
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[spanish, es-tabla]{babel}

% Hipervínculos dentro del documento
\usepackage{hyperref}
\usepackage{bookmark}

% Ubicaciones absolutas
\usepackage{float}

\usepackage{caption}
\captionsetup{
  margin=0pt,
  font={footnotesize,stretch=.85},
  labelfont=bf}

\usepackage{datetime2}
\usepackage{graphicx}
\usepackage{multirow}
\usepackage{subfigure}
\usepackage[numbers]{natbib}
\usepackage{appendix}
\usepackage{listings}
\usepackage{longtable}
\usepackage{minted}
\usepackage[export]{adjustbox}
\usepackage{emptypage}
\usepackage{setspace}
\usepackage{times}
\usepackage{xcolor}
\usepackage{enumerate}
\usepackage{textcomp}
\usepackage[nottoc,numbib]{tocbibind}

\usepackage[
  paperwidth=210mm,
  paperheight=297mm,
  left=35mm,right=30mm,
  top=25mm, bottom=25mm,
  marginparwidth=1cm, marginparsep=1cm]{geometry}

\definecolor{gris30}{gray}{0.30}
\definecolor{gris85}{gray}{0.85}
\definecolor{gris20}{gray}{0.20}
\definecolor{gris50}{gray}{0.50}

\setlength{\parskip}{4pt}

\makeatletter
\providecommand*{\input@path}{}
\g@addto@macro\input@path{{memoria/}{memoria/tex/}{memoria/sty/}{tex/}{sty/}}
\makeatother
\graphicspath{{fig/}{memoria/fig/}{memoria/}}

\usepackage{metadata}
\usepackage{licencia}
\usepackage{code}
\usepackage{portada}
\usepackage{entornos}
\usepackage{indices}
\usepackage{admonition}

\pagestyle{headings}
\renewcommand{\bibname}{Referencias}
\bibliographystyle{abbrvnat}
\renewcommand{\appendixname}{Anexo}
\renewcommand{\appendixtocname}{Anexo}
\renewcommand{\appendixpagename}{Anexo}
