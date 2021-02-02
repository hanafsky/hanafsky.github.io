@def title="juliaの文法"
@def rss=""
@def tags=["recipe"]
@def hascode=true
@def isjulia =true 
# Juliaの文法

\mytoc
---

## リテラル
リテラルとは組み込み型の定数を表すものです。いくつか列挙します。
```julia:ex1
#数値リテラル
@show typeof(1)
@show typeof(1.0)
@show typeof(1.0f0)
@show typeof(1+1im)
#文字リテラル
@show typeof("abc\n")
@show typeof('a')
@show typeof(r"abc")
@show typeof(raw"abc")
#配列リテラル
@show typeof([1,2,3])
@show typeof((1,2,3))
@show typeof((a=1,b=3));
@show typeof(Dict("a"=>1,"b"=>2))
```
\prettyshow{ex1}
組み込み型は他にもいっぱいあります。

## 演算子
## 変数と定数
## 代入
## 文の区切り
文の区切りもpythonと同じく``;``です。
ただし、``;``には評価結果を出力しないという意味もあります。
```julia
x=1;y=2;
```
また、括弧が閉じていないときは自動的に複数行扱いになります。
文末をパイプ演算子にしても複数行扱いにできます。

```julia:ex_kugiri
a = [1,
    2,
    3]
a .|> sqrt |>
     println
```
\prettyshow{ex_kugiri}
## コメント
コメントの書き方はpythonと同じです。

