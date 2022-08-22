@def title="juliaで前処理大全5"
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

# juliaで前処理大全 6.生成
\titleimage{/assets/tips/preprocess.jpg}{https://pixabay.com/photos/food-salad-raw-carrots-1209503/}
\share{tips/preprocess/}{juliaで前処理大全}

juliaで前処理大全その5です。今回は生成をテーマに扱います。
章のテーマとしては不均衡なデータを取り扱う手法について述べています。
手法としては多すぎるデータを削るアンダーサンプリング、そして少ないデータを水増しするオーバーサンプリングの2つですが、この章では主に後者を取り扱います。

\toc

## 準備
今回は準備として製造レコード``production.csv``を読み込みます。
```julia:ex1-preprocess5
using DataFrames,CSV,Chain,Downloads
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"

production_df = @chain production_url Downloads.download CSV.File DataFrame
first(production_df,10) |> println
```

\prettyshow{ex1-preprocess5}

### アンダーサンプリングによる不均衡データの調整
ここはとくにコードもないので省略させてもらいます。
### オーバーサンプリングによる不均衡データの調整
製造レコードのデータセットを用いて、データの分割を行います。

まずは、代表的なオーバーサンプリングの方法であるSMOTEについてアルゴリズムをおさらいします。[^1]

\begin{mermaid}
~~~
graph TD
  id1(生成元のデータからランダムに1つのデータを選択)
  id2(1からkの整数値からランダムに選択しnを設定)
  id3(選択したデータにn番目に近いデータを新たに選択)
  id4(2つのデータの間のデータを生成)
  id5(指定したデータ数に達するまで繰り返す)
  id1-->id2
  id2-->id3
  id3-->id4
  id4-->id5
~~~
\end{mermaid}

前処理大全においては、自分でSMOTEの処理を実装するのではなく、適当なライブラリからインポートしてくることを推奨しています。

juliaでオーバーサンプリングを提供しているパッケージとしては、ClassImbalance.jlとMLUtils.jlがありました。前者は長らくメンテされていないため、依存パッケージのバージョンが整合しない可能性もあります。後者はまだドキュメントが整備されていないようで、SMOTEは実装されていないようです。[^2]
自分で実装しても良いのですが、ここではpythonのライブラリを呼び出してみたいと思います。
本のpythonコードが古いせいか、キーワード引数名に違いはあります。
また、DataFrame型をそのまま渡すことができないので、一度マトリックスに変換してオーバーサンプリング後にDataFrame型に戻す操作をしています。
この辺りの作業は止むを得ないですが、"Not Awesome"かもしれません。

```!
using PyCall
imblearn = pyimport("imblearn.over_sampling")
sm = imblearn.SMOTE(sampling_strategy="auto", k_neighbors=5, random_state=71)
imb_data = production_df[!,[:length,:thickness]] |> Matrix
imb_target = production_df.fault_flg
balance_data,balance_target = sm.fit_resample(imb_data, imb_target)
new_df= DataFrame(hcat(balance_data,balance_target),["length","thickness","fault_flg"]);
```

せっかくなので可視化してみることにしましょう。
まず、オーバーサンプリングする前のデータを散布図にしてみます。
```!
using StatsPlots
p = @chain production_df begin
        filter(:fault_flg=>==(false),_)
        @df scatter(:length, :thickness, label="false")
    end
                                                              
@chain production_df begin
      filter(:fault_flg=>==(true),_)
      @df scatter!(:length, :thickness, label="true")
    end
savefig(p, joinpath(@OUTPUT,"5-1.svg")) # hide
```
\figpop{5-1}

真の値のデータが偽のデータに比べて非常に少ないことがわかります。
一方で、オーバーサンプリングされたデータはどうでしょうか。
```!
p2 = @chain new_df begin
        filter(:fault_flg=>==(false),_)
        @df scatter(:length, :thickness, label="false")
    end
                                                              
@chain new_df begin
      filter(:fault_flg=>==(true),_)
      @df scatter!(:length, :thickness, label="true")
    end
savefig(p2, joinpath(@OUTPUT,"5-2.svg")) # hide
```
\figpop{5-2}
もともとのデータに比べて真のデータが水増しされていることがわかります。


[^1]: Synthetic Minority Over-sampling Technique

[^2]: oversampleという関数はある。




\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prev{/tips/preprocess/split}{juliaで前処理大全 分割}

\backtotop


{{ addcomments }}