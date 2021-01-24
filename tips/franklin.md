@def title="Franklin.jlを使った話"
@def tags=["thirdparty","setting"]
@def hascode=true
@def isjulia =true

# 静的サイトジェネレータ　Franklin.jl を使った話
[Franklin.jl](https://github.com/tlienart/Franklin.jl)はjulia言語で作られた静的サイト作成パッケージです。
このサイトはFranklin.jlで作成しました。
ブログの選択肢としては、WordPress、はてなブログ、Qiitaなど色々あるでしょうが、
julia言語が好きで、juliaや数式も使ったブログを書きたいなら、Franklin.jlは有力な選択肢だと思います。

~~~
<dl>
  <dt>目次</dt>
  <dd>説明</dd>
</dl>
~~~

本サイトの作成にあたって参考にしたサイトはこちらです。
- [本家](http://franklin.org) 
- [MathSeminar.jl](http://terasakisatoshi.github.io/MathSeminar.jl) 今のところ唯一の日本語ソース

\mytoc
--- 
## 使ってみる
### インストール方法
まずREPLのパッケージモードからFranklinをインストールします。
```julia
julia>]
(pkg)>add Franklin
```
### デモサイトを作ってみる。
以下のコードを実行すると、デモサイト作成後にローカルサーバーが立ち上がり、
http://localhost:8000/　でサイトを確認することができます。
```julia
using Franklin
newsite("mySite",template="vela")
serve()
```
テンプレートは[ここ](https://tlienart.github.io/FranklinTemplates.jl/)で確認できます。

mySiteフォルダ以下にマークダウンファイルや素材が入っています。
テンプレートファイルをいじりながら使って行くことになります。
ライブレンダリングによって編集後の結果をすぐに確認できるので、
初心者でも使いやすいと思います。
サーバー停止後にもう一度起動する時は、mySiteフォルダでREPLを立ち上げて、
```julia
using Franklin
serve()
```
とタイプします。
### 基本的な文法
マークダウンの記法にしたがって書きます。Latexライクな拡張コマンドもあります。
数式もお手の物です。
```
$$ \int_{a}^{b} f(x) = F(b) - F(a)$$
```

$$ \int_{a}^{b} f(x) = F(b) - F(a)$$
### juliaのコードを書いてみる。
マークダウンの中で次のようなコードを実行したとします。
`````markdown
```julia:test
println("Hello Franklin")
```
\show{test}
`````
するとこのコードが実行された結果を出力することができます。
```julia:test
println("Hello Franklin")
```
\show{test}

次のように書いてやればグラフも出力できます。
`````markdown
```julia:plot
using Plots
p = plot(x->sin(x),xlabel="x",ylabel="y")
savefig(p,joinpath(@OUTPUT,"figplot.svg"))
```
\fig{figplot}
`````
```julia:plot
using Plots
p = plot(x->sin(x),xlabel="x",ylabel="y")
savefig(p,joinpath(@OUTPUT,"figplot.svg"))
```
\fig{figplot}
---
## 注意したいポイント
### ``\ ``記号に気を付けよう
``\ ``の記号をMarkdownの中で使うときは、注意が必要です。
FranklinはMarkdownのなかで拡張されたコマンドを使うことができます。
たとえば、こんな具合です。
```html
<!-- コマンドの定義 -->
\newcommand{\bolditaliccenter}[1]{
    ~~~
    <div style=
    "font-size:xx-large;text-align:center;font-style:italic; font-weight:bold">
    #1
    </div>
    ~~~
    }
<!-- コマンドの実行 -->
\bolditaliccenter{無駄！}
```
\newcommand{\bolditaliccenter}[1]{~~~<div style="font-size:xx-large; text-align:center;font-style:italic; font-weight:bold">#1</div>~~~}
\bolditaliccenter{無駄！}

Franklinは、``\ ``が付くところをコマンドだとみなすので、下手に``\ ``を使おう
ものなら``\newcommand``で定義されていないコマンドとみなされ、
サーバーが落ちてライブレンダリングできなくなります。
\\
通常のマークダウンを書いているときは、ミスをしにくいと思いますが、
Literate.jlを使って、コメントを書いているときは、気づきにくいので注意が必要です。

### juliaコード内の変数のスコープ
juliaを使うときは、基本的にループや関数内部からグローバル変数を何の断りもなく参照するのは
アウトだと知っている人も多いと思います。この罠は、REPLやjupyterを使ってプロトタイピングを
しているときには気にしなくてもよいですが、端末上で``julia hoge.jl``とするときは
アウトになります。
Franklinでjuliaのコードを実行するときはこの状況になるようで、実際に試してみると
```julia:out
a = 1
for i in 1:2
    a += 1
end
```
\show{out}
となってしまいます。
これを防ぐには、let環境に入れ込んでしまうか、
```julia:safe
let
a = 1
for i in 1:2
    a += 1
end
a
end
```
\show{safe}

コントロールの中でグローバル変数であることを明記する必要があります。[^2]

```julia:global
a = 1
for i in 1:2
    global a += 1
end
a
```
\show{global}
 
[^2]: ``global a #hide ``のように書けば、コードを隠すこともできます。

### github actionsの罠
github pagesを使えば、無料でホームページを作ることができます。Franklinでは
github actions(githubのレポジトリの中で自動的に実行される処理) を利用して、
サイトを構成することが推奨されています。

Franklinの場合は、
``.github\workflows\deploy.yml``にコードが記載されていて、
リモートレポジトリにpushしたときに処理が実行されるようになっています。
deploy.ymlの中身を見れば雰囲気が分かると思いますが、処理の流れをざっくり説明すると
1. github上でOSを立ち上げて、juliaやら何やら必要なものをインストール
1. Franklinを実行して、サイト(__siteフォルダ以下)を作る
1. gh-pagesブランチにできたサイトをぶちこむ
ということになります。

個別の状況によりますが、このdeploy.ymlは修正する必要があります。
私がハマった点を書いておきます。
#### master or main?
\warning{
2020年の米国の騒動が原因githubのデフォルトブランチ名がmasterからmainに変更されました。
これに伴って、Franklinでもdeploy.ymlにもmainブランチにプッシュされたときに
動作するようになっています。当たり前ですが、この状態でmasterブランチにプッシュしても
何も起こりません。deploy.ymlのブランチ名を実際のブランチ名と合わせる必要があります。
}
#### github-pagesの設定をしておくこと
\warning{
    レポジトリのページのSettingsタブの下の方にGitHub Pagesの欄があります。
    ソースのブランチにgh-pagesを選択しておく必要があります。
}

#### どのレポジトリにプッシュするか 

\warning{
    username.github.io**以外**のレポジトリにプッシュするときは、deploy.ymlの中に書いてあるoptimize()を
    optimize(;prepath="レポジトリ名")にしておく必要があります。そうしないと、リンク切れを起こしてしまいます。
}

#### Project.tomlを入れておこう。
github actions でのデプロイ時には、juliaコードの中で使用したパッケージが分かるように、
教えてやる必要があります。ローカルレポジトリで、以下のように処理しておくと、
```julia
julia>]
(pkg)>activate . 
(pkg)>add Plots # 使用したパッケージ
```
Project.tomlが作成されるので、deploy.ymlのなかでいちいちPkg.add(～～)する必要はなくなります。

### プロットのxylabelが切れる
localサーバー上ではプロットは問題なくできるのですが、
githubにアップするとグラフのマージン設定が上手くできない場合があります。
以下のようなコードを書いてマージンを設定しておけば解決することができました。
```julia
using Plots.PlotMeasures
Plots.reset_defaults() 
default( 
    left_margin = 30px, 
    bottom_margin = 30px 
) 
```
---
## せっかくなので、拡張してみる。
htmlやcssに関する知識が多少あれば、色々と機能を拡張[^1]することができます。
[^1]: 多少の知識があれば、WordPressの立ち上げより簡単だと思います。
私はadomonitionの設定、トップに戻るボタン、mermaidによるフローチャート描画の機能を追加してみました。
### コードのフォントにはjuliamonoを使おう
[juliamono](https://github.com/cormullion/juliamono)フォントを使えば、juliaのコードを洗練された見栄えに変更できます。
パイプ演算子や無名関数を多用する人は、気に入るのではないでしょうか？
->が``->``になったり、|>が``|>``になるわけです。
[Cormullionのブログ](https://cormullion.github.io/pages/2020-07-26-JuliaMono/)(このサイトもFranklinで作られている。)にインストール方法は載っています。


cssでwebフォントとして使うのも簡単で[こちら](https://cormullion.github.io/pages/2020-07-26-JuliaMono/#how_can_i_use_the_web_fonts_for_my_blog)にやり方が載っています。
少し改変したものが以下になります。まず、cssファイルに
```css
@font-face {
    font-family: JuliaMono-Regular;
    src: url("https://cdn.jsdelivr.net/gh/cormullion/juliamono/webfonts/JuliaMono-Regular.woff2");
}
```
と書いて、次にcssセレクタのなかで、codeを探して、
```css
code {
  font-family: "JuliaMono-Regular",Monaco,Consolas,"Lucida Console",monospace
}
```
としておけば良いです。(font-familyの一番左に書くことが重要)

## まとめ
- Franklin.jlを使えば、テンプレートサイトをいじって簡単に自分だけのサイトが作れる。
- 自分だけのコマンドを作れるが、``\ ``の記号には注意が必要。
- juliaコードを実行するときは変数のスコープに注意する。
- githubにプッシュして簡単にホームページが作れる。
    - github-pagesを使うときは、deploy.yml、Project.toml、ソースブランチの設定に注意。
- cssやjavascriptをいじって自分で拡張できる。
\right{めでたしめでたし}
\backtotop