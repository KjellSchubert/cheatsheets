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

phpdbg
---

Very similar to gdb:
```
phpdbg <script>
help
break <line>
run
ev $name # evals exprs
```

See also https://wiki.archlinux.org/index.php/lighttpd for php-fpm setup.

PHP syntax
---

```
<?php
    assert_options(ASSERT_BAIL, true); // otherwise assert just prints warning
    error_reporting(E_ALL | E_STRICT); // recommended when writing new code (how to exit on error?)

    $welcome = "Hello World";
    echo $welcome;
    var_dump($welcome); // prints string(11) "Hello World"
    unset($welcome); // sets it to NULL? http://php.net/manual/en/function.unset.php
    echo $welcome; // no error, unless you set error_reporting(E_ALL)
    echo $nonExisting + 7; // no error either, value 7
    var_dump($otherNonExisting); // NULL
    var_dump($otherNonExisting+7.5); // prints float(7.5)

    /* comments are C & C++ style */
    // vars do not need to declared before use (assignment), like in Python
    # unix shell comments are also allowed

    // statements need trailing semicolon, C-style, unlike in
    // JS they are mandatory (in JS they're recommended anyway)

    // Types
    $foo = True;
    assert(gettype($foo) == "boolean");

    $foo = 7.5;
    assert(gettype($foo) == "double"); // 7.5f would be float
    assert(is_float($foo));
    assert(is_double($foo)); // same type, historic reasons
    assert(!is_integer($foo));
    // Casting:
    // a) C-style:
    assert(is_integer((int)$foo));
    // b) settype
    settype($foo, "integer");
    assert(is_integer($foo));
    assert($foo === 7);

    $foo = function($x) { return $x + 1; };
    assert(gettype($foo) == "object"); // not 'callable'/ 'callback'?
    // other: string, integer, array, object, NULL, callable

    // integer:
    assert(01090 == 8); // 010 octal = 8 decimal, 9 is parse error with silent ignore
    assert(1/2 == 0.5); // 1/2 => float 0.5, php has no integer division?
    $million = 1000000;
    $large_number =  50000 * $million;
    assert(is_double($large_number)); // instead of overflow we get a float/double
    assert(((int)((0.1+0.7) * 10)) == 7); // float->int rounds towards 0
    assert((round((0.1+0.7) * 10)) == 8); // unless you round towards nearest int explicitly

    // strings
    echo "ab" . "cd\n"; // concat with . instead of the usual +
    echo 'single quote\n'; # prints backslash & n
    echo "double quote\n"; # prints ascii line break char
    $foo = 123;
    echo 'single quote $foo', "\n"; # prints literally foo
    echo "double quote $foo", "\n"; # auto-replaces the var with its value!
    assert("double quote $foo" === "double quote 123");
    assert('double quote $foo' !== 'double quote 123');
    assert(is_string((string)1.0));
    $foo = "abc";
    assert(strlen(foo) == 3);
    assert($foo[1] == 'b');
    // string char encodings: see http://php.net/manual/en/language.types.string.php
    // which sounds somewhat fishy: so a string is a byte seq, knows nothing
    // about chars (similar to std::string being a char or wchar_t container
    // without knowledge of encodings). String encoding is same as in script file.
    // See also http://php.net/manual/en/book.mbstring.php

    // loops
    for ($number = 1; $number <= 10; $number++) {}
    foreach ($things as $thing) {
        //echo $thing;
    }
    var_dump($thing); // lifetime of foreach var extends beyond loop
    echo "\nvar_dump(get_defined_vars()):";
    //var_dump(get_defined_vars()); // all vars in scope

    // impl interface Iterator to have foreach work with custom classes,
    // not just arrays, see http://php.net/manual/en/language.oop5.iterations.php


    // include files
    // You can replace 'include' with 'require', the latter will fail on error
    // (e.g. non existing file), the former will print warning only.
    // There also is 'include/require_once'.
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
    assert((new MyException) instanceof Exception);


    // interface
    interface MyInterface {
      function memberFun(); // automatically abstract
    }
    class MyImpl implements MyInterface {
      function memberFun() { return 7; }
    }
    $x = new MyImpl;
    assert($x instanceof MyInterface);
    assert(is_a($x, 'MyInterface')); // this alt syntax was temp deprecated
    assert($x->memberFun() === 7);


    // extends
    // For base/parent class constructors remember parent::__construct();
    class MyDerived extends MyImpl {
      function memberFun() { return 8; }
    }
    $x = new MyDerived;
    assert($x->memberFun() === 8);


    // trait: interesting concept, useful for languages without MI.
    // So this is yet another way to reuse code (without which you'd otherwise
    // need a member variable with another level of indirection for accessors)
    // Besides via parent::func() the trait impl can effectively have abstract
    // methods impl'd by the trait-using (sort of derived) class.
    // See http://php.net/manual/en/language.oop5.traits.php
    trait MyTrait {
      function fun1() {
        // could also do this here if derived class would have a base/parent class:
        //parent::sayHello(); // sort of an abstract method call (impl'd in derived/using cls)
        // this doesn't work (not accessible): fun3();
        return 7;
      }
    }
    class MyTraitor {
      use MyTrait;
      function fun2() {
        assert($this->fun1() === 7);
      }
      public function fun3() {
        return 8;
      }
    }
    (new MyTraitor)->fun2();

    // clone & __clone, for custom deep copies (as by default clone is shallow)
    class MyClonable {
      public $myMember = 123;
      // this __clone should really be called __onAfterClone() imo!
      function __clone() {
        return $this->foo = 7;
      }
    }
    $x = new MyClonable();
    assert(!isset($x->foo));
    $y = clone $x;
    $x->myMember = 567;
    assert(isset($y->foo));
    assert($y->foo === 7); // this ensures __onAfterClone aka __clone was called
    assert($y->myMember = 123); // this ensures we got a clone

    /*
    // obj compare: http://php.net/manual/en/language.oop5.object-comparison.php
    // Only used as comparison op for method call that take compare funcs,
    // e.g. usort(). Cannot override lessthan, see
    // http://stackoverflow.com/questions/3111668/comparison-operator-overloading-in-php
    class MyComparable {
      public $foo;
      public function __construct($val) {
        $this->foo = $val;
      }
      public static function compare($a, $b) {
        $lhs = (int)$a->foo;
        $rhs = (int)$b->foo;
        $a->wasCompared = "lhs";
        $b->wasCompared = "rhs";
        return $lhs < $rhs ? -1 : ($lhs === $rhs ? 0 : 1);
      }
    }
    $x = new MyComparable("2");
    $y = new MyComparable("0055");
    // not called during < comparison
    assert($x < $y);
    assert($x->wasCompared === "lhs");
    */


    // functions, func-local classes
    function myFunc() {
      class MyOtherException extends MyException { }
      echo "myFunc\n";
      return 7;
    }
    assert(myFunc() == 7);

    // WARNING: funcs all end up in a single flat global scope when define
    // via function name() {} syntax, for details see example 3 at
    // http://php.net/manual/en/functions.user-defined.php.
    // So if you want to keep inner funcs private use $innerFunc = function()
    // anonymous function syntax.
    function outerFunc() {
      function innerFunc() {
        return 7;
      }
      return 8;
    }
    // cannot call innerFunc() here without calling outerFunc() first
    assert(!function_exists('innerFunc'));
    assert( function_exists('outerFunc'));
    assert(outerFunc() === 8);
    assert( function_exists('innerFunc'));
    assert(innerFunc() === 7);

    // passing by value vs ref
    $x = 7;
    function funcByVal($val) {
      ++$val;
    }
    function funcByRef(&$val) {
      ++$val;
    }
    funcByVal($x); assert($x === 7);
    funcByRef($x); assert($x === 8);
    function objFuncByVal($val) {
      $val->x = 7;
      $val = null;
    }
    $x = new stdClass;
    objFuncByVal($x);
    assert($x->x === 7);
    assert($x != null);

    // There thankfully is no func overloading:
    //function func1() {}
    //function func1() {} // error
    // But there's a concept called 'overloading' in PHP, an umbrella term
    // for defining funcs __get/set/isset/unset for props, and __call/__callStatic
    // for methods. Maybe 'interpreter hooks' (which can be used for implementing
    // C++-style func overloading) would have been a better term.
    class Overloader {
      public $member1 = 7;
      function __set($name, $val) {
        $this->member1 = $name . (string)$val;
      }
      function __call ( $name ,  $args) {
        assert($name === 'foobar');
        # this here allows you to impl func overloading:
        if (count($args) == 1)
          return $args[0] + 1;
        return $args[0] * 10 + $args[1];
      }
    }
    $x = new Overloader;
    assert($x->member1 === 7);
    $x->member1 = 8; // this does not call Overloader.__set (only called for unk props)
    assert($x->member1 === 8);
    $x->other = 6;
    assert($x->member1 === "other6");
    assert($x->foobar(1) === 2);
    echo "XXXXXX", $x->foobar(1, 2);
    assert($x->foobar(1, 2) === 12);

    // var arg lists: function sum(...$numbers) {} represented args as array.
    // Also this ... is an operator that unpacks an array for a func call
    // in expressions, ex add(...[1, 2])
    // http://php.net/manual/en/functions.arguments.php#functions.variable-arg-list

    // returning tuples via array, unpack via list()
    function small_numbers()
    {
      return array (0, 1, 2);
    }
    list ($zero, $one, $two) = small_numbers();
    assert($one === 1);
    list ($x, $y) = ['foox', 'foob'];
    assert($x === 'foox');

    // returning a reference
    // See also http://php.net/manual/en/language.references.php
    // TODO: read http://derickrethans.nl/talks/phparch-php-variables-article.pdf
    /* doesnt work, why not? Cannot have ref to array value?
    $x = ['one', 'two'];
    function &retRef($arr) {
      return $arr[1];
    }
    $y = &retRef($x);
    assert($y === 'two');
    $y = 'zwei';
    assert($x[1] === 'zwei');
    */
    $x = 1;
    $y = 2;
    function &retRef2() {
      global $x;
      return $x;
    }
    $foo = &retRef2(); // note the additional ref here, without it foo still is a copy
    $foo = 3;
    assert($x === 3);

    // closures aka anonymous functions:
    // (see http://php.net/manual/en/functions.anonymous.php)
    // Remember the use($foo) and use(&$foo) to capture variables from
    // outer scope as needed (same as C++ closures).
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


    // optional typehinting in php5, cannot specify int or string but userdef'd
    // types, see http://php.net/manual/en/language.oop5.typehinting.php
    function funcWithHints(Overloader $x) {
      return 7;
    }
    //funcWithHints(123); // error
    assert(funcWithHints(new Overloader) === 7);

    function funcWithHints2(callable $x) {
      return $x(7);
    }
    //funcWithHints2("hi"); // error
    assert(funcWithHints2(function($val) { return $val * 10; }) == 70);


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
    assert(MYCONSTANT == 1234); // note not $
    // new const syntax since PHP 5.3:
    const CONSTANT2 = 'Hello World';
    assert(CONSTANT2 === 'Hello World');
    //MYCONSTANT = 77; // error

    // PHP arrays (covering what in Python is covered by lists and dicts, or more
    // accurately OrderedDict, with some similarity to JS arrays which are also
    // more like mappings from ints to values, and can have holes in JS as they
    // can in PHP)
    $x = array("a", "b", "foo" => "c", "d"); // instead of "foo" can use ints as keys
    $x = [ "a", "b", "foo" => "c", "d" ]; // since PHP 5.4
    assert($x[0] === "a");
    assert($x[1] === "b");
    assert($x[2] === "d"); // since "b" had key 1
    assert($x[3] === null);
    assert($x[999] === null);
    assert($x["foo"] === "c");
    assert(isset($x[0]));
    assert(!isset($x[123]));
    echo "x[...]=", $x["foo"], "\n";
    // iter over array that doesn't have 'holes':
    $arrlength = count($x);
    assert(count($x) == 4); // number of key-value tuples, not max index in array
    for($i = 0; $i < $arrlength; $i++)
      echo "  for $i: ", $i, "=>", $x[$i], "\n"; // surprising here: $i in string gets replace with val!
    // iter over array that has holes, or represents a general dict to begin with:
    foreach($x as $key => $value)
      echo "  foreach key/val: ", $key, "=>", $value, "\n";
    // foreach with reference to modify values
    foreach($x as &$value)
      $value = 7;
    assert($x[1] === 7);
    // More on array ops: http://php.net/manual/en/language.operators.array.php

    // be aware of some unexpected key type casts when populating arrays:
    $x = ["1" => "one", 2.5 => "two", "drei" => "three"];
    assert($x[1] == "one"); // string was cast to int just because it held a decimal number
    assert($x[2] == "two"); // float was cast to int
    $x[nonExistingVariable] = 7; //
    assert($x[nonExistingVariable] === 7);
    assert($x["nonExistingVariable"] === 7); // nonexisting var name turned into string ?!
    //var_dump($x);

    // unset(array) removes a key,value pair from the map,  array_values can
    // but used to fill 'holes'
    $x = ["one", "two", "three"];
    unset($x[1]);
    assert($x[1] === null);
    assert($x[2] === "three");
    $x = array_values($x); // this removes the gap
    assert($x[1] === "three");
    $x = ["one", "two", "three"];
    sort($x);
    //var_dump($x); // 0=>one 1=>three 2=>two

    // surprised me: assignment operator with array on rhs shallow copies!:
    $x = ["one", "two", "three"];
    $y = $x;
    $y[1] = "zwei";
    assert($x[1] === "two" and $y[1] == "zwei");
    //var_dump($x); var_dump($y);

    /// objects
    // Visibility: we have private/protected/public like in C++.
    // Remember C-style -> instead of . to access members!
    // Lots of details at http://php.net/manual/en/language.oop5.php
    class foo {
      public function member_fun() { // default visibility is public
        //privMemFun(); // Call to undefined function privMemFun(), so $this-> is needed
        $this->privMemFun();
        //assert($privMemVar === 'hi'); // $this-> is needed
        assert($this->privMemVar === 'hi');
        return "bar";
      }
      private function privMemFun() {}
      private $privMemVar = 'hi';
    };
    $x = new foo;
    //$x->privMemFun(); // err: Call to private method foo::privMemFun()
    //echo $x->$privMemVar; //err:  Cannot access empty property, even when public
    //echo $x->privMemVar; //err:  Cannot access private property
    assert("bar" === $x->member_fun());
    assert("bar" === (new foo)->member_fun());

    // stdClass gives you generic obj, similar to var x = {} in JS:
    $genericObject = new stdClass();
    $genericObject->foo = 7; // expando props
    //var_dump($genericObject); // note how var dump is similar to array's

    // special object members: __construct
    class fooWithCtor {
      function __construct() {
        $this->bar = 8;
        $this->memFun2 = function($arg) { $this->bar = $arg + 1; };
        ++fooWithCtor::$instanceCount;
      }
      function __destruct() {
        echo "executing fooWithCtor::__destruct";
        --fooWithCtor::$instanceCount;
      }
      function memFun($arg) { $this->bar = $arg + 1; }
      public static $instanceCount = 0;
    };
    assert(fooWithCtor::$instanceCount == 0);
    //assert((new fooWithCtor)->bar === 8); // this messes with $instanceCount
                                            // (destruction at end of func?)
    $x = new fooWithCtor;
    assert(fooWithCtor::$instanceCount == 1);
    $x->memFun(8);
    assert($x->bar === 9);
    // why doesn't this work?:
    //$x->memFun2(5);
    // See also http://php.net/manual/en/functions.anonymous.php 'lawbreaker' comment.
    // instead I have to either a)
    $fun = $x->memFun2; // this is the closure
    $fun(5);
    assert($x->bar === 6);
    // or b)
    call_user_func($x->memFun2, 7); // ugly
    assert($x->bar === 8);
    //var_dump($x); // prints memFun2 as a member that is a closure object
    assert(fooWithCtor::$instanceCount == 1);
    unset($x);
    unset($fun);
    gc_collect_cycles(); // not even that will ensure timely destruction (GC worker thread?)
                         // or who keeps the reference to fooWithCtor alive?
    //assert(fooWithCtor::$instanceCount == 0); // so dtor call is NOT deterministic unlike in C++

    // special object members: __call
    // TODO

    // call_user_func(), why is this necessary? Why not just use paren syntax?
    // Plenty more variants are at http://php.net/manual/en/language.types.callable.php
    $x = function($arg) { return $arg * 10; };
    assert(50 === call_user_func($x, 5));
    assert(50 === $x(5));


    // global
    $a = 1;
    function testLocal() {
      assert($a === null); // undefined, since local var $a is accessed here!
      assert($GLOBALS['a'] === 1); // not pretty imo, note that GLOBALS is one
                                   // of the superglobals
    }
    testLocal();
    function testGlobal() {
      global $a; // makes $a accessible in local scope
      assert($a === 1);
    }
    testGlobal();


    // static vars, same as C++: global vars accessible from within only
    // their defining func:
    $counter = function() {
      static $cnt = 0;
      ++$cnt;
      return $cnt;
    };
    assert($counter() === 1);
    assert($counter() === 2);


    // references, similar to C++ refs or C ptrs
    // From http://derickrethans.nl/talks/phparch-php-variables-article.pdf
    $x = 5;
    $y = &$x;
    $y = 6;
    assert($x === 6);
    // in addition to this assign-by-ref there's passing func args by ref
    // (out vars) and returning by ref. Dont overuse refs!


    // generators like in Python or JS:
    function gen() {
      yield 3;
      yield 6;
    }
    $sum = 0;
    foreach (gen() as $number)
      $sum += $number;
    assert($sum === 9);

    // python-style coroutines we also have (with Generator::send()).
    // semantics of send() exactly as in python.
    // One difference to python is generator init: the new gen immediately
    // has its first current() value, so unlike in python the gen doesnt need
    // to be 'primed'. And next() has no retval.
    function coro() {
      $val = (yield 3);
      yield $val * 10;
    }
    $genObj = coro();
    assert($genObj->current() == 3);
    assert($genObj->send(10) == 100);
    assert($genObj->next() == null); // next() is like send(null), same as python

    echo "SUCCESS";
?>
```
