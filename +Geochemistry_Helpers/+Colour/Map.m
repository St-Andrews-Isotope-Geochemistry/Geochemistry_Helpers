classdef Map < handle
    properties
        name
        colours
    end
    methods
        function self = Map(name,colour_array)
            self.name = name;
            if nargin>1
                for colour = colour_array
                    self.addColour(colour);
                end
            end
        end
        function map = interpolate(self,positions)
            original_locations = self.colours.collate("location");
            original_rgb = self.colours.collate("set_value_numeric");
            assert(issorted(original_locations),"Locations must be sorted");
            
            new_locations = positions;
            new_rgb = interp1(original_locations,original_rgb,new_locations);
            
            if numel(positions)>1
                map = Geochemistry_Helpers.Colour.Map("internal");
                for location_index = 1:numel(positions)
                    map.addColour(Geochemistry_Helpers.Colour.Colour(new_rgb(location_index,:),new_locations(location_index)));
                end
            else
                map = Geochemistry_Helpers.Colour.Colour(new_rgb,positions,"prevent");
            end
        end
        function map = getColours(self,number_of_colours)
            if any(isnan(self.colours.collate("location")))
                for colour_index = 1:numel(self.colours)
                    if isnan(self.colours(colour_index).location)
                        if colour_index==1 && isnan(self.colours(colour_index+1).location)
                            self.colours(colour_index).location = 0;
                        elseif colour_index==1
                            self.colours(colour_index).location = self.colours(colour_index+1).location-1;
                        elseif colour_index == numel(self.colours)
                            self.colours(colour_index).location = self.colours(colour_index-1).location+1;
                        elseif ~isnan(self.colours(colour_index-1).location) && ~isnan(self.colours(colour_index+1).location)
                            self.colours(colour_index).location = (self.colours(colour_index-1).location+self.colours(colour_index+1).location)/2;
                        else
                            self.colours(colour_index).location = self.colours(colour_index-1).location+1;
                        end
                    end
                end
            end
            original_locations = self.colours.collate("location");
            original_rgb = self.colours.collate("set_value");
            assert(issorted(original_locations),"Locations must be sorted");
            
            new_locations = linspace(original_locations(1),original_locations(end),number_of_colours);
            new_rgb = interp1(original_locations,original_rgb,new_locations);
            
            map = Geochemistry_Helpers.Colour.Map("internal");
            for location_index = 1:number_of_colours
                map.addColour(Geochemistry_Helpers.Colour.Colour(new_rgb(location_index,:),new_locations(location_index)));
            end
        end
        function self = addColour(self,colour,location)
            if nargin>2
                colour = Geochemistry_Helpers.Colour.Colour(colour,"prevent",location);
            end
            self.colours = [self.colours,colour];
            
            [~,sort_indices] = sort(self.colours.collate("location"));
            self.colours = self.colours(sort_indices);
        end
        function self = removeColour(self,name)
            if isstring(name)
                standardised_name = self.colours(1).standardiseName(name);
                
                same_colour = strcmp(self.colours.collate("name"),standardised_name);
                self.colours = self.colours(~same_colour);
            else
                indices = 1:numel(self.colours);
                self.colours = self.colours(indices~=name);                
            end
        end
        
        function self = asColourblind(self,type)
            for colour = self.colours
                colour.asColourblind(type);
            end
        end
        
        function output = asMatrix(self)
            output = self.colours.collate("rgb")./255;
        end
        function output = preserve(self)
            output = Geochemistry_Helpers.Colour.Map(self.name+"_derivative");
            for colour = self.colours
                output.addColour(colour.copy());
            end
        end
        
        function json_string = toJSON(self)
            json_string = "["+newline+"{"+newline+'  "'+name+'"'+":["+newline+"    ";
            for colour = self.colours
                json_string = json_string+colour.toJSON();
                if colour==self.colours(end)
                    json_string = json_string+newline+"  ";                    
                else
                    json_string = json_string+newline+"    ";
                end
            end
            json_string = json_string+"]"+newline+"}"+newline+"]";
        end
    end
end