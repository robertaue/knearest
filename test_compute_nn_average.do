/* example usage to compute the average of the k nearest neighbours' value */

clear all
do "mata_knn.do" // init functions
do "mata_nn_average.do"


// generate test data

set obs 100000
gen ID = _n
gen x = runiform()
gen y = runiform()
gen statistic_of_interest = rnormal()
putmata coords=(x y), replace


// find 10 nearest neighbours of each observation

mata: knn(coords, coords, 5, kni_t=., knd_t=., 20)
getmata knd_* = knd_t
getmata kni_* = kni_t
// the index refers to the observation number ID, the nearest neighbour kni_1 is
// always "self", i.e. kni_1 = ID:
assert kni_1 == ID



// compute weighted average of neighbours' statistic_of_interest if distance < .01
// with zero if no such neighbour exists
mata
	weights = knd_t[,2::5] :<= .01
	weights = weights :/ rowsum(weights)
	_editmissing(weights, 0)
	weights[1::10,]
	nn_average("statistic_of_interest", weights, kni_t[,2::5])
end
