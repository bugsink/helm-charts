## Bugsink Helm Charts

[![GitHub License](https://img.shields.io/github/license/bugsink/helm-charts)](https://github.com/bugsink/helm-charts/blob/main/LICENSE)
[![GitHub Tests](https://img.shields.io/github/actions/workflow/status/bugsink/helm-charts/test.yaml?branch=main&label=tests)](https://github.com/bugsink/helm-charts/actions/workflows/test.yaml?query=branch%3Amain++)

Helm charts for deploying Bugsink and its related applications on Kubernetes using [Helm](https://github.com/helm/helm).

## Before You Begin

### Prerequisites

- A running Kubernetes cluster
- Kubectl installed and configured for that cluster
- Helm installed (See [here](#helm) for details on Helm)

### Helm

Helm is a tool for managing Kubernetes charts. Charts are packages of pre-configured Kubernetes resources.

To install Helm, refer to the [Helm install guide](https://github.com/helm/helm#install) and ensure that the `helm`
binary is in the `PATH` of your shell.

## Usage

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

To install [Bugsink](https://www.bugsink.com) using Helm, execute the following command:

```console
helm install bugsink bugsink/bugsink \
    --set "baseUrl=https://bugsink.example.com" \
    --namespace bugsink --create-namespace
```

Refer to the Bugsink chart [values](https://github.com/bugsink/helm-charts/blob/main/charts/bugsink/values.yaml) file
for configuration options.

**WARNING**: The instance deployed with the command above is **not** exposed to the internet and is only accessible from
within the cluster. To expose your Bugsink instance, you can choose one of several options—such as an Ingress, a
LoadBalancer service, or a NodePort service—and specify it in your `values.yaml` file.
