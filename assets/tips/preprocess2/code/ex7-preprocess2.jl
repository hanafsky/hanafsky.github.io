# This file was generated, do not modify it. # hide
df3_4=@chain reserve_df begin 
  groupby(:hotel_id)
  combine(:total_price=>var,
          :total_price=>std)
end
df = df3_4[!,2:end] #２列目以降のviewを作成。１列目にisnanを適用するとエラーがかえって来ます。
df .= ifelse.(isnan.(df),0,df) #ブロードキャスト演算
@show first(df3_4,10)