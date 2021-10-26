from importlib import resources
from scipy.linalg.special_matrices import dft
import umap
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.manifold import TSNE
from sklearn.cluster import KMeans
from sklearn import svm

import pickle

class aki_model:
    def __init__(self):
        self.data = None
        self.sub_mean = None
        self.sub_std = None
        self.norm_data = None
        self.model = None
        self.umap = None
        pass

    def visualization(self,type="umap",colorby='AKI_STAGE',save=False):
        if type.lower() == "tsne":
            if "tsne_1" not in self.data.columns:
                self.get_tsne()
            data_x = self.data["tsne_1"]
            data_y = self.data["tsne_2"]
        else:
            if "umap_1" not in self.data.columns:
                self.get_umap()
            data_x = self.data["umap_1"]
            data_y = self.data["umap_2"]
        plt.scatter(data_x, data_y, c=self.data[colorby])
        plt.title("{} Color by {}".format(type,colorby))
        if save:
            plt.savefig(save)
        plt.show()

    
    def get_umap(self):
        if "umap_1" in self.data.columns and "umap_2" in self.data.columns:
            pass
        else:
            reducer = umap.UMAP()
            subdata = self.norm_data[['GENDER', 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']]
            if self.umap:
                embedding = reducer.transform(subdata)
            else:
                reducer = umap.UMAP()
                embedding = reducer.fit_transform(subdata)
                try:
                    with resources.path("BMI500HW7.files", "umap.pkl") as f_name:
                        pickle.dump(reducer ,open(f_name, 'wb'))
                except Exception as e:
                    pass
                self.umap=reducer
            self.data['umap_1'] = embedding[:,0]
            self.data['umap_2'] = embedding[:,1]
            return

    def get_tsne(self):
        if "tsne_1" in self.data.columns and "tsne_1" in self.data.columns:
            return 
        else:
            reducer = TSNE(n_components=2,init='pca')
            subdata = self.norm_data[['GENDER', 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']]
            embedding = reducer.fit_transform(subdata)
            self.data['tsne_1'] = embedding[:,0]
            self.data['tsne_2'] = embedding[:,1]
            return
        
    def cluster(self):
        self.get_umap()
        kmeans = KMeans(random_state=0).fit(self.data[['umap_1', 'umap_2']])
        self.clust_model = kmeans
        self.data["cluster"] = kmeans.labels_
        pass
    
    def train_on_data(self):
        clf = svm.SVC()
        clf.fit(self.norm_data[['GENDER', 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']], self.norm_data["AKI_STAGE"])
        self.model = clf
        with resources.path("BMI500HW7.files", "model.pkl") as f_name:
            pickle.dump(clf ,open(f_name, 'wb'))

    def predict(self,data):
        if not self.model:
            try:
                with resources.path("BMI500HW7.files", "model.pkl") as f_name:
                    self.model = pickle.load((open(f_name, 'rb')))
            except Exception as e:
                self.train_on_data()
           
        df = pd.DataFrame(data, columns=['GENDER', 'BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline'])
        if 1 not in set(df["GENDER"]):
            df["GENDER"] = (df["GENDER"].values == 'M').astype(int)
        df = df.fillna(self.sub_mean)
        df[self.val_cols] = (df[self.val_cols]-self.sub_mean)/self.sub_std
        return self.model.predict(df)

    
    def load_data(self):
        with resources.path("BMI500HW7.files", "patient_data.csv") as df:
            data = pd.read_csv(df)
        if 1 not in set(data["GENDER"]):
            data["GENDER"] = (data["GENDER"].values == 'M').astype(int)
        self.data = data.fillna(data.mean())

        self.val_cols = ['BICAR_AVG', 'CHLO_AVG', 'UN_AVG', 'HEM_AVG', 'PC_AVG', 'uo_rt_6hr_avg', 'uo_rt_6hr_max', 'uo_rt_6hr_min', 'uo_rt_12hr_avg', 'uo_rt_12hr_max', 'uo_rt_12hr_min', 'uo_rt_24hr_avg', 'uo_rt_24hr_max', 'uo_rt_24hr_min', 'creat_diff', 'creat_avg', 'creat_baseline']

        sub = self.data[self.val_cols]
        self.sub_mean = sub.mean()
        self.sub_std = sub.std()
        sub = (sub-self.sub_mean)/self.sub_std
        self.norm_data = self.data.copy(True)
        self.norm_data[self.val_cols] = sub