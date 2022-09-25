
@def title="juliaで前処理大全8"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2022,9,25)
@def published=" September 25 2022"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# juliaで前処理大全 9.カテゴリ型

juliaで前処理大全その8です。今回はカテゴリ型を取り扱います。

\toc

## カテゴリ型への変換
### Q カテゴリ型の変換
CategoricalArrays.jlを使うとカテゴリ型に変換できます。
```!
using DataFrames,CSV,Chain,Downloads
using CategoricalArrays
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"

customer_df = @chain customer_url begin 
                    Downloads.download 
                    CSV.File 
                    DataFrame
                    DataFrames.transform(:sex=>categorical=>:sex_c)
                    end
first(customer_df,10) |> println
```
カテゴリ型のマスターデータには、Rの場合と同じく、levels関数でアクセスできます。
```!
@show levels(customer_df.sex_c)
```
カテゴリ型のインデックスを取得するには``refs``というフィールドを取得すれば、閲覧可能です。
ただし、UInt型なので、Int型に変換して見やすくしています。
```!
@show customer_df.sex_c.refs .|> Int
```

インデックスの順番を自分好みに変えることもできます。
```
levels(customer_df.sex_c, ["woman","man"])
```

## ダミー変数化
### Q ダミー変数化
文字のカテゴリをダミー変数化します。いわゆる``One hot encoding``という処理です。
juliaではいくつかこの機能を備えたパッケージはありますが、
大して難しいコードでもないので、パイプライン処理の中に自分で書いてしまっても良さそうです。
[こちら](https://discourse.julialang.org/t/all-the-ways-to-do-one-hot-encoding/64807/2)のdiscourseの議論を参考にしてみました。ski先生流の書き方ならこのようになります。
```julia:ex1-preprocess8
@chain customer_df begin
    select(:sex, [:sex=>ByRow(isequal(v))=>Symbol("sex_is_"*v) for v in unique(customer_df.sex)])
    first(10)
    println
end
```
\prettyshow{ex1-preprocess8}
パイプライン処理の中で行えるので、Awesomeだと思います。

行列とブロードキャストを利用したエレガントな別解もあります。
```
customer_df.sex .== permutedims(unique(customer_df.sex))
```
\note{``permutedims``はベクトルを1行のマトリックスに変換してくれるbuiltin関数です。}
## カテゴリ値の集約
### Q カテゴリ値の集約
60歳以上のカテゴリ値を1つに集約するお題です。
まず、数値型の例と同様にCategoricalArrays.jlを使ってカテゴリ型に変更します。
CategoricalArrayがAny型をサポートしていないため、``replace!``関数で60歳以上のカテゴリを60に入れてしまうことにしました。
```julia:ex2-preprocess8
transform!(customer_df, :age=>ByRow(c->10floor(Int,c/10))=>:age_rank)
transform!(customer_df, :age_rank=>categorical=>:age_rank)
replace!(customer_df.age_rank,[70,80]=>60)
first(customer_df,20) |> println
```
\prettyshow{ex2-preprocess8}
\warning{
    StringとNumberが混在するAny型の配列をCategoricalArrayに変換しようとするとエラーがでます。
    ```!
    categorical([1,2,"3"])
    ```
}
## カテゴリ値の組み合わせ
### Q カテゴリ値の組み合わせ
年代と性別の組み合わせを使ってカテゴリ値を作るお題です。
``string``関数を使って簡単に実装できます。
```julia:ex3-preprocess8
@chain customer_df begin
    select(:age,:sex, [:age,:sex]=>ByRow((x,y)->string(floor(Int,x/10)*10, "_", y))=>:sex_and_age)
    DataFrames.transform(:sex_and_age=>categorical=>:sex_and_age)
    first(10)
    println
end
```
\prettyshow{ex3-preprocess8}
## カテゴリ型の数値化
### Q カテゴリ型の数値化
製造レコードから種別ごとに、平均障害率を計算するというお題です。
種別ごとに計算するのは``groupby``を使って実装できます。
自分自身のレコードを除かなければならないというのが少々曲者です。
今回は、ブロードキャスト演算子を使った無名関数で実装してみました。

```julia:ex4-preprocess8

production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"

production_df = 
    @chain production_url begin 
        Downloads.download 
        CSV.File 
        DataFrame
        groupby(:type)
        transform(:fault_flg=>(c->(sum(c) .- c)/(length(c)-1))=>:fault_flg_per_type)
    end

first(production_df,10) |> println
```
\prettyshow{ex4-preprocess8}
## カテゴリ型の補完
### Q KNNによる補完
まずデータを準備します。typeの列で欠損が発生しています。
欠損のないデータについてまずKNNで学習し、欠損のあるデータに適用するという流れです。
今回はjuliaにおけるScikitLearnのような存在であるMLJを利用してみたいと思います。[^1]

いつも通り、データの読み込みを行いますが、KNNを適用する準備として、``:type``の列は``categorical``型に変換します。
また、学習に利用するデータとして``:length``、``:thickness``を選んでおきます。

```julia:ex5-preprocess8

production_missc_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production_missing_category.csv"

production_missc_df = 
    @chain production_missc_url begin 
        Downloads.download 
        CSV.File 
        DataFrame
        select(:type=>categorical=>:type,
              :length,:thickness)
    end

first(production_missc_df,10) |> println
```
\prettyshow{ex5-preprocess8}

さて、データを訓練データとテストデータに分け、KNNで学習するようにしてみます。
\marker{出力を補完値にするために``predict``関数ではなく、``predict_mode``関数を使いました。}
それなりにAwesomeにかけたのではないでしょうか。

```julia:ex6-preprocess8
using MLJ
KNNClassifier = @load KNNClassifier pkg=NearestNeighborModels verbosity=0

train = dropmissing(production_missc_df)
test = filter(:type=>ismissing, production_missc_df)
y, X = unpack(train, ==(:type))
test[!,:type] = @chain machine(KNNClassifier(K=3), X, y) begin 
                    fit!
                    predict_mode(test[!, Not(:type)])
                end
first(test,10) |> println
```

\prettyshow{ex6-preprocess8}

[^1]: MLJについては、有名なパッケージではありますが、日本語での使い方をまとめた記事はあまりないので、そのうちにMLJのみを単独で取り上げてみたいと思います。

\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prev{/tips/preprocess/numeric}{juliaで前処理大全 数値型}

\backtotop


{{ addcomments }}