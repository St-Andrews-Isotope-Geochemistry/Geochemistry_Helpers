classdef Distribution < handle&Geochemistry_Helpers.Collator
    properties
        bin_edges
        probabilities
        type
        values
    end
    properties (Dependent=true)
        bin_midpoints
    end
%     properties (Hidden=true)
%         known_values = ["flat","gaussian","manual"];
%     end
    methods
        % Constructor
        function self = Distribution(bin_edges,type,values)
            if nargin==0
                self.bin_edges = NaN;
                self.probabilities = NaN;
                self.type = NaN;
                self.values = NaN;
            else
                type = lower(type);
                self.type = type;
                if self.type~="manual"
                    self.values = values;
                end
                if type=="flat"
                    assert(numel(values)==2,"Number of values must be 2");
                    assert(values(1)<=values(2),"The first value must be less than or equal to the second")
                    self.bin_edges = bin_edges;
                    probability = zeros(1,numel(self.bin_edges)-1);
                    probability(self.bin_edges>values(1) & self.bin_edges<values(2))=1;
                    self.probabilities = probability;
                elseif type=="gaussian" || type=="normal"
                    assert(numel(values)==2,"Number of values must be 2 (mean and standard deviation)");
                    self.bin_edges = bin_edges;
                    mu = values(1);
                    sigma = values(2);                    
                    gaussian = (1./(sigma.*sqrt(2.*pi))).*(exp(-0.5.*(((self.bin_midpoints-mu)./sigma).^2)));
                    self.probabilities = gaussian;                    
                elseif type=="manual"
                    assert(numel(bin_edges)==numel(values)+1,"Number of elements in bin_edges must be one greater than the number of probabilities");
                    self.bin_edges = bin_edges;
                    self.probabilities = values;
                elseif type=="subsample"
                    self.bin_edges = bin_edges;
                    self.values = values;
                    self.probabilities = NaN;
                else
                    error("Type unknown");
                end
            end
        end
        
        
        % Setters and Getters
        function set.bin_midpoints(self,value)
            error("Can't set directly");
        end
        function midpoints = get.bin_midpoints(self)
            midpoints = self.bin_edges(1:end-1) + 0.5*(self.bin_edges(2:end)-self.bin_edges(1:end-1));
        end
        
        % Analysis
        function output = quantile(self,value)
            cumulative_probabilities = [0,cumsum(self.probabilities)];
            values = cumulative_probabilities-value;
            values_sign = sign(values);
            crossover = logical(values_sign(1:end-1)-values_sign(2:end));
            locations = logical([crossover,0]+[0,crossover]);
            crossover_bin_edges = self.bin_edges(locations);
            cumulative_values = cumulative_probabilities(locations);
            distances = abs(value-cumulative_values);
            weights = 1-distances./sum(distances);
            output = sum(weights.*crossover_bin_edges);
        end
        function self = normalise(self)
            self.probabilities = self.probabilities/sum(self.probabilities);
        end
        
        % Display
        function plot(self,varargin)
            plot(self.bin_midpoints,self.probabilities,varargin{:});
        end
    end
    methods (Static)
        function output = create(type,value)
            output = Distribution(type,value);
        end
        function output = fromSamples(bin_edges,samples)
            if isnan(bin_edges)
                value_range = range(samples);
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,101);
            elseif isscalar(bin_edges)
                value_range = range(samples);
                number_of_bins = bin_edges;
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,number_of_bins);
            end
            output = Geochemistry_Helpers.Distribution(bin_edges,"manual",histcounts(samples,bin_edges,'Normalization','Probability'));
        end
    end
end