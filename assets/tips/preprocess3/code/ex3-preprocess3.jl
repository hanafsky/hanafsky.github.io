# This file was generated, do not modify it. # hide
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