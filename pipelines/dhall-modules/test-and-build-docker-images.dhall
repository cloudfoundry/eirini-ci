let Concourse = ./deps/dhall-concourse/types.dhall

let Defaults = ./deps/dhall-concourse/defaults.dhall

let Helpers = ./deps/dhall-concourse/helpers.dhall

let Prelude = ./deps/prelude.dhall

let keyText = Prelude.JSON.keyText

let RunTestRequirements =
	  { eirini :
		  Concourse.Resource
	  , ciResources :
		  Concourse.Resource
	  , sampleConfigs :
		  Concourse.Resource
	  , clusterStagingEventReady :
		  Concourse.Resource
	  , clusterName :
		  Text
	  }

let getEverything
	: RunTestRequirements → Concourse.Step
	=   λ(reqs : RunTestRequirements)
	  → let getEirini =
			  Helpers.getStep
			  (   Defaults.GetStep
				⫽ { resource = reqs.eirini, trigger = Some True }
			  )

		let getClusterEventReady =
			  Helpers.getStep
			  (   Defaults.GetStep
				⫽ { resource =
					  reqs.clusterStagingEventReady
				  , trigger =
					  Some True
				  }
			  )

		let getCIResources =
			  Helpers.getStep
			  (Defaults.GetStep ⫽ { resource = reqs.ciResources })

		let getSampleConfigs =
			  Helpers.getStep
			  (Defaults.GetStep ⫽ { resource = reqs.sampleConfigs })

		in  Helpers.aggregateStep
			[ getEirini
			, getClusterEventReady
			, getCIResources
			, getSampleConfigs
			]

let runUnitTests
	: Concourse.Step
	= Helpers.taskStep
	  (   Defaults.TaskStep
		⫽ { task =
			  "run-unit-tests"
		  , config =
			  Concourse.TaskSpec.File
			  "ci-resources/tasks/run-unit-tests/task.yml"
		  , input_mapping =
			  Some [ keyText "eirini-source" "eirini" ]
		  }
	  )

let runStaticChecks
	: Concourse.Step
	= Helpers.taskStep
	  (   Defaults.TaskStep
		⫽ { task =
			  "run-static-checks"
		  , config =
			  Concourse.TaskSpec.File
			  "ci-resources/tasks/run-static-checks/task.yml"
		  , input_mapping =
			  Some [ keyText "eirini-source" "eirini" ]
		  }
	  )

let runIntegrationTests
	: Text → Concourse.Step
	=   λ(clusterName : Text)
	  → let downloadKubeConfig =
			  Helpers.taskStep
			  (   Defaults.TaskStep
				⫽ { task =
					  "download-kubeconfig"
				  , config =
					  Concourse.TaskSpec.File
					  "ci-resources/tasks/download-kubeconfig/task.yml"
				  , params =
					  Some
					  [ keyText "IBMCLOUD_ACCOUNT" "((ibmcloud-account))"
					  , keyText "IBMCLOUD_USER" "((ibmcloud-user))"
					  , keyText "IBMCLOUD_PASSWORD" "((ibmcloud-password))"
					  , keyText "CLUSTER_NAME" clusterName
					  ]
				  }
			  )

		let runTests =
			  Helpers.taskStep
			  (   Defaults.TaskStep
				⫽ { task =
					  "run-integration-tests"
				  , config =
					  Concourse.TaskSpec.File
					  "ci-resources/tasks/run-integration-tests/task.yml"
				  , input_mapping =
					  Some [ keyText "eirini-source" "eirini" ]
				  }
			  )

		in  Helpers.aggregateStep [ downloadKubeConfig, runTests ]

let mkRunTestsJob
	: RunTestRequirements → Concourse.Job
	=   λ(reqs : RunTestRequirements)
	  → let runAllTests =
			  Helpers.aggregateStep
			  [ runUnitTests
			  , runStaticChecks
			  , runIntegrationTests reqs.clusterName
			  ]

		in  Defaults.Job ⫽ { plan = [ getEverything reqs, runAllTests ] }

let mkJobs
	: RunTestRequirements → List Concourse.Job
	= λ(reqs : RunTestRequirements) → [] : List Concourse.Job

in  mkJobs
