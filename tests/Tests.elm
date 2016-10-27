module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz
import Pomodoro exposing (..)


all : Test
all =
    describe "Pomodoro App Test Suit"
        [ test "Starting timer" <|
            \() ->
                Expect.equal
                    (update
                        Started
                        { achievedPomodoros = 0, timer = Idle }
                        |> fst
                    )
                    { achievedPomodoros = 0, timer = Countdown 2 }
          --
          --
        , fuzz Fuzz.int "Should stop and increase achievedPomodoros after countdown go to 0" <|
            \achievedPomodoros ->
                Expect.equal
                    (update
                        OneSecondPassed
                        { achievedPomodoros = achievedPomodoros, timer = Countdown 0 }
                        |> fst
                    )
                    { achievedPomodoros = achievedPomodoros + 1, timer = Idle }
          --
          --
        , fuzz2 (Fuzz.intRange 0 100) (Fuzz.intRange 1 100) "Every tick should reduce timer for 1 second" <|
            \achievedPomodoros remainingSeconds ->
                Expect.equal
                    (update
                        OneSecondPassed
                        { achievedPomodoros = achievedPomodoros, timer = Countdown remainingSeconds }
                        |> fst
                    )
                    { achievedPomodoros = achievedPomodoros, timer = Countdown (remainingSeconds - 1) }
        ]
