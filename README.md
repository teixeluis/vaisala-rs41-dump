# Vaisala RS41 Dump

## Overview

Simple script for dumping the parameters of the Vaisala RS41 radiosondes.

## Requirements

 * bash interpreter;
 * Serial UART (RS-232) with 3.3 Volt TTL level output for the Vaisala data port;

## Usage

Clone this repo to a folder of your choice:

```
$ git clone https://github.com/teixeluis/vaisala-rs41-dump.git
```

The script assumes a serial port located in /dev/ttyUSB0, but this can 
be modified by changing the value of the env variable:

```
SERIAL_PORT=/dev/ttyUSB0
```

A csv file holding the list of parameters to be scanned is required.
The sample file 'rs41_params.csv' is provided, which covers some of the known
parameters. You may point to a different location by setting this env variable
with a different value:

```
PARAM_FILE=rs41_params.csv
```

In order to run the script, make sure it has executable permissions:

```
$ chmod a+x rs41_dump.sh
```

Depending on your environment, in order to access the serial port you might need
to run the script with sudo permissions:

```
$ sudo ./rs41_dump.sh > dump.csv
```

If all goes well, the script should provide an output similar to:

```
param_name,param_value
10,0
20,14
30,0
40,0
45,P10
50,0000000000
60,20215
70,9089
75,9089
76,9089
77,9089
80,4
90,7
A0,703
B0,45969
C0,6
D0,600
E0,18
100,180
110,60
120,1700
130,20
140,135
150,50
160,2
170,0000000000
180,000000000
190,0000000000
1A0,0
1A8,0
1B0,00000000
1B8,0
1C0,0
1C8,538
1D0,0
1D5,0
1D8,0
1E0,0
200,29
210,2
220,38
230,42
240,128
250,38
255,0
260,391
400,37759
410,0
420,0
430,65535
440,0
450,0
460,0
470,0
480,6521
490,1000
4a0,0
570,1.0030000210
5a0,44.2999992371
5b0,4.9000000954
800,0.0000000000
900,0
```

## Relevant links

 * Vaisala RS-41 SGP Modification - http://happysat.nl/RS-41/RS41.html

## License

Author: Luis Teixeira (https://creationfactory.co)

Licence and copyright notice:

Copyright 2021 Luis Teixeira

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file 
except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, softwar distributed under the License 
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express 
or implied. See the License for the specific language governing permissions and limitations 
under the License.