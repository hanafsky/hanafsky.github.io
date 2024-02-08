# This file was generated, do not modify it. # hide
using Dates: Date
# filter(:checkin_date => row-> Date(2016,10,12) <= row <= Date(2016,10,13), reserve_df) |> println
filter(row-> Date(2016,10,12) <= row.checkin_date <= Date(2016,10,13), reserve_df) |> println