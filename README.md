# Eirini CI

CI Resources for [cube-release](https://github.com/andrew-edgar/cube-release)

## Pipelines

- [Eirini-CI](https://flintstone.ci.cf-app.com/teams/cube/pipelines/eirini-release-ci)
- [Eirini-Dev](https://flintstone.ci.cf-app.com/teams/eirini/pipelines/eirini-dev)

## Access

There are two ways to access our Concourse server:

1. GitHub OAuth

To be able to login via Github you will need to be member of the `cf-cube-ci/cube` team.

1. LastPass

- [LastPass](https://lastpass.com) account,  
- install the [LastPass CLI](https://github.com/lastpass/lastpass-cli), and
- contact the cube development team to share the login with you.

After you got all these things, run the following to login via `fly`:

```bash
fly -t <alias> login \
  -c https://flintstone.ci.cf-app.com \
  -u <user-name> \
  -p $(lpass show "<key-name>" --password) \
  --team-name <team-name>
```

## Development

### Prereqs

- Access to private repo, which contains environment specific vars
- Install [Aviator](https://github.com/JulzDiverse/aviator) (used to merge pipeline YAML files)
- Clone the following repositories to your local workstation:
    - [1-click-pipeline](https://github.com/petergtz/1-click-bosh-lite-pipeline)
    - [bosh-deployment](https://github.com/cloudfoundry/bosh-deployment)
    - [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config)
- Make sure you have `pass` configured (see `eirini-private-config`)

### Set the CI Pipeline

1. Point `KUBECONFIG` to the config file of your Kubernetes cluster and export the variable
1. Execute the provided `./set-pipeline` script. Use the `help` parameter to get details on the required parameters.

### Set a Development Pipeline

1. Copy `eirini-private-config/concourse/env/custom-sample.yml` to `custom.yml`
1. Edit the file and provide the necessary information
1. Run `set-pipeline` as above
