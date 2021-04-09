classdef Distribution < handle&Geochemistry_Helpers.Collator
    properties
        bin_edges
        probabilities
        type
        values
        location
    end
    properties (Dependent=true)
        bin_midpoints
    end
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
                    bin_width = self.bin_edges(2)-self.bin_edges(1);
                    probability = zeros(1,numel(self.bin_edges)-1);
                    probability(self.bin_edges>=values(1) & self.bin_edges<values(2))=1;
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
        function set.bin_midpoints(~,~)
            error("Can't set directly");
        end
        function midpoints = get.bin_midpoints(self)
            midpoints = self.bin_edges(1:end-1) + 0.5*(self.bin_edges(2:end)-self.bin_edges(1:end-1));
        end
        
        % Analysis
        function output = quantile(self,value)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                if ~isempty(self(self_index).probabilities)
                    cumulative_probabilities = NaN(1,numel(self(self_index).probabilities)+1);
                    cumulative_probabilities(1) = 0;
                    cumulative_probabilities(2:end) = cumsum(self(self_index).probabilities);
                    values = cumulative_probabilities-value;
                    if any(values==0)
                        if numel(self(self_index).bin_midpoints(values==0))==1
                            output(self_index) = self(self_index).bin_midpoints(values==0);
                        else
                            zero_bins = self(self_index).bin_midpoints(values==0);
                            first = zero_bins(1);
                            last = zero_bins(end);
                            output(self_index) = (first+last)/2;
                        end
                    else
                        values_sign = sign(values);
                        crossover = logical(values_sign(1:end-1)-values_sign(2:end));
                        locations = logical([crossover,0]+[0,crossover]);
                        crossover_bin_edges = reshape(self(self_index).bin_edges(locations),1,2);
                        cumulative_values = cumulative_probabilities(locations);
                        distances = abs(value-cumulative_values);
                        weights = 1-distances./sum(distances);
                        output(self_index) = sum(weights.*crossover_bin_edges);
                    end
                else
                    output(self_index) = NaN;
                end
            end
        end
        function self = normalise(self)
            self.probabilities = self.probabilities/sum(self.probabilities);
        end
        
        function output = mean(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = sum(self(self_index).bin_midpoints.*self(self_index).probabilities');
            end
        end
        function output = standard_deviation(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = sqrt(sum((self(self_index).bin_midpoints-self(self_index).mean()).^2 .*self(self_index).probabilities'));
            end
        end
        function output = variance(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = (sum((self(self_index).bin_midpoints-self(self_index).mean()).^2 .*self(self_index).probabilities));
            end
        end
        
        % Display
        function plot(self,varargin)
            plot(self.bin_midpoints,self.probabilities,varargin{:});
        end
        function area(self,varargin)
            area(self.bin_midpoints,self.probabilities,varargin{:});
        end
        function output = toJSON(self)
            output = "["+newline;
            for self_index = 1:numel(self)
                output = output+sprintf("\t")+"{"+newline;
                
                output = output+sprintf("\t\t")+'"location":';
                temporary_string = num2str(self(self_index).location,'%.2f,');
                output = output+temporary_string(1:end-1);
                output = output+","+newline;
                
                output = output+sprintf("\t\t")+'"bin_edges":[';
                temporary_string = num2str(self(self_index).bin_edges,'%.2f,');
                output = output+temporary_string(1:end-1);
                output = output+"],"+newline;
                
                output = output+sprintf("\t\t")+'"probabilities":[';
                temporary_string = num2str(self(self_index).probabilities','%.5e,');
                output = output+temporary_string(1:end-1);                
                
                output = output+"]"+newline;
                output = output+sprintf("\t")+"}";
                if self_index == numel(self)
                    output = output+newline;
                else
                    output = output+","+newline;
                end
            end
            output = output+"]";
        end
       
    end
    methods (Static)
%         function output = create(type,value)
%             output = Distribution(type,value);
%         end
        function output = fromSamples(bin_edges,samples)
            if isnan(bin_edges)
                value_range = range(samples);
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,101);
            elseif isscalar(bin_edges)
                value_range = range(samples);
                number_of_bins = bin_edges;
                bin_edges = linspace(nanmin(samples)-0.2*value_range,nanmax(samples)+0.2*value_range,number_of_bins);
            end
            output = Geochemistry_Helpers.Distribution(bin_edges,"manual",histcounts(samples,bin_edges,'Normalization','Probability')');
        end        
        function output = fromJSON(filename)
            file_raw = fileread(filename);
            file_json = jsondecode(file_raw);
            
            for output_index = 1:numel(file_json)
                output(output_index) = Geochemistry_Helpers.Distribution(file_json(output_index).bin_edges,"manual",file_json(output_index).probabilities);
                output(output_index).location = file_json(output_index).location;
            end            
        end
    end
end