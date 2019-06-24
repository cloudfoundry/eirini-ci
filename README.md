# Eirini CI

CI Resources for [eirini-release](https://github.com/cloudfoundry-incubator/eirini-release). The pipeline is deployed at [GCP](https://ci.eirini.cf-app.com).

To be able to login via Github you will need to be member of the `cf-cube-ci/cube` team.

# Development

- Access to private repo, which contains environment specific vars
- Install [Aviator](https://github.com/JulzDiverse/aviator) (used to merge pipeline YAML files)
- Clone [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config)
- Make sure you have `pass` configured (see `eirini-private-config`)

The pipelines are organized in separate directories with individual `set-pipeline` scripts. They usually require one argument for the Concourse target and one for the local path to the private repo (for secrets etc.):

    $ pipelines/acceptance/set-pipeline $CONCOURSE_TARGET $PATH_TO_PRIVATE_REPO
