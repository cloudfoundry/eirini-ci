fly -t flintstone set-pipeline \
	--pipeline cube-release-ci \
	--config pipeline.yml \
	--var "cube_conf=$(kubectl config view --flatten)" \
        -l creds/vars.yml


