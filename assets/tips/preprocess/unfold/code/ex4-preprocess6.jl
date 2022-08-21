# This file was generated, do not modify it. # hide
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