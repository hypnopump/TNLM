import os
import sys
import numpy as np
import nibabel as nib

# routes to store the weights
route         = "program_files/storage"

# image to process 
img_route = str(sys.argv[1])
Rest      = nib.load(img_route).get_data()

#= Define params to run the algorithm. =#
D = 7
H = 0.7
slices = Rest.shape[-2]

#= Run the processing in PARALLEL. =#
p = 8
calls = []
chunks = [i for i in range(0, slices+1, 8)]
if slices not in chunks:
	chunks.append(slices)
print("CHUNKS:", chunks)

# PARALLEL MAGIC GOING ON
for i in range(0, len(chunks)-1):
	calls = []
	for j in range(chunks[i], chunks[i+1]):
		call = "python3 slicer.py {0} {1} {2} {3}".format(img_route, D, H, j)
		calls.append(call)
	# start all *parallel* processes in parallel
	joint_call = " & ".join(calls) 
	# print(joint_call)
	os.system(joint_call)

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