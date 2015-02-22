good online tutorial: http://www.codecademy.com/en/tracks/php

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
    echo "\ncalling libfunc: ", libfunc("zzz");
    
    // other
?>
```
Unit testing: http://stackoverflow.com/questions/282150/how-do-i-write-unit-tests-in-php