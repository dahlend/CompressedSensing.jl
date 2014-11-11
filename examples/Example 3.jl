#Comparing Gini Index to L0 as a measure of sparsity

using PyPlot
using CompressedSensing
srand(0)

#Create 2 data sets, one without noise, and one with 5% gaussian noise
example_data_no_noise=zeros(100)
example_data_noise=randn(100)*.05

#Create arrays that will contain the measures of sparsity for the two data sets
calculated_GI_no_noise = []
calculated_GI_noise = []
calculated_L0_no_noise = []
calculated_L0_noise = []

#for both data sets, set an increasing number of points to 1, IE: reduce sparsity on element at a time
for i=1:length(example_data_no_noise)
    
    example_data_no_noise[i]+=1
    example_data_noise[i]+=1 

    #calculate the Gini Index for both data sets and save the value
    calculated_GI_no_noise = [calculated_GI_no_noise,GI(example_data_no_noise)]
    calculated_GI_noise = [calculated_GI_noise,GI(example_data_noise)]
    
    #calculate the L0 sparsity measure for each data set and save the value
    calculated_L0_no_noise = [calculated_L0_no_noise,sum(abs(example_data_no_noise).>0)]
    calculated_L0_noise = [calculated_L0_noise,sum(abs(example_data_noise).>0.)]
end

#Plot the results
figure(figsize=(6,5))
title("Comparison of Gini Index to L0 as measures of Sparsity")
plot([1:length(example_data_no_noise)],calculated_GI_no_noise,label="Gini Index",color="red")
plot([1:length(example_data_noise)],calculated_GI_noise,label="Gini Index w/ Noise",color="purple")
xlabel("Number of Non-Zero Elements in Data")
ylabel("Gini Index")
ylim([0,1.05])
grid()
#put the L0 on a different axes, as it goes from 0-100 not 0-1
twinx()
plot([1:length(example_data_no_noise)],calculated_L0_no_noise,label="L0 Sparsity")
plot([1:length(example_data_noise)],calculated_L0_noise,label="L0 w/ Noise")
ylabel("L0 Sparsity Measure")
ylim([0,105])
annotate("L0 w/ Noise", xy=[70, 100], xytext=(65, 89),arrowprops=["width"=>.1,"headwidth"=>5]);
annotate("L0", xy=[80, 80], xytext=(85, 69),arrowprops=["width"=>.1,"headwidth"=>5]);
annotate("GI", xy=[20, 80], xytext=(25, 90),arrowprops=["width"=>.1,"headwidth"=>5]);
annotate("GI w/ Noise", xy=[20, 71], xytext=(10, 50),arrowprops=["width"=>.1,"headwidth"=>5]);
savefig("Example_3_Fig_1.png")