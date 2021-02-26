classdef Sampler < handle&Geochemistry_Helpers.Distribution
    properties
        method
        samples
        subselection
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
                elseif type~="subsample"
                    distribution = Geochemistry_Helpers.Distribution(bin_edges,type,values);
                    self.bin_edges = bin_edges;
                    self.type = type;
                    self.values = values;
                    self.probabilities = distribution.probabilities;                    
                    self.method = method;
                else
%                     distribution = Geochemistry_Helpers.Distribution(bin_edges,type,values);
                    self.bin_edges = bin_edges;
                    self.type = type;
                    self.values = values;
                end
            end
        end
        function [self,samples] = getSamples(self,number_of_samples)
            for self_index = 1:numel(self)
                if self(self_index).method=="monte_carlo"
                    samples = self(self_index).getMonteCarloSamples(number_of_samples);
                    self(self_index).samples = samples;
                elseif self(self_index).method=="latin_hypercube"
                    samples = self(self_index).getMedianLatinHypercubeSamples(number_of_samples);
                    self(self_index).samples = samples;
                else
                    error("Method unknown");
                end
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
%                         fraction_in = samples_every; %(self.probabilities(bin_index)-difference_value)/self.probabilities(bin_index);
%                         right_edge = [right_edge,self.bin_edges(bin_index)+((self.bin_edges(bin_index+1)-self.bin_edges(bin_index))*fraction_in)];
%                         left_edge = [left_edge,right_edge(end)];
                        
                        remaining_bin_width = (self.bin_edges(bin_index+1)-self.bin_edges(bin_index));
                        sample_distances = linspace(0,1,current_number_of_samples+1);
                        actual_sample_distances = sample_distances(1:end-1);
                        for sample_distance_index = 1:numel(actual_sample_distances)
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
            if numel(samples)==number_of_samples+1
                samples = samples(1:end-1);
            end
        end
        
        function [self,samples] = shuffle(self)
            for self_index = 1:numel(self);
                [~,sort_by] = sort(rand(numel(self(self_index).samples),1));
                self(self_index).samples = self(self_index).samples(sort_by);
                samples = self(self_index).samples;
            end
        end
        function distribution = distributionFromSamples(self,bin_edges)
            distribution = Geochemistry_Helpers.Distribution(bin_edges,"manual",histcounts(self.samples,bin_edges));
        end
        
        
        function output = where(self,boolean)
            assert(boolean.type=="subsample","Must be subsample");
            correct_samples = self.samples(boolean.values);
            output = Geochemistry_Helpers.Sampler();
            output.samples = correct_samples;
            output.bin_edges = self.bin_edges;
            distribution = output.distributionFromSamples(output.bin_edges).normalise();
            output.probabilities = distribution.probabilities;
        end
        function sampler = near(self,value,tolerance)
            if nargin<3
                tolerance = 0;
            end
            if numel(value)==1
                output = self.samples>=value-tolerance & self.samples<=value+tolerance;
            elseif numel(value)==2
                output = self.samples>=min(value) & self.samples<=max(value);
            else
                error("Wrong number of value - should be 1 or 2 numbers");
            end
            sampler = Geochemistry_Helpers.Sampler(self.bin_edges,"subsample",output);
            sampler.samples = self.samples(output);
            sampler.subselection = self;
            distribution = Geochemistry_Helpers.Distribution.fromSamples(sampler.bin_edges,sampler.samples);
            sampler.probabilities = distribution.probabilities;
        end
        function output = samplesNear(self,value,tolerance)
            if nargin<3
                tolerance = 0;
            end
            output = self.samples(self.near(value,tolerance));
        end
        
        function histogram(self,number_of_bins,normalisation)
            if nargin==1
                histogram(self.samples,self.bin_edges,'Normalization','Probability','EdgeColor','None');
            elseif nargin==2
                histogram(self.samples,number_of_bins,'Normalization','Probability');
            elseif nargin==3
                histogram(self.samples,number_of_bins,'Normalization',normalisation);
            end
        end
    end
end