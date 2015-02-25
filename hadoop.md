Tutorial at http://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html

Installation as stand-alone for testing:
```
wget http://mirror.nexcess.net/apache/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz
tar xzf ...
bin/hadoop # Error: JAVA_HOME is not set and could not be found.
cat etc/hadoop/hadoop-env.sh
which java | xargs ls -l
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
export HADOOP_PREFIX=`pwd` # assuming we're in bin/hadoop parent dir
bin/hadoop # now shows usage
```
