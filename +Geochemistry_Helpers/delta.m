classdef delta<handle&Geochemistry_Helpers.Collator&matlab.mixin.Copyable
    % delta represents isotopes ratios in delta form, with associated standards, fractions and ratios
    %
    % delta Properties
    %   value - The delta value in permille
    %   standard - The isotope ratio of the standard
    %   amount - The total concentration (needs to be proportional to other delta objects for correct addition)
    %
    % delta Properties (Dependent)
    %   ratio - The isotope ratio of the sample
    %   fraction - The isotope fraction of the sample
    %
    % delta Properties (Hidden)
    %    known_standards - A map (dictionary) of standards allowing a string->isotope ratio conversion
    %
    % delta Methods
    %   delta - Constructor.
    %   invert - Flips the isotope ratio
    %   times - Multiplies the 'number of atoms' (amount*isotope fraction) by a scalar
    %   plus - Adds a delta object and a scalar or two delta objects
    %
    % delta Origin
    %   Written by - Ross Whiteford 1st October 2020
    %   Affiliation - University of St Andrews
    %   Contact - rdmw1@st-andrews.ac.uk
    %   Licensing - Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0), https://creativecommons.org/licenses/by-nc-sa/4.0/    
    
    properties
        value = NaN;        
        standard = NaN;
        amount = 1;
    end
    properties (Dependent)
        ratio
        fraction
    end
    properties (Hidden)
        known_standards = containers.Map({'B','Boron','SRM951'},[4.04367,4.04367,4.04367]);
    end
    methods
        function self = delta(standard,value)
            % delta - Constructor
            %   input - The standard to be used, either as a string known by the known_standards map, or an isotope ratio value
            %           The delta value (optional)
            if nargin~=0
                if nargin<2
                    value = NaN;
                end
                if isstring(standard)||ischar(standard)
                    if isKey(self.known_standards,standard)
                        self.standard = self.known_standards(standard);
                    else
                        error("Unknown standard, possible values are: "+strjoin(string(keys(self.known_standards)),", "));
                    end
                else
                    self.standard = standard;
                end            
                self.value = value;
            else
                self.value = NaN;
                self.standard = NaN;
            end
        end
        
        % Getters
        function output = get.ratio(self)
            output = ((self.value/1000)+1)*self.standard;
        end
        function output = get.fraction(self)
            output = self.ratio./(self.ratio+1);
        end
        
        % Setters
        function set.ratio(self,input)
            self.value = ((input/self.standard)-1)*1000;
        end
        function set.fraction(self,input)
            self.ratio = input/(1-input);
        end
        function set.standard(self,standard)
            if isstring(standard)||ischar(standard)
                if isKey(self.known_standards,standard)
                    self.standard = self.known_standards(standard);
                else
                    error("Unknown standard, possible values are: "+strjoin(string(keys(self.known_standards)),", "));
                end
            else
                self.standard = standard;
            end
        end
        
        % Functions
        function invert(self)
        %   invert - Flips the isotope ratio
            self.ratio = 1./self.ratio;
        end
        
        % Overloading
        function output = times(input_1,input_2)
            %   times - Multiplies the 'number of atoms' (amount*isotope fraction) by a scalar
            %       input - delta object or scalar
            %               delta object or scalar
            %       output - A delta object
            if ~(isnumeric(input_1)||isnumeric(input_2))
                error("Must be multipled by scalar");
            end
            if isnumeric(input_1)
                delta_object = input_2;
                scalar_object = input_1;
            else
                delta_object = input_1;
                scalar_object = input_2;
            end
            delta_object.amount = scalar_object;
            output = delta_object;
            %output = delta(delta_object.standard,NaN);
            
            
            
            %output.fraction = delta_object.fraction.*scalar_object;
        end
        function output = plus(input_1,input_2)
        %   plus - Adds a delta object and a scalar or two delta objects
        %       input - delta object or scalar
        %               delta object or scalar
        %       output - A delta object
            if input_1.standard~=input_2.standard
                error("Must have the same standard")
            else
                output = delta(input_1.standard,NaN);
                output.fraction = (input_1.amount+input_2.amount)/(input_1.amount./input_1.fraction+input_2.amount./input_2.fraction);
                output.amount = input_1.amount+input_2.amount;
            end
        end
    end
end