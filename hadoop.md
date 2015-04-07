Tutorial at http://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html. Some HDFS http://hadoop.apache.org/docs/r1.2.1/hdfs_design.html
(customizable replication factor, rack-aware replication). Also see good
tutorial [here](https://developer.yahoo.com/hadoop/tutorial/module4.html).


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

# if you have no bin/hdfs availabe the use hadoop cmd directly:
# see http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/FileSystemShell.html
hadoop fs -ls -R hdfs://some-machine.VOL1:9000/some-dir
hadoop fs -tail hdfs://some-machine.VOL1:9000/some-dir

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

So where Hadoop streaming with 'key \t value \n' format on stdin & stdout
allows writing mappers & reduces in any lang (bash, py)  https://developer.yahoo.com/hadoop/tutorial/module4.html also talks about Hadoop
pipes for writing mappers & reducers in C++. Not sure what the advantage of
Hadoop pipes over Hadoop streaming is.

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

"Hadoop the definite guide" is a downloadable pdf, see
http://ce.sysu.edu.cn/hope/UploadFiles/Education/2011/10/201110221516245419.pdf.
Mentions some details on Hadoop + Hive usage at Facebook: general data store,
log data store. Also has plenty of info on Hadoop extensions: Pig, Sqoop.

Data import into hdfs via Java API: see
http://www.slideshare.net/martyhall/hadoop-tutorial-hdfs-part-3-java-api
```
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;

public class TestImport {
  public static void main(String[] args) throws Exception {
    // quick demo listing hdfs files, from
    // http://www.slideshare.net/martyhall/hadoop-tutorial-hdfs-part-3-java-api?related=2
    Configuration conf = new Configuration();
    conf.set("fs.default.name", "hdfs://localhost:9000");
    FileSystem hdfs = FileSystem.get(conf);
    // or FileSystem hdfs = FileSystem.get( new URI( "hdfs://localhost:5000" ), configuration );
    FileStatus[] files = hdfs.listStatus(new Path("/user"));
    for (FileStatus file : files) {
      System.out.println("hdfs file: " + file.getPath().getName());
    }

    // test code for writing data to single file:
    {
      Path path = new Path("/user/kschubert/testImport");
      //FSDataOutputStream out = hdfs.create(path); // err if exist
      //FSDataOutputStream out = hdfs.append(path); // err if nonexist
      boolean overwrite = true;
      FSDataOutputStream out = hdfs.create(path, overwrite);
      out.writeUTF("hello\n");
      out.writeInt(123);
      out.close();
      // print content like that:
      // $HADOOP_PREFIX/bin/hdfs dfs -cat /user/kschubert/testImport
    }
  }
}
```
Compile & run this via:
```
export CP_HADOOP=`$HADOOP_PREFIX/bin/hadoop classpath --glob`
export CLASSPATH=.:$CP_HADOOP
javac TestImport.java

# make sure hadoop is running locally
cat $HADOOP_PREFIX/etc/hadoop/core-site.xml # should be localhost:9000
$HADOOP_PREFIX/sbin/start-dfs.sh # only if not running yet
curl http://localhost:9000 # its not an HTTP port, but a decent test for if Hadoop's running

# now run test import against localhost:9000
java TestImport
```

Now after importing the data we can access it via hdfs FSDataInputStream from
Java of course. E.g. see
http://www.slideshare.net/martyhall/hadoop-tutorial-mapreduce-on-yarn-part-1-overview-and-installation
for how to process the data with Hadoop 2's yarn. So org.apache.hadoop.mapred
is the old Hadoop 1 map-reduce API, org.apache.hadoop.mapreduce is the new
Hadoop 2 API. How to read the input files for MapReduce jobs? See
http://www.slideshare.net/martyhall/hadoop-tutorial-mapreduce-part-4-input-and-output
slides around slide 15 for info on InputFormat: this seems to deserialize the
hdfs file into pairs of key/value records. TextInputFormat is the default input
format: assumes utf8, breaks file on \n delimiters. See also
https://issues.apache.org/jira/browse/MAPREDUCE-232 for attempts to generalize
this. Other InputFormats besides TextInputFormat are:

* NLineInputFormar
* TableInputFormat (HBASE)
* StreamInputFormat
* [SequenceFileInputFormat](http://hadooptutorial.info/tag/full-fileinputformat-example-hadoop-sequence-file-input-format/)
* your [custom InputFormat](https://developer.yahoo.com/hadoop/tutorial/module5.html#inputformat)

```
$HADOOP_PREFIX/sbin/start-yarn.sh
lsof -i shows additional ports now, around default ports 8xxxx

# test yarn with builtin example:
$HADOOP_PREFIX/bin/yarn jar $HADOOP_PREFIX/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar pi 5 1000
$HADOOP_PREFIX/bin/mapred job -list # funky exception in 2.6 (with no jobs running)

# now run variant of http://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html applied to example data written above.
TODO
```

What happens when for TextInputFormat there's a record (line) split across the
64MB block boundary? See
http://stackoverflow.com/questions/14291170/how-does-hadoop-process-records-records-split-across-block-boundaries. So looks like there's a (usually) small number of remote reads going
on in each mapper to fetch bytes across block boundaries from a remove data node?

Links:
* [MapReduceAlgorithms](https://github.com/lintool/MapReduceAlgorithms/blob/master/MapReduce-book-final.pdf)
