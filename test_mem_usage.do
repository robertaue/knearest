/*
	Inspect memory usage of the tree building process
	
	The search tree consumes a lot of memory, which can be problematic for medium-
	sized data sets (>100k obs). There is a large discrepancy between the size
	of the search tree as reported by sizeof(), and the actual memory that is
	consumed.
*/

clear all
mata: mata clear
mata: mata set matastrict on
run mata_knn.do

memory // allocated memory usage before: 73,546,461 Bytes
global mem_before = r(mata_matrices_a)
mata
	data = runiform(100000,2)
	index = (1::rows(data))							/* has to be a col matrix */
	root = kd_tree_build(data, index, 2, 1, max_rec_depth=20)
	nnodes = kd_tree_size(root)
	nodesize = sizeof(root) + sizeof(root.idx) + sizeof(root.value) + 
		sizeof(root.axis) + sizeof(root.point) + sizeof(root.left) + sizeof(root.right)
	display("the tree has " + strofreal(nnodes) + " nodes.")
	mata drop data
	mata drop index
end

// allocated memory usage after: 508,779,365 Bytes
memory
global mem_after = r(mata_matrices_a)
mata
	actual_size = strtoreal(st_global("mem_after")) - strtoreal(st_global("mem_before"))
	actual_node_size = actual_size / nnodes
	
	display("actual memory usage: " + strofreal(actual_size/1e6) + " MB")
	display("actual memory usage per node: " + strofreal(actual_node_size) + " Bytes")
	display("sizeof memory usage per node: " + strofreal(nodesize) + " Bytes")
end
