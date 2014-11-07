##Examples

####[IRLS - Example 1](examples/Example 1.jl)

```julia

n=1000   #Signal Dimensions
m=400    #Measurement Dimension
k=100    #Approximate Sparsity

Signal = zeros(n)     #Create a random sparse signal
Signal[int(rand(k)*(n-1)+1)] = randn(k)

MM = randn(m,n)     #Create a random measurement matrix
Measurement = MM*Signal  #Measure the signal using the measurement matrix

#Reconstruct using IRLS
Reconstruction = IRLS(MM,Measurement,verbose=true)
```
![IRLS Example](examples/Example_1_Fig_1.png)


####[UIRLS w/ Noise - Example 2](examples/Example 2.jl)
Taking the signal and measurement matrix from example 1:
```julia
Noise = randn(m)*.3
Measurement += Noise  #Add ~30% noise to the measurement and reconstruct

#reconstruct using IRLS and UIRLS at multiple lambdas
IRLS(MM,Measurement)
UIRLS(MM,Measurement,lambda=.1)
```
![IRLS Example](examples/Example_2_Fig_1.png)

####[Gini Index - Example 3](examples/Example 3.jl)
The gini index is an excelent measure of the sparsity of a dataset, a full discussion of its benefits are discussed in [[4]][bib4].  To briefly see the benefit, we can look at the difference between GI and L0 as a measure of sparsity on noisy and non-noisy data.  Here we have made 2 vectors of length 100, one without noise and one with noise. The noiseless vector starts set to 0, and each element is incrementally set to 1.  Taking the L0 sparsity of this, we get the expected result of 1,2,3 etc. However if we add a small amount of noise to the vector, the L0 sparsity is fixed at 100. A comparison to the GI is visible.

![GI Index Example](examples/Example_3_Fig_1.png)


[bib1]:http://www.sciencedirect.com/science/article/pii/S092523121300430X
[bib2]:http://arxiv.org/pdf/1203.1548.pdf
[bib3]:http://arxiv.org/pdf/1308.5546.pdf
[bib4]:http://arxiv.org/pdf/0811.4706.pdf
[bib5]:http://cmc.edu/pages/faculty/DNeedell/papers/redundant.pdf