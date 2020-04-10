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
	
	// check that data have no duplicates
	qui duplicates report `varlist' `if' `in'
	*return list
	if r(unique_value) < r(N) {
		di in red _newline "Duplicate values in `varlist' not allowed. Consider adding a small random permutation to your data."
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
	
	// initialize results variables (aborts if variables already exist - this is desired)
	forvalues q=1/`knearest' {
		qui gen long `kni'`q' = .
		qui gen double `knd'`q' = .
	}
	
	// run the search algorithm
	mata: knn_wrapper("`varlist'", `knearest', "`kni'", "`knd'", "`touse'")
	
end

capture mata: mata drop knn_wrapper()
mata
	void knn_wrapper(coord_vars, knearest, kni_stub, knd_stub, touse) {
		real matrix coords, kni, knd
		real vector idx
		real scalar k
		
		/* load data to mata, so variables will be private to knn_wrapper() */
		st_view(coords=., ., coord_vars, touse)
		idx = st_viewobs(coords)
		
		/* run the search */
		knn(coords, coords, knearest+1, kni=., knd=., ., idx) /* k+1 bec. self will always be returned by knn */
		
		/* transfer results to Stata */
		for (k=1; k<=knearest; k++) {
			/* start at q=2 to discard index reference to 'self' */
			st_store(., kni_stub+strofreal(k), touse, kni[,(k+1)]) 
			st_store(., knd_stub+strofreal(k), touse, knd[,(k+1)]) 
		}
	}
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

