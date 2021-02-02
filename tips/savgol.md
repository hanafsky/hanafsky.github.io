
@def title="ノイズを含むデータの微分"
@def rss=""
@def tags=["recipe"]
@def hascode=true
@def isjulia =true 

# ノイズを含むデータの微分 - Savitzky-Golay filter
実験データを解析するときに、傾きや変曲点を求めたくなる時があります。
典型的なのが、時系列データの解析をしているときに、データが急激に変化し
始めるポイントを特定したいときです。
学生の頃は、scipyで実装されたsavitzky-golayフィルターをよく使っていたのですが、
juliaでは公式パッケージで使えるものはなさそうです。[^1]

scipyからimportしても良いのですが、
Vincent-Picaudさんがblogで公開している説明がとても分かりやすいので、
それに準拠して日本語で原理をまとめたり、juliaでの実装をまとめたいと思います。

[^1]:VincentさんのDirectConvolution.jlで実行可能のはずなのですが、3年ほどメンテされていなくて、現在は使用不可となっています。

## SavitzkyとGolayの心
