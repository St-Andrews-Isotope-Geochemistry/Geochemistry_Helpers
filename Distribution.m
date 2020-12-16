classdef Distribution < handle&Collator
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
                else
                    error("Type unknown");
                end
            end
        end
        
        % 
        function self = normalise(self)
            self.probabilities = self.probabilities/sum(self.probabilities);
        end
        function plot(self)
            plot(self.bin_midpoints,self.probabilities);
        end
        
        % Setters and Getters
        function set.bin_midpoints(self,value)
            error("Can't set directly");
        end
        function midpoints = get.bin_midpoints(self)
            midpoints = self.bin_edges(1:end-1) + 0.5*(self.bin_edges(2:end)-self.bin_edges(1:end-1));
        end
    end
    methods (Static)
        function output = create(type,value)
            output = Distribution(type,value);
        end
    end
end