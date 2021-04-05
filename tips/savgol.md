
@def title="ノイズを含むデータの微分 - Savitzky-Golay filter"
@def rss_pupdate=Date(2021,4,5)
@def published="4 April 2021"


="Kei Hanafusa"
@def tags=["recipe"]
@def hascode=true
@def hasmath=true
@def hasmermaid=true
@def isjulia =true 

# ノイズを含むデータの微分 - Savitzky-Golay filter

\titleimage{/assets/tips/smooth-3221868_640.jpg}
\share{tips/savgol/}{ノイズを含むデータの微分 - Savitzky-Golay filter}

実験データを解析していると、傾きや変曲点を求めたくなる時があります。
典型的なのが、時系列データの解析で急激に変化し始めるポイントを特定したいときです。
実際のデータの微分を求めようとすると、ノイズが入っているので難儀します。
学生の頃は、scipyで実装されたsavitzky-golayフィルターをよく使っていたのですが、
juliaでは公式パッケージで使えるものはなさそうです。[^1]

scipyをimportしても良いのですが、[Vincent Picaudさんがblogで公開している説明](https://pixorblog.wordpress.com/2016/07/13/savitzky-golay-filters-julia/)がとても分かりやすいので、
それに参考にして日本語で原理をまとめたり、juliaでのテスト結果をまとめたいと思います。

[^1]: VincentさんのDirectConvolution.jlで実行可能のはずなのですが、メンテされていなくて、現在は使用不可となっています。幸いにもProject.tomlを付け加えて、ソースファイル名を修正するだけで無事に動くようになりました。


\toc

## Savitzky-Golayフィルターの心
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
$\rm{VD^{-1}P}^{\delta} =\rm{V}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y}$の両辺に左から$V^\mathsf{T}$をかけて整理していけば、
$$\rm{P}^{\delta} = \rm{D}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}\bm{y}$$
となって、微分係数を求めることができます。

\note{
VincentさんはVをQR分解して、式(5)をさらに整理しています。
ちなみにjuliaでは連立一次方程式の解法はQR分解を利用しています。
REPLで``?\　``とたたけば分かります。なので、自分でQR分解しても意味がないこともあります。


}

## 相互相関関数
$\rm{D}(\rm{V}^\mathsf{T}\rm{V})^{-1}\rm{V}^\mathsf{T}$は$(1+d) \times (2n+1)$行列です。$j$行$(n+i+1)$列目の成分を$f_{j}[n+i+1](i\in \{-n,-n+1,\dots,n\})$と書くことにすれば、
$x=x_k$における$j$階微分は
$$ P^{(j)}(x_k) = \sum_{i\in\{-n,-n+1, \dots , n-1, n\}} f_{j}[n+i+1]y_{k+i}$$
として求められることが分かります。

$$
\sum_{m} F(m)G(n+m)
$$

は自己相関関数と呼ばれるもので、$G$のかわりにそれを逆順に並べたものを利用すれば、畳込みになります。

$$
\sum_{-m} F(m)G(n-m)
$$

データ点が等間隔であるならば、どの$x_k$についても、同じ$f$を適用できます。
また、フーリエ変換での畳み込み積分は、DSP.jlの中に実装済みで簡単に利用できます。

ここまでくれば、あとはコードを実装するだけです。
## 実装してみる。

