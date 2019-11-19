let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let Requirements = { name : Text, uri : Text, branch : Text, privateKey : Text }

let repo
    : Requirements → Concourse.Types.Resource
    =   λ(reqs : Requirements)
      →   Concourse.defaults.Resource
        ⫽ { name = reqs.name
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "git"
          , source =
              Some
                ( toMap
                    { uri = Prelude.JSON.string reqs.uri
                    , branch = Prelude.JSON.string reqs.branch
                    , private_key = Prelude.JSON.string reqs.privateKey
                    }
                )
          }

in  repo
