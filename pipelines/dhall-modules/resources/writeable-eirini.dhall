let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

let TextJSONMap = Prelude.Map.Type Text JSON.Type

in    λ(name : Text)
    → λ(branch : Text)
    → λ(privateKey : Text)
    → λ(ignorePaths : Bool)
    → let wholeRepo =
            ./writable-git-repo.dhall
              { name = name
              , uri = "git@github.com:cloudfoundry-incubator/eirini.git"
              , branch = branch
              , privateKey = privateKey
              }

      in        if ignorePaths

          then    wholeRepo
                ⫽ { source =
                      Prelude.Optional.map
                        TextJSONMap
                        TextJSONMap
                        (   λ(source : TextJSONMap)
                          →   source
                            # toMap
                                { ignore_paths =
                                    ../helpers/text-list-to-json.dhall
                                      ../facts/non-go-eirini-paths.dhall
                                }
                        )
                        wholeRepo.source
                  }

          else  wholeRepo
