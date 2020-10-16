# Geochemistry Helpers
This repository contains a number of Matlab classes and functions to aid with Geochemical data analysis.

## Dependencies
None

## Jump To
- [Collator](#Collator)
- [pX](#pX)
- [delta](#delta)

## Collator
The ```Collator``` class should be inherited from where you want to make some operations on arrays of objects easier.

### collate
The ```collate``` method iterates over an array of objects and returns an array of collected values.

Let us take the ```pX``` class as an example. The ```pX``` class is very simple, it contains only two properties: ```pValue``` and ```value```. We can create an array of ```pX```, and, because ```pX``` inherits from ```Collator```, we can collate either of the properties into a single array.
```MATLAB
example = [pX(),pX(),pX()];
collated = example.collate("value");
```
This collects the ```value``` field from each of the ```pX``` objects in ```example```, and returns them in an array.

### assignToAll
The ```assignToAll``` method iterates over an array of objects and assigns a value (or object) to a property.

Let us again take ```pX``` as an example.
```MATLAB
example = [pX(),pX(),pX()];
example.assignToAll("pValue",8.8);
```
Now ```example(1).pValue==8.8```,```example(2).pValue==8.8``` and ```example(3).pValue==8.8```.


### assignToEach
The ```assignToEach``` method iterates over an array of objects and an array of values (or objects) to assign one value (or object) to a property of each object.

Again with ```pX``` as the example.
```MATLAB
example = [pX(),pX(),pX()];
array = [8.2,8.6,8.8];
example.assignToEach("pValue",array);
```
Now ```example(1).pValue==8.2```,```example(2).pValue==8.6``` and ```example(3).pValue==8.8```. The number of elements of ```array``` must be equal to the number of objects (in ```example```).

## pX
The ```pX``` class is very simple. It contains only two properties, and no bespoke methods. It's purpose is to represent the relationship between [H<sup>+</sup>] concentration and pH, or any value and its negative log (base 10).

### Properties
```value``` - this is the raw concentration (equivalent to [H<sup>+</sup>])  
```pValue``` - this is the negative base 10 logarithm of ```value```

```MATLAB
pH = pX(7);
```


```pX``` objects can be added and subtracted - this is done based on the concentration ```value``` not the ```pValue```. To add two ```pValues``` use: ```pX_Object(1).pValue + pX_Object(2).pValue```.

## delta
The ```delta``` object is used to represent isotope ratios in delta notation. It allows easy conversion between delta notation, raw isotope ratio and isotope fraction.
Delta notation is defined as follows:  
&delta;<sup>n</sup>X = ((<sup><sup>n</sup>X</sup>&frasl;<sub><sup>m</sup>X<sub>sample</sub></sub>&divide;<sup><sup>n</sup>X</sup>&frasl;<sub><sup>m</sup>X<sub>standard</sub></sub>)-1&times;1000  
where m and n are two isotopes of element X.

This means that in order to convert the raw isotope ratio (<sup><sup>n</sup>X</sup>&frasl;<sub><sup>m</sup>X<sub>sample</sub></sub>) into delta notation, the isotope ratio of the standard (<sup><sup>n</sup>X</sup>&frasl;<sub><sup>m</sup>X<sub>standard</sub></sub>) is required.

There are two input values to the constructor, the first of which is the standard (and is required), the second of which is the delta value (and is optional). The standard can be specified as a number or a string. If specified as a string, the constructor will search a map defined in the class file for a matching entry. Currently the only values available in the map are for boron (<sup><sup>11</sup>B</sup>&frasl;<sub><sup>10</sup>B<sub>standard</sub></sub>), and can be accessed by "B", "Boron" or "SRM951".  
The second value, if specified, must be a number or NaN. If not specified the default is NaN.

Example usage:
```MATLAB
delta_object = delta(10);        % Create a delta object with standard ratio 10/1 and sample ratio NaN
delta_object = delta(10,5);      % Create a delta object with standard ratio 10/1 and sample delta 5‰
disp(delta_object.ratio);        % Show the isotope ratio
```

Using a string standard:
```MATLAB
delta_object = delta("Boron");   % Create a delta object with standard ratio for boron
delta_object = delta("Boron",29); % Create a delta object with standard ratio for boron and sample delta 29‰
disp(delta_object.ratio);        % Show the isotope ratio
```

Converting a standard ratio to delta notation:
```MATLAB
delta_object = delta(1,NaN);       
delta_object.ratio = 2;          % Convert a ratio relative to 1
```
