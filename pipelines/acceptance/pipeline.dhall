let Concourse = ../dhall-modules/deps/concourse.dhall

let scfJobs = ./scf-acceptance.dhall

let cf4K8sJobs = ./cf4k8s-acceptance.dhall

let pipeline = ../dhall-modules/helpers/slack-on-fail-grouped-jobs.dhall
      cf4K8sJobs # scfJobs
in  Concourse.render.groupedJobs pipeline
