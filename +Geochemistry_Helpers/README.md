# Geochemistry Helpers
This repository contains a number of Matlab classes and functions to aid with Geochemical data analysis.

## Dependencies
None

## Jump To
- [Collator](#Collator)
- [pX](#pX)
- [delta](#delta)
- [Distribution](#Distribution)
- [Sampler](#Sampler)
- [GaussianProcess](#GaussianProcess)
- [Timer](#Timer)


## pX
The ```pX``` class is very simple. It contains only two properties, and no bespoke methods. It's purpose is to represent the relationship between [H<sup>+</sup>] concentration and pH, or any value and its negative log (base 10).

### Properties
```value``` - this is the raw concentration (equivalent to [H<sup>+</sup>])  
```pValue``` - this is the negative base 10 logarithm of ```value```

```MATLAB
pH = pX(7);
```


```pX``` objects can be added and subtracted - this is done based on the concentration ```value``` not the ```pValue```. To add two ```pValues``` use: ```pX_Object(1).pValue + pX_Object(2).pValue```.

## Collator
The ```Collator``` class should be inherited from where you want to make some operations on arrays/matrices of objects easier.

### collate
The ```collate``` method iterates over an array of objects and returns an array of collected values.

Let us take the ```pX``` class as an example. The ```pX``` class is very simple, it contains only two properties: ```pValue``` and ```value```. We can create an array of ```pX```, and, because ```pX``` inherits from ```Collator```, we can collate either of the properties into a single array.
```MATLAB
example = [pX(),pX(),pX()];
collated = example.collate("value");
```
This collects the ```value``` field from each of the ```pX``` objects in ```example```, and returns them in an array. The Collator class overrides the default getter behaviour, meaning you can also request a property of an array/matrix of objects:
```MATLAB
example = [pX(),pX(),pX()];
collated = example.value;
```
Returns an array containing the 3 pX.values.


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

## Distribution
The Distribution class is designed to represent any arbitrary discretised unidimensional distribution. It contains the bin edges and midpoints, and the probabilities for each bin. These probabilities can be calculated for common distributions. Create one like so:
```MATLAB
distribution = Geochemistry_Helpers.Distribution(bin_edges,distribution_type,distribution_values);
```
Where ```distribution_type``` can be: ```"gaussian"```, ```"glat"```,```"loggaussian"```, or ```"manual"```.
```distribution_values``` depends on the distribution type. For ```"gaussian"``` or ```"loggaussian"```, it is [mean,standard_deviation], for ```"flat"``` it is [lower_bound,upper_bound], and for ```"manual"``` it is an array which has length ```bin_edges-1```.

#### Methods
```normalise``` divides the distribution by the sum of distribution to ensure it sums to 1. Optionally input a value to normalise to that instead of 1.
```MATLAB
distribution = Geochemistry_Helpers.Distribution(0:0.01:1,"gaussian",[0.5,0.1]);

distribution.normalise();
sum(distribution.probabilities)

distribution.normalise(2);
sum(distribution.probabilities)
```

```mean```,```median```,```standard_deviation```,```variance``` compute the statistic for the distribution.

```quantile(value)``` gets the fraction of the distribution below the specified input.

```plot(inputs)``` does a basic plot (histogram style), with regular plot arguments passed through.


## Sampler
Sampler inherits from Distribution, so has all the same properties and methods as Distribution, as well as alowing you to sample from that Distribution using one of three methods: ```monte_carlo```, ```latin_hypercube``` or ```latin_hypercube_random```. Create a Sampler:
```MATLAB
sampler = Geochemistry_Helpers.Sampler(bin_edges,distribution_type,distribution_values,sample_strategy);

sampler = Geochemistry_Helpers.Sampler(Distribution,sample_strategy);
```

#### Methods
Main method is ```getSamples(number)``` which generates the samples using your chosen strategy.

Samples can also be assigned manually, after which you can do things like bootstrapping:
```MATLAB
sampler = Geochemistry_Helpers.Sampler.fromSamples(bin_edges,samples);
output = sampler.bootstrap(number);
output.mean()
```
