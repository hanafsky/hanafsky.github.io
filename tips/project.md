@def title="Project.toml"
@def description="Project環境を作るメリット"
@def titleimage="/assets/tips/agriculture.jpg"
@def rss_description="![titleimage](/assets/tips/agriculture.jpg)Project環境を作るメリット"
@def rss_pupdate=Date(2021,10,3)
@def published="3 October 2021"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# Project環境を作るメリット
@@date
3 Oct 2021
@@

\titleimage{/assets/tips/agriculture.jpg}{https://pixabay.com/photos/agriculture-rice-plantation-thailand-1807581/}
\share{tips/project/}{個別のProject環境を作るメリット}

## パッケージ管理システム
juliaのパッケージ管理システムPkg.jlは、Project.tomlとManifest.tomlというTOML(Tom's Opbvious, Minimal Language)で書かれたテキスト形式の設定ファイルを使って、インストールされたパッケージの情報・依存関係を管理しています。[^1]

通常これらのファイルは以下の場所に作成されます。
- windowsの場合: ``%USERPROFILE%.julia\environments\v1.x``
- linuxの場合: ``home/.julia/environments/v1.x``

xのところには実際のバージョン番号が入ります。

juliaのreplを立ち上げたときは、ここを参照するわけですが、
それとは個別のProject環境を作って、別のProject.tomlおよびManifest.tomlを参照することもできます。

今回は\marker{わざわざそのようなことをするメリット}についてまとめておきます。

[^1]: 二つのtomlファイルの中身の詳細については、今回は割愛します。

## Project環境の作り方
メリットについて述べる前にProject環境の作り方を整理しておきます。
たとえば、``plots``というディレクトリで作業しているとします。
以下のようなコードを実行すると、Plots.jlをインストールしたプロジェクト環境を作成できます。

```
PS~~~\plots> julia 
julia>]
(@v1.7) pkg> activate .
(plots) pkg> add Plots
```

juliaのreplを立ち上げて、パッケージモードに移行します。
``activate .``と打つと現在のディレクトリをプロジェクト環境として参照します。
ここはプロジェクトファイルをおいてあるディレクトリを直接書いてもかまいません。
``activate``した後に、必要なパッケージを``add``するとproject.tomlとmanifest.tomlが自動生成されます。

一度プロジェクトファイルを作ったあとであれば、`--project`オプションをつけて、repl起動時にプロジェクト環境を指定することもできます。

```
PS~~~\plots>julia --project=.
julia>]
(plots) pkg> 
```


### パッケージダウングレード問題を解消
~~~
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr"><a href="https://twitter.com/hashtag/Julia%E8%A8%80%E8%AA%9E?src=hash&amp;ref_src=twsrc%5Etfw">#Julia言語</a> 解決策：任意の作業用ディレクトリで以下を実行して、そこに作成したProject.tomlを使えばよい。<br><br>julia&gt; ]<br>pkg&gt; activate .<br> Activating new project at `/work/proj`<br><br>pkg&gt; add ～<br>～<br> Updating `/work/proj/Project.toml`<br>～<br> Updating `/work/proj/Manifest.toml`</p>&mdash; 黒木玄 Gen Kuroki (@genkuroki) <a href="https://twitter.com/genkuroki/status/1439036962854240260?ref_src=twsrc%5Etfw">September 18, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
~~~
黒木玄さんのtwitterを引用しましたが、本当にその通りで
新しいパッケージをインストールしたり、アップデートをかけただけなのに別のパッケージのバージョンが下がってしまうということは良く起こります。これはあるパッケージが指定するバージョンと、別のパッケージが指定するバージョンの上限が合わないためです。
この問題は、ボトルネックになっているパッケージのバージョンアップで解消されるのですが、それをいちいち待っていられないのが人情というものです。

個別にプロジェクト環境を作って、\marker{必要最小限のパッケージだけを使う}ようにしておけば、パッケージのダウングレードのリスクを最小化できます。

### 他人のパッケージ環境をコピーできる。
juliaの色々なパッケージのチュートリアル等で、以下のようなコマンドを求められることもあるでしょう。

```
julia>import Pkg
julia>Pkg.activate(".")
julia>Pkg.instantiate()
```
これをすると、現在ディレクトリのプロジェクト環境を参照して、そこに記載されているバージョンのパッケージをインストールできます。
チュートリアルを作った人と同じバージョンのパッケージを使用できるので、コードを実行できないリスクが低くなります。

## Visual Studio Code(VS Code)でのメリット
次はVS Codeで個別のプロジェクト環境を準備するメリットをまとめておきます。
VS Codeでjuliaのreplを立ち上げると、プロジェクトファイルがある場合には自動的にそのファイルを認識するようになっています。

### Language Server Protocol(LSP)のIndexingが早くなる。
VS Codeでコードを書くときは、コードの補完機能が非常に役に立ちます。
ただし、このコードを補完機能を使うには、LSPがプロジェクト環境にあるパッケージを読み込んで、
補完機能を使えるようにIndexingをしているようです。
デフォルトのプロジェクト環境にたくさんのパッケージを入れているとこの[Indexingの行程が何時間かかっても終わらない](https://discourse.julialang.org/t/vs-code-julia-language-server-indexing/41576)事態になってしまいます。VS Codeを快適に使うには、\marker{個別のプロジェクト環境を作るのは大前提}と言っても良いかもしれません。

### System imageを作ることができる。
VS Codeでは``Ctrl+Shift+B`` + ``Enter``コマンドを打つとプロジェクトファイルにあるパッケージのコンパイル済みイメージを作ることができます。[^2]

\luminous{/images/40e6ac158e1f580c1c277876e236d28c41819c765c179d4465239fcbacc73726.png}  

コンパイル後には``JuliaSysimage.dll``というファイルが作られていることがわかります。
コンパイルには数分かかりますが、一度システムイメージを作ると次にreplを立ち上げるときには
自動でシステムイメージを認識してくれるので、パッケージの読み込みがものすごく早くなります。

\luminous{/images/54fd31432a011f593bca636ff57dccaede554f51ec8bf9a1e7cf6db6a14c2f3c.png}  

[^2]: システムイメージの構築には、PackageCompiler.jlを使う方法もありますが、こちらの方が圧倒的に簡単です。
#### TTFP(time to first plot)
ここでは、TTFP(time to first plot)というjulia界隈でよく使われるベンチマークをやってみます。
Plots.jlというのは、比較的よく使われる可視化パッケージですが、usingにかかる時間は非常に長いことで知られています。

最初にシステムイメージを読み込まない状態で、Plots.jlをインポートして適当なプロットを実行します。

```
PS C:\folder> julia --project -e '@time using Plots;plot(rand(10))'
  4.123728 seconds (8.06 M allocations: 564.466 MiB, 3.64% gc time, 0.23% compilation time)
```

このときの実行時間はおよそ4秒です。以前に比べればかなり早くなった方ですが、
まだ秒単位で時間がかかります。(以前は数十秒かかっていた。)

システムイメージを読み込んだreplを起動するには``-J``オプションを使います。

```
PS C:\folder> julia -J JuliaSysimage.dll --project -e '@time using Plots;plot(rand(10))'  
  0.007352 seconds (1.33 k allocations: 86.109 KiB, 38.49% compilation time)
```
読み込み時間がm秒オーダーになりました。これでいわゆるTTFPのストレスは改善されます。

このシステムイメージを構築する方式の欠点は、
- システムイメージの容量が数100MBと重いこと
- プロジェクトファイルが更新されるとシステムイメージを読み込めずreplが立ち上がらないこと
です。

こうした欠点を念頭に置けば、うまく運用できるようになるかと思います。

## まとめ   
Project環境をつくるメリットをまとめます。
- パッケージ更新時のダウングレードの問題を解消できる。
- Pkg.instantiate()で他人と同じ環境を構築できる。
- VS CodeでLSPのIndexingが早くなる。
- VS CodeでProject専用のSystem Imageを作ることができる。パッケージの読み込みが爆速になる。

\right{めでたしめでたし}
\share{tips/project/}{個別のProject環境を作るメリット}
\prev{/tips/preprocess}{juliaで前処理大全をやってみる}
\backtotop

{{ addcomments }}