classdef Sampler < handle&Distribution
    properties
        method
        samples
    end
    methods
        % Constructor
        function self = Sampler(bin_edges,type,values,method)
            if nargin>0
                if nargin==2
                    distribution = bin_edges;
                    self.bin_edges = distribution.bin_edges;
                    self.type = distribution.type;
                    self.values = distribution.values;
                    self.probabilities = distribution.probabilities;
                    self.method = type;
                else
                    distribution = Distribution(bin_edges,type,values);
                    self.bin_edges = bin_edges;
                    self.type = type;
                    self.values = values;
                    self.probabilities = distribution.probabilities;
                    self.method = method;
                end
            end
        end
        function samples = getSamples(self,number_of_samples)
            if self.method=="monte_carlo"
                samples = self.getMonteCarloSamples(number_of_samples);
                self.samples = samples;
            elseif self.method=="latin_hypercube"
                samples = self.getMedianLatinHypercubeSamples(number_of_samples);
                self.samples = samples;
            else
                error("Method unknown");
            end
        end
        
        function samples = getMonteCarloSamples(self,number_of_samples)
            r = rand(1,number_of_samples);
            samples = NaN(1,number_of_samples);
            
            cumulative_distribution = [0;cumsum(self.probabilities(:))];
            
            for sample_index = 1:number_of_samples
                output_bins = zeros(numel(cumulative_distribution)-1,1);
                
                % Find which bin the random number falls in
                for bin_index = 1:numel(output_bins)
                    if r(sample_index)>=cumulative_distribution(bin_index) && r(sample_index)<cumulative_distribution(bin_index+1)
                        output_bins(bin_index:bin_index+1) = 1;
                        output_bins = logical(output_bins);
                        break;
                    end
                end
                
                distance_from_left = mod(r(sample_index),1/numel(self.bin_midpoints));
                distance_from_right = 1/numel(self.bin_midpoints)-distance_from_left;
                
                values = self.bin_edges(output_bins);
                distances = [distance_from_left,distance_from_right];
                normalised_distance = distances./sum(distances);
                
                
                samples(sample_index) = sum(normalised_distance.*values);
            end
        end
        function samples = getMedianLatinHypercubeSamples(self,number_of_samples)
            samples = NaN(1,number_of_samples);
            samples_every = 1/number_of_samples;
            left_edge = NaN(1,number_of_samples);
            right_edge = NaN(1,number_of_samples);
            
            current_value = 0;            
            left_edge = self.bin_edges(1);
            right_edge = [];
            for bin_index = 1:numel(self.bin_midpoints)
                current_value = current_value + self.probabilities(bin_index);
                if self.probabilities(bin_index)==0
                    current_value = 0;
                    left_edge(end) = self.bin_edges(bin_index+1);
                else
                    last_right_edge = self.bin_edges(bin_index);
                end
                difference_value = current_value-samples_every;
                if current_value>samples_every                    
                    current_number_of_samples = fix(current_value/samples_every);
%                     new_value = mod(current_value,samples_every);
%                     current_value = new_value;
                    if current_number_of_samples==1
                        % There's a new sample in this bin, where is it?
                        fraction_in = (self.probabilities(bin_index)-difference_value)/self.probabilities(bin_index);
                        right_edge = [right_edge,self.bin_edges(bin_index)+((self.bin_edges(bin_index+1)-self.bin_edges(bin_index))*fraction_in)];
                        left_edge = [left_edge,right_edge(end)];
                        current_value = mod(current_value,samples_every);
%                         current_value = current_value - (1-fraction_in*self.probabilities(bin_index))
                    else
                        % This bin needs to be split multiple times
                        % Get the first one
                        fraction_in = (self.probabilities(bin_index)-difference_value)/self.probabilities(bin_index);
                        right_edge = [right_edge,self.bin_edges(bin_index)+((self.bin_edges(bin_index+1)-self.bin_edges(bin_index))*fraction_in)];
                        left_edge = [left_edge,right_edge(end)];
                        
                        remaining_bin_width = (1-fraction_in)*(self.bin_edges(bin_index+1)-self.bin_edges(bin_index));
                        sample_distances = linspace(1-remaining_bin_width,1,current_number_of_samples+1);
                        actual_sample_distances = sample_distances(2:end-1);
                        for sample_distance_index = 1:numel(actual_sample_distances);
                            fraction_in = actual_sample_distances(sample_distance_index);
                            right_edge = [right_edge,self.bin_edges(bin_index)+((self.bin_edges(bin_index+1)-self.bin_edges(bin_index))*fraction_in)];
                            left_edge = [left_edge,right_edge(end)];
                        end
                        current_value = mod(current_value,samples_every);
                    end
                    
%                 left_edge = self.bin_edges(bin_index);
                end
            end
            if left_edge(end)==self.bin_edges(end) && self.probabilities(end)==0
                left_edge(end) = right_edge(end);
            end
            right_edge = [right_edge,last_right_edge];
            edges = [left_edge;right_edge];
            samples = median(edges,1);
        end
        
        function histogram(self)
            histogram(self.samples,self.bin_edges);
        end
    end
end