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
