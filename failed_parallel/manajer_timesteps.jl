# This is gonna be the manager file for the TNLm Application

using NIfTI
using Plots
using LinearAlgebra
using Statistics
using JLD

# include useful functions
include("utils.jl")

# routes to store the weights
route         = "program_files/storage"
neighs_route  = route*"_neighs.jld"
weights_route = route*"_weights.jld"

# image to process 
img_route = string(ARGS[1])
Rest      = niread(img_route)


#= Define params to run the algorithm. =#
D = 7
H = 0.7
DIMS = 128
SLICE = 5 # Slice we're working on
times = 120   # number of timesteps to load

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
println("\nWEIGHTS DONE")


#= Save the weights to retrieve them in parallel computations. =#
save(neighs_route, "neighs", NEIGHS)
save(weights_route, "route", WEIGHTS)
println("DATA IS SAVED. GOING PARALLEL")


#= Run the processing in parallel. =#
calls = []
chunks = [i for i in 1:8:times]
push!(chunks, times)

for i in 1:length(chunks)-1
	t0  = string(chunks[i])
	t1 = string(chunks[i+1])
	push!(calls, "julia timestep.jl $img_route $DIMS $H $neighs_route $weights_route $SLICE $t0 $t1")
end
joint_call = join(calls, " & ")
run(`$joint_call`)
println("IMAGE PROCESSING DONE")


#= Retrieve data and merge. =#
image = []
for i in 1:length(chunks)-1
	t0  = string(chunks[i])
	t1 = string(chunks[i+1])
	t_step = load("program_files/step_$t0"*"_$t1.jld", "processed")
	for chunk in 1:size(t_step)[1]
		push!(image, t_step[chunk])
	end
end
image    = permutedims(image, [3,2,1])


#= Save final image. =#
out_name = split(split(image, "/")[-1], ".")[-2] * ".nii"
niwrite(out_name, image)
println("SUCCESS. IMAGE PROCESSED.")