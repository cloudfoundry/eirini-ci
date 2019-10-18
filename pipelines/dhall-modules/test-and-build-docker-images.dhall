let Concourse = ./deps/concourse.dhall

let Prelude = ./deps/prelude.dhall

let keyText = Prelude.JSON.keyText

let RunTestRequirements =
	  { eirini :
		  Concourse.Types.Resource
	  , ciResources :
		  Concourse.Types.Resource
	  , sampleConfigs :
		  Concourse.Types.Resource
	  , clusterStagingEventReady :
		  Concourse.Types.Resource
	  , clusterName :
		  Text
	  }

let getEverything
	: RunTestRequirements → Concourse.Types.Step
	=   λ(reqs : RunTestRequirements)
	  → let getEirini =
			  Concourse.helpers.getStep
			  (   Concourse.defaults.GetStep
				⫽ { resource = reqs.eirini, trigger = Some True }
			  )

		let getClusterEventReady =
			  Concourse.helpers.getStep
			  (   Concourse.defaults.GetStep
				⫽ { resource =
					  reqs.clusterStagingEventReady
				  , trigger =
					  Some True
				  }
			  )

		let getCIResources =
			  Concourse.helpers.getStep
			  (Concourse.defaults.GetStep ⫽ { resource = reqs.ciResources })

		let getSampleConfigs =
			  Concourse.helpers.getStep
			  (Concourse.defaults.GetStep ⫽ { resource = reqs.sampleConfigs })

		in  Concourse.helpers.aggregateStep
			[ getEirini
			, getClusterEventReady
			, getCIResources
			, getSampleConfigs
			]

let runUnitTests
	: Concourse.Types.Step
	= Concourse.helpers.taskStep
	  (   Concourse.defaults.TaskStep
		⫽ { task =
			  "run-unit-tests"
		  , config =
			  Concourse.Types.TaskSpec.File
			  "ci-resources/tasks/run-unit-tests/task.yml"
		  , input_mapping =
			  Some [ keyText "eirini-source" "eirini" ]
		  }
	  )

let runStaticChecks
	: Concourse.Types.Step
	= Concourse.helpers.taskStep
	  (   Concourse.defaults.TaskStep
		⫽ { task =
			  "run-static-checks"
		  , config =
			  Concourse.Types.TaskSpec.File
			  "ci-resources/tasks/run-static-checks/task.yml"
		  , input_mapping =
			  Some [ keyText "eirini-source" "eirini" ]
		  }
	  )

let runIntegrationTests
	: Text → Concourse.Types.Step
	=   λ(clusterName : Text)
	  → let downloadKubeConfig =
			  Concourse.helpers.taskStep
			  (   Concourse.defaults.TaskStep
				⫽ { task =
					  "download-kubeconfig"
				  , config =
					  Concourse.Types.TaskSpec.File
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
			  Concourse.helpers.taskStep
			  (   Concourse.defaults.TaskStep
				⫽ { task =
					  "run-integration-tests"
				  , config =
					  Concourse.Types.TaskSpec.File
					  "ci-resources/tasks/run-integration-tests/task.yml"
				  , input_mapping =
					  Some [ keyText "eirini-source" "eirini" ]
				  }
			  )

		in  Concourse.helpers.aggregateStep [ downloadKubeConfig, runTests ]

let mkRunTestsJob
	: RunTestRequirements → Concourse.Types.Job
	=   λ(reqs : RunTestRequirements)
	  → let runAllTests =
			  Concourse.helpers.aggregateStep
			  [ runUnitTests
			  , runStaticChecks
			  , runIntegrationTests reqs.clusterName
			  ]

		in  Concourse.defaults.Job ⫽ { plan = [ getEverything reqs, runAllTests ] }

let mkJobs
	: RunTestRequirements → List Concourse.Types.Job
	= λ(reqs : RunTestRequirements) → [] : List Concourse.Types.Job

in  mkJobs
