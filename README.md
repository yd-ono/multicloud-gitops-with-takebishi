# multicloud-gitops-with-takebishi

Large scale deployment Takebishi Device Gateway on OpenShift with GitOps approach

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Live build status](https://util.hybrid-cloud-patterns.io/dashboard.php?pattern=mcgitops)


## Getting Started

If you've followed a link to this repository, but are not really sure what it contains
or how to use it, head over to [Multicloud GitOps](http://hybrid-cloud-patterns.io/multicloud-gitops/)
for additional context and installation instructions

i) Fork this Git repository to your Git account.

ii) copy a `values-secret.yaml` to any path and edit your own configuration

```bash
cp values-secret.yaml.template ~/values-secret.yaml
vi ~/values-secret.yaml
```

iii) modify `value-hub.yaml` file
Change `clusterGroup.managedClusterGroups.clusterPools.baseDomain` to the appropriate value.

iv) run `pattern.sh` as follows:

```bash
./pattern.sh make install
```

Once you run `pattern.sh`, a `pattern` operator is installed onto your OpenShift Cluster.
A `pattern` operator is configured as using your Git repo path.

> If you are using MAC OS, you need to install podman-desktop.

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
skupper expose service hub-cluster-kafka-bootstrap --address hub-cluster-kafka-bootstrap
```

### From edge to Fog

```bash
skupper expose statefulset amq-broker-ss --headless --target-port 61616
```

### From Hub to Fog

```bash
skupper expose service hub-cluster-kafka-bootstrap --address hub-cluster-kafka-bootstrap
```

```bash
vi ~/.odf/credentials
```

```bash
./pattern.sh make load-secrets
```