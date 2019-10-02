# This is gonna be the merger file for the TNLm Application

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
slices    = size(Rest[3]) 


#= Retrieve data and merge. =#
image = []
for i in 1:slices
	slice = load("program_files/slice_$i.jld", "processed")
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