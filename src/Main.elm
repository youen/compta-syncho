module Main exposing (Model(..), Msg(..), init, main, update)

import Browser
import Caisse exposing (Caisse)
import Html exposing (Html, button, div, h1, text)
import Html.Events exposing (onClick)


type Model
    = Configuration
    | EnService Caisse


type Msg
    = OuvrirCaisse Int Int


init : () -> ( Model, Cmd Msg )
init _ =
    ( Configuration, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OuvrirCaisse fond jetons ->
            ( EnService (Caisse.ouvrir fond jetons), Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Configuration ->
            div []
                [ h1 [] [ text "Configuration Initiale" ]
                , button [ onClick (OuvrirCaisse 150 1000) ] [ text "Ouvrir la caisse" ]
                ]

        EnService _ ->
            div [] [ h1 [] [ text "Caisse Ouverte" ] ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
