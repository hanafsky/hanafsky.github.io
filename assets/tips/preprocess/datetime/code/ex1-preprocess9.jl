# This file was generated, do not modify it. # hide
using DataFrames, CSV, Chain, Downloads, Dates
reserve_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url begin
                Downloads.download
                CSV.File
                DataFrame
                transform(:reserve_datetime=>ByRow(d->DateTime(d, dateformat"yyyy-mm-dd H:M:S"))=>:reserve_datetime)
                transform(:reserve_datetime=>ByRow(Date)=>:reserve_date,
                          :reserve_datetime=>ByRow(Time)=>:reserve_time)
            end
first(reserve_df, 10) |> println