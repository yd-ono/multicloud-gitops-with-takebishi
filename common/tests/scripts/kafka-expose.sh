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
    strimzi.io/name: cluster1-kafka
    statefulset.kubernetes.io/pod-name: cluster1-kafka-0
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
    statefulset.kubernetes.io/pod-name: cluster1-kafka-1
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
    strimzi.io/name: cluster1-kafka
    statefulset.kubernetes.io/pod-name: cluster1-kafka-2
  sessionAffinity: None
  type: ClusterIP
---
EOF

oc annotate service cluster1-kafka-0 skupper.io/proxy=tcp
oc annotate service cluster1-kafka-1 skupper.io/proxy=tcp
oc annotate service cluster1-kafka-2 skupper.io/proxy=tcp
skupper expose service cluster1-kafka-bootstrap --address cluster1-kafka-bootstrap-ex --protocol tcp


oc run client --attach --rm --restart Never --image quay.io/skupper/kafka-example-client \
--env BOOTSTRAP_SERVERS=cluster1-kafka-bootstrap-ex:9092
