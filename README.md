# Eirini CI

CI Resources for [eirini-release](https://github.com/cloudfoundry-incubator/eirini-release). The pipeline is deployed at [GCP](https://jetson.eirini.cf-app.com/teams/main/pipelines/ci).

# Development

- Access to private repo, which contains environment specific vars
- Install [Aviator](https://github.com/JulzDiverse/aviator) (used to merge pipeline YAML files)
- Clone [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config)
- Make sure you have `pass` configured (see `eirini-private-config`)

The pipelines are organized in separate directories with individual `set-pipeline` scripts:

```
$ pipelines/<pipeline-name>/set-pipeline
```
