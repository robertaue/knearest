/*
	Mata routines for (k) nearest neighbour search
	
	Robert Aue, 13.07.2018
	
	for an explanation and pseudocode, see
	http://andrewd.ces.clemson.edu/courses/cpsc805/references/nearest_search.pdf
	
	edit 17.07.18: added check for NULL pointer in find_knn() which caused problems
	edit 28.01.20: make max_recursion_depth optional, with reasonable default value
*/

capture mata: mata drop kd_node()
capture mata: mata drop median()
capture mata: mata drop kd_tree_build()
capture mata: mata drop kd_tree_print()
capture mata: mata drop kd_tree_depth()
capture mata: mata drop find_nn()
capture mata: mata drop find_knn()
capture mata: mata drop knn()

mata
struct kd_node {
	/* container to hold a node, and possibly a pointer to child nodes */
	real scalar idx, axis, value
	real vector point
	pointer(struct kd_node) left, right
}

real scalar median(real matrix values) {
	/* finds the median of a list */
	real scalar median_pos, len, medianvalue
	real vector ordering
	ordering = order(values, 1)
	
	/* position in the ordered vector */
	len = length(values)
	if (mod(len,2)==1) {
		/* if uneven number: exact median */
		medianvalue = values[ordering[(len+1)/2]]
	}
	else {
		median_pos = len/2
		medianvalue = (values[ordering[median_pos]] + values[ordering[median_pos+1]] ) /2
	}
	
	return(medianvalue)
}

struct kd_node kd_tree_build(real matrix data, real matrix index, real scalar Ndim, real scalar axis, real scalar max_rec_depth) {
	/* From a given set of data along with an index variable, construct
	a search tree. Note that data must be a N x Ndim matrix, and index must
	be a N x 1 Matrix. orientation is the dimension along which to split first */
	
	struct kd_node scalar thisnode /* 'scalar' is required! */
	real matrix left_set, right_set, left_idx, right_idx
	real scalar axis_new
	thisnode.axis = axis
	
	if (max_rec_depth==0) {
		display("Maximum number of recursions has been reached. Check if there are data duplicates!")
		display("Currently splitting along axis " + strofreal(axis))
		display("Remaining data (first row is ID):")
		(index,data)
		exit(1)
	}
	
	if (rows(data) > 1) {
		/* find median */
		thisnode.value = median(data[,axis])
		
		/* pass on remaining data to left and right child nodes */
		left_set  = select(data,  data[,axis] :<= thisnode.value)
		left_idx  = select(index, data[,axis] :<= thisnode.value)
		right_set = select(data,  data[,axis] :>  thisnode.value)
		right_idx = select(index, data[,axis] :>  thisnode.value)
		
		/* cycle through the dimensions and continue with remaining points*/
		axis_new = mod(axis, Ndim) + 1
		if (rows(left_set)>=1) {
			thisnode.left =  &kd_tree_build(left_set, left_idx, Ndim, axis_new, max_rec_depth-1)
		}
		else thisnode.left = NULL
		if (rows(right_set)>=1) {
			thisnode.right = &kd_tree_build(right_set, right_idx, Ndim, axis_new, max_rec_depth-1)
		}
		else thisnode.right = NULL
	}
	else {
		/* terminal node */
		thisnode.point = data[1,]
		thisnode.idx   = index[1]
		thisnode.left  = NULL
		thisnode.right = NULL
	}
	
	return(thisnode)
}

void kd_tree_print(struct kd_node scalar root) {
	if (root.left == NULL & root.right == NULL) {
		display("idx: " + strofreal(root.idx) + " axis: " + strofreal(root.axis))
	}
	else {
		kd_tree_print(*root.left)
		kd_tree_print(*root.right)
	}
}

real scalar kd_tree_size(struct kd_node scalar root) {
	/* returns the memory size of the search tree */
	real scalar size
	size = sizeof(root)
	if (root.left != NULL) {
		size = size + kd_tree_size(*root.left)
	}
	if (root.right != NULL) {
		size = size + kd_tree_size(*root.right)
	}
	return(size)
}

