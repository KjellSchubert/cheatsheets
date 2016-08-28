Initial goal was trying to use Spark SQL on a Hive DB, but Spark 2.0 doesn't come with Hive support out of the box, so running Spark SQL on top of HDFS file directly instead:

```
# http://www.michael-noll.com/tutorials/running-hadoop-on-ubuntu-linux-multi-node-cluster/
vim $HADOOP_HOME/etc/hadoop/hadoop-env.sh # add JAVA_HOME, funky
hadoop namenode -format # before 1st start or after corruption
$HADOOP_HOME/sbin/start-all.sh
netstat -tulpn | grep java
jps
```

Testing Hive:
```
hadoop fs -ls /
hadoop fs -mkdir /temp
hadoop fs -mkdir -p /user/hive/warehouse
schematool -initSchema -dbType derby # run before running hive for the 1st time
hive
create table cars (make STRING, model STRING);
show tables;
insert into cars (make, model) values ('toyota', 'corolla');
select * from cars;
```

Testing Presto to query Hive:
```
# install presto https://prestodb.io/
# https://prestodb.io/docs/current/connector/hive.html didn't get this to run
```

Testing Spark SQL on top of Hive tables/metastore:
```
# Spark SQL CLI (also for accessing Hive tables, but need to build Spark with extra opts):
# install version without integrated hadoop
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
vim $SPARK_HOME/conf/spark-env.sh
  export HADOOP_HOME=/usr/local/hadoop
    export SPARK_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
      export HADOOP_CONF_DIR=/etc/hadoop/conf
      $SPARK_HOME/sbin/start-all.sh
      $SPARK_HOME/bin/spark-sql
# => http://stackoverflow.com/questions/38582919/cdh5-4-2-spark-can-use-hivecontent-in-spark-shell-but-cant-open-spark-sql
```

Not gonna bother with custom Hive-enabled Spark build, using Spark SQL directly on HDFS instead:
```
$HADOOP_HOME/sbin/start-dfs.sh # don't need Yarn
printf 'ford,prefect,15000\nford,f150,30000' | hdfs dfs -appendToFile - /cars.txt
hdfs dfs -cat /cars.txt
$SPARK_HOME/bin/spark-shell

case class Car(make: String, model: String, price: Int)
val carsDF = sc.textFile("hdfs://localhost:9000/cars.txt").map(_.split(",")).map(cols => Car(cols(0), cols(1), cols(2).trim.toInt)).toDF()
carsDF.createOrReplaceTempView("cars")
val someCarsDF = spark.sql("SELECT * FROM cars")
someCarsDF.map(car => "Model: " + car(1).show()
spark.sql("SELECT * FROM cars WHERE price > 20000 LIMIT 10").show()
```

