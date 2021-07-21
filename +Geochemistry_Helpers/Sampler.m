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
            edges = self.getLatinHypercubeEdges(number_of_samples);
            samples = median(edges,1);
            if numel(samples)==number_of_samples+1
                samples = samples(1:end-1);
            end
        end
        function samples = getRandomLatinHypercubeSamples(self,number_of_samples)
            edges = self.getLatinHypercubeEdges(number_of_samples);
            samples = edges(1,:) + (edges(2,:)-edges(1,:)).*rand(1,size(edges,2));
            if numel(samples)==number_of_samples+1
                samples = samples(1:end-1);
            end
        end
        function edges = getLatinHypercubeEdges(self,number_of_samples)
            samples_every = 1/number_of_samples;
            edge_index = 1;
            current_value = 0;
            added_samples = 0;
            initial_number_of_samples = number_of_samples;
            maximum_number_of_samples = min([2*number_of_samples,number_of_samples+1000]);
            
            % Find out which bin to start at
            bin_start = 1;
            while self.probabilities(bin_start)==0
                bin_start = bin_start+1;
            end
            bin_end = numel(self.bin_edges)-1;
            while self.probabilities(bin_end)==0
                bin_end = bin_end-1;
            end
            % Detect if there is a resonance between samples
            if self.probabilities(bin_start)==self.probabilities(bin_start+1)
                while abs(round(1/mod(self.probabilities(bin_start)/samples_every,1),1)-(1/mod(self.probabilities(bin_start)/samples_every,1)))<1e-10 && number_of_samples<=maximum_number_of_samples
                    number_of_samples = number_of_samples+1;
                    samples_every = 1/number_of_samples;
                    added_samples = added_samples+1;
                end
            end
            left_edge = NaN(1,number_of_samples);
            right_edge = NaN(1,number_of_samples);
            
            for bin_index = bin_start:bin_end
                current_value = current_value + self.probabilities(bin_index);
                % Check for rounding which can make a sample disappear at
                % the end
                if sum(self.probabilities(bin_index+1:end))==0 && current_value~=0 && abs(mod(current_value,samples_every)-samples_every)<1e-10
                    current_value = (fix(current_value/samples_every)+1)*samples_every;
                end
                if current_value>=samples_every
                    if abs(round(current_value/samples_every)-(current_value/samples_every))<1e-10
                        current_number_of_samples = round(current_value/samples_every);
                        leftover = round(current_value/samples_every)-(current_value/samples_every);
                    else
                        current_number_of_samples = fix(current_value/samples_every);
                        leftover = 0;
                    end
                    if current_number_of_samples==1
                        % There's a new sample in this bin, where is it?
                        difference_value = current_value-samples_every;
                        fraction_in = (self.probabilities(bin_index)-difference_value)/self.probabilities(bin_index);
                        if edge_index==1
                            left_edge(edge_index) = self.bin_edges(bin_start);
                        else
                            left_edge(edge_index) = right_edge(edge_index-1);
                        end                        
                        right_edge(edge_index) = self.bin_edges(bin_index)+((self.bin_edges(bin_index+1)-self.bin_edges(bin_index))*fraction_in);
                        
                        current_value = mod(current_value,samples_every);
                        edge_index = edge_index+1;
                    else
                        % This bin needs to be split multiple times
                        sample_distances = linspace(0,1,current_number_of_samples+1);
                        lefts_relative = sample_distances(1:end-1);
                        rights_relative = sample_distances(2:end);
                        bin_width = self.bin_edges(bin_index+1)-self.bin_edges(bin_index);
                        
                        lefts_absolute = self.bin_edges(bin_index)+(lefts_relative*bin_width);
                        rights_absolute = self.bin_edges(bin_index)+(rights_relative*bin_width);

                        left_edge(edge_index:edge_index+current_number_of_samples-1) = lefts_absolute;
                        right_edge(edge_index:edge_index+current_number_of_samples-1) = rights_absolute;
                        
                        current_value = mod(current_value,samples_every);                       
                        edge_index = edge_index+current_number_of_samples;
                    end                    
                end
            end
            edges = [left_edge;right_edge];
            edges_to_remove = floor(1+rand(added_samples,1)*(number_of_samples-1));
            edges(:,edges_to_remove) = [];            
            
            extra_samples = size(edges,2)-initial_number_of_samples;
            extra_edges_to_remove = floor(1+rand(extra_samples,1)*(number_of_samples-1));
            edges(:,extra_edges_to_remove) = [];
            
            assert(size(edges,2)==initial_number_of_samples,"Got wrong number of samples...");
            assert(edge_index-1 >= number_of_samples,"Didn't fill all samples");
        end
        
        function [self,samples] = shuffle(self)
            for self_index = 1:numel(self)
                [~,sort_by] = sort(rand(numel(self(self_index).samples),1));
                self(self_index).samples = self(self_index).samples(sort_by);
                samples = self(self_index).samples;
            end
        end
        function distribution = distributionFromSamples(self,bin_edges)
            distribution = Geochemistry_Helpers.Distribution(bin_edges,"manual",histcounts(self.samples,bin_edges));
        end
        
        function output = resample(self,weights,number_of_samples)
            assert(numel(weights)==numel(self.samples),"Number of weights must equal number of samples");
            [sorted,sorted_indices] = sort(weights);
            sorted_indices_sampler = Geochemistry_Helpers.Sampler(0:numel(weights),"manual",sorted./sum(sorted),"latin_hypercube");
            sorted_indices_sampler.getSamples(number_of_samples);
            sampled_indices = sorted_indices(ceil(sorted_indices_sampler.samples));
            resamples =  self.samples(sampled_indices);
            
%             samples = resamples;
            indices = sampled_indices;
            
            output = {resamples,indices};
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
    methods (Static=true)
        function output = fromSamples(bin_edges,samples,method)
            if isnan(bin_edges)
                value_range = range(samples);
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,101);
            elseif isscalar(bin_edges)
                value_range = range(samples);
                number_of_bins = bin_edges;
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,number_of_bins);
            end
            output = Geochemistry_Helpers.Sampler(bin_edges,"manual",histcounts(samples,bin_edges,'Normalization','Probability')',method);
            output.samples = samples;
        end
    end
end