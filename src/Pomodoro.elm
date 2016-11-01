port module Pomodoro exposing (Model, Timer(..), init, Msg(..), update, view)

import Html
import Html.Attributes
import Html.Events
import Html.App
import Time
import String


---- MODEL ----


type alias Model =
    { singlePomodoroTime : Int
    , achievedPomodoros : Int
    , timer : Timer
    }


type Timer
    = Countdown Int
    | Idle


init : Int -> ( Model, Cmd Msg )
init singlePomodoroTime =
    ( { singlePomodoroTime = singlePomodoroTime
      , achievedPomodoros = 0
      , timer = Idle
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = Started
    | Stopped
    | Resetted
    | OneSecondPassed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Started ->
            ( { model
                | timer = Countdown model.singlePomodoroTime
              }
            , Cmd.none
            )

        Stopped ->
            ( { model
                | timer = Idle
              }
            , Cmd.none
            )

        Resetted ->
            init model.singlePomodoroTime

        OneSecondPassed ->
            case model.timer of
                Countdown remainingSeconds ->
                    let
                        newRemainingSeconds =
                            remainingSeconds - 1

                        newPomodoroAchieved =
                            newRemainingSeconds == 0
                    in
                        if newPomodoroAchieved then
                            ( { model
                                | timer = Idle
                                , achievedPomodoros = model.achievedPomodoros + 1
                              }
                            , notifyTimerFinished ()
                            )
                        else
                            ( { model
                                | timer = Countdown newRemainingSeconds
                              }
                            , Cmd.none
                            )

                Idle ->
                    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    let
        withLeadingZero string =
            if String.length string > 1 then
                string
            else
                "0" ++ string

        remainingSeconds =
            case model.timer of
                Countdown remainingSeconds ->
                    remainingSeconds

                Idle ->
                    0

        minutes =
            (remainingSeconds // 60)
                |> toString
                |> withLeadingZero

        seconds =
            (remainingSeconds % 60)
                |> toString
                |> withLeadingZero
    in
        Html.div
            [ Html.Attributes.class "container" ]
            [ Html.p
                [ Html.Attributes.class "timer"
                ]
                [ Html.text (minutes ++ ":" ++ seconds) ]
              -- Controls
            , case model.timer of
                Idle ->
                    Html.button
                        [ Html.Attributes.class "btn start-btn"
                        , Html.Events.onClick Started
                        ]
                        [ Html.text "Start" ]

                Countdown _ ->
                    Html.button
                        [ Html.Attributes.class "btn stop-btn"
                        , Html.Events.onClick Stopped
                        ]
                        [ Html.text "Stop" ]
            , Html.button
                [ Html.Attributes.class "btn reset-btn"
                , Html.Events.onClick Resetted
                ]
                [ Html.text "Reset" ]
              -- Achiements
            , [1..model.achievedPomodoros]
                |> List.map (always chilicornie)
                |> Html.div []
            ]


chilicornie : Html.Html Msg
chilicornie =
    Html.img
        [ Html.Attributes.src "./chilicornie.png"
        , Html.Attributes.width 50
        , Html.Attributes.height 50
        ]
        []



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.timer of
        Idle ->
            Sub.none

        Countdown _ ->
            Time.every Time.second (always OneSecondPassed)



---- PROGRAM ----


main : Program Never
main =
    Html.App.program
        { init =
            -- 30 minutes
            init (30 * 60)
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


port notifyTimerFinished : () -> Cmd msg
