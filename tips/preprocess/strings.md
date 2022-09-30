@def title="juliaで前処理大全10"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2022,10,29)
@def published=" October 29 2022"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# juliaで前処理大全 11.文字型

juliaで前処理大全その10です。今回は文字型を取り扱います。

\toc

## 形態素解析による分解
### Q 名詞、動詞の抽出
走れメロスのテキストデータをまず読み込んでみます。
```julia:ex1-preprocess10
using  Chain, Downloads
meros_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/txt/meros.txt"

meros = @chain meros_url begin
                Downloads.download
                read
                String
            end
first(meros, 10) |> println
```
\prettyshow{ex1-preprocess10}

```!
using Awabi
dic = Sys.iswindows() ? Dict("dicdir" => "C:\\Program Files (x86)\\MeCab\\dic\\ipadic") : nothing

tokenize(Tokenizer(dic), "すもももももももものうち")
```

## 単語の集合データに変換
### bag of wordsの作成

## TF-IDFによる単語の重要度調整
### TF-IDFを利用したbag of wordsの作成


\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prev{/tips/preprocess/category}{juliaで前処理大全 カテゴリー型}

\backtotop


{{ addcomments }}