@def title = "Julia Tips"
@def isjulia =true

# Julia Tips

julia言語は、コードを書くのが楽で、実行速度がC言語なみに高速なプログラミング言語です。

データ解析やシミュレーションなどの科学技術計算には長年pythonを利用していましたが、
実行速度に限界を感じ、2018年以降はjulia言語のお世話になっています。

ここではjulia言語の利用中に得た気づきなどをシェアします。


\share{tips/}{julia言語に関するトピックまとめ}

## インストール方法

juliaのインストールは、[公式サイト](https://julialang.org/downloads/)からバイナリファイルをダウンロードして実行するだけです。
下記の動画は、MITのComputational Thinkingの授業の導入ですが、REPL（read eval print loop: 対話的実行環境のこと）の使い方、
パッケージのインストール方法（Pluto.jlの実行方法）を学ぶことが可能です。

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/OOjKEgbt8AI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

## トピック

@@cards
@@row
@@column \card{/assets/tips/agriculture.jpg}{Project.toml}{Project環境を作るメリット}{/tips/project}{3 Oct 2021} @@
@@column \card{/assets/tips/preprocess.jpg}{DataFrames.jl}{juliaで前処理大全をやってみる}{/tips/preprocess}{30 May 2021} @@
@@column \card{/assets/tips/steam-locomotive-4275398_1280.jpg}{GoogleTrans.jl}{Google Patentsを翻訳してみる}{/tips/patent}{28 Apr 2021} @@
@@column \card{/assets/tips/smooth-3221868_640.jpg}{Savitzky Golay}{ノイジーなデータの微分}{/tips/savgol}{5 Apr 2021} @@
@@column \card{/assets/tips/pluto-5962694_640.jpg}{Pluto.jl}{リアクティブなノートブック}{/tips/pluto}{3 Apr 2021} @@
@@column \card{/assets/tips/money-franklin.jpg}{Franklin.jl}{静的サイトジェネレーター}{/tips/franklin}{2 Apr 2021} @@
@@column \card{/assets/tips/startup.jpg}{startup.jl}{julia 起動時の初期設定}{/tips/startup}{1 Apr 2021} @@
@@
@@

\share{tips/}{julia言語に関するトピックまとめ}