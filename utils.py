# Python functions for Temporal Non-Local Means
import numpy as np 

def weights(imgs, s, r, h=0.7):
	""" Returns weight for s & r """
	ws = imgs[:, s[0], s[1]]
	wr = imgs[:, r[0], r[1]]

	return np.exp(-(2 - 2*np.corrcoef(ws, wr)[-1, -1]) / (h**2))


def neighbors(s, dims, d):
	""" Returns neighbors with distance<d for point S. """
	n = []
	for i in range(max(0, s[0]-d), min(dims, s[0]+d+1)):
		for j in range(max(0, s[1]-d), min(dims, s[1]+d+1)):
			# apply euclidean norm between points
			if np.sqrt((s[0]-i)**2 + (s[1]-j)**2) <= d:
				n.append([i,j])
	return n


def tnlm(imgs, s, t, NEIGHS, WEIGHTS):
	""" Temporal Non-Local Means algo. """
	n = NEIGHS[s]
	w_sr = np.array([WEIGHTS[s + "/" + str(r[0])+"-"+str(r[1])] for r in n])
	d_rt = np.array([imgs[t, r[0], r[1]] for r in n])

	val = (1/np.sum(w_sr)) * np.sum([drt*wsr for drt, wsr in zip(d_rt, w_sr)])
	return val


def data(imgs, p, t=None):
	""" Return data from p @time = t. """
	if t is None:
		return imgs[:, p[1], p[2]]

	return imgs[t, p[1], p[2]]


def run(imgs, dims, NEIGHS, WEIGHTS, verbose=None):
	""" Return processed images. """
	results = np.zeros_like(imgs).astype(np.float)
	# Get data to zero mean and unit variance
	mu    = np.mean(imgs, axis=(0))
	sigma = np.std(imgs, axis=(0))
	imgs  = (imgs-mu)/sigma

	for t in range(imgs.shape[0]):
		for i in range(dims):
			for j in range(dims):
				results[t, i, j] = tnlm(imgs, 
										str(i)+"-"+str(j),
										t,
										NEIGHS, 
										WEIGHTS)
		
		if verbose:
			print("Timestep", t, "out of", imgs.shape[0], "completed")

	if verbose:
		print("max number of results:", np.amax(results))
		print("min number of results:", np.amax(results))

	return results