@def title="juliaで前処理大全7"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2022,8,18)
@def published=" August 18 2022"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# juliaで前処理大全 8.数値型

juliaで前処理大全その7です。今回は数値型を取り扱います。

\toc

## 数値型への変換

### Q 様々な数値型の変換
$40000 / 3 $をさまざまな数値のデータ型に変換するというお題です。

#### 型の確認
```!
typeof(40000/3)
```
デフォルトの型を確認すると``Float64``であることがわかります。
#### 整数型へ変換
整数型に変換するには``round``関数、あるいは``floor``関数を用います。
```!
round(Int, 40000/3)
```
```!
floor(Int, 40000/3)
```
\note{この2つの関数はとくに違いが無さそうですが、負の数に適用する場合、注意が必要です。
      ```!
      round(Int, -2.1),floor(Int, -2.1)
      ```}

## 対数化による非線形な変換
$$
\log (年齢 + 1) = (対数化した年齢)
$$
のような対数変換を行うと値が大きくなるほど値の差の意味をなくす効果があります。
また、回帰分析などを行うときに目的変数が負の値をとるとまずい場合に、対数変換を適用することがあります。
この場合、対数スケールで見たときに誤差の分散が等しい仮定をすることになりますが、細かく意識している人っているのか偶に疑問を抱きます。
### Q 対数化
ホテルの予約レコードのtotal_priceを1000で割って1を足して、底10で対数化するというお題です。

transform関数とByRowと無名関数を使って難なく実現できます。
```julia:ex1-preprocess7
using DataFrames,CSV,Chain,Downloads
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url begin 
                    Downloads.download 
                    CSV.File 
                    DataFrame
                    transform(:total_price=>ByRow(c->log10(c/1000 + 1))=>:total_price_log)
                    end

first(reserve_df,10) |> println
```

\prettyshow{ex1-preprocess7}
## カテゴリ化による非線形な変換

### Q 数値型のカテゴリ化
ホテルの予約レコードの顧客テーブルの年齢を10刻みのカテゴリー型として追加するというお題です。
行ごとの処理と列全体を分けて行っているので、本のpythonコードなどと比べるとやや冗長な書き方になっています。
```julia:ex2-preprocess7
using CategoricalArrays
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"
customer_df = @chain customer_url Downloads.download CSV.File DataFrame
transform!(customer_df, :age=>ByRow(c->10floor(Int,c/10))=>:age_rank)
transform!(customer_df, :age_rank=>categorical=>:age_rank)

first(customer_df,10) |> println
```
\prettyshow{ex2-preprocess7}
## 正規化
正規化処理にもいくつか種類があります。
- 中心化: 平均値が0になるようにする。
- 標準化: 平均値が0、かつ標準偏差が1になるようにする。
- 
### Q 正規化
ホテルの予約レコードの予約人数と合計金額を平均0、標準偏差1になるように正規化するというお題です。
この正規化には``StatsBase.jl``の``zscore``が使えます。
```julia:ex3-preprocess7
using StatsBase
transform!(reserve_df,:people_num=>zscore, :total_price=>zscore)
first(reserve_df,10) |> println
```
\prettyshow{ex3-preprocess7}

なお、zscoreでは標本標準偏差が適用されることに意識しておく必要があります。
また、
\note{全ての列に適用するときはmapcolsあるいはmapcols!が使えます。
```julia
mapcols(zscore,df)
```
}

また、最小値0、最大値1でスケーリングするにはStatsBase.jlにUnitRangeTransormが用意されています。

```!
standardize(UnitRangeTransform, [0.0 -0.5 0.5; 0.0 1.0 2.0], dims=2)
```

