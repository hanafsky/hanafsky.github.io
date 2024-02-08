# This file was generated, do not modify it. # hide
production_missing_url = "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/production_missing_num.csv"
production_missing_df = @chain production_missing_url begin
    Downloads.download 
    CSV.File(;missingstring="None") 
    DataFrame
end

@chain dropmissing(production_missing_df)  first(10) println