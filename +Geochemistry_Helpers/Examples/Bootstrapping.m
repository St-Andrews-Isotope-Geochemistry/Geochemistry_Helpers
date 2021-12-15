%% Example of bootstrapping
clear

%% Generate a random time series
random_bin_edges = sort(100*rand(1,101));

gaussian_process = Geochemistry_Helpers.GaussianProcess("rbf",random_bin_edges);
gaussian_process.runKernel([1,10]);
gaussian_process.getSamples(1);

time_series = gaussian_process.samples + rand(size(gaussian_process.samples))*0.5;

%%
samples = time_series;
age_bin_edges = 0:5:100;
age_bin_midpoints = age_bin_edges(1:end-1)+2.5;
value_bins = (-10:0.1:10)';

for age_bin_index = 1:numel(age_bin_edges)-1
    relevant_samples = random_bin_edges>age_bin_edges(age_bin_index) & random_bin_edges<=age_bin_edges(age_bin_index+1); 
    
    samplers(age_bin_index) = Geochemistry_Helpers.Sampler.fromSamples(value_bins,samples(relevant_samples),"monte_carlo"); 
end

bootstrapped = samplers.bootstrap(1000);
    
for age_index = 1:size(bootstrapped,1)
    means(age_index,:) = bootstrapped(age_index,:).mean();
    mean_sampler(age_index) = Geochemistry_Helpers.Sampler.fromSamples(value_bins,means(age_index,:),"monte_carlo");
end
final_means = mean_sampler.mean();
final_standard_deviations = mean_sampler.standard_deviation();

%%
figure(1);
clf
hold on
plot(random_bin_edges,time_series,'r.');

plot(age_bin_midpoints,final_means-2*final_standard_deviations,'k--');
plot(age_bin_midpoints,final_means+2*final_standard_deviations,'k--');
plot(age_bin_midpoints,final_means,'k');
