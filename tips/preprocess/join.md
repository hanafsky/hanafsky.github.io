@def title="juliaで前処理大全3"
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

# juliaで前処理大全 4.結合

juliaで前処理大全その3です。今回は結合を扱います。

\toc

## 準備
まずは、ホテルの予約データ``reserve.csv``を読み込みます。
``hotel.csv``と``customer.csv``も結合処理に利用するので、一緒に読み込みます。
予約日時の列（:reserve_datetime）がStringで読み込まれているので、DateTime型に変更します。
```julia:ex1-preprocess3
using DataFrames,CSV,Chain,Downloads,NaturalSort
reserve_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"
hotel_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/hotel.csv"
customer_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/customer.csv"

reserve_df = @chain reserve_url Downloads.download CSV.File DataFrame
hotel_df = @chain hotel_url Downloads.download CSV.File DataFrame
customer_df = @chain customer_url Downloads.download CSV.File DataFrame
using Dates
reserve_df.reserve_datetime = DateTime.(reserve_df.reserve_datetime, dateformat"yyyy-mm-dd HH:MM:SS")
first(hotel_df) |> println
```
\prettyshow{ex1-preprocess3}
\note{customer_idで自然なソートを行うために、NaturalSort.jlをインポートしています。

~~~
<a href="https://github.com/JuliaStrings/NaturalSort.jl"><img src="https://github-link-card.s3.ap-northeast-1.amazonaws.com/JuliaStrings/NaturalSort.jl.png" width="460px"></a>
~~~
```julia
sort(df,:customer_id,lt=natural)
```
のように使っています。
普通にソートするとこのようになってしまいますが、
```
c_1
c_10
c_100
```
NaturalSort.jlを使うと、
```
c_1
c_2
c_3
```
のように、適切に並べ替えてくれます。
}

## 結合
### マスターテーブルの結合

``reserve_df``と``hotel_df``を`:hotel_id`が等しいデータ同士で結合します。
ただし、宿泊人数が1かつビジネスホテルであるという条件付きです。

ポイントとなるのは、結合処理を行う前にフィルター処理を行って、
結合するデータのサイズをなるべく小さくすることらしいです。

結合処理には、"双方に存在するデータ"同士での統合なので、内部結合の関数`innerjoin`を利用します。
今回は一度フィルターをかけるだけなので、@chainマクロによるパイプライン処理は使っていません。

```julia:ex2-preprocess3
innerjoin(filter(:people_num=>==(1),reserve_df),
          filter(:is_business=>==(true),hotel_df),
          on=:hotel_id) |> first |> println
```

\prettyshow{ex2-preprocess3}

### 条件に応じた結合テーブルの切り替え

あるホテルと同じ地域にあるホテルを推薦リストを作る例題です。
複数のマスターテーブルをつくる必要があるため、なかなか複雑です。
前処理大全とは順番を変えて、先にレコメンド候補のテーブルを作っておくことにします。
こうすると、あとは1回のパイプラインで処理をまとめることが可能になります。

複数列を1つの列にまとめる作業をstack関数で実施できますし、かなりAwesomeな書き方だと思います。

ただし、処理が複雑なので、すっきり書いてもわかりにくいです。

```julia:ex3-preprocess3
using Chain
recommend_hotel_mst = @chain hotel_df begin
  select(:hotel_id,:big_area_name,:small_area_name)
  stack([:big_area_name,:small_area_name],value_name=:join_area_id)
  select(:hotel_id=>:rec_hotel_id,:join_area_id)
end

base_hotel_mst = @chain hotel_df begin
  groupby([:big_area_name,:small_area_name]) # big_area,small_area毎にグループ分け
  combine(:hotel_id=>(r->length(r)-1)=>:hotel_cnt) # hotel_idの数をカウント(自分をのぞく)
  transform([:hotel_cnt,:big_area_name,:small_area_name]=>
            ((a,b,c)->ifelse.(a.>20,c,b))=>:join_area_id) # カウント数が20以下ならbig_areaをjoin_area_idに設定
  select(:small_area_name,:join_area_id) 
  innerjoin(hotel_df,_,on=:small_area_name) # hotel_dfと:small_area_nameで内部結合する。
  select(:hotel_id,:join_area_id) 
  innerjoin(_,recommend_hotel_mst, on=:join_area_id) # レコメンド候補を結合する。
  filter([:hotel_id,:rec_hotel_id]=>((a,b)->a .!= b) ,_) # 自分ホテルをのぞく
  select(:hotel_id,:rec_hotel_id)
end

first(base_hotel_mst,10) |> println
```

