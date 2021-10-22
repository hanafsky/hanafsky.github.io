:(let
      var"##366" = Downloads.download(reserve_url, IOBuffer())
      var"##367" = String(take!(var"##366"))
      var"##368" = CSV.read(IOBuffer(var"##367"), DataFrame)
      var"##368"
  end)