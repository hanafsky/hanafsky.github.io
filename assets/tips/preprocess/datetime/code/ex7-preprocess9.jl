# This file was generated, do not modify it. # hide
using CategoricalArrays

function to_season(m)
    3≤m<6 ? "spring" : 
    6≤m<9 ? "summer" : 
    9≤m<12 ? "autumn" : "winter" 
end

@chain reserve_df begin
    select(:reserve_datetime => ByRow(to_season∘month) => :reserve_datetime_season)
    transform(:reserve_datetime_season => categorical => :reserve_datetime_season)
    first(10)
    println
end