module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz
import Pomodoro exposing (..)


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
                        , timer = Countdown 0
                        }
                        |> fst
                    )
                    { singlePomodoroTime = singlePomodoroTime
                    , achievedPomodoros = achievedPomodoros + 1
                    , timer = Idle
                    }
          --
          --
        , fuzz3
            (Fuzz.intRange 0 100)
            (Fuzz.intRange 1 100)
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
                    )
                    { singlePomodoroTime = singlePomodoroTime
                    , achievedPomodoros = achievedPomodoros
                    , timer = Countdown (remainingSeconds - 1)
                    }
        ]
