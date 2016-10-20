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
                    (update Start { achievedPomodoros = 0, timer = Idle })
                    { achievedPomodoros = 0, timer = Countdown 2 }
        , fuzz Fuzz.int "Should stop and increase achievedPomodoros after countdown go to 0" <|
            \achievedPomodoros ->
                Expect.equal
                    (update OneSecondTick { achievedPomodoros = achievedPomodoros, timer = Countdown 0 })
                    { achievedPomodoros = achievedPomodoros + 1, timer = Idle }
          --
        , fuzz2 (Fuzz.intRange 0 100) (Fuzz.intRange 1 100) "Every tick should reduce timer for 1 second" <|
            \achievedPomodoros remainingSeconds ->
                Expect.equal
                    (update OneSecondTick { achievedPomodoros = achievedPomodoros, timer = Countdown remainingSeconds })
                    { achievedPomodoros = achievedPomodoros, timer = Countdown (remainingSeconds - 1) }
        ]
