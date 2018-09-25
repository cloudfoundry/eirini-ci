# Eirini CI

CI Resources for [eirini-release](https://github.com/cloudfoundry-incubator/eirini-release)

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
       -  Note: There's a problem with the certificates in the latest bosh-deployment version. Checkout [this](https://github.com/cloudfoundry/bosh-deployment/commit/ab64aef9c6a439722e3fd570969c27457095b0a5) commit.
    - [eirini-private-config](https://github.com/cloudfoundry/eirini-private-config)
- Make sure you have `pass` configured (see `eirini-private-config`)

### Set the CI Pipeline

Execute the following script:

`$ ./pipelines/ci/set-pipeline <CONCOURSE_TARGET> <PATH_TO_PRIVATE_REPO>`

### Set the Acceptance Pipeline

Execute the following script:

`$ ./pipelines/acceptance/set-pipeline <CONCOURSE_TARGET> <PATH_TO_PRIVATE_REPO>`