\prettyshow{ex3-preprocess3}

### 過去データの結合

#### Q n件前のデータ取得
2回前の予約時の支払い額を、新たな列（before_price）として追加するという例題です。

以下のような流れでプログラムを書いていきます。

\begin{mermaid}
~~~
graph TD
  id1(custormer_id,reserve_datetimeで並べ替え)
  id2(customer_idについてgroupbyを適用)
  id3(lag関数を使って2件前の支払い額を調べる)
  id1-->id2
  id2-->id3
~~~
\end{mermaid}

前処理大全と順番が違うのは、sortをGroupedDataFrameに対して直接適用できないからです。

まず、lag関数を使うために、ShiftedArrays.jlを読み込みます。
transform関数は新たな列を作れる機能がselect関数と似ていますが、
select関数と異なり、選択していない列も保存されます。
GroupedDataFrameにtransform関数を作用させると、ただのDataFrame型に戻るようです。

```julia:ex4-preprocess3
using Chain, ShiftedArrays

@chain reserve_df begin
  sort(:reserve_datetime)
  sort(:customer_id,lt=natural)
  groupby(:customer_id)
  transform(:total_price=>(r->lag(r,2))=>:before_price)
  select(:customer_id,:reserve_datetime,:total_price,:before_price) # 表示する列を選択
  first(_,15) # 15件目のレコードまで選択
  println
end
```

\prettyshow{ex4-preprocess3}

初回と2回目の予約レコードについては、前々回の支払金額がmissingとして追加されていることがわかります。

#### Q 過去n件の合計値
今度は同一顧客の過去3件の予約金額の合計値を出力する例題です。
Rのrun_sum関数に相当するものとしては、RollingFunctions.jlが使えそうです。
``rolling(f::Function, v::Vector, window::Int64)``の形式で呼び出してみます。
```!
using RollingFunctions
rolling(sum, [1,2,3,4,5],3)
```
もとの配列と同じ長さで、3つ毎に足した和が得られているはずです。
ただし、最初と2つ目のデータは、3つ分のデータはありませんから、missingに置き換えたいです。
また、そもそもデータ数が窓幅より少ない場合もmissingを返したいですね。

このような関数をroll_sumとして実装してみましょう。
```!
function roll_sum(v,window=3)
  length(v) < window ? Vector{Missing}(undef,length(v)) : 
                       vcat(Vector{Missing}(undef,window-1),rolling(sum,v,window))
end
roll_sum([1,2,3,4,5],3)
```

前の例のlag関数をroll_sumで置き換えて、新たに:price_sumの列を作ります。
DataFrames.jlでは、適当に作った関数を用いて、すっきりした処理を記載することができました。
\marker{対応する処理が既存のライブラリになければ、作ってしまえばよい}のです。
これは処理が高速なjuliaならでは強みだと思います。

```julia:ex5-preprocess3
using Chain, ShiftedArrays

@chain reserve_df begin
  sort(:reserve_datetime)
  sort(:customer_id,lt=natural)
  groupby(:customer_id)
  transform(:total_price=>roll_sum=>:price_sum)
  select(:customer_id,:reserve_datetime,:total_price,:price_sum) # 表示する列を選択
  first(_,15) # 15件目のレコードまで選択
  println
end
```

\prettyshow{ex5-preprocess3}
#### Q 過去n件の平均値
この例題では、

平均値を出す関数としては、runmean関数が使えそうです。
```!
using RollingFunctions
runmean([1,2,3,4,5],3)
```

ただし、自身の行を含めない平均予約金額であり、
過去に予約がない場合はmissingを割り当てたいので、
以下のような関数を作ることにします。

```!
function price_avg(v,window=3)
  length(v) < window ? vcat(missing,runmean(v,length(v))[begin:end-1]) :
                       vcat(missing,runmean(v,window)[begin:end-1])
end
price_avg([1,2,3,4,5],3)
```
うまく動作することを確認できました。

