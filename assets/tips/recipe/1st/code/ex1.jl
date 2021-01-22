# This file was generated, do not modify it. # hide
#数値リテラル
@show typeof(1)
@show typeof(1.0)
@show typeof(1.0f0)
@show typeof(1+1im)
#文字リテラル
@show typeof("abc\n")
@show typeof('a')
@show typeof(r"abc")
@show typeof(raw"abc")
#配列リテラル
@show typeof([1,2,3])
@show typeof((1,2,3))
@show typeof((a=1,b=3));
@show typeof(Dict("a"=>1,"b"=>2))