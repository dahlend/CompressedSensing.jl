#An example of nGMCA
using CompressedSensing
using PyPlot
srand(1)

#Generate some sparse positive data, S and A
n=1000
m=500
r=20
k_a=2
k_s=1

A=zeros(n,r)
S=zeros(r,m)

for i =1:n
    A[i,int(rand(k_a)*(r-1))+1]=rand(k_a)
end
for i =1:m
    S[int(rand(k_s)*(r-1))+1,i]=rand(k_s)
end

#calculate the Gini Index of the data
print(string("GI(S): ",GI(S),"    GI(A): ",GI(A)))

#Find the response matrix
Y=A*S

#attempt to rebuild the inputs from only the output
(A0,S0)=nGMCA(Y,r;verbose=true,maxIter=100,threshold=1e-7,phaseRatio=.15)

#See how well it correlates with the inputs
figure(figsize=(12,5))
subplot(121)
title("Correlation for A")
pcolormesh(cor(A0,A).^2)
colorbar()
subplot(122)
title("Correlation for S")
pcolormesh(cor(S0',S').^2)
colorbar();
savefig("Example_4_Fig_1.png")