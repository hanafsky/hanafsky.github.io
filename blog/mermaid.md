+++
title="mermaid.js"
description="フローチャートの書き方メモ"
titleimage="/assets/blog/mermaid.jpg"
imgsrc="https://pixabay.com/photos/mermaid-fantasy-mystical-nature-2456981/"
rss_description="![titleimage](/assets/blog/mermaid.jpg)mermaid.js　フローチャートの書き方メモ"
rss_pubdate=Date(2021, 4, 18)
published="18 April 2021"
rss_category="blog"
hasmermaid=true
hascode=true
tags=["memo"]
isblog=true
+++

{{inserttitle blog mermaid.md}}

\share{blog/mermaid}{mermaid.js フローチャートの書き方メモ}

\toc
## はじめに
フローチャートを書きたいときには、どんなツールを使うのが良いのでしょうか。

以前の私はパワーポイントもしくはイラストレーターで一生懸命作っていましたが、
時短を意識してマークダウンエディターで文書を書くようになってからは、[mermaid](https://mermaid-js.github.io/mermaid/#/)というjavascriptで書かれた描画ツールをよく利用しています。[^1]

mermaidを使うメリットをまとめてみました。
- \marker{ユーザーは図の論理構造だけを考えれば良い。}
- フローチャート以外の図も充実。（ガントチャート、UML図など）
- コードで記述するのでgitで変更差分を管理できる。
- cssやjavascriptの知識があれば、デザインを調整可能。[^2]

それでは、実際に使ってみましょう。

### 使ってみる

簡単な例をみてみましょう。Fig.1はジャンケンの関係を表すフローチャートです。

フローチャート記号もジャンケンのシンボルに似たデザインで合わせてみました。

\begin{mermaid}
~~~
graph LR
  id1([グー])
  id2>チョキ]
  id3{パー}
  id1-->id2
  id2-->id3
  id3-->id1
~~~
\end{mermaid}
~~~<p style="text-align:center">Fig.1 簡単なフローチャートの例</p>~~~

[live editor](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcbiAgICBBW0NocmlzdG1hc10gLS0-fEdldCBtb25leXwgQihHbyBzaG9wcGluZylcbiAgICBCIC0tPiBDe0xldCBtZSB0aGlua31cbiAgICBDIC0tPnxPbmV8IERbTGFwdG9wXVxuICAgIEMgLS0-fFR3b3wgRVtpUGhvbmVdXG4gICAgQyAtLT58VGhyZWV8IEZbZmE6ZmEtY2FyIENhcl0iLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)
もしくは、typoraやVisual Studio Codeなどのマークダウンプレビューが可能なエディターを立ち上げて以下のコードを書いてプレビューします。
するとFig.1のようなグラフを描画できます。live editorでは画像ファイルとしてダウンロードも可能です。

`````markdown
```mermaid
graph LR 
  id1([グー])
  id2>チョキ]
  id3{パー}
  id1-->id2
  id2-->id3
  id3-->id1
```
`````

#### 簡単な説明
まず、フローチャートであることを明示するために``graph``と書きます。その右に書いた
``LR``は"左から右"という意味です。``TD``もしくは``TB``と書くと、上から下へのフローチャートになります。

``id+数字``で書かれたところはフローチャートの要素の名前です。その右側に書いているのが、端子の形と端子の中に書く文字列です。
``id1([グー])``は中にグーと書いた丸端子です。


### HTMLに埋め込む
このサイトのようにHTMLの中でdiv要素の中にコードを記述して直接ウェブページにフローチャートを書くこともできます。

ただし、最後にmermaidのjavascriptを読み込む必要があります。

