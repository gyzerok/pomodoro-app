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
                    (update
                        Started
                        { singlePomodoroTime = singlePomodoroTime
                        , achievedPomodoros = 0
                        , timer = Idle
                        }
                        |> fst
                    )
                    { singlePomodoroTime = singlePomodoroTime
                    , achievedPomodoros = 0
                    , timer = Countdown singlePomodoroTime
                    }
          --
          --
        , fuzz
            (Fuzz.intRange 1 100)
            "Reseting timer reuses same time for single pomodoro"
          <|
            \singlePomodoroTime ->
                Expect.equal
                    (update
                        Resetted
                        { singlePomodoroTime = singlePomodoroTime
                        , achievedPomodoros = 10
                        , timer = Countdown 42
                        }
                        |> fst
                    )
                    { singlePomodoroTime = singlePomodoroTime
                    , achievedPomodoros = 0
                    , timer = Idle
                    }
          --
          --
        , fuzz2
            Fuzz.int
            (Fuzz.intRange 1 100)
            "Should stop and increase achievedPomodoros after countdown go to 0"
          <|
            \achievedPomodoros singlePomodoroTime ->
                Expect.equal
                    (update
                        OneSecondPassed
                        { singlePomodoroTime = singlePomodoroTime
                        , achievedPomodoros = achievedPomodoros
                        , timer = Countdown 1
                        }
                        |> fst
                        |> .achievedPomodoros
                    )
                    (achievedPomodoros + 1)
          --
          --
        , fuzz3
            (Fuzz.intRange 0 100)
            (Fuzz.intRange 2 100)
            (Fuzz.intRange 1 100)
            "Every tick should reduce timer for 1 second"
          <|
            \achievedPomodoros remainingSeconds singlePomodoroTime ->
                Expect.equal
                    (update
                        OneSecondPassed
                        { singlePomodoroTime = singlePomodoroTime
                        , achievedPomodoros = achievedPomodoros
                        , timer = Countdown remainingSeconds
                        }
                        |> fst
                        |> .timer
                    )
                    (Countdown (remainingSeconds - 1))
          --
          --
        , fuzz
            msgList
            "Started timer should result in one pomodoro in less steps then seconds in single pomodoro"
          <|
            \messages ->
                let
                    singlePomodoroTime =
                        List.length messages
                in
                    Expect.equal
                        (messages
                            |> List.foldl (\msg model -> update msg model |> fst)
                                { singlePomodoroTime = singlePomodoroTime
                                , achievedPomodoros = 42
                                , timer = Countdown singlePomodoroTime
                                }
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
            Random.andThen lengthGen (\length -> Random.list length msgGen)

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
