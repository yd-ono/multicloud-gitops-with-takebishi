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

## EdgeとFogの接続

### [Fog side] Skupper Tokenを作成
```bash
oc login --server https://api.fog-fog-$CLUSTERID.$BASEDOMAIN:6443 -u kubeadmin -p $PASSWORD
oc project kafka
skupper token create ~/token-fog2edge.yaml
```

### [Edge side] Skupper Linkの作成
```bash
oc login --server https://api.edge-edge-$CLUSTERID.$BASEDOMAIN:6443 -u kubeadmin -p $PASSWORD
oc project mqtt
skupper link create ~/token-fog2edge.yaml
skupper link status
```

```
Links created from this site:

         Link link1 is connected
```

### [Edge side] MQTT BrokerをFogへExpose

```bash
skupper expose statefulset amq-broker-ss --headless --target-port 61616
skupper service status
```

```
Services exposed through Skupper:
╰─ amq-broker-hdls-svc (tcp ports 8161 61616)
   ╰─ Targets:
      ╰─ ActiveMQArtemis=amq-broker,application=amq-broker-app name=amq-broker-ss namespace=mqtt
```

### [Fog side] 接続確認

![Kafdrop](./doc/images/kafdrop-fog.png)

## HubとFogの接続

### [Hub side] Skupper Tokenを作成

```bash
oc login --server https://api.$CLUSTERNAME.$BASEDOMAIN:6443 -u kubeadmin -p $PASSWORD
oc project kafka
skupper token create ~/token-hub2fog.yaml
```

### [Fog side] Skupper Linkの作成
```bash
oc login --server https://api.fog-fog-$CLUSTERID.$BASEDOMAIN:6443 -u kubeadmin -p $PASSWORD
oc project kafka
skupper link create ~/token-hub2fog.yaml
skupper link status
```

```
Links created from this site:

         Link link1 is connected
```

### [Hub side] Kafka BrokerのアドレスをFogへExpose

```bash
oc login --server https://api.$CLUSTERNAME.$BASEDOMAIN:6443 -u kubeadmin -p $PASSWORD
skupper expose statefulset/hub-cluster-kafka --headless --port 9092
skupper service status
```

```
Services exposed through Skupper:
├─ amq-broker-hdls-svc (tcp ports 8161 61616)
╰─ hub-cluster-kafka-brokers (tcp port 9092)
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
skupper expose service hub-cluster-kafka-bootstrap --address hub-cluster-kafka-bootstrap
```

### From Hub to Fog

```bash
vi ~/.odf/credentials
```

```bash
./pattern.sh make load-secrets
```

## ODF
```bash
oc label node <NodeName> cluster.ocs.openshift.io/openshift-storage=''
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
```

Create a S3 user
5.1. Method 1
To create a new S3 user interactively, log into the Ceph toolbox using the command below:

```
oc rsh -n openshift-storage $(oc get pod -n openshift-storage -l app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
```

Create a S3 user using the following command:

```
radosgw-admin user create --display-name="Your user" --uid=your-user
```

The output of the command will give you all the details for the newly create user, especially this part:

{
  "user": "your-user",
  "access_key": "XXXXXXXXXXXXXXXX",
  "secret_key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

```
oc exec -n openshift-storage $(oc get pod -n openshift-storage -l app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}') -- radosgw-admin user create --uid="<user-name>" --display-name="<Display Name>"
``