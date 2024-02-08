# This file was generated, do not modify it. # hide
unfold_df = @chain reserve_df begin
    groupby([:customer_id,:people_num]) 
    combine(nrow=>:rsv_cnt)
    unstack(:people_num,:rsv_cnt; fill=0)
    select(["customer_id","1","2","3","4"])
end

first(unfold_df,10) |> println