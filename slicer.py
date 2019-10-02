# This is gonna be the processor file for the TNLm Application

import sys
import numpy as np
import nibabel as nib

# include useful functions
from utils import *

# image to process 
img_route = str(sys.argv[1])
Rest      = nib.load(img_route).get_data()


#= Define params to run the algorithm. =#
D = int(sys.argv[2])
H = float(sys.argv[3])
DIMS = Rest.shape[0]
SLICE = int(sys.argv[4])
times = Rest.shape[-1]

test_imgs = Rest[:, :, SLICE, 0:times]
test_imgs = np.moveaxis(test_imgs, -1, 0)
print("Dimensions Changed - Slice:", SLICE)


#= calculate neighbors efficiently. =#
NEIGHS = {}
for i in range(DIMS):
    for j in range(DIMS):
        NEIGHS[str(i)+"-"+str(j)] = neighbors([i,j], DIMS, D)

    if i%30 == 0:
        print("row", i, "done")
    
print("\nNEIGHBORS DONE")


#= Calculate weights efficiently. =#
WEIGHTS = {}
for i in range(DIMS):
    for j in range(DIMS):
        vecino = NEIGHS[str(i)+"-"+str(j)]
        for v in vecino:
            WEIGHTS[str(i)+"-"+str(j)+"/"+str(v[0])+"-"+str(v[1])] = weights(test_imgs, [i,j], v, h=H)

    if i%16 == 0:
        print("row", i, "done")

for w in WEIGHTS:
    if np.isnan(WEIGHTS[w]):
        WEIGHTS[w] = 0

print("\nWEIGHTS DONE")


#= Process chunk. =#
processed = run(test_imgs, DIMS, NEIGHS, WEIGHTS, verbose=1)
print("CHUNK PROCESSING DONE")


#= Save slice. =#
np.save("program_files/slice_{0}.npy".format(SLICE), processed)
print("SLICE {0} DONE".format(SLICE))