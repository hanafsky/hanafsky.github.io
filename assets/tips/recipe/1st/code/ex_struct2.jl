# This file was generated, do not modify it. # hide
mutable struct mBaz
    a
    b
end

mbaz=mBaz(1,2)
@show mbaz.a
mbaz.a = 2
@show mbaz.a