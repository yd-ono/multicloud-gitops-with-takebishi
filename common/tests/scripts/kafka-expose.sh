#!/bin/bash

cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Service
metadata:
  labels:
    strimzi.io/component-type: kafka
  name: cluster1-kafka-0
spec:
  ports:
  - name: tcp-clients
    port: 9092
    protocol: TCP
    targetPort: 9092
  publishNotReadyAddresses: true
  selector:
    strimzi.io/cluster: cluster1
    strimzi.io/kind: Kafka
    strimzi.io/name: kafka
    strimzi.io/pod-name: cluster1-kafka-0
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  labels:
    strimzi.io/component-type: kafka
  name: cluster1-kafka-1
spec:
  ports:
  - name: tcp-clients
    port: 9092
    protocol: TCP
    targetPort: 9092
  publishNotReadyAddresses: true
  selector:
    strimzi.io/cluster: cluster1
    strimzi.io/kind: Kafka
    strimzi.io/name: cluster1-kafka
    strimzi.io/pod-name: cluster1-kafka-1
  sessionAffinity: None
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  labels:
    strimzi.io/component-type: kafka
  name: cluster1-kafka-2
spec:
  ports:
  - name: tcp-clients
    port: 9092
    protocol: TCP
    targetPort: 9092
  publishNotReadyAddresses: true
  selector:
    strimzi.io/cluster: cluster1
    strimzi.io/kind: Kafka
    strimzi.io/name: kafka
    strimzi.io/pod-name: cluster1-kafka-2
  sessionAffinity: None
  type: ClusterIP
---
EOF

for name in `oc get svc  -l strimzi.io/component-type=kafka -o=custom-columns=NAME:.metadata.name | grep kafka` ; do
	skupper service create ${name} 9092
	skupper service bind ${name} service ${name}.test2.svc.cluster.local --target-port 9092
done

oc run client --attach --rm --restart Never --image quay.io/skupper/kafka-example-client \
--env BOOTSTRAP_SERVERS=cluster1-kafka-bootstrap:9092
