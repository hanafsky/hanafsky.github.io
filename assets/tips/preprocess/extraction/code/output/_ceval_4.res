:(let
      var"##416" = reserve_url
      var"##417" = Downloads.download(var"##416", IOBuffer())
      var"##418" = String(take!(var"##417"))
      var"##419" = CSV.read(IOBuffer(var"##418"), DataFrame)
      var"##419"
  end)