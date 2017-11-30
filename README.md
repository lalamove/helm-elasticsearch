# helm-elasticsearch
This is a fork by @lalamove merging the incubator elasticsearch chart found here: https://github.com/kubernetes/charts/tree/master/incubator/elasticsearch
together with some open pull requests on https://github.com/clockworksoul/helm-elasticsearch

## Features
 - RBAC support
 - TLS support using Kubernetes certificate API
 - Elasticsearch Curator (to prune old indicies)
 - Install Elasticsearch Addons through init container
 - Compatible with any vanilla elasticsearch install
 - Latest version of Elasticsearch in an Alpine image (blacktop/elasticsearch)

## Deploying with Helm

Read the comments in values.yaml and customise them to suit your needs. The sizes and resource limits are suitable for a minikube deploy. Production deploys will require significantly more resources.
With Helm properly installed and configured, standing up a complete cluster is almost trivial:

```
$ git clone https://github.com/lalamove/helm-elasticsearch.git elasticsearch
$ helm install elasticsearch
```

## Enabling TLS
If you enable TLS you need to keep two things in mind. First, make sure the `clusterDomain` is correct. And second, make sure you approve the certificate requests by using `kubectl certificate approve ...`

## Contributing

Please do! Taking pull requests.
