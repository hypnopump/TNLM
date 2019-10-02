# This is gonna be the manager file for the TNLm Application

using NIfTI
using Plots
using LinearAlgebra
using Statistics
using JLD
import Base.run

# include useful functions
include("utils.jl")
include("slicer_utils.jl")

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
DIMS = size(Rest)[1]
slices = size(Rest)[3]
times = size(Rest)[4]

# calculate neighbors
NEIGHS = calc_neighs(DIMS)
println("\nNEIGHBORS DONE")


#= Run the processing in PARALLEL across available Threads. =#
Threads.@threads for j in 1:slices
	parallel_magic(copy(Rest), D, H, DIMS, j, times, copy(NEIGHS))
end
println("IMAGE PROCESSING DONE")


#= Retrieve data and merge. =#
image = []
for i in 1:slices
	slice =  load("program_files/slice_$i.jld", "processed")
	slice = permutedims(slice, [3,2,1])
	slice = reshape(slice, (1, size(slice)[1], size(slice)[2], size(slice)[3]))
	push!(image, slice)
end
image = reduce(vcat, image)
image = permutedims(image, [2,3,1,4])
println("IMAGE RETRIEVED. SAVING")


#= Save final image. =#
# splitting the string
bars   = split(img_route, "/")
points = split(bars[length(bars)], ".")
out_name = points[length(points)-1] * ".jld"

save(out_name, "processed", image)
println("SUCCESS. IMAGE PROCESSED.")