function calc_neighs(DIMS)
    """ calculate neighbors efficiently. """
    NEIGHS = Dict()
    for i in 1:DIMS
        for j in 1:DIMS
            NEIGHS[string(i)*"-"*string(j)] = neighbors([i,j], DIMS, D)
        end
        if i%30 == 0
            println("row ", i, " done")
        end
    end
    return NEIGHS
end


function calc_weights(NEIGHS, DIMS, test_imgs)
    """Calculate weights efficiently. """
    WEIGHTS = Dict()
    for i in 1:DIMS
        for j in 1:DIMS
            vecino = NEIGHS[string(i)*"-"*string(j)]
            for v in vecino 
                w = weights(test_imgs, [i,j], v)
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
    return WEIGHTS
end


function parallel_magic(image, D, H, DIMS, SLICE, times, NEIGHS)
    println("Starting Slice ", SLICE)
    test_imgs = image[:, :, SLICE, 1:times]
    test_imgs = permutedims(test_imgs, [3,2,1])
    # Calculate weights
    WEIGHTS = calc_weights(NEIGHS, DIMS,  test_imgs)
    println("\nWEIGHTS DONE")
    # Process chunk.
    processed = run(test_imgs, DIMS, H, NEIGHS, WEIGHTS; verbose=1)
    println("CHUNK PROCESSING DONE")
    # Save slice
    save("program_files/slice_$SLICE.jld", "processed", processed)
    println("SLICE $SLICE DONE")
end