Vincentさんのブログのコードは、そのままは古くて動かなかったので、[野良パッケージSavGol.jl](https://github.com/hanafsky/SavGol.jl.git)を作成しました。40行程度の簡単なコードです。
インストール方法はjuliaのREPLを立ち上げて、以下のようにタイプするだけです。
```julia
julia>] # ]キーでパッケージモードに移動
(pkg)>add https://github.com/hanafsky/SavGol.jl.git # バックスペースでjuliaモードに戻る
julia>using SavGol
```

コードの流れをざっくり確認してみます。

\begin{mermaid}
~~~
graph TD
    id1[多項式の次数を決める]
    id2[窓関数のデータ点数を決める]
    id3[求めたい微分階数の窓関数を作る]
    id4[元のデータの端点のデータを水増し]
    id5[窓関数を元のデータに畳込む]
    id6[水増しした端点データを除去する]
    id1-->id2
    id2-->id3
    id3-->id4
    id4-->id5
    id5-->id6
~~~
\end{mermaid}

```julia:pre
# hideall
using Plots,Plots.PlotMeasures
Plots.reset_defaults()
default(
    left_margin = 30px,
    bottom_margin = 30px
)
```

\output{pre}

2回微分まで求めるとして、長さが10の場合の窓関数をプロットしてみます。
SG関数は、窓関数の長さの半分と微分階数を引数にしていて、窓関数を行列で返してくれます。
(1列目はスムージング用、2列目は1階微分用、3列目は2階微分用）
```julia:savgol
using SavGol
sg1 = SavGol.SG(5,3)
p0=scatter(sg1[:,1],label="window for smoothing")
scatter!(sg1[:,2], label="window for 1st order derivative")
scatter!(sg1[:,3], label="window for 2nd order derivative")
savefig(p0,joinpath(@OUTPUT,"savgol.svg")) # hide
```
\fig{savgol}

なお、Vincentさん曰く、畳み込む列が小さい時は、直接畳込みを実行した方が速いそうです。
VincentさんのDirectConvolution.jlをforkして使えるように修正したので、
最後に実行時間の比較をしてみたいと思います。

## 実際に微分してみる。

シグモイド関数の変曲点を求めてみたいと思います。

$$ f(x) = \dfrac{1}{1+\exp(-x+1)}$$

一階微分は次のように書けます。
$$ \dfrac{\rm{d}f(x)}{dx} = \dfrac{\exp(-x+1)}{(1+\exp(-x+1))^2}$$

この例では、$x＝1$で傾きが最大になります。ノイズを加えたデータを生成してプロットしてみます。

```julia:savgol1
using Plots, Random
Random.seed!(123)
sigmoid(x) = 1/(1+exp(-x+1))
sigmoid_d(x) = exp(-x+1)/(1+exp(-x+1))^2
p_1=plot(sigmoid,xlabel="x",ylabel="y",label="sigmoid curve",legend=:topleft)
x = -4:0.1:4
y = sigmoid.(x) + 0.01randn(length(x))
scatter!(p_1,x,y,label="observed") 
savefig(p_1,joinpath(@OUTPUT,"savgol1.svg")) # hide
```
\fig{savgol1}

### FFTを使ったフィルタリング

では、フィルターをかけて微分を求めてみます。
実際の微分値に合わせるため、返り値をデータの刻み幅（0.1）で割っていることに注意してください。

```julia:savgol2
deriv1_1 = apply_filter(sg1[:,2],y)/0.1
println(deriv1_1)
p_2 = plot(sigmoid_d,label="theoretical 1st order derivative",legend=:topleft)
scatter!(p_2,x,deriv1_1,label="smoothed 1st order derivative")
savefig(p_2,joinpath(@OUTPUT,"savgol2.svg")) # hide
```
\fig{savgol2}

荒っぽいですが、真の微分係数に近い値が得られています。
### 直接畳み込みの場合

同じことをDirectConvolution.jlで実行してみます。
DirectConvolution.jlではその名の通り、FFTを使わずに直接畳み込みを実行します。
私のGitHubレポジトリにあるDirectConvolution.jlをREPLのpkgモードでaddしてインストールします。
```julia
julia>]
(pkg)>add https://github.com/hanafsky/DirectConvolution.jl.git
julia>using DirectConvolution
```
今度は、窓関数の長さを倍にしてもう少し滑らかなデータになるか検討してみます。

```julia:savgol3
using DirectConvolution
sg2 = SG_Filter(Float64,halfWidth=10,degree=2)
deriv1_2 = apply_SG_filter(y,sg2,derivativeOrder=1)/0.1
p_3 = plot(sigmoid_d,label="theoretical 1st order derivative",legend=:topleft)
scatter!(p_3,x,deriv1_2,label="smoothed 1st order derivative") 
savefig(p_3,joinpath(@OUTPUT,"savgol3.svg")) # hide
```

\fig{savgol3}

ピーク値がやや下がりましたが、より滑らかなデータを得ることができました。
### ベンチマーク
最後に直接畳み込みとFFT畳み込みで速度の比較をしてみたいと思います。
公平のために窓関数の大きさを同じにしておきます。
```julia:bench1
using BenchmarkTools
sg3 = SG_Filter(Float64,halfWidth=5,degree=2)
@btime apply_SG_filter(y,sg3,derivativeOrder=0) # 直接畳み込み
@btime apply_filter(sg1[:,2],y) # FFT畳み込み
```
\prettyshow{bench1}
結果は直接畳み込みの圧勝で、Vincentさんのブログに書いてあるとおりでした。
DirectConvolution.jlにはこのほかにも2次元のSavitzky-Golayフィルターなど実装されているので、
いろいろ遊んでみたいと思います。

\right{めでたしめでたし}
\share{tips/savgol/}{ノイズを含むデータの微分 - Savitzky-Golay filter}
\prev{tips/pluto}{リアクティブなノートブック Pluto.jl}
\backtotop

