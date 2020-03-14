{smcl}
{* 09 March 2020}{...}
{hline}
help for {hi:knn}
{hline}

{title:Distance and identity of {it:k} nearest neighbours from point coordinates}

{p 2 11}
{cmd:knn} 
{it:x1} 
{it:x2} 
{it:...}
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 
, 
{cmd:{ul:k}nearest(}{it:k}{cmd:)} 
{cmd:knd(}{it:stub}{cmd:)} 
{cmd:kni(}{it:stub}{cmd:)} 


{title:Description}

For every observation (as selected by {cmd:if} and {cmd:in}), this Stata routine computes the {it:k} nearest neighbours in the 
data set (again, as selected by {cmd:if} and {cmd:in}). It has some overhead, so may not be quicker than the brute force approach if
the number of observations is very small. For large data sets, it runs much faster than brute force. 

{p}{it:x1,x2,..} is a list of variables (a {it:varlist}) containing the coordinates of the data points. 
Currently, there must be at least two such coordinates, but there can be more than two.


{title:Options}

{p 0 4}{cmd:Knearest(}{it:k}{cmd:)} specifies the number of nearest neighbours (excluding self) to be computed.

{p 0 4}{cmd:knd(}{it:stub}{cmd:)} is a name that will be used to construct variables holding the nearest neighbour distances.
These will be called {it:stub1}, {it:stub2}, etc.

{p 0 4}{cmd:knd(}{it:stub}{cmd:)} is a name that will be used to construct variables holding the nearest neighbour indices.
These will be called {it:stub1}, {it:stub2}, etc.

{title:Examples}

{p 4 8}{inp: clear}

{p 4 8}{inp: set obs 10}

{p 4 8}{inp: gen x1 = runiform()}

{p 4 8}{inp: gen x2 = runiform()}

{p 4 8}{inp: knn x1 x2, k(2) kni(kni_) knd(knd_)}

{title:See also}

{cmd:knn()}: the underlying Mata routine, for more flexible use cases: type {cmd:help mata:knn()}

{title:Author} 

        Robert Aue, ZEW Mannheim
        robert.aue@hotmail.de

