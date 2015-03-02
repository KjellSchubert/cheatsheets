good(?) online tutorials & manuls & tips:
* http://php.net/manual/en/
* http://www.codecademy.com/en/tracks/php

Package manager modeled after npm & pip: htts://github.com/composer/composer.
More details here: http://blog.teamtreehouse.com/dependency-management-in-php-using-composer
Installing composer on Windows with php 5.6.3 pulled via choco yielded:

```
Some settings on your machine make Composer unable to work properly.
Make sure that you fix the issues listed below and run this script again:
The openssl extension is missing, which means that secure HTTPS transfers are impossible.
If possible you should enable it or recompile php with --with-openssl
```

The same worked fine on Ubuntu 14 though with php 5.5.9:
```
sudo apt-get install php5-dev
curl -sS https://getcomposer.org/installer | php
php composer.phar --version
# see http://php.net/manual/en/intro.phar.php for phar files
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

An (older?) alternative to composer is PEAR: http://pear.php.net/, sudo apt get
php-pearl (installed via apt-get install php5-dev).

To test composer create composer.json with
```
{
  "require": {
    "phpunit/phpunit": "4.3.*"
  }
}
```
Then 'composer install'. The npmjs.org or Pypi equivalent is here:
https://packagist.org/ (e.g. search phpunit). To test the downloaded phpunit
package do this:
```
require './vendor/autoload.php';
class FooTest extends PHPUnit_Framework_TestCase {
  // phpunit runs every public member starting with 'test'?
  public function test_foo1() {
    $this->assertTrue(5 < 6);
  }
  public function test_foo2() {
    $this->assertTrue(5 == 6); // fails
  }
}
```
Run with
```
./vendor/bin/phpunit foo.php
```
Alternative unit testing frameworks: http://stackoverflow.com/questions/282150/how-do-i-write-unit-tests-in-php

FastCGI
---
php[-cli].exe populates $argv and $argc (see http://php.net/manual/en/migration5.cli-cgi.php).
For nginx reverse proxy with PHP FastCGI Process Manager(?) use see
http://wiki.nginx.org/PHPFcgiExample. Alternatively using lighttpd:

```
sudo apt-get install lighttpd
sudo apt-get install php5-cgi
php-cgi --version
sudo mkdir -p /etc/lighttpd/conf.d/
sudo vim /etc/lighttpd/conf.d/fastcgi.conf
# paste from https://wiki.archlinux.org/index.php/lighttpd
sudo vim /etc/lighttpd/lighttpd.conf
# paste include from http://www.cyberciti.biz/faq/stop-lighttpd-server/
/etc/init.d/lighttpd restart # errored for me at 1st, port 80 was in use (nginx)
sudo lsof -i:80 # optionally -t[erse], shows me nginx
sudo /etc/init.d/nginx stop
sudo /etc/init.d/lighttpd restart
sudo lsof -i:80 # now shows lighttpd

# test lighttp:
curl http://localhost # shows default blurb in /var/www
curl http://localhost/index.php # 404 unless you created /var/www/index.php

