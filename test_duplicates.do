/* duplicates are problem for the following reason: at the very end, the two
duplicates will always be put together into the same node, and the tree building
algorithm never finishes */

mata: mata clear
mata: mata set matastrict on
run mata_knn.do

mata
/* set up test data */

data = (1,5\
		1,6\
		6,3\
		7,5\
		3,4)
index = (1::rows(data))							/* has to be a col matrix */
data[2,] = data[1,] /* create a duplicate entry */

/* build the tree, inspect the result */

root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)

liststruct(root)
liststruct(*root.left)
liststruct(*root.right)
display("The tree consumes " + strofreal(kd_tree_size(root)) + " bytes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")

end
