fly -t flintstone set-pipeline \
	--pipeline eirini-release-ci \
	--config pipeline.yml \
	--var "cube_conf=$(kubectl config view --flatten)" \
        -l creds/vars.yml


