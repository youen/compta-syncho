module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1)

main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , update = \_ model -> model
        , view = \_ -> div [] [ h1 [] [ text "Caisse Jetons Synchro" ] ]
        }
