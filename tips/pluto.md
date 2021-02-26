@def title="Pluto.jl でレポートを作る。"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# Pluto.jl とは

文章や数式と共にコードとその実行結果を記述することを Literate Programming と呼びます。
Literate Programming の定番は Jupyter Notebook(IJulia.jl)ですが、
julia 独自の Pluto Notebook(Pluto.jl)というものもあります。
python への依存関係もないので、インストールに苦労することも少ないでしょう。
教育への適用が狙いの 1 つであるようで、julia 開発者の一人である MIT の Alan Edelman 先生の
[Computational Thinking](https://computationalthinking.mit.edu/) の授業でも、大いに活用されています。

\mytoc
---
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

[github](https://github.com/fonsp/Pluto.jl)の動画をみれば、イメージがつかめると思います。
私がとくに特徴的だと感じたことを書いていきます。
### リアクティブであること

Pluto.jl の最大の特徴は、リアクティブであることです。
ある変数の値を変更すると、別のセルでの同じ変数の値も自動的に変更されます。
@bind マクロを使って、変数を html input と連携させることも可能なため、
GUI を実装することも簡単です。

### スライドモードも実装できる。

javascript を利用して、プレゼンテーションモード試すことができます。
ブラウザの javascript コンソールで present()とタイプすると、
プレゼンテーションモードになります。

また、以下のコードを書いたセルを実行すると、ボタンでプレゼンテーションモードと通常モードを切り替えられます。

```julia
html"<button onclick=present()>Present</button>"
```

プレゼンテーションモードで pdf に変換すると、スライド毎にページが変わることも確認できます。

### ただの julia file である。

Pluto-notebook はただのテキストファイルなので、 git で変更差分を管理可能です。
Jupyter Notebook の場合は、git での変更差分管理が難しくなります。
(git で ipynb を管理するのが大変というのが、Literate.jl の生まれた理由でもあるそうです。)

### コードや実行結果を隠すことができる。

プログラマでない人は、コードを見てもよく分からないので、
ストレスを感じるかもしれません。
セルの左側の目のマークを押すと、コードを隠すことができます。
冗長な部分を隠して、ドキュメントとしての体裁を整えることができます。

## 欠点

当然良いことばかりではありません。

### 重い処理に向いていない

Pluto はセルの実行結果を一緒に保存していないので、
ノートブックの立ち上げ時に、すべてのコードを実行しようとします。
このため、重い処理を実行したり、くそ重いファイルを読み込むような使い方では、立ち上げに時間がかかるので結構イライラします。

また、リアクティブなので、ある変数の値を変更すると、その変数を使った別のセルの内容も自動的に実行されます。
実行する計算内容が軽いものなら大丈夫ですが、実行に時間がかかるセルの内容が変更された場合は、
しばらく身動きがとれなくなります。
これらの点で、実行結果を保存しておける Jupyter Notebook の方がある意味安全です。

### マクロが使えないことがある。

Pluto では実行できないマクロがあります。
私の場合は、微分方程式のマクロである ParameterizedFunctions.jl を使おうとして、error がでたことで気づきました。

```julia
f = @ode_def LotkaVolterra begin
  dx = a*x - b*x*y
  dy = -c*y + d*x*y
end a b c d
```

[issue](https://github.com/fonsp/Pluto.jl/issues/196) で詳しく議論されています。
何か抜け道があるのかもしれませんが、
JuMP.jl のようなドメイン固有言語が発達したパッケージの利用には苦労すると思われます。

### 複数行のコード

1 つのセルに複数行を入力して実行するためには、`begin`-`end`環境に入れてやる必要があります。

```julia
begin
  a = 1
  println(a)
end
```

jupyter と同じ感覚で使おうとするとミスります。

## Pluto.jl のまとめ

- （良くも悪くも）リアクティブなノートブック
- マークダウンやhtmlとの連携など、基本的な機能を備えている。
- GUIを実装しやすく、教育用のコンテンツとしても優秀
- 重い処理や、ドメイン固有言語が発達したパッケージの利用には要注意。
\right{めでたしめでたし}

\backtotop
