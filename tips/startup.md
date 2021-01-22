@def title="julia起動時の初期設定 - startup.jl"
@def hascode=true
@def tags=["julia","設定"]
# julia起動時の初期設定 - startup.jl
startup.jlは、juliaのREPL起動時に自動的に実行されるプログラムです。
よく使うパッケージの読み込みや環境変数の設定などに利用できます。
私は会社ではプロキシ環境下でjuliaを利用するので、重宝しています。
\note{
    環境変数は直接設定をいじっても問題ありませんが、他のソフトウェアに影響を及ぼしたり、
    再起動しないと変更が反映されないこともあるので、julia関係の環境変数はstartup.jlを
    使って設定した方が良いと思っています。
}

\mytoc
---

## startup.jlの場所
- Windowsの場合: `%USERPROFILE%\.julia\config\startup.jl`
- Linuxの場合: `.julia/config/startup.jl`
\warning{configフォルダとファイルは自分で作る必要があります。}

## 内容
参考までに私のstartup.jlをさらしてみます。

なお、proxyのアドレスやポートを直接知らなくても、自動構成スクリプト(`***.pac`)を
使っている場合、テキストエディタで開けば調べられる可能性があります。

```julia
"""
Proxy 設定関連
"""
import  Pkg
Pkg.setprotocol!(protocol="https") # gitではなくhttps経由でダウンロード

# 認証付きプロキシの場合
username = "xxxxxxxx"
pw= "xxxxxxxx"
proxy = "123.123.123.123" 
port = "8000"
ENV["BINARYPROVIDER_DOWNLOAD_ENGINE"] = "curl"
ENV["HTTP_PROXY"] = "http://$(username):$(pw)@$(proxy):$(port)"
ENV["HTTPS_PROXY"] = ENV["HTTP_PROXY"]

# 認証無しなら
# ENV["HTTP_PROXY"] = "http://$(proxy):$(port)"

# PythonとJupyterをインストール済みの場合の環境変数設定
ENV["PYTHON"] = Sys.which("python")
ENV["PYTHON3"] = Sys.which("python")
ENV["JUPYTER"] = Sys.which("jupyter")

"""
よく使うパッケージ
"""

using OhMyREPL # REPLで分かりやすく色付けをしてくれる。
using Revise # パッケージ開発時に利用する。

using TabularDisplay # arrayをテーブル形式で表示してくれる。
#手抜きのためのマクロと関数
macro dt(expr)
    quote
        displaytable($(expr);padding=5, index=true, indexsep=" -> ") 
    end
end

function dt(a)
    displaytable(a;padding=5, index=true, indexsep=" -> ")
end

```

## 注意事項
\danger{
    Windows環境下ではjuliaの新しいバージョンをインストールしてjuliaを実行すると、エラーが発生して、**そもそもREPLが立ち上がらない**問題が発生します。
    }

これはjuliaが参照するProject.tomlファイルが変更されたときに起こります。
(つまり、v1.4 -> v1.5のようなversion変更を行ったとき。 v1.5.2 -> v1.5.3のような
マイナーチェンジの時は起こりません。)

新バージョンのjuliaをインストールしたときは、startup.jlのusing文を一旦コメントアウトしておきましょう。

\right{めでたしめでたし}
\backtotop