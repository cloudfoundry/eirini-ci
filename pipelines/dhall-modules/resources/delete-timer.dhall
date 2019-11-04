let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let deleteTimer =
   Concourse.defaults.Resource
// { name = "delete-timer"
   , type = Concourse.Types.ResourceType.InBuilt "time"
   , icon = Some "bomb"
   , source = 
	Some
	  ( toMap
	       { start = Prelude.JSON.string "12:00 AM"
	       , stop = Prelude.JSON.string "1:00 AM"
	       , days = Prelude.JSON.array [Prelude.JSON.string "Saturday"]
	       }
          )
    }

in deleteTimer
