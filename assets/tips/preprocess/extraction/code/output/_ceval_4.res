:(let
      var"##307" = Downloads.download(reserve_url, IOBuffer())
      var"##308" = String(take!(var"##307"))
      var"##309" = CSV.read(IOBuffer(var"##308"), DataFrame)
      var"##309"
  end)