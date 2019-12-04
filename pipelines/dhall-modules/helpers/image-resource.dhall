let Concourse = ../deps/concourse.dhall

let JSON = (../deps/prelude.dhall).JSON

in    λ(imageRepo : Text)
    → Some
        Concourse.schemas.ImageResource::{
        , type = "docker-image"
        , source = Some (toMap { repository = JSON.string imageRepo })
        }
