# multicloud-gitops-with-takebishi

How to large scale deploy Takebishi Device Gateway on OpenShift with GitOps approach

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Live build status](https://util.hybrid-cloud-patterns.io/dashboard.php?pattern=mcgitops)

## Start Here

If you've followed a link to this repository, but are not really sure what it contains
or how to use it, head over to [Multicloud GitOps](http://hybrid-cloud-patterns.io/multicloud-gitops/)
for additional context and installation instructions

```bash
./pattern.sh make install
```

## Connection between hub and edge cluster

You can connect Kafka cluster in between hub and edge by usin Skupper.
Run the following command:

i) skupper token create in `hub cluster``
```bash
oc login https://HUBCLUSTER:6443
skupper token create ~/token.yaml
```

ii) skupper link create in `edge cluster
```bash
oc login https://EDGECLUSTER:6443
skupper link create ~/token.yaml
```

iii) expose kafka address from hub cluster to edge cluster
```bash
skupper expose service hub-cluster-kafka-bootstrap --address hub-cluster-kafka-bootstrap --port 9092
```