javascriptファイルは[こちら](https://unpkg.com/browse/mermaid/)からダウンロードできます。

```html

 <div style="text-align:center" class="mermaid"> 
graph LR
  id1([グー])
  id2>チョキ]
  id3{パー}
  id1-->id2
  id2-->id3
  id3-->id1
 </div>

 <script src="mermaid.min.js"></script>
```
\note{
  この記事のように、Franklin.jlでmermaildを使うには、デプロイ時の設定に注意しなければいけません。
  具体的にはdeploy.ymlの中のoptimize()という関数を呼び出す場所で、以下のオプションを指定すればOKです。
  ```julia
  optimize(;minify=false)
  ```
  簡単に説明すると、デフォルトでは余計な改行を省いてhtmlのファイルサイズを小さくする処理が入っているのですが、
  改行によって図の構造を表すmermaidとは相性が悪いので、これを無効化する必要があるということです。
}

## チートシート
フローチャートの記号にはそれぞれ意味があるようです。丸端子は始点終点、◇は分岐といった具合です。

フローチャートの記号の意味と、記号の出力方法の両方を知っていないとmermaidでフローチャートを作ることはできません。

そこで、JIS規格っぽい感じのフローチャートを書くためのチートシート（Fig.2）を作りました。


\begin{mermaid}
~~~
graph TD
  id1(["([はじめ])"])
  id2("(家帰る)")
  id3{"{運動したか？}"}
  id4("(風呂に入る)")
  id5[["[[筋トレ]]"]]
  id6(("((ごはん食べる))"))
  id7(["([寝る])"])
  sub1[["[[筋トレ]]"]]
  sub2[/"[/20回やる\]"\]
  sub3[腕立て伏せ]
  sub4[\"[\20回やる/]"/]
  sub5[/"[/アプリで入力する/]"/]
  sub6[("[(データベースに保存する)]")]
  id1-->id2
  id2-->id3
  id3-->|yes|id4
  id3-->|no|id5
  id5-->id3
  id4-->id6
  id6-->id7
  subgraph 腕立て伏せ20回3セットやる
  sub1---sub2
  sub2-.->sub3
  sub3-.->sub4
  sub4-->sub5
  sub4==>|3セット|sub2
  sub5-->sub6
  end
~~~
\end{mermaid}
~~~<p style="text-align:center">Fig.2 フローチャートのチートシート</p>~~~

フローチャート記号の中に括弧も一緒に記載したので、記号の記述を忘れてもすぐに理解できます。

実際のコードは以下のとおりです。

```
graph TD
  id1(["([はじめ])"])
  id2("(家帰る)")
  id3{"{運動したか？}"}
  id4("(風呂に入る)")
  id5[["[[筋トレ]]"]]
  id6(("((ごはん食べる))"))
  id7(["([寝る])"])
  sub1[["[[筋トレ]]"]]
  sub2[/"[/腕立て伏せ\]"\]
  sub3[腕立て伏せ２０回]
  sub4[\"[\腕立て伏せ/]"/]
  sub5[/"[/アプリで入力する/]"/]
  sub6[("[(データベースに保存する)]")]
  id1-->id2
  id2-->id3
  id3-->|yes|id4
  id3-->|no|id5
  id5-->id3
  id4-->id6
  id6-->id7
  subgraph 腕立て伏せ20回3セットやる
  sub1---sub2
  sub2-.->sub3
  sub3-.->sub4
  sub4-->sub5
  sub4==>|3セット|sub2
  sub5-->sub6
  end
```

## まとめ
コードで管理可能なmermaid.jsを用いたフローチャートの書き方、HTMLへの導入方法、チートシートを書いてみました。

mermaid.jsにはフローチャート以外にもUML図やガントチャート、円グラフを書く機能も用意されています。

機会があれば、こうした機能もブログで使ってみたいと思います。

\right{めでたしめでたし}

[^1]: 2019年に[オープンソース賞](https://osawards.com/javascript/2019)を受賞したとのこと。
[^2]: 本サイトでは、javascriptをいじって色を変えています。このページのソースを見ると調整方法を確認できます。

\share{blog/mermaid}{mermaid.jsのフローチャートメモ}
\prevnext{/blog/hhkb}{HHKBの話}{/blog/jdla}{JDLA認定 G検定・E資格}
\backtotop

{{ addcomments }}