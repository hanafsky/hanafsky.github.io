@def title="juliaの文法"
@def rss=""
@def tags=["julia","設定"]
@def hascode=true
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
## コメント
## 真偽値と条件分岐
## 繰り返し
## メソッド呼び出し
## ブロック
## 関数定義
関数の定義にはfunction文を使います。
戻り値はreturnの後に書くか、最後に書いた行の値になります。
また、戻り値の型や引数の型を指定することもできます。(省略することもできます。)
```julia:ex_funcdef1
function add(a::Number,b::Number)::Number
    a+b
end
println(add(1,2))
```
\output{ex_funcdef1}
同じ名前の関数でも、引数の型を変えて定義することが可能です。
これが多重ディスパッチというjuliaの重要な機能のひとつです。

無名関数も使えます。（引数）->（処理）の形式で使います。
```julia:ex_funcdef2
f = x->x^2
@show f(2)
@show (x->x^2)(2)
@show ((x,y)->x+y)(1,2)
```
\output{ex_funcdef2}
## 複合型定義
もともとはクラス定義でしたが、juliaにはクラスがありません。
オブジェクト指向でいうクラスの属性が複合型に相当します。
メソッドがない点は、多重ディスパッチ
複合型は抽象型から継承はできますが、複合型から複合型への継承はできません。
struct文を使います。
## モジュール定義
## 特異メソッド
## 例外処理
## aliasとundef?
## 予約語
\backtotop