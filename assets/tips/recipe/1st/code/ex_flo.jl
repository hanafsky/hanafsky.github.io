# This file was generated, do not modify it. # hide
struct FLO
    a
    b
    c
end

function (flo::FLO)(x)
    flo.a*x^2+flo.b*x+flo.c
end

f=FLO(1,2,3)
@show f(2)