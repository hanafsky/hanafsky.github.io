<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "Toccatina"
@def website_descr = "a web site to share information mainly about julia-lang"
@def website_url   = "https://lethal8723.github.io/"

@def author = "Kei Hanafusa"

@def mintoclevel = 2

@def hasmermaid = false
<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["node_modules/", "franklin", "franklin.pub"]

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}

\newcommand{\lineskip}{@@blank@@} 
\newcommand{\skipline}{\lineskip} 
\newcommand{\note}[1]{@@note @@title 😲 Note@@ @@content #1 @@ @@}
\newcommand{\success}[1]{@@success @@title 😄 Excellent! @@ @@content #1 @@ @@}
\newcommand{\warning}[1]{@@warning @@title 😕 Warning! @@ @@content #1 @@ @@}
\newcommand{\danger}[1]{@@danger @@title 😱 Danger! @@ @@content #1 @@ @@}
\newcommand{\compat}[1]{@@compat @@title 😐 Compatible @@ @@content #1 @@ @@}
\newcommand{\right}[1]{~~~ <p style="text-align:right"> #1 </p>~~~}
\newcommand{\center}[1]{~~~ <div style="text-align:center"> #1 </div>~~~}
\newcommand{\mermaid}[1]{~~~ <div style="text-align:center" class="mermaid"> #1 </div>~~~}