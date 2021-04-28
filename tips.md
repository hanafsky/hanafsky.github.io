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
@@column \card{/assets/tips/steam-locomotive-4275398_1280.jpg}{GoogleTrans.jl}{Google Patentを翻訳してみる}{/tips/patent} @@
@@column \card{/assets/tips/smooth-3221868_640.jpg}{Savitzky Golay}{ノイジーなデータの微分}{/tips/savgol} @@
@@column \card{/assets/tips/pluto-5962694_640.jpg}{Pluto.jl}{リアクティブなノートブック}{/tips/pluto} @@
@@column \card{/assets/tips/money-franklin.jpg}{Franklin.jl}{静的サイトジェネレーター}{/tips/franklin} @@
@@column \card{/assets/tips/startup.jpg}{startup.jl}{julia 起動時の初期設定}{/tips/startup} @@
@@
@@

\share{tips/}{julia言語に関するトピックまとめ}