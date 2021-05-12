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
            size_of = num2cell(size(self));
            size_of_parameter = num2cell(size(self(1).(parameter)));
            if numel(self(1).(parameter))>1
                collapsed_size = [size_of{:},size_of_parameter{:}];
                nonsingleton_collapsed_size = num2cell(collapsed_size(collapsed_size~=1));
                if numel(nonsingleton_collapsed_size)==1
                    nonsingleton_collapsed_size{2} = 1;
                end
                if isnumeric(self(1).(parameter))
                    output(nonsingleton_collapsed_size{:}) = NaN;
                    output(:) = NaN;
                end
                for index = 1:numel(self)
                    output(index,:) = self(index).(parameter);
                end
            else
                output(size_of{:},size_of_parameter{:}) = self(1).(parameter);
                for index = 1:numel(self)
                    output(index) = self(index).(parameter);
                end
            end
        end
        function output = flatten(self)
            %   flatten - Reshapes an array so all but one dimension is
            %   singleton
            %       input - axis, the direction to stack in, not
            %       implemented yet
            %       output - Is an array of objects
            if nargin<2
                axis = 1;
            end
            number_of_elements = ones(1,numel(size(self)));
            number_of_elements(axis) = numel(self);
            
            output = reshape(self,number_of_elements);
        end
        function assignToAll(self,parameter,value)
            %   assignToAll - Iterates over an array of objects to assign a value or object to the specified property
            %       input - The name of the parameter to assign to as a string
            %               The value/object to assign to the parameter
            for index = 1:numel(self)
                if isnumeric(value) || isstring(value)
                    self(index).(parameter) = value;
                else
                    try
                        self(index).(parameter) = copy(value);
                    catch
                        self(index).(parameter) = value;
                    end
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
        function output = create(self,number)
            class_name = string(class(self));
            number_cell = num2cell(number);
            output(number_cell{:}) = eval(class_name+"();");
            for index = 1:prod(number)
                output(index) = eval(class_name+"();");
            end
        end
    end
end
