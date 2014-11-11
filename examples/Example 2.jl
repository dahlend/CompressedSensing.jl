using CompressedSensing
using PyPlot
n=1000     #Signal Dimensions
m=400      #Measurement Dimension
k=100      #Approximate Sparsity
stdNoise=.3#standard deviation of noise

srand(0)
Signal = zeros(n)        #Create a random sparse signal
Signal[int(rand(k)*(n-1)+1)] = randn(k)

MM = randn(m,n)           #Create a random measurement matrix
Measurement = MM*Signal   #Measure the signal using the measurement matrix

Noise = randn(m)*stdNoise #Create measurement noise
Measurement += Noise      #add noise to measurement

#Reconstruct using IRLS
IRLS_Reconstruction = IRLS(MM,Measurement)

#reconstruct using UIRLS at multiple lambdas
DistToSig=[]
for lam = 0.0001:.25:5
    print("\r"*string("Calculating lambda=",lam))
    UIRLS_Reconstruction = UIRLS(MM,Measurement,lambda=lam)
    #Save the Euclidean Distance to original signal
    DistToSig =[DistToSig,sum(abs(UIRLS_Reconstruction-Signal).^2).^.5]
end

#plot the results
plot(0.0001:.25:5,DistToSig,label="UIRLS Distance to Signal")
DistIRLS=sum(abs(IRLS_Reconstruction-Signal).^2).^.5
plot([0,5],[DistIRLS,DistIRLS],label="IRLS Distance to Signal")
legend(loc=5)
xlabel("Lambda")
ylabel("Euclidean Distance to Original Signal")
savefig("Example_2_Fig_1.png")