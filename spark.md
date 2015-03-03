Installation
===
```
# http://blog.prabeeshk.com/blog/2014/10/31/install-apache-spark-on-ubuntu-14-dot-04/
# installs oracle Java7, I alrdy had openjdk installed for Hadoop tutorial,
# so skipped that Oracle step.

# install Scala
wget http://www.scala-lang.org/files/archive/scala-2.10.4.tgz
sudo mkdir -p /usr/local/src/scala
sudo tar xvf scala-2.10.4.tgz -C /usr/local/src/scala
# append to ~/.bashrc:
export SCALA_HOME=/usr/local/src/scala/scala-2.10.4
export PATH=$SCALA_HOME/bin:$PATH

source ~/.bashrc
scala -version

# http://spark.apache.org/downloads.html: if you don't plan to use
# HDFS the choice of 'built for Hadoop' version won't matter?
# The spark.tgz download is strangely enormous (200MB), why?
wget http://d3kbcqa49mib13.cloudfront.net/spark-1.2.1-bin-hadoop2.4.tgz
tar xvf spark*
cd spark-1.2.1-bin-hadoop2.4
bin/spark-shell # scala shell
bin/run-example SparkPi 10 # some example app
bin/pyspark # python shell
```

Using Spark via Scala:
===
See https://spark.apache.org/docs/0.9.0/scala-programming-guide.html and
https://spark.apache.org/examples.html.
Primary abstraction is distributed collection of Resilient Distributed Datasets
(RDDs), typically (but not necessarily) stored in Hadoop's HDFS. Unlike Hadoop
Spark makes use of in-memory caching (of RDDs?) for faster computation.

First start HDFS node, containing the same data as I used during Hadoop
WordCount.java tutorial:
```
cd hadoop...
sbin/start-dfs.sh
bin/hdfs dfs -ls /user/kschubert/input # lists 2 files
bin/hdfs dfs -cat /user/kschubert/input/file01 # Hello World ...
```

Let Spark access these HDFS files:
```
bin/spark-shell
val textFile = sc.textFile("hdfs://localhost:9000/user/kschubert/input/file01")
textFile.first() # Hello World
# BTW this 9000 is listed in
# grep -r 9000 etc/hadoop/
# etc/hadoop/core-site.xml:        <value>hdfs://localhost:9000</value>

# now execute the Hadoop WordCount example via Spark, code at
# https://spark.apache.org/examples.html
val textFile = sc.textFile("hdfs://localhost:9000/user/kschubert/input/file01")
# P.S.: if you specify a glob expr in the filename (as "".../file*") then you
# can easily iterate over file01, file02 and so on, exactly like the Hadoop
# WordCount example did. You can also specify a dir name as the param for
# textFile, in which case you iterate over all files in the dir. Not sure
# if the calculation automatically is going to be distributed that way, I
# assume so.
val counts = textFile.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)
# here _+_ is syntactic Scala sugar for closure (a, b) => a + b ?
counts.saveAsTextFile("hdfs://localhost:9000/user/kschubert/output/sparkout")
# print output via shell:
bin/hdfs dfs -cat /user/kschubert/output/sparkout/part-00000 # prints:
(Bye,1)
(Hello,1)
(World,2)
```

Now instead of using interactive Scala shell do the same via self-contained
Spark app written in Scala:
```
# from http://spark.apache.org/docs/1.2.0/quick-start.html:
vim src/main/scala/SimpleApp.scala # paste (and put in abs path for Readme.md)
vim simple.sbt # paste
# install sbt, which is not part of scale tgz?
# See http://www.scala-sbt.org/release/tutorial/Installing-sbt-on-Linux.html
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-get update
sudo apt-get install sbt
# fails with
#E: Method https has died unexpectedly!
#E: Sub-process https received a segmentation fault.
# Is this a problem with openjdk? Just guessing.
sbt package # cannot execute without sbt installed :) TODO
```

Of course this code above only accesses file01, whereas the Hadoop sample
iterated over all files in the hdfs dir (file01 and file02). How to do the
same via Spark? TODO

Using Spark from Python 2
===

Python 3 is still not supported?! Apparently uses http://py4j.sourceforge.net/
for interop with JVM.
See https://spark.apache.org/docs/0.9.0/python-programming-guide.html.
Lets try interactive bin/pyspark first:
```
textFile = sc.textFile("hdfs://localhost:9000/user/kschubert/input/file01")
textFile.first() # prints hello world
counts = textFile.flatMap(lambda line: line.split(" ")).map(lambda word: (word, 1)).reduceByKey(lambda a,b: a+b)
help(counts)
print(counts) # not very useful
counts.toDebugString() # pretty verbose (processing chain?)
counts.top(5) # prints conveniently
counts.saveAsTextFile("myrdd") # thats a dirname, content is myrdd/part-00000
```
So this is very similar to the Scala experience (with some funcs missing in
Python still).

Now run standalone app, non-interactive: see
https://spark.apache.org/docs/0.9.0/quick-start.html#a-standalone-app-in-python.

```
vim SimpleApp.py
bin/pyspark kjell/SimpleApp.py
```

Now how to submit a map-reduce script to an hdfs Hadoop/Spark cluster? I want
to run the Hadoop WordCount.java equivalent with Spark. See
https://spark.apache.org/docs/0.9.0/quick-start.html#a-standalone-app-in-python
"Running on a cluster"
TODO
