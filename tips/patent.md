
@def title="Google Patentsを翻訳してみる"
@def rss_description="![titleimage](/assets/tips/steam-locomotive-4275398_1280.jpg)Google Patentsをスクレイプして翻訳する方法を解説します。"
@def rss_pubdate=Date(2021, 4, 28)
@def published="28 April 2021"
@def rss_category="julia"
@def hasmermaid=true
@def tags=["thirdparty"]
@def isjulia =true

# Google Patentsを翻訳してみる。

\titleimage{/assets/tips/steam-locomotive-4275398_1280.jpg}{https://pixabay.com/illustrations/steam-locomotive-steam-car-4275398/}
\share{tips/pluto/}{Google Patentsを翻訳してみる。}

企業で研究者をやっていると、特許調査と無縁ではいられません。[^1]

日本語の特許ならまだ良いのですが、外国語で書かれた特許を読む場合もあります。

それも、外国語の特許を100件単位でチェックしなければならない事態になるとしたら、仮にその言語が得意であっても、大抵の人は嫌になると思います。

実際に、そのような事態に巻き込まれた私は、時短のために特許の請求項だけ抽出して翻訳する作業をpythonで自動化していました。

juliaでも同様のことができたので、やり方を紹介したいと思います。

ちなみにGoogle Patentsをパースして、Google翻訳するというGoogle先生に完全におんぶにだっこのプログラムです。[^2]


[^1]: 特許を書くこととも無縁ではいられません。

[^2]: chromeの右クリックメニューで翻訳すればいいのに、という突っ込みは無視します。

\toc
## 流れ

プログラムの流れを図示すると、以下のようになります。

\begin{mermaid}
~~~
graph LR
    id1("1. GooglePatentをパースする")
    id2("2. 請求項だけを抜き出す")
    id3("3. 翻訳する")
    id4("4. Pluto.jlで体裁を整える")
    id1-->id2
    id2-->id3
    id3-->id4
~~~
\end{mermaid}

この順に見ていきます。

### Google Patentsをパースする
ここでは[Stupid Patent of the month](https://www.eff.org/ja/deeplinks/2020/08/guitar-villain-ubisoft-patents-basic-teaching-techniques)で紹介された特許例を使ってみます。

最初にサードパーティライブラリのHTTP.jlで特許番号US9839852のURLにアクセスできることを確認します。

~~~<a href="https://github.com/JuliaWeb/HTTP.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/JuliaWeb/HTTP.jl.png" width="460px"></a>~~~

```julia:patent1
using HTTP
patentURL="https://patents.google.com/patent/US9839852"
r=HTTP.request("GET", patentURL)
@show r.status;
```

\prettyshow{patent1}
ステータスが200と表示されたので、アクセスに成功したことがわかります。

次にGumbo.jlを使ってHTMLをパースします。

~~~
<a href="https://github.com/JuliaWeb/Gumbo.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/JuliaWeb/Gumbo.jl.png" width="460px"></a>
~~~

```julia:patent2
using Gumbo
h = parsehtml(String(r.body))
```
\prettyshow{patent2}

## 請求項だけを抜き出す

次にCSSセレクターを使って必要な部分を抽出します。
ここでは、Cascadia.jlを使います。

~~~
<a href="https://github.com/Algocircle/Cascadia.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/Algocircle/Cascadia.jl.png" width="460px"></a>
~~~

たとえば、titleタグの中身を表示したければ以下のようにします。
```julia:patent3
using Cascadia
s = Selector("title")
q = eachmatch(s, h.root)
q[1] |> nodeText |> println
```
\prettyshow{patent3}

タグに囲まれた文章ではなく、href属性を取得したければ以下のようにします。

```julia:patent4
qa = eachmatch(Selector("a"), h.root)
qa[1].attributes["href"] |> println
```
\prettyshow{patent4}

\note{Google Patentの最初のaタグはpdfのダウンロードリンクです。}

Cascadia.jlについては、ドキュメントがまだ充実していないので、気が向いたらまとめを作ってみたいと思います。
いよいよ請求項を抜き出します。

### Google Patentの請求項の構造を確認する
Google Patentのソースを見てみると、請求項は"claims"というクラスのブロック要素の中に記述されていることがわかります。

独立クレームの場合は、その中の"claim"というクラスのブロック要素の中にある"claim"というクラスのブロック要素の中に記述されています。

一方で従属クレームの場合は、"claim-dependent"というクラスのブロック要素の中にある"claim"というクラスのブロック要素の中に記述されています。

クラス名が重複しているので、自分でも何を書いているのかよくわかりません。
図示してみるとわかりやすいです。

\begin{mermaid}
~~~
graph TD
        id1("""div class='claims'""")
        id2("""div class='claim'""")
        id3("""div class='claim'""")
        id4("""div class='claims'""")
        id5("""div class='claim-dependent'""")
        id6("""div class='claim'""")
        subgraph 従属クレーム
        id4-.-id5
        id5---id6
        end
        subgraph 独立クレーム
        id1-.-id2
        id2---id3
        end
~~~
\end{mermaid}

独立請求項だけを抜き出したいときは、``Selector(".claims .claim .claim")``とすればOKです。
実際に最初の請求項を抽出します。

```julia:patent5
using Cascadia
s_claim = Selector(".claims .claim .claim")
q_claim = eachmatch(s_claim, h.root)
claim1 = q_claim[1] |> nodeText 
@show claim1
```
\prettyshow{patent5}

（2021/5/1追記）\marker{すべての特許にこの構造が当てはまるわけではないようです。}

全請求項を抜き出したいときは、claimクラスのdivのidが"CLM-"で始まることに注目して、
```julia:patent5
eachmatch(Selector("""div[id^="CLM-"]"""), h.root)
```
とすればOKでした。

## 翻訳する

親切なひとがGoogle翻訳のパッケージを作ってくれていました。

~~~
<a href="https://github.com/sonicrules1234/GoogleTrans.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/sonicrules1234/GoogleTrans.jl.png" width="460px"></a>
~~~

READMEをみるとわかりますが、使用例の翻訳言語が"ja"になっていて、いかにも英語の苦手な日本人におあつらえ向きのパッケージです。
せっかくなので☆を差し上げておきました。試しに何か訳させてみましょう。

```julia:patent6
using GoogleTrans 
GoogleTrans.translate("おれは人間をやめるぞ!ジョジョーッ!","en") |> println  
```
\prettyshow{patent6}

うまく翻訳できたでしょうか？

\note{
Google翻訳は優秀なのですが、図.をイチジクと訳すのは、本当にやめてほしいと思います。
```julia:patent7
GoogleTrans.translate("Fig. 1 ","ja") |> println  
```
\prettyshow{patent7}
}



## Pluto.jlでWebアプリ化
Pluto.jlは[こちら](/tips/pluto)で紹介したように、HTMLインプットを使って簡単にウェブアプリっぽいものを作ることができます。

これまで紹介した機能をPluto.jlでまとめて、[特許翻訳アプリ](/PlutoNotebook/patenttranslator)っぽいものを作ってみました。[^3]



見た目は下のiframeで表示した通りです。そのままでは動きませんが、右上にある**Edit or run this notebook**
を押すとクラウド上で動かすことが可能です。binderの仕様上、立ち上がりにはちょっと時間がかかります。
(Pluto.jlが使える人は自分のPCで動かすこともできます。)

ただ翻訳するだけではつまらないので、特許のpdfのダウンロードリンク、特許に関するメモを自分で書いてダウンロードできる機能を追加しました。

\lineskip
\iframe{/PlutoNotebook/patenttranslator}


[^3]: MITのComputationalthinkingの授業のPlutoノートブックを参考にしています。

### Pluto.jlでhtmlを生成する
このノートブックでは、請求項の原文と翻訳を表形式で並べて表示しました。
その際には、htmlをjuliaに書かせる必要があって、少々躓きました。[^4]


結果的には、PlutoUI.jlの\marker{HTML関数にdo構文を使ってテキストをぶち込むことで解決できた}ので、紹介しておきます。

```julia:patent8
using PlutoUI
@doc(HTML) |> println
```
\prettyshow{patent8}

do構文を使った例は、iframeの請求項の下で確認できます。

[^4]: ``md"a=$(a)"``はできても``html"a=$(a)"``はできないし、``md"text1"*md"text2"``もできない。ただし、HypertextLiteral.jlを使うと``@htl"$(a)"``ができるらしい。

## まとめ
- Google Patentsのページをパースする方法を紹介した。(HTTP.jl Gumbo.jl Cascadia.jl)
- Google翻訳をjuliaで実行する方法を紹介した。(GoogleTrans.jl)
- Plutoノートブック形式で翻訳アプリとしてまとめてみた。(Pluto.jl PlutoUI.jl)

今回は特許を翻訳するという事例での紹介ですが、要素技術は色々つぶしが効くと思います。誰かの参考になれば幸いです。

\right{めでたしめでたし}


\share{tips/pluto/}{Google Patentsを翻訳してみる。}

\prev{tips/savgol}{ノイズを含むデータの微分 - Savitzky-Golay filter}
\backtotop

{{ addcomments }}
