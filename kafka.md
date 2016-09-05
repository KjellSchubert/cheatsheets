http://blog.cloudera.com/blog/2014/09/apache-kafka-for-beginners/

* Kafka topic is approx like a Scribe category
* Kafka consumer group to partition message queue

Hello World
---

echo "Hello World" | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic FooTopic
$KAFKA_HOME/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic FooTopic [--from-beginning]  # tails

How to stream log file to Kafka:
---

for i in {1..10}; do printf "log line $i\n"; sleep 1; done | $KAFKA_HOME/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic FooTopic

How to stream Kafka topic to hdfs:
---

https://spark.apache.org/docs/latest/streaming-kafka-integration.html
https://community.cloudera.com/t5/Data-Ingestion-Integration/Stream-data-from-Kafka-to-HDFS/td-p/40731
http://blog.cloudera.com/blog/2014/03/letting-it-flow-with-spark-streaming/ # haha, Russell's post

Crappy:
* $KAFKA_HOME/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic FooTopic | $HADOOP_HOME/bin/hdfs dfs -appendToFile - /kafka/streamFooTopic
* $HADOOP_HOME/bin/hdfs dfs -cat /kafka/streamFooTopic

