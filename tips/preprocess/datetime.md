@def title="juliaで前処理大全9"
@def hascode=true
@def tags=["thirdparty"]
@def isjulia =true

@def rss_description="![titleimage](/assets/tips/preprocess1.jpg) juliaで前処理大全をやっています。"
@def rss_pupdate=Date(2022,9,29)
@def published=" September 29 2022"
@def rss_category="julia"

@def hascode=true
@def tags=["recipe"]
@def isjulia =true 
@def hasmermaid=true

# juliaで前処理大全 10.日時型

juliaで前処理大全その9です。今回は日時型を取り扱います。

\toc

## 日時型、日付型への変換
### Q 日時型、日付型への変換

ホテルの予約レコードから、予約日時の列を日時型、日付型へ変換する問題です。
標準パッケージの``Dates.jl``を用いることで簡単に実装できます。
一度、文字列を``DateTime``型に変換し、その後、``Date``型・``Time``型に変換を行います。
文字列を``DateTime``型に変換する際に、\marker{``dateformat``を指定する}のがポイントでしょう。

```julia:ex1-preprocess9
using DataFrames, CSV, Chain, Downloads, Dates
reserve_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/reserve.csv"

reserve_df = @chain reserve_url begin
                Downloads.download
                CSV.File
                DataFrame
                transform(:reserve_datetime=>ByRow(d->DateTime(d, dateformat"yyyy-mm-dd H:M:S"))=>:reserve_datetime)
                transform(:reserve_datetime=>ByRow(Date)=>:reserve_date,
                          :reserve_datetime=>ByRow(Time)=>:reserve_time)
            end
first(reserve_df, 10) |> println
```
\prettyshow{ex1-preprocess9}
## 年/月/日/時刻/分/秒/曜日への変換
### 各日時要素の取り出し
``DateTime``型から各日時要素の取り出しも``Dates.jl``の関数で実装されています。
任意の文字列に変換するには``Dates.format``関数を利用する必要があります。(exportされていないので、パッケージの指定が必要です。)

dayname関数はlocaleを指定できるようになっていますが、英語にしか対応していないようです。
公式ドキュメントを見るとフランス語バージョンが書いてあってので、必要な場合は勝手に拡張しろということなのでしょう。

```julia:ex2-preprocess9
@chain reserve_df begin
    select(:reserve_datetime=>ByRow(year)=>:year,
           :reserve_datetime=>ByRow(month)=>:month,
           :reserve_datetime=>ByRow(day)=>:wday,
           :reserve_datetime=>ByRow(d->dayname(d,locale="english"))=>:weekday,
           :reserve_datetime=>ByRow(hour)=>:hour,
           :reserve_datetime=>ByRow(minute)=>:minute,
           :reserve_datetime=>ByRow(second)=>:second,
           :reserve_datetime=>ByRow(d->Dates.format(d, "yyyy-mm-ss H:M:S"))=>:format_str,
    )
    first(10)
    println
end
```
\prettyshow{ex2-preprocess9}
## 日時差への変換
### 日時差の計算
予約日時とチェックイン日時の差を求め、それを年単位、月単位、日単位から秒単位まで差を求めるお題です。
年や月単位であれば、先に``DateTime``型から年や月を取得して変換することになります。
``DateTime``型の差分は``Millisecond``型になるため、日、時間、分、秒単位にするには少し工夫が必要です。
```julia:ex3-preprocess9
t1 = DateTime(2022, 1, 12, 12, 23, 34) 
t2 = DateTime(2021, 12, 24, 23, 34, 45)
dt = t1 - t2
println(dt)
```
\prettyshow{ex3-preprocess9}

日単位であれば、``Dates.days``関数が単位変換に利用可能です。秒・分・時間に関しては自分で関数を作る必要があります。
``Dates.days``関数の実装を参考に秒・分・時間について変換する関数を作ってみました。
```julia:ex4-preprocess9
tosecond(dt::Millisecond) = div(Dates.value(dt), 1000)
tominute(dt::Millisecond) = div(Dates.value(dt), 60000)
tohour(dt::Millisecond) = div(Dates.value(dt), 3600000)
@show tohour(dt)
```
\prettyshow{ex4-preprocess9}
それではやってみます。
```julia:ex5-preprocess9
@chain reserve_df begin
    transform([:checkin_date, :checkin_time]=>ByRow(+)=>:checkin_datetime)
    select(
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->year(x)-year(y))=>:diff_year,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->12year(x)+month(x)-12year(y)-month(y))=>:diff_month,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->Dates.days(x-y))=>:diff_days,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tohour(x-y))=>:diff_hours,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tominute(x-y))=>:diff_minutes,
        [:checkin_datetime, :reserve_datetime]=>ByRow((x, y)->tosecond(x-y))=>:diff_seconds,
        )
    first(10)
    println
end
```
\prettyshow{ex5-preprocess9}
## 日時型の増減
### 日時の増減処理
日時のデータを1日、1時間、1分、1秒増やすという問題です。
``DateTime``型の列のそれぞれの行について、``Period``型のデータを足すと実現可能です。
可読性も高く、Awesomeでしょう。

```julia:ex6-preprocess9
@chain reserve_df begin
    select(
        :reserve_datetime => ByRow(d->d+Day(1)) => :reserve_datetime_1d,
        :reserve_date => ByRow(d->d+Day(1)) => :reserve_date_1d,
        :reserve_datetime => ByRow(d->d+Hour(1)) => :reserve_datetime_1h,
        :reserve_datetime => ByRow(d->d+Minute(1)) => :reserve_datetime_1m,
        :reserve_datetime => ByRow(d->d+Second(1)) => :reserve_datetime_1s
    )
    first(10)
    println
end
```
\prettyshow{ex6-preprocess9}
## 季節への変換
### 季節への変換
こちらはホテルの予約レコードから予約月を季節に変換する問題です。
数値から季節の文字コードに変換するのは、本と同じですが、合成関数を利用して、簡潔にかけたと思います。

```julia:ex7-preprocess9
using CategoricalArrays

function to_season(m)
    3≤m<6 ? "spring" : 
    6≤m<9 ? "summer" : 
    9≤m<12 ? "autumn" : "winter" 
end

@chain reserve_df begin
    select(:reserve_datetime => ByRow(to_season∘month) => :reserve_datetime_season)
    transform(:reserve_datetime_season => categorical => :reserve_datetime_season)
    first(10)
    println
end
```
\prettyshow{ex7-preprocess9}
## 時間帯への変換
時間帯への変換はコードが記載されていないので割愛します。
## 平日/休日への変換
### 休日フラグの付与
こちらは、ホテルの予約レコードと休日のマスターレコードを内部結合するだけです。
技術的に新しいものはありません。

```julia:ex8-preprocess9
holiday_url =  "https://raw.githubusercontent.com/hanafsky/awesomebook/master/data/holiday_mst.csv"

holiday_mst = @chain holiday_url begin
                Downloads.download
                CSV.File
                DataFrame
            end

@chain reserve_df begin
    innerjoin(holiday_mst, on=[:checkin_date => :target_day ])
    first(10)
    println
end
```
\prettyshow{ex8-preprocess9}



\right{つづく}
\share{tips/preprocess/}{juliaで前処理大全}
\prev{/tips/preprocess/category}{juliaで前処理大全 カテゴリー型}

\backtotop


{{ addcomments }}