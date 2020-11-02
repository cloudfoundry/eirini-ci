# Eirini CI

CI Resources for [eirini-release](https://github.com/cloudfoundry-incubator/eirini-release). The pipeline is deployed at [GCP](https://jetson.eirini.cf-app.com/teams/main/pipelines/ci).

## Development

- Access to private repo, which contains environment specific vars
- Install [Aviator](https://github.com/JulzDiverse/aviator) (used to merge pipeline YAML files)
- Clone [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config)
- Make sure you have `pass` configured (see `eirini-private-config`)

The pipelines are organized in separate directories with individual `set-pipeline` scripts:

```
$ pipelines/<pipeline-name>/set-pipeline
```

## Eirini.cf certificates
The certificates for the [eirini.cf](eirini.cf) website are generated using letsencrypt and [cert-manager](https://cert-manager.io/) via the dns01 challenge. To do this the pipeline requires several things to be set up:
1. The dns provider for the eirini.cf domain should point to the GCP dns servers and a corresponding entry should be created in GCP.
1. In GCS's CloudDNS console, the `eirini.cf` domain should point to the external IP of the Istio Gateway.
1. The [Issuer](https://cert-manager.io/docs/concepts/issuer/) should be configured to generate with [the ACME challenge](https://cert-manager.io/docs/configuration/acme/dns01/) with a GCP service account that has permissions to create and delete CloudDNS entries. Additionaly a [Certificate](https://cert-manager.io/docs/concepts/certificate/) should be created for the eirini.cf domain using this Issuer.
1. The certificate should be present in the namespace where the Istio Gateway is deployed (in cf-for-k8s that's `istio-system`). Since that namespace is managed by cf-for-k8s, it will be deleted when doing a `kapp delete`, which will also delete the certificates. Since letsencrypt has an API limit of 5 per week for a single domain, the certificates must be generated in a separate namespace and copied over to a secret in `istio-system`.
1. A server must be configured in the Istio Gateway that has the `eirini.cf` host and uses the copied secret in `istio-system`.
