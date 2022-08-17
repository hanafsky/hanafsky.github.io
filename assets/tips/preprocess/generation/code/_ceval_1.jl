# This file was generated, do not modify it. # hide
using PyCall
imblearn = pyimport("imblearn.over_sampling")
sm = imblearn.SMOTE(sampling_strategy="auto", k_neighbors=5, random_state=71)
imb_data = production_df[!,[:length,:thickness]] |> Matrix
imb_target = production_df.fault_flg
balance_data,balance_target = sm.fit_resample(imb_data, imb_target)
new_df= DataFrame(hcat(balance_data,balance_target),["length","thickness","fault_flg"]);
