# This file was generated, do not modify it. # hide
tosecond(dt::Millisecond) = div(Dates.value(dt), 1000)
tominute(dt::Millisecond) = div(Dates.value(dt), 60000)
tohour(dt::Millisecond) = div(Dates.value(dt), 3600000)
@show tohour(dt)