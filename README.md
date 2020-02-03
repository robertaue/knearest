# knearest
This repository currently only includes Mata modules to compute the (k) nearest neighbours from a set of points. This is useful for researchers who analyse large spatial data sets, and need to compute spatial relationships between their observations.
At the heart of this is the Mata routine `build_kd_tree()` that builds a k-dimensional search tree (kd-tree) for a given set of data points. This can be used to efficiently look up the nearest neighbours using the function `find_knn()`. The `knn()` function provides a convenient interface to these two steps, as is illustrated by the following example:
```
version 15.1
mata: mata clear
mata: mata set matastrict on
run "https://raw.githubusercontent.com/robertaue/knearest/master/mata_knn.do"
mata:
    N = 10000
    k = 5
    query_coords = runiform(N,2)
    data_coords = runiform(N,2)
    knn(query_coords, data_coords, k, kni=., knd=.)
end
```
It is further planned to write a simple Stata program to make these functions accessible without using Mata.
