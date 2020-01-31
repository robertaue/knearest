/*
	time the difference between kd tree lookup and brute force search
	
	with only 500 data points and 10000 queries, brute force is 3 x faster
	
	with 20000 data points, the kd search is faster (4 x)
*/

mata: mata clear
mata: mata set matastrict on
run mata_knn.do


mata

Ndata = 100000
Nqueries = 10000
k = 5

/* time the difference to brute force (20,000 data points, 10,000 query points)*/

timer_clear()
data = runiform(Ndata,2)
index = (1::rows(data))
query_points = runiform(Nqueries,2)
query_points = sort(query_points, (1,2))
kni = J(rows(query_points), k, 1)
kni_check = J(rows(query_points), k, 1)
kni_2  = J(rows(query_points), k, 1)
knd = J(rows(query_points), k, 4)
knd_check = J(rows(query_points), k, 4)
knd_2 = J(rows(query_points), k, 4)
max_depth = ceil(ln(rows(data))/ln(2))+1

timer_on(1)
root = kd_tree_build(data, index, 2, 1, max_rec_depth=max_depth)
timer_off(1)
kd_tree_size(root)

timer_on(2)
for (i=1; i<=rows(query_points); i++) {
	kni_q = J(1,k,1) /* has to be initialized before each call to find_knn() */
	knd_q = J(1,k,4)
	find_knn(query_points[i,], root, k, kni_q, knd_q, knd_maxid=1)
	knd[i,] = knd_q
	kni[i,] = kni_q
}
timer_off(2)

timer_on(3)
for (i=1; i<=rows(query_points); i++){
	distances = rowsum((data:-query_points[i,]):^2) /* use squared dist to save time */
	minindex(distances, k, kni_q, .)
	kni_check[i,] = kni_q'
	knd_check[i,] = distances[kni_q]'
}
timer_off(3)

timer_on(4)
	knn(query_points, data, k, kni_2=., knd_2=., max_rec_depth=20)
timer_off(4)

/* check if results coincide */
asserteq(rowsum(kni), rowsum(kni_check))
asserteq(rowsum(kni_2), rowsum(kni_check))
asserteq(rowsum(kni_2), rowsum(kni))


timer()
display("Time to build the tree: " + strofreal(timer_value(1)[1]) + "s")
display("Relative runtime of kd tree search: " + strofreal(timer_value(2)[1] / timer_value(3)[1]))
display("Time saved: " + strofreal(timer_value(3)[1] - (timer_value(2)[1] + timer_value(1)[1]))+"s")

end
