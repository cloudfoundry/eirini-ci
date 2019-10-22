-- - name: deployment-version
-- type: semver
-- source:
-- initial_version: 1.0.0
-- driver: gcs
-- bucket: eirini-ci
-- key: image-versions/((world-name))
-- json_key: ((gcs-json-key))

let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(worldName : Text)
    → λ(json_key : Text)
    → Concourse.schemas.Resource::{
      , name = "deployment-version"
      , type = Concourse.Types.ResourceType.InBuilt "semver"
      , source =
          Some
            ( toMap
                { initial_version = JSON.string "1.0.0"
                , driver = JSON.string "gcs"
                , bucket = JSON.string "eirini-ci"
                , key = JSON.string "image-versions/${worldName}"
                , json_key = JSON.string json_key
                }
            )
      }
