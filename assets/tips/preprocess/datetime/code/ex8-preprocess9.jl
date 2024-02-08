# This file was generated, do not modify it. # hide
holiday_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/holiday_mst.csv"

holiday_mst = @chain holiday_url begin
                Downloads.download
                CSV.File
                DataFrame
            end

@chain reserve_df begin
    innerjoin(holiday_mst, on=[:checkin_date => :target_day ])
    first(10)
    println
end