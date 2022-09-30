# This file was generated, do not modify it. # hide
using Awabi
dic = Sys.iswindows() ? Dict("dicdir" => "C:\\Program Files (x86)\\MeCab\\dic\\ipadic") : nothing

tokenize(Tokenizer(dic), "すもももももももものうち")
