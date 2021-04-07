@def title="リアクティブなノートブック Pluto.jl"
@def rss_description="PlutoでLiterate Programmingする方法を説明します。"
@def rss_pubdate=Date(2021, 4, 3)
@def published="3 April 2021"
@def rss_category="julia"

@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# リアクティブなノートブック Pluto.jl
\titleimage{/assets/tips/pluto-5962694_640.jpg}
\share{tips/pluto/}{リアクティブなノートブック Pluto.jl}

文章や数式などのドキュメントと共にコードを記述することをLiterate Programmingと呼びます。
（厳密には違うかもしれませんが）

Literate Programmingの定番はJupyter Notebook(IJulia.jl)ですが、
julia独自のPluto Notebook(Pluto.jl)というものもあります。
pythonへの依存関係もないので、インストールに苦労することも少ないでしょう。

教育への適用が狙いの1つであるようで、julia開発者の1人であるMITの Alan Edelman 先生の
[Computational Thinking](https://computationalthinking.mit.edu/) の授業でも、大いに活用されています。

ちなみに、Plutoはjupyterに対応する名前だと思うので、画像のPlutoは多分関係ありません。

\toc
## インストール方法

インストールは REPL の pkg モードで add するだけです。

```julia
julia>]
(pkg)>add Pluto
```

julia モードで以下のようにタイプすれば、サーバーが立ち上がります。

```
julia> using Pluto; Pluto.run()

Opening http://localhost:1234/?secret=X5qmVqFH in your default browser... ~ have fun!

Press Ctrl+C in this terminal to
stop Pluto
```

## 特徴

[github](https://github.com/fonsp/Pluto.jl)のgif画像やjuliacon2020の動画をみれば、イメージをつかめると思います。

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/IAF8DjrQSSk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

私がとくに特徴的だと感じたことを書いていきます。
### リアクティブであること

Pluto.jl の最大の特徴は、リアクティブであることです。
ある変数の値を変更すると、別のセルでの同じ変数の値も自動的に変更されます。
@bind マクロを使って、変数を html input と連携させることも可能なため、
GUI を実装することも簡単です。

### スライドモードも実装できる。

javascript を利用して、プレゼンテーションモードを試すことができます。
ブラウザのjavascriptコンソールでpresent()とタイプすると、
プレゼンテーションモードになります。

また、以下のコードを書いたセルを実行すると、ボタンでプレゼンテーションモードと通常モードを切り替えられます。

```julia
html"<button onclick=present()>Present</button>"
```

プレゼンテーションモードで pdf に変換すると、スライド毎にページが変わることも確認できます。

### ただのjulia fileである。

Pluto-notebookはただのテキストファイルなので、 gitで変更差分を管理可能です。
Jupyter Notebookの場合は、gitでの変更差分管理が難しくなります。
(gitでipynbを管理するのが大変というのが、Literate.jlの生まれた理由でもあるそうです。)

### コードや実行結果を隠すことができる。

プログラマでない人は、コードを見てもよく分からないので、
ストレスを感じるかもしれません。
セルの左側の目のマークを押すと、コードを隠すことができるので、
冗長な部分を隠して、ドキュメントとしての体裁を整えることができます。

## 欠点

当然良いことばかりではありません。

### 重い処理に向いていない

Plutoはセルの実行結果を一緒に保存していないので、
ノートブックの立ち上げ時に、すべてのコードを実行しようとします。
このため、重い処理を実行したり、くそ重いファイルを読み込むような使い方では、立ち上げに時間がかかるので結構イライラします。

また、リアクティブなので、ある変数の値を変更すると、その変数を使った別のセルの内容も自動的に実行されます。
実行する計算内容が軽いものなら大丈夫ですが、実行に時間がかかるセルの内容が変更された場合は、
しばらく身動きがとれなくなります。
こうした点では、実行結果をセル毎に保存しておける Jupyter Notebook の方がある意味安全です。

### マクロが使えないことがある。

Plutoでは実行できないマクロがあります。
私の場合は、微分方程式のマクロである ParameterizedFunctions.jlを使おうとして、errorがでたことで気づきました。

```julia
f = @ode_def LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a b c d
```

[issue](https://github.com/fonsp/Pluto.jl/issues/196)で詳しく議論されています。
何か抜け道があるのかもしれませんが、
ドメイン固有言語が発達したパッケージの利用には苦労すると思われます。

### 複数行のコード

1つのセルに複数行を入力して実行するためには、`begin`-`end`環境に入れてやる必要があります。

```julia
begin
  a = 1
  println(a)
end
```

jupyterと同じ感覚で使おうとするとミスります。

## Pluto.jl のまとめ

- （良くも悪くも）リアクティブなノートブック。
- マークダウンやhtmlとの連携など、基本的な機能を備えている。
- GUIを実装しやすく、教育用のコンテンツとしても優秀。
- 重い処理や、ドメイン固有言語が発達したパッケージの利用には要注意。
\right{めでたしめでたし}

\share{tips/pluto/}{リアクティブなノートブック Pluto.jl}
\prevnext{tips/pluto/}{リアクティブなノートブック Pluto.jl}{tips/savgol}{ノイズを含むデータの微分 - Savitzky-Golay filter}
\backtotop

{{ addcomments }}