ただ、DataFrameには適用できないようなので、もしやりたいなら次のように適当な関数を作って適用したほうがいいでしょう。
```julia
unitrangetransform(v)=(v-minimum(v))/(maximum(v)-minimum(v))
transform(df, :colname=>unitrangetransform)
```
## 外れ値の除去
標準化後に絶対値が3を超えないデータだけを採用します。
### Q 標準偏差基準の外れ値の除去
zscoreを適用した列に対して、絶対値が3以下のデータをフィルターしています。
```julia:ex4-preprocess7
reserve_df2 = @chain reserve_df begin
      transform(:total_price=>zscore)
      filter(:total_price_zscore=>(c->abs(c)≤3),_)
end

first(reserve_df2,10) |> println
```
\prettyshow{ex4-preprocess7}
## 主成分分析による次元圧縮
主成分分析によって、データの次元を圧縮するお題です。
### Q 主成分分析による次元圧縮
PCAはMultivariateStats.jlで実装されています。
注意点は、データ行列を転置して渡す必要があることです。
```julia
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"
production_df = @chain production_url Downloads.download CSV.File DataFrame
import MultivariateStats
X = @chain production_df begin
    select(:length,:thickness)
    Matrix
    transpose
end
M = MultivariateStats.fit(MultivariateStats.PCA, X)
MultivariateStats.predict(M, X)
```
## 数値の補完
この節は欠損値の取り扱いに関してまとめています。
欠損にはいくつか種類があるようです。
- MCAR: 完全にランダムな欠損
- MAR: ほかの項目に依存した欠損
- MNAR: 欠損したデータに依存した欠損

一番簡単な対処方法は欠損値を削除してしまうことです。
その他の対処方法としては、定数による補完、集計値（平均値・中央値など）による補完、欠損していないデータに基づく予測値によって補完、時系列の関係から補完などがあるようです。
### Q 欠損レコードの削除
対象レコードはthicknessに欠損が存在する製造レコードです。
まずデータを読み込む際に、欠損値を表す文字列をしているようにキーワード引数を指定します。
欠損値の除去は``dropmissing``関数で簡単に行えます。
```julia:ex5-preprocess7
production_missing_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production_missing_num.csv"
production_missing_df = @chain production_missing_url begin
    Downloads.download 
    CSV.File(;missingstring="None") 
    DataFrame
end

@chain dropmissing(production_missing_df)  first(10) println
```
\prettyshow{ex5-preprocess7}

### Q 定数補完
欠損値を1に置き換えます。
missingを置き換えるには、SQLの例と同じく``coalesce``が利用可能です。
```julia:ex6-preprocess7
@chain production_missing_df begin
    transform(:thickness=>ByRow(c->coalesce(c,1))=>:thickness)
    first(30) 
    println
end
```
\prettyshow{ex6-preprocess7}
### Q 平均値補完
欠損値に平均値を代入するお題です。
平均を``mean``関数で計算するにはビルトインモジュールの``Statistics.jl``をインポートする必要があります。
しかし、欠損値を含んだままで平均を計算すると、計算結果も``missing``になってしまいます。
各種統計量をまとめて計算可能な``describe``関数を利用すれば、欠損値があっても平均値を計算可能なので、これを利用することにします。

平均値を計算した後は、定数補完と同様の処理が可能です。
今回は``Chain.jl``の``@aside``マクロを使って、平均値の計算をパイプライン処理の中に入れてました。
```julia:ex7-preprocess7
@chain production_missing_df begin
    @aside M = describe(_, :mean,cols=:thickness) # 平均値を計算
    @aside thickness_mean = M[!,:mean][1] # データフレームから平均値を取り出す
    transform(:thickness=>ByRow(c->coalesce(c,thickness_mean))=>:thickness) # 欠損値を平均値で置き換え
    first(30) 
    println
end
```
\prettyshow{ex7-preprocess7}
19.4704というのが平均値です。

公式パッケージには次の多重代入法に関連する``Impute.jl``というパッケージがあって、こちらを使うともう少しエレガントに処理が可能です。

```julia
using Impute
@chain production_missing_df begin
    Impute.substitute(;statistic=Impute.mean)
end

```
### Q PMMによる多重代入
PMM(Predictive Mean Matching)は、残念ながら``Impute.jl``では実装されていないようです。[^1]
（逆に実装するチャンスともいえます。）
おとなしく、RCallやPyCallで処理を呼び出すか、``Impute.jl``の別の補完法を使うのが良さそうです。

[^1]: 他のパッケージもあるにはあるのですが、RCallでwrapしたもののようです。

\prev{/tips/preprocess/unfold}{juliaで前処理大全 展開}

\backtotop


{{ addcomments }}