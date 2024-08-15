# webFuzz

A grey-box fuzzer for web applications

## Installation

1. Instrument your web application using [php-ast-instrumentor](https://github.com/ovanr/webFuzz/tree/v1.2.0/instrumentor/php).
2. Make sure your instrumented web application now works fine.
4. Install the python dependencies:  ```pip3 install --upgrade -r web_fuzzer/requirements.txt```

## Usage

Run the fuzzer using `webFuzz.py`.
*Tested on Linux environments with Python version 3.8 and 3.9*

Example run: 
```
./webFuzz.py -vv 
             --driver webFuzz/drivers/geckodriver 
             -m ~/MyWebappInstrumented/instr.meta 
             -w 8 
             -b 'wp-login|action|logout|' 
             -b 'settings|||POST 
             -p -s 
             -r simple 
             'http://localhost/wp-admin/index.php'
```

## Paper

A paper that discusses the internals of webFuzz can be found at: 
[ESORICS 2021](https://www.researchgate.net/publication/354942205_webFuzz_Grey-Box_Fuzzing_for_Web_Applications)

### Cite the paper
```
@inproceedings{rooij2021webfuzz,
  title={webFuzz: Grey-Box Fuzzing for Web Applications},
  author={Rooij, Orpheas van and Charalambous, Marcos Antonios and Kaizer, Demetris and Papaevripides, Michalis and Athanasopoulos, Elias},
  booktitle={European Symposium on Research in Computer Security},
  pages={152--172},
  year={2021},
  organization={Springer}
}
```

## Trophy Case

* OSCommerce CE-Phoenix - 8 Zero day XSS bugs - [GitHub Issue](https://github.com/gburton/CE-Phoenix/issues/1039)
* WordPress 5.7 - 1 Zero Day Reflective XSS bug - [HackerOne Report](https://hackerone.com/reports/1103740) (Report will be publicly available as soon as a bug fix is released)

## Authors

* **Orpheas van Rooij** - *ovan-r01@cs.ucy.ac.cy*
* **Marcos Antonios Charalambous** - *mchara01@cs.ucy.ac.cy*
* **Demetris Kaizer** - *dkaize01@cs.ucy.ac.cy*
* **Michalis Papaevripides** - *mpapae04@cs.ucy.ac.cy*
* **Elias Athanasopoulos** - *eliasathan@cs.ucy.ac.cy*

All authors are with the University of Cyprus and members of the [SREC group](https://srec.cs.ucy.ac.cy). 

## License
[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)
