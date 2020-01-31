/*
	test the find_knn function
*/

mata: mata clear
mata: mata set matastrict on
run mata_knn.do

mata
/* set up test data */

Ntest = 10000
data = runiform(100,2)
index = (1::rows(data))							/* has to be a col matrix */

/* build the tree */

root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)

/* compare kd tree and brute force result */

k = 5

for (t=1;t<=Ntest;t++) {
	/* construct a query point */
	query_point = runiform(1,2)

	/* need to initialize knd with large numbers, larger than any distance encountered */
	knd = J(1,k,2) /* has to be initialized before each call to find_knn */
	kni = J(1,k,0)
	
	/* run the search algorithm */
	find_knn(query_point, root, k, kni, knd, knd_maxid=1)

	/* double check against naive brute force search */
	distances = sqrt(rowsum((data:-query_point):^2))
	minindex(distances, k, kni_check=., .)
	knd_check = distances[kni_check]'

	assert(sum(kni)==sum(kni_check))
	}

end
