Tutorial at http://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html. Some HDFS http://hadoop.apache.org/docs/r1.2.1/hdfs_design.html
(customizable replication factor, rack-aware replication).

Installation as stand-alone for testing:
```
wget http://mirror.nexcess.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
tar xzf ...
bin/hadoop # Error: JAVA_HOME is not set and could not be found.
cat etc/hadoop/hadoop-env.sh
which java | xargs ls -l
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
export HADOOP_PREFIX=`pwd` # assuming we're in bin/hadoop parent dir
bin/hadoop # now shows usage
```

From http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html:
setup as standalone (for debugging)
```
$ mkdir input
$ cp etc/hadoop/*.xml input
$ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar grep input output 'dfs[a-z.]+'
$ cat output/*
```

Now running the Hadoop WordCount.java sample from the tutorial:
```
# See http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/CommandsManual.html
# for classpath options.
# Variant (a) for compiling with javac directly:
export CLASSPATH=`bin/hadoop classpath --glob` # freakishly long classpath btw
javac WordCount.java
export CLASSPATH=$CLASSPATH:.
java WordCount
# Variant (b) using bin/hadoop to compile (no need to set CLASSPATH, but need
# to set HADOOP_CLASSPATH so it can find javac's impl):
# P.S. this doesn't work for openjdk because there's no tools.jar and no
# com.sun...?
export HADOOP_CLASSPATH=$JAVA_HOME/lib/tools.jar # doesn't work with openjdk
../hadoop-2.6.0/bin/hadoop com.sun.tools.javac.Main WordCount.java

# now package as jar (why? is the jar shipped to the servers for execution?
# I think so)
jar cf wc.jar WordCount*.class

# now prepare sample data in hdfs
bin/hdfs dfs -ls /  # hdfs exposes / ?! in default config?
bin/hdfs dfs -ls /home/kschubert/hadoop/test/input # should be empty initially
echo "Hello World Bye World" > file01
echo "Hello Hadoop Goodbye Hadoop" > file02
bin/hdfs dfs -cat /home/kschubert/hadoop/test/input/file01 # "Hello ..."

# run app
bin/hadoop jar wc.jar WordCount /home/kschubert/hadoop/test/input /home/kschubert/hadoop/test/output

# show results
less output/part-r-00000
```

Now running Hadoop in Pseudo-Distributed Operation (see
http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html#Pseudo-Distributed_Operation):
```
vim etc/hadoop/core-site.xml
vim etc/hadoop/hdfs-site.xml

# Setup passphraseless ssh
#ssh-keygen
ssh-copy-id localhost

bin/hdfs namenode -format
# created /tmp/hadoop-kschubert/dfs/name dir
sbin/start-dfs.sh
#sbin/stop-dfs.sh
# this results in:
localhost: Error: JAVA_HOME is not set and could not be found
# is this https://issues.apache.org/jira/browse/HADOOP-7894 ?
# adding this here to .bashrc or /etc/profile didn't work either:
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
# Editing JAVA_HOME directly in hadoop-env.sh worked though:
vim ./etc/hadoop/hadoop-env.sh

# now sbin/start-dfs.sh works:
sbin/start-dfs.sh # prints:
Starting namenodes on [localhost]
localhost: starting namenode, logging to /home/kschubert/hadoop/hadoop-2.6.0/logs/hadoop-kschubert-namenode-ubuntu.out
localhost: starting datanode, logging to /home/kschubert/hadoop/hadoop-2.6.0/logs/hadoop-kschubert-datanode-ubuntu.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /home/kschubert/hadoop/hadoop-2.6.0/logs/hadoop-kschubert-secondarynamenode-ubuntu.out

curl http://localhost:9000 # prints:
It looks like you are making an HTTP request to a Hadoop IPC port. This is not the correct port for the web interface on this daemon.
# I guess that's just a TCP port then :)

# continue tutorial steps:
bin/hdfs dfs -mkdir /user
bin/hdfs dfs -mkdir /user/kschubert # this is where 'dfs -put' copies files?
bin/hdfs dfs -put etc/hadoop input
bin/hdfs dfs -ls /user/kschubert # shows copied ./input dir
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar grep input output 'dfs[a-z.]+'
rm -rf output
bin/hdfs dfs -get output output
cat output/*

# now try the same with WordCount example:
bin/hdfs dfs -rm -r -f input
bin/hdfs dfs -ls /user/kschubert
bin/hdfs dfs -put input input # creates hdfs /user/kschubert/input
# btw the "Hello world" data ends up in node's local disk here: /tmp/hadoop-kschubert/dfs/data/current/BP-1508548473-127.0.1.1-14254096963
17/current/finalized/subdir0/subdir0/blk_1073741856
bin/hdfs dfs -ls /user/kschubert
bin/hadoop jar wc.jar WordCount input output
bin/hdfs dfs -cat /user/kschubert/output/part-r-00000 # has wordcount results
```

Using Hadoop map-reduce from Python using Hadoop streaming API (instead of
Jython):
http://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/.
This will ship (shell, python, ...) scripts to the data nodes, similar to how
jar files presumably get sent to the data nodes when using Hadoop Java clients.
```
vim mapper.py
vim reducer.py
# test map/reduce scripts locally
echo "foo foo quux labs foo bar quux" | ./mapper.py
echo "foo foo quux labs foo bar quux" | ./mapper.py | sort -k1,1
echo "foo foo quux labs foo bar quux" | ./mapper.py | sort -k1,1 | ./reducer.py

# run map/reduce scripts on hadoop data nodes (using /home/kschubert/input used
# when running the Java map/reduce impl):
bin/hdfs dfs -rm -r -f /user/kschubert/output
bin/hadoop jar ./share/hadoop/tools/lib/hadoop-streaming-2.6.0.jar -mapper ../test/mapper.py -reducer ../test/reducer.py -input input -output output
```

Hadoop web interface
```
lsof -i
# shows various ports Hadoop listens on, e.g. for admin:
curl http://localhost:50090/
```

Some general info on distributed large graph processing, extending Hadoop:
http://www.ibm.com/developerworks/library/os-giraph/.

See also Apache Spark for a higher performance in-memory alternative to Hadoop,
some details at http://stackoverflow.com/questions/25267204/hadoop-vs-spark.
