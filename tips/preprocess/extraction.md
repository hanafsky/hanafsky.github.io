@def title="juliaで前処理大全1"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2021,5,30)
@def published="30 May 2021"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true
# juliaで前処理大全 2.抽出 

\titleimage{/assets/tips/preprocess.jpg}{https://pixabay.com/photos/food-salad-raw-carrots-1209503/}
\share{tips/preprocess/}{juliaで前処理大全}

juliaで前処理大全をやります。今回は、データの読みこみと抽出のやり方を見ていきます。
内容は前処理大全の第2章に相当します。

@chainマクロを使ったパイプライン処理についても簡単に解説します。

\toc
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
df = DataFrame(load("file.xlsx","Sheet1"))
```

datファイルなら、標準パッケージのDelimitedFiles.jlを利用すると読み込みが高速です。

```julia
using DataFrames,DelimitedFiles

df = DataFrame(readdlm("file.dat"))
```

そのほかに、Rとpythonで共通なFeather形式を利用していたこともありましたが、
ほかの言語で処理することもなかったし、特段ファイルサイズが小さくなるわけでもありませんでした。

さて、早速サンプルのホテルの予約データ（reserve.csv）を読み込んでいきます。
一行目のデータを表示してみましょう。


```julia:ex1-preprocess1
using DataFrames,CSV,Chain,Downloads

reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
println(first(reserve_df))
```

\prettyshow{ex1-preprocess1}

いきなり@chainマクロを使ったパイプライン処理がでてきますが、これは次のセクションで解説します。
## パイプライン処理
### julia標準のパイプライン処理
**「そもそもパイプライン処理とは何ぞや?」**から解説したいと思います。
簡単な例として、次のような関数が入れ子になった計算をしたい場合を考えます。

```julia
sin(cos(tan(1)))
```

関数名が短い場合は良いのですが、このような入れ子になった式は、一般的に可読性が高いとは言えません。
そこで、作用させる関数を後から追加できるように、juliaでは次のパイプ演算子``|>``が用意されています。
フォントの関係で右三角に見えますが、実際の入力は|>です。

```julia
1 |> tan |> cos |> sin
```

このような記法を採用するメリットは、可読性が高まるだけでなく、実行結果を確認しながら後で関数を追加できることです。

### 引数が複数ある場合の対応
ところが、複数の引数をとる関数をパイプライン処理で実装したいときは、
そのままでは実行できない問題が発生します。そこで、無名関数を使う必要がでてきます。

```
add(a,b) = a+b
1 |> (x -> add(x,2))
```
ただし、このような書き方をすると可読性が犠牲になります。

この問題を解決できるのがパイプライン処理のパッケージです。

### Chain.jl パッケージ
パイプライン処理のパッケージはいくつかありますが、ここではChain.jlを使うことにします。
使い方を簡単に解説します。
~~~
<a href="https://github.com/jkrumbiegel/Chain.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/jkrumbiegel/Chain.jl.png" width="460px"></a>
~~~

@chainマクロを使うと、そもそもパイプ演算子``|>``を記述する必要がなくなります。
最初の例は、次のように一行で書けます。
```julia
using Chain
@chain 1 tan cos sin
```
2番目の例のように、複数の引数をとる関数がきても大丈夫です。

```!
add(a,b) = a+b
@chain 1 add(2) add(3)
```
左側の計算結果を、次の関数の最初に引数として扱ってくれるからです。
この@chainマクロが何をしているか展開して確認してみると

```!
using Chain
@macroexpand @chain 1 add(2) add(3) add(4)
```

#### 複数行で実行
複数行で実行したい場合は、``begin-end``環境で囲います。
最初の例でやってみましょう。
```!
@chain 1 begin
  tan
  cos
  sin
end
```

#### 引数の位置を明示
引数の位置を明示したい場合は、``_``（アンダースコア）を用います。
これは、ほかのパイプライン処理のパッケージでも同じ実装であることが多いです。

マクロを展開すると``_``の位置がlocal変数で書き換えられていることがわかると思います。

```!
@macroexpand(@chain reserve_url begin
  Downloads.download(IOBuffer())
  String(take!(_))
  CSV.read(IOBuffer(_),DataFrame)
end) |>Base.remove_linenums!
```

#### @asideマクロ
パイプライン処理の途中の結果で何かをしたいときには、@asideマクロが使えます。
そのうち使うかもしれません。

```!
@chain 1 begin
  tan
  @aside println(_)
  cos
  sin
end
```

@chainマクロとDataFrames.jlは非常に相性が良いので、この先ガンガン使っていきます。


## 抽出

### データ列の抽出

前処理大全では、可読性を高めるために、データの列番号ではなく、ラベルによって列を抽出することが推奨されています。
まず、ラベル名を確認しておきます。

```julia:ex2-preprocess1
@show names(reserve_df);
```

\prettyshow{ex2-preprocess1}

試しに`reserve_id`と`hotel_id`の列を抽出してみます。

#### String で指定

オーソドックスなのは、ラベル名をString型で指定する場合です。

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
ともに型はSymbol型です。

`:reserve_id`の方が、タイプ数が少ないので省エネです。

また、一列だけ抽出したいときは、`df.reserve_id`のようにすることもできます。
ただし、返り値の型はDataFrame型ではなく、Vecter型になります。

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
Not の中身は、直接ラベル名を指定することもできるので有用です。

```julia:ex10-preprocess1
reserve_df[!,Not(r"id$")] |> first |> println
```

\prettyshow{ex10-preprocess1}

### 条件指定による抽出

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

### データ値に基づかないサンプリング

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
IDの重複をなくすにはunique関数が便利です。
```julia:ex15-preprocess1
@chain reserve_df.customer_id begin
  unique
  sample(_, round(Int,length(_)/2),replace=false)
  filter(:customer_id => in(_),reserve_df) 
end
```
\prettyshow{ex15-preprocess1}

unique関数はデータフレーム全体に適用することも可能です。

```!
DataFrame(a=[1,1,2],b=["a","a","b"]) |> unique
```

\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prevnext{/tips/preprocess}{juliaで前処理大全}{/tips/preprocess/aggregation}{juliaで前処理大全 集約}
\backtotop

{{ addcomments }}