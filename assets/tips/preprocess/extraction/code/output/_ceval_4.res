quote
    local var"##452" = reserve_url
    local var"##453" = Downloads.download(var"##452", IOBuffer())
    local var"##454" = String(take!(var"##453"))
    local var"##455" = CSV.read(IOBuffer(var"##454"), DataFrame)
    var"##455"
end