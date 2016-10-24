module Pomodoro exposing (Model, Timer(..), init, Msg(..), update, view)

import Html
import Html.Attributes
import Html.Events
import Html.App
import Time
import String


---- MODEL ----


type alias Model =
    { achievedPomodoros : Int
    , timer : Timer
    }


type Timer
    = Countdown Int
    | Idle


init : Model
init =
    { achievedPomodoros = 0
    , timer = Idle
    }


singlePomodoroTime : Int
singlePomodoroTime =
    --60 * 30
    2



---- UPDATE ----


type Msg
    = Started
    | Stopped
    | Resetted
    | OneSecondPassed


update : Msg -> Model -> Model
update msg model =
    case msg of
        Started ->
            { model
                | timer = Countdown singlePomodoroTime
            }

        Stopped ->
            { model
                | timer = Idle
            }

        Resetted ->
            init

        OneSecondPassed ->
            case model.timer of
                Countdown remainingSeconds ->
                    let
                        newPomodoroAchieved =
                            remainingSeconds == 0
                    in
                        if newPomodoroAchieved then
                            { model
                                | timer = Idle
                                , achievedPomodoros = model.achievedPomodoros + 1
                            }
                        else
                            { model
                                | timer = Countdown (remainingSeconds - 1)
                            }

                Idle ->
                    model



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
            [ stylesheet "./style.css"
            , Html.p
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


stylesheet : String -> Html.Html Msg
stylesheet link =
    let
        tag =
            "link"

        attrs =
            [ Html.Attributes.attribute "rel" "stylesheet"
            , Html.Attributes.attribute "property" "stylesheet"
            , Html.Attributes.attribute "href" link
            ]

        children =
            []
    in
        Html.node tag attrs children



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
        { init = ( init, Cmd.none )
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        }
