// try to implement nearest neighbour lookup with a kd tree in mata
// see http://andrewd.ces.clemson.edu/courses/cpsc805/references/nearest_search.pdf

mata: mata clear
mata: mata set matastrict on
run mata_knn.do

mata
/* set up test data */

data = runiform(1000,2)
index = (1::rows(data))							/* has to be a col matrix */

/* build the tree, inspect the result */

root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)

liststruct(root)
liststruct(*root.left)
liststruct(*root.right)
display("The tree consumes " + strofreal(kd_tree_size(root)) + " bytes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")


/*
data
kd_tree_print(root)
root.value
root.axis
root.left->value
root.left->axis
*/

/* test the find_nn function */

query_point = (0.2,0.4)
find_nn(query_point, root, point=., idx=., dist=10)
display("Closest point of find_nn at idx = " + strofreal(idx) + " with dist = " + strofreal(dist))

distances = sqrt(rowsum((data:-query_point):^2))
minindex(distances, 1, idx_check=., .)
display("Actual closest point idx = " + strofreal(idx_check) + " with dist = " + strofreal(distances[idx_check]))

end
