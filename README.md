## Bugsink Helm Charts

[![GitHub License](https://img.shields.io/github/license/bugsink/helm-charts)](https://github.com/bugsink/helm-charts/blob/main/LICENSE)
[![GitHub Tests](https://github.com/bugsink/helm-charts/workflows/test/badge.svg)](https://github.com/bugsink/helm-charts)

[![GitHub Release](https://img.shields.io/github/v/release/bugsink/helm-charts?filter=bugsink/*)](https://github.com/bugsink/helm-charts/tree/main/charts/bugsink)

Helm charts for deploying Bugsink and its related applications on Kubernetes using [Helm](https://github.com/helm/helm).

## Before you begin

### Prerequisites

- A running Kubernetes cluster
- Kubectl installed and configured for that cluster
- Helm installed (See [here](#helm) for details on Helm.)

### Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm`
binary is in the `PATH` of your shell.

## Quick Start

To start using Bugsink Helm charts, you first need to add the Bugsink Helm chart repository to your list of Helm
repositories. To do this, execute the following command in your terminal:

```console
helm repo add bugsink https://bugsink.github.io/helm-charts
```

After adding the repository, proceed with initiating an update from it to retrieve the latest charts:

```console
helm repo update bugsink
```

Now you can install any chart using the following syntax:

```console
helm install my-release bugsink/my-chart
```

### Installing Bugsink

To install [Bugsink](https://www.bugsink.com) using its Helm chart, execute the following command:

```console
helm install bugsink bugsink/bugsink \
    --set "baseUrl=https://bugsink.example.com" \
    --namespace bugsink --create-namespace
```

Refer to the Bugsink chart [values](https://github.com/bugsink/helm-charts/blob/main/charts/bugsink/values.yaml) file
for configurations.

**WARNING**: The installed Bugsink instance using the above command is not exposed to the internet and is only available
from within the cluster. For exposing your Bugsink instance, you can choose between a few options such as ingress, load
balancer and a node-port. This can be specified in your `values.yaml` file.
