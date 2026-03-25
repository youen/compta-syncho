module Main exposing (Model(..), Msg(..), init, main, update)

import Browser
import Caisse exposing (Caisse)
import Html exposing (Html, button, div, h1, input, label, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)


type Model
    = Configuration { fondSaisi : String, jetonsSaisis : String }
    | EnService Caisse


type Msg
    = SetFond String
    | SetJetons String
    | ValiderConfiguration


init : () -> ( Model, Cmd Msg )
init _ =
    ( Configuration { fondSaisi = "", jetonsSaisis = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetFond val ->
            case model of
                Configuration config ->
                    ( Configuration { config | fondSaisi = val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SetJetons val ->
            case model of
                Configuration config ->
                    ( Configuration { config | jetonsSaisis = val }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ValiderConfiguration ->
            case model of
                Configuration { fondSaisi, jetonsSaisis } ->
                    case ( String.toInt fondSaisi, String.toInt jetonsSaisis ) of
                        ( Just fond, Just jetons ) ->
                            ( EnService (Caisse.ouvrir fond jetons), Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Configuration { fondSaisi, jetonsSaisis } ->
            div []
                [ h1 [] [ text "Configuration Initiale" ]
                , div []
                    [ label [] [ text "Fond de caisse (€)" ]
                    , input [ type_ "number", placeholder "Ex: 150", value fondSaisi, onInput SetFond ] []
                    ]
                , div []
                    [ label [] [ text "Nombre de jetons initial" ]
                    , input [ type_ "number", placeholder "Ex: 1000", value jetonsSaisis, onInput SetJetons ] []
                    ]
                , button [ onClick ValiderConfiguration ] [ text "Ouvrir la caisse" ]
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
