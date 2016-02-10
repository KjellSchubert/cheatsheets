Install:
---

On centos via

>yum install -y haskell-platform
>vim ~/.haskeline # append line: editMode: Vi

On osx via

>brew install ghc cabal-install

Package manager Cabal:
---

The package repo is [Hackage](https://hackage.haskell.org), the package
manager is [Cabal](http://bob.ippoli.to/archives/2013/01/11/getting-started-with-haskell/).
The equivalent of Python virtualenv is cabal sandbox.

```
# From https://wiki.haskell.org/How_to_write_a_Haskell_program
cabal sandbox init
edit Haq.hs
cabal init  # creates Haq.cabal, or faster:
cabal init -n --is-executable --license=MIT
cabal install json
cabal install -j
.cabal-sandbox/bin/Haq foo
cabal freeze # for freezing dep versions for prod builds

# add json dep to Haq.cabal:
  build-depends:       base >=4.8 && <4.9, json >=0.9
cabal repl
>import Text.JSON

# or ad-hoc compilation
ghc Haq.hs
./Haq foo

# or run in single step
runhaskell Haq.hs

# or load into interpreter repl
ghci Haq.hs
```


Testing
---


Links:
---

* ghc, ghci basics at https://wiki.haskell.org/Haskell_in_5_steps
* http://learnyouahaskell.com/introduction
* http://bob.ippoli.to/archives/2013/01/11/getting-started-with-haskell/
* https://wiki.haskell.org/How_to_write_a_Haskell_program
* https://www.haskell.org/hoogle/
* http://www.reddit.com/r/haskell/comments/3dnrpl/why_are_people_using_scala_when_there_is_haskell/
* https://hackage.haskell.org/package/pipes-4.0.0/docs/Pipes-Tutorial.html

Notes:
---


```
import Data.List (sort)
let minima k xs = take k (sort xs) # only need 'let' in ghci ?
minima 2 [1, 5, 99, 3, 77]  # [1, 3]
minima 2 [1, 5, 99, 3, 77, "foo"]  # error
    No instance for (Num [Char])
      arising from the literal `77'
    Possible fix: add an instance declaration for (Num [Char])
map show [1..3] # ["1","2","3"]
:t map  # shows type of map in ghci: map :: (a -> b) -> [a] -> [b]
:t map (+1)  # Enum b => [b] -> [b]
(map succ) [1,5]  # [2,6]
(map (+1)) [1,5]  # same
:i map  # more details than :t
:i decode  # decode :: JSON a => String -> Result a   -- Defined in ‘Text.JSON’


# https://wiki.haskell.org/Introduction_to_Haskell_IO/Actions
# So funcs with side effects are 'Actions', which are treated as values, just
# like 77, "foo", sort.
# putStrLn :: String -> IO ()
# PutStrLn takes an argument, but it is not an action. It is a function that
# takes one argument (a string) and returns an action of type IO ().
# So putStrLn is not an action, but putStrLn "hello" is. 
let action = putStrLn "hello"  # doesn't print
action # prints
action # prints again

# The arrow <- indicates that the result of an action is being bound.
line <- getLine  # run in ghci to have it read a line from stdin

:t ()  # () :: ()
:t 100  # 100 :: Num a => a

# return is a function that takes any type of value and makes an action that 
# results in that value (does not affect the control flow of the program!)
# There is no way to take an IO action and extract just its results to a simple
# value (an inverse return), you can only pass the value to another IO action
# (e.g. putStr).See https://wiki.haskell.org/Introduction_to_Haskell_IO/Actions

# put this in hello.hs
module Main where
main :: IO ()  # main also returns a single IO action, which the RT execs
main = putStrLn "hello"
>ghc hello.hs  
>./hello # prints hello

# combining actions with 'do' block
let x = do putStr "a"; putStr "b"
x # prints "ab"
# The result of a do-block is the result of the last action in the do block,
# here IO ()

# pattern matching in ghci: let and ;
let factorial n | n < 2 = 1; factorial n = n * factorial (n - 1)

# prefix notation for binary ops usually written in infix:
(*) 5 6
(*5) 6

not True  # not is a func, there's no C ! operator
5 /= 6  # like C !=
[1,2]++[3]
1:[] # : is (List) Cons(truct) infix operator
1:2:3:[]
1:(2:(3:[]))
:i :  # infixr 5 :  
'a':""  # string as list of char, with "" being an empty list of chars
show 7  # toString
length [1,7]  # 2
lines "fi\nfo"  # split on \n => 2 
succ 'a'
[1,2] :: [Int]  # specify type instead of letting compiler deduce it
[1,2] :: [Double]
compare 2 3  # LT
# :t LT
LT :: Ordering
let x = [1,2,3]
head x : tail x # same list
# type [Foo] is list of Foo, type [a] is list template<typename a>
:t ('a', 5) # Num t => (Char, t), like template typename t with t being Numeric :t () # unit,sort of like C void, so () is the value and the type (see also [])

# lambda expr notation with \
filter (\num -> num < 10) [1,3,12,5,14]  # [1,3,5]
let cond = \num -> num < 10  # alt: let cond num = num < 10
# or let cond = (<10) # not (<) 10
cond 10 # False

# unlines (like "".join) as the reverse of lines (like str.split('\n'))
unlines (lines "ab\n\nc\nde") # same

# curry: Putting a space between two things is simply function application.
# The space is sort of like an operator and it has the highest precedence.
(max 4) 5 # <=> max 4 5 

compare 10 6 => GT

# list comprehension similar as in python:
[x+3 | x <- [1,5,3,1,6]] <=> map (+3) [1,5,3,1,6] 
# <=> python's [x+3 for x in [1,5,3,1,6]]
# or with condition for [x for x in range(1,10) if x%2 == 0]
[x | x <- [1..10], odd x]

# example filter with guards, as a neat syntax for a long repeated if then else
# or switch statement
filter :: (a -> Bool) -> [a] -> [a]  
filter _ [] = []  
filter p (x:xs)   
    | p x       = x : filter p xs  
    | otherwise = filter p xs 

# backticks to call (or define) func with infix syntax
3 `myCompare` 2  

$ 
. for function composition f(g(g)) <=> f . g x

data PersonInfo = Person String String -- first, last # type name, ctor name
data Person = Person String String -- usually type name & ctor func name are ==
data Bool = False | True  # like C enum

-- more complex type:
type CardHolder = String  # like C typedef
type CardNumber = String
type Address = [String]
data BillingInfo = CreditCard CardNumber CardHolder Address
                 | CashOnDelivery
                 | Invoice CustomerID
data Cartesian2D = Cartesian2D Double Double
                   deriving (Eq, Show) # Eq generates funcs

-- records: syntactic sugar that auto-gens accessor funcs
data Customer = Customer {
      customerID      :: CustomerID  -- prop :: Type
    , customerName    :: String
    , customerAddress :: Address
    } deriving (Show)A

-- parameterized/polymorphic/generic types (like template<class a> in C++)
data Maybe a = Just a
             | Nothing

-- recursive generic types 
data List a = Cons a (List a)
            | Nil
              deriving (Show)
data Tree a = Node a (Tree a) (Tree a)
            | Empty
              deriving (Show)

-- execption
mySecond xs = if null (tail xs)
              then error "list too short"
              else head (tail xs)

import Data.Ratio # rational numbers
2%3 + 1%3  # 1%1 

-- comment

# getLine :: IO String
# See stdio.hs for example reading IO in a loop. Note that indent is 
# similarly important as for Python (indent & dedent the last line to
# get different compiler errors or endless loops).

import Control.Monad (replicateM_, replicateM)
replicate 3 "foo" # ["foo","foo","foo"]
replicateM 3 (putStr "foo") # foofoofoo[(),(),()]
replicateM_ 3 (putStr "foo") # foofoofoo
putStr (concat $ replicate 3 "foo")

lines (readFile "LICENSE") # Couldn't match type ‘IO String’ with ‘[Char]’


# TODO
import Network.Http.Client

# TODO Interesting approach to concurrency: `par` `seq`  

```

