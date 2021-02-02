# This file was generated, do not modify it. # hide
module A

struct bar
    x
    y
end

function foo()
    println("foo")
end

end #end module

BAR = A.bar(1,2)
println(BAR.x)

A.foo()