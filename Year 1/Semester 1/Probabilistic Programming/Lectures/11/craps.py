import numpy as np
import pymc as pm

point = 6


with pm.Model() as model:
    
    d1 = pm.DiscreteUniform("d1", lower=1, upper=6)
    d2 = pm.DiscreteUniform("d2", lower=1, upper=6)
    rez = pm.math.switch(pm.math.eq(d1+d2, point), 1, pm.math.switch(pm.math.eq(d1+d2, 7), -1, 0))

data = pm.draw(rez, 100000)

npoint = (data == 1).sum()
n7 = (data == -1).sum()

print(npoint / (npoint + n7))
