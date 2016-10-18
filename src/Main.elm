module Main exposing (..)

import Html
import Html.Attributes
import Html.Events
import Html.App
import Time
import String


---- MODEL ----


type alias Model =
    { achievedPomodoros : Int
    , isOngoing : Bool
    , remainingTime : Int
    }


init : Model
init =
    { achievedPomodoros = 0
    , isOngoing = False
    , remainingTime = 0
    }


singlePomodoroTime : Int
singlePomodoroTime =
    --60 * 30
    2



---- UPDATE ----


type Msg
    = Start
    | Stop
    | Reset
    | OneSecondTick


update : Msg -> Model -> Model
update msg model =
    case msg of
        Start ->
            { model
                | isOngoing = True
                , remainingTime = singlePomodoroTime
            }

        Stop ->
            { model
                | isOngoing = False
                , remainingTime = 0
            }

        Reset ->
            init

        OneSecondTick ->
            let
                newPomodoroAchieved =
                    model.remainingTime == 0
            in
                if newPomodoroAchieved then
                    { model
                        | isOngoing = False
                        , achievedPomodoros = model.achievedPomodoros + 1
                    }
                else
                    { model
                        | remainingTime = model.remainingTime - 1
                    }



---- VIEW ----


view : Model -> Html.Html Msg
view model =
    let
        withLeadingZero string =
            if String.length string > 1 then
                string
            else
                "0" ++ string

        minutes =
            model.remainingTime
                // 60
                |> toString
                |> withLeadingZero

        seconds =
            model.remainingTime
                % 60
                |> toString
                |> withLeadingZero
    in
        Html.div
            [ Html.Attributes.class "container" ]
            [ stylesheet "./static/style.css"
            , Html.p
                [ Html.Attributes.class "timer"
                ]
                [ Html.text (minutes ++ ":" ++ seconds) ]
            , if not model.isOngoing then
                Html.button
                    [ Html.Attributes.class "btn start-btn"
                    , Html.Events.onClick Start
                    ]
                    [ Html.text "Start" ]
              else
                Html.button
                    [ Html.Attributes.class "btn stop-btn"
                    , Html.Events.onClick Stop
                    ]
                    [ Html.text "Stop" ]
            , Html.button
                [ Html.Attributes.class "btn reset-btn"
                , Html.Events.onClick Reset
                ]
                [ Html.text "Reset" ]
            , [1..model.achievedPomodoros]
                |> List.map (always chilicornie)
                |> Html.div []
            ]


chilicornie : Html.Html Msg
chilicornie =
    Html.img
        [ Html.Attributes.src "./static/chilicornie.png"
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
    if model.isOngoing then
        Time.every Time.second (always OneSecondTick)
    else
        Sub.none



---- PROGRAM ----


main : Program Never
main =
    Html.App.program
        { init = ( init, Cmd.none )
        , update = \msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        , view = view
        }
