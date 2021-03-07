@def title="Awesome な前処理"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# Awesome な前処理 3

前処理大全のjulia版その3です。
まずは、ホテルの予約データを読み込みます。
hotel.csvも結合処理に利用するので、一緒に読み込みます。
```julia:ex1-preprocess3
using DataFrames,CSV
path_rsv = joinpath("tips","data","reserve.csv")
path_hotel = joinpath("tips","data","hotel.csv")
reserve_df = CSV.read(path_rsv,DataFrame)
hotel_df = CSV.read(path_hotel,DataFrame)
#first(hotel_df) |> println
```

\prettyshow{ex1-preprocess3}


## 4 結合
### 4-1 マスターテーブルの結合

reserve_dfとhotel_dfを`:hotel_id`が等しいデータ同士で結合します。
ただし、宿泊人数が1かつビジネスホテルであるという条件付きです。

ポイントとなるのは、結合処理を行う前にフィルター処理を行って、
結合するデータのサイズをなるべく小さくすることらしいです。

結合処理には、"双方に存在するデータ"同士での統合なので、内部結合の関数`innerjoin`を利用します。
一度フィルターをかけるだけなので、パイプラインは使っていません。

```julia:ex2-preprocess3
innerjoin(filter(:people_num=>==(1),reserve_df),
          filter(:is_business=>==(true),hotel_df),
          on=:hotel_id) |> first |> println
```

\prettyshow{ex2-preprocess3}

### 4-2 条件に応じた結合テーブルの切り替え

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

### 4-3 過去データの結合



\prevnext{/tips/preprocess2}{Awesome な前処理2}{/tips/preprocess1}{Awesome な前処理1}

\backtotop