```julia:ex6-preprocess3
using Chain, ShiftedArrays

@chain reserve_df begin
  sort(:reserve_datetime)
  sort(:customer_id,lt=natural)
  groupby(:customer_id)
  transform(:total_price=>price_avg=>:price_avg)
  select(:customer_id,:reserve_datetime,:total_price,:price_avg) # 表示する列を選択
  first(_,15) # 15件目のレコードまで選択
  println
end
```

\prettyshow{ex6-preprocess3}

#### Q 過去n日の合計値
予約テーブルのすべてのデータ行にたいして、自身の行を含めずに同じ顧客の過去90日間の合計予約金額を付与するという問題です。
(予約がない場合は0)
問題もだんだん難しくなってきており、RにもpythonもAwesomeな回答はありませんでした。

顧客ごとにグループ化するのは前の問題と共通していますので、過去の予約合計金額を計算する関数``total_price_history``を作ることにしました。
各予約日毎に自身の行を含めず、過去90日分の予約日をフィルターした日付を抽出します。
フィルターされた日付に含まれる場合について、予約金額の合計の和をとって
ただし、フィルターされた列が空の場合は、0を返すことにします。
(``enumerate``関数を多用しているので、ちょっとわかりにくいかもしれません。)

```julia:ex7-preprocess3
using Dates
function total_price_history(reserve_dates,prices;day=Day(90))
  tp = similar(prices)
  for (index,date) in enumerate(reserve_dates)
    filtered_date = filter(((d)->date-day ≤ d < date), reserve_dates)
    tp[index] = filtered_date==DateTime[] ? 0 :
                sum(prices[i] for (i,d) in enumerate(reserve_dates) if d in filtered_date)
  end
  return tp
end

@chain reserve_df begin
  sort([:customer_id,:reserve_datetime])
  groupby(:customer_id)
  transform([:reserve_datetime,:total_price]=>total_price_history=>:total_price_90d)
  select(:customer_id,:reserve_datetime,:total_price,:total_price_90d) # 表示する列を選択
  sort(:customer_id,lt=natural)
  first(_,15) # 15件目のレコードまで選択
  println
end
```

\prettyshow{ex7-preprocess3}

このようにオーダーメイドの処理を自作することで、パイプライン処理をシンプルにまとめることができました。

### 全結合
顧客ごとに2017年1月～2017年3月の月間利用料金を計算する問題です。
これも少々頭を悩ませました。
流れは以下のようになっています。

\begin{mermaid}
~~~
graph TD
  sub1(年月マスターのデータフレームを作成)
  sub2(顧客テーブルに対して年月マスターを全結合)
  id1(予約レコードから必要な列を抽出<br>customer_id,checkin_date,total_price)
  id2(チェックイン日を年月マスターの形式に合わせる)
  id3(年月マスターに対して結合<br>chainの都合上rightjoin)
  id4(顧客IDと年月でグループ分け)
  id5(予約金額を合計)
  id6(Missingを0に置き換え)
  subgraph 年月マスターの作成
  sub1-->sub2
  end
  id1-->id2
  id2-->id3
  id3-->id4
  id4-->id5
  id5-->id6
~~~
\end{mermaid}
コード化したものがこちらです。
```julia:ex8-preprocess3
# 年月マスタの生成
month_mst = DataFrame(:year_month=>[Date("2017-01-01")+Month(m) for m in 0:2]) 
customer_mst = crossjoin(customer_df,month_mst)

summary_result = @chain reserve_df begin
  select(:customer_id,
         :checkin_date=>ByRow(r->Date(Year(r),Month(r)))=>:year_month,
         :total_price)
  # customer_mstに対して結合したいのでleftjoinではなくrightjoinを使う。
  rightjoin(customer_mst,on=[:customer_id,:year_month]) 
  groupby([:customer_id,:year_month])
  combine(:total_price=>sum=>:price_sum)
  sort(:year_month)
  sort(:customer_id,lt=natural)
end
replace!(summary_result.price_sum,missing=>0)

first(summary_result,10) |> println

```
\prettyshow{ex8-preprocess3}
本の通りの答えが得られていると思います。

この章の問題はかなり難しいため、問題を理解するのもコードを考えるのも、かなり骨が折れました。
しかし、自前で関数を用意する考えや、DataFrames.jlとChain.jlのおかげで、本のコードに勝るとも劣らない非常に\marker{Awesome}な処理ができたのではないかと思います。
\prev{/tips/preprocess/aggregation}{juliaで前処理大全 集約}

\backtotop