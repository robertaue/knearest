mata: mata clear
mata: mata set matastrict on
capture mata: mata drop median()

mata
real scalar median(real colvector values) {
	/* Finds the median a column vector.
	(can be subscripted from a matrix, e.g. mymat[,1])*/
	real scalar median_pos, len, medianvalue
	real vector sorted_values

	sorted_values = sort(values, 1)
	len = length(values)
	
	if (mod(len,2)==1) { /* if uneven number: exact median */
		medianvalue = sorted_values[(len+1)/2]
	}
	else { /* else: median from the left */
		median_pos = len/2
		medianvalue = (sorted_values[median_pos] + sorted_values[median_pos+1] ) /2
	}
	
	return(medianvalue)
}
end



mata
values = (2,2,1,3,5)'
median(values)
values = (2,2,1,3,5)'
median(values)
values = (2,1,3)
median(values)
data = (2,10\1,11\3,12)
median(data[,1])
end
