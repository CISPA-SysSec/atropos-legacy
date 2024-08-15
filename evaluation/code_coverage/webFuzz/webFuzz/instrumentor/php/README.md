# PHP-INSTRUMENTOR

Instrument PHP files using Node, Edge, Node-Edge (combo) or Path coverage policy.

Coverage feedback can be outputted in the form of a file or via HTTP headers.

## Usage

**Tested on PHP7.4**

1. Install needed libraries using:  
```sh
php composer.phar install
```

2. Start instrumenting using:
```sh
php src/instrumentor.php --verbose --method (file|http) --policy (node|edge|...) --exclude exclude.txt --dir ~/MyWebApp
```

## Developer Tips

when creating/updating classes in the src directory run:  
```sh
php composer.phar dump-autoload
```

in order to load project classes in a file insert:  
```php
require_once(__DIR__ . '../vendor/autoload.php')
```

## Authors

* **Orpheas van Rooij** - *ovan-r01@cs.ucy.ac.cy*

## License

[GNU GPLv3](https://choosealicense.com/licenses/gpl-3.0/)