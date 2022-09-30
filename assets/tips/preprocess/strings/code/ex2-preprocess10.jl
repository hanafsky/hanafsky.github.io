# This file was generated, do not modify it. # hide
using Awabi
tokenizer = Sys.iswindows() ? Tokenizer(Dict("dicdir" => "C:\\Program Files (x86)\\MeCab\\dic\\ipadic")) : Tokenizer()

tokenize(tokenizer, "すもももももももものうち") |> println