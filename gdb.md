gdb --args <prog> <args>


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
set variable i = 10
# prevent thread switch during n(ext)
set scheduler-locking on

# print mem content as string
x/520c 0x7f6fec545000 # crappy formatting
dump binary memory crash_req 0x7f6fec545000 0x7f6fec545000+520

# https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerAndDebugger
b(reak) __asan_report_error

