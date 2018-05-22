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

```
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

### Fly `eirini-ci`/`eirini-dev`

1. export the `KUBECONFIG` environment variable and point it to corresponding kubernetes config file

1. Execute the provided `./fly.sh` script as follows:

```
$ ./fly.sh <CONCOURSE-ALIAS> <eirini-ci|eirini-dev> <PATH-TO-PRIVATE-REPO>
```

This will use aviator to spruce the required pipeline.yml and fly the pipeline to your concourse target.

### Create a full new Development pipeline

**Further Prereqs**

- Clone [1-click-pipeline](https://github.com/petergtz/1-click-bosh-lite-pipeline) to your local machine
- Make sure you have access to the Flintstone Softlayer account with rights to create VMs. 

**Fly**

1. Create the director manifest as described in the [1-click-pipeline](https://github.com/petergtz/1-click-bosh-lite-pipeline/#creating-a-bosh-lite-using-a-concourse-management-pipeline) README.

1. Create the `eirini-full.yml` file using aviator:

`$ ONE_CLICK=<path-to-1-click-pipeline> aviator -f aviator/eirini-full.yml`


1. In the `eirini-private-config` repo you can find a `eirini-full.yml` property file (located in the `concourse/env` dir). Copy the file and provide the necessary information. 

1. export the `KUBECONFIG` environment variable and point it to corresponding kubernetes config file

1. Run fly as follows:

```
$ fly -t flintstone \
  set-pipeline \
    -p <PIPELINE-NAME> \
    -c eirini-full.yml \
    -v bosh-manifest="$(sed -e 's/((/_(_(/g' <PATH-TO-DIRECTOR-MANIFEST> )" \
    -l <PATH-TO-VARS-FILE> \
    -l <PATH-TO-COMMON-VARS-FILE> \
    --var "kube_conf=$(kubectl config view --flatten)"
```
