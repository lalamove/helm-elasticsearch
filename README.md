# helm-elasticsearch
This is a fork by @lalamove merging the incubator elasticsearch chart found here: https://github.com/kubernetes/charts/tree/master/incubator/elasticsearch
together with some open pull requests on https://github.com/clockworksoul/helm-elasticsearch

## Features
 - RBAC support
 - Uses pires/docker-elasticsearch-kubernetes image which tracks ES release versions very well
 - Install Elasticsearch Addons through environment variable ES_PLUGINS_INSTALL
 - Latest version of Elasticsearch

## Deploying with Helm

With Helm properly installed and configured, standing up a complete cluster is almost trivial:

```
$ git clone https://github.com/lalamove/helm-elasticsearch.git elasticsearch
$ helm install elasticsearch
```

## Contributing

Please do! Taking pull requests.
