# This file was generated, do not modify it. # hide
@chain reserve_df begin
    select(:reserve_datetime=>ByRow(year)=>:year,
           :reserve_datetime=>ByRow(month)=>:month,
           :reserve_datetime=>ByRow(day)=>:wday,
           :reserve_datetime=>ByRow(d->dayname(d,locale="english"))=>:weekday,
           :reserve_datetime=>ByRow(hour)=>:hour,
           :reserve_datetime=>ByRow(minute)=>:minute,
           :reserve_datetime=>ByRow(second)=>:second,
           :reserve_datetime=>ByRow(d->Dates.format(d, "yyyy-mm-ss H:M:S"))=>:format_str,
    )
    first(10)
    println
end