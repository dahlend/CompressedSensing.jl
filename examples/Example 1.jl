#Basic Example of IRLS in a noiseless situation

using PyPlot
using CompressedSensing

srand(0)

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
Reconstruction = IRLS(MM,Measurement,verbose=true)

#plot the results
bar(1:length(Signal),Signal,width=.01) #easiest method for plotting thin lines
SigHandle = plt.Line2D([], [],label="Signal",color="black") #by using bar() plot above, the legend
						#gets all funky, so to fix it make a handle that contains the correct
						#information	
ReconPlot=scatter(1:length(Reconstruction),Reconstruction,label="IRLS Reconstruction")
xlim(0,length(Signal))
legend(loc=1,handles=[SigHandle,ReconPlot])
savefig("Example_1_Fig_1.png")