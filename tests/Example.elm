module Example exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Application Initialization"
        [ test "Basic math is working" <|
            \_ ->
                Expect.equal 4 (2 + 2)
        ]
