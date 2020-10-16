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

```pX``` objects can be added and subtracted - this is done based on the concentration ```value``` not the ```pValue```. To add two ```pValues``` use: ```pX_Object(1).pValue + pX_Object(2).pValue```
