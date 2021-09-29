:(let
      var"##309" = Downloads.download(reserve_url, IOBuffer())
      var"##310" = String(take!(var"##309"))
      var"##311" = CSV.read(IOBuffer(var"##310"), DataFrame)
      var"##311"
  end)