@def title="Pluto.jlでレポートを作る。"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true
# Pluto.jlとは
文章や数式と共にコードとその実行結果を記述することをLiterate Programmingと呼びます。
Literate Programmingの定番はJupyter Notebook(IJulia.jl)ですが、
julia独自のPluto Notebook(Pluto.jl)というものもあります。
pythonへの依存関係もないので、インストールに苦労することも少ないでしょう。

## Installation
インストールはREPLのpkgモードでaddするだけです。
```julia
julia>]
(pkg)>add Pluto
```
juliaモードで以下のようにタイプすれば、サーバーが立ち上がります。
```
julia> Pluto.run()

Opening http://localhost:1234/?secret=X5qmVqFH in your default browser... ~ have fun!

Press Ctrl+C in this terminal to 
stop Pluto
```
## 特徴
### リアクティブであること
### Chromeブラウザで綺麗なpdfに変換可能
### スライドモードも実装できる。
javascriptを利用して、プレゼンテーションモード試すことができます。
ブラウザのjavascriptコンソールでpresent()とタイプすると、
プレゼンテーションモードになります。

また、以下のコードを書いたセルを実行すると、ボタンでプレゼンテーションモードと通常モードを切り替えられます。
```julia
html"<button onclick=present()>Present</button>"
```
プレゼンテーションモードでpdfに変換すると、スライド毎にページが変わることも確認できます。
### コードや実行結果を隠すことができる。
プログラマでない人は、コードを見てもよく分からないので、
ストレスを感じるかもしれません。

## 欠点
### 重い処理に向いていない
Plutoは良くも悪くもリアクティブです。
セルの実行結果を一緒に保存していないので、
ノートブックの立ち上げ時に、全てのコードを実行しようとします。
このため、くそ重いファイルを読み込むような使い方では、時間がかかるので結構イライラします。
また、あるセルの内容を変更すると、そのセルで定義された値を参照する別のセルも自動的に実行されます。
実行する計算内容が軽いものなら大丈夫ですが、実行に時間がかかるセルの内容が変更された場合は、
しばらく身動きがとれなくなります。
この点、実行結果を保存しておけるjupyter notebookの方が安全です。
### コードの場所が分かりにくい。
### マクロが使えないことがある。

## まとめ 
- Pluto