module Main exposing (Model(..), Msg(..), init, main, update)

import Browser
import Caisse exposing (Caisse)
import Html exposing (Html, button, div, h1, input, label, text)
import Html.Attributes exposing (class, placeholder, type_, value)
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
            div [ class "w-screen h-screen flex items-center justify-center bg-gray-50 p-6" ]
                [ div [ class "w-full max-w-lg bg-white p-10 rounded-3xl shadow-xl flex flex-col gap-8" ]
                    [ h1 [ class "font-display font-black text-primary text-4xl text-center uppercase tracking-tight" ]
                        [ text "Initialisation" ]
                    , div [ class "flex flex-col gap-6" ]
                        [ div [ class "flex flex-col gap-2" ]
                            [ label [ class "text-textDark font-semibold text-lg" ] [ text "Fond de caisse initial (€)" ]
                            , input
                                [ type_ "number"
                                , placeholder "Ex: 150"
                                , value fondSaisi
                                , onInput SetFond
                                , class "w-full text-2xl p-4 border-2 border-gray-200 rounded-2xl outline-none focus:border-primary transition-colors text-center font-bold"
                                ]
                                []
                            ]
                        , div [ class "flex flex-col gap-2" ]
                            [ label [ class "text-textDark font-semibold text-lg" ] [ text "Nombre de jetons initial" ]
                            , input
                                [ type_ "number"
                                , placeholder "Ex: 1000"
                                , value jetonsSaisis
                                , onInput SetJetons
                                , class "w-full text-2xl p-4 border-2 border-gray-200 rounded-2xl outline-none focus:border-primary transition-colors text-center font-bold"
                                ]
                                []
                            ]
                        ]
                    , button
                        [ onClick ValiderConfiguration
                        , class "mt-4 w-full bg-primary hover:bg-primaryDark active:scale-95 text-white font-bold py-5 rounded-2xl text-xl shadow-lg transition-all"
                        ]
                        [ text "Ouvrir la caisse" ]
                    ]
                ]

        EnService _ ->
            div [ class "w-screen h-screen bg-bg flex flex-col" ]
                [ div [ class "w-full bg-dark text-white p-6 shadow-md" ]
                    [ h1 [ class "font-display font-bold text-2xl uppercase tracking-wide text-primary" ]
                        [ text "Caisse Centrale" ]
                    ]
                , div [ class "flex-1 flex items-center justify-center" ]
                    [ div [ class "text-2xl text-gray-400 font-semibold" ]
                        [ text "Interface de vente à venir..." ]
                    ]
                ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
