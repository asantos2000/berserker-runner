
## Berserker-runner

This image is based on [berserker-runner](https://github.com/smartcat-labs/berserker). Clone the repo and run `mvn clean package` to build and pack the berserker-runner jar (located at berserker-runner/target/berserker-runner-0.0.X-SNAPSHOT.jar).

## Configuring infra for testing

### Starting kafka stack

```
docker-compose up
```

### Configuring topics

```
kafka-topics --zookeeper 127.0.0.1:2181 --create --topic load-test-1 --partitions 1 --replication-factor 1
Created topic "load-test-1".

kafka-topics --zookeeper 127.0.0.1:2181 --create --topic load-test-3 --partitions 3 --replication-factor 1
Created topic "load-test-3".
```

### Starting consumers

```
# Terminal 1
kafka-console-consumer --bootstrap-server 127.0.0.1:9092 --topic load-test-3

# Terminal 2
kafka-console-consumer --bootstrap-server 127.0.0.1:9092 --topic load-test-1
```


### Configuring load-test config file
Ref: [More about Ranger data-soure configuration.](https://github.com/smartcat-labs/ranger)

> kafka-local.yml

```yml
load-generator-configuration:
  data-source-configuration-name: Ranger
  rate-generator-configuration-name: default
  worker-configuration-name: Kafka
  metrics-reporter-configuration-name: SimpleConsoleReporter
  thread-count: 4
  queue-capacity: 1000

data-source-configuration:
  values:
    values: circular([random(0.0..100),random(100..600),random(600..1000)])
    user:
      id: circular(1..2000000, 1)
      username: string("{}{}", random(["aragorn", "johnsnow", "mike", "batman"]), random(1..100))
      firstName: random(["Peter", "Rodger", "Michael"])
      lastName: random(["Smith", "Cooper", "Stark", "Grayson", "Atkinson", "Durant"])
      maried: false
      accountBalance: random(0.0..10000.0)
      address:
        city: random(["New York", "Washington", "San Francisco"])
        street: random(["2nd St", "5th Avenue", "21st St", "Main St"])
        houseNumber: random(1..55)
    kafkaMessage:
      key: randomContentString(10, ['A'..'Z', '0'..'9'])
      value: json($user)
  output: $kafkaMessage

rate-generator-configuration:
  rates:
    r: 100
  output: $r

worker-configuration:
  async: true
  topic: load-test-1
  producer-configuration:
    bootstrap.servers: localhost:9092

metrics-reporter-configuration:
```

## Running berserker

```bash
# Terminal 3
java -jar berserker-runner-0.0.12-SNAPSHOT.jar -c kafka-local.yml
```

## Building image

```bash
docker build -t adsantos/berserker-runner:0.0.12 .
```

### Running with docker

```bash
docker run -it --rm --name load-test --net=host -v $PWD:/config adsantos/berserker-runner:0.0.12 -c /config/kafka-local.yml
```

## Metrics gathering

Output of berserker-runner command (SimpleConsoleReporter).

```txt
7/11/18 11:11:35 AM ============================================================

-- Gauges ----------------------------------------------------------------------
io.smartcat.berserker.queueSize
             value = 0

-- Histograms ------------------------------------------------------------------
io.smartcat.berserker.failureResponseTime
             count = 0
               min = 0
               max = 0
              mean = 0.00
            stddev = 0.00
            median = 0.00
              75% <= 0.00
              95% <= 0.00
              98% <= 0.00
              99% <= 0.00
            99.9% <= 0.00
io.smartcat.berserker.failureServiceTime
             count = 0
               min = 0
               max = 0
              mean = 0.00
            stddev = 0.00
            median = 0.00
              75% <= 0.00
              95% <= 0.00
              98% <= 0.00
              99% <= 0.00
            99.9% <= 0.00
io.smartcat.berserker.successResponseTime
             count = 1000
               min = 947021
               max = 89474651
              mean = 3993507.16
            stddev = 8367130.50
            median = 2016793.00
              75% <= 3867500.00
              95% <= 8373695.00
              98% <= 20591170.00
              99% <= 48713345.00
            99.9% <= 88834825.00
io.smartcat.berserker.successServiceTime
             count = 1005
               min = 904610
               max = 89261494
              mean = 3566677.87
            stddev = 6590434.34
            median = 1974660.00
              75% <= 3758522.00
              95% <= 8338487.00
              98% <= 14445798.00
              99% <= 25680764.00
            99.9% <= 88812394.00
io.smartcat.berserker.totalResponseTime
             count = 1006
               min = 947021
               max = 89474651
              mean = 3994571.42
            stddev = 8349623.55
            median = 2016793.00
              75% <= 3829926.00
              95% <= 8463302.00
              98% <= 20591170.00
              99% <= 48713345.00
            99.9% <= 88834825.00
io.smartcat.berserker.totalServiceTime
             count = 1006
               min = 904610
               max = 89261494
              mean = 3566714.67
            stddev = 6586915.67
            median = 1975914.00
              75% <= 3758522.00
              95% <= 8338487.00
              98% <= 14445798.00
              99% <= 25680764.00
            99.9% <= 88812394.00
io.smartcat.berserker.waitTime
             count = 1006
               min = 15278
               max = 72161963
              mean = 427856.75
            stddev = 4474579.72
            median = 36419.00
              75% <= 55039.00
              95% <= 170005.00
              98% <= 437095.00
              99% <= 2535879.00
            99.9% <= 71817945.00

-- Meters ----------------------------------------------------------------------
io.smartcat.berserker.dropped
             count = 0
         mean rate = 0.00 events/second
     1-minute rate = 0.00 events/second
     5-minute rate = 0.00 events/second
    15-minute rate = 0.00 events/second
io.smartcat.berserker.failureProcessedThroughput
             count = 0
         mean rate = 0.00 events/second
     1-minute rate = 0.00 events/second
     5-minute rate = 0.00 events/second
    15-minute rate = 0.00 events/second
io.smartcat.berserker.generatedThroughput
             count = 1016
         mean rate = 99.62 events/second
     1-minute rate = 99.26 events/second
     5-minute rate = 99.21 events/second
    15-minute rate = 99.20 events/second
io.smartcat.berserker.successProcessedThroughput
             count = 1016
         mean rate = 99.59 events/second
     1-minute rate = 99.26 events/second
     5-minute rate = 99.21 events/second
    15-minute rate = 99.20 events/second
io.smartcat.berserker.totalProcessedThroughput
             count = 1016
         mean rate = 99.58 events/second
     1-minute rate = 99.26 events/second
     5-minute rate = 99.21 events/second
    15-minute rate = 99.20 events/second
```

Enjoy!