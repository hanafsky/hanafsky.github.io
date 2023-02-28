
@def title="juliaで前処理大全6"
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

# juliaで前処理大全 7.展開
\titleimage{/assets/tips/preprocess.jpg}{https://pixabay.com/photos/food-salad-raw-carrots-1209503/}
\share{tips/preprocess/}{juliaで前処理大全}

juliaで前処理大全その6です。今回は展開をテーマに扱います。

\toc

## 準備
今回は準備としてホテルの予約レコード``reserve.csv``を読み込みます。
```julia:ex1-preprocess6
using DataFrames,CSV,Chain,Downloads
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
first(reserve_df,10) |> println
```

\prettyshow{ex1-preprocess6}

## 横持ちへの変換

### Q 横持ち変換
結合の章では複数の列をまとめるのに``stack``関数を用いました。
ここでは1つの列を複数の列に展開するため、``unstack``関数を用います。

\note{unstackを利用するには、データフレーム以外に以下のようにさらに二つの引数を指定する必要があります。
    ```julia
    unstack(df::DataFrame, :新しい列名,:展開するデータ)
    ```
    ここでは、新しい列名のカラムとして``:people_num``、値として``:rsv_cnt``を指定しました。
    }

実際に適用してみましょう。

```julia:ex2-preprocess6
unfold_df = @chain reserve_df begin
    groupby([:customer_id,:people_num]) 
    combine(nrow=>:rsv_cnt)
    unstack(:people_num,:rsv_cnt; fill=0)
    select(["customer_id","1","2","3","4"])
end

first(unfold_df,10) |> println
```
\prettyshow{ex2-preprocess6}
処理の流れを解説すると以下のようになります。
1. ``:customer_id``と``:people_num``毎に場合分け
1. ``nrow``関数でグループの数を数え、``:rsv_cnt``に格納
1. ``unstack``関数で``:people_num``の値毎に``:rsv_cnt``の値を格納。missing値は0で埋める。
1. ``select``関数で並べ替え


## スパースマトリックスへの変換

上の例のようにデータを展開すると``missing``データができるので、メモリの節約のために
スパース行列にデータを格納しようというのが、この節のお題です。

juliaではビルトインモジュールの``SparseArrays.jl``の``sparse``を使えば、スパース行列を利用することが可能です。
利用方法を確認してみましょう。
```julia:ex3-preprocess6
using SparseArrays
print(@doc sparse)
```
\prettyshow{ex3-preprocess6}

最後の例を見るに、
```julia
sparse(行インデックス, 列インデックス, データ, 行数, 列数)
```
のように入力すれば使えそうです。[^1]

[^1]: scipyのcsc_matrixとはデータの指定順が異なります。

### Q スパースマトリックス
ここで問題になるのが、データが文字列の場合のインデックス取得です。
本では``:customer_id``などをカテゴリーデータへ変換した後に、そのままcsc_matrixなどの関数にそのまま代入しています。
juliaではCategoricalArrays.jlでカテゴリーデータへの変換が可能ですが、``sparse``へそのまま代入することはできませんでした。
したがって、カテゴリーデータに対して、行番号を割り当ててやる必要があります。
とりあえず、CategoricalArray型のrefsを参照をInt型に変換して、新たに``id``というデータとして格納し、これを行番号として割り当てることにしました。

```julia:ex4-preprocess6
using CategoricalArrays
cnt_df = @chain reserve_df begin
    groupby([:customer_id,:people_num]) 
    combine(nrow=>:rsv_cnt)
    transform(:customer_id=>categorical=>:customer_id)
    @aside id = Int.(_.customer_id.refs)
    hcat(_, DataFrame(:id=>id))
end
sp_data=sparse(cnt_df.id, cnt_df.people_num, cnt_df.rsv_cnt,length(levels(cnt_df.customer_id)),length(levels(cnt_df.people_num)))
Matrix(sp_data) |> println
```
\prettyshow{ex4-preprocess6}

少々冗長な書き方になってしまいました。私がCategoricalArrays.jlの使い方に習熟していないせいかもしれませんが、このあたりはまだjuliaの未成熟な領域かと思われます。

\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prevnext{/tips/preprocess/generation}{juliaで前処理大全 生成}{/tips/preprocess/numeric}{juliaで前処理大全 数値型}

\backtotop


{{ addcomments }}