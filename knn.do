/*
	Stata function to compute the (k) nearest neighbours efficiently.
	It makes use of the Mata function knn.
	
	Robert Aue, 09.03.2020
	
	To dos:
	- avoid using matrices in Mata that are visible globally, lest we overwrite
	  something that the use has already specified --> write a thin wrapper round knn
	  that takes care of the data transfer etc.

*/

clear
run "mata_knn.do"


capture program drop knn
program knn

	version 15
	syntax varlist(numeric min=2) [if] [in], [Knearest(integer 1)] knd(namelist) kni(namelist)
	marksample touse
	local k = `knearest'+1 // self will always be returned by knn
	
	// check that data have no duplicates
	qui duplicates report `varlist' `if' `in'
	*return list
	if r(unique_value) < r(N) {
		di in red _newline "Duplicate values in `varlist' not allowed"
		error 9
	}
	
	// ... and no missings
	qui misstable summarize `varlist'
	*return list
	if r(vartype) != "none" {
		di in red _newline "Missing values encountered in `varlist'"
		error 416	
	}
	
	// and that we have enough data
	qui su `varlist' `if' `in', meanonly
	if r(N)<=`knearest' {
		di in red _newline "Not enough observations to compute `knearest' nearest neighbours"
		error 9
	}
	
	// store coordinate matrices 
	tempvar id
	qui gen `id' = _n // needed to assign matrices to correct entries if only subset of data is used
	qui putmata __coords=(`varlist') __id=`id' `if' `in', replace
	
	// run the search algorithm
	mata: knn(__coords, __coords, `k', __kni=., __knd=.)
	
	// get results
	mata: __knd = __knd[,2::`k'] // discard distance to 'self'
	mata: __kni = __kni[,2::`k'] // discard index to 'self'
	mata: for (q=1;q<=cols(__kni);q++) __kni[,q] = __id[__kni[,q]] // re-project nearest indices to original id variable
	qui getmata (`knd'*)=__knd (`kni'*)=__kni, id("`id'"=__id)
	mata: mata drop __coords __knd __kni __id q
end


// check that missing return an error
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
replace x1 = . in 1
capture knn x1 x2, k(2) kni(kni_) knd(knd_)
assert _rc == 416


// check that duplicates return an error
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
replace x1 = x1[2] in 1
replace x2 = x2[2] in 1
capture knn x1 x2, k(2) kni(kni_) knd(knd_)
assert _rc == 9


// check that missing return an error
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
capture knn x1 x2, k(10) kni(kni_) knd(knd_)
assert _rc == 9


// test that it works
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
knn x1 x2, k(2) kni(kni_) knd(knd_)


// test that it works with a subset of observations
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
knn x1 x2 in 5/10, k(2) kni(kni_) knd(knd_)

// test that it works with a subset of observations (2)
clear
set obs 10
gen x1 = runiform()
gen x2 = runiform()
knn x1 x2 if x1<.8, k(2) kni(kni_) knd(knd_)


// build a thin mata wrapper
*mata: st_varindex("tmp"+strofreal(1))