real scalar kd_tree_depth(struct kd_node scalar root) {
	/* returns the maximum depth search tree */
	real scalar depth, depth_left, depth_right
	depth = 1
	depth_left = depth_right = 0
	if (root.left != NULL) {
		depth_left = kd_tree_depth(*root.left)
	}
	if (root.right != NULL) {
		depth_right = kd_tree_depth(*root.right)
	}
	return(depth + max((depth_left,depth_right)))
}

void find_nn(real vector query_coord, struct kd_node scalar thisnode, 
	real vector nearest_coord, real scalar nearest_idx, real scalar nearest_dist) {
	real scalar dist
	if (thisnode.left == NULL & thisnode.right == NULL) {
		dist = sqrt(sum((query_coord :- thisnode.point):^2))
		/*display("  found a leaf with idx = " + strofreal(thisnode.idx) + ", dist = " + strofreal(dist))*/
		if (dist < nearest_dist) {
			/*display("  this is closer than the previous point.")*/
			nearest_dist 	= dist
			nearest_coord   = thisnode.point
			nearest_idx     = thisnode.idx
		}
	}
	else {
		if (query_coord[thisnode.axis] <= thisnode.value) {
			/*display("search first to the left of axis " + strofreal(thisnode.axis))*/
			/*if (query_coord[thisnode.axis] - nearest_dist <= thisnode.value)*/ /* this is implied by previous if-condition */
				find_nn(query_coord, *thisnode.left, nearest_coord, nearest_idx, nearest_dist)
			if (query_coord[thisnode.axis] + nearest_dist > thisnode.value)
				find_nn(query_coord, *thisnode.right, nearest_coord, nearest_idx, nearest_dist)
		}
		else {
			/*display("search first to the right of axis " + strofreal(thisnode.axis))*/
			/*if (query_coord[thisnode.axis] + nearest_dist > thisnode.value)*/
				find_nn(query_coord, *thisnode.right, nearest_coord, nearest_idx, nearest_dist)	
			if (query_coord[thisnode.axis] - nearest_dist <= thisnode.value)
				find_nn(query_coord, *thisnode.left, nearest_coord, nearest_idx, nearest_dist)				
		}
	}
}

void find_knn(real vector query_coord, struct kd_node scalar thisnode, 
	real scalar k, real vector kni, real vector knd, real scalar knd_maxid) {
	/* kni and knd are k-dim vectors holding the current k nearest neighbours
	and distances, respectively. The currently _largest_ distance is found
	in knd[knd_maxid]. */
	
	/*display("Current worst knd = " + strofreal(knd[knd_maxid]) + " at " + strofreal(knd_maxid))*/
	real scalar dist
	real vector i
	if (thisnode.left == NULL & thisnode.right == NULL) {
		dist = sqrt(sum((query_coord :- thisnode.point):^2))
		/*display("  found a leaf with idx = " + strofreal(thisnode.idx) + ", dist = " + strofreal(dist))*/
		if (dist < knd[knd_maxid]) {
			/*display("  this is closer than the previous worst point.")*/
			knd[knd_maxid] 	= dist
			kni[knd_maxid]  = thisnode.idx
			/* find new position of the maximum */
			maxindex(knd, 1, i, .)
			knd_maxid = i[1]
		}
	}
	else {
		if (query_coord[thisnode.axis] <= thisnode.value) {
			/*" search first to the left "*/
			/*if (query_coord[thisnode.axis] - knd[knd_maxid] <= thisnode.value)*/ /* this condition is superfluous because the above if cond already implies this!*/
			if (thisnode.left != NULL)
				find_knn(query_coord, *thisnode.left,  k, kni, knd, knd_maxid)
			if (thisnode.right != NULL & query_coord[thisnode.axis] + knd[knd_maxid] > thisnode.value)
				find_knn(query_coord, *thisnode.right, k, kni, knd, knd_maxid)
		}
		else {
			/*" search first to the right "*/
			/*if (query_coord[thisnode.axis] + knd[knd_maxid] > thisnode.value)*/ /* this condition is superfluous because the above if cond already implies this!*/
			if (thisnode.right != NULL)
				find_knn(query_coord, *thisnode.right, k, kni, knd, knd_maxid)
			if (thisnode.left != NULL & query_coord[thisnode.axis] - knd[knd_maxid] <= thisnode.value)
				find_knn(query_coord, *thisnode.left,  k, kni, knd, knd_maxid)	
		}
	}
}

