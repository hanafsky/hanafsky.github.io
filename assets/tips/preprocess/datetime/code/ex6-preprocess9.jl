# This file was generated, do not modify it. # hide
@chain reserve_df begin
    select(
        :reserve_datetime => ByRow(d->d+Day(1)) => :reserve_datetime_1d,
        :reserve_date => ByRow(d->d+Day(1)) => :reserve_date_1d,
        :reserve_datetime => ByRow(d->d+Hour(1)) => :reserve_datetime_1h,
        :reserve_datetime => ByRow(d->d+Minute(1)) => :reserve_datetime_1m,
        :reserve_datetime => ByRow(d->d+Second(1)) => :reserve_datetime_1s
    )
    first(10)
    println
end