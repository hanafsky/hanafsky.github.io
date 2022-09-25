# This file was generated, do not modify it. # hide
production_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production.csv"

production_df = 
    @chain production_url begin 
        Downloads.download 
        CSV.File 
        DataFrame
        groupby(:type)
        transform(:fault_flg=>(c->(sum(c) .- c)/(length(c)-1))=>:fault_flg_per_type)
    end

first(production_df,10) |> println