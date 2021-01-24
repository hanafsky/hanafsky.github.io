@def title="Pluto.jlでレポートを作る。"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true
# Pluto.jlとは
## Installation
```julia
julia>]
(pkg)>add Pluto
```
## pros and cons

## Presentation mode
ブラウザのjavascriptコンソールでpresent()とタイプすると、
プレゼンテーションモードになる。
また、以下のコードを書いたセルを実行すると、ボタンでプレゼンテーションモードと通常モードを切り替えられる。
```julia
html"<button onclick=present()>Present</button>"
```
プレゼンテーションモードでpdfに変換すると、スライド毎にページが変わる！
