classdef Collator<handle
    % Collator allows properties of objects to be collected into an array, and is built to be inherited from only
    %
    % Collator Properties
    %   None
    %
    % Collator Methods
    %   collate - Iterates over an array of objects to extract the specified property
    %   assignToAll - Iterates over an array of objects to assign a value or object to the specified property
    %   assignToEach - Iterates over an array of objects and an array of values or objects to assign the latter to the former
    %
    % Collator Origin
    %   Written by - Ross Whiteford 1st October 2020
    %   Affiliation - University of St Andrews
    %   Contact - rdmw1@st-andrews.ac.uk
    %   Licensing - Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0), https://creativecommons.org/licenses/by-nc-sa/4.0/
    properties
    end
    methods
        function output = collate(self,parameter)
            %   collate - Iterates over an array of objects to extract the specified property
            %       input - The name of the parameter to extract as a string
            %       output - Is an array of values or objects
            output = [];
            for index = 1:numel(self)
                output = [output,self(index).(parameter)];
            end
        end
        function assignToAll(self,parameter,value)
            %   assignToAll - Iterates over an array of objects to assign a value or object to the specified property
            %       input - The name of the parameter to assign to as a string
            %               The value/object to assign to the parameter
            for index = 1:numel(self)
                if isnumeric(value)
                    self(index).(parameter) = value;
                else
                    self(index).(parameter) = copy(value);
                end
            end
        end
        function assignToEach(self,parameter,values)
            %   assignToEach - Iterates over an array of objects and an array of values or objects to assign the latter to the former
            %       input - The name of the parameter to assign to as a string
            %               The array of values/objects to assign to the parameter (must be the same length as the number of Boron_pH objects).
            assert(numel(self)==numel(values),"Number of objects must equal the number of input values");
            for index = 1:numel(self)
                if isnumeric(values)
                    self(index).(parameter) = values(index);
                else
                    self(index).(parameter) = copy(values(index));
                end
            end
        end
    end
end
