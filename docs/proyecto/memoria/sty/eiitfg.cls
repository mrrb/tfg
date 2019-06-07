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

% Custom words
\newcommand{\noWord}[1][]{%
  \ifthenelse{\equal{#1}{}}{{\color{red}\#\#\#\# }}{{\color{red}#1}}%
}

% Fonts
% \usepackage{times}
\usepackage{tgtermes}

% Packages & config
\usepackage{csquotes}
\usepackage{gensymb}
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
\usepackage{dirtree}
\usepackage{float} % Absolute position

\usepackage{caption}
\captionsetup{
  margin=0pt,
  font={footnotesize,stretch=.85},
  labelfont=bf
}

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


% TikZ package
\usepackage{tikz}
\usetikzlibrary{automata, positioning, arrows, intersections, calc, shapes.geometric, matrix, chains}

% Style of the state machine diagrams
\newcommand{\tikzFSM}
{
  \tikzset{
           initial/.append style={font=\bfseries\itshape},
           every state/.style={thick, fill=gray!15},
           every loop/.append style={looseness=5, min distance=10mm},
           %  edge/.append style={->, black, thick, shorten <=2pt, shorten >=2pt},
           %
           trs/.style={->, black, thick, shorten <=2pt, shorten >=2pt},
           startSty/.style={->, black},
           infoNode/.style={rectangle, draw},
           %
           >=stealth,
           font=\scriptsize \itshape, 
           initial text=$ $,
           node distance=3.25cm
          }
}

% Style of the flow diagrams
\newcommand{\tikzFlow}
{
  \newcommand{\tikzFlowSep}{2cm}
  \tikzset{
          %  every node/.append style={on chain, on grid, align=center, minimum height=4ex, text width=2.5cm},
           every node/.append style={on grid, align=center, minimum height=4ex, text width=2.5cm},
           every join/.style={norm},
           %
           flowBase/.style={draw, fill=gray!15, rectangle, thick},
           flowStart/.style={flowBase, rounded corners},
           flowDecision/.style={flowBase, diamond, aspect=3, node distance=\tikzFlowSep+0.25cm, inner sep=0pt,},
           flowDelay/.style={flowBase},
           flowEnd/.style={flowStart, ellipse},
           flowLine/.style={draw, -latex'},
           flowLineNA/.style={draw, -},
           flowHide/.style={inner sep=0pt},
          %  flowPathTxt/.style={right, anchor=west, xshift=-1.2cm},
          %  flowSmallDist/.append style={node distance=0.75cm},
           %
           >=stealth,
           font=\scriptsize, 
          %  font=\scriptsize \itshape, 
           initial text=$ $,
           node distance=\tikzFlowSep,
          %  start chain=going below,
          }
}

% % Define block styles
% \tikzstyle{decision} = [diamond, draw, fill=orange!20, 
%     text width=2.8cm, text badly centered, node distance=3.2cm, inner sep=0pt, aspect=2]
% \tikzstyle{block} = [rectangle, draw, fill=blue!20, node distance = 2.8cm, text centered, rounded corners, minimum height=4em]
% \tikzstyle{line} = [draw, -latex']
% \tikzstyle{cloud} = [draw, ellipse,fill=red!20, node distance=3cm,
%     minimum height=2em]


\lstset{literate=
  {á}{{\'a}}1 {é}{{\'e}}1 {í}{{\'i}}1 {ó}{{\'o}}1 {ú}{{\'u}}1
  {Á}{{\'A}}1 {É}{{\'E}}1 {Í}{{\'I}}1 {Ó}{{\'O}}1 {Ú}{{\'U}}1
  {à}{{\`a}}1 {è}{{\`e}}1 {ì}{{\`i}}1 {ò}{{\`o}}1 {ù}{{\`u}}1
  {À}{{\`A}}1 {È}{{\'E}}1 {Ì}{{\`I}}1 {Ò}{{\`O}}1 {Ù}{{\`U}}1
  {ä}{{\"a}}1 {ë}{{\"e}}1 {ï}{{\"i}}1 {ö}{{\"o}}1 {ü}{{\"u}}1
  {Ä}{{\"A}}1 {Ë}{{\"E}}1 {Ï}{{\"I}}1 {Ö}{{\"O}}1 {Ü}{{\"U}}1
  {â}{{\^a}}1 {ê}{{\^e}}1 {î}{{\^i}}1 {ô}{{\^o}}1 {û}{{\^u}}1
  {Â}{{\^A}}1 {Ê}{{\^E}}1 {Î}{{\^I}}1 {Ô}{{\^O}}1 {Û}{{\^U}}1
  {Ã}{{\~A}}1 {ã}{{\~a}}1 {Õ}{{\~O}}1 {õ}{{\~o}}1
  {œ}{{\oe}}1 {Œ}{{\OE}}1 {æ}{{\ae}}1 {Æ}{{\AE}}1 {ß}{{\ss}}1
  {ű}{{\H{u}}}1 {Ű}{{\H{U}}}1 {ő}{{\H{o}}}1 {Ő}{{\H{O}}}1
  {ç}{{\c c}}1 {Ç}{{\c C}}1 {ø}{{\o}}1 {å}{{\r a}}1 {Å}{{\r A}}1
  {€}{{\euro}}1 {£}{{\pounds}}1 {«}{{\guillemotleft}}1
  {»}{{\guillemotright}}1 {ñ}{{\~n}}1 {Ñ}{{\~N}}1 {¿}{{?`}}1
}