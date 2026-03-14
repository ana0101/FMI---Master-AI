import numpy as np
import pymc as pm
from matplotlib import pyplot as plt

#       G, G, L, E, L, L, L, E, G, L
data = [2, 2, 0, 1, 0, 0, 0, 1, 2, 0] 


with pm.Model() as model:

    DT = pm.Categorical("DT", p = [1.0 / 6.0, 1.0 / 6.0, 1.0 / 6.0, 1.0 / 6.0, 1.0 / 6.0, 1.0 / 6.0], initval = 3)
    obs = pm.Categorical("obs", p = [DT / 6.0, 1.0 / 6.0, (6.0 - DT - 1.0) / 6.0], observed=data)
    
with model:
    step = pm.CategoricalGibbsMetropolis(vars=[DT])
    trace = pm.sample(400000, step=step, tune=100000, return_inferencedata=False, chains=1)

DT_samples = trace["DT"]

DT_samples = np.bincount(DT_samples, minlength = 6)
DT_samples = DT_samples / 400000

print(DT_samples)

plt.bar(np.arange(6), DT_samples)
plt.show()

