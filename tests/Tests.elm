module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz
import Random.Pcg as Random
import Shrink
import Lazy.List
import Pomodoro exposing (..)


-- Pomodoro is achieved in single pomodoro time + 1 steps


all : Test
all =
    describe "Pomodoro App Test Suit"
        [ fuzz
            (Fuzz.intRange 1 100)
            "Starting timer results in setting countdown"
          <|
            \singlePomodoroTime ->
                Expect.equal
                    (init singlePomodoroTime
                        |> Tuple.first
                        |> update Started
                        |> Tuple.first
                        |> .timer
                    )
                    (Countdown singlePomodoroTime)
          --
          --
        , fuzz
            (Fuzz.intRange 1 100)
            "Reseting timer reuses same time for single pomodoro"
          <|
            \singlePomodoroTime ->
                Expect.equal
                    ({ singlePomodoroTime = singlePomodoroTime
                     , achievedPomodoros = 10
                     , timer = Countdown 42
                     }
                        |> update Resetted
                        |> Tuple.first
                        |> .singlePomodoroTime
                    )
                    singlePomodoroTime
          --
          --
        , fuzz
            Fuzz.int
            "Should stop and increase achievedPomodoros after countdown go to 0"
          <|
            \achievedPomodoros ->
                Expect.equal
                    ({ singlePomodoroTime = 42
                     , achievedPomodoros = achievedPomodoros
                     , timer = Countdown 1
                     }
                        |> update OneSecondPassed
                        |> Tuple.first
                        |> .achievedPomodoros
                    )
                    (achievedPomodoros + 1)
          --
          --
        , fuzz
            (Fuzz.intRange 2 100)
            "Every tick should reduce timer for 1 second"
          <|
            \singlePomodoroTime ->
                Expect.equal
                    (init singlePomodoroTime
                        |> Tuple.first
                        |> update Started
                        |> Tuple.first
                        |> update OneSecondPassed
                        |> Tuple.first
                        |> .timer
                    )
                    (Countdown (singlePomodoroTime - 1))
          --
          --
        , fuzz
            msgList
            "Started timer should result in one pomodoro in less steps then seconds in single pomodoro"
          <|
            \msgs ->
                let
                    singlePomodoroTime =
                        List.length msgs
                in
                    Expect.equal
                        ((Started :: msgs)
                            |> List.foldl (\msg model -> update msg model |> Tuple.first)
                                (init singlePomodoroTime |> Tuple.first)
                            |> .timer
                        )
                        Idle
        ]


msgList : Fuzz.Fuzzer (List Msg)
msgList =
    let
        lengthGen =
            Random.frequency
                [ ( 1, Random.constant 1 )
                , ( 3, Random.int 2 10 )
                , ( 2, Random.int 10 100 )
                , ( 0.5, Random.int 100 400 )
                ]

        msgGen =
            Random.frequency
                [ ( 0.25, Random.constant Resetted )
                , ( 0.25, Random.constant Stopped )
                , ( 2, Random.constant OneSecondPassed )
                ]

        listGen =
            Random.andThen (\length -> Random.list length msgGen) lengthGen

        shrinker list =
            case list of
                [] ->
                    Lazy.List.empty

                x :: [] ->
                    Lazy.List.empty

                x :: xs ->
                    Lazy.List.singleton xs
    in
        Fuzz.custom listGen shrinker
