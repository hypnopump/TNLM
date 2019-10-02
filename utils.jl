# Julia functions for Temporal Non-Local Means


""" Returns weight for s & r """
function weights(imgs, s, r, h=0.7)
	ws = imgs[:, s[1], s[2]]
	wr = imgs[:, r[1], r[2]]

	return exp(-(2 - 2*cor(ws, wr)) / (h^2))
end


""" Returns neighbors with distance<d for point S. """
function neighbors(s, dims, d)
	n = []
	for i in maximum([1, s[1]-d]):minimum([dims, s[1]+d])
		for j in maximum([1, s[2]-d]):minimum([dims, s[2]+d])
			if  norm(s - [i,j]) <= d
				push!(n, [i,j])
			end
		end
	end
	return n
end


""" Temporal Non-Local Means algo. """
function tnlm(imgs, s, t, NEIGHS, WEIGHTS)
	n = NEIGHS[s]
    w_sr = [WEIGHTS[s * "/" *string(r[1])*"-"*string(r[2])] for r in n]
    d_rt = [imgs[t, r[1], r[2]] for r in n]

    val = (1/sum(w_sr)) * sum([drt*wsr for (drt, wsr) in zip(d_rt, w_sr)])
	return val
end


""" Return data from p @time = t. """
function data(imgs, p, t=false)
	if t == false
		return imgs[:, p[1], p[2]]
	end

	return imgs[t, p[1], p[2]]
end


""" Return processed images. """
function run(imgs, dims, NEIGHS, WEIGHTS; verbose=false)
	results = zeros(Float64, size(imgs))
	# Get data to zero mean and unit variance
	mu    = mean(imgs, dims=(1))
	sigma = std(imgs, dims=(1))
	imgs  = broadcast(-, mu, imgs) 
	imgs  = broadcast(/, sigma, imgs)

	for t in 1:size(imgs)[1]
		for i in 1:dims
			for j in 1:dims
				results[t, i, j] = tnlm(imgs, 
										string(i)*"-"*string(j),
										t,
										NEIGHS, 
										WEIGHTS)
			end
		end
		if verbose == true
			println("Timestep ", t, " out of ", size(imgs)[1], " completed")
		end
	end

	if verbose == true 
		println("max number of results:", maximum(results))
		println("min number of results:", minimum(results))
	end
	return results
end


""" Return processed images. """
function display_imgs()
	return
end