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

In order to run the script, make sure it has executable permissions:

```
$ chmod a+x rs41_dump.sh
```

Depending on your environment, in order to access the serial port you might need
to run the script with sudo permissions.

There are two modes of operation, which are explained below:


### 1. Specify interval of parameter ID's and step

In this mode, you can execute a dump by specifying the interval of parameter ID's,
and the step between values to be assumed. For example:


```
$ ./rs42_dump.sh 0x10 0x800 0x10
```

You can also watch the parameters being dumped while these are saved to a file,
by running the following way:

```
$ ./rs42_dump.sh 0x10 0x800 0x10 | tee dump.csv
```

### 2. CSV list of parameters


A csv file holding the list of parameters to be scanned is required for this mode.
The sample file 'rs41_params.csv' is provided, which covers some of the known
parameters. You may point to a different location by setting this env variable
with a different value:

```
PARAM_FILE=rs41_params.csv
```

And then to run the script, simply do:

```
$ sudo ./rs41_dump.sh | tee dump.csv
```

### Output

If all goes well, the script should provide an output similar to:

```
param_name,param_value,is_rw
10,0,1
20,14,1
30,0,1
40,0,1
45,123245,1
50,0000000000,1
60,20215,0
70,9089,1
75,,0
76,,0
77,,0
80,4,0
90,7,0
A0,703,0
B0,45969,0
C0,6,0
D0,600,1
E0,18,1
100,180,1
110,60,1
120,1700,1
130,20,1
140,135,1
150,50,1
160,2,1
170,0000000000,1
180,000000000,1
190,0000000000,1
1A0,0,1
1A8,0,0
1B0,00000000,0
1B8,0,1
1C0,0,1
1C8,538,1
1D0,0,1
1D5,0,1
1D8,0,1
1E0,0,1
200,29,0
210,2,0
220,36,0
230,39,0
240,128,0
250,35,0
255,0,0
260,0,0
400,37759,1
410,0,1
420,0,1
430,65535,1
440,0,1
450,0,1
460,0,1
470,0,1
480,0,1
490,1000,1
4a0,0,1
570,1.0030000210,1
5a0,44.2999992371,1
5b0,4.9000000954,1
800,0.0000000000,0
900,0,0
```

(this example is not a perfect reference, as is belongs to an 
already corrupted radiosonde, from previous testing)

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