/*
Test the utility wrapper function knn()
*/

mata: mata clear
mata: mata set matastrict on
run mata_knn.do


mata
display("TEST: knn()")
k = 10 		/* number of nearest neighbours to search for */
d = 3  		/* dimension of data points */
N = 1000	/* number of data points */
Ntests = 1	/* number of test runs with randomly generated data */

N_kni_errors = 0
max_abs_knd_error = 0
for (t=1;t<=Ntests;t++) {

	/* construct a random data set of coordinates */
	data = runiform(N,d)
	
	/* run the search algorithm */
	knn(data, data, k, kni=., knd=.)

	/* double check against naive brute force search */
	for (i=1;i<=N;i++) {
		query_point = data[i,]
		distances = sqrt(rowsum((data:-query_point):^2))
		minindex(distances, k, kni_check=., .)
		knd_check = distances[kni_check]'
		N_kni_errors = N_kni_errors + sum(kni[i,] :!= kni_check')
		max_abs_knd_error = max((max_abs_knd_error, max(abs(knd[i,]-knd_check))))
	}
}

display("Number of wrong nearest neighbours:  " + strofreal(N_kni_errors))
display("Maximum absolute error of distances: " + strofreal(max_abs_knd_error))
	


/* build the tree */



end
