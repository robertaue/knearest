/* duplicates are problem for the following reason: at the very end, the two
duplicates will always be put together into the same node, and the tree building
algorithm never finishes. Also, the nearest neighbour among two identical
points is not well defined!

In the Stata parent routine, I should include a check for uniqueness and leave
it to the user to deal with non-unique data points. */

mata: mata clear
mata: mata set matastrict on
run mata_knn.do

// See how the tree grows when there are duplicate points

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
kd_tree_print(root)
display("The tree has " + strofreal(kd_tree_size(root)) + " nodes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")

end

// Test how the tree grows when all data points are the same on one axis (but different on at least another one aixs)

mata
/* set up test data */
data = (1,1\
		1,2\
		1,3\
		1,4\
		1,5)
index = (1::rows(data))							/* has to be a col matrix */
/* build the tree, inspect the result */
root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)
liststruct(root)
liststruct(*root.left)
liststruct(*root.right)
kd_tree_print(root)
display("The tree has " + strofreal(kd_tree_size(root)) + " nodes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")
end


// Test how the tree grows when data points form a lower left triangle or a upper right triangle (cannot be splitted if we don't change the split rule)

mata
/* set up test data (lower left triangle)*/
data = (1,1\
		1,2\
		1,3\
		2,1\
		3,1)
index = (1::rows(data))							/* has to be a col matrix */
/* build the tree, inspect the result */
root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)
liststruct(root)
liststruct(*root.left)
liststruct(*root.right)
kd_tree_print(root)
display("The tree has " + strofreal(kd_tree_size(root)) + " nodes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")
end

mata
/* set up test data (upper right triangle)*/
data = (1,3\
		2,3\
		3,3\
		3,2\
		3,1)
index = (1::rows(data))							/* has to be a col matrix */
/* build the tree, inspect the result */
root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)
liststruct(root)
liststruct(*root.left)
liststruct(*root.right)
kd_tree_print(root)
display("The tree has " + strofreal(kd_tree_size(root)) + " nodes.")
display("The maximum depth of the tree is " + strofreal(kd_tree_depth(root)) + ".")
end