void knn(real matrix query_coords, real matrix data_coords,
	real scalar k, real matrix kni, real matrix knd, |real scalar max_rec_depth) {
	
	/* just a wrapper around find_knn and kd_tree_build for convenience */
	
	real scalar Nqueries,  Ndim, maxdist, first_axis, Ndata1percent, q
	real vector index, span, knd_q, kni_q, sort_knd /*, coord_q, coord_q_old*/
	struct kd_node scalar root /* scalar is required here */
	
	/*timer_on(5)*/
	/* a few dimension checks and set ups */
	Nqueries = rows(query_coords)
	assert(cols(query_coords) == cols(data_coords))
	Ndim = cols(query_coords)
	index = (1::rows(data_coords))
	if (args()<6) max_rec_depth = ceil(ln(rows(data_coords))/ln(2)) + 1
	/*coord_q_old = query_coords[1,]
	coord_q = query_coords[1,]*/
	
	/* check that all points are distinct (else the kd tree gros unbounded */
	if (rows(data_coords) != rows(uniqrows(data_coords))) {
		display("data_coords contains duplicates")
		exit(1)
	}
	
	/* compute maximum distance to be expected (to initialize knd) */
	span = colmax(query_coords):-colmin(query_coords)
	maxdist = sqrt(sum(span:^2))*2 /* just in case a query point is sligthly out of bounds */
	kni = J(Nqueries, k, .)
	knd = J(Nqueries, k, .) 
	kni_q = J(1,k,1)	/* has to be initialized before each call to find_knn() */
	knd_q = J(1,k,maxdist)
	
	/* find first axis (whichever has larger span) */
	if (abs(span)[1]>=abs(span[2])) first_axis = 1
	else first_axis = 2
	
	/*timer_off(5)
	timer_on(6)*/
	
	/* build the tree */
	display("Building the kd tree for " + strofreal(rows(data_coords)) + " data points in " + strofreal(Ndim) + " dimensions ...")
	root = kd_tree_build(data_coords, index, Ndim, first_axis, max_rec_depth)
	
	/*timer_off(6)
	timer_on(7)*/
	
	/* loop through query points, find knn for each */
	display("Finding " + strofreal(k) + " nearest neighbours for " + strofreal(Nqueries) + " query points. Each . = 1% ...")
	Ndata1percent = trunc(Nqueries/100)
	for (q=1; q<=Nqueries; q++) {
		/*find_knn(query_coords[q,], root, k, kni[q,], knd[q,], 1)*/
		/* this turns out to be four times faster: */
		/*coord_q = query_coords[q,]*/
		kni_q = kni_q*0 /* need to reset each time? */
		/* If we know knd_max(q), the largest knd of point q, and the distance ||q-q'||,
		then knd_max(q') <= knd_max(q) + ||q-q'||. I planned to "update" the knd vector
		but this does not work so easily, because the tree has to be traversed from the
		start and setting knd too low breaks this!*/
		/*knd_q = knd_q*0 :+ sum(abs(coord_q:-coord_q_old))*2*/
		knd_q = knd_q :+ maxdist
		find_knn(query_coords[q,], root, k, kni_q, knd_q, 1)
		sort_knd = order(knd_q', 1)'
		kni[q,] = kni_q[sort_knd]
		knd[q,] = knd_q[sort_knd]
		/*swap(coord_q, coord_q_old)*/
		/* impact of the following on speed is < 10% */
		if (!mod(q, Ndata1percent)) {
			printf(".")
			displayflush() /* override buffering, force display */
		}
	}
	/*timer_off(7)*/
	display(" done.")
}


end
