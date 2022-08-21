# This file was generated, do not modify it. # hide
@chain production_missing_df begin
    @aside M = describe(_, :mean,cols=:thickness) # 平均値を計算
    @aside thickness_mean = M[!,:mean][1] # データフレームから平均値を取り出す
    transform(:thickness=>ByRow(c->coalesce(c,thickness_mean))=>:thickness) # 欠損値を平均値で置き換え
    first(30) 
    println
end