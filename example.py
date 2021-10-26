from BMI500HW7.main import aki_model

aki = aki_model()
aki.load_data()
aki.get_umap()
aki.cluster()
aki.visualization(colorby="cluster", save = "../figs/fig_cluster_umap.png")
aki.visualization("tsne", colorby="cluster", save = "../figs/fig_cluster_tsne.png")

vars = ['GENDER', "AKI_STAGE", 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']
for i in vars:
    aki.visualization(colorby=i, save = "../figs/fig_{}.png".format(i))

aki.train_on_data()
aki.predict([["F",24.000000000000007,107.49999999999994,18.5,27.850000000000012,55.499999999999993,1.621664706,1.9795,1.2941,1.497776471,1.6923,1.3012,1.441717647,1.5242,1.2687,0.099999999999999978,0.45,0.4]])

vals = ['GENDER', 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']

# y_pred = aki.predict(aki.data[vals])
# from sklearn.metrics import accuracy_score
# accuracy_score(aki.data["AKI_STAGE"], y_pred)
# # 0.7322385413052697