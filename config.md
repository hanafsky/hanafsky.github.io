<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->

@def website_title = "Hanafsky.com"
@def website_descr = "a web site to share information mainly about julia-lang"
@def website_url = "https://hanafsky.github.io/"

@def author = "Kei Hanafusa"

@def mintoclevel = 2
@def maxtoclevel = 3

@def hasmermaid = false
@def isblog = false
@def isjulia = false

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
\newcommand{\backtotop}{~~~ <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button> ~~~}
\newcommand{\mytoc}{
\center{目次}
\toc
}
\newcommand{\html}[1]{~~~#1~~~}
\newenvironment{center}{
\html{<div style="text-align:center">}
}{
\html{</div>}
}
\newcommand{\luminous}[1]{

```
<div style="text-align:center">
<a href="#1" class="zoom"><img src="#1" alt=""></a>
</div>
```

}
\newcommand{\card}[3]{
@@card

~~~<p style="text-align:center"><img src="#1" alt="No Image"></p>~~~
  @@container
  \center{#2}
  ~~~
  <p><button class="button" onclick="location.href='#3'">読む</button></p>
  ~~~
  @@
@@
}
\newcommand{\textcard}[3]{
@@card
  @@container
~~~<div style="font-family:yozakura; font-size:200%; text-align:center;padding-top:30pt;padding-bottom:15pt">#1</div>~~~
  @@title
  \center{#2}
  @@
  ~~~
  <p><button class="button" onclick="location.href='#3'">読む</button></p>
  ~~~
  @@
@@
}

\newcommand{\prettyshow}[1]{
@@code-output \output{#1} @@
}


\newcommand{\prevnext}[4]{
~~~
  <div class="prev-next-link">
  <a class="prev-link" href="#1">
    <p class="prev-next-label">前の記事</p>
    <p>
      #2
    </p>
  </a>
  <a class="next-link" href="#3">
    <p class="prev-next-label">次の記事</p>
    <p>
      #4
    </p>
  </a>
</div>
~~~
}
\newcommand{\next}[2]{
  ~~~
  <div class="prev-next-link">
  <a class="next-link" href="#1">
    <p class="prev-next-label">次の記事</p>
    <p>
      #2
    </p>
  </a>
</div>
~~~
}
\newcommand{\prev}[2]{
  ~~~
  <div class="prev-next-link">
  <a class="prev-link" href="#1">
    <p class="prev-next-label">次の記事</p>
    <p>
      #2
    </p>
  </a>
</div>
~~~
}
\newcommand{\yozakura}[1]{
  ~~~<p style="font-family:yozakura;font-size:xx-large">#1</p>~~~
}

\newcommand{\share}[2]{
~~~
<div class="sns-container top">
  <div class="sns-box b-twitter">
    <a href="https://twitter.com/share?url=https://hanafsky.com/!#1&text=!#2&via=HanafusaKei&related=HanafusaKei"
    target="_blank" rel="nofollow"><i class="fab fa-twitter"></i></a></div>
  <div class="sns-box b-facebook">
    <a href="http://www.facebook.com/share.php?u=https://hanafsky.com/!#1" 
    target="_blank" rel="nofollow"><i class="fab fa-facebook"></i></a></div>
  <div class="sns-box b-hatena">
    <a href="http://b.hatena.ne.jp/add?mode=confirm&url=!#1&title=!#2"
    target="_blank" rel="nofollow"><span class="icon-hatena"></span></a></div>
  <div class="sns-box b-pocket">
    <a href="http://getpocket.com/edit?url=!#1&title=!#2"
    rel="nofollow" target="_blank"><i class="fab fa-get-pocket"></i></a></div>
  <div class="sns-box b-feedly">
    <a href='https://feedly.com/i/subscription/!#1'
    target='blank' rel="nofollow"><span class="icon-feedly"></span></a></div>
  <div class="sns-box b-line">
    <a href='https://social-plugins.line.me/lineit/share?url=!#1'
    target='blank' rel="nofollow"><span class="icon-line"></span></a></div>
</div>
~~~
}