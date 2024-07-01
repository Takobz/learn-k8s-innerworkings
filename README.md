# Learning Kubernetes Inner workings.
This repo is used as a means of documentating my learning of Kubernetes mainly using the [Core Kubernetes](https://www.manning.com/books/core-kubernetes) book.

## Tools used here.
For mimicing a Kubernetes environment locally, the following tools where used:
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) - for creating local cluster
- [Docker](https://www.docker.com/) - For creating Nodes in my K8s environment
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) - For interacting with the cluster.

The examples and notes here will be using `kind` as the cluster type, meaning that our Nodes will be normal docker containers that run the kubelet within them. In the real world K8s Nodes are not limited to Docker containers, and most cases they aren't even Docker containers, they are actual VMs/Physical Machines.

**NOTE: I was using a Linux environment to do all this playing around**

## Frequetly Used Commands:
Here I will keep updating with commands I used while learning:

- Delete Cluster:
```bash
# delete a cluster on the local machine
kind deleter cluster --name=<name-of-cluster>
```
- Create Cluster:
```bash
# create a new cluster on the local machine
# creation of a cluster will create a node for us, which is a docker container.
kind create cluster
```
