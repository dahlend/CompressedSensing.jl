# CompressiveSensing

This package contains several useful algorithms for compressive sensing, multiple measurement vectors, and sparse blind source separation.

##Available Algorithms

#####SMV - Single Measurement Vectors
   http://www.sciencedirect.com/science/article/pii/S092523121300430X
- *IRLS* - Equality constrained Iteratively Rewieghted Least Squares Lp Minimization
- *UIRLS* - Unconstrained Iteratively Reweighted Lease Squares Lp Minimization

#####MMV - Multiple Measurement Vectors
- *ZAP* - Zeropoint Attractor - http://arxiv.org/pdf/1203.1548.pdf

#####BSS - Sparse Blind Source Separation
- *nGMCA* - Sparse non-negative Blind Source Separation - http://arxiv.org/pdf/1308.5546.pdf

#####Quantifying Sparsity
- *GI* - Absolute Gini Index - http://arxiv.org/pdf/0811.4706.pdf
- *Coherence* - Measuring the coherence of a measurement matrix by the definitions commonly used - http://cmc.edu/pages/faculty/DNeedell/papers/redundant.pdf


##Functions

######IRLS(MeasurementMatrix,Measurement;x...)
This function reconstructs a signal using Lp minimization, where 0 < p < =1
It accepts these options:
	- *verbose = false* - Print iteration and convergence information
	- *maxiter = 1000* - The maximum number of iterations before giving up.
	- *p = .5* - The p in Lp
	- *theshold = 1e-5* - Threshold for convergence, the smaller the number the more the algorithm converges.
	- *eps=x- >1/x^3* - A function that converges to 0 as x->Inf. The faster eps approaches 0 the faster the algorithm converges, however it also becomes more likely to fail.  1/x^3 seems to be something of a conservative setting, resulting in good convergence at the cost of taking slightly more time to run.

##Examples

####IRLS

[IRLS Example](./examples/Example_1_Fig_1.png)

```julia
#Signal Dimensions
n=1000
#measurement dimension
m=400
#Approximate Sparsity
k=100

#Create a random sparse signal
Signal = zeros(n)
Signal[int(rand(k)*(n-1)+1)] = randn(k)

#Create a random measurement matrix
MM = randn(m,n)

#Measure the signal using the measurement matrix
Measurement = MM*Signal

#Reconstruct using IRLS
Reconstruction = IRLS(MM,Measurement,verbose=true)[1]
```