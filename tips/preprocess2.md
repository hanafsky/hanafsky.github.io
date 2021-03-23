@def title="Awesome な前処理"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# Awesome な前処理 2

前処理大全のjulia版その2です。
まずは、ホテルの予約データを読み込みます。

```julia:ex1-preprocess2
using DataFrames,CSV
path = joinpath("tips","data","reserve.csv")
reserve_df = CSV.read(path,DataFrame)
#first(reserve_df) |> println
```

\prettyshow{ex1-preprocess2}

\mytoc
## 3 集約
### 3-1 データ数、種類数の算出
ホテルごとに予約数、顧客数の集計を行う練習です。
ホテルごとにデータを分ける処理は、groupby関数で実施します。

groupby関数は、``groupby(df::AbstractDataFrame,cols;kwargs...)``
のようにデータフレームと列名を引数して、返り値は``GroupedDataFrame``となります。

グループ化したデータ毎に集計する処理はcombine関数で実施します。
combine関数は、``GroupedDataFrame``を引数にして、さらに
``列名 => 関数 (=> 新しい列名)``のような書き方の可変長引数をとることができます。

この問題は、@chainマクロを用いたパイプライン処理によって、以下のように、簡潔に記述できます。


```julia:ex2-preprocess2
using Chain
df3_1= @chain reserve_df begin
  groupby(:hotel_id)
  combine(:reserve_id  => length        => :rsv_cnt,
          :customer_id => length∘unique => :cus_cnt)
end
first(df3_1) |> println

```

\prettyshow{ex2-preprocess2}

予約数は、length関数で集計可能です。
顧客数を集計するには、顧客名の重複を消すために、unique関数とlength関数を合成した関数を利用しました。

unique関数とlength関数を組み合わせる書き方は前処理大全では推奨されていない書き方ですが、
この例では可読性が十分高く、処理速度もおそらく問題にならないでしょうからAwesomeということにします。

### 3-2 合計値の算出
ホテルと宿泊人数毎に集計してみます。複数の列についてグループ分けして集計を行う場合は、`:hote_id`と`:people_num`をArrayとして、
groupby関数の引数にすればOKです。
また、グループごとに列の合計値を出力するには、sum関数を指定すればよいです。

```julia:ex3-preprocess2
df3_2 = @chain reserve_df begin
  groupby([:hotel_id,:people_num])
  combine(:total_price=> sum =>:price_sum)
end
first(df3_2) |> println
```

\prettyshow{ex3-preprocess2}

### 3-3 極値、代表値の算出

ホテル毎にtotal_price列の最大値、最小値、平均値、中央値、20%のパーセンタイルを出力します。
平均値、中央値、パーセンタイルの出力には、新たな関数が必要なので、Statistics.jlを導入します。
パーセンタイルは、無名関数を使用するため、やや冗長な書き方となっています。
```julia:ex4-preprocess2
using Statistics
@chain reserve_df begin
  groupby(:hotel_id)
  combine(:total_price=>maximum=>:price_max,
          :total_price=>minimum=>:price_min,
          :total_price=>mean=>:price_mean, 
          :total_price=>median=>:price_medeian,
          :total_price=>(r->quantile(r,0.2))=>:price_20per) 
  first(10)
  println
end
```

\prettyshow{ex4-preprocess2}

### 3-4 ばらつき具合の算出

分散や標準偏差は、平均同様にStatistics.jlをusingすれば使えます。
分散や標準偏差は、データ数が1つしかない場合にはNaN（Not a Number）を返します。
```julia:ex5-preprocess2
using Statistics
@show var([1,5,9])
@show std([1,5,9])
@show var([1])
@show std([1])
```
\prettyshow{ex5-preprocess2}

varとstdについてNaNを0に変更する方法を調査しました。いくつか方法はありましたが、
``ifelse(isnan(x),0,x)``という関数を使うのが一番短く書けそうです。
(R版の回答にあるcoalesce関数はjuliaにもありますが、機能が異なるようです。)

