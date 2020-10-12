classdef pX<handle&Collater&matlab.mixin.Copyable
    % pX represents a value and its corresponding p value (-log10(value))
    %
    % pX Properties
    %   pValue - -log10(value), defaults to NaN
    % pX Properties (Dependent)
    %   value - 10^(-pValue)
    %
    % pX Methods
    %   + (plus) - Adds the values a pX object and a scalar or two pX objects
    %   - (minus) - Subtracts the values of a pX object and a scalar or two pX objects
    %
    % pX Origin
    %   Written by - Ross Whiteford 1st October 2020
    %   Affiliation - University of St Andrews
    %   Contact - rdmw1@st-andrews.ac.uk
    %   Licensing - Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0), https://creativecommons.org/licenses/by-nc-sa/4.0/    
    properties
        pValue = NaN
    end
    properties (Dependent)
        value
    end
    methods
        % Constructor
        function self = pX(pValue)
            if nargin<1
                self.pValue = NaN;
            else
                self.pValue = pValue;
            end
        end
        
        % Setter and getter
        function set.value(self,input)
            self.pValue = -log10(input);
        end
        function output = get.value(self)
            output = 10.^(-self.pValue);
        end
        
        % Overrides
        function output = plus(input_1,input_2)
            % 
            if isnumeric(input_1)||isnumeric(input_2)
                if isnumeric(input_1)
                    number_object = input_1;
                    p_object = input_2;
                else
                    number_object = input_2;
                    p_object = input_1;
                end
                output = pX(p_object.pValue+number_object);
            elseif isa(input_1,"pX") && isa(input_2,"pX")
                output = pX(NaN);
                output.value = input_1.value+input_2.value;
            end
        end
        function output = minus(input_1,input_2)
            if isnumeric(input_1)||isnumeric(input_2)
                if isnumeric(input_1)
                    number_object = input_1;
                    p_object = input_2;
                else
                    number_object = input_2;
                    p_object = input_1;
                end
                output = pX(p_object.pValue-number_object);
            elseif isa(input_1,"pX") && isa(input_2,"pX")
                output = pX(NaN);
                output.value = input_1.value-input_2.value;
            end
        end
    end
end