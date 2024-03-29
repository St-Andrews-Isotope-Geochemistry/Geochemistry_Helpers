classdef Distribution < handle&Geochemistry_Helpers.Collator&matlab.mixin.Copyable
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
                    probability = zeros(numel(self.bin_edges)-1,1);
                    probability(self.bin_edges>=values(1) & self.bin_edges<values(2))=1;
                    self.probabilities = probability;
                elseif type=="gaussian" || type=="normal"
                    assert(numel(values)==2,"Number of values must be 2 (mean and standard deviation)");
                    self.bin_edges = bin_edges;
                    mu = values(1);
                    sigma = values(2);                    
                    gaussian = (1./(sigma.*sqrt(2.*pi))).*(exp(-0.5.*(((self.bin_midpoints-mu)./sigma).^2)));
                    self.probabilities = gaussian;
                elseif type=="loggaussian" || type=="lognormal"
                    assert(numel(values)==2,"Number of values must be 2 (mean and standard deviation)");
                    self.bin_edges = bin_edges;
                    mu = values(1);
                    sigma = values(2);                    
                    loggaussian = (1./(self.bin_midpoints.*sigma.*sqrt(2.*pi))).*(exp(-(((log(self.bin_midpoints)-mu).^2)./(2.*sigma.^2))));
                    self.probabilities = loggaussian;
                elseif type=="manual"
                    assert(numel(bin_edges)==numel(values)+1,"Number of elements in bin_edges must be one greater than the number of probabilities");
                    if size(bin_edges,1)==1
                        bin_edges = bin_edges';
                    end
                    if size(values,1)==1
                        values = values';
                    end
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
        function output = quantile(self,input)
            output = NaN(numel(self),numel(input));
            for value_index = 1:numel(input)
                value = input(value_index);
                for self_index = 1:numel(self)
                    cumulative_probabilities = NaN(1,numel(self(self_index).probabilities)+1);
                    cumulative_probabilities(1) = 0;
                    cumulative_probabilities(2:end) = cumsum(self(self_index).probabilities);
                    values = cumulative_probabilities-value;
                    if any(values==0)
                        output(self_index,value_index) = mean(self(self_index).bin_midpoints(values==0));
                    elseif any(isnan(values))
                        output(self_index,value_index) = NaN;
                    else
                        output(self_index,value_index) = self.piecewiseInterpolate(cumulative_probabilities',self(self_index).bin_edges,value);
                    end
                end
            end
        end
        function self = normalise(self,value)
            assert(sum(self.probabilities)~=0,"Sum of probabilities can not be 0");
            if nargin<2
                value = 1;
            end
            self.probabilities = value.*(self.probabilities/sum(self.probabilities));
        end
        function self = limit(self,limits)
            assert(numel(limits)==2,"Must have array of lower and upper limit");
            
            if ~isnan(limits(1)) && ~isnan(limits(2))
                assert(limits(2)>limits(1),"Limits must be in ascending order");
                self.probabilities(self.bin_midpoints<limits(1) | self.midpoints>limits(2)) = 0;
            elseif isnan(limits(1))
                self.probabilities(self.bin_midpoints>limits(2)) = 0;
            elseif isnan(limits(2))
                self.probabilities(self.bin_midpoints<limits(1)) = 0;
            end
        end
        function self = truncate(self,value)
            self.probabilities(self.probabilities<=value) = 0;
        end
        
        function output = mean(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = sum(self(self_index).bin_midpoints.*self(self_index).probabilities);
            end
        end
        function output = median(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = self(self_index).quantile(0.5);
            end
        end
        function output = standard_deviation(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = sqrt(sum((self(self_index).bin_midpoints-self(self_index).mean()).^2 .*self(self_index).probabilities));
            end
        end
        function output = variance(self)
            output = NaN(numel(self),1);
            for self_index = 1:numel(self)
                output(self_index) = (sum((self(self_index).bin_midpoints-self(self_index).mean()).^2 .*self(self_index).probabilities));
            end
        end
        
        function output = getProbability(self,value)
            for value_index = 1:size(value,2)
                for self_index = 1:numel(self)
                    output(self_index,value_index) = self.piecewiseInterpolate(self(self_index).bin_midpoints,self(self_index).probabilities,value(self_index,value_index));
                end
            end
            
%             figure(1);
%             clf
%             hold on
%             
%             for self_index = 1:numel(self)
%             clf
%             hold on
%                 self_index = 6;
%                 self(self_index).plot();
%                 plot(value(self_index),output(self_index),'x');
%             end
        end
        function output = likelihoodFromQuantiles(self,values)
            x = self.quantile(values);
            output = self.getProbability(x);
        end
        
        function output = approximateGaussian(self,inflation)
            if nargin<2
                inflation = 1;
            end
            if numel(inflation)==1
                inflation = repelem(inflation,1,numel(self));
            end
            for self_index = 1:numel(self)
                output(self_index) = Geochemistry_Helpers.Distribution(self(self_index).bin_edges,"Gaussian",[self(self_index).mean(),self(self_index).standard_deviation()*inflation(self_index)]).normalise();
                output(self_index).location = self(self_index).location;
            end
        end
        function self = smooth(self,widths,preserves)
            if nargin<2
                widths = 3;
            end
            if nargin<3
                preserves = 0.5;
            end
            if numel(widths)==1 && numel(preserves)>1
                widths = repelem(widths,numel(preserves));
            elseif numel(preserves)==1 && numel(widths)>1
                preserves = repelem(preserves,numel(widths));
            end
            assert(numel(widths)==numel(preserves),"Number of widths must be equal to number of preserves unless one is scalar");
            
            for repeat_index = 1:numel(widths)
                width = widths(repeat_index);
                preserve = preserves(repeat_index);
                
                assert(mod(width,2)~=0,"Width must be odd");
                assert(preserve>=0 && preserve<=1,"Preserve must be between 0 and 1");
                half_width = floor(width/2);
                for self_index = 1:numel(self)
                    probabilities = self(self_index).probabilities;
                    output = NaN(size(self(self_index).probabilities));
                    output(1:half_width) = self(self_index).probabilities(1);
                    output(end-half_width:end) = self(self_index).probabilities(end);
                    for probability_index = half_width+1:numel(self(self_index).probabilities)-half_width-1
                        difference = abs([self(self_index).probabilities(probability_index-half_width:probability_index-1);self(self_index).probabilities(probability_index+1:probability_index+half_width)]-self(self_index).probabilities(probability_index));
                        if all(difference==0)
                            difference_fraction = zeros(width-1,1);
                        else
                            if self(self_index).probabilities(probability_index)~=0
                                difference_fraction = difference/self(self_index).probabilities(probability_index);
                            elseif mean(self(self_index).probabilities(probability_index-1:probability_index+1))~=0
                                difference_fraction = difference/mean(self(self_index).probabilities(probability_index-half_width:probability_index+half_width));
                            end
                        end
                        weight = ((1-preserve)/(width-1))./(1+exp((-50).*(1-difference_fraction-0.75)));
                        output(probability_index) = [weight(1:half_width)',1-sum(weight),weight(half_width+1:end)']*self(self_index).probabilities(probability_index-half_width:probability_index+half_width);
                    end
                    self(self_index).probabilities = output;
                    self(self_index).normalise();
                end
            end
        end
        
        % Display
        function self = plot(self,varargin)
            for self_index = 1:numel(self)
                plot(self(self_index).bin_midpoints,self(self_index).probabilities,varargin{:});
            end
        end
        function self = area(self,varargin)
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
        function output = toStruct(self)
            for self_index = 1:numel(self)
                output(self_index).location = self(self_index).location;
                output(self_index).bin_edges = self(self_index).bin_edges;
                output(self_index).probabilities = self(self_index).probabilities;
            end
        end
       
    end
    methods (Static)
        function output = fromSamples(bin_edges,samples)
            if isempty(bin_edges) || (numel(bin_edges)==1 && isnan(bin_edges))
                value_range = max(samples)-min(samples);
                bin_edges = linspace(min(samples,[],'omitnan')-0.2*value_range,max(samples,[],'omitnan')+0.2*value_range,101);
            elseif isscalar(bin_edges)
                value_range = max(samples)-min(samples);
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
        function output = piecewiseInterpolate(x,y,xq)
            if any(x==xq) && sum(x==xq)==1
                output = y(x==xq);
            else
                signed_distance = xq-x;
                distance_sign = sign(signed_distance);
                distance_sign(distance_sign<0) = 0;
                crossover = logical(distance_sign(1:end-1)-distance_sign(2:end))';
                distances = abs([signed_distance([crossover,false]),signed_distance([false,crossover])]);
                weights = 1-(distances*(1/sum(distances)));
                values =  [y([crossover,false]),y([false,crossover])];
                output = weights*values';
            end
        end
    end
end