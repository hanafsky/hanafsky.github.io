quote
    local var"##509" = reserve_url
    local var"##510" = Downloads.download(var"##509", IOBuffer())
    local var"##511" = String(take!(var"##510"))
    local var"##512" = CSV.read(IOBuffer(var"##511"), DataFrame)
    var"##512"
end