# test fastcgi php
sudo vim /var/www/index.php # e.g. add 'hello world'
```

Example /var/www/index.php:
```
hi, this is /var/www/index.php<br/>
<?php
$foo = 77;
// see http://www.w3schools.com/php/php_superglobals.asp for $_SERVER
echo $foo, $_SERVER['REQUEST_METHOD'], var_dump($_SERVER);
// _SERVER contains QUERY_STRING and plenty of other HTTP request details.
?>
```


See also https://wiki.archlinux.org/index.php/lighttpd for php-fpm setup.

PHP syntax
---

```
<?php
    $welcome = "Hello World";
    echo $welcome;
    var_dump($welcome); // prints string(11) "Hello World"
    unset($welcome); // sets it to NULL? http://php.net/manual/en/function.unset.php
    echo $welcome; // no error
    echo $nonExisting + 7; // no error either, value 7
    var_dump($otherNonExisting); // NULL
    var_dump($otherNonExisting+7.5); // prints float(7.5)

    /* comments are C & C++ style */
    // vars do not need to declared before use, like in Python

    // statements need trailing semicolon, C-style, unlike in
    // JS they are mandatory (in JS they're recommended anyway)

    // containers
    $things = array("foo", "bar");

    // strings
    echo "ab" . "cd\n"; // concat with . instead of the usual +
    echo 'single quote\n'; # prints backslash & n
    echo "double quote\n"; # prints ascii line break char
    $foo = 123;
    echo 'single quote $foo', "\n"; # prints literally foo
    echo "double quote $foo", "\n"; # auto-replaces the var with its value!
    assert("double quote $foo" === "double quote 123");
    assert('double quote $foo' !== 'double quote 123');

    // loops
    for ($number = 1; $number <= 10; $number++) {}
    foreach ($things as $thing) {
        //echo $thing;
    }
    var_dump($thing); // lifetime of foreach var extends beyond loop
    echo "\nvar_dump(get_defined_vars()):";
    //var_dump(get_defined_vars()); // all vars in scope

    // include files
    include 'lib.php';
    echo "\ncalling libfunc: ", libfunc("zzz"), "\n";

    // conditions: 0 implicitly converts to false (as in C, JS)
    if (0) {
      // never hit
    }

    // exception handling: usual Java-like try-catch-finally
    // http://php.net/manual/en/language.exceptions.php
    try {
      throw new Exception("bla");
    }
    catch (Exception $ex) {
      echo "caught ex: ", $ex->getMessage(), "\n";
    }
    finally {
      echo "finally block\n";
    }

    // classes
    class MyException extends Exception { }
    //throw new MyException('bla')

    // functions, func-local classes
    function myFunc() {
      class MyOtherException extends MyException { }
      echo "myFunc\n";
      return 7;
    }
    assert(myFunc() == 7);

    // closures aka anonymous functions:
    // (see http://php.net/manual/en/functions.anonymous.php)
    $outerScopeVar = 100;
    function funcTakingCallback($theCallback) {
      return 1 + $theCallback(2000);
    }
    $retVal = funcTakingCallback(function($val) use ($outerScopeVar) {
      // WARNING: without the 'use' $outerScopeVar will be undefined.
      // Compare with C++11 closures which also need explicit capture
      // of variables from outer scope (but C++ yields compile time errors).
      // Used/bound/captured variable's value is from when the function
      // is defined, not when called (like C++ capture by value, not ref).
      // To capture by ref use this syntax: use (&$outerScopeVar), looks C++ish.
      return $outerScopeVar + $val + 8;
    });
    echo "retVal=", $retVal;
    assert($retVal == 2109);

    // null / NULL
    $var = null;
    var_dump($var);
    $var = NULL;
    var_dump($var);
    $var = Null;
    var_dump($var);
    $var = nULl; // really...
    var_dump($var);
    var_dump($nonExistingVariable); // indistinguishable from var containing null?
    //$var = nULlxxx;

    // cmdline
    $params = array_slice($argv, 1);
    var_dump($argv);
    // anything like python argparse or C++ gflags? E.g.
    // https://packagist.org/packages/pear/console_getopt
    // https://packagist.org/packages/donatj/flags

    // constants
    define("MYCONSTANT", 1234);
    echo MYCONSTANT, "\n"; // note not $
    //MYCONSTANT = 77; // error

    // PHP arrays (covering what in Python is covered by lists and dicts, or more
    // accurately OrderedDict, with some similarity to JS arrays which are also
    // more like mappings from ints to values, and can have holes in JS as they
    // can in PHP)
    $x = array("a", "b", "foo" => "c", "d"); // instead of "foo" can use ints as keys
    assert($x[0] === "a");
    assert($x[1] === "b");
    assert($x[2] === "d"); // since "b" had key 1
    assert($x[3] === null);
    assert($x[999] === null);
    assert($x["foo"] === "c");
    echo "x[...]=", $x["foo"], "\n";
    // iter over array that doesn't have 'holes':
    $arrlength = count($x);
    assert(count($x) == 4); // number of key-value tuples, not max index in array
    for($i = 0; $i < $arrlength; $i++)
      echo "  for $i: ", $i, "=>", $x[$i], "\n"; // surprising here: $i in string gets replace with val!
    // iter over array that has holes, or represents a general dict to begin with:
    foreach($x as $key => $value)
      echo "  foreach key/val: ", $key, "=>", $value, "\n";
    // More on array ops: http://php.net/manual/en/language.operators.array.php
?>
```
