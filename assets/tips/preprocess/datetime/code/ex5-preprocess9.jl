# This file was generated, do not modify it. # hide
@chain reserve_df begin
    transform([:checkin_date, :checkin_time]=>ByRow(+)=>:checkin_datetime)
    select(
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->year(x)-year(y))=>:diff_year,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->12year(x)+month(x)-12year(y)-month(y))=>:diff_month,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->Dates.days(x-y))=>:diff_days,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tohour(x-y))=>:diff_hours,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tominute(x-y))=>:diff_minutes,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tosecond(x-y))=>:diff_seconds,
        )
    first(10)
    println
end