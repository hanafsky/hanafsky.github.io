# This file was generated, do not modify it. # hide
function add(a::Number,b::Number)::Number
    a+b
end

function add(a::String,b::String)::String
    a*b
end

println(add(1,2))
println(add("abc","def"))