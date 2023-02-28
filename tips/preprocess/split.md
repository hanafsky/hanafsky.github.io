
@def title="juliaで前処理大全4"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2021,6,4)
@def published="4 June 2021"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# juliaで前処理大全 5.分割
\titleimage{/assets/tips/preprocess.jpg}{https://pixabay.com/photos/food-salad-raw-carrots-1209503/}
\share{tips/preprocess/}{juliaで前処理大全}

juliaで前処理大全その4です。今回は分割をテーマに扱います。

\toc

## 準備
今回は製造レコード``production.csv``と月ごとの経営指標のデータ``monthly_index.csv``を読み込みます。
```julia:ex1-preprocess4
using DataFrames,CSV,Chain,Downloads,NaturalSort
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"
monthly_index_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/monthly_index.csv"

production_df = @chain production_url Downloads.download CSV.File DataFrame
monthly_index_df = @chain monthly_index_url Downloads.download CSV.File DataFrame
first(production_df,10) |> println
```

\prettyshow{ex1-preprocess4}

### レコードデータにおけるモデル検証用のデータ分割
#### 交差検証
製造レコードのデータセットを用いて、データの分割を行います。
流れは以下のようになっています。
\begin{mermaid}
~~~
graph TD
    id1("ホールドアウト検証用に20%のデータを確保")
    id2(残りのデータを4分割して交差検証)
    id1-->id2
~~~
\end{mermaid}
データの分割そのものの実装は易しいのですが、コードの可読性とバグ削減の観点から、
有名なパッケージを使うのがAwesomeとされています。
PythonのScikitLearnはjuliaから容易にインポートできますが、
julia純正で何かないか探してみました。
MLUtils.jlを使ってみることにします。
データの分割は``splitobs``、データのシャッフルは``shuffleobs``、K-foldCVには``kfolds``を使います。

```julia
using MLUtils, Random
Random.seed!(71)#幸運を呼ぶ乱数シード71
#ホールドアウト検証用のデータ分割。0.8は学習データの割合
train_df,test_df = @chain production_df shuffleobs splitobs(at=0.8) 
test_data=test_df[!,Not(:fault_flg)]
test_target=test_df[!,:fault_flg]

for train,val in kfolds(train_df,k=4)
    train_data=train[!,Not(:fault_flg)]
    train_target=train[!,:fault_flg]
    val_data = val[!,Not(:fault_flg)]
    val_target = val[!,:fault_flg]
    # trainを使って学習モデルを構築、valで検証
end
# 交差検証の結果をまとめる
# test_dataを用いて学習モデルの推論を行い検証。
```

``splitobs``と``kfolds``をDataFrameに対して適用すると、SubDataFrameがかえってきます。
SubDataFrameにはDataFrameに対して行った処理を同じように適用できます。
行番号を直す必要もなく、きわめてエレガントな処理と言えるでしょう。

### 時系列データにおけるモデル検証用のデータ分割
#### 時系列データにおける学習／検証データの準備
次は、時系列データの取り扱いです。時系列データの解析では、未来のデータを使って過去のデータを
予測すると不当に精度が高くなってしまうため、あくまで過去のデータから未来のデータを予測する必要があります。
この例題では、学習期間（24カ月）と検証期間（12カ月）を12カ月スライドさせながらデータを生成します。

時系列データの解析に適した分割手法は、あまり汎用的なものが無さそうだったので、python版と同じく実装することにしました。

```julia
let
    train_window_start = 1 # 学習データの開始行番号
    train_window_end = 24 # 学習データの終了行番号
    horizon = 12 # 検証データ数
    skip = 12 # スライドするデータ数

    sort!(monthly_index_df,:year_month) # 年月に基づいてデータを並べ替え
    while true
        test_window_end = train_window_end + horizon
        train =monthly_index_df[train_window_start:train_window_end,:]
        test = monthly_index_df[(train_window_end+1):test_window_end,:]
        test_window_end ≥ size(monthly_index_df)[1] && break
        train_window_start += skip #　学習データをスライド
        train_window_end += skip
        # 検定の結果をまとめる。
    end
end    
```

\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prevnext{/tips/preprocess/join}{juliaで前処理大全 結合}{/tips/preprocess/generation}{juliaで前処理大全 生成}

\backtotop


{{ addcomments }}