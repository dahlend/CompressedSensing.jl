#CompressedSensing
[![Build Status](https://travis-ci.org/dahlend/CompressedSensing.svg?branch=master)](https://travis-ci.org/dahlend/CompressedSensing)

This package contains several useful algorithms for compressed sensing, multiple measurement vectors, and sparse blind source separation. 

- [Examples](Examples/)
- [Functions](Functions/)


##Available Algorithms

#####SMV - Single Measurement Vectors
- *IRLS* - Equality constrained Iteratively Rewieghted Least Squares Lp Minimization [1][bib1]
- *UIRLS* - Unconstrained Iteratively Reweighted Lease Squares Lp Minimization [1][bib1]

#####MMV - Multiple Measurement Vectors
- *ZAP* - Zeropoint Attractor [2][bib2]

#####BSS - Sparse Blind Source Separation
- *nGMCA* - Sparse non-negative Blind Source Separation [3][bib3]

#####Quantifying Sparsity
- *GI* - Absolute Gini Index [4][bib4]
- *Coherence* - Measuring the coherence of a measurement matrix by the definitions commonly used [5][bib5] 






[bib1]:http://www.sciencedirect.com/science/article/pii/S092523121300430X
[bib2]:http://arxiv.org/pdf/1203.1548.pdf
[bib3]:http://arxiv.org/pdf/1308.5546.pdf
[bib4]:http://arxiv.org/pdf/0811.4706.pdf
[bib5]:http://cmc.edu/pages/faculty/DNeedell/papers/redundant.pdf