let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let JSON = Prelude.JSON

in  Concourse.schemas.Resource::{
    , name = "bump-day"
    , type = Concourse.Types.ResourceType.InBuilt "time"
    , icon = Some "timetable"
    , source =
        Some
          ( toMap
              { start = JSON.string "12:00 AM"
              , stop = JSON.string "1:00 AM"
              , days = JSON.array [ JSON.string "Sunday" ]
              }
          )
    }
