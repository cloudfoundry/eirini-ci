let Prelude = ../deps/prelude.dhall

let jsonString = Prelude.JSON.string

let TextToJSONMap = Prelude.Map.Type Text Prelude.JSON.Type

let dockerResource =
        λ(name : Text)
      → λ(repository : Text)
      → λ(optionalTag : Optional Text)
      → λ(dockerHubUser : Text)
      → λ(dockerHubPassword : Text)
      → let resourceWithoutCreds =
              ./docker-resource-no-creds.dhall name repository optionalTag
        
        in    resourceWithoutCreds
            ⫽ { source =
                  Prelude.Optional.map
                    TextToJSONMap
                    TextToJSONMap
                    (   λ(s : TextToJSONMap)
                      →   s
                        # toMap
                            { username = jsonString dockerHubUser
                            , password = jsonString dockerHubPassword
                            }
                    )
                    resourceWithoutCreds.source
              }

in  dockerResource
