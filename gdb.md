r(un) <args>
b(reak) file:line
catch throw
c(ont)
f(inish) # aka step out (of current func)
s(tep into)
n(ext)
info locals
info args
p(rint) <var> # or expression like *ptr or ptr[5]
p $1 # prints previously printed var again
p(rint)t(ype) <var>
set <var> = 10

# prevent thread switch during n(ext)
set scheduler-locking on
