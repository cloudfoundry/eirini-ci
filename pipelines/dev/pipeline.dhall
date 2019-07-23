let x = 1

let Concourse = ../dhall-modules/deps/dhall-concourse/types.dhall

let Defaults = ../dhall-modules/deps/dhall-concourse/defaults.dhall

let Helpers = ../dhall-modules/deps/dhall-concourse/helpers.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let ciResources =
		Defaults.Resource
	  ⫽ { name =
			"ci-resources"
		, type =
			Concourse.ResourceType.InBuilt "git"
		, source =
			Some
			( toMap
			  { uri =
				  "https://github.com/cloudfoundry-incubator/eirini-ci"
			  , branch =
				  "((ci-resources-branch))"
			  }
			)
		}

let clusterEventResource
	: Text → Text → Concourse.Resource
	=   λ(clusterName : Text)
	  → λ(event : Text)
	  →   Defaults.Resource
		⫽ { name =
			  "cluster-${clusterName}-staging-event-${event}"
		  , type =
			  Concourse.ResourceType.InBuilt "semver"
		  , source =
			  Some
			  ( toMap
				{ driver =
					"git"
				, uri =
					"git@github.com:cloudfoundry/eirini-private-config.git"
				, branch =
					"events"
				, file =
					"${clusterName}-event-${event}"
				, private_key =
					"((github-private-key))"
				, initial_version =
					"0.1.0"
				}
			  )
		  }

let clusterState =
		Defaults.Resource
	  ⫽ { name =
			"cluster-state"
		, type =
			Concourse.ResourceType.InBuilt "git"
		, source =
			Some
			( toMap
			  { uri =
				  "git@github.com:cloudfoundry/eirini-private-config.git"
			  , branch =
				  "master"
			  , private_key =
				  "((github-private-key))"
			  }
			)
		}

let kubeClusterReqs =
	  { ciResources =
		  ciResources
	  , clusterState =
		  clusterState
	  , clusterCreatedEvent =
		  clusterEventResource "dhall-test" "created"
	  , clusterReadyEvent =
		  clusterEventResource "dhall-test" "ready"
	  , clusterName =
		  "dhall-test"
	  , enableOPIStaging =
		  "true"
	  }

let kubeCluster = ../dhall-modules/kube-cluster.dhall kubeClusterReqs

in  kubeCluster
