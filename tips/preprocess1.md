@def title="Awesome な前処理"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# Awesome な前処理 1

機械学習を利用した仕事でデータの前処理をする必要に迫られました。
一冊くらいは前処理の本を読んだほうがいいだろうと思い、ホクソエムの方が
著者の[前処理大全](https://gihyo.jp/book/2018/978-4-7741-9647-3)という本を読んでみました。

この本は、データ解析の場面において、複数の言語を使い分けることを想定して、
SQL、R、pythonの3つの言語でAwesomeなコードの書き方を教えてくれます。
具体的には、メモリに収まらない大規模なデータならSQL、プロトタイピングにはR、
システムへの組み込みにはpythonという具合です。

余談やあとがきも著者の人柄が偲ばれて、とてもおもしろかったです。

私は、普段からプロトタイピングもウェブアプリもjuliaで作っているので、
自分用にjulia版（DataFrames.jlを利用[^1]）でのエッセンスをまとめたいと思います。

[^1]: 大規模なデータについては、JuliaDBを使う選択肢もありますが、今のところその機会はなさそうなので、DataFrames.jlだけでやってみます。


ほかの参考資料としては、[Julia 1.0 Programming CookBook](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)の著者のBogumił Kamiński先生のブログと
[Hands-On Design Patterns and Best Practices with Julia](https://www.packtpub.com/product/hands-on-design-patterns-and-best-practices-with-julia/9781838648817)の著者のTom Kwong さんのデータレングリングのvideoとブログを挙げておきます。

- [Blog by Bogumił Kamiński](https://bkamins.github.io/)
- [Tom Kwong's Infinite Loop](https://ahsmart.com/)

Tom Kwong さんのブログには、DataFrames.jlのチートシートがおいてあるので、手元において活用させてもらっています。

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/txme9o0EdLk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

データは
[前処理大全のサポートページのデータ](https://github.com/ghmagazine/awesomebook)を利用しました。

\mytoc
---
## ファイルを読み込む

CSV ファイルの読み込みでは、以下の方法をよく使います。

```julia
using DataFrames,CSV
df = CSV.read("file.csv", DataFrame)
```

\warning{最近、`CSV.read`関数は、出力するデータ型（この場合は DataFrame 型）を指定しないとエラーを吐くようになりました。}

CSVファイル以外の読み込みでは、Excelから読み込むことが多いので、
ExcelFiles.jlをよく利用します。こちらはシート名を直接指定する必要があります。

```julia
using DataFrames, ExcelFiles
df =
```

datファイルなら、標準パッケージのDelimitedFiles.jlを利用すると読み込みが高速です。

```julia
using DataFrames,DelimitedFiles

df = DataFrame(readdlm("file.dat"))
```

そのほかに、Rとpythonで共通なFeather形式を利用していたこともありましたが、
ほかの言語で処理することもなかったし、特段ファイルサイズが小さくなるわけでもありませんでした。

早速サンプルのホテルの予約データ（reserve.csv）を読み込んでいきます。
長ったらしいので、最初の行だけをfirst関数で見てみます。

```julia:ex1-preprocess1
using DataFrames,CSV
path = joinpath("tips","data","reserve.csv")
reserve_df = CSV.read(path,DataFrame)
println(first(reserve_df))
```

\prettyshow{ex1-preprocess1}

## 2 抽出

### 2-1 データ列の抽出

前処理大全では、可読性を高めるために、データの列番号ではなく、ラベルによって列を抽出することが推奨されています。
まず、ラベル名を確認しておきます。

```julia:ex2-preprocess1
@show names(reserve_df);
```

\prettyshow{ex2-preprocess1}

試しに`reserve_id`と`hotel_id`の列を抽出してみます。

#### String で指定

オーソドックスなラベル名をString型で指定する場合です。

```julia:ex3-preprocess1
reserve_df[!,["reserve_id","hotel_id"]] |> first |> println
```

\prettyshow{ex3-preprocess1}

#### Symbol で指定

同じことを Symbol型で指定してやってみます。

```julia:ex4-preprocess1
reserve_df[!,[:reserve_id,Symbol("hotel_id")]] |> first |> println
println()
@show typeof(:reserve_id)
```

\prettyshow{ex4-preprocess1}
ここで、`:reserve_id`と`Symbol("reserve_id")`は同じ結果を示します。
ともに型は Symbol 型です。

`:reserve_id`の方が、タイプ数が少ないので省エネです。

また、一列だけ抽出したいときは、`df.reserve_id`のようにすることもできます。
ただし、返り値の型は DataFrame 型ではなく、Vecter 型になります。

```julia:ex5-preprocess1
@show reserve_df.reserve_id[1:5]
println()
@show typeof(reserve_df.reserve_id)
```

\prettyshow{ex5-preprocess1}

\warning{
いつでも`:reserve_id`のようにできるわけではありません。よくあるトラップが、
ラベル名に`%`や`/`などの2項演算子が文字列に使われている時です。

```julia:ex6-preprocess1
testdf = DataFrame("a%"=>"a", "b(m/s)"=>1:1e5)
println(first(testdf))
```

\prettyshow{ex6-preprocess1}

この場合には、`df[!,Symbol("a%")]`のようにして指定する必要があります。
演算子がラベル名に使われている場合は、私は最初にラベル名を当たり障りのないように変更するようにしています。
}

\note{
`reserve_df[:,["reserve_id"]]`でも`reserve_df[!,["reserve_id"]]` でも、返り値は同じです。
ただし、前者の場合は新しくメモリ割り当てが発生します。その結果として実行速度も遅くなります。

```julia:ex7-preprocess1
@time testdf[:,["a%","b(m/s)"]]
println()
@time testdf[!,["a%","b(m/s)"]]
```

\prettyshow{ex7-preprocess1}
}

#### select 関数

列を抽出するには、select 関数も利用できます。

```julia:ex8-preprocess1

select(reserve_df,:reserve_id, :hotel_id) |> first |> println
```

\prettyshow{ex8-preprocess1}

select関数には、新しい列を作る機能もあるので、
後で活躍しそうです。

#### Not や正規表現による抽出

ラベルが`id`で終わる列を正規表現で抽出します。

```julia:ex9-preprocess1
reserve_df[!,r"id$"] |> first |> println
```

\prettyshow{ex9-preprocess1}
\warning{
前処理大全では、ずっと使うコードにこのような抽出方法を採用することは避けるべきだとされています。
}

ラベル名が`id`で終わらない列を抽出するには、Not に入れてしまうと楽です。
Not の中身は、直接ラベル名を指定することもできるので、有用です。

```julia:ex10-preprocess1
reserve_df[!,Not(r"id$")] |> first |> println
```

\prettyshow{ex10-preprocess1}

### 2-2 条件指定による抽出

`checkin_date`が2016-10-12から2016-10-13までのデータを抽出します。
ここではfilter関数を使います。
filter関数には、見ての通り2通りの使い方があります。
基本的には無名関数を使って、`引数x-> a<x<b`のような書き方をしています。

```julia:ex11-preprocess1
using Dates: Date
# filter(:checkin_date => row-> Date(2016,10,12) <= row <= Date(2016,10,13), reserve_df) |> println
filter(row-> Date(2016,10,12) <= row.checkin_date <= Date(2016,10,13), reserve_df) |> println
```

\prettyshow{ex11-preprocess1}

上の例では1行で書きましたが、いくつかの前処理を一気に行うなら、以下のように複数行に分けたほうが、可読性は高いでしょう。

```julia:ex12-preprocess1
using Chain
@chain reserve_df begin
  filter(:checkin_date => >=(Date(2016,10,12)),_)
  filter(:checkin_date => <=(Date(2016,10,13)),_)
  # println
end
```

\prettyshow{ex12-preprocess1}

### 2-3 データ値に基づかないサンプリング

データ数を大体半分にしたいときの処方箋です。
pythonやRのようにDataFrame用にsample関数のようなものがあってもよさそうですが、
ないみたいなので、StatsBase.jlのsample関数を利用します。
DataFrameの行数から重複を許さずに、半分の値をサンプリングします。
そして、それを行番号として指定します。

```julia:ex13-preprocess1
using StatsBase: sample 
sample_row = sample(1:nrow(reserve_df), round(Int,nrow(reserve_df)/2), replace=false)
reserve_df[sample_row,:]
```

\prettyshow{ex13-preprocess1}

SQLで出てきた、乱数を使って、データ数を約半分にする方法も使えそうです。

```julia:ex14-preprocess1
using Chain
reserve_df.rand=rand(nrow(reserve_df))
sdf = @chain reserve_df begin
  filter(:rand =><(0.5),_)
  select!(Not(:rand))
end
println(first(sdf))
```
\prettyshow{ex14-preprocess1}


### 2-4 集約IDに基づくサンプリング

顧客IDを集約して、半分にサンプリングし、顧客IDによるデータの抽出を行います。
chainマクロを使ったパイプラインの実装ですが、可読性は高いと思います。
```julia:ex15-preprocess1
@chain reserve_df.customer_id begin
  unique
  sample(_, round(Int,length(_)/2),replace=false)
  filter(:customer_id => in(_),reserve_df) 
end
```
\prettyshow{ex15-preprocess1}

\next{/tips/preprocess2}{Awesome な前処理2}

\backtotop
