/*
	Mata routines to compute weighted average of neighbours' variables
	
	Robert Aue, 13.07.2018
	
	This function computes the weighted average of the variables in colnames
	among all the nearest neighbours that are encoded in the matrix kni.
	See example_compute_nn_average.do for an example
	
	Syntax:
		colnames - a string vector of variables of interest
		weights  - an NxK matrix of weights
		kni 	 - an NxK matrix, so that kni[i,k] is the index of i-th
		           k-th nearest neighbour.
	
	N is the number of observations in data, K the number of neighbours to consider
	
*/

capture mata: mata drop nn_average()
mata
	void nn_average(string vector colnames, weights, kni) {
		real matrix X, WX
		real vector nn
		real scalar Nobs, Nvar, v, j
		string scalar Wname
		
		X = st_data(., colnames)
		colnames = tokens(colnames)
		Nobs = st_nobs()
		Nvar = cols(colnames)
		WX = J(Nobs, Nvar, 0)
		
		for (j=1; j<=Nobs; j++) {
			/* select nn indices of neighbours nearer than distance_cutoff */
			WX[j,] = colsum( X[kni[j,]',] :* weights[j,.]' )
		}
		_editmissing(WX, 0)
		for (v=1; v<=Nvar; v++) {
			Wname = "W"+colnames[v]
			nn = st_addvar("float", Wname)
			st_store(., Wname, WX[,v])
		}
	}
	
end
