classdef Colour < handle&Geochemistry_Helpers.Collator&matlab.mixin.Copyable
    properties
        location
        name
        rgb
        ryb
        hsv
        
        space
    end
    properties (Hidden=true,Dependent=true)
        available
        as_map
        RGB
        RYB
        ryb_cube
    end
    properties (Hidden=true)
        hue
        set_value
        set_value_numeric
        ryb_weight_function = @(d,A,B) A + d*(B-A);
        rgb_weight_function = @(d,A,B) A + d*(B-A);
%         polar_map = [0,60,120,180,240,300,360;
%                      1, 1,  0,  0,  0,  1,  1;
%                      0, 1,  1,  1,  0,  0,  0;
%                      0, 0,  0,  1,  1,  1,  0]';
        colours = {
                   "mediumvioletred",     [199, 21,133]
                   "deeppink",            [255, 20,147]
                   "palevioletred",       [219,112,147]
                   "hotpink",             [255,105,180]
                   "lightpink",           [255,182,193]
                   "pink",                [255,192,203]
                   "darkred",             [139,  0,  0]
                   "red",                 [255,  0,  0]
                   "firebrick",           [178, 34, 34]
                   "crimson",             [220, 20, 60]
                   "indianred",           [205, 92, 92]
                   "lightcoral",          [240,128,128]
                   "salmon",              [250,128,114]
                   "darksalmon",          [233,150,122]
                   "lightsalmon",         [255,160,122]
                   "orangered",           [255, 69,  0]
                   "tomato",              [255, 99, 71]
                   "darkorange",          [255,140,  0]
                   "coral",               [255,127, 80]
                   "orange",              [255,165,  0]
                   "darkkhaki",           [189,183,107]
                   "gold",                [255,215,  0]
                   "khaki",               [240,230,140]
                   "peachpuff",           [255,218,185]
                   "yellow",              [255,255,  0]
                   "palegoldenrod",       [238,232,170]
                   "moccasin",            [255,228,181]
                   "papayawhip",          [255,239,213]
                   "lightgoldenrodyellow",[250,250,210]
                   "lemonchiffon",        [255,250,205]
                   "lightyellow",         [255,255,224]
                   "maroon",              [128,  0,  0]
                   "brown",               [165, 42, 42]
                   "saddlebrown",         [139, 69, 19]
                   "sienna",              [160, 82, 45]
                   "chocolate",           [210,105, 30]
                   "darkgoldenrod",       [184,134, 11]
                   "peru",                [205,133, 63]
                   "rosybrown",           [188,143,143]
                   "goldenrod",           [218,165, 32]
                   "sandybrown",          [244,164, 96]
                   "tan",                 [210,180,140]
                   "burlywood",           [222,184,135]
                   "wheat",               [245,222,179]
                   "navajowhite",         [255,222,173]
                   "bisque",              [255,228,196]
                   "blanchedalmond",      [255,235,205]
                   "cornsilk",            [255,248,220]
                   "darkgreen",           [  0,100,  0]
                   "green",               [  0,128,  0]
                   "darkolivegreen",      [ 85,107, 47]
                   "forestgreen",         [ 34,139, 34]
                   "seagreen",            [ 46,139, 87]
                   "olive",               [128,128,  0]
                   "olivedrab",           [107,142, 35]
                   "mediumseagreen",      [ 60,179,113]
                   "limegreen",           [ 50,205, 50]
                   "lime",                [  0,255,  0]
                   "springgreen",         [  0,255,127]
                   "mediumspringgreen",   [  0,250,154]
                   "darkseagreen",        [143,188,143]
                   "mediumaquamarine",    [102,205,170]
                   "yellowgreen",         [154,205, 50]
                   "lawngreen",           [124,252,  0]
                   "chartreuse",          [127,255,  0]
                   "lightgreen",          [144,238,144]
                   "greenyellow",         [173,255, 47]
                   "palegreen",           [152,251,152]
                   "teal",                [  0,128,128]
                   "darkcyan",            [  0,139,139]
                   "lightseagreen",       [ 32,178,170]
                   "cadetblue",           [ 95,158,160]
                   "darkturquoise",       [  0,206,209]
                   "mediumturquoise",     [ 72,209,204]
                   "turquoise",           [ 64,224,208]
                   "aqua",                [  0,255,255]
                   "cyan",                [  0,255,255]
                   "aquamarine",          [127,255,212]
                   "paleturquoise",       [175,238,238]
                   "lightcyan",           [224,255,255]
                   "navy",                [  0,  0,128]
                   "darkblue",            [  0,  0,139]
                   "mediumblue",          [  0,  0,205]
                   "blue",                [  0,  0,255]
                   "midnightblue",        [ 19, 19, 70]
                   "royalblue",           [ 65,105,225]
                   "steelblue",           [ 70,130,180]
                   "dodgerblue",          [ 30,144,255]
                   "deepskyblue",         [  0,191,255]
                   "cornflowerblue",      [100,149,237]
                   "skyblue",             [135,206,235]
                   "lightskyblue",        [135,206,250]
                   "lightsteelblue",      [176,196,222]
                   "lightblue",           [173,216,230]
                   "powderblue",          [176,224,230]
                   "indigo",              [ 75,  0,130]
                   "purple",              [128,  0,128]
                   "darkmagenta",         [139,  0,139]
                   "darkviolet",          [148,  0,211]
                   "darkslateblue",       [ 72, 61,139]
                   "blueviolet",          [138, 43,226]
                   "darkorchid",          [153, 50,204]
                   "fuschia",             [255,  0,255]
                   "magenta",             [255,  0,255]
                   "slateblue",           [106, 90,205]
                   "mediumslateblue",     [123,104,238]
                   "mediumorchid",        [186, 85,211]
                   "mediumpurple",        [147,112,219]
                   "orchid",              [218,112,214]
                   "violet",              [238,130,238]
                   "plum",                [221,160,221]
                   "thistle",             [216,191,216]
                   "lavender",            [230,230,250]
                   "mistyrose",           [255,228,225]
                   "antiquewhite",        [250,235,215]
                   "linen",               [250,240,230]
                   "beige",               [245,245,220]
                   "whitesmoke",          [245,245,245]
                   "lavenderblush",       [255,240,245]
                   "oldlace",             [253,245,230]
                   "aliceblue",           [240,248,255]
                   "seashell",            [255,245,238]
                   "ghostwhite",          [248,248,255]
                   "honeydew",            [240,255,240]
                   "floralwhite",         [255,250,240]
                   "azure",               [240,255,255]
                   "mintcream",           [245,255,250]
                   "snow",                [255,250,250]
                   "ivory",               [255,255,240]
                   "white",               [255,255,255]
                   "black",               [  0,  0,  0]
                   "darkslategrey",       [ 47, 79, 79]
                   "dimgrey",             [105,105,105]
                   "slategrey",           [112,128,144]
                   "gray",                [128,128,128]
                   "lightslategrey",      [119,136,153]
                   "darkgrey",            [169,169,169]
                   "silver",              [192,192,192]
                   "lightgrey",           [211,211,211]
                   "gainsboro",           [220,220,220]
        };
    end
    methods
        % Constructor
        function self = Colour(colour,space,location)
            if nargin<3
                location = NaN;
            end
            if nargin<2
                space = "rgb";
            end
            
            self.set_value = colour;
            if isstring(colour)
                name = self.standardiseName(colour);
                assert(isKey(self.as_map,name),"Unknown colour")
                self.name = name;
                
                self.RGB = self.as_map(self.name);
                self.set_value_numeric = self.rgb;
                if ~strcmp(space,"prevent")
                    self.hsv = self.rgbTohsv(self.rgb);
                    self.ryb = self.rgbToryb(self.rgb);
                end
            else
                self.name = "custom";
                if strcmp(space,"rgb")
                    self.rgb = colour;
                    self.set_value_numeric = self.rgb;
                    if ~strcmp(space,"prevent")
                        self.hsv = self.rgbTohsv(self.rgb);
                        self.ryb = self.rgbToryb(self.rgb);
                    end
                elseif strcmp(space,"hsv")
                    self.hsv = colour;
                    self.hue = colour(1);
                    self.set_value_numeric = self.hsv;
                    if ~strcmp(space,"prevent")
                        self.rgb = self.hsvTorgb(self.hsv);
                        self.ryb = self.rgbToryb(self.rgb);
                    end
                elseif strcmp(space,"ryb")
                    self.ryb = colour;
                    self.set_value_numeric = self.ryb;
                    if ~strcmp(space,"prevent")
                        self.rgb = self.rybTorgb(self.ryb);
                        self.hsv = self.rgbTohsv(self.rgb);
                    end
                elseif strcmp(space,"prevent")
                    self.set_value_numeric = colour;
                end
            end
            self.location = location;
            self.space = space;
        end
        
        function setSpace(self,space)
            if any(strcmpi(["rgb","ryb","hsv"],space))
                self.space = lower(space);
            else
                error("Unknown space - should be rgb, ryb or hsv");
            end
        end        
        function rxb = interpolateAngle(self,angle)
            c = self.getPolarMap.interpolate(angle);
            r = c.set_value(1);
            x = c.set_value(2);
            b = c.set_value(3);
            
            rxb = [r,x,b];
        end

        % Operations
        function self = desaturate(self,amount)
            polar = self.toPolar();
            polar(2) =self.clamp([0,1],polar(2).*(1/amount));
            self.fromPolar(polar);
        end
        function self = saturate(self,amount)
            polar = self.toPolar();
            polar(2) = self.clamp([0,1],polar(2).*amount);
            self.fromPolar(polar);
        end
        function self = setSaturation(self,saturation)
            polar = self.toPolar();
            polar(2) = self.clamp([0,polar(3)],self.clamp([0,1],saturation));
            self.fromPolar(polar);
        end
        function self = darken(self,amount)
            polar = self.toPolar();
            polar(3) = self.clamp([0,1],polar(3).*(1/amount));
            self.fromPolar(polar);
        end
        function self = lighten(self,amount)
            polar = self.toPolar();
            [polar(3),leftover] = self.clamp([0,1],polar(3).*amount);
            [polar(2),~] = self.clamp([0,1],polar(2)-leftover);
            self.fromPolar(polar);
        end
        function self = setBrightness(self,brightness)
            polar = self.toPolar();
            [polar(3),leftover] = self.clamp([0,1],brightness);
            [polar(2),~] = self.clamp([0,1],polar(2)-leftover);
            self.fromPolar(polar);
        end
        function self = rotate(self,angle)
            polar = self.toPolar();
            polar(1) = mod(polar(1)+angle,360);
            self.fromPolar(polar);
        end
        function self = setHue(self,hue)
            polar = self.toPolar();
            polar(1) = mod(hue,360);
            self.fromPolar(polar);
        end
        
        function map = makePalette(self,type,number)
            if strcmp(type,"monochrome")
                if ~strcmp(self.space,"ryb")
                    light = linspace(0,2,number);
                else
                    light = linspace(-1,1,number);
                end
                for index = 1:number
                    colours(index) = self.preserve().setBrightness(light(index));
                end
                map = Geochemistry_Helpers.Colour.Map("monochrome",colours);            
            elseif strcmp(type,"complementary")
                assert(nargin<3 || number==2,"For complementary requested number of colours must be unspecified or 2")
                map = Geochemistry_Helpers.Colour.Map("complementary",[self.preserve(),self.complementary()]);
            elseif strcmp(type,"triad")
                assert(nargin<3 || number==3,"For triad requested number of colours must be unspecified or 3")
                map = Geochemistry_Helpers.Colour.Map("triad",[self.preserve(),self.preserve().rotate(120),self.preserve().rotate(240)]);
            elseif strcmp(type,"tetrad")
                assert(nargin<3 || number==4,"For tetrad requested number of colours must be unspecified or 4")
                map = Geochemistry_Helpers.Colour.Map("triad",[self.preserve(),self.preserve().rotate(45),self.preserve().rotate(180),self.preserve().rotate(45+180)]);
            elseif strcmp(type,"square")
                assert(nargin<3 || number==4,"For square requested number of colours must be unspecified or 4")
                map = Geochemistry_Helpers.Colour.Map("triad",[self.preserve(),self.preserve().rotate(90),self.preserve().rotate(180),self.preserve().rotate(270)]);
            elseif strcmp(type,"analogous")
                assert(nargin<3 || number==3,"For analogous requested number of colours must be unspecified or 3")
                map = Geochemistry_Helpers.Colour.Map("analogous",[self.preserve().rotate(-30),self.preserve(),self.preserve().rotate(30)]);
            elseif strcmp(type,"split-complementary")
                assert(nargin<3 || number==4,"For split-complementary requested number of colours must be unspecified or 4")
                map = Geochemistry_Helpers.Colour.Map("split-complementary",[self.preserve().rotate(-15),self.preserve().rotate(+15),self.preserve().rotate(-15+180),self.preserve().rotate(+15+180)]);
            elseif strcmp(type,"around")
                angle_addition = linspace(0,360,number);
                polar = self.toPolar();
                angles = mod(polar(1)+angle_addition,360);
                for angle_index = 1:numel(angles)
                    colours(angle_index) = self.preserve().setHue(angles(angle_index));
                end
                map = Geochemistry_Helpers.Colour.Map("around",colours);
            end
        end
        function self = asColourblind(self,type)
            self.removeGammaCorrection();
            switch lower(type)
                case "protanopia"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getProtanopiaMatrix()*self.getrgblmsMatrix()*self.rgb')');
                case "deutranopia"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getDeutranopiaMatrix()*self.getrgblmsMatrix()*self.rgb')');
                case "tritanopia"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getTritanopiaMatrix()*self.getrgblmsMatrix()*self.rgb')');
                case "monochromatism_red"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getMonochromatismRedMatrix()*self.getrgblmsMatrix()*self.rgb')');
                case "monochromatism_blue"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getMonochromatismGreenMatrix()*self.getrgblmsMatrix()*self.rgb')');
                case "monochromatism_green"
                    [rgb,~] = self.clamp([0,1],(self.getlmsrgbMatrix()*self.getMonochromatismBlueMatrix()*self.getrgblmsMatrix()*self.rgb')');
            end
            self.rgb = rgb;
            self.applyGammaCorrection();
        end
        
        function output = complementary(self)
            output = self.preserve().rotate(180);
        end        
        function output = preserve(self)
            output = Geochemistry_Helpers.Colour.Colour(self.set_value,self.space,self.location);
        end
        
        % Conversions
        function polar = toPolar(self)
            if strcmp(self.space,"hsv")
                % Already polar
            elseif strcmp(self.space,"rgb")
                if numel(unique(self.rgb))==3
                    if max(self.rgb)==self.rgb(1)
                        if min(self.rgb)==self.rgb(2)
                            angle = 300+60*((self.rgb(1)-self.rgb(3))/(self.rgb(1)-self.rgb(2)));
                        elseif min(self.rgb)==self.rgb(3)
                            angle = 0+60*(1-((self.rgb(1)-self.rgb(2))/(self.rgb(1)-self.rgb(3))));
                        end
                    elseif max(self.rgb)==self.rgb(2)
                        if min(self.rgb)==self.rgb(1)
                            angle = 120+60*(1-((self.rgb(2)-self.rgb(3)))/(self.rgb(2)-self.rgb(1)));
                        elseif min(self.rgb)==self.rgb(3)
                            angle = 60+60*((self.rgb(2)-self.rgb(1))/(self.rgb(2)-self.rgb(3)));
                        end
                    elseif max(self.rgb)==self.rgb(3)
                        if min(self.rgb)==self.rgb(1)
                            angle = 180+60*((self.rgb(3)-self.rgb(2))/(self.rgb(3)-self.rgb(1)));
                        elseif min(self.rgb)==self.rgb(2)
                            angle = 240+60*(1-((self.rgb(3)-self.rgb(1)))/(self.rgb(3)-self.rgb(2)));
                        end
                    end
%                     brightness = max(self.rgb);
%                     saturation = max(self.rgb)-min(self.rgb);
                elseif numel(unique(self.rgb))==2
                    if self.rgb(1)==self.rgb(2)
                        if self.rgb(1)==min(self.rgb)
                            angle = 240;
                        else
                            angle = 60;
                        end
                    elseif self.rgb(2)==self.rgb(3)
                        if self.rgb(2)==min(self.rgb)
                            angle = 0;
                        else
                            angle = 180;
                        end
                    elseif self.rgb(1)==self.rgb(3)
                        if self.rgb(3)==min(self.rgb)
                            angle = 120;
                        else
                            angle = 300;
                        end
                    end
                    
%                     brightness = max(self.rgb);
%                     saturation = max(self.rgb)-min(self.rgb);
                elseif numel(unique(self.rgb))==1
                    if ~isnan(self.hue)
                        angle = self.hue;
                    else
                        angle = 0;
                    end
                end
                brightness = max(self.rgb);
                if max(self.rgb)~=0
                    saturation = (max(self.rgb)-min(self.rgb))/max(self.rgb);
                else
                    saturation = 0;
                end
                polar = [angle,saturation,brightness];
            elseif strcmp(self.space,"ryb")                
                if numel(unique(self.ryb))==3
                    if max(self.ryb)==self.ryb(1)
                        if min(self.ryb)==self.ryb(2)
                            angle = 300+60*((self.ryb(1)-self.ryb(3))/(self.ryb(1)-self.ryb(2)));
                        elseif min(self.ryb)==self.ryb(3)
                            angle = 0+60*(1-((self.ryb(1)-self.ryb(2))/(self.ryb(1)-self.ryb(3))));
                        end
                    elseif max(self.ryb)==self.ryb(2)
                        if min(self.ryb)==self.ryb(1)
                            angle = 120+60*(1-((self.ryb(2)-self.ryb(3)))/(self.ryb(2)-self.ryb(1)));
                        elseif min(self.ryb)==self.ryb(3)
                            angle = 60+60*((self.ryb(2)-self.ryb(1))/(self.ryb(2)-self.ryb(3)));
                        end
                    elseif max(self.ryb)==self.ryb(3)
                        if min(self.ryb)==self.ryb(1)
                            angle = 180+60*((self.ryb(3)-self.ryb(2))/(self.ryb(3)-self.ryb(1)));
                        elseif min(self.ryb)==self.ryb(2)
                            angle = 240+60*(1-((self.ryb(3)-self.ryb(1)))/(self.ryb(3)-self.ryb(2)));
                        end
                    end
                elseif numel(unique(self.ryb))==2
                    if self.ryb(1)==self.ryb(2)
                        if self.ryb(1)==min(self.ryb)
                            angle = 240;
                        else
                            angle = 60;
                        end
                    elseif self.ryb(2)==self.ryb(3)
                        if self.ryb(2)==min(self.ryb)
                            angle = 0;
                        else
                            angle = 180;
                        end
                    elseif self.ryb(1)==self.ryb(3)
                        if self.ryb(3)==min(self.ryb)
                            angle = 120;
                        else
                            angle = 300;
                        end
                    end
                elseif numel(unique(self.ryb))==1
                    if ~isnan(self.hue)
                        angle = self.hue;
                    else
                        angle = 0;
                    end
                end
                brightness = 1-max(self.ryb);
                if max(self.ryb)~=0
                    saturation = (max(self.ryb)-min(self.ryb))/max(self.ryb);
                else
                    saturation = 0;
                end
                polar = [angle,saturation,brightness];
            end
        end
        function fromPolar(self,polar)
            if strcmp(self.space,"rgb")
                relative = self.interpolateAngle(polar(1));
                range = polar(2)*polar(3);
                minimum = polar(3)-range;
                
                scaled = relative.*range;
                moved = scaled+minimum;
                
                rgb = moved;
                
                self.rgb = rgb;
                self.hsv = self.rgbTohsv(self.rgb);
                self.ryb = self.rgbToryb(self.rgb);
            elseif strcmp(self.space,"ryb")
                relative = self.interpolateAngle(polar(1));
                range = polar(2)*(1-polar(3));
                minimum = (1-polar(3))-range;
                
                scaled = relative.*range;
                moved = scaled+minimum;
                ryb = moved;
                
                self.ryb = ryb;
                self.rgb = self.rybTorgb(self.ryb);
                self.hsv = self.rgbTohsv(self.rgb);
            elseif strcmp(self.space,"hsv")
                self.name = "custom";
                self.hsv = polar;
                self.rgb = self.hsvTorgb(self.hsv);
                self.ryb = self.rgbToryb(self.rgb);
            end
        end
        function ryb = rgbToryb(self,rgb)
            ryb = self.rgbTorybCube(rgb,self.getrybCube,self.rgb_weight_function);
        end
        function rgb = rybTorgb(self,ryb)
            rgb = self.rybTorgbCube(ryb,self.getrgbCube,self.ryb_weight_function);
        end        
        function removeGammaCorrection(self)
            condition = self.rgb<=0.04045;
            self.rgb(condition) = self.rgb(condition)/12.92;
            self.rgb(~condition) = ((self.rgb(~condition)+0.055)/1.055).^2.4;
        end
        function applyGammaCorrection(self)
            condition = self.rgb<=0.0031308;
            self.rgb(condition) = self.rgb(condition)*12.92;
            self.rgb(~condition) = 1.055*self.rgb(~condition).^0.41666 - 0.055;
        end
        
        % Getters and setters
        function output = get.available(self)
            output = keys(self.as_map);
        end
        function map = get.as_map(self)
            map = containers.Map([self.colours{:,1}]',self.colours(:,2));
        end
        function RGB = get.RGB(self)
            RGB = self.rgb.*255;
        end
        function set.RGB(self,RGB)
            self.rgb = RGB./255;
        end
        function RYB = get.RYB(self)
            RYB = self.ryb.*255;
        end
        function set.RYB(self,RYB)
            self.ryb = RYB./255;
        end
        
        % Output
        function json_string = toJSON(self)
            json_string = ""+'{"location":'+self.location+', "name":"'+self.name+'", "rgb":['+self.rgb(1)+','+self.rgb(2)+','+self.rgb(3)+']}';
        end
    end
    methods (Static=true)
        % Conversions
        function hsv = rgbTohsv(rgb)
            value = max(rgb);
            delta = max(rgb)-min(rgb);
            if delta==0
                hue = 0;
            elseif max(rgb)==rgb(1)
                hue = 60*mod(((rgb(2)-rgb(3))/delta),6);
            elseif max(rgb)==rgb(2)
                hue = 60*(((rgb(3)-rgb(1))/delta)+2);
            elseif max(rgb)==rgb(3)
                hue = 60*(((rgb(1)-rgb(2))/delta)+4);
            end
            
            if value==0
                saturation = 0;
            else
                saturation = delta/value;
            end
            
            hsv = [hue,saturation,value];
        end
        function rgb = hsvTorgb(hsv)
            c = hsv(2).*hsv(3);
            x = c*(1-abs(mod(hsv(1)/60,2)-1));
            m = hsv(3)-c;
            
            if hsv(1)<=60
                rgb = [c,x,0]+m;
            elseif hsv(1)>60 && hsv(1)<=120
                rgb = [x,c,0]+m;
            elseif hsv(1)>120 && hsv(1)<=180
                rgb = [0,c,x]+m;
            elseif hsv(1)>180 && hsv(1)<=240
                rgb = [0,x,c]+m;
            elseif hsv(1)>240 && hsv(1)<=300
                rgb = [x,0,c]+m;
            elseif hsv(1)>300
                rgb = [c,0,x]+m;
            end
        end
        function ryb = rgbTorybCube(rgb,colour_cube,weight_function)
            blue_axis = weight_function(rgb(3),colour_cube(:,:,1).collate("set_value"),colour_cube(:,:,2).collate("set_value"));
            green_axis = weight_function(1-rgb(2),blue_axis(1,:,:),blue_axis(2,:,:));
            red_axis = weight_function(rgb(1),green_axis(:,1,:),green_axis(:,2,:));
            ryb = squeeze(red_axis)';
        end
        function rgb = rybTorgbCube(ryb,colour_cube,weight_function)
            blue_axis = weight_function(ryb(3),colour_cube(:,:,1).collate("set_value"),colour_cube(:,:,2).collate("set_value"));
            yellow_axis = weight_function(1-ryb(2),blue_axis(1,:,:),blue_axis(2,:,:));
            red_axis = weight_function(ryb(1),yellow_axis(:,1,:),yellow_axis(:,2,:));
            rgb = squeeze(red_axis)';
        end
        function rgb_cube = getrgbCube()
            rgb_cube = cat(3,[[Geochemistry_Helpers.Colour.Colour([1,1,0],"prevent");Geochemistry_Helpers.Colour.Colour([1,1,1],"prevent")],[Geochemistry_Helpers.Colour.Colour([1,0.5,0],"prevent");Geochemistry_Helpers.Colour.Colour([1,0,0],"prevent")]],[[Geochemistry_Helpers.Colour.Colour([0,0.66,0.2],"prevent");Geochemistry_Helpers.Colour.Colour([0.163,0.373,0.6],"prevent")],[Geochemistry_Helpers.Colour.Colour([0,0,0],"prevent");Geochemistry_Helpers.Colour.Colour([0.5,0,0.5],"prevent")]]);
        end
        function ryb_cube = getrybCube()
            ryb_cube = cat(3,[[Geochemistry_Helpers.Colour.Colour([0,1,0.483],"prevent");Geochemistry_Helpers.Colour.Colour([0,0,0],"prevent")],[Geochemistry_Helpers.Colour.Colour([0,1,0],"prevent");Geochemistry_Helpers.Colour.Colour([1,0,0],"prevent")]],[[Geochemistry_Helpers.Colour.Colour([0,0.053,0.21],"prevent");Geochemistry_Helpers.Colour.Colour([0,0,1],"prevent")],[Geochemistry_Helpers.Colour.Colour([1,1,1],"prevent");Geochemistry_Helpers.Colour.Colour([0.309,0,0.469],"prevent")]]);
        end
        function polar_map = getPolarMap()
            polar_array = [Geochemistry_Helpers.Colour.Colour([1,0,0],"prevent",0),Geochemistry_Helpers.Colour.Colour([1,1,0],"prevent",60),Geochemistry_Helpers.Colour.Colour([0,1,0],"prevent",120),Geochemistry_Helpers.Colour.Colour([0,1,1],"prevent",180),Geochemistry_Helpers.Colour.Colour([0,0,1],"prevent",240),Geochemistry_Helpers.Colour.Colour([1,0,1],"prevent",300),Geochemistry_Helpers.Colour.Colour([1,0,0],"prevent",360)];
            polar_map = Geochemistry_Helpers.Colour.Map("polar",polar_array);
%             polar_array = [0,60,120,180,240,300,360;
%                      1, 1,  0,  0,  0,  1,  1;
%                      0, 1,  1,  1,  0,  0,  0;
%                      0, 0,  0,  1,  1,  1,  0]';
        end
        function rgb_lms_matrix = getrgblmsMatrix()
            rgb_lms_matrix = [0.31399022,0.63951294,0.04649755;
                              0.15537241,0.75789446,0.08670142;
                              0.01775239,0.10944209,0.87256922];
        end
        function lms_rgb_matrix = getlmsrgbMatrix()
            lms_rgb_matrix = [ 5.47221206,-4.6419601,  0.16963708;
                              -1.1252419,  2.29317094,-0.1678952;
                               0.02980165,-0.19318073, 1.16364789];
        end
        function protanopia_matrix = getProtanopiaMatrix()
            protanopia_matrix = [0,1.05118294,-0.05116099;
                                 0,1,          0         ;
                                 0,0,          1         ];
        end
        function deutranopia_matrix = getDeutranopiaMatrix()
            deutranopia_matrix = [1,        0,0         ;
                                  0.9513092,0,0.04866992;
                                  0,        0,1         ];
        end
        function tritanopia_matrix = getTritanopiaMatrix()
            tritanopia_matrix = [ 1,         0,         0;
                                  0,         1,         0;
                                 -0.86744736,1.86727089,0];
        end
        function monochromatism_blue = getMonochromatismBlueMatrix()
            monochromatism_blue = [0.01775,0.10945,0.87262;
                                   0.01775,0.10945,0.87262;
                                   0.01775,0.10945,0.87262];
        end
        function monochromatism_red = getMonochromatismRedMatrix()
            monochromatism_red = [0.212656,0.715158,0.072186;
                                  0.212656,0.715158,0.072186;
                                  0.212656,0.715158,0.072186];
        end
        function monochromatism_green = getMonochromatismGreenMatrix()
            monochromatism_green = [0.15537,0.75792,0.0867;
                                    0.15537,0.75792,0.0867;
                                    0.15537,0.75792,0.0867];
        end
        
        function [output,leftover] = clamp(bounds,input)
            output = input;
            if any(input<bounds(1))
                output(input<bounds(1)) = bounds(1);
                leftover(input<bounds(1)) = bounds(1)-input(input<bounds(1));
            end
            if any(input>bounds(2))
                output(input>bounds(2)) = bounds(2);
                leftover(input>bounds(2)) = input(input>bounds(2))-bounds(2);
            end
            if all(input>=bounds(1) & input<=bounds(2))
                output = input;
                leftover = 0;
            end
        end
        
        % Internal
        function standardised_name = standardiseName(name)
            standardised_name = strrep(lower(name),"gray","grey");                
        end
    end
end