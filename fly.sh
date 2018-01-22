fly -t flintstone set-pipeline \
	--pipeline cube-release-ci \
	--config pipeline.yml \
	--var "cube_conf=$(cat creds/kube_conf.yml)" \
        -l creds/vars.yml


