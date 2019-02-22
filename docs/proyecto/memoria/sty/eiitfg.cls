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

% Math
\usepackage{amsmath,amssymb,amsfonts}

% Hipervínculos dentro del documento
\usepackage{hyperref}
\usepackage{bookmark}
\usepackage{cleveref}

% Colores
\usepackage[dvipsnames]{xcolor}
\newcommand\myshade{85}
\colorlet{mylinkcolor}{violet}
\colorlet{mycitecolor}{YellowOrange}
\colorlet{myurlcolor}{Aquamarine}

\hypersetup{
  linkcolor  = mylinkcolor!\myshade!black,
  citecolor  = mycitecolor!\myshade!black,
  urlcolor   = myurlcolor!\myshade!black,
  colorlinks = true,
}

% Ubicaciones absolutas
\usepackage{float}

% Máquinas de estado
% \usepackage{graphviz}
\usepackage{tikz}
\usetikzlibrary{automata, positioning, arrows, intersections, calc, shapes.geometric, matrix}
\newcommand{\tikzFSM}
{
  \tikzset{
           initial/.append style={font=\bfseries\itshape},
           every state/.style={thick, fill=gray!15},
           every loop/.append style={looseness=5, min distance=10mm},
           %  edge/.append style={->, black, thick, shorten <=2pt, shorten >=2pt},
           %
           trs/.style={->, black, thick, shorten <=2pt, shorten >=2pt},
           infoNode/.style={rectangle, draw},
           %
           >=stealth,
           font=\scriptsize \itshape, 
           initial text=$ $,
           node distance=3.25cm
          }
}

\usepackage{caption}
\captionsetup{
  margin=0pt,
  font={footnotesize,stretch=.85},
  labelfont=bf}

% Fonts
% \usepackage{times}
\usepackage{tgtermes}

\usepackage{tabularx}
\usepackage{datetime2}
\usepackage{eurosym}
\usepackage{nameref}
\usepackage{svg}
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
