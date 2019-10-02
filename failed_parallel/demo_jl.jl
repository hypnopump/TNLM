
using NIfTI
using Plots
using Images
using LinearAlgebra
using Statistics
using JLD

# include useful functions
include("utils.jl")

# Check number of Threads
println("Number of Threads: ", Threads.nthreads())

Original = 	 "data/Original Rest/run-8.nii"
SmoothRest = "data/smoothed/saurun-8.nii"
Rest = 		 "data/Rest_Unsmoothed/aurun-8.nii"
Structural = "data/Structural/run-3.nii"
Surface_lh = "data/surface/surf/lh.inflated.surf"
Surface_rh = "data/surface/surf/rh.inflated.surf"

Original = niread(Original)
println("Original size: ", size(Original))

SmoothRest = niread(SmoothRest)
println("SmoothRest size: ", size(SmoothRest))

Rest = niread(Rest)
println("Rest size: ", size(Rest))

# """ Sample plot of non-smoothed image. """
# img = Image()
heatmap(Rest[:, :, 25, 1], c = :greys)
# heatmap(Rest[:, :, 25, 31], c = :greys)
# heatmap(Rest[:, :, 25, 61], c = :greys)

# Define params to run the algorithm.
D = 7
H = 0.7
DIMS = 128
SLICE = 5 # Slice we're working on
times = 120   # number of timesteps to load

test_imgs = Rest[:, :, SLICE, 1:times]
test_imgs = permutedims(test_imgs, [3,2,1])
println("Dimensions Changed")

NEIGHS = Dict()

# first of all, calculate neighbors efficiently
for i in 1:DIMS
    for j in 1:DIMS
        NEIGHS[string(i)*"-"*string(j)] = neighbors([i,j], DIMS, D)
    end
    if i%30 == 0
        println("row ", i, " done")
    end
end

println("\nNEIGHBORS DONE")

WEIGHTS = Dict()

# key = pointA-pointB :: == example: "12-34"
for i in 1:DIMS
    for j in 1:DIMS
        vecino = NEIGHS[string(i)*"-"*string(j)]
        for v in vecino 
            w = weights(test_imgs, [i,j], v)
            if w == NaN
                WEIGHTS[string(i)*string(j)*"-"*string(v[1])*string(v[2])] = 0
            else
               WEIGHTS[string(i)*string(j)*"-"*string(v[1])*string(v[2])] = w
            end
        end
    end
    if i%16 == 0
        println("row ", i, " done")
    end
end


processed = run(test_imgs, DIMS, H, NEIGHS, WEIGHTS; verbose=1)
println("IMMAGE PROCESSING DONE")


save("data.jld", "processed", processed)
# %matplotlib notebook
