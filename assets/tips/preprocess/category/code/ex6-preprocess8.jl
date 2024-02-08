# This file was generated, do not modify it. # hide
using MLJ
KNNClassifier = @load KNNClassifier pkg=NearestNeighborModels verbosity=0

train = dropmissing(production_missc_df)
test = filter(:type=>ismissing, production_missc_df)
y, X = unpack(train, ==(:type))
test[!,:type] = @chain machine(KNNClassifier(K=3), X, y) begin 
                    fit!
                    predict_mode(test[!, Not(:type)])
                end
first(test,10) |> println