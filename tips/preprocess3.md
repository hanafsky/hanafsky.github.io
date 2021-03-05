@def title="Awesome な前処理"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

# Awesome な前処理 3

前処理大全のjulia版その3です。
まずは、ホテルの予約データを読み込みます。

```julia:ex1-preprocess3
using DataFrames,CSV
path = joinpath("tips","data","reserve.csv")
reserve_df = CSV.read(path,DataFrame)
#first(reserve_df) |> println
```

\prettyshow{ex1-preprocess3}


## 4 結合

\prevnext{/tips/preprocess2}{Awesome な前処理2}{/tips/preprocess1}{Awesome な前処理1}

\backtotop