```julia
# コメント1
a=1 # コメント2
```
複数行にわたるコメントは``"""``で囲まれた環境で表します。
```julia
"""
ここはコメントです。
"""
```
## 真偽値と条件分岐
if文の使い方は以下の通りです。
```julia
if condition1
    process1
elseif condition2
    process2
else
    process3
end
```
``condition``の部分には``true``または``false``の真偽値を返すような
条件式が入ります。

ある条件を満たしたときの処理を書ければ良いだけならば、次の短絡評価が便利です。
```julia:ex_if
a = 1
a == 1 && println(a) # aが1なら, aを出力
a == 2 || println(a) # aが2でないなら、aを出力
```
\prettyshow{ex_if}

## 繰り返し

## メソッド呼び出し
## ブロック
## 関数定義
関数の定義にはfunction文を使います。
戻り値はreturnの後に書くか、最後に書いた行の値になります。
また、戻り値の型や引数の型を指定することもできます。
```julia:ex_funcdef1
function add(a::Number,b::Number)::Number
    a+b
end

function add(a::String,b::String)::String
    a*b
end

println(add(1,2))
println(add("abc","def"))
```
\prettyshow{ex_funcdef1}

\note{
同じ名前の関数でも、引数の型を変えて定義することが可能です。
これが**多重ディスパッチ**というjuliaの重要な機能のひとつです。

**自分で定義した複合型を、既存の関数でも使えるように再定義する**
というのが、よくある使い方です。
}

\warning{型を``Float64``のようにガチガチに固めてしまうと、
融通が効かなくなるので、juliaが上手く型推論できる程度に緩くしておくのが、
吉です。
}
### 無名関数
無名関数も使えます。（引数）->（処理）の形式で使います。
```julia:ex_funcdef2
f = x->x^2
@show f(2)
@show (x->x^2)(2)
@show ((x,y)->x+y)(1,2)
```
\prettyshow{ex_funcdef2}

例えば、filter関数のように、"関数を引数にできる関数"で良く利用します。

```julia:ex_funcdef3
filter(r->r%3==0, 1:10) |> println
```
\prettyshow{ex_funcdef3}

## 複合型の定義
この項目はもともとはクラス定義でしたが、juliaにはクラスがありません。
オブジェクト指向でいうクラスの属性が複合型に相当します。
メソッドがない点は、多重ディスパッチで補うことができます。

複合型は、複数の型をセットにしたものです。
型の定義にはstruct文を使います。具体例を見てみましょう。

```julia:ex_struct1
struct Baz
    a
    b::Int
end

baz = Baz("a",4)
@show baz.a
@show baz.b
```
\prettyshow{ex_struct1}

このように複合型のインスタンスを生成すると、``インスタンス名.要素名``で
要素を呼び出すことができます。

struct文では、要素について型を指定することができます。

### 可変な複合型
複合型のインスタンスは基本的に値が固定されてしまいます。
要素の値を変動させたいときには、``mutable struct``文を使います。

```julia:ex_struct2
mutable struct mBaz
    a
    b
end

mbaz=mBaz(1,2)
@show mbaz.a
mbaz.a = 2
@show mbaz.a
```
\prettyshow{ex_struct2}

### 初期値付きの複合型
複合型を定義した時点で、初期値を設定しておきたいこともあります。
そんな時は、Baseモジュールの@kwdefマクロが使えます。
ヘルプを読んでみましょう。
```julia:ex_struct3
println(@doc Base.@kwdef)
```
\prettyshow{ex_struct3}

\note{
    REPLで?関数名,とタイプしてもヘルプを読むことができます。　
    @docマクロでヘルプを文字列として取り出すことができます。}

\note{
同様の機能は, Parameters.jlでも実装可能です。
Parameters.jlは複合型の中身を簡単にまとめたり、吐き出すマクロがあるので、
私はこちらの方をよく使います。
}

## モジュール定義
juliaのモジュールとpythonのモジュールはちょっと違います。
(pythonでいうモジュールは、juliaでいうpackageに相当します。)

用途に応じて書き分けたいと思います。
### 別のソースファイルをインポートしたい
source_a.jlのコードを読み込みたいとしましょう。
その場合は、次のようにinclude関数にソースファイルのパスを渡せばOKです。
```julia
include("source_a.jl")
```

### モジュールを定義する。
juliaにおけるモジュールは、以下のように``module end``で囲まれた環境のことをさします。
```julia:ex_module
module A

struct bar
    x
    y
end

function foo()
    println("foo")
end

end #end module

BAR = A.bar(1,2)
println(BAR.x)

A.foo()
```
\prettyshow{ex_module}
モジュール環境の中に書かれた関数や複合型は、他のモジュールの中に
同名の関数があっても``A.foo()``のように呼び出す限りは名前の衝突を
避けることができます。
\note{
実は、REPLでコードを叩いているときは、Mainモジュールの中で関数の定義や
複合型を定義しています。このため、一度定義した複合型を書き換えると
怒られてしまうのですが、モジュール内で複合型を定義しておけば、
名前空間が異なるので、コードを試しながら複合型を変更することが可能です。
}
### パッケージ
juliaを使っているときに、``using DelimitedFiles``のように、
using文でパッケージをインポートします。
\note{import文も使えます。}

これは、モジュールをインポートしていることになりますが、
こうしたモジュールはパッケージと呼ばれています。

モジュールとパッケージの違いは何かというと難しいですが、
モジュール(ソース)とドキュメントとテスト結果がまとまっているものが、
パッケージというべきでしょうか。
パッケージの作り方は[zlatanのブログ](https://zlatanvasovic.github.io/blog/2020/06/make-your-julia-package/)が分かりやすいです。

## 特異メソッド
そもそもjuliaはオブジェクト指向ではないので、特異メソッドはありません。
以下のように、複合型のインスタンスに対して関数を定義しようとすると、
helloというフィールドがFooの中にないので、アウトです。
(逆にhelloというフィールドがあれば定義できる。でも何もうれしくない)
```julia
struct Foo
    x
end

test=Foo(3)

function test.hello()
    println("hello")
end
```

なお、複合型に対して、関数を定義することはfunction-like objectの機能を利用して実装可能です。

```julia:ex_flo
struct FLO
    a
    b
    c
end

function (flo::FLO)(x)
    flo.a*x^2+flo.b*x+flo.c
end

f=FLO(1,2,3)
@show f(2)
```
\prettyshow{ex_flo}

インスタンスごとに別の関数を割り当てることはできません。

## 例外処理
## aliasとundef?
## 予約語

\backtotop