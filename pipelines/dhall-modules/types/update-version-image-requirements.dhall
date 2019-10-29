let Concourse = ../deps/concourse.dhall

in  { docker : Concourse.Types.Resource, name : Text }
