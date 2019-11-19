let Prelude = ../deps/prelude.dhall

in    λ(ts : List Text)
    → let listOfJSONStrings =
            Prelude.List.map
              Text
              Prelude.JSON.Type
              (λ(t : Text) → Prelude.JSON.string t)
              ts

      in  Prelude.JSON.array listOfJSONStrings
