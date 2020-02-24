let scfJobs = ./scf-acceptance.dhall

let cf4K8sJobs = ./cf4k8s-acceptance.dhall

in    ../dhall-modules/helpers/slack-on-fail-grouped-jobs.dhall cf4K8sJobs
    # scfJobs
