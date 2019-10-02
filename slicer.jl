# This is gonna be the manager file for the TNLm Application

using NIfTI
using Plots
using LinearAlgebra
using Statistics
using JLD

# include useful functions
include("utils.jl")

# image to process 
img_route = string(ARGS[1])
Rest      = niread(img_route)


#= Define params to run the algorithm. =#
D = parse(Int, ARGS[2])
H = parse(Float32, ARGS[3])
DIMS = size(Rest)[1]
SLICE = parse(Int, ARGS[4])
times = size(Rest)[4]

test_imgs = Rest[:, :, SLICE, 1:times]
test_imgs = permutedims(test_imgs, [3,2,1])
println("Dimensions Changed")


#= calculate neighbors efficiently. =#
NEIGHS = Dict()
for i in 1:DIMS
    for j in 1:DIMS
        NEIGHS[string(i)*"-"*string(j)] = neighbors([i,j], DIMS, D)
    end
    if i%30 == 0
        println("row ", i, " done")
    end
end
println("\nNEIGHBORS DONE")


#= Calculate weights efficiently. =#
WEIGHTS = Dict()
for i in 1:DIMS
    for j in 1:DIMS
        vecino = NEIGHS[string(i)*"-"*string(j)]
        for v in vecino 
            w = weights(test_imgs, [i,j], v, h=H)
            if w == NaN
                WEIGHTS[string(i)*"-"*string(j)*"/"*string(v[1])*"-"*string(v[2])] = 0
            else
               WEIGHTS[string(i)*"-"*string(j)*"/"*string(v[1])*"-"*string(v[2])] = w
            end
        end
    end
    if i%16 == 0
        println("row ", i, " done")
    end
end
println("\nWEIGHTS DONE")


#= Process chunk. =#
processed = run(test_imgs, DIMS, NEIGHS, WEIGHTS; verbose=1)
println("CHUNK PROCESSING DONE")


#= Save slice. =#
save("program_files/slice_$SLICE.jld", "processed", processed)
println("SLICE $SLICE DONE")