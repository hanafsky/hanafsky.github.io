quote
    local var"##447" = reserve_url
    local var"##448" = Downloads.download(var"##447", IOBuffer())
    local var"##449" = String(take!(var"##448"))
    local var"##450" = CSV.read(IOBuffer(var"##449"), DataFrame)
    var"##450"
end