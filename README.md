# Geochemistry Helpers
This repository contains a number of Matlab classes and functions to aid with Geochemical data analysis.

## Dependencies
None

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
