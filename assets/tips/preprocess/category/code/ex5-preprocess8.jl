# This file was generated, do not modify it. # hide
production_missc_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production_missing_category.csv"

production_missc_df = 
    @chain production_missc_url begin 
        Downloads.download 
        CSV.File 
        DataFrame
        select(:type=>categorical=>:type,
              :length,:thickness)
    end

first(production_missc_df,10) |> println