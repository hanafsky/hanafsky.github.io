# This file was generated, do not modify it. # hide
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