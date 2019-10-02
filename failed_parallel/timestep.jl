# Process each timestep

using NIfTI
using Plots
using LinearAlgebra
using Statistics
using JLD

# include useful functions
include("utils.jl")

# retrieve ARGS passed
img_route     = string(ARGS[1])
DIMS          = string(ARGS[2])
H             = string(ARGS[3])
neighs_route  = string(ARGS[4])
weights_route = string(ARGS[5])
slice         = string(ARGS[6])
t0           = string(ARGS[7])
t1           = string(ARGS[8])


#= Load image, neighs and weights. =#
Rest      = niread(img_route)
test_imgs = Rest[:, :, slice, t0:t1]
test_imgs = permutedims(test_imgs, [3,2,1])

NEIGHS  = load(neighs_route, "neighs")
WEIGHTS = load(weights_route, "weights")


#= Process step. =#
processed = run(test_imgs, DIMS, H, NEIGHS, WEIGHTS; verbose=1)
println("CHUNK PROCESSING DONE")

save("porgram_files/steps_$t0"*"_$t1.jld", "processed", processed)