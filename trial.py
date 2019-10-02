import os
import sys
import numpy as np
import nibabel as nib
import multiprocessing as mp
from joblib import Parallel,delayed

# include useful functions
from utils import *


def execute(dims, neighs, test_imgs, t):
    test_imgs = np.moveaxis(test_imgs, -1, 0)

    #= Calculate weights efficiently. =#
    WEIGHTS = {}
    for i in range(dims):
        for j in range(dims):
            vecino = neighs[str(i)+"-"+str(j)]
            for v in vecino:
                WEIGHTS[str(i)+"-"+str(j)+"/"+str(v[0])+"-"+str(v[1])] = weights(test_imgs, [i,j], v, h=H)

        if i%16 == 0:
            print("row", i, "done")

    for w in WEIGHTS:
        if np.isnan(WEIGHTS[w]):
            WEIGHTS[w] = 0

    processed = run(test_imgs, dims, neighs, WEIGHTS, verbose=1)
    np.save("program_files/slice_{0}.npy".format(t), processed)
    return True

# routes to store the weights
route         = "program_files/storage"

# image to process 
img_route = str(sys.argv[1])
Rest      = nib.load(img_route).get_data()


#= Define params to run the algorithm. =#
D = 7
H = 0.7
DIMS = Rest.shape[0]
slices = Rest.shape[-2]


#= calculate neighbors efficiently. =#
NEIGHS = {}
for i in range(DIMS):
    for j in range(DIMS):
        NEIGHS[str(i)+"-"+str(j)] = neighbors([i,j], DIMS, D)

    if i%30 == 0:
        print("row", i, "done")
    
print("\nNEIGHBORS DONE")


# PROCESS THINGS
process = Parallel(n_jobs=8)(delayed(execute)(DIMS, NEIGHS, Rest[:, :, i, :], i) for i in range(slices))


# Merge all slices
image = []
for i in range(slices):
	slice_chunk = np.load("program_files/slice_{0}.npy".format(i))
	slice_chunk = np.rollaxis(slice_chunk, 0, 2)
	image.append(slice_chunk)

image = np.array(image)
image = image.moveaxis(image, 0, 2)
print("IMAGE RETRIEVED. SAVING")


# Save final image
out_name = img_route.split("/")[-1].split(".")[0] + ".nii"
img = nib.Nifti1Image(image, np.eye(4))
nib.save(img, "output/"+outname)

print("SUCCESS. IMAGE PROCESSED.")