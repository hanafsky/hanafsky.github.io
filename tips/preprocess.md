@def title="juliaで前処理大全0"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2021,5,30)
@def published="30 May 2021"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true
# juliaで前処理大全をやってみる
@@date
30 May 2021
@@
\titleimage{/assets/tips/preprocess.jpg}{https://pixabay.com/photos/food-salad-raw-carrots-1209503/}
\share{tips/preprocess/}{juliaで前処理大全}

データの前処理をjuliaでやっているのですが、
一冊くらいはちゃんとした前処理の本を読んだほうがいいだろうと思い、ホクソエムにお勤めの方が書かれた
[前処理大全](https://gihyo.jp/book/2018/978-4-7741-9647-3)という本を読んでみました。

この本は、データ解析の場面において、複数の言語を使い分けることを想定して、
SQL、R、pythonの3つの言語でAwesomeなコードの書き方を教えてくれます。
具体的には、メモリに収まらない大規模なデータならSQL、プロトタイピングにはR、
システムへの組み込みにはpythonという具合です。

余談やあとがきも著者の人柄が偲ばれて、とてもおもしろい良い本でした。

今回は自分用にjulia版[^1]のレシピをまとめたいと思います。

## お品書き
長くなるのでカードを作りました。
@@cards
@@row
@@column \textcard{Extraction}{2.抽出}{/tips/preprocess/extraction}@@
@@column \textcard{Aggregation}{3.集約}{/tips/preprocess/aggregation}@@
@@column \textcard{Join}{4.結合}{/tips/preprocess/join}@@
@@column \textcard{Split}{5.分割}{/tips/preprocess/split}@@
@@
@@

## 参考資料
参考資料としては、[Julia 1.0 Programming CookBook](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)の著者のBogumił Kamiński先生のブログと
[Hands-On Design Patterns and Best Practices with Julia](https://www.packtpub.com/product/hands-on-design-patterns-and-best-practices-with-julia/9781838648817)の著者のTom Kwong さんのデータレングリングのvideoとブログを挙げておきます。

- [Blog by Bogumił Kamiński](https://bkamins.github.io/)
- [Tom Kwong's Infinite Loop](https://ahsmart.com/)

Tom Kwong さんのブログには、DataFrames.jlのチートシートがおいてあるので、手元において活用させてもらっています。

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/txme9o0EdLk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~



## ライセンス

データは
[前処理大全のサポートページのデータ](https://github.com/ghmagazine/awesomebook)を利用しました。

~~~
<a href="https://github.com/ghmagazine/awesomebook"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/ghmagazine/awesomebook.png" width="460px"></a>
~~~

別の言語で書くのでライセンスの記載が必要かどうか微妙ですが、素材のデータは利用させていただくので、念のためライセンスを転載します。

>BSD 3-Clause License

>Copyright (c) 2018, Tomomitsu Motohashi
>All rights reserved.

>Redistribution and use in source and binary forms, with or without
>modification, are permitted provided that the following conditions are met:

> Redistributions of source code must retain the above copyright notice, this
>list of conditions and the following disclaimer.

> Redistributions in binary form must reproduce the above copyright notice,
>this list of conditions and the following disclaimer in the documentation
>and/or other materials provided with the distribution.

> Neither the name of the copyright holder nor the names of its
>contributors may be used to endorse or promote products derived from
>this software without specific prior written permission.

>THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
>AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
>IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
>DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
>FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
>DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
>SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
>CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
>OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
>OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[^1]: DataFrames.jlを使いました。大規模なデータについては、JuliaDBを使う選択肢もあるようです。

\right{つづく}
\share{tips/preprocess}{juliaで前処理大全}
\prevnext{/tips/patent}{Google Patents を翻訳してみる。}{/tips/project}{Project環境を作るメリット}
\backtotop

{{ addcomments }}