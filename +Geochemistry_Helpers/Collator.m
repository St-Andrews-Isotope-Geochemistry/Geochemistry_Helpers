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
            
            % Make necessary checks
            output_size = size(self(1).(parameter));
            if isnumeric(self(1).(parameter))
                output_type = 1;
            elseif isstring(self(1).(parameter))
                output_type = 2;
            elseif isdatetime(self(1).(parameter))
                output_type = 3;
            else
                output_type = 4;
            end
            for self_index = 1:numel(self)
                assert(all(size(self(self_index).(parameter))==output_size),"Requested parameters have variable size");
                if output_type==1
                    assert(isnumeric(self(self_index).(parameter)),"Requested parameters are of different type");
                elseif output_type==2
                    assert(isstring(self(self_index).(parameter)),"Requested parameters are of different type");
                elseif output_type==3
                    assert(isdatetime(self(self_index).(parameter)),"Requested parameters are of different type");
                elseif output_type==4
                    % Assume a random object
                end
            end
            
            
            % Define the metadata
            original_size_cell = num2cell(size(self));
            output_size_cell = num2cell(output_size);
            
%             size_of = num2cell(size(self));
%             size_of_parameter = num2cell(size(self(1).(parameter)));
%             if numel(self(1).(parameter))>1
%                 collapsed_size = [size_of{:},size_of_parameter{:}];
%                 nonsingleton_collapsed_size = num2cell(collapsed_size(collapsed_size~=1));
%                 if numel(nonsingleton_collapsed_size)==1
%                     nonsingleton_collapsed_size{2} = 1;
%                 end
%                 if isnumeric(self(1).(parameter))
%                     output(nonsingleton_collapsed_size{:}) = NaN;
%                     output(:) = NaN;
%                 end
%                 for index = 1:numel(self)
%                     output(index,:) = self(index).(parameter);
%                 end
%             else
%                 output(size_of{:},size_of_parameter{:}) = self(1).(parameter);
%                 for index = 1:numel(self)
%                     output(index) = self(index).(parameter);
%                 end
%             end

            % First flatten the array, then collate, then reshape
            flattened = self.flatten;
            if output_type==1
                flat_output = NaN(numel(flattened),output_size_cell{:});
            elseif output_type==4
            end
            
            for self_index = 1:numel(self)
                flat_output(self_index,:) = self(self_index).(parameter);
            end
            output = squeeze(reshape(flat_output,original_size_cell{:},output_size_cell{:}));
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
        function self = assignToAll(self,parameter,value)
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
        function self = assignToEach(self,parameter,values)
            %   assignToEach - Iterates over an array of objects and an array of values or objects to assign the latter to the former
            %       input - The name of the parameter to assign to as a string
            %               The array of values/objects to assign to the parameter (must be the same length as the number of Boron_pH objects).
            if size(values,1)>1
                assert(numel(self)==size(values,1),"Number of objects must equal the number of input values");
            else
                assert(numel(self)==numel(values),"Number of objects must equal the number of input values");
            end
            for index = 1:numel(self)
                if all(isnumeric(values))
                    if size(values,1)>1
                        self(index).(parameter) = values(index,:);
                    else
                        self(index).(parameter) = values(index);
                    end
                else
                    self(index).(parameter) = copy(values(index));
                end
            end
        end
        function output = create(self,number)
%             class_name = string();
            if numel(number)==1
                number = [number,1];
            end
            number_cell = num2cell(number);
            output(number_cell{:}) = feval(class(self));
            for index = 1:prod(number)
                output(index) = feval(class(self));
            end
        end
        
        function number = numArgumentsFromSubscript(self,request,indexingContext)
            number = 1;
        end
        function varargout = subsref(self,request)
                switch request(1).type
                    case '.'
                        request_string = request(1).subs;
                        if (numel(self)>1 && isprop(self(1),request_string))
                            collated = self.collate(request_string);
                            if size(request(2:end),2)>0
                                varargout = {subsref(collated,request(2:end))};
                            else
                                varargout = {collated};
                            end
                            return
                        else
                            varargout = {builtin('subsref',self,request)};
                            if iscell(varargout{1})
                                varargout = varargout{:};
                            end
                            return
                        end
                    case '()'
                        collated = builtin('subsref',self,request(1));
                        if size(request(2:end),2)>0
                            varargout = {subsref(collated,request(2:end))};
                        else
                            varargout = {collated};
                        end
                        return
                end
            try
                [varargout{1:nargout}] = builtin('subsref',self,request);
                return
            catch
                builtin('subsref',self,request);
                return
            end
        end
    end
end
