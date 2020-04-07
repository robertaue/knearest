{smcl}
{* 09 March 2020}{...}
{hline}
help for {hi:knn()}
{hline}

{title:Distance and identity of {it:k} nearest neighbours from point coordinates}

{p 2 12}
{it:void} {cmd:knn(}
{it:real matrix query_coords},{break}
{it:real matrix data_coords},{break}
{it:real scalar k},{break}
{it:real matric kni},{break}
{it:real matrixc knd}, {break}
|{it:real scalar max_rec_depth}
{cmd:)}

where:

{p 4 4}
	1. {it:query_coords}   is an {it:M x Ndim} matrix of query coordinates {break}
	2. {it:data_coords}    is an {it:N x Ndim} matrix of query coordinates (could be same as query_coords) {break}
	3. {it:k}				integer that specifieshow many nearest neighbours should be searched for (including self if query_coords=data_coords) {break}
	4. {it:kni}			output: {it:M x k} matrix with indices of k nearest points in {it:data_coords}  {break}
	5. {it:knd}			output: {it:M x k} table with distances to k nearest points {break}
	6. {it:max_rec_depth}	maximum recursion depth of the search tree (optional) {break}

Currently, only data sets with {it:Ndim>1} are supported.

{title:Description}

{pstd}
For every point specified in {it:query_coords}, this function computes the {it:k} nearest neighbours in the
data points contained in {it:data_coords}. Of course, these two matrices could be the same. Results are stored
in {it:kni} and {it:knd}. It has some overhead, so may not be quicker than the brute force approach if
the number of observations is very small. For large data sets, it runs much faster than brute force. 
Currently

{title:Examples}

{p 4 4}
{inp:N = 10000} {break}
{inp:k = 5} {break}
{inp:query_coords = runiform(N,2)} {break}
{inp:data_coords = runiform(N,2)} {break}
{inp:knn(query_coords, data_coords, k, kni=., knd=.)}

{title:See also}

{cmd:knn}: a simple wrapper in Stata: type {stata help knn}

{title:Author} 

        Robert Aue, ZEW Mannheim
        robert.aue@hotmail.de

