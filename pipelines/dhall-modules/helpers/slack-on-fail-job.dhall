let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let slackResource =
      let slackResourceType =
              Concourse.defaults.CustomResourceType
            ⫽ { name = "slack-notification"
              , source =
                  Some
                    ( toMap
                        { repository =
                            Prelude.JSON.string
                              "cfcommunity/slack-notification-resource"
                        , tag = Prelude.JSON.string "latest"
                        }
                    )
              , type = "docker-image"
              }

      in  Concourse.schemas.Resource::{
          , name = "slack"
          , type = Concourse.Types.ResourceType.Custom slackResourceType
          , icon = Some "slack"
          , source =
              Some (toMap { url = Prelude.JSON.string "((slack_webhook))" })
          }

let hook =
      Some
        ( Concourse.helpers.putStep
            Concourse.schemas.PutStep::{
            , resource = slackResource
            , params =
                Some
                  ( toMap
                      { text =
                          Prelude.JSON.string
                            ''
                            Pipeline *$BUILD_PIPELINE_NAME* failed :cry:

                            Job is *$BUILD_JOB_NAME*
                            Build name is *$BUILD_NAME*
                            ''
                      , channel = Prelude.JSON.string "#eirini-ci"
                      , attachments =
                          Prelude.JSON.string
                            ''
                              [{
                                  "color": "danger",
                                  "actions": [
                                        {
                                          "type": "button",
                                          "text": "View in Concourse",
                                          "url": "https://jetson.eirini.cf-app.com/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME/jobs/$BUILD_JOB_NAME/builds/$BUILD_NAME"
                                        }
                                  ]
                              }]
                            ''
                      }
                  )
            }
        )

in  λ(j : Concourse.Types.Job) → j ⫽ { on_failure = hook }
