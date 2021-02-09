
@def title="ノイズを含むデータの微分"
@def rss=""
@def tags=["recipe"]
@def hascode=true
@def hasmath=true
@def isjulia =true 

# ノイズを含むデータの微分 - Savitzky-Golay filter
実験データを解析するときに、傾きや変曲点を求めたくなる時があります。
典型的なのが、時系列データの解析をしているときに、データが急激に変化し
始めるポイントを特定したいときです。
学生の頃は、scipyで実装されたsavitzky-golayフィルターをよく使っていたのですが、
juliaでは公式パッケージで使えるものはなさそうです。[^1]

scipyをimportしても良いのですが、
[Vincent-Picaudさんがblogで公開している説明](https://pixorblog.wordpress.com/2016/07/13/savitzky-golay-filters-julia/)がとても分かりやすいので、
それに参考にして日本語で原理をまとめたり、juliaでの実装をまとめたいと思います。

[^1]:VincentさんのDirectConvolution.jlで実行可能のはずなのですが、3年ほどメンテされていなくて、現在は使用不可となっています。

## SavitzkyとGolayの心
一言で結論をまとめると「ある点におけるn階微分係数をテーラー展開と多項式近似から推定する」ということになります。

$(\bm{x},\bm{y}) = [(x_1,y_1), \dots, (x_N,y_N)] (x,y\in\R, N\in \N)$のデータセットがあった時のことを考えます。

多項式$P(x)$の$x = x_k(k\in{1,\dots N})$におけるd階微分係数を$p^{(d)}(x_k)$と書くことにすると、$x=x_k$周りのd次のテーラー展開は次のように書けます。

$$P(x) = \sum_{j=0}^{d}\dfrac{(x-x_k)^j}{j!}P^{j}(x_k)$$

$x=x_k$の近くの$2n+1$個の点、$\bm{x}=\{x_{k+i}|i=0, \pm1,\pm2,\dots,\pm n \}$について、$P(\bm{x})$を行列で書くと
$$\begin{aligned} 
P(\bm{x}) &= \begin{bmatrix}
              \vdots & \vdots & \vdots \\
              1      & \dfrac{(x_i-x_k)^j}{j!} & \dfrac{(x_i-x_k)^d}{d!} \\
              \vdots & \vdots & \vdots 
              \end{bmatrix}\cdot
              \begin{bmatrix} 
              P^{(0)}(x_k) \\ 
              \vdots \\ 
              P^{(j)}(x_k) \\ 
              \vdots \\ 
              P^{(d)}(x_k) \\ 
               \end{bmatrix}\\
         &= \begin{bmatrix}
              \vdots & \vdots & \vdots \\
              1      & (x_i-x_k)^j & (x_i-x_k)^d \\
              \vdots & \vdots & \vdots 
              \end{bmatrix}\cdot

              \begin{bmatrix}
              1 & & & & 0 \\
                & \ddots & & & \\
                &    & \dfrac{1}{j!} & & \\
                & & & \ddots  & \\
              0 & & & &\dfrac{1}{d!} 
              \end{bmatrix}\cdot
              \begin{bmatrix} 
              P^{(0)}(x_k) \\ 
              \vdots \\ 
              P^{(j)}(x_k) \\ 
              \vdots \\ 
              P^{(d)}(x_k) \\ 
               \end{bmatrix}\\
         &= \rm{VD^{-1}P}^{\delta}
\end{aligned}
$$

$\rm{V}$はVendermonde行列で、$\rm{D}$は $j! (j=0,1,\dots,d)$ を対角成分にもった対角行列です。
また、$\rm{P}^{\delta}$は微分係数の列ベクトルです。

一方で、$\bm{y} = \{y_{k-n}, \dots, y_{k+n} \}$を$(x-x_k)$のd次多項式の最小二乗法で回帰分析すると

回帰係数の推定値を$\hat{\beta}$として
$$
\hat{\beta} = (\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y}   
$$
と書けますから、
$$
\begin{aligned}
P(\bm{x}) &= \rm{V}\bm{\hat{\beta}} \\
          &= \rm{V}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y} \\
          &= \rm{VD^{-1}P}^{\delta}
\end{aligned}
$$
となります。
$\rm{VD^{-1}P}^{\delta} =\rm{V}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y}$の両辺に$V^\mathsf{T}$をかけて整理していけば、
$$\rm{P}^{\delta} = \rm{D}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y}$$
となって、微分係数を求めることができます。

VincentさんはVをQR分解してさらに整理しています。
\note{
実はjuliaでは連立一次方程式の解法はQR分解を利用しています。
REPLで``?\　``とたたけば分かります。
}
## 相互相関関数
$\rm{D}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}$は$(1+d) \times (2n+1)$行列です。$j$行$(n+i+1)$列目の成分を$f_{j}[n+i+1](i\in \{-n,-n+1,\dots,n\})$と書くことにすれば、
$x=x_k$における$j$階微分は
$$ P^{(j)}(x_k) = \sum_{i\in(-n,n)} f_{j}[n+i+1]y_{k+i}$$
として求められることが分かります。

$$
\sum_{m} F(m)G(n+m)
$$

は自己相関関数と呼ばれるもので、$G$のかわりにそれを逆順に並べたものを利用すれば、畳込みになります。

$$
\sum_{-m} F(m)G(n-m)
$$

データ点が等間隔であるならば、どの$x_k$についても、同じ$f$を適用できるので、
高速フーリエ変換を利用した畳み込み積分を利用できます。

畳み込む列が小さい時は、直接畳込みを実行した方が速い

