using CompressedSensing
using PyPlot
#This is a recreation of figure 1 from http://arxiv.org/pdf/1203.1548.pdf
#WARNING: this simulation takes a few minutes to complete!

#define settings used
sources=200
sensors=50
measurements= 10

noise=0
srand(0)

#how many monte carlo runs to do
max_monte=100

#at what sparsity should the algorithm be tested
S=10:5:40

mean_cor=zeros(length(S))

#For each sparsity level
for sparsity = 1:length(S)
    #run max_monte simulations and record the results
    for monte=1:max_monte
        #Create a signal that is sparsity sparse
        signal = zeros(sources,measurements)
        index=[] #Find "sparsity" random indecies
        while length(index)<S[sparsity]
            index = [index,unique(int(rand(1)*(sources-1)+1))]
        end
        #Set those random indecies to random gaussian values
        signal[index,:]=randn(S[sparsity],measurements)
        
        #Create an IID random measurement matrix
        measurement_Matrix = randn(sensors,sources)

        #"Measure" the signal, and add noise if desired
        measured = measurement_Matrix*signal+randn(sensors,measurements)*noise;

        #Attempt to rebuild the signal from the measurement and the measurement_Matrix
        re_signal = ZAP(measured,measurement_Matrix,verbose=false)

        #Record how often the answer is correct (we define correct to be >.99 correlation)
        mean_cor[sparsity]+=mean(sum(cor(signal, (re_signal)).*eye(measurements),1).>.99)./max_monte
    end
end

#plot the results
figure(figsize=(3.5,3))
xlabel("K Sparsity")
ylabel("Recovery Rate (%)")
ylim(0,1)
plot(S,mean_cor)
savefig("Example_5_Fig_1.png", bbox_inches="tight",pad_inches=.2)