NaNを0に置き換える処理はパイプライン処理の中で無名関数を使って実装することもできますが、
可読性は低いので、ブロードキャスト演算で最後にまとめて処理するのがAwesomeでしょう。
```julia:ex6-preprocess2
using Chain,Statistics,DataFrames
df3_4=@chain DataFrame(a=["あ","あ","い"],b=[1,2,3]) begin
  groupby(:a)
  combine(:b=>sum,
          :b=>(r->ifelse(isnan(var(r)),0,var(r))) =>:b_var,
          :b=>std)
end
@show df3_4
df = df3_4[!,2:end] #２列目以降のviewを作成。１列目にisnanを適用するとエラーがかえって来ます。
df .= ifelse.(isnan.(df),0,df) #ブロードキャスト演算
println()
@show df3_4
```
\prettyshow{ex6-preprocess2}

この方法を例題に適用すると以下のようになります。
```julia:ex7-preprocess2
df3_4=@chain reserve_df begin 
  groupby(:hotel_id)
  combine(:total_price=>var,
          :total_price=>std)
end
df = df3_4[!,2:end] #２列目以降のviewを作成。１列目にisnanを適用するとエラーがかえって来ます。
df .= ifelse.(isnan.(df),0,df) #ブロードキャスト演算
@show first(df3_4,10)
```
\prettyshow{ex7-preprocess2}

\note{前処理大全の著者によれば、データはパートナーの心と同様に不安定でばらつきがあるものだそうです。
分散値/標準偏差値とパートナーの気持ちを常々気にかけたいと思います。}

### 3-5 最頻値の算出

``:total_price``を100の位を四捨五入して、最頻値を求めます。
四捨五入はround関数で実行できますが、丸める桁はキーワード引数digitsで指定する必要があります。
StatsBase.jlをインポートしておけば、pythonと同じくmode関数で最頻値を求めることが可能です。

```julia:ex8-preprocess2
using StatsBase
mode(round.(reserve_df.total_price, digits=-3)) |> println
```
\prettyshow{ex8-preprocess2}

2万円くらいホテルにお金を落としている人が一番多いということですね。

### 3-6 順位の算出

ホテルごとに予約日時順の番号付けをしてみます。
そもそも予約日時がString型として認識されているので、まずはDateTime型にパースします。
```julia:ex9-preprocess2
using Dates
reserve_df.reserve_datetime = DateTime.(reserve_df.reserve_datetime,dateformat"y-m-d HH:MM:SS")
reserve_df |> first |> println
```
\prettyshow{ex9-preprocess2}

ランキング付けに対応する関数はStatsBase.jlに用意されています。

|関数名|表示法|
|-----|-----|
|ordinalrank|1234|
|competerank|1223|
|denserank|1223|
|tiedrank|1 2.5 2.5 4|

ランキング方法にもいくつか種類がありますが、日時が完全に一致することはないでしょうから、
ここでは`ordinalrank`を利用します。

前処理の手順としては、groupby関数でhotel_id毎にデータを分けて、select関数で必要な列を選びます。

select関数の引数は``:列名 => 処理 => :新しい列名``というようにcombine関数と同じような与え方が可能です。
ではやってみます。

```julia:ex10-preprocess2
using StatsBase
@chain reserve_df begin
  groupby(:hotel_id)
  select(:,:reserve_datetime => ordinalrank =>:log_no)
  first(10)
  println
end
```
\prettyshow{ex10-preprocess2}
一番右の列に`:log_no`の列が追加されていることが確認できます。

### Q ランキング
ホテル毎に予約数を集計して、ランキング付けを行います。同じ予約数の場合は、
最小の順位を付けることになっているので、ordinalrankではなくて、competerankを利用します。

```julia:ex11-preprocess2
@chain reserve_df begin
  groupby(:hotel_id)
  combine(:reserve_id => length => :rsv_cnt)
  select(:,:rsv_cnt => competerank =>:rsv_cnt_rank)
  first(10)
  println
end
```
\prettyshow{ex11-preprocess2}


\prevnext{/tips/preprocess1}{Awesome な前処理1}{/tips/preprocess3}{Awesome な前処理3}
\backtotop