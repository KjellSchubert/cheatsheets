Building
---

Follow https://github.com/facebook/fbthrift readme.md instructions, so apt-get install deps listed for fbthrift, as well as deps for folly. Sadly the

```
cd fbthrift/thrift
./deps.sh
```

cmd seq didn't work for me on Ubuntu 14, where it exited with "Please install folly library". So after this failed I executed the remaining ./deps.sh manually:

```
cd fbthrift/thrift/folly/folly
sudo make install
cd /fbthrift/thrift
autoreconf --install
CPPFLAGS=" -I`pwd`/folly/" LDFLAGS="-L`pwd`/folly/folly/.libs/" ./configure
make # or make -j8
```

Docu entry point is at https://github.com/facebook/fbthrift/blob/master/thrift/doc/Cpp2.md,
points to older Apache-thrift docu. I wanted to write a hello-world sample that
lets C++ interact with Python. My first problem: where's the idl compiler for
generating C++ & Python proxy/stub code?

```
find . -executable -name thrift
```

No hits. Default make target doesn't build IDL compiler?

BTW I didn't know that on Ubuntu I can simply:
```
sudo apt-get install thrift-compiler
```
But I want to build & run from source. So:
```
cd fbthrift/thrift/compiler
cat README
#./bootstrap.sh
#./configure
make
sudo make install
```

Still no 'thrift' executable available on cmd line. Time to look at
https://github.com/facebook/fbthrift/tree/master/thrift/tutorial
Still not very enlightening. Supposedly the older C++ compiler was replaced
with a Python compiler? Where is it though?

```
thrift1 # is this even the new compiler? Doubt that.
# yields: error while loading shared libraries: libfolly.so.24: cannot open shared object file: No such file or directory
find /usr/local/lib/ -name "*folly*"
# lists /usr/local/lib/libfolly.so.24
ls -l /usr/local/lib/libfolly.so.24 # shows 20ish MB file
ldd `which thrift1`
# => libfolly.so.24 => not found
# => http://stackoverflow.com/questions/17889799/libraries-in-usr-local-lib-not-found
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
thrift1 # works now
```

Now create sample idl file TestService.thrift with sample service at
https://github.com/facebook/fbthrift/blob/master/thrift/doc/Cpp2.md, then:
```
thrift1 -r --gen cpp TestService.thrift
# from http://stackoverflow.com/questions/23121808/how-to-use-thrift-java-code-generator-with-multiple-generator-options
thrift1 -r --gen py:asyncio,new_style TestService.thrift
```

This generates dirs gen-cpp and gen-py. Trying python server & client first,
using https://github.com/facebook/fbthrift/tree/master/thrift/tutorial/py.asyncio
as a template. Or rather run the tutorial first